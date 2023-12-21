import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: fileThumb    

    property string icon: ""

    property string filePath: ""

    property bool useSourceSize: true

    Image {
        id: image
        source: fileThumb.icon
        width: useSourceSize?sourceSize.width:parent.width
        height: useSourceSize?sourceSize.height:parent.height
        fillMode: useSourceSize?Image.Pad:Image.PreserveAspectFit
        anchors.centerIn: parent

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
}
