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

    // Format role for display (add spaces to camelCase)
    function formatRole(role) {
        if (!role) return "N/A"
        // Insert space before capital letters (except first)
        return role.replace(/([A-Z])/g, ' $1').trim()
    }

    // Filter employees based on search query
    function getFilteredEmployees() {
        if (!personnelApp) return []
        var emps = personnelApp.employees
        if (!searchQuery || searchQuery.trim() === "") return emps

        var query = searchQuery.toLowerCase()
        var filtered = []
        for (var i = 0; i < emps.length; i++) {
            var emp = emps[i]
            var fullName = ((emp.firstName || "") + " " + (emp.lastName || "")).toLowerCase()
            var email = (emp.email || "").toLowerCase()
            var role = (emp.role || "").toLowerCase()
            var deptName = emp.departmentId ? getDepartmentName(emp.departmentId).toLowerCase() : ""

            if (fullName.indexOf(query) >= 0 ||
                email.indexOf(query) >= 0 ||
                role.indexOf(query) >= 0 ||
                deptName.indexOf(query) >= 0) {
                filtered.push(emp)
            }
        }
        return filtered
    }

    contentWidth: availableWidth

    Column {
        width: root.availableWidth
        spacing: 12

        // Header
        RowLayout {
            width: parent.width
            spacing: 8

            Text {
                text: "Employees"
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
                        personnelApp.refreshEmployees()
                    }
                }
            }

            MaterialButton {
                text: "+ Add Employee"
                primary: true
                colorScheme: root.colorScheme
                onClicked: createEmployeeDialog.open()
            }
        }

        // Search field
        Rectangle {
            width: parent.width
            height: 44
            color: colorScheme.surfaceVariant
            radius: 8
            border.width: empSearchInput.activeFocus ? 2 : 1
            border.color: empSearchInput.activeFocus ? colorScheme.primary : colorScheme.outline

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
                    id: empSearchInput
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
                        text: "Search by name, email, role, or department..."
                        color: colorScheme.textOnSurfaceVariant
                        font.pixelSize: 14
                        visible: !empSearchInput.text && !empSearchInput.activeFocus
                    }
                }

                Text {
                    text: "✕"
                    font.pixelSize: 14
                    color: colorScheme.textOnSurfaceVariant
                    visible: empSearchInput.text !== ""

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            empSearchInput.text = ""
                            root.searchQuery = ""
                        }
                    }
                }
            }
        }

        // Results count
        Text {
            text: {
                var filtered = getFilteredEmployees()
                var total = personnelApp ? personnelApp.employees.length : 0
                if (searchQuery && searchQuery.trim() !== "") {
                    return filtered.length + " of " + total + " employees"
                }
                return total + " employees"
            }
            font.pixelSize: 12
            color: colorScheme.textOnSurfaceVariant
        }

        // Employee list
        Repeater {
            model: getFilteredEmployees()

            MaterialCard {
                width: parent.width
                height: 160
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
                            text: modelData.firstName + " " + modelData.lastName
                            font.pixelSize: 18
                            font.bold: true
                            color: colorScheme.textOnSurface
                        }

                        RowLayout {
                            spacing: 6

                            MaterialIcon {
                                icon: "email"
                                iconColor: colorScheme.textOnSurfaceVariant
                                size: 16
                            }

                            Text {
                                text: modelData.email
                                font.pixelSize: 13
                                color: colorScheme.textOnSurfaceVariant
                            }
                        }

                        RowLayout {
                            spacing: 6

                            MaterialIcon {
                                icon: "work"
                                iconColor: colorScheme.textOnSurfaceVariant
                                size: 16
                            }

                            Text {
                                text: formatRole(modelData.role)
                                font.pixelSize: 13
                                color: colorScheme.textOnSurfaceVariant
                            }
                        }

                        RowLayout {
                            spacing: 6

                            MaterialIcon {
                                icon: "business"
                                iconColor: colorScheme.textOnSurfaceVariant
                                size: 16
                            }

                            Text {
                                text: modelData.departmentId ? getDepartmentName(modelData.departmentId) : "No department"
                                font.pixelSize: 13
                                color: colorScheme.textOnSurfaceVariant
                            }
                        }

                        RowLayout {
                            spacing: 6

                            MaterialIcon {
                                icon: "attach_money"
                                iconColor: colorScheme.textOnSurfaceVariant
                                size: 16
                            }

                            Text {
                                text: modelData.salaryGradeId ? getSalaryGradeCode(modelData.salaryGradeId) : "No grade"
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
                                editEmployeeDialog.employeeId = modelData.id
                                editEmployeeDialog.employeeFirstName = modelData.firstName
                                editEmployeeDialog.employeeLastName = modelData.lastName
                                editEmployeeDialog.employeeEmail = modelData.email
                                editEmployeeDialog.employeeRole = modelData.role || ""
                                editEmployeeDialog.employeeDepartmentId = modelData.departmentId || ""
                                editEmployeeDialog.employeeManagerId = modelData.managerId || ""
                                editEmployeeDialog.employeeSalaryGradeId = modelData.salaryGradeId || ""
                                editEmployeeDialog.open()
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
                                    confirmDeleteDialog.employeeId = modelData.id
                                    confirmDeleteDialog.employeeName = modelData.firstName + " " + modelData.lastName
                                    confirmDeleteDialog.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Helper functions to resolve IDs
    function getDepartmentName(deptId) {
        if (!personnelApp || !deptId) return "Unknown"
        var departments = personnelApp.departments
        for (var i = 0; i < departments.length; i++) {
            if (departments[i].id === deptId) {
                return departments[i].name
            }
        }
        return "Unknown"
    }

    function getSalaryGradeCode(gradeId) {
        if (!personnelApp || !gradeId) return "Unknown"
        var grades = personnelApp.salaryGrades
        for (var i = 0; i < grades.length; i++) {
            if (grades[i].id === gradeId) {
                return grades[i].code + " - $" + grades[i].baseSalary.toFixed(0)
            }
        }
        return "Unknown"
    }

    // Create employee dialog
    Dialog {
        id: createEmployeeDialog
        modal: true
        anchors.centerIn: parent
        width: 500
        padding: 0

        header: Item {}

        background: Rectangle {
            color: colorScheme.surface
            radius: 12
            border.width: 1
            border.color: colorScheme.outline
        }

        Column {
            spacing: 20
            width: parent.width
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
                    text: "Create Employee"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: colorScheme.textOnSurface
                }
            }

            // Content area with padding
            Column {
                width: parent.width
                spacing: 20
                leftPadding: 24
                rightPadding: 24
                bottomPadding: 24

                Column {
                    width: parent.width - 48
                    spacing: 8

                    Text {
                        text: "First Name *"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: createEmpFirstName
                        placeholderText: "e.g., John"
                        colorScheme: root.colorScheme
                        width: parent.width
                    }
                }

                Column {
                    width: parent.width - 48
                    spacing: 8

                    Text {
                        text: "Last Name *"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: createEmpLastName
                        placeholderText: "e.g., Doe"
                        colorScheme: root.colorScheme
                        width: parent.width
                    }
                }

                Column {
                    width: parent.width - 48
                    spacing: 8

                    Text {
                        text: "Email *"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: createEmpEmail
                        placeholderText: "e.g., john.doe@company.com"
                        colorScheme: root.colorScheme
                        width: parent.width
                    }
                }

                Column {
                    width: parent.width - 48
                    spacing: 8

                    Text {
                        text: "Role"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: createEmpRole
                        placeholderText: "e.g., Developer"
                        colorScheme: root.colorScheme
                        width: parent.width
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
                            createEmployeeDialog.close()
                            createEmpFirstName.text = ""
                            createEmpLastName.text = ""
                            createEmpEmail.text = ""
                            createEmpRole.text = ""
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
                            if (personnelApp && createEmpFirstName.text.trim() !== "" &&
                                createEmpLastName.text.trim() !== "" && createEmpEmail.text.trim() !== "") {
                                // Store values for confirmation
                                confirmCreateDialog.empFirstName = createEmpFirstName.text
                                confirmCreateDialog.empLastName = createEmpLastName.text
                                confirmCreateDialog.empEmail = createEmpEmail.text
                                confirmCreateDialog.empRole = createEmpRole.text
                                confirmCreateDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // Edit employee dialog
    Dialog {
        id: editEmployeeDialog
        property string employeeId
        property string employeeFirstName
        property string employeeLastName
        property string employeeEmail
        property string employeeRole
        property string employeeDepartmentId
        property string employeeManagerId
        property string employeeSalaryGradeId

        modal: true
        anchors.centerIn: parent
        width: 500
        padding: 0

        header: Item {}

        background: Rectangle {
            color: colorScheme.surface
            radius: 12
            border.width: 1
            border.color: colorScheme.outline
        }

        onOpened: {
            editEmpFirstName.text = employeeFirstName
            editEmpLastName.text = employeeLastName
            editEmpEmail.text = employeeEmail
            editEmpRole.text = employeeRole

            // Set department dropdown
            var departments = personnelApp.departments
            editEmpDepartmentCombo.currentIndex = 0
            for (var i = 0; i < departments.length; i++) {
                if (departments[i].id === employeeDepartmentId) {
                    editEmpDepartmentCombo.currentIndex = i + 1
                    break
                }
            }

            // Set manager dropdown using SearchableEmployeeComboBox
            editEmpManagerCombo.setSelectedId(employeeManagerId)

            // Set salary grade dropdown
            var grades = personnelApp.salaryGrades
            editEmpGradeCombo.currentIndex = 0
            for (var k = 0; k < grades.length; k++) {
                if (grades[k].id === employeeSalaryGradeId) {
                    editEmpGradeCombo.currentIndex = k + 1
                    break
                }
            }
        }

        Column {
            spacing: 20
            width: parent.width
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
                    text: "Edit Employee"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: colorScheme.textOnSurface
                }
            }

            // Content area with padding
            Column {
                width: parent.width
                spacing: 20
                leftPadding: 24
                rightPadding: 24
                bottomPadding: 24

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "First Name *"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                MaterialTextField {
                    id: editEmpFirstName
                    placeholderText: "e.g., John"
                    colorScheme: root.colorScheme
                    width: parent.width
                }
            }

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Last Name *"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                MaterialTextField {
                    id: editEmpLastName
                    placeholderText: "e.g., Doe"
                    colorScheme: root.colorScheme
                    width: parent.width
                }
            }

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Email *"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                MaterialTextField {
                    id: editEmpEmail
                    placeholderText: "e.g., john.doe@company.com"
                    colorScheme: root.colorScheme
                    width: parent.width
                }
            }

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Role"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                MaterialTextField {
                    id: editEmpRole
                    placeholderText: "e.g., Developer"
                    colorScheme: root.colorScheme
                    width: parent.width
                }
            }

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Department"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                ComboBox {
                    id: editEmpDepartmentCombo
                    width: parent.width
                    implicitHeight: 48

                    model: {
                        var items = ["None"]
                        if (personnelApp) {
                            var depts = personnelApp.departments
                            for (var i = 0; i < depts.length; i++) {
                                items.push(depts[i].name)
                            }
                        }
                        return items
                    }

                    background: Rectangle {
                        color: colorScheme.surfaceVariant
                        radius: 8
                        border.width: editEmpDepartmentCombo.activeFocus ? 2 : 1
                        border.color: editEmpDepartmentCombo.activeFocus ? colorScheme.primary : colorScheme.outline
                    }

                    contentItem: Text {
                        leftPadding: 12
                        rightPadding: editEmpDepartmentCombo.indicator.width + editEmpDepartmentCombo.spacing
                        text: editEmpDepartmentCombo.displayText
                        font.pixelSize: 14
                        color: colorScheme.textOnSurface
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    delegate: ItemDelegate {
                        width: editEmpDepartmentCombo.width
                        height: 40
                        contentItem: Text {
                            text: modelData
                            color: colorScheme.textOnSurface
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }
                        background: Rectangle {
                            color: parent.highlighted ? colorScheme.primaryContainer : "transparent"
                            radius: 4
                        }
                    }

                    popup: Popup {
                        y: editEmpDepartmentCombo.height + 4
                        width: editEmpDepartmentCombo.width
                        implicitHeight: contentItem.implicitHeight + 16
                        padding: 8
                        background: Rectangle {
                            color: colorScheme.surface
                            radius: 8
                            border.width: 1
                            border.color: colorScheme.outline
                        }
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: editEmpDepartmentCombo.popup.visible ? editEmpDepartmentCombo.delegateModel : null
                            currentIndex: editEmpDepartmentCombo.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }
                    }
                }
            }

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Manager"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                SearchableEmployeeComboBox {
                    id: editEmpManagerCombo
                    width: parent.width
                    colorScheme: root.colorScheme
                    employees: personnelApp ? personnelApp.employees : []
                    showRole: true
                    placeholderText: "Select manager..."
                }
            }

            Column {
                width: parent.width - 48
                spacing: 8

                Text {
                    text: "Salary Grade"
                    font.pixelSize: 12
                    color: colorScheme.textOnSurfaceVariant
                    font.weight: Font.Medium
                }

                ComboBox {
                    id: editEmpGradeCombo
                    width: parent.width
                    implicitHeight: 48

                    model: {
                        var items = ["None"]
                        if (personnelApp) {
                            var grds = personnelApp.salaryGrades
                            for (var i = 0; i < grds.length; i++) {
                                items.push(grds[i].code + " - $" + grds[i].baseSalary.toFixed(0))
                            }
                        }
                        return items
                    }

                    background: Rectangle {
                        color: colorScheme.surfaceVariant
                        radius: 8
                        border.width: editEmpGradeCombo.activeFocus ? 2 : 1
                        border.color: editEmpGradeCombo.activeFocus ? colorScheme.primary : colorScheme.outline
                    }

                    contentItem: Text {
                        leftPadding: 12
                        rightPadding: editEmpGradeCombo.indicator.width + editEmpGradeCombo.spacing
                        text: editEmpGradeCombo.displayText
                        font.pixelSize: 14
                        color: colorScheme.textOnSurface
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    delegate: ItemDelegate {
                        width: editEmpGradeCombo.width
                        height: 40
                        contentItem: Text {
                            text: modelData
                            color: colorScheme.textOnSurface
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }
                        background: Rectangle {
                            color: parent.highlighted ? colorScheme.primaryContainer : "transparent"
                            radius: 4
                        }
                    }

                    popup: Popup {
                        y: editEmpGradeCombo.height + 4
                        width: editEmpGradeCombo.width
                        implicitHeight: contentItem.implicitHeight + 16
                        padding: 8
                        background: Rectangle {
                            color: colorScheme.surface
                            radius: 8
                            border.width: 1
                            border.color: colorScheme.outline
                        }
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: editEmpGradeCombo.popup.visible ? editEmpGradeCombo.delegateModel : null
                            currentIndex: editEmpGradeCombo.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }
                    }
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
                            editEmployeeDialog.close()
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
                            if (personnelApp && editEmpFirstName.text.trim() !== "" &&
                                editEmpLastName.text.trim() !== "" && editEmpEmail.text.trim() !== "") {

                                // Get selected IDs from dropdowns
                                var selectedDeptId = ""
                                var selectedDeptName = "None"
                                if (editEmpDepartmentCombo.currentIndex > 0) {
                                    var depts = personnelApp.departments
                                    var deptIndex = editEmpDepartmentCombo.currentIndex - 1
                                    if (deptIndex < depts.length) {
                                        selectedDeptId = depts[deptIndex].id
                                        selectedDeptName = depts[deptIndex].name
                                    }
                                }

                                var selectedManagerId = editEmpManagerCombo.selectedEmployeeId
                                var selectedManagerName = editEmpManagerCombo.getDisplayText()

                                var selectedGradeId = ""
                                var selectedGradeCode = "None"
                                if (editEmpGradeCombo.currentIndex > 0) {
                                    var grds = personnelApp.salaryGrades
                                    var grdIndex = editEmpGradeCombo.currentIndex - 1
                                    if (grdIndex < grds.length) {
                                        selectedGradeId = grds[grdIndex].id
                                        selectedGradeCode = grds[grdIndex].code
                                    }
                                }

                                // Store for confirmation
                                confirmSaveDialog.empId = editEmployeeDialog.employeeId
                                confirmSaveDialog.empFirstName = editEmpFirstName.text
                                confirmSaveDialog.empLastName = editEmpLastName.text
                                confirmSaveDialog.empEmail = editEmpEmail.text
                                confirmSaveDialog.empRole = editEmpRole.text
                                confirmSaveDialog.deptId = selectedDeptId
                                confirmSaveDialog.deptName = selectedDeptName
                                confirmSaveDialog.managerId = selectedManagerId
                                confirmSaveDialog.managerName = selectedManagerName
                                confirmSaveDialog.gradeId = selectedGradeId
                                confirmSaveDialog.gradeCode = selectedGradeCode
                                confirmSaveDialog.originalName = editEmployeeDialog.employeeFirstName + " " + editEmployeeDialog.employeeLastName
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
        property string empFirstName: ""
        property string empLastName: ""
        property string empEmail: ""
        property string empRole: ""

        colorScheme: root.colorScheme
        dialogTitle: "Create Employee"
        message: "You are about to create a new employee."
        consequences: {
            var text = "• A new employee '" + empFirstName + " " + empLastName + "' will be created"
            text += "\n• Email: " + empEmail
            if (empRole) {
                text += "\n• Role: " + empRole
            }
            return text
        }
        confirmText: "Create"
        isDestructive: false

        onConfirmed: {
            if (personnelApp) {
                personnelApp.createEmployee(
                    empFirstName, empLastName, empEmail,
                    empRole, "", "", ""
                )
                createEmployeeDialog.close()
                createEmpFirstName.text = ""
                createEmpLastName.text = ""
                createEmpEmail.text = ""
                createEmpRole.text = ""
            }
        }
    }

    // Confirm save/update dialog
    ConfirmDialog {
        id: confirmSaveDialog
        property string empId: ""
        property string empFirstName: ""
        property string empLastName: ""
        property string empEmail: ""
        property string empRole: ""
        property string deptId: ""
        property string deptName: ""
        property string managerId: ""
        property string managerName: ""
        property string gradeId: ""
        property string gradeCode: ""
        property string originalName: ""

        colorScheme: root.colorScheme
        dialogTitle: "Save Changes"
        message: "You are about to update employee '" + originalName + "'."
        consequences: {
            var changes = []
            changes.push("• Name: " + empFirstName + " " + empLastName)
            changes.push("• Email: " + empEmail)
            if (empRole) {
                changes.push("• Role: " + empRole)
            }
            if (deptName !== "None") {
                changes.push("• Department: " + deptName)
            }
            if (managerName !== "None") {
                changes.push("• Manager: " + managerName)
            }
            if (gradeCode !== "None") {
                changes.push("• Salary Grade: " + gradeCode)
            }
            return changes.join("\n")
        }
        confirmText: "Save"
        isDestructive: false

        onConfirmed: {
            if (personnelApp) {
                var updates = {
                    "first_name": empFirstName,
                    "last_name": empLastName,
                    "email": empEmail
                }
                // Only include role if not empty
                if (empRole && empRole !== "") {
                    updates["role"] = empRole
                }
                // Handle nullable fields - use null for empty, otherwise the ID
                updates["department_id"] = (deptId && deptId !== "") ? deptId : null
                updates["manager_id"] = (managerId && managerId !== "") ? managerId : null
                updates["salary_grade_id"] = (gradeId && gradeId !== "") ? gradeId : null

                personnelApp.updateEmployee(empId, updates)
                editEmployeeDialog.close()
            }
        }
    }

    // Confirm delete dialog
    ConfirmDialog {
        id: confirmDeleteDialog
        property string employeeId: ""
        property string employeeName: ""

        colorScheme: root.colorScheme
        dialogTitle: "Delete Employee"
        message: "Are you sure you want to delete '" + employeeName + "'?"
        consequences: "• The employee record will be deactivated\n• Their assignments and history will be preserved\n• This action can be reversed by an administrator"
        confirmText: "Delete"
        isDestructive: true

        onConfirmed: {
            if (personnelApp) {
                personnelApp.deleteEmployee(employeeId)
            }
        }
    }
}
