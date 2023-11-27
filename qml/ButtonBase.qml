import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    width: 75
    height: 50
    text: "确定"
    font.styleName: "Bold"
    font.family: "Arial"
    font.bold: true
    font.pointSize: 16
    palette.buttonText: "#FFFFFF"
    display: AbstractButton.TextBesideIcon
    
    property int borderWidth: 0

    property color borderColor: "#ffffff"

    background: Rectangle {
        color: parent.down ? "#1E2330" : (parent.containsMouse ? "#3C465F" : "#2D3447")
        border.width: borderWidth
        radius: 10
        border.color: borderColor
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onPressed: parent.down = true
        onReleased: parent.down = false
    }
}
