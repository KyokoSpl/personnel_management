import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    property bool primary: false
    property var colorScheme

    implicitWidth: Math.max(90, contentItem.implicitWidth + 32)
    implicitHeight: 36

    background: Rectangle {
        color: {
            if (!control.colorScheme) return control.primary ? "#D0BCFF" : "#2C2831"
            return control.primary ? control.colorScheme.primary : control.colorScheme.surfaceVariant
        }
        radius: 8
        opacity: control.enabled ? 1.0 : 0.5
    }

    contentItem: Text {
        text: control.text
        font.pixelSize: 13
        color: {
            if (!control.colorScheme) return control.primary ? "#381E72" : "#E6E1E6"
            return control.primary ? control.colorScheme.textOnPrimary : control.colorScheme.textOnSurface
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: control.enabled ? 1.0 : 0.5
    }
}
