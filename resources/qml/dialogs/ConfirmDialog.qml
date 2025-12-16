import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root

    property var colorScheme
    property string dialogTitle: "Confirm Action"
    property string message: "Are you sure you want to proceed?"
    property string consequences: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property bool isDestructive: false

    // Default colors for when colorScheme is undefined
    readonly property color defaultPrimary: "#D0BCFF"
    readonly property color defaultSurface: "#141218"
    readonly property color defaultSurfaceVariant: "#2C2831"
    readonly property color defaultTextOnSurface: "#E6E1E6"
    readonly property color defaultTextOnSurfaceVariant: "#CAC4D0"
    readonly property color defaultOutline: "#938F99"
    readonly property color defaultError: "#F2B8B5"

    // Helper functions for safe color access
    function getPrimary() { return root.colorScheme ? root.colorScheme.primary : defaultPrimary }
    function getSurface() { return root.colorScheme ? root.colorScheme.surface : defaultSurface }
    function getSurfaceVariant() { return root.colorScheme ? root.colorScheme.surfaceVariant : defaultSurfaceVariant }
    function getTextOnSurface() { return root.colorScheme ? root.colorScheme.textOnSurface : defaultTextOnSurface }
    function getTextOnSurfaceVariant() { return root.colorScheme ? root.colorScheme.textOnSurfaceVariant : defaultTextOnSurfaceVariant }
    function getOutline() { return root.colorScheme ? root.colorScheme.outline : defaultOutline }
    function getError() { return root.colorScheme ? root.colorScheme.error : defaultError }

    signal confirmed()
    signal cancelled()

    modal: true
    anchors.centerIn: parent
    width: 450
    padding: 0
    header: Item {}
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    background: Rectangle {
        color: getSurface()
        radius: 12
        border.width: 1
        border.color: getOutline()

        // Shadow
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 4
            anchors.rightMargin: -4
            anchors.bottomMargin: -4
            z: -1
            radius: 12
            color: "#25000000"
        }
    }

    contentItem: Column {
        spacing: 0

        // Custom header area
        Rectangle {
            width: parent.width
            height: 56
            color: root.isDestructive ? Qt.rgba(getError().r, getError().g, getError().b, 0.15) : "transparent"
            radius: 12

            // Flatten bottom corners
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 12
                color: parent.color
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 12

                Text {
                    text: root.isDestructive ? "⚠" : "ℹ"
                    font.pixelSize: 20
                    color: root.isDestructive ? getError() : getPrimary()
                }

                Text {
                    text: root.dialogTitle
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: root.isDestructive ? getError() : getTextOnSurface()
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }

        // Content area
        Column {
            width: parent.width
            spacing: 16
            topPadding: 16
            bottomPadding: 24
            leftPadding: 24
            rightPadding: 24

            // Main message
            Text {
                text: root.message
                font.pixelSize: 15
                color: getTextOnSurface()
                wrapMode: Text.WordWrap
                width: parent.width - 48
                lineHeight: 1.3
            }

            // Consequences section (if provided)
            Rectangle {
                width: parent.width - 48
                height: consequencesColumn.height + 16
                color: getSurfaceVariant()
                radius: 8
                visible: root.consequences !== ""

                Column {
                    id: consequencesColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 6

                    Text {
                        text: "What will happen:"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: getTextOnSurfaceVariant()
                    }

                    Text {
                        text: root.consequences
                        font.pixelSize: 13
                        color: getTextOnSurface()
                        wrapMode: Text.WordWrap
                        width: parent.width
                        lineHeight: 1.4
                    }
                }
            }

            // Spacer
            Item {
                width: 1
                height: 8
            }

            // Buttons
            Row {
                spacing: 12
                anchors.right: parent.right
                anchors.rightMargin: 0

                Button {
                    text: root.cancelText
                    implicitHeight: 40
                    implicitWidth: Math.max(90, contentItem.implicitWidth + 24)

                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(0, 0, 0, 0.05) : "transparent"
                        radius: 8
                        border.width: 1
                        border.color: getOutline()
                    }

                    contentItem: Text {
                        text: parent.text
                        color: getTextOnSurface()
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                    }

                    onClicked: {
                        root.cancelled()
                        root.close()
                    }
                }

                Button {
                    text: root.confirmText
                    implicitHeight: 40
                    implicitWidth: Math.max(90, contentItem.implicitWidth + 24)

                    background: Rectangle {
                        color: {
                            var baseColor = root.isDestructive ? getError() : getPrimary()
                            return parent.hovered ? Qt.darker(baseColor, 1.1) : baseColor
                        }
                        radius: 8
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }

                    onClicked: {
                        root.confirmed()
                        root.close()
                    }
                }
            }
        }
    }

    // Close on escape
    onRejected: {
        root.cancelled()
    }
}
