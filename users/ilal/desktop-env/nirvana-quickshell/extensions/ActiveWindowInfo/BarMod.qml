// extensions/ActiveWindowInfo/BarModHyprland.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

Column {
    id: colLayout
    Layout.alignment: Qt.AlignTop

    // Get the active window from ToplevelManager
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    Text {
        font.pixelSize: 12
        color: "hotpink"
        text: activeWindow?.appId ?? "Desktop"
    }

    Text {
        font.pixelSize: 15
        color: "lawngreen"
        text: activeWindow?.title ?? "No active window"
    }
}
