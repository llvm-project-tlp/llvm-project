//===- Operation.cpp - Operation support code -----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Operation.h"
#include "mlir/IR/Attributes.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/Matchers.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/OperationSupport.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/TypeUtilities.h"
#include "mlir/Interfaces/FoldInterfaces.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/ErrorHandling.h"
#include <numeric>
#include <optional>

using namespace mlir;

//===----------------------------------------------------------------------===//
// Operation
//===----------------------------------------------------------------------===//

/// Create a new Operation from operation state.
Operation *Operation::create(const OperationState &state) {
  Operation *op =
      create(state.location, state.name, state.types, state.operands,
             state.attributes.getDictionary(state.getContext()),
             state.properties, state.successors, state.regions);
  if (LLVM_UNLIKELY(state.propertiesAttr)) {
    assert(!state.properties);
    LogicalResult result =
        op->setPropertiesFromAttribute(state.propertiesAttr,
                                       /*diagnostic=*/nullptr);
    assert(result.succeeded() && "invalid properties in op creation");
    (void)result;
  }
  return op;
}

/// Create a new Operation with the specific fields.
Operation *Operation::create(Location location, OperationName name,
                             TypeRange resultTypes, ValueRange operands,
                             NamedAttrList &&attributes,
                             OpaqueProperties properties, BlockRange successors,
                             RegionRange regions) {
  unsigned numRegions = regions.size();
  Operation *op =
      create(location, name, resultTypes, operands, std::move(attributes),
             properties, successors, numRegions);
  for (unsigned i = 0; i < numRegions; ++i)
    if (regions[i])
      op->getRegion(i).takeBody(*regions[i]);
  return op;
}

/// Create a new Operation with the specific fields.
Operation *Operation::create(Location location, OperationName name,
                             TypeRange resultTypes, ValueRange operands,
                             NamedAttrList &&attributes,
                             OpaqueProperties properties, BlockRange successors,
                             unsigned numRegions) {
  // Populate default attributes.
  name.populateDefaultAttrs(attributes);

  return create(location, name, resultTypes, operands,
                attributes.getDictionary(location.getContext()), properties,
                successors, numRegions);
}

/// Overload of create that takes an existing DictionaryAttr to avoid
/// unnecessarily uniquing a list of attributes.
Operation *Operation::create(Location location, OperationName name,
                             TypeRange resultTypes, ValueRange operands,
                             DictionaryAttr attributes,
                             OpaqueProperties properties, BlockRange successors,
                             unsigned numRegions) {
  assert(llvm::all_of(resultTypes, [](Type t) { return t; }) &&
         "unexpected null result type");

  // We only need to allocate additional memory for a subset of results.
  unsigned numTrailingResults = OpResult::getNumTrailing(resultTypes.size());
  unsigned numInlineResults = OpResult::getNumInline(resultTypes.size());
  unsigned numSuccessors = successors.size();
  unsigned numOperands = operands.size();
  unsigned numResults = resultTypes.size();
  int opPropertiesAllocSize = llvm::alignTo<8>(name.getOpPropertyByteSize());

  // If the operation is known to have no operands, don't allocate an operand
  // storage.
  bool needsOperandStorage =
      operands.empty() ? !name.hasTrait<OpTrait::ZeroOperands>() : true;

  // Compute the byte size for the operation and the operand storage. This takes
  // into account the size of the operation, its trailing objects, and its
  // prefixed objects.
  size_t byteSize =
      totalSizeToAlloc<detail::OperandStorage, detail::OpProperties,
                       BlockOperand, Region, OpOperand>(
          needsOperandStorage ? 1 : 0, opPropertiesAllocSize, numSuccessors,
          numRegions, numOperands);
  size_t prefixByteSize = llvm::alignTo(
      Operation::prefixAllocSize(numTrailingResults, numInlineResults),
      alignof(Operation));
  char *mallocMem = reinterpret_cast<char *>(malloc(byteSize + prefixByteSize));
  void *rawMem = mallocMem + prefixByteSize;

  // Create the new Operation.
  Operation *op = ::new (rawMem) Operation(
      location, name, numResults, numSuccessors, numRegions,
      opPropertiesAllocSize, attributes, properties, needsOperandStorage);

  assert((numSuccessors == 0 || op->mightHaveTrait<OpTrait::IsTerminator>()) &&
         "unexpected successors in a non-terminator operation");

  // Initialize the results.
  auto resultTypeIt = resultTypes.begin();
  for (unsigned i = 0; i < numInlineResults; ++i, ++resultTypeIt)
    new (op->getInlineOpResult(i)) detail::InlineOpResult(*resultTypeIt, i);
  for (unsigned i = 0; i < numTrailingResults; ++i, ++resultTypeIt) {
    new (op->getOutOfLineOpResult(i))
        detail::OutOfLineOpResult(*resultTypeIt, i);
  }

  // Initialize the regions.
  for (unsigned i = 0; i != numRegions; ++i)
    new (&op->getRegion(i)) Region(op);

  // Initialize the operands.
  if (needsOperandStorage) {
    new (&op->getOperandStorage()) detail::OperandStorage(
        op, op->getTrailingObjects<OpOperand>(), operands);
  }

  // Initialize the successors.
  auto blockOperands = op->getBlockOperands();
  for (unsigned i = 0; i != numSuccessors; ++i)
    new (&blockOperands[i]) BlockOperand(op, successors[i]);

  // This must be done after properties are initalized.
  op->setAttrs(attributes);

  return op;
}

Operation::Operation(Location location, OperationName name, unsigned numResults,
                     unsigned numSuccessors, unsigned numRegions,
                     int fullPropertiesStorageSize, DictionaryAttr attributes,
                     OpaqueProperties properties, bool hasOperandStorage)
    : location(location), numResults(numResults), numSuccs(numSuccessors),
      numRegions(numRegions), hasOperandStorage(hasOperandStorage),
      propertiesStorageSize((fullPropertiesStorageSize + 7) / 8), name(name) {
  assert(attributes && "unexpected null attribute dictionary");
  assert(fullPropertiesStorageSize <= propertiesCapacity &&
         "Properties size overflow");
#ifndef NDEBUG
  if (!getDialect() && !getContext()->allowsUnregisteredDialects())
    llvm::report_fatal_error(
        name.getStringRef() +
        " created with unregistered dialect. If this is intended, please call "
        "allowUnregisteredDialects() on the MLIRContext, or use "
        "-allow-unregistered-dialect with the MLIR tool used.");
#endif
  if (fullPropertiesStorageSize)
    name.initOpProperties(getPropertiesStorage(), properties);
}

