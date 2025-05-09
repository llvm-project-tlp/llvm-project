//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___TYPE_TRAITS_IS_TRIVIALLY_COPYABLE_H
#define _LIBCPP___TYPE_TRAITS_IS_TRIVIALLY_COPYABLE_H

#include <__config>
#include <__type_traits/integral_constant.h>
#include <cstdint>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

_LIBCPP_BEGIN_NAMESPACE_STD

template <class _Tp>
struct _LIBCPP_NO_SPECIALIZATIONS is_trivially_copyable : integral_constant<bool, __is_trivially_copyable(_Tp)> {};

#if _LIBCPP_STD_VER >= 17
template <class _Tp>
_LIBCPP_NO_SPECIALIZATIONS inline constexpr bool is_trivially_copyable_v = __is_trivially_copyable(_Tp);
#endif

template <class _Tp>
inline const bool __is_cheap_to_copy = __is_trivially_copyable(_Tp) && sizeof(_Tp) <= sizeof(std::intmax_t);

_LIBCPP_END_NAMESPACE_STD

#endif // _LIBCPP___TYPE_TRAITS_IS_TRIVIALLY_COPYABLE_H
