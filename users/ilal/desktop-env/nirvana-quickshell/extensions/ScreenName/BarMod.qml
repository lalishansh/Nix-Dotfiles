import QtQuick

Row {
    spacing: 15
    anchors.verticalCenter: parent.verticalCenter

    Text {
        text: screen ? `Monitor: ${screen.name}` : "Monitor: Unknown"
        color: "#FFdd00"
        font.pointSize: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: screen ? `${screen.width}x${screen.height}` : "N/A"
        color: "#ddFF00"
        font.pointSize: 9
        anchors.verticalCenter: parent.verticalCenter
    }
}