// Operations are deleted through the destroy() member because they are
// allocated via malloc.
Operation::~Operation() {
  assert(block == nullptr && "operation destroyed but still in a block");
#ifndef NDEBUG
  if (!use_empty()) {
    {
      InFlightDiagnostic diag =
          emitOpError("operation destroyed but still has uses");
      for (Operation *user : getUsers())
        diag.attachNote(user->getLoc()) << "- use: " << *user << "\n";
    }
    llvm::report_fatal_error("operation destroyed but still has uses");
  }
#endif
  // Explicitly run the destructors for the operands.
  if (hasOperandStorage)
    getOperandStorage().~OperandStorage();

  // Explicitly run the destructors for the successors.
  for (auto &successor : getBlockOperands())
    successor.~BlockOperand();

  // Explicitly destroy the regions.
  for (auto &region : getRegions())
    region.~Region();
  if (propertiesStorageSize)
    name.destroyOpProperties(getPropertiesStorage());
}

/// Destroy this operation or one of its subclasses.
void Operation::destroy() {
  // Operations may have additional prefixed allocation, which needs to be
  // accounted for here when computing the address to free.
  char *rawMem = reinterpret_cast<char *>(this) -
                 llvm::alignTo(prefixAllocSize(), alignof(Operation));
  this->~Operation();
  free(rawMem);
}

/// Return true if this operation is a proper ancestor of the `other`
/// operation.
bool Operation::isProperAncestor(Operation *other) {
  while ((other = other->getParentOp()))
    if (this == other)
      return true;
  return false;
}

/// Replace any uses of 'from' with 'to' within this operation.
void Operation::replaceUsesOfWith(Value from, Value to) {
  if (from == to)
    return;
  for (auto &operand : getOpOperands())
    if (operand.get() == from)
      operand.set(to);
}

/// Replace the current operands of this operation with the ones provided in
/// 'operands'.
void Operation::setOperands(ValueRange operands) {
  if (LLVM_LIKELY(hasOperandStorage))
    return getOperandStorage().setOperands(this, operands);
  assert(operands.empty() && "setting operands without an operand storage");
}

/// Replace the operands beginning at 'start' and ending at 'start' + 'length'
/// with the ones provided in 'operands'. 'operands' may be smaller or larger
/// than the range pointed to by 'start'+'length'.
void Operation::setOperands(unsigned start, unsigned length,
                            ValueRange operands) {
  assert((start + length) <= getNumOperands() &&
         "invalid operand range specified");
  if (LLVM_LIKELY(hasOperandStorage))
    return getOperandStorage().setOperands(this, start, length, operands);
  assert(operands.empty() && "setting operands without an operand storage");
}

/// Insert the given operands into the operand list at the given 'index'.
void Operation::insertOperands(unsigned index, ValueRange operands) {
  if (LLVM_LIKELY(hasOperandStorage))
    return setOperands(index, /*length=*/0, operands);
  assert(operands.empty() && "inserting operands without an operand storage");
}

//===----------------------------------------------------------------------===//
// Diagnostics
//===----------------------------------------------------------------------===//

/// Emit an error about fatal conditions with this operation, reporting up to
/// any diagnostic handlers that may be listening.
InFlightDiagnostic Operation::emitError(const Twine &message) {
  InFlightDiagnostic diag = mlir::emitError(getLoc(), message);
  if (getContext()->shouldPrintOpOnDiagnostic()) {
    diag.attachNote(getLoc())
        .append("see current operation: ")
        .appendOp(*this, OpPrintingFlags().printGenericOpForm());
  }
  return diag;
}

/// Emit a warning about this operation, reporting up to any diagnostic
/// handlers that may be listening.
InFlightDiagnostic Operation::emitWarning(const Twine &message) {
  InFlightDiagnostic diag = mlir::emitWarning(getLoc(), message);
  if (getContext()->shouldPrintOpOnDiagnostic())
    diag.attachNote(getLoc()) << "see current operation: " << *this;
  return diag;
}

/// Emit a remark about this operation, reporting up to any diagnostic
/// handlers that may be listening.
InFlightDiagnostic Operation::emitRemark(const Twine &message) {
  InFlightDiagnostic diag = mlir::emitRemark(getLoc(), message);
  if (getContext()->shouldPrintOpOnDiagnostic())
    diag.attachNote(getLoc()) << "see current operation: " << *this;
  return diag;
}

DictionaryAttr Operation::getAttrDictionary() {
  if (getPropertiesStorageSize()) {
    NamedAttrList attrsList = attrs;
    getName().populateInherentAttrs(this, attrsList);
    return attrsList.getDictionary(getContext());
  }
  return attrs;
}

void Operation::setAttrs(DictionaryAttr newAttrs) {
  assert(newAttrs && "expected valid attribute dictionary");
  if (getPropertiesStorageSize()) {
    // We're spliting the providing DictionaryAttr by removing the inherentAttr
    // which will be stored in the properties.
    SmallVector<NamedAttribute> discardableAttrs;
    discardableAttrs.reserve(newAttrs.size());
    for (NamedAttribute attr : newAttrs) {
      if (getInherentAttr(attr.getName()))
        setInherentAttr(attr.getName(), attr.getValue());
      else
        discardableAttrs.push_back(attr);
    }
    if (discardableAttrs.size() != newAttrs.size())
      newAttrs = DictionaryAttr::get(getContext(), discardableAttrs);
  }
  attrs = newAttrs;
}
void Operation::setAttrs(ArrayRef<NamedAttribute> newAttrs) {
  if (getPropertiesStorageSize()) {
    // We're spliting the providing array of attributes by removing the
    // inherentAttr which will be stored in the properties.
    SmallVector<NamedAttribute> discardableAttrs;
    discardableAttrs.reserve(newAttrs.size());
    for (NamedAttribute attr : newAttrs) {
      if (getInherentAttr(attr.getName()))
        setInherentAttr(attr.getName(), attr.getValue());
      else
        discardableAttrs.push_back(attr);
    }
    attrs = DictionaryAttr::get(getContext(), discardableAttrs);
    return;
  }
  attrs = DictionaryAttr::get(getContext(), newAttrs);
}

std::optional<Attribute> Operation::getInherentAttr(StringRef name) {
  return getName().getInherentAttr(this, name);
}

