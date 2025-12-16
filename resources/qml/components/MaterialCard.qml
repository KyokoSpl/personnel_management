import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: card
    property var colorScheme
    property alias contentItem: content
    
    color: colorScheme.surfaceVariant
    radius: 16
    border.width: 1
    border.color: colorScheme.outlineVariant
    
    Item {
        id: content
        anchors.fill: parent
        anchors.margins: 20
    }
}
