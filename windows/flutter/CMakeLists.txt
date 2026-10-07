cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake OPTIONAL)

# Apply the standard set of build settings.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_UNICODE" "UNICODE")
  target_compile_definitions(${TARGET} PRIVATE "_CRT_SECURE_NO_WARNINGS")
endfunction()

# Target platform
if(NOT DEFINED FLUTTER_TARGET_PLATFORM)
  set(FLUTTER_TARGET_PLATFORM "windows-x64")
endif()

# Flutter engine and plugin wrapper
list(APPEND FLUTTER_LIBRARY_SOURCES
  "${EPHEMERAL_DIR}/cpp_client_wrapper/core_implementations.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/standard_codec.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/plugin_registrar.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/flutter_engine.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/flutter_view_controller.cc"
)

add_library(flutter_wrapper_app STATIC
  ${FLUTTER_LIBRARY_SOURCES}
)
apply_standard_settings(flutter_wrapper_app)
set_target_properties(flutter_wrapper_app PROPERTIES
  POSITION_INDEPENDENT_CODE ON
  CXX_VISIBILITY_PRESET hidden
)
target_include_directories(flutter_wrapper_app PUBLIC
  "${EPHEMERAL_DIR}/cpp_client_wrapper/include"
  "${EPHEMERAL_DIR}"
)
