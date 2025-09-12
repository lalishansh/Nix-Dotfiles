import QtQuick

Text {
    id: timeText
    color: "#00ffff"
    font.pointSize: 10

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss");
        }
    }

    Component.onCompleted: {
        text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss");
    }
}
