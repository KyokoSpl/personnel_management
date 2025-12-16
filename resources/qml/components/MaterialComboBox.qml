import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: control

    property var colorScheme
    property string labelText: ""

    implicitHeight: 48

    // Label above the combo box
    Item {
        anchors.bottom: parent.top
        anchors.bottomMargin: 4
        visible: control.labelText !== ""

        Text {
            text: control.labelText
            font.pixelSize: 12
            color: control.colorScheme ? control.colorScheme.textOnSurfaceVariant : "#CAC4D0"
            font.weight: Font.Medium
        }
    }

    background: Rectangle {
        color: control.colorScheme ? control.colorScheme.surfaceVariant : "#2C2831"
        radius: 8
        border.width: control.activeFocus ? 2 : 1
        border.color: {
            if (!control.colorScheme) return control.activeFocus ? "#D0BCFF" : "#938F99"
            return control.activeFocus ? control.colorScheme.primary : control.colorScheme.outline
        }
    }

    contentItem: Text {
        leftPadding: 12
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font.pixelSize: 14
        color: control.colorScheme ? control.colorScheme.textOnSurface : "#E6E1E6"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - 12
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() { canvas.requestPaint(); }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.colorScheme ? control.colorScheme.textOnSurfaceVariant : "#CAC4D0";
            context.fill();
        }
    }

    popup: Popup {
        y: control.height + 4
        width: control.width
        implicitHeight: contentItem.implicitHeight + 16
        padding: 8

        background: Rectangle {
            color: control.colorScheme ? control.colorScheme.surface : "#141218"
            radius: 8
            border.width: 1
            border.color: control.colorScheme ? control.colorScheme.outline : "#938F99"

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 4
                radius: 8
                samples: 17
                color: "#40000000"
            }
        }

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    delegate: ItemDelegate {
        width: control.width - 16
        height: 40

        contentItem: Text {
            text: modelData
            color: control.colorScheme ? control.colorScheme.textOnSurface : "#E6E1E6"
            font.pixelSize: 14
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }

        background: Rectangle {
            color: {
                if (!control.colorScheme) return parent.highlighted ? "#4F378B" : "transparent"
                return parent.highlighted ? control.colorScheme.primaryContainer : "transparent"
            }
            radius: 4
        }
    }
}
