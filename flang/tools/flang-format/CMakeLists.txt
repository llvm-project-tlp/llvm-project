set(LLVM_LINK_COMPONENTS
  FrontendOpenACC
  FrontendOpenMP
  Support
  )

add_flang_tool(flang-format
  flang-format.cpp
  DeleterStubs.cpp
  Format.cpp
  Main.cpp
)

target_link_libraries(flang-format
  PRIVATE
  FortranCommon
  FortranParser
  )
