import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property var colorScheme
    property var employees: []
    property string selectedEmployeeId: ""
    property string placeholderText: "Select employee..."
    property bool showRole: true

    // Trigger to force model refresh
    property int refreshTrigger: 0

    // Default colors for when colorScheme is undefined
    readonly property color defaultPrimary: "#D0BCFF"
    readonly property color defaultSurface: "#141218"
    readonly property color defaultSurfaceVariant: "#2C2831"
    readonly property color defaultTextOnSurface: "#E6E1E6"
    readonly property color defaultTextOnSurfaceVariant: "#CAC4D0"
    readonly property color defaultOutline: "#938F99"
    readonly property color defaultPrimaryContainer: "#4F378B"

    // Helper functions for safe color access
    function getPrimary() { return root.colorScheme ? root.colorScheme.primary : defaultPrimary }
    function getSurface() { return root.colorScheme ? root.colorScheme.surface : defaultSurface }
    function getSurfaceVariant() { return root.colorScheme ? root.colorScheme.surfaceVariant : defaultSurfaceVariant }
    function getTextOnSurface() { return root.colorScheme ? root.colorScheme.textOnSurface : defaultTextOnSurface }
    function getTextOnSurfaceVariant() { return root.colorScheme ? root.colorScheme.textOnSurfaceVariant : defaultTextOnSurfaceVariant }
    function getOutline() { return root.colorScheme ? root.colorScheme.outline : defaultOutline }
    function getPrimaryContainer() { return root.colorScheme ? root.colorScheme.primaryContainer : defaultPrimaryContainer }

    // Watch for employee changes
    onEmployeesChanged: {
        refreshTrigger++
    }

    implicitHeight: 48
    implicitWidth: 200

    signal employeeSelected(string employeeId)

    // Get display text for current selection
    function getDisplayText() {
        if (!root.selectedEmployeeId || root.selectedEmployeeId === "") {
            return "None"
        }
        for (var i = 0; i < root.employees.length; i++) {
            if (root.employees[i].id === root.selectedEmployeeId) {
                return root.employees[i].firstName + " " + root.employees[i].lastName
            }
        }
        return "None"
    }

    // Set selection by employee ID
    function setSelectedId(empId) {
        root.selectedEmployeeId = empId || ""
    }

    // Clear selection
    function clear() {
        root.selectedEmployeeId = ""
        searchField.text = ""
    }

    // Format role for display (add spaces to camelCase)
    function formatRole(role) {
        if (!role) return ""
        // Insert space before capital letters (except first)
        return role.replace(/([A-Z])/g, ' $1').trim()
    }

    // Filter employees based on search text
    function getFilteredEmployees() {
        var searchText = searchField.text.toLowerCase()
        var filtered = []

        // Always add "None" option first
        filtered.push({ id: "", firstName: "None", lastName: "", role: "" })

        if (!root.employees) return filtered

        for (var i = 0; i < root.employees.length; i++) {
            var emp = root.employees[i]
            var fullName = (emp.firstName + " " + emp.lastName).toLowerCase()
            var role = (emp.role || "").toLowerCase()

            if (searchText === "" || fullName.indexOf(searchText) >= 0 || role.indexOf(searchText) >= 0) {
                filtered.push(emp)
            }
        }
        return filtered
    }

    // Main button that shows current selection
    Rectangle {
        id: comboButton
        anchors.fill: parent
        color: getSurfaceVariant()
        radius: 8
        border.width: popup.visible ? 2 : 1
        border.color: popup.visible ? getPrimary() : getOutline()

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: root.getDisplayText()
                font.pixelSize: 14
                color: getTextOnSurface()
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "▼"
                font.pixelSize: 10
                color: getTextOnSurfaceVariant()
                rotation: popup.visible ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: 150 } }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (popup.visible) {
                    popup.close()
                } else {
                    searchField.text = ""
                    popup.open()
                    searchField.forceActiveFocus()
                }
            }
        }
    }

    // Dropdown popup
    Popup {
        id: popup
        y: comboButton.height + 4
        width: root.width
        implicitHeight: Math.min(380, popupContent.implicitHeight + 24)
        padding: 0

        background: Rectangle {
            color: getSurface()
            radius: 8
            border.width: 1
            border.color: getOutline()

            // Shadow rectangle behind
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 3
                anchors.leftMargin: 3
                anchors.rightMargin: -3
                anchors.bottomMargin: -3
                z: -1
                radius: 8
                color: "#30000000"
            }
        }

        contentItem: Rectangle {
            id: popupContent
            implicitHeight: contentColumn.implicitHeight + 16
            color: getSurface()
            radius: 8

            Column {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                // Search field container
                Rectangle {
                    id: searchContainer
                    width: parent.width
                    height: 40
                    color: getSurfaceVariant()
                    radius: 6
                    border.width: searchField.activeFocus ? 2 : 1
                    border.color: searchField.activeFocus ? getPrimary() : getOutline()

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: "🔍"
                            font.pixelSize: 14
                            color: getTextOnSurfaceVariant()
                        }

                        TextInput {
                            id: searchField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                            color: getTextOnSurface()
                            clip: true
                            selectByMouse: true

                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: "Type to filter..."
                                color: getTextOnSurfaceVariant()
                                font.pixelSize: 14
                                visible: !searchField.text && !searchField.activeFocus
                            }
                        }

                        // Clear button
                        Text {
                            text: "✕"
                            font.pixelSize: 12
                            color: getTextOnSurfaceVariant()
                            visible: searchField.text !== ""

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                onClicked: searchField.text = ""
                            }
                        }
                    }
                }

                // List container with fixed max height for ~6 items
                Rectangle {
                    id: listContainer
                    width: parent.width
                    height: Math.min(listView.contentHeight, 6 * 52)
                    color: "transparent"

                    ListView {
                        id: listView
                        anchors.fill: parent
                        clip: true
                        // Model depends on refreshTrigger to force updates when employees change
                        model: {
                            var dummy = root.refreshTrigger  // Force re-evaluation
                            return root.getFilteredEmployees()
                        }
                        boundsBehavior: Flickable.StopAtBounds

                        ScrollBar.vertical: ScrollBar {
                            active: true
                            policy: listView.contentHeight > listView.height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                        }

                        delegate: Rectangle {
                            id: delegateItem
                            width: listView.width - (listView.ScrollBar.vertical.visible ? 12 : 0)
                            height: 52
                            radius: 4

                            property bool isNone: modelData.id === ""
                            property bool isSelected: modelData.id === root.selectedEmployeeId

                            color: {
                                if (isSelected) {
                                    return getPrimaryContainer()
                                } else if (delegateMouseArea.containsMouse) {
                                    return Qt.rgba(0.5, 0.5, 0.5, 0.1)
                                }
                                return "transparent"
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        text: delegateItem.isNone ? "None" : (modelData.firstName + " " + modelData.lastName)
                                        font.pixelSize: 14
                                        font.weight: delegateItem.isSelected ? Font.Medium : Font.Normal
                                        color: getTextOnSurface()
                                        elide: Text.ElideRight
                                    }

                                    // Role display in light grey
                                    Text {
                                        width: parent.width
                                        text: root.formatRole(modelData.role)
                                        font.pixelSize: 12
                                        color: getTextOnSurfaceVariant()
                                        elide: Text.ElideRight
                                        visible: root.showRole && !delegateItem.isNone && modelData.role
                                        opacity: 0.7
                                    }
                                }

                                // Checkmark for selected item
                                Text {
                                    text: "✓"
                                    font.pixelSize: 14
                                    color: getPrimary()
                                    visible: delegateItem.isSelected
                                }
                            }

                            MouseArea {
                                id: delegateMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.selectedEmployeeId = modelData.id
                                    root.employeeSelected(modelData.id)
                                    popup.close()
                                }
                            }
                        }
                    }
                }

                // "No results" message
                Text {
                    width: parent.width
                    height: 40
                    text: "No employees found"
                    font.pixelSize: 14
                    color: getTextOnSurfaceVariant()
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: root.getFilteredEmployees().length <= 1 && searchField.text !== ""
                }
            }
        }

        onClosed: {
            searchField.text = ""
        }
    }
}
