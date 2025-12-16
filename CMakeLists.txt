cmake_minimum_required(VERSION 3.21)
project(personnel_management VERSION 0.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)  # Enable automatic resource compilation for fonts

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Network)

include_directories(${CMAKE_SOURCE_DIR}/include)

# Generate QML module registration without qrc
set(QML_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml" CACHE STRING "" FORCE)

set(SOURCES
    src/main.cpp
    src/api/apiclient.cpp
    src/models/department.cpp
    src/models/employee.cpp
    src/models/salarygrade.cpp
    src/gui/personnelapp.cpp
    src/gui/material3colors.cpp
)

set(HEADERS
    include/api/apiclient.h
    include/models/department.h
    include/models/employee.h
    include/models/salarygrade.h
    include/gui/personnelapp.h
    include/gui/material3colors.h
    include/config.h
)

# List all QML files to be installed alongside the binary
set(QML_FILES
    resources/qml/main.qml
    resources/qml/views/DepartmentsView.qml
    resources/qml/views/EmployeesView.qml
    resources/qml/views/SalaryGradesView.qml
    resources/qml/components/MaterialButton.qml
    resources/qml/components/MaterialCard.qml
    resources/qml/components/MaterialComboBox.qml
    resources/qml/components/IconButton.qml
    resources/qml/components/MaterialIcon.qml
    resources/qml/components/MaterialTextField.qml
    resources/qml/components/SearchableEmployeeComboBox.qml
    resources/qml/components/qmldir
    resources/qml/dialogs/ConfirmDialog.qml
    resources/qml/dialogs/DepartmentEditDialog.qml
    resources/qml/dialogs/EmployeeEditDialog.qml
    resources/qml/dialogs/SalaryGradeEditDialog.qml
    resources/qml/dialogs/qmldir
)

add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} resources/fonts.qrc)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::QuickControls2 Qt6::Network
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# Copy QML files to build directory
foreach(QML_FILE ${QML_FILES})
    get_filename_component(QML_DIR ${QML_FILE} DIRECTORY)
    file(COPY ${QML_FILE} DESTINATION ${CMAKE_BINARY_DIR}/${QML_DIR})
endforeach()

# Install executable and QML files
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)
install(DIRECTORY resources/qml DESTINATION share/${PROJECT_NAME})
