import QtQuick
import Quickshell

Text {
    anchors.verticalCenter: parent.verticalCenter
    color: "#00ffff"
    font.pointSize: 10

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    text: Qt.formatDateTime(clock.date, "hh:mm:ss • ddd, dd/MM")
}
