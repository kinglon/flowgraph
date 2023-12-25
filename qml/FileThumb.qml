import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: fileThumb    

    property string icon: ""

    property string filePath: ""

    property bool useSourceSize: true

    property bool editable: false

    signal deleteFile(string filePath)

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
                    Qt.openUrlExternally(fileThumb.filePath)
                } else if (mouse.button === Qt.RightButton) {
                    if (fileThumb.editable) {
                        contextMenu.popup()
                    }
                }
            }

            Menu {
                id: contextMenu
                width: 60

                property int fontSize: 15
                MenuItem {
                    text: "删除"
                    font.pointSize: contextMenu.fontSize
                    onTriggered: {
                        fileThumb.deleteFile(fileThumb.filePath)
                    }
                }
            }
        }
    }
}
