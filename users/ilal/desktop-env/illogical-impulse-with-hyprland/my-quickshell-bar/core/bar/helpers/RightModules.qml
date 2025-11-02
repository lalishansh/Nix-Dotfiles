import QtQuick
import QtQuick.Layouts

import "./others"

Item {
    id: rightContent

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.rightMargin: 10

    default property alias contentItems: childRow.children
    signal scrollUp(delta: int)
    signal scrollDown(delta: int)
    signal clicked
    FocusedScrollMouseArea {
        anchors.fill: parent
        onScrollUp: delta => parent.scrollUp(delta)
        onScrollDown: delta => parent.scrollDown(delta)
        onClicked: parent.clicked()
    }
    // // For Debug
    // Rectangle {
    //     anchors.fill: parent
    //     color: "blue"
    // }

    Row {
        id: childRow
        spacing: 4
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