void Operation::setInherentAttr(StringAttr name, Attribute value) {
  getName().setInherentAttr(this, name, value);
}

Attribute Operation::getPropertiesAsAttribute() {
  std::optional<RegisteredOperationName> info = getRegisteredInfo();
  if (LLVM_UNLIKELY(!info))
    return *getPropertiesStorage().as<Attribute *>();
  return info->getOpPropertiesAsAttribute(this);
}
LogicalResult Operation::setPropertiesFromAttribute(
    Attribute attr, function_ref<InFlightDiagnostic()> emitError) {
  std::optional<RegisteredOperationName> info = getRegisteredInfo();
  if (LLVM_UNLIKELY(!info)) {
    *getPropertiesStorage().as<Attribute *>() = attr;
    return success();
  }
  return info->setOpPropertiesFromAttribute(
      this->getName(), this->getPropertiesStorage(), attr, emitError);
}

void Operation::copyProperties(OpaqueProperties rhs) {
  name.copyOpProperties(getPropertiesStorage(), rhs);
}

llvm::hash_code Operation::hashProperties() {
  return name.hashOpProperties(getPropertiesStorage());
}

//===----------------------------------------------------------------------===//
// Operation Ordering
//===----------------------------------------------------------------------===//

constexpr unsigned Operation::kInvalidOrderIdx;
constexpr unsigned Operation::kOrderStride;

/// Given an operation 'other' that is within the same parent block, return
/// whether the current operation is before 'other' in the operation list
/// of the parent block.
/// Note: This function has an average complexity of O(1), but worst case may
/// take O(N) where N is the number of operations within the parent block.
bool Operation::isBeforeInBlock(Operation *other) {
  assert(block && "Operations without parent blocks have no order.");
  assert(other && other->block == block &&
         "Expected other operation to have the same parent block.");
  // If the order of the block is already invalid, directly recompute the
  // parent.
  if (!block->isOpOrderValid()) {
    block->recomputeOpOrder();
  } else {
    // Update the order either operation if necessary.
    updateOrderIfNecessary();
    other->updateOrderIfNecessary();
  }

  return orderIndex < other->orderIndex;
}

/// Update the order index of this operation of this operation if necessary,
/// potentially recomputing the order of the parent block.
void Operation::updateOrderIfNecessary() {
  assert(block && "expected valid parent");

  // If the order is valid for this operation there is nothing to do.
  if (hasValidOrder() || llvm::hasSingleElement(*block))
    return;
  Operation *blockFront = &block->front();
  Operation *blockBack = &block->back();

  // This method is expected to only be invoked on blocks with more than one
  // operation.
  assert(blockFront != blockBack && "expected more than one operation");

  // If the operation is at the end of the block.
  if (this == blockBack) {
    Operation *prevNode = getPrevNode();
    if (!prevNode->hasValidOrder())
      return block->recomputeOpOrder();

    // Add the stride to the previous operation.
    orderIndex = prevNode->orderIndex + kOrderStride;
    return;
  }

  // If this is the first operation try to use the next operation to compute the
  // ordering.
  if (this == blockFront) {
    Operation *nextNode = getNextNode();
    if (!nextNode->hasValidOrder())
      return block->recomputeOpOrder();
    // There is no order to give this operation.
    if (nextNode->orderIndex == 0)
      return block->recomputeOpOrder();

    // If we can't use the stride, just take the middle value left. This is safe
    // because we know there is at least one valid index to assign to.
    if (nextNode->orderIndex <= kOrderStride)
      orderIndex = (nextNode->orderIndex / 2);
    else
      orderIndex = kOrderStride;
    return;
  }

  // Otherwise, this operation is between two others. Place this operation in
  // the middle of the previous and next if possible.
  Operation *prevNode = getPrevNode(), *nextNode = getNextNode();
  if (!prevNode->hasValidOrder() || !nextNode->hasValidOrder())
    return block->recomputeOpOrder();
  unsigned prevOrder = prevNode->orderIndex, nextOrder = nextNode->orderIndex;

  // Check to see if there is a valid order between the two.
  if (prevOrder + 1 == nextOrder)
    return block->recomputeOpOrder();
  orderIndex = prevOrder + ((nextOrder - prevOrder) / 2);
}

//===----------------------------------------------------------------------===//
// ilist_traits for Operation
//===----------------------------------------------------------------------===//

auto llvm::ilist_detail::SpecificNodeAccess<
    typename llvm::ilist_detail::compute_node_options<
        ::mlir::Operation>::type>::getNodePtr(pointer n) -> node_type * {
  return NodeAccess::getNodePtr<OptionsT>(n);
}

auto llvm::ilist_detail::SpecificNodeAccess<
    typename llvm::ilist_detail::compute_node_options<
        ::mlir::Operation>::type>::getNodePtr(const_pointer n)
    -> const node_type * {
  return NodeAccess::getNodePtr<OptionsT>(n);
}

auto llvm::ilist_detail::SpecificNodeAccess<
    typename llvm::ilist_detail::compute_node_options<
        ::mlir::Operation>::type>::getValuePtr(node_type *n) -> pointer {
  return NodeAccess::getValuePtr<OptionsT>(n);
}

auto llvm::ilist_detail::SpecificNodeAccess<
    typename llvm::ilist_detail::compute_node_options<
        ::mlir::Operation>::type>::getValuePtr(const node_type *n)
    -> const_pointer {
  return NodeAccess::getValuePtr<OptionsT>(n);
}

void llvm::ilist_traits<::mlir::Operation>::deleteNode(Operation *op) {
  op->destroy();
}

Block *llvm::ilist_traits<::mlir::Operation>::getContainingBlock() {
  size_t offset(size_t(&((Block *)nullptr->*Block::getSublistAccess(nullptr))));
  iplist<Operation> *anchor(static_cast<iplist<Operation> *>(this));
  return reinterpret_cast<Block *>(reinterpret_cast<char *>(anchor) - offset);
}

/// This is a trait method invoked when an operation is added to a block.  We
/// keep the block pointer up to date.
void llvm::ilist_traits<::mlir::Operation>::addNodeToList(Operation *op) {
  assert(!op->getBlock() && "already in an operation block!");
  op->block = getContainingBlock();

  // Invalidate the order on the operation.
  op->orderIndex = Operation::kInvalidOrderIdx;
}

/// This is a trait method invoked when an operation is removed from a block.
/// We keep the block pointer up to date.
void llvm::ilist_traits<::mlir::Operation>::removeNodeFromList(Operation *op) {
  assert(op->block && "not already in an operation block!");
  op->block = nullptr;
}

