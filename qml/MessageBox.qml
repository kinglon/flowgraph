import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: messageBox
    flags: Qt.Window|Qt.FramelessWindowHint
    visible: true
    modality: Qt.WindowModal
    width: 380
    height: 180
    title: "提示"
    
    // 提示内容
    property string message: "提示内容"
    
    // 是否显示取消按钮
    property bool showCancelButton: true
    
    // 点击确定按钮
    signal okClicked()

    WindowBase {
        id: windowBase
        window: messageBox
        title: messageBox.title
        hasLogo: false
        hasMinButton: false
    }

    Item {
        id: windowContent
        parent: windowBase.contentArea
        anchors.fill: parent

        TextEdit {
            width: parent.width
            height: 80
            readOnly: true
            text: message
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            font.pointSize: 15
            textMargin: 20
            inputMethodHints: Qt.ImhMultiLine
        }

        Control {
            width: showCancelButton?135:60
            height: 40
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            ButtonBase {
                width: 60
                height: 36
                text: "确定"
                font.pointSize: 12
                anchors.left: parent.left
                onClicked: {
                    okClicked()
                    messageBox.close()
                }
            }

            ButtonBase {
                visible: showCancelButton
                width: 60
                height: 36
                anchors.right: parent.right
                text: "取消"
                font.pointSize: 12
                onClicked: {
                    messageBox.close()
                }
            }
        }
    }    
}
