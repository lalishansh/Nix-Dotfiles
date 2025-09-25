// SysTrayBarMod.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import qs.core.templates

Row {
    id: root
    property bool quickSettingsVisible: false
    Timer {
        id: autoCloseAfterTrayOpen
        interval: 2000
        onTriggered: parent.quickSettingsVisible = false
    }
    Button {
        id: trayOverflowButton
        onClicked: {
            parent.quickSettingsVisible = !parent.quickSettingsVisible;
            autoCloseAfterTrayOpen.running = true;
        }
        text: parent.quickSettingsVisible ? "Close The Tray" : "Open The Tray"
    }
    PanelWindow {
        visible: root.quickSettingsVisible

        anchors {
            top: true
            bottom: true
            right: true
        }
        Text {
            id: testText
            text: "text"
        }
    }
}--quiet