/// This is a trait method invoked when an operation is moved from one block
/// to another.  We keep the block pointer up to date.
void llvm::ilist_traits<::mlir::Operation>::transferNodesFromList(
    ilist_traits<Operation> &otherList, op_iterator first, op_iterator last) {
  Block *curParent = getContainingBlock();

  // Invalidate the ordering of the parent block.
  curParent->invalidateOpOrder();

  // If we are transferring operations within the same block, the block
  // pointer doesn't need to be updated.
  if (curParent == otherList.getContainingBlock())
    return;

  // Update the 'block' member of each operation.
  for (; first != last; ++first)
    first->block = curParent;
}

/// Remove this operation (and its descendants) from its Block and delete
/// all of them.
void Operation::erase() {
  if (auto *parent = getBlock())
    parent->getOperations().erase(this);
  else
    destroy();
}

/// Remove the operation from its parent block, but don't delete it.
void Operation::remove() {
  if (Block *parent = getBlock())
    parent->getOperations().remove(this);
}

/// Unlink this operation from its current block and insert it right before
/// `existingOp` which may be in the same or another block in the same
/// function.
void Operation::moveBefore(Operation *existingOp) {
  moveBefore(existingOp->getBlock(), existingOp->getIterator());
}

/// Unlink this operation from its current basic block and insert it right
/// before `iterator` in the specified basic block.
void Operation::moveBefore(Block *block,
                           llvm::iplist<Operation>::iterator iterator) {
  assert(getBlock() &&
         "cannot move an operation that isn't contained in a block");
  block->getOperations().splice(iterator, getBlock()->getOperations(),
                                getIterator());
}

/// Unlink this operation from its current block and insert it right after
/// `existingOp` which may be in the same or another block in the same function.
void Operation::moveAfter(Operation *existingOp) {
  moveAfter(existingOp->getBlock(), existingOp->getIterator());
}

/// Unlink this operation from its current block and insert it right after
/// `iterator` in the specified block.
void Operation::moveAfter(Block *block,
                          llvm::iplist<Operation>::iterator iterator) {
  assert(iterator != block->end() && "cannot move after end of block");
  moveBefore(block, std::next(iterator));
}

/// This drops all operand uses from this operation, which is an essential
/// step in breaking cyclic dependences between references when they are to
/// be deleted.
void Operation::dropAllReferences() {
  for (auto &op : getOpOperands())
    op.drop();

  for (auto &region : getRegions())
    region.dropAllReferences();

  for (auto &dest : getBlockOperands())
    dest.drop();
}

/// This drops all uses of any values defined by this operation or its nested
/// regions, wherever they are located.
void Operation::dropAllDefinedValueUses() {
  dropAllUses();

  for (auto &region : getRegions())
    for (auto &block : region)
      block.dropAllDefinedValueUses();
}

void Operation::setSuccessor(Block *block, unsigned index) {
  assert(index < getNumSuccessors());
  getBlockOperands()[index].set(block);
}

#ifndef NDEBUG
/// Assert that the folded results (in case of values) have the same type as
/// the results of the given op.
static void checkFoldResultTypes(Operation *op,
                                 SmallVectorImpl<OpFoldResult> &results) {
  if (results.empty())
    return;

  for (auto [ofr, opResult] : llvm::zip_equal(results, op->getResults())) {
    if (auto value = dyn_cast<Value>(ofr)) {
      if (value.getType() != opResult.getType()) {
        op->emitOpError() << "folder produced a value of incorrect type: "
                          << value.getType()
                          << ", expected: " << opResult.getType();
        assert(false && "incorrect fold result type");
      }
    }
  }
}
#endif // NDEBUG

/// Attempt to fold this operation using the Op's registered foldHook.
LogicalResult Operation::fold(ArrayRef<Attribute> operands,
                              SmallVectorImpl<OpFoldResult> &results) {
  // If we have a registered operation definition matching this one, use it to
  // try to constant fold the operation.
  if (succeeded(name.foldHook(this, operands, results))) {
#ifndef NDEBUG
    checkFoldResultTypes(this, results);
#endif // NDEBUG
    return success();
  }

  // Otherwise, fall back on the dialect hook to handle it.
  Dialect *dialect = getDialect();
  if (!dialect)
    return failure();

  auto *interface = dyn_cast<DialectFoldInterface>(dialect);
  if (!interface)
    return failure();

  LogicalResult status = interface->fold(this, operands, results);
#ifndef NDEBUG
  if (succeeded(status))
    checkFoldResultTypes(this, results);
#endif // NDEBUG
  return status;
}

LogicalResult Operation::fold(SmallVectorImpl<OpFoldResult> &results) {
  // Check if any operands are constants.
  SmallVector<Attribute> constants;
  constants.assign(getNumOperands(), Attribute());
  for (unsigned i = 0, e = getNumOperands(); i != e; ++i)
    matchPattern(getOperand(i), m_Constant(&constants[i]));
  return fold(constants, results);
}

/// Emit an error with the op name prefixed, like "'dim' op " which is
/// convenient for verifiers.
InFlightDiagnostic Operation::emitOpError(const Twine &message) {
  return emitError() << "'" << getName() << "' op " << message;
}

//===----------------------------------------------------------------------===//
// Operation Cloning
//===----------------------------------------------------------------------===//

Operation::CloneOptions::CloneOptions()
    : cloneRegionsFlag(false), cloneOperandsFlag(false) {}

Operation::CloneOptions::CloneOptions(bool cloneRegions, bool cloneOperands)
    : cloneRegionsFlag(cloneRegions), cloneOperandsFlag(cloneOperands) {}

Operation::CloneOptions Operation::CloneOptions::all() {
  return CloneOptions().cloneRegions().cloneOperands();
}

Operation::CloneOptions &Operation::CloneOptions::cloneRegions(bool enable) {
  cloneRegionsFlag = enable;
  return *this;
}

Operation::CloneOptions &Operation::CloneOptions::cloneOperands(bool enable) {
  cloneOperandsFlag = enable;
  return *this;
}

/// Create a deep copy of this operation but keep the operation regions empty.
/// Operands are remapped using `mapper` (if present), and `mapper` is updated
/// to contain the results. The `mapResults` flag specifies whether the results
/// of the cloned operation should be added to the map.
Operation *Operation::cloneWithoutRegions(IRMapping &mapper) {
  return clone(mapper, CloneOptions::all().cloneRegions(false));
}

