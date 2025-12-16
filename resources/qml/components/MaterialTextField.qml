import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: control
    property var colorScheme

    color: control.colorScheme ? control.colorScheme.textOnSurface : "#E6E1E6"
    implicitWidth: 380
    implicitHeight: 44

    background: Rectangle {
        color: control.colorScheme ? control.colorScheme.surface : "#141218"
        radius: 8
        border.width: 1
        border.color: {
            if (!control.colorScheme) return control.activeFocus ? "#D0BCFF" : "#44404B"
            return control.activeFocus ? control.colorScheme.primary : control.colorScheme.outlineVariant
        }
    }

    placeholderTextColor: control.colorScheme ? control.colorScheme.textOnSurfaceVariant : "#CAC4D0"
}
