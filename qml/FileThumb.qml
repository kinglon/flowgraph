import QtQuick 2.15
import QtQuick.Controls 2.15

Image {
    id: fileThumb
    width: height
    source: icon
    fillMode: Image.Pad

    property string icon: ""

    property string filePath: ""

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton|Qt.LeftButton
        onReleased: {
            if (mouse.button === Qt.LeftButton) {
                // todo by yejinlong, open the local file
                console.log("left button click")
            } else if (mouse.button === Qt.RightButton) {
                // todo by yejinlong, show delete menu
                console.log("Right mouse button clicked on the image.")
            }
        }
    }
}