Operation *Operation::cloneWithoutRegions() {
  IRMapping mapper;
  return cloneWithoutRegions(mapper);
}

/// Create a deep copy of this operation, remapping any operands that use
/// values outside of the operation using the map that is provided (leaving
/// them alone if no entry is present).  Replaces references to cloned
/// sub-operations to the corresponding operation that is copied, and adds
/// those mappings to the map.
Operation *Operation::clone(IRMapping &mapper, CloneOptions options) {
  SmallVector<Value, 8> operands;
  SmallVector<Block *, 2> successors;

  // Remap the operands.
  if (options.shouldCloneOperands()) {
    operands.reserve(getNumOperands());
    for (auto opValue : getOperands())
      operands.push_back(mapper.lookupOrDefault(opValue));
  }

  // Remap the successors.
  successors.reserve(getNumSuccessors());
  for (Block *successor : getSuccessors())
    successors.push_back(mapper.lookupOrDefault(successor));

  // Create the new operation.
  auto *newOp = create(getLoc(), getName(), getResultTypes(), operands, attrs,
                       getPropertiesStorage(), successors, getNumRegions());
  mapper.map(this, newOp);

  // Clone the regions.
  if (options.shouldCloneRegions()) {
    for (unsigned i = 0; i != numRegions; ++i)
      getRegion(i).cloneInto(&newOp->getRegion(i), mapper);
  }

  // Remember the mapping of any results.
  for (unsigned i = 0, e = getNumResults(); i != e; ++i)
    mapper.map(getResult(i), newOp->getResult(i));

  return newOp;
}

Operation *Operation::clone(CloneOptions options) {
  IRMapping mapper;
  return clone(mapper, options);
}

//===----------------------------------------------------------------------===//
// OpState trait class.
//===----------------------------------------------------------------------===//

// The fallback for the parser is to try for a dialect operation parser.
// Otherwise, reject the custom assembly form.
ParseResult OpState::parse(OpAsmParser &parser, OperationState &result) {
  if (auto parseFn = result.name.getDialect()->getParseOperationHook(
          result.name.getStringRef()))
    return (*parseFn)(parser, result);
  return parser.emitError(parser.getNameLoc(), "has no custom assembly form");
}

// The fallback for the printer is to try for a dialect operation printer.
// Otherwise, it prints the generic form.
void OpState::print(Operation *op, OpAsmPrinter &p, StringRef defaultDialect) {
  if (auto printFn = op->getDialect()->getOperationPrinter(op)) {
    printOpName(op, p, defaultDialect);
    printFn(op, p);
  } else {
    p.printGenericOp(op);
  }
}

/// Print an operation name, eliding the dialect prefix if necessary and doesn't
/// lead to ambiguities.
void OpState::printOpName(Operation *op, OpAsmPrinter &p,
                          StringRef defaultDialect) {
  StringRef name = op->getName().getStringRef();
  if (name.starts_with((defaultDialect + ".").str()) && name.count('.') == 1)
    name = name.drop_front(defaultDialect.size() + 1);
  p.getStream() << name;
}

/// Parse properties as a Attribute.
ParseResult OpState::genericParseProperties(OpAsmParser &parser,
                                            Attribute &result) {
  if (succeeded(parser.parseOptionalLess())) { // The less is optional.
    if (parser.parseAttribute(result) || parser.parseGreater())
      return failure();
  }
  return success();
}

/// Print the properties as a Attribute with names not included within
/// 'elidedProps'
void OpState::genericPrintProperties(OpAsmPrinter &p, Attribute properties,
                                     ArrayRef<StringRef> elidedProps) {
  if (!properties)
    return;
  auto dictAttr = dyn_cast_or_null<::mlir::DictionaryAttr>(properties);
  if (dictAttr && !elidedProps.empty()) {
    ArrayRef<NamedAttribute> attrs = dictAttr.getValue();
    llvm::SmallDenseSet<StringRef> elidedAttrsSet(elidedProps.begin(),
                                                  elidedProps.end());
    auto filteredAttrs =
        llvm::make_filter_range(attrs, [&](NamedAttribute attr) {
          return !elidedAttrsSet.contains(attr.getName().strref());
        });
    if (!filteredAttrs.empty()) {
      p << "<{";
      interleaveComma(filteredAttrs, p, [&](NamedAttribute attr) {
        p.printNamedAttribute(attr);
      });
      p << "}>";
    }
  } else {
    p << "<" << properties << ">";
  }
}

/// Emit an error about fatal conditions with this operation, reporting up to
/// any diagnostic handlers that may be listening.
InFlightDiagnostic OpState::emitError(const Twine &message) {
  return getOperation()->emitError(message);
}

/// Emit an error with the op name prefixed, like "'dim' op " which is
/// convenient for verifiers.
InFlightDiagnostic OpState::emitOpError(const Twine &message) {
  return getOperation()->emitOpError(message);
}

/// Emit a warning about this operation, reporting up to any diagnostic
/// handlers that may be listening.
InFlightDiagnostic OpState::emitWarning(const Twine &message) {
  return getOperation()->emitWarning(message);
}

/// Emit a remark about this operation, reporting up to any diagnostic
/// handlers that may be listening.
InFlightDiagnostic OpState::emitRemark(const Twine &message) {
  return getOperation()->emitRemark(message);
}

//===----------------------------------------------------------------------===//
// Op Trait implementations
//===----------------------------------------------------------------------===//

LogicalResult
OpTrait::impl::foldCommutative(Operation *op, ArrayRef<Attribute> operands,
                               SmallVectorImpl<OpFoldResult> &results) {
  // Nothing to fold if there are not at least 2 operands.
  if (op->getNumOperands() < 2)
    return failure();
  // Move all constant operands to the end.
  OpOperand *operandsBegin = op->getOpOperands().begin();
  auto isNonConstant = [&](OpOperand &o) {
    return !static_cast<bool>(operands[std::distance(operandsBegin, &o)]);
  };
  auto *firstConstantIt = llvm::find_if_not(op->getOpOperands(), isNonConstant);
  auto *newConstantIt = std::stable_partition(
      firstConstantIt, op->getOpOperands().end(), isNonConstant);
  // Return success if the op was modified.
  return success(firstConstantIt != newConstantIt);
}

