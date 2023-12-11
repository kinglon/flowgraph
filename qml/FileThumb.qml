import QtQuick 2.15
import QtQuick.Controls 2.15

Image {
    id: coverCtrl

    // image or video
    property string type: ""

    property string coverImage: "../res/template_image.png"

    property string filePath: ""

    source: coverImage
    fillMode: Image.PreserveAspectCrop

    Image {
        visible: coverCtrl.type != ""
        width: 33
        height: width
        source: coverCtrl.type=="image"?"../res/type_image.png":"../res/type_video.png"
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
    }

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
