cmake_minimum_required(VERSION 3.21)
project(personnel_management VERSION 0.5.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)  # Enable automatic resource compilation for fonts

# Windows-specific settings
if(WIN32)
    # Ensure we use the correct runtime library
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")

    # Add Windows-specific definitions
    add_definitions(-DWIN32_LEAN_AND_MEAN)
    add_definitions(-DNOMINMAX)

    # Enable Unicode on Windows
    add_definitions(-DUNICODE -D_UNICODE)
endif()

# Find Qt6 packages
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Network)

# On Windows, we may need additional Qt components
if(WIN32)
    find_package(Qt6 COMPONENTS QmlIntegration QUIET)
endif()

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

# Windows application icon resource
if(WIN32)
    # Create a Windows resource file for the application icon if it doesn't exist
    set(WIN_RC_FILE "${CMAKE_BINARY_DIR}/windows_resource.rc")
    if(NOT EXISTS "${WIN_RC_FILE}")
        file(WRITE "${WIN_RC_FILE}" "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_SOURCE_DIR}/resources/icon.ico\"\n")
    endif()

    # Only include resource file if icon exists
    if(EXISTS "${CMAKE_SOURCE_DIR}/resources/icon.ico")
        list(APPEND SOURCES "${WIN_RC_FILE}")
    endif()
endif()

add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} resources/fonts.qrc)

# Link Qt libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
)

# Link QmlIntegration if available (Windows may need this)
if(TARGET Qt6::QmlIntegration)
    target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::QmlIntegration)
endif()

# Windows-specific linking
if(WIN32)
    # Link Windows-specific libraries
    target_link_libraries(${PROJECT_NAME} PRIVATE
        ws2_32      # Windows Sockets
        winmm       # Windows Multimedia
        iphlpapi    # IP Helper API
    )

    # Suppress console window in Release builds
    if(MSVC)
        set_target_properties(${PROJECT_NAME} PROPERTIES
            LINK_FLAGS_RELEASE "/SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup"
        )
    endif()
endif()

# Set executable properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# Output directory configuration for multi-config generators (MSVC)
if(CMAKE_CONFIGURATION_TYPES)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/Debug"
        RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/Release"
        RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/RelWithDebInfo"
        RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_BINARY_DIR}/MinSizeRel"
    )
endif()

# Copy QML files to build directory
foreach(QML_FILE ${QML_FILES})
    get_filename_component(QML_DIR ${QML_FILE} DIRECTORY)
    file(COPY ${QML_FILE} DESTINATION ${CMAKE_BINARY_DIR}/${QML_DIR})

    # For multi-config generators, copy to each config directory
    if(CMAKE_CONFIGURATION_TYPES)
        foreach(CONFIG ${CMAKE_CONFIGURATION_TYPES})
            file(COPY ${QML_FILE} DESTINATION ${CMAKE_BINARY_DIR}/${CONFIG}/${QML_DIR})
        endforeach()
    endif()
endforeach()

# Install rules
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
)
install(DIRECTORY resources/qml DESTINATION share/${PROJECT_NAME})

# Windows deployment - copy Qt DLLs (for installed builds)
if(WIN32)
    # Find windeployqt
    get_target_property(_qmake_executable Qt6::qmake IMPORTED_LOCATION)
    get_filename_component(_qt_bin_dir "${_qmake_executable}" DIRECTORY)
    find_program(WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${_qt_bin_dir}")

    if(WINDEPLOYQT_EXECUTABLE)
        # Add custom command to run windeployqt after build
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND "${WINDEPLOYQT_EXECUTABLE}"
                --qmldir "${CMAKE_SOURCE_DIR}/resources/qml"
                --no-translations
                --no-system-d3d-compiler
                --no-opengl-sw
                "$<TARGET_FILE:${PROJECT_NAME}>"
            COMMENT "Running windeployqt..."
        )
    endif()
endif()

# Enable testing
option(BUILD_TESTING "Build tests" ON)
if(BUILD_TESTING AND NOT CMAKE_CROSSCOMPILING)
    enable_testing()
    add_subdirectory(tests)
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "Personnel Management System v${PROJECT_VERSION}")
message(STATUS "  Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "  Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Qt version: ${Qt6_VERSION}")
message(STATUS "  Testing: ${BUILD_TESTING}")
if(WIN32 AND WINDEPLOYQT_EXECUTABLE)
    message(STATUS "  windeployqt: Found")
endif()
message(STATUS "")