OpFoldResult OpTrait::impl::foldIdempotent(Operation *op) {
  if (op->getNumOperands() == 1) {
    auto *argumentOp = op->getOperand(0).getDefiningOp();
    if (argumentOp && op->getName() == argumentOp->getName()) {
      // Replace the outer operation output with the inner operation.
      return op->getOperand(0);
    }
  } else if (op->getOperand(0) == op->getOperand(1)) {
    return op->getOperand(0);
  }

  return {};
}

OpFoldResult OpTrait::impl::foldInvolution(Operation *op) {
  auto *argumentOp = op->getOperand(0).getDefiningOp();
  if (argumentOp && op->getName() == argumentOp->getName()) {
    // Replace the outer involutions output with inner's input.
    return argumentOp->getOperand(0);
  }

  return {};
}

LogicalResult OpTrait::impl::verifyZeroOperands(Operation *op) {
  if (op->getNumOperands() != 0)
    return op->emitOpError() << "requires zero operands";
  return success();
}

LogicalResult OpTrait::impl::verifyOneOperand(Operation *op) {
  if (op->getNumOperands() != 1)
    return op->emitOpError() << "requires a single operand";
  return success();
}

LogicalResult OpTrait::impl::verifyNOperands(Operation *op,
                                             unsigned numOperands) {
  if (op->getNumOperands() != numOperands) {
    return op->emitOpError() << "expected " << numOperands
                             << " operands, but found " << op->getNumOperands();
  }
  return success();
}

LogicalResult OpTrait::impl::verifyAtLeastNOperands(Operation *op,
                                                    unsigned numOperands) {
  if (op->getNumOperands() < numOperands)
    return op->emitOpError()
           << "expected " << numOperands << " or more operands, but found "
           << op->getNumOperands();
  return success();
}

/// If this is a vector type, or a tensor type, return the scalar element type
/// that it is built around, otherwise return the type unmodified.
static Type getTensorOrVectorElementType(Type type) {
  if (auto vec = llvm::dyn_cast<VectorType>(type))
    return vec.getElementType();

  // Look through tensor<vector<...>> to find the underlying element type.
  if (auto tensor = llvm::dyn_cast<TensorType>(type))
    return getTensorOrVectorElementType(tensor.getElementType());
  return type;
}

LogicalResult OpTrait::impl::verifyIsIdempotent(Operation *op) {
  // FIXME: Add back check for no side effects on operation.
  // Currently adding it would cause the shared library build
  // to fail since there would be a dependency of IR on SideEffectInterfaces
  // which is cyclical.
  return success();
}

LogicalResult OpTrait::impl::verifyIsInvolution(Operation *op) {
  // FIXME: Add back check for no side effects on operation.
  // Currently adding it would cause the shared library build
  // to fail since there would be a dependency of IR on SideEffectInterfaces
  // which is cyclical.
  return success();
}

LogicalResult
OpTrait::impl::verifyOperandsAreSignlessIntegerLike(Operation *op) {
  for (auto opType : op->getOperandTypes()) {
    auto type = getTensorOrVectorElementType(opType);
    if (!type.isSignlessIntOrIndex())
      return op->emitOpError() << "requires an integer or index type";
  }
  return success();
}

LogicalResult OpTrait::impl::verifyOperandsAreFloatLike(Operation *op) {
  for (auto opType : op->getOperandTypes()) {
    auto type = getTensorOrVectorElementType(opType);
    if (!llvm::isa<FloatType>(type))
      return op->emitOpError("requires a float type");
  }
  return success();
}

LogicalResult OpTrait::impl::verifySameTypeOperands(Operation *op) {
  // Zero or one operand always have the "same" type.
  unsigned nOperands = op->getNumOperands();
  if (nOperands < 2)
    return success();

  auto type = op->getOperand(0).getType();
  for (auto opType : llvm::drop_begin(op->getOperandTypes(), 1))
    if (opType != type)
      return op->emitOpError() << "requires all operands to have the same type";
  return success();
}

LogicalResult OpTrait::impl::verifyZeroRegions(Operation *op) {
  if (op->getNumRegions() != 0)
    return op->emitOpError() << "requires zero regions";
  return success();
}

LogicalResult OpTrait::impl::verifyOneRegion(Operation *op) {
  if (op->getNumRegions() != 1)
    return op->emitOpError() << "requires one region";
  return success();
}

LogicalResult OpTrait::impl::verifyNRegions(Operation *op,
                                            unsigned numRegions) {
  if (op->getNumRegions() != numRegions)
    return op->emitOpError() << "expected " << numRegions << " regions";
  return success();
}

LogicalResult OpTrait::impl::verifyAtLeastNRegions(Operation *op,
                                                   unsigned numRegions) {
  if (op->getNumRegions() < numRegions)
    return op->emitOpError() << "expected " << numRegions << " or more regions";
  return success();
}

LogicalResult OpTrait::impl::verifyZeroResults(Operation *op) {
  if (op->getNumResults() != 0)
    return op->emitOpError() << "requires zero results";
  return success();
}

LogicalResult OpTrait::impl::verifyOneResult(Operation *op) {
  if (op->getNumResults() != 1)
    return op->emitOpError() << "requires one result";
  return success();
}

LogicalResult OpTrait::impl::verifyNResults(Operation *op,
                                            unsigned numOperands) {
  if (op->getNumResults() != numOperands)
    return op->emitOpError() << "expected " << numOperands << " results";
  return success();
}

LogicalResult OpTrait::impl::verifyAtLeastNResults(Operation *op,
                                                   unsigned numOperands) {
  if (op->getNumResults() < numOperands)
    return op->emitOpError()
           << "expected " << numOperands << " or more results";
  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsShape(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)))
    return failure();

  if (failed(verifyCompatibleShapes(op->getOperandTypes())))
    return op->emitOpError() << "requires the same shape for all operands";

  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsAndResultShape(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)) ||
      failed(verifyAtLeastNResults(op, 1)))
    return failure();

  SmallVector<Type, 8> types(op->getOperandTypes());
  types.append(llvm::to_vector<4>(op->getResultTypes()));

  if (failed(verifyCompatibleShapes(types)))
    return op->emitOpError()
           << "requires the same shape for all operands and results";

  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsElementType(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)))
    return failure();
  auto elementType = getElementTypeOrSelf(op->getOperand(0));

  for (auto operand : llvm::drop_begin(op->getOperands(), 1)) {
    if (getElementTypeOrSelf(operand) != elementType)
      return op->emitOpError("requires the same element type for all operands");
  }

  return success();
}

