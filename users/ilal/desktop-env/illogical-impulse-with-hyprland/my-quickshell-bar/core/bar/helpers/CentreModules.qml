import QtQuick
import QtQuick.Layouts

import "./others"

Item {
    id: centerContent

    Layout.fillWidth: false
    Layout.fillHeight: true
    Layout.minimumWidth: implicitWidth
    Layout.leftMargin: 10
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
    //     color: "green"
    // }

    Row {
        id: childRow
        spacing: 4
        anchors.centerIn: parent
    }
    implicitWidth: childRow.implicitWidth
}
