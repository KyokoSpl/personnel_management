import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: control
    property string icon: ""
    property var colorScheme
    property bool primary: false
    signal clicked()

    width: 40
    height: 40

    Rectangle {
        id: background
        anchors.fill: parent
        color: {
            if (!control.colorScheme) return "transparent"
            if (mouseArea.containsMouse) {
                return control.primary ? Qt.lighter(control.colorScheme.primary, 1.2) : control.colorScheme.surfaceVariant
            }
            return control.primary ? control.colorScheme.primary : "transparent"
        }
        radius: 20
        opacity: control.enabled ? 1.0 : 0.5

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: control.icon
        iconColor: {
            if (!control.colorScheme) return control.primary ? "#381E72" : "#E6E1E6"
            return control.primary ? control.colorScheme.textOnPrimary : control.colorScheme.textOnSurface
        }
        size: 20
        opacity: control.enabled ? 1.0 : 0.5
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: control.clicked()
    }
}
