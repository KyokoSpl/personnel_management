import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import "../dialogs"

ScrollView {
    id: root
    property var colorScheme

    // Enable scrollbars and mouse wheel on Windows
    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
    clip: true

    contentWidth: availableWidth

    Column {
        width: root.availableWidth
        spacing: 12

        // Header
        RowLayout {
            width: parent.width
            spacing: 8

            Text {
                text: "Salary Grades"
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
                        personnelApp.refreshSalaryGrades()
                    }
                }
            }

            MaterialButton {
                text: "+ Add Salary Grade"
                primary: true
                colorScheme: root.colorScheme
                onClicked: createGradeDialog.open()
            }
        }

        // Salary grade list
        Repeater {
            model: personnelApp ? personnelApp.salaryGrades : []

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
                            text: modelData.code
                            font.pixelSize: 18
                            font.bold: true
                            color: colorScheme.textOnSurface
                        }

                        RowLayout {
                            spacing: 6

                            MaterialIcon {
                                icon: "attach_money"
                                iconColor: colorScheme.primary
                                size: 16
                            }

                            Text {
                                text: "$" + modelData.baseSalary.toFixed(0) + "/year"
                                font.pixelSize: 14
                                color: colorScheme.primary
                                font.weight: Font.Medium
                            }
                        }

                        RowLayout {
                            spacing: 6

                            MaterialIcon {
                                icon: "info"
                                iconColor: colorScheme.textOnSurfaceVariant
                                size: 16
                            }

                            Text {
                                text: modelData.description || "No description"
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
                                editGradeDialog.gradeId = modelData.id
                                editGradeDialog.gradeCode = modelData.code
                                editGradeDialog.gradeSalary = modelData.baseSalary
                                editGradeDialog.gradeDescription = modelData.description || ""
                                editGradeDialog.open()
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
                                    confirmDeleteDialog.gradeId = modelData.id
                                    confirmDeleteDialog.gradeCode = modelData.code
                                    confirmDeleteDialog.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Create salary grade dialog
    Dialog {
        id: createGradeDialog
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
            spacing: 20
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
                    text: "Create Salary Grade"
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
                        text: "Code *"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: gradeCode
                        placeholderText: "e.g., E3, M1"
                        colorScheme: root.colorScheme
                        width: parent.width
                    }
                }

                Column {
                    width: parent.width - 48
                    spacing: 8

                    Text {
                        text: "Base Salary *"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: gradeSalary
                        placeholderText: "e.g., 70000"
                        colorScheme: root.colorScheme
                        width: parent.width
                    }
                }

                Column {
                    width: parent.width - 48
                    spacing: 8

                    Text {
                        text: "Description"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: gradeDesc
                        placeholderText: "e.g., Mid Level Engineer"
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
                            createGradeDialog.close()
                            gradeCode.text = ""
                            gradeSalary.text = ""
                            gradeDesc.text = ""
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
                            if (personnelApp && gradeCode.text.trim() !== "" && gradeSalary.text.trim() !== "") {
                                // Store values for confirmation
                                confirmCreateDialog.code = gradeCode.text
                                confirmCreateDialog.salary = parseFloat(gradeSalary.text)
                                confirmCreateDialog.description = gradeDesc.text
                                confirmCreateDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // Edit salary grade dialog
    Dialog {
        id: editGradeDialog
        property string gradeId
        property string gradeCode
        property double gradeSalary
        property string gradeDescription

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
            editGradeCodeField.text = gradeCode
            editGradeSalaryField.text = gradeSalary.toString()
            editGradeDescField.text = gradeDescription
        }

        Column {
            width: parent.width
            spacing: 20
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
                    text: "Edit Salary Grade"
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
                        text: "Code *"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: editGradeCodeField
                        placeholderText: "e.g., E3, M1"
                        colorScheme: root.colorScheme
                        width: parent.width
                    }
                }

                Column {
                    width: parent.width - 48
                    spacing: 8

                    Text {
                        text: "Base Salary *"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: editGradeSalaryField
                        placeholderText: "e.g., 70000"
                        colorScheme: root.colorScheme
                        width: parent.width
                    }
                }

                Column {
                    width: parent.width - 48
                    spacing: 8

                    Text {
                        text: "Description"
                        font.pixelSize: 12
                        color: colorScheme.textOnSurfaceVariant
                        font.weight: Font.Medium
                    }

                    MaterialTextField {
                        id: editGradeDescField
                        placeholderText: "e.g., Mid Level Engineer"
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
                            editGradeDialog.close()
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
                            if (personnelApp && editGradeCodeField.text.trim() !== "" && editGradeSalaryField.text.trim() !== "") {
                                // Store values for confirmation
                                confirmSaveDialog.gradeId = editGradeDialog.gradeId
                                confirmSaveDialog.code = editGradeCodeField.text
                                confirmSaveDialog.salary = parseFloat(editGradeSalaryField.text)
                                confirmSaveDialog.description = editGradeDescField.text
                                confirmSaveDialog.originalCode = editGradeDialog.gradeCode
                                confirmSaveDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // Confirm delete dialog
    // Confirm create dialog
    ConfirmDialog {
        id: confirmCreateDialog
        property string code: ""
        property real salary: 0
        property string description: ""

        colorScheme: root.colorScheme
        dialogTitle: "Create Salary Grade"
        message: "You are about to create a new salary grade."
        consequences: {
            var text = "• A new salary grade '" + code + "' will be created"
            text += "\n• Base salary: $" + salary.toFixed(2)
            if (description) {
                text += "\n• Description: " + description
            }
            return text
        }
        confirmText: "Create"
        isDestructive: false

        onConfirmed: {
            if (personnelApp) {
                personnelApp.createSalaryGrade(code, salary, description)
                createGradeDialog.close()
                gradeCode.text = ""
                gradeSalary.text = ""
                gradeDesc.text = ""
            }
        }
    }

    // Confirm save/update dialog
    ConfirmDialog {
        id: confirmSaveDialog
        property string gradeId: ""
        property string code: ""
        property real salary: 0
        property string description: ""
        property string originalCode: ""

        colorScheme: root.colorScheme
        dialogTitle: "Save Changes"
        message: "You are about to update salary grade '" + originalCode + "'."
        consequences: {
            var changes = []
            changes.push("• Code: " + code)
            changes.push("• Base salary: $" + salary.toFixed(2))
            if (description) {
                changes.push("• Description: " + description)
            }
            changes.push("• Employees with this grade will see updated salary information")
            return changes.join("\n")
        }
        confirmText: "Save"
        isDestructive: false

        onConfirmed: {
            if (personnelApp) {
                personnelApp.updateSalaryGrade(gradeId, code, salary, description)
                editGradeDialog.close()
            }
        }
    }

    // Confirm delete dialog
    ConfirmDialog {
        id: confirmDeleteDialog
        property string gradeId: ""
        property string gradeCode: ""

        colorScheme: root.colorScheme
        dialogTitle: "Delete Salary Grade"
        message: "Are you sure you want to delete salary grade '" + gradeCode + "'?"
        consequences: "• The salary grade will be permanently removed\n• Employees assigned to this grade will no longer have a salary grade\n• This action cannot be undone"
        confirmText: "Delete"
        isDestructive: true

        onConfirmed: {
            if (personnelApp) {
                personnelApp.deleteSalaryGrade(gradeId)
            }
        }
    }
}
