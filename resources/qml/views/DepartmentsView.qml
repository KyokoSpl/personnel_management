import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import "../dialogs"

ScrollView {
    id: root
    property var colorScheme
    property string searchQuery: ""

    // Enable scrollbars and mouse wheel on Windows
    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
    clip: true

    // Filter departments based on search query
    function getFilteredDepartments() {
        if (!personnelApp) return []
        var depts = personnelApp.departments
        if (!searchQuery || searchQuery.trim() === "") return depts

        var query = searchQuery.toLowerCase()
        var filtered = []
        for (var i = 0; i < depts.length; i++) {
            var dept = depts[i]
            var name = (dept.name || "").toLowerCase()
            var headName = dept.headId ? getEmployeeName(dept.headId).toLowerCase() : ""
            if (name.indexOf(query) >= 0 || headName.indexOf(query) >= 0) {
                filtered.push(dept)
            }
        }
        return filtered
    }

    contentWidth: availableWidth

    Column {
        width: root.availableWidth
        spacing: 12

        // Header with title and add button
        RowLayout {
            width: parent.width
            spacing: 8

            Text {
                text: "Departments"
                font.pixelSize: 28
                font.bold: true
                color: colorScheme.textOnSurface
                Layout.fillWidth: true
            }

            IconButton {
                icon: "refresh"
                colorScheme: root.colorScheme
                onClicked: {
                    if (personnelApp) {
                        personnelApp.refreshDepartments()
                    }
                }
            }

            MaterialButton {
                text: "+ Add Department"
                primary: true
                colorScheme: root.colorScheme
                onClicked: {
                    createDepartmentDialog.open()
                }
            }
        }

        // Search field
        Rectangle {
            width: parent.width
            height: 44
            color: colorScheme.surfaceVariant
            radius: 8
            border.width: searchInput.activeFocus ? 2 : 1
            border.color: searchInput.activeFocus ? colorScheme.primary : colorScheme.outline

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "🔍"
                    font.pixelSize: 16
                    color: colorScheme.textOnSurfaceVariant
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                    color: colorScheme.textOnSurface
                    clip: true
                    selectByMouse: true
                    onTextChanged: root.searchQuery = text

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Search departments by name or head..."
                        color: colorScheme.textOnSurfaceVariant
                        font.pixelSize: 14
                        visible: !searchInput.text && !searchInput.activeFocus
                    }
                }

                Text {
                    text: "✕"
                    font.pixelSize: 14
                    color: colorScheme.textOnSurfaceVariant
                    visible: searchInput.text !== ""

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchInput.text = ""
                            root.searchQuery = ""
                        }
                    }
                }
            }
        }

        // Results count
        Text {
            text: {
                var filtered = getFilteredDepartments()
                var total = personnelApp ? personnelApp.departments.length : 0
                if (searchQuery && searchQuery.trim() !== "") {
                    return filtered.length + " of " + total + " departments"
                }
                return total + " departments"
            }
            font.pixelSize: 12
            color: colorScheme.textOnSurfaceVariant
        }

        // Department list
        Repeater {
            model: getFilteredDepartments()

            MaterialCard {
                width: parent.width
                height: 120
                colorScheme: root.colorScheme

                RowLayout {
                    anchors.fill: parent
                    anchors.rightMargin: 16
                    anchors.leftMargin: 16
                    anchors.topMargin: 16
                    anchors.bottomMargin: 16
                    spacing: 20

                    Column {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: modelData.name
                            font.pixelSize: 18
                            font.bold: true
                            color: colorScheme.textOnSurface
                        }

                        RowLayout {
                            spacing: 6

                            MaterialIcon {
                                icon: "person"
                                iconColor: colorScheme.textOnSurfaceVariant
                                size: 16
                            }

                            Text {
                                text: modelData.headId ? getEmployeeName(modelData.headId) : "No head assigned"
                                font.pixelSize: 13
                                color: colorScheme.textOnSurfaceVariant
                            }
                        }
                    }

                    Row {
                        spacing: 12
                        Layout.rightMargin: 8

                        Button {
                            implicitWidth: 90
                            implicitHeight: 36

                            background: Rectangle {
                                color: parent.hovered ? colorScheme.primaryContainer : "transparent"
                                radius: 8
                                border.width: 1
                                border.color: colorScheme.primary
                            }

                            contentItem: RowLayout {
                                spacing: 6

                                MaterialIcon {
                                    icon: "edit"
                                    iconColor: colorScheme.primary
                                    size: 16
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: "Edit"
                                    color: colorScheme.primary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            onClicked: {
                                editDepartmentDialog.departmentId = modelData.id
                                editDepartmentDialog.departmentName = modelData.name
                                editDepartmentDialog.departmentHeadId = modelData.headId || ""
                                editDepartmentDialog.open()
                            }
                        }

                        Button {
                            implicitWidth: 100
                            implicitHeight: 36

                            background: Rectangle {
                                color: parent.hovered ? "#3D1616" : "transparent"
                                radius: 8
                                border.width: 1
                                border.color: colorScheme.error
                            }

                            contentItem: RowLayout {
                                spacing: 6

                                MaterialIcon {
                                    icon: "delete"
                                    iconColor: colorScheme.error
                                    size: 16
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: "Delete"
                                    color: colorScheme.error
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            onClicked: {
                                if (personnelApp) {
                                    confirmDeleteDialog.departmentId = modelData.id
                                    confirmDeleteDialog.departmentName = modelData.name
                                    confirmDeleteDialog.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Helper function to get employee name by ID
    function getEmployeeName(employeeId) {
        if (!personnelApp || !employeeId) return "Unknown"
        var employees = personnelApp.employees
        for (var i = 0; i < employees.length; i++) {
            if (employees[i].id === employeeId) {
                return employees[i].firstName + " " + employees[i].lastName
            }
        }
        return "Unknown"
    }

    // Create department dialog
    Dialog {
        id: createDepartmentDialog
        modal: true
        anchors.centerIn: parent
        width: 450
        padding: 0

        header: Item {}

        background: Rectangle {
            color: colorScheme.surface
            radius: 12
            border.width: 1
            border.color: colorScheme.outline
        }

        Column {
            width: parent.width
            spacing: 24
            padding: 0

            // Custom header
            Rectangle {
                width: parent.width
                height: 56
                color: colorScheme.surfaceVariant
                radius: 12

                // Bottom corners should not be rounded
                Rectangle {
                    width: parent.width
                    height: 12
                    color: colorScheme.surfaceVariant
                    anchors.bottom: parent.bottom
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Create Department"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: colorScheme.textOnSurface
                }
            }

            // Content area with padding
            Column {
                width: parent.width
                spacing: 24
                leftPadding: 24
                rightPadding: 24
                bottomPadding: 24

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Department Name *"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                MaterialTextField {
                    id: deptNameField
                    placeholderText: "e.g., Sales, Engineering"
                    colorScheme: root.colorScheme
                    width: parent.width
                }
            }

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Department Head"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                SearchableEmployeeComboBox {
                    id: deptHeadCombo
                    width: parent.width
                    colorScheme: root.colorScheme
                    employees: personnelApp ? personnelApp.employees : []
                    showRole: true
                    placeholderText: "Select department head..."
                }
            }

                Row {
                    spacing: 12
                    anchors.right: parent.right

                    Button {
                        text: "Cancel"
                        implicitHeight: 40
                        implicitWidth: 90

                        background: Rectangle {
                            color: parent.hovered ? Qt.rgba(0, 0, 0, 0.05) : "transparent"
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: colorScheme.textOnSurfaceVariant
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                        }

                        onClicked: {
                            createDepartmentDialog.close()
                            deptNameField.text = ""
                            deptHeadCombo.clear()
                        }
                    }

                    Button {
                        text: "Create"
                        implicitHeight: 40
                        implicitWidth: 90

                        background: Rectangle {
                            color: parent.hovered ? Qt.darker(colorScheme.primary, 1.1) : colorScheme.primary
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: colorScheme.textOnPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }

                        onClicked: {
                            if (personnelApp && deptNameField.text.trim() !== "") {
                                // Store values for confirmation
                                confirmCreateDialog.deptName = deptNameField.text
                                confirmCreateDialog.headId = deptHeadCombo.selectedEmployeeId
                                confirmCreateDialog.headName = deptHeadCombo.getDisplayText()
                                confirmCreateDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // Edit department dialog
    Dialog {
        id: editDepartmentDialog
        property string departmentId
        property string departmentName
        property string departmentHeadId
        property string originalHeadId: ""

        modal: true
        anchors.centerIn: parent
        width: 450
        padding: 0

        header: Item {}

        background: Rectangle {
            color: colorScheme.surface
            radius: 12
            border.width: 1
            border.color: colorScheme.outline
        }

        onOpened: {
            editDeptNameField.text = departmentName
            editDeptHeadCombo.setSelectedId(departmentHeadId)
            // Store the original head ID for role updates
            originalHeadId = departmentHeadId || ""
        }

        Column {
            width: parent.width
            spacing: 24
            padding: 0

            // Custom header
            Rectangle {
                width: parent.width
                height: 56
                color: colorScheme.surfaceVariant
                radius: 12

                // Bottom corners should not be rounded
                Rectangle {
                    width: parent.width
                    height: 12
                    color: colorScheme.surfaceVariant
                    anchors.bottom: parent.bottom
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Edit Department"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: colorScheme.textOnSurface
                }
            }

            // Content area with padding
            Column {
                width: parent.width
                spacing: 24
                leftPadding: 24
                rightPadding: 24
                bottomPadding: 24

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Department Name *"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                MaterialTextField {
                    id: editDeptNameField
                    placeholderText: "e.g., Sales, Engineering"
                    colorScheme: root.colorScheme
                    width: parent.width
                }
            }

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Department Head"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                SearchableEmployeeComboBox {
                    id: editDeptHeadCombo
                    width: parent.width
                    colorScheme: root.colorScheme
                    employees: personnelApp ? personnelApp.employees : []
                    showRole: true
                    placeholderText: "Select department head..."
                }
            }

                Row {
                    spacing: 12
                    anchors.right: parent.right

                    Button {
                        text: "Cancel"
                        implicitHeight: 40
                        implicitWidth: 90

                        background: Rectangle {
                            color: parent.hovered ? Qt.rgba(0, 0, 0, 0.05) : "transparent"
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: colorScheme.textOnSurfaceVariant
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                        }

                        onClicked: {
                            editDepartmentDialog.close()
                        }
                    }

                    Button {
                        text: "Save"
                        implicitHeight: 40
                        implicitWidth: 90

                        background: Rectangle {
                            color: parent.hovered ? Qt.darker(colorScheme.primary, 1.1) : colorScheme.primary
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: colorScheme.textOnPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }

                        onClicked: {
                            if (personnelApp && editDeptNameField.text.trim() !== "") {
                                // Store values for confirmation
                                confirmSaveDialog.deptId = editDepartmentDialog.departmentId
                                confirmSaveDialog.deptName = editDeptNameField.text
                                confirmSaveDialog.headId = editDeptHeadCombo.selectedEmployeeId
                                confirmSaveDialog.headName = editDeptHeadCombo.getDisplayText()
                                confirmSaveDialog.originalName = editDepartmentDialog.departmentName
                                confirmSaveDialog.originalHeadId = editDepartmentDialog.originalHeadId
                                confirmSaveDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // Confirm create dialog
    ConfirmDialog {
        id: confirmCreateDialog
        property string deptName: ""
        property string headId: ""
        property string headName: ""

        colorScheme: root.colorScheme
        dialogTitle: "Create Department"
        message: "You are about to create a new department."
        consequences: {
            var text = "• A new department '" + deptName + "' will be created"
            if (headId && headName !== "None") {
                text += "\n• " + headName + " will be assigned as department head"
                text += "\n• " + headName + "'s role will be updated to 'Department Head'"
            }
            return text
        }
        confirmText: "Create"
        isDestructive: false

        onConfirmed: {
            if (personnelApp) {
                // Create department first
                personnelApp.createDepartment(deptName, headId)
                // If a head was assigned, update their role (API uses camelCase without spaces)
                if (headId) {
                    personnelApp.updateEmployee(headId, {"role": "DepartmentHead"})
                }
                createDepartmentDialog.close()
                deptNameField.text = ""
                deptHeadCombo.clear()
            }
        }
    }

    // Confirm save/update dialog
    ConfirmDialog {
        id: confirmSaveDialog
        property string deptId: ""
        property string deptName: ""
        property string headId: ""
        property string headName: ""
        property string originalName: ""
        property string originalHeadId: ""

        colorScheme: root.colorScheme
        dialogTitle: "Save Changes"
        message: "You are about to update the department '" + originalName + "'."
        consequences: {
            var changes = []
            if (deptName !== originalName) {
                changes.push("• Department will be renamed to '" + deptName + "'")
            }
            if (headId && headName !== "None") {
                changes.push("• " + headName + " will be set as department head")
                if (headId !== originalHeadId) {
                    changes.push("• " + headName + "'s role will be updated to 'Department Head'")
                }
            } else if (headName === "None" && originalHeadId) {
                changes.push("• Department head will be removed")
                changes.push("• Previous head's role will be updated to 'Employee'")
            }
            if (changes.length === 0) {
                changes.push("• Department information will be updated")
            }
            return changes.join("\n")
        }
        confirmText: "Save"
        isDestructive: false

        onConfirmed: {
            if (personnelApp) {
                // Use the new method that also updates roles
                personnelApp.updateDepartmentWithHead(deptId, deptName, headId, originalHeadId)
                editDepartmentDialog.close()
            }
        }
    }

    // Confirm delete dialog
    ConfirmDialog {
        id: confirmDeleteDialog
        property string departmentId: ""
        property string departmentName: ""

        colorScheme: root.colorScheme
        dialogTitle: "Delete Department"
        message: "Are you sure you want to delete '" + departmentName + "'?"
        consequences: "• The department will be permanently removed\n• Employees in this department will no longer be assigned to it\n• This action cannot be undone"
        confirmText: "Delete"
        isDestructive: true

        onConfirmed: {
            if (personnelApp) {
                personnelApp.deleteDepartment(departmentId)
            }
        }
    }
}
