# Personnel Management System - Testing Documentation

This directory contains the test suite for the Personnel Management System, built using Google Test framework.

## Overview

The test suite provides comprehensive coverage for the core functionality of the application, including:

- **Model Tests**: JSON serialization/deserialization, data validation
- **Config Tests**: Configuration loading and validation
- **Integration Tests**: Component interaction and data flow

## Prerequisites

- CMake 3.16 or higher
- Qt 6.x
- C++17 compatible compiler
- Google Test (automatically downloaded via CMake FetchContent)

## Building and Running Tests

### Quick Start

```bash
# From the project root
mkdir -p build && cd build
cmake .. -DBUILD_TESTING=ON
cmake --build .
ctest --output-on-failure
```

### Detailed Build Steps

1. **Configure with tests enabled:**
   ```bash
   cmake -B build -DBUILD_TESTING=ON
   ```

2. **Build the test executable:**
   ```bash
   cmake --build build
   ```

3. **Run all tests:**
   ```bash
   cd build
   ctest
   ```

4. **Run tests with verbose output:**
   ```bash
   ctest --verbose --output-on-failure
   ```

5. **Run specific test suite:**
   ```bash
   cd build
   ./tests/personnel_management_tests --gtest_filter="EmployeeTest.*"
   ```

### Using the Makefile Target

```bash
# Run tests via custom target
cd build
make run_tests
```

## Test Organization

### Test Files

- **`test_main.cpp`**: Entry point for test execution
- **`test_models.cpp`**: Tests for Employee, Department, and SalaryGrade models
- **`test_config.cpp`**: Tests for configuration management

### Test Structure

Each test file follows this pattern:

```cpp
class ComponentTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup test fixtures
    }
    
    void TearDown() override {
        // Cleanup
    }
    
    // Test data members
};

TEST_F(ComponentTest, TestName) {
    // Test implementation
}
```

## Test Coverage

### Model Tests

#### Employee Model
- Default constructor initialization
- Full name concatenation
- JSON serialization (toJson)
- JSON deserialization (fromJson)
- Round-trip conversion
- Handling missing fields
- Special characters in strings
- Edge cases (empty data, long strings)

#### Department Model
- Default and parameterized constructors
- JSON serialization/deserialization
- Optional head_id handling
- Data validation

#### SalaryGrade Model
- Default constructor
- Salary precision handling
- JSON operations
- Edge cases (zero, very large salaries)

### Config Tests
- Singleton pattern verification
- Default values validation
- Configuration format checking
- API URL construction
- Route uniqueness

## Running Specific Tests

### By Test Suite
```bash
./personnel_management_tests --gtest_filter="EmployeeTest.*"
./personnel_management_tests --gtest_filter="DepartmentTest.*"
./personnel_management_tests --gtest_filter="SalaryGradeTest.*"
./personnel_management_tests --gtest_filter="ConfigTest.*"
```

### By Test Name
```bash
./personnel_management_tests --gtest_filter="EmployeeTest.ToJson"
./personnel_management_tests --gtest_filter="*JsonConversion*"
```

### Exclude Tests
```bash
./personnel_management_tests --gtest_filter="-*EdgeCases*"
```

## Test Environment

### Environment File

Tests use `.env.test` for configuration:

```env
API_BASE_URL=http://localhost
API_PORT=3000
ROUTE_EMPLOYEES=/api/employees
ROUTE_DEPARTMENTS=/api/departments
ROUTE_SALARY_GRADES=/api/salary-grades
```

The test suite automatically creates this file during test execution if needed.

## Continuous Integration

Tests are automatically run in GitHub Actions on:
- Push to `main` or `develop` branches
- Pull requests
- Manual workflow dispatch

### CI Workflow

The CI pipeline includes:

1. **Format Check**: Validates C++ code formatting with clang-format
2. **Build**: Compiles on Linux, Windows, and macOS
3. **Test**: Runs full test suite on all platforms
4. **Coverage**: Generates code coverage reports

See `.github/workflows/ci.yml` for details.

## Code Coverage

### Generate Coverage Report Locally

```bash
# Configure with coverage flags
cmake -B build \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_FLAGS="--coverage" \
  -DCMAKE_EXE_LINKER_FLAGS="--coverage" \
  -DBUILD_TESTING=ON

# Build and run tests
cmake --build build
cd build
ctest

# Generate coverage report (requires gcovr or lcov)
gcovr -r .. --html --html-details -o coverage.html

# Open report
xdg-open coverage.html
```

## Adding New Tests

### 1. Create Test File

Add a new test file in the `tests/` directory:

```cpp
#include <gtest/gtest.h>
#include "your_component.h"

TEST(YourComponentTest, TestSomething) {
    // Arrange
    YourComponent component;
    
    // Act
    auto result = component.doSomething();
    
    // Assert
    EXPECT_EQ(result, expectedValue);
}
```

### 2. Update CMakeLists.txt

Add your test file to `tests/CMakeLists.txt`:

```cmake
set(TEST_SOURCES
    test_main.cpp
    test_models.cpp
    test_config.cpp
    test_your_component.cpp  # Add this line
)
```

### 3. Build and Run

```bash
cmake --build build
cd build
ctest
```

## Test Best Practices

### Use Descriptive Test Names

```cpp
TEST(EmployeeTest, FullName_ConcatenatesFirstAndLastName) {
    // Test implementation
}
```

### Follow AAA Pattern

- **Arrange**: Set up test data and preconditions
- **Act**: Execute the code under test
- **Assert**: Verify the results

### Test One Thing at a Time

Each test should verify a single behavior or aspect.

### Use Test Fixtures for Setup/Teardown

```cpp
class MyTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Common setup
    }
};
```

### Handle Edge Cases

Test boundary conditions, empty inputs, null values, etc.

## Troubleshooting

### Tests Won't Build

1. Ensure Qt is properly installed and found by CMake
2. Check that GoogleTest is being downloaded correctly
3. Verify C++17 compiler support

### Tests Fail to Run

1. Ensure `.env` or `.env.test` file exists
2. Check that all required Qt modules are installed
3. Verify working directory is correct

### CMake Can't Find GoogleTest

GoogleTest is downloaded automatically. If this fails:
1. Check internet connection
2. Try clearing CMake cache: `rm -rf build && mkdir build`
3. Manually specify GoogleTest location if needed

## Resources

- [Google Test Documentation](https://google.github.io/googletest/)
- [Google Test Primer](https://google.github.io/googletest/primer.html)
- [CMake Testing Documentation](https://cmake.org/cmake/help/latest/manual/ctest.1.html)
- [Qt Test Framework](https://doc.qt.io/qt-6/qtest-overview.html)

## Contributing

When adding new features:

1. Write tests first (TDD approach recommended)
2. Ensure tests pass locally before committing
3. Maintain or improve code coverage
4. Follow existing test naming conventions
5. Document complex test scenarios

## License

Same as the main project license.