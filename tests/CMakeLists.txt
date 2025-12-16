cmake_minimum_required(VERSION 3.16)

# Enable testing
enable_testing()

# Include GoogleTest
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.14.0
)

# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Include GoogleTest module
include(GoogleTest)

# Find Qt packages (needed for tests)
find_package(Qt6 REQUIRED COMPONENTS Core Network Test)

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/include)

# Test executable
set(TEST_SOURCES
    test_main.cpp
    test_models.cpp
    test_config.cpp
)

add_executable(personnel_management_tests ${TEST_SOURCES})

# Link libraries
target_link_libraries(personnel_management_tests
    PRIVATE
    GTest::gtest
    GTest::gtest_main
    GTest::gmock
    Qt6::Core
    Qt6::Network
    Qt6::Test
)

# Copy .env.test file to build directory if it exists
if(EXISTS "${CMAKE_SOURCE_DIR}/.env.test")
    configure_file(
        "${CMAKE_SOURCE_DIR}/.env.test"
        "${CMAKE_CURRENT_BINARY_DIR}/.env"
        COPYONLY
    )
endif()

# Add model source files (since they contain implementation)
target_sources(personnel_management_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/src/models/employee.cpp
    ${CMAKE_SOURCE_DIR}/src/models/department.cpp
    ${CMAKE_SOURCE_DIR}/src/models/salarygrade.cpp
)

# Discover tests
gtest_discover_tests(personnel_management_tests)

# Add custom target to run tests
add_custom_target(run_tests
    COMMAND personnel_management_tests
    DEPENDS personnel_management_tests
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Running tests..."
)
