cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Add runner executable
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply standard settings
apply_standard_settings(${BINARY_NAME})

# Target properties
set_target_properties(${BINARY_NAME} PROPERTIES
  OUTPUT_NAME "Panel-LufyaCBT"
)

target_compile_definitions(${BINARY_NAME} PRIVATE
  FLUTTER_VERSION="${FLUTTER_VERSION}"
  FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}
  FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}
  FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}
  FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}
  NOMINMAX
)

target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
