cmake_minimum_required(VERSION 3.12)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

include("HunterGate")
HunterGate(
    URL "https://github.com/cpp-pm/hunter/archive/v0.24.3.tar.gz"
    SHA1 "10738b59e539818a01090e64c2d09896247530c7"
)

project(jumpstart)

option(JUMPSTART_BUILD_EXAMPLES "Configure CMake to build examples (or not)" ON)
option(JUMPSTART_BUILD_TESTS "Configure CMake to build tests (or not)" ON)
option(JUMPSTART_ENABLE_COVERAGE "Enable code coverage testing" OFF)
option(JUMPSTART_BUILD_STATIC "Configure CMake to build a static version of the library" ON)
option(JUMPSTART_BUILD_SHARED "Configure CMake to build a shared version of the library" ON)

set(JUMPSTART_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/dummy.cpp
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

if(JUMPSTART_BUILD_STATIC)
    add_library(jumpstart_static STATIC ${JUMPSTART_SOURCES})
    add_library(jumpstart::jumpstart_static ALIAS jumpstart_static) # To match export
    target_compile_features(jumpstart_static PUBLIC cxx_std_20)
    target_include_directories(jumpstart_static PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
    install(TARGETS jumpstart_static EXPORT jumpstart-targets
            LIBRARY ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
if(JUMPSTART_BUILD_SHARED)
    add_library(jumpstart_shared SHARED ${JUMPSTART_SOURCES})
    add_library(jumpstart::jumpstart_shared ALIAS jumpstart_shared) # To match export
    target_compile_features(jumpstart_shared PUBLIC cxx_std_20)
    target_include_directories(jumpstart_shared PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
    install(TARGETS jumpstart_shared EXPORT jumpstart-targets
            LIBRARY ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()

if(JUMPSTART_BUILD_STATIC)
    add_library(jumpstart::jumpstart ALIAS jumpstart_static)
elseif(JUMPSTART_BUILD_SHARED)
    add_library(jumpstart::jumpstart ALIAS jumpstart_shared)
else()
    message(FATAL_ERROR "Neither static not shared library selected!")
endif()

# Hunter needs relative paths so the files are placed correctly
if(NOT JUMPSTART_CMAKE_FILES_INSTALL_DIR)
    set(JUMPSTART_CMAKE_FILES_INSTALL_DIR cmake)
endif()

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/cmake/jumpstart-config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/jumpstart-config.cmake
    INSTALL_DESTINATION ${JUMPSTART_CMAKE_FILES_INSTALL_DIR})
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/jumpstart-config-version.cmake VERSION 0.1.0 COMPATIBILITY ExactVersion)

install(EXPORT jumpstart-targets NAMESPACE jumpstart:: FILE jumpstart-targets.cmake DESTINATION ${JUMPSTART_CMAKE_FILES_INSTALL_DIR})
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/jumpstart-config.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/jumpstart-config-version.cmake
        DESTINATION ${JUMPSTART_CMAKE_FILES_INSTALL_DIR})

if(JUMPSTART_BUILD_EXAMPLES)
    add_subdirectory(example)
endif()

if(JUMPSTART_BUILD_TESTS)
    enable_testing() # enable_testing needs to be part of the top level file....
    add_subdirectory(test)
endif()