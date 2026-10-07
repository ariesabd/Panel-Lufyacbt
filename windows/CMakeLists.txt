cmake_minimum_required(VERSION 3.14)
project(panel_lufyacbt LANGUAGES CXX)

set(BINARY_NAME "panel_lufyacbt")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build options.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()

set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")

# Use Unicode for all Windows APIs.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation flags
if(MSVC)
  add_compile_options(/W4 /WX /wd"4100")
  add_compile_options(/EHsc)
  add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
endif()

# Flutter wrapper
add_subdirectory(flutter)

# Application runner
add_subdirectory(runner)
