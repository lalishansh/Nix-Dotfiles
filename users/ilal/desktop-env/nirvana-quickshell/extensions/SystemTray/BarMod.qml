import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import qs.core.templates

Row {
    id: root
    property bool overflowTrayVisible: false
    property bool barBottom: true // TODO: get data from config

    Button {
        id: trayOverflowButton
        visible: SystemTray.items.values.length > 0

        onClicked: (root.overflowTrayVisible = !root.overflowTrayVisible)

        background: Rectangle {
            radius: 4
            opacity: 0.05 + 0.2 * ((+root.overflowTrayVisible) + (+parent.hovered))
        }
        contentItem: Text {
            color: "white"
            // overflowTrayVisible barBottom logic (req  ?   ↑  :  ↓)
            // 1         +         1         2      0
            // 0         +         1         1      1
            // 1         +         0         1      1
            // 0         +         0         0      0
            text: (+root.overflowTrayVisible) + (+root.barBottom) === 1 ? "" : ""
            // text: {
            //     if (true) /*root.horizontal*/ {
            //         if (root.barBottom)
            //             return root.overflowTrayVisible ? "󰁊" : "󰁣";
            //         else
            //             return root.overflowTrayVisible ? "󰁢" : "󰁋";
            //     } else {
            //         if (true) /*bar.left*/
            //             return root.overflowTrayVisible ? "󰁒" : "󰁚";
            //         else
            //             return root.overflowTrayVisible ? "󰁙" : "󰁓";
            //     }
            // }
        }
        ToolPopup {
            // TODO: clicking outside unfocuses
            active: root.overflowTrayVisible
            hoverTarget: trayOverflowButton

            alignment: root.barBottom ? Qt.AlignTop : Qt.AlignBottom
            alignmentMargin: 10

            Grid {
                id: sysTray
                anchors.centerIn: parent
                columns: Math.ceil(Math.sqrt(SystemTray.items.values.length))
                columnSpacing: 10
                rowSpacing: 10

                Repeater {
                    model: SystemTray.items
                    delegate: SysTrayItem {}
                }
            }
        }
    }

    component SysTrayItem: MouseArea {
        id: trayItem
        required property SystemTrayItem modelData
        property alias item: trayItem.modelData

        property bool targetMenuOpen: false

        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        implicitWidth: icon.implicitWidth
        implicitHeight: icon.implicitHeight

        IconImage {
            id: icon
            source: item.icon
            implicitSize: 20
        }

        QsMenuAnchor {
            id: menuAnchor
            menu: item.menu

            anchor.window: parent.QsWindow.window
            anchor.adjustment: PopupAdjustment.Flip

            anchor.onAnchoring: {
                // TODO: Fix positioning
                const window = parent.QsWindow.window;
                const widgetRect = window.contentItem.mapFromItem(parent, 0, parent.height, parent.width, parent.height);

                menuAnchor.anchor.rect = widgetRect;
            }
        }

        ToolPopup {
            hoverTarget: trayItem
            alignment: Qt.AlignTop
            Text {
                anchors.centerIn: parent
                text: {
                    const title = trayItem.item.title;
                    const textTip = trayItem.item.tooltip || trayItem.item.tooltipTitle;
                    if (title && textTip) {
                        return title + "•\n" + textTip;
                    }
                    return textTip || trayItem.item.id || "System Tray Item, nothing to display :(";
                }
            }
        }

        onClicked: event => {
            event.accepted = true;
            switch (event.button) {
            case Qt.LeftButton:
                return item.activate();
            case Qt.MiddleButton:
                return item.secondaryActivate();
            case Qt.RightButton:
                return menuAnchor.open();
            }
        }
        onWheel: event => {
            event.accepted = true;
            const points = event.angleDelta.y / 120;
            item.scroll(points, false);
        }
    }
}
