import QtQuick 2.15

Text {
    id: root

    property string icon: ""
    property color iconColor: "#000000"
    property int size: 18

    text: icon
    font.family: "Material Icons"
    font.pixelSize: size
    color: iconColor
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter

    // Material Icons mapping
    readonly property var icons: ({
        "edit": "\ue3c9",
        "delete": "\ue872",
        "add": "\ue145",
        "person": "\ue7fd",
        "business": "\ue0af",
        "attach_money": "\ue227",
        "email": "\ue0be",
        "work": "\ue8f9",
        "check": "\ue5ca",
        "close": "\ue5cd",
        "info": "\ue88e",
        "refresh": "\ue5d5"
    })

    Component.onCompleted: {
        if (icons[icon]) {
            text = icons[icon]
        }
    }
}
