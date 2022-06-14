hunter_add_package(GTest)
find_package(GTest REQUIRED)
include(GoogleTest)

set(TEST_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/DummyTest.cpp
)

add_executable(jumpstart-test ${TEST_SOURCES})

# NOTE: Don't use space inside a generator expression here, because the function prematurely breaks the expression into
# multiple lines. https://cmake.org/pipermail/cmake/2018-April/067422.html
set(JUMPSTART_TESTER_MSVC_FLAGS /W4)
set(JUMPSTART_TESTER_GCC_FLAGS -Wall -Wextra -Wpedantic)
set(JUMPSTART_TESTER_CLANG_FLAGS -Weverything -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-global-constructors -Wno-weak-vtables)
target_compile_options(
    jumpstart-test PRIVATE
    $<$<CXX_COMPILER_ID:MSVC>:${JUMPSTART_TESTER_MSVC_FLAGS}>
    $<$<CXX_COMPILER_ID:GNU>:${JUMPSTART_TESTER_GCC_FLAGS}>
    $<$<CXX_COMPILER_ID:Clang>:${JUMPSTART_TESTER_CLANG_FLAGS}>
)

target_link_libraries(jumpstart-test PRIVATE GTest::gtest GTest::gtest_main)
target_link_libraries(jumpstart-test PRIVATE  $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:${CMAKE_DL_LIBS}>)

gtest_discover_tests(jumpstart-test)

if(JUMPSTART_ENABLE_COVERAGE)
    include("code-coverage")
    setup_coverage(jumpstart-test)
    set(COVERAGE_EXCLUDES "/usr/**" "/home/*/.conan/**" "*test*" "*build*")
    setup_target_for_coverage_lcov(NAME coverage EXECUTABLE ${CMAKE_CURRENT_BINARY_DIR}/jumpstart-test)
endif()