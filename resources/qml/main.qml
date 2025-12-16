import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "views"

ApplicationWindow {
    id: window
    visible: true
    width: 1200
    height: 800
    minimumWidth: 800
    minimumHeight: 600
    title: "Personnel Management System"

    // Dark theme colors
    QtObject {
        id: darkColors
        property color primary: "#D0BCFF"
        property color textOnPrimary: "#381E72"
        property color primaryContainer: "#4F378B"
        property color surface: "#141218"
        property color surfaceVariant: "#2C2831"
        property color textOnSurface: "#E6E1E6"
        property color textOnSurfaceVariant: "#CAC4D0"
        property color outline: "#938F99"
        property color outlineVariant: "#44404B"
        property color error: "#F2B8B5"
        property color success: "#81C784"
    }

    // Light theme colors
    QtObject {
        id: lightColors
        property color primary: "#6750A4"
        property color textOnPrimary: "#FFFFFF"
        property color primaryContainer: "#EADDFF"
        property color surface: "#FEF7FF"
        property color surfaceVariant: "#E7E0EC"
        property color textOnSurface: "#1C1B1F"
        property color textOnSurfaceVariant: "#49454F"
        property color outline: "#79747E"
        property color outlineVariant: "#CAC4D0"
        property color error: "#B3261E"
        property color success: "#388E3C"
    }

    // Material 3 colors - default to dark theme, switch based on personnelApp.darkMode
    property var colorScheme: {
        if (typeof personnelApp !== 'undefined' && personnelApp !== null && !personnelApp.darkMode) {
            return lightColors
        }
        return darkColors
    }

    color: colorScheme.surface

    // Top navigation bar
    header: Rectangle {
        id: headerBar
        height: 60
        color: colorScheme.surface
        z: 100

        // Bottom border
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: colorScheme.outline
            opacity: 0.2
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 8

            // Tab buttons
            Repeater {
                model: [
                    {text: "Departments", index: 0},
                    {text: "Employees", index: 1},
                    {text: "Salary Grades", index: 2}
                ]

                Rectangle {
                    id: tabButton
                    property bool isSelected: personnelApp && personnelApp.currentTab === modelData.index

                    Layout.preferredHeight: 48
                    Layout.preferredWidth: tabText.implicitWidth + 32
                    color: tabMouseArea.containsMouse ? Qt.rgba(colorScheme.primary.r, colorScheme.primary.g, colorScheme.primary.b, 0.1) : "transparent"
                    radius: 4

                    Text {
                        id: tabText
                        anchors.centerIn: parent
                        text: modelData.text
                        color: tabButton.isSelected ? colorScheme.primary : colorScheme.textOnSurfaceVariant
                        font.pixelSize: 14
                        font.weight: tabButton.isSelected ? Font.Bold : Font.Normal
                        renderType: Text.NativeRendering
                    }

                    // Active indicator
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 8
                        height: 3
                        radius: 1.5
                        color: colorScheme.primary
                        visible: tabButton.isSelected
                    }

                    MouseArea {
                        id: tabMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (personnelApp) personnelApp.currentTab = modelData.index
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Theme toggle button
            Rectangle {
                id: themeToggle
                Layout.preferredHeight: 36
                Layout.preferredWidth: themeText.implicitWidth + 24
                color: themeMouseArea.containsMouse ? Qt.rgba(colorScheme.outline.r, colorScheme.outline.g, colorScheme.outline.b, 0.2) : "transparent"
                border.width: 1
                border.color: colorScheme.outline
                radius: 18

                Text {
                    id: themeText
                    anchors.centerIn: parent
                    text: (personnelApp && personnelApp.darkMode) ? "☀ Light" : "🌙 Dark"
                    color: colorScheme.textOnSurface
                    font.pixelSize: 13
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: themeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (personnelApp) personnelApp.darkMode = !personnelApp.darkMode
                    }
                }
            }
        }
    }

    // Main content area
    StackLayout {
        anchors.fill: parent
        anchors.margins: 32
        currentIndex: personnelApp ? personnelApp.currentTab : 0

        DepartmentsView {
            colorScheme: window.colorScheme
        }

        EmployeesView {
            colorScheme: window.colorScheme
        }

        SalaryGradesView {
            colorScheme: window.colorScheme
        }
    }

    // Error message display
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        height: errorText.height + 24
        color: "#321E1E"
        radius: 8
        visible: personnelApp && personnelApp.errorMessage !== ""

        Text {
            id: errorText
            anchors.centerIn: parent
            text: personnelApp ? ("⚠ " + personnelApp.errorMessage) : ""
            color: colorScheme.error
            font.pixelSize: 14
            renderType: Text.NativeRendering
        }
    }
}