LogicalResult
OpTrait::impl::verifySameOperandsAndResultElementType(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)) ||
      failed(verifyAtLeastNResults(op, 1)))
    return failure();

  auto elementType = getElementTypeOrSelf(op->getResult(0));

  // Verify result element type matches first result's element type.
  for (auto result : llvm::drop_begin(op->getResults(), 1)) {
    if (getElementTypeOrSelf(result) != elementType)
      return op->emitOpError(
          "requires the same element type for all operands and results");
  }

  // Verify operand's element type matches first result's element type.
  for (auto operand : op->getOperands()) {
    if (getElementTypeOrSelf(operand) != elementType)
      return op->emitOpError(
          "requires the same element type for all operands and results");
  }

  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsAndResultType(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)) ||
      failed(verifyAtLeastNResults(op, 1)))
    return failure();

  auto type = op->getResult(0).getType();
  auto elementType = getElementTypeOrSelf(type);
  Attribute encoding = nullptr;
  if (auto rankedType = dyn_cast<RankedTensorType>(type))
    encoding = rankedType.getEncoding();
  for (auto resultType : llvm::drop_begin(op->getResultTypes())) {
    if (getElementTypeOrSelf(resultType) != elementType ||
        failed(verifyCompatibleShape(resultType, type)))
      return op->emitOpError()
             << "requires the same type for all operands and results";
    if (encoding)
      if (auto rankedType = dyn_cast<RankedTensorType>(resultType);
          encoding != rankedType.getEncoding())
        return op->emitOpError()
               << "requires the same encoding for all operands and results";
  }
  for (auto opType : op->getOperandTypes()) {
    if (getElementTypeOrSelf(opType) != elementType ||
        failed(verifyCompatibleShape(opType, type)))
      return op->emitOpError()
             << "requires the same type for all operands and results";
    if (encoding)
      if (auto rankedType = dyn_cast<RankedTensorType>(opType);
          encoding != rankedType.getEncoding())
        return op->emitOpError()
               << "requires the same encoding for all operands and results";
  }
  return success();
}

LogicalResult OpTrait::impl::verifySameOperandsAndResultRank(Operation *op) {
  if (failed(verifyAtLeastNOperands(op, 1)))
    return failure();

  // delegate function that returns true if type is a shaped type with known
  // rank
  auto hasRank = [](const Type type) {
    if (auto shapedType = dyn_cast<ShapedType>(type))
      return shapedType.hasRank();

    return false;
  };

  auto rankedOperandTypes =
      llvm::make_filter_range(op->getOperandTypes(), hasRank);
  auto rankedResultTypes =
      llvm::make_filter_range(op->getResultTypes(), hasRank);

  // If all operands and results are unranked, then no further verification.
  if (rankedOperandTypes.empty() && rankedResultTypes.empty())
    return success();

  // delegate function that returns rank of shaped type with known rank
  auto getRank = [](const Type type) {
    return cast<ShapedType>(type).getRank();
  };

  auto rank = !rankedOperandTypes.empty() ? getRank(*rankedOperandTypes.begin())
                                          : getRank(*rankedResultTypes.begin());

  for (const auto type : rankedOperandTypes) {
    if (rank != getRank(type)) {
      return op->emitOpError("operands don't have matching ranks");
    }
  }

  for (const auto type : rankedResultTypes) {
    if (rank != getRank(type)) {
      return op->emitOpError("result type has different rank than operands");
    }
  }

  return success();
}

LogicalResult OpTrait::impl::verifyIsTerminator(Operation *op) {
  Block *block = op->getBlock();
  // Verify that the operation is at the end of the respective parent block.
  if (!block || &block->back() != op)
    return op->emitOpError("must be the last operation in the parent block");
  return success();
}

static LogicalResult verifyTerminatorSuccessors(Operation *op) {
  auto *parent = op->getParentRegion();

  // Verify that the operands lines up with the BB arguments in the successor.
  for (Block *succ : op->getSuccessors())
    if (succ->getParent() != parent)
      return op->emitError("reference to block defined in another region");
  return success();
}

LogicalResult OpTrait::impl::verifyZeroSuccessors(Operation *op) {
  if (op->getNumSuccessors() != 0) {
    return op->emitOpError("requires 0 successors but found ")
           << op->getNumSuccessors();
  }
  return success();
}

LogicalResult OpTrait::impl::verifyOneSuccessor(Operation *op) {
  if (op->getNumSuccessors() != 1) {
    return op->emitOpError("requires 1 successor but found ")
           << op->getNumSuccessors();
  }
  return verifyTerminatorSuccessors(op);
}
LogicalResult OpTrait::impl::verifyNSuccessors(Operation *op,
                                               unsigned numSuccessors) {
  if (op->getNumSuccessors() != numSuccessors) {
    return op->emitOpError("requires ")
           << numSuccessors << " successors but found "
           << op->getNumSuccessors();
  }
  return verifyTerminatorSuccessors(op);
}
LogicalResult OpTrait::impl::verifyAtLeastNSuccessors(Operation *op,
                                                      unsigned numSuccessors) {
  if (op->getNumSuccessors() < numSuccessors) {
    return op->emitOpError("requires at least ")
           << numSuccessors << " successors but found "
           << op->getNumSuccessors();
  }
  return verifyTerminatorSuccessors(op);
}

LogicalResult OpTrait::impl::verifyResultsAreBoolLike(Operation *op) {
  for (auto resultType : op->getResultTypes()) {
    auto elementType = getTensorOrVectorElementType(resultType);
    bool isBoolType = elementType.isInteger(1);
    if (!isBoolType)
      return op->emitOpError() << "requires a bool result type";
  }

  return success();
}

LogicalResult OpTrait::impl::verifyResultsAreFloatLike(Operation *op) {
  for (auto resultType : op->getResultTypes())
    if (!llvm::isa<FloatType>(getTensorOrVectorElementType(resultType)))
      return op->emitOpError() << "requires a floating point type";

  return success();
}

LogicalResult
OpTrait::impl::verifyResultsAreSignlessIntegerLike(Operation *op) {
  for (auto resultType : op->getResultTypes())
    if (!getTensorOrVectorElementType(resultType).isSignlessIntOrIndex())
      return op->emitOpError() << "requires an integer or index type";
  return success();
}

