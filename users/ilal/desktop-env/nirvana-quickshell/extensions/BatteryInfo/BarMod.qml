import QtQuick
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import Quickshell

Text {
    id: batteryItem
    visible: false
    anchors.verticalCenter: parent.verticalCenter
    color: "gray"
    text: "No Battery"

    Process {
        id: batteryCheck
        command: ["sh", "-c", "test -d /sys/class/power_supply/BAT*"]
        running: true
        onExited: function (exitCode) {
            batteryItem.visible = exitCode === 0;
        }
    }

    Process {
        id: batteryProc
        // Modify command to get both capacity and status in one call
        command: ["sh", "-c", "echo $(cat /sys/class/power_supply/BAT*/capacity),$(cat /sys/class/power_supply/BAT*/status)"]
        running: batteryItem.visible

        stdout: SplitParser {
            onRead: function (data) {
                const [capacityStr, status] = data.trim().split(',');
                const batterySymbols = /* [10 + 1] */ ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
                const batteryColors = /* [10 + 1] */ ["#FF0000", "#FF3300", "#FF6600", "#FF9900", "#FFCC00", "#FFFF00", "#CCFF00", "#99FF00", "#66FF00", "#33FF00", "#00FF00"];
                const batteryStatus = {
                    "Unknown": "  ",
                    "Charging": "  ",
                    "Discharging": "  ",
                    "Not charging": "  ",
                    "Full": "  "
                };
                const capacityBy10 = parseInt(capacityStr) / 10;

                batteryItem.text = `${batterySymbols[capacityBy10]} ${capacityStr}% • ${batteryStatus[status]}`;
                batteryItem.color = batteryColors[capacityBy10];
            }
        }
    }

    Timer {
        interval: 1000
        running: batteryItem.visible
        repeat: true
        onTriggered: batteryProc.running = true
    }
}
