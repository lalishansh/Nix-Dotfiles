// PopupWnd.qml
import QtQuick
import Quickshell
import Quickshell.Wayland

LazyLoader {
    id: root

    default property Item contentItem
    property Item hoverTarget
    property real alignment: Qt.AlignBottom
    property real alignmentMargin: 0

    active: hoverTarget.hovered || hoverTarget.containsMouse

    component: PopupWindow {
        visible: true
        color: "transparent"

        anchor.window: root.hoverTarget.QsWindow?.window
        anchor.rect.x: {
            const offset_x = root.hoverTarget.QsWindow?.window.itemRect(root.hoverTarget).x;
            switch (root.alignment) {
            case Qt.AlignLeft:
                return offset_x + root.alignmentMargin + root.hoverTarget.width;
            case Qt.AlignRight:
                return offset_x - root.alignmentMargin - this.width;
            default:
                return offset_x + (root.hoverTarget.width - this.width) * 0.5;
            }
        }
        anchor.rect.y: {
            const offset_y = root.hoverTarget.QsWindow?.window.itemRect(root.hoverTarget).y;
            switch (root.alignment) {
            case Qt.AlignBottom:
                return offset_y + root.alignmentMargin + root.hoverTarget.height;
            case Qt.AlignTop:
                return offset_y - root.alignmentMargin - this.height;
            default:
                return offset_y + (root.hoverTarget.height - this.height) * 0.5;
            }
        }
        implicitWidth: popupBackground.implicitWidth // 200
        implicitHeight: popupBackground.implicitHeight // 200

        Rectangle {
            id: popupBackground

            readonly property real margin: 10
            implicitWidth: root.contentItem ? root.contentItem.implicitWidth + this.margin * 2 : 75
            implicitHeight: root.contentItem ? root.contentItem.implicitHeight + this.margin * 2 : 75
            anchors.fill: parent

            color: "white"
            radius: 12
            border.color: "gray"
            border.width: 1

            children: root.contentItem ? [root.contentItem] : []
        }
    }
}