LogicalResult OpTrait::impl::verifyValueSizeAttr(Operation *op,
                                                 StringRef attrName,
                                                 StringRef valueGroupName,
                                                 size_t expectedCount) {
  auto sizeAttr = op->getAttrOfType<DenseI32ArrayAttr>(attrName);
  if (!sizeAttr)
    return op->emitOpError("requires dense i32 array attribute '")
           << attrName << "'";

  ArrayRef<int32_t> sizes = sizeAttr.asArrayRef();
  if (llvm::any_of(sizes, [](int32_t element) { return element < 0; }))
    return op->emitOpError("'")
           << attrName << "' attribute cannot have negative elements";

  size_t totalCount =
      std::accumulate(sizes.begin(), sizes.end(), 0,
                      [](unsigned all, int32_t one) { return all + one; });

  if (totalCount != expectedCount)
    return op->emitOpError()
           << valueGroupName << " count (" << expectedCount
           << ") does not match with the total size (" << totalCount
           << ") specified in attribute '" << attrName << "'";
  return success();
}

LogicalResult OpTrait::impl::verifyOperandSizeAttr(Operation *op,
                                                   StringRef attrName) {
  return verifyValueSizeAttr(op, attrName, "operand", op->getNumOperands());
}

LogicalResult OpTrait::impl::verifyResultSizeAttr(Operation *op,
                                                  StringRef attrName) {
  return verifyValueSizeAttr(op, attrName, "result", op->getNumResults());
}

LogicalResult OpTrait::impl::verifyNoRegionArguments(Operation *op) {
  for (Region &region : op->getRegions()) {
    if (region.empty())
      continue;

    if (region.getNumArguments() != 0) {
      if (op->getNumRegions() > 1)
        return op->emitOpError("region #")
               << region.getRegionNumber() << " should have no arguments";
      return op->emitOpError("region should have no arguments");
    }
  }
  return success();
}

LogicalResult OpTrait::impl::verifyElementwise(Operation *op) {
  auto isMappableType = llvm::IsaPred<VectorType, TensorType>;
  auto resultMappableTypes =
      llvm::filter_to_vector<1>(op->getResultTypes(), isMappableType);
  auto operandMappableTypes =
      llvm::filter_to_vector<2>(op->getOperandTypes(), isMappableType);

  // If the op only has scalar operand/result types, then we have nothing to
  // check.
  if (resultMappableTypes.empty() && operandMappableTypes.empty())
    return success();

  if (!resultMappableTypes.empty() && operandMappableTypes.empty())
    return op->emitOpError("if a result is non-scalar, then at least one "
                           "operand must be non-scalar");

  assert(!operandMappableTypes.empty());

  if (resultMappableTypes.empty())
    return op->emitOpError("if an operand is non-scalar, then there must be at "
                           "least one non-scalar result");

  if (resultMappableTypes.size() != op->getNumResults())
    return op->emitOpError(
        "if an operand is non-scalar, then all results must be non-scalar");

  SmallVector<Type, 4> types = llvm::to_vector<2>(
      llvm::concat<Type>(operandMappableTypes, resultMappableTypes));
  TypeID expectedBaseTy = types.front().getTypeID();
  if (!llvm::all_of(types,
                    [&](Type t) { return t.getTypeID() == expectedBaseTy; }) ||
      failed(verifyCompatibleShapes(types))) {
    return op->emitOpError() << "all non-scalar operands/results must have the "
                                "same shape and base type";
  }

  return success();
}

/// Check for any values used by operations regions attached to the
/// specified "IsIsolatedFromAbove" operation defined outside of it.
LogicalResult OpTrait::impl::verifyIsIsolatedFromAbove(Operation *isolatedOp) {
  assert(isolatedOp->hasTrait<OpTrait::IsIsolatedFromAbove>() &&
         "Intended to check IsolatedFromAbove ops");

  // List of regions to analyze.  Each region is processed independently, with
  // respect to the common `limit` region, so we can look at them in any order.
  // Therefore, use a simple vector and push/pop back the current region.
  SmallVector<Region *, 8> pendingRegions;
  for (auto &region : isolatedOp->getRegions()) {
    pendingRegions.push_back(&region);

    // Traverse all operations in the region.
    while (!pendingRegions.empty()) {
      for (Operation &op : pendingRegions.pop_back_val()->getOps()) {
        for (Value operand : op.getOperands()) {
          // Check that any value that is used by an operation is defined in the
          // same region as either an operation result.
          auto *operandRegion = operand.getParentRegion();
          if (!operandRegion)
            return op.emitError("operation's operand is unlinked");
          if (!region.isAncestor(operandRegion)) {
            return op.emitOpError("using value defined outside the region")
                       .attachNote(isolatedOp->getLoc())
                   << "required by region isolation constraints";
          }
        }

        // Schedule any regions in the operation for further checking.  Don't
        // recurse into other IsolatedFromAbove ops, because they will check
        // themselves.
        if (op.getNumRegions() &&
            !op.hasTrait<OpTrait::IsIsolatedFromAbove>()) {
          for (Region &subRegion : op.getRegions())
            pendingRegions.push_back(&subRegion);
        }
      }
    }
  }

  return success();
}

bool OpTrait::hasElementwiseMappableTraits(Operation *op) {
  return op->hasTrait<Elementwise>() && op->hasTrait<Scalarizable>() &&
         op->hasTrait<Vectorizable>() && op->hasTrait<Tensorizable>();
}

//===----------------------------------------------------------------------===//
// Misc. utils
//===----------------------------------------------------------------------===//

/// Insert an operation, generated by `buildTerminatorOp`, at the end of the
/// region's only block if it does not have a terminator already. If the region
/// is empty, insert a new block first. `buildTerminatorOp` should return the
/// terminator operation to insert.
void impl::ensureRegionTerminator(
    Region &region, OpBuilder &builder, Location loc,
    function_ref<Operation *(OpBuilder &, Location)> buildTerminatorOp) {
  OpBuilder::InsertionGuard guard(builder);
  if (region.empty())
    builder.createBlock(&region);

  Block &block = region.back();
  if (!block.empty() && block.back().hasTrait<OpTrait::IsTerminator>())
    return;

  builder.setInsertionPointToEnd(&block);
  builder.insert(buildTerminatorOp(builder, loc));
}

/// Create a simple OpBuilder and forward to the OpBuilder version of this
/// function.
void impl::ensureRegionTerminator(
    Region &region, Builder &builder, Location loc,
    function_ref<Operation *(OpBuilder &, Location)> buildTerminatorOp) {
  OpBuilder opBuilder(builder.getContext());
  ensureRegionTerminator(region, opBuilder, loc, buildTerminatorOp);
}
