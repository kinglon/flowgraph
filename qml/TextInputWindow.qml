import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: textInputWindow
    flags: Qt.Window|Qt.FramelessWindowHint
    visible: true
    modality: Qt.WindowModal
    width: 380
    height: 180
    title: "输入"
    
    // 文本内容
    property string content: ""

    // context，给调用者存储使用
    property var context
    
    // 点击确定按钮
    signal okClicked()

    WindowBase {
        id: windowBase
        window: textInputWindow
        title: textInputWindow.title
        hasLogo: false
        hasMinButton: false
    }

    Item {
        id: windowContent
        parent: windowBase.contentArea
        anchors.fill: parent

        Rectangle {
            width: parent.width-20
            height: 60
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"

            ScrollView {
                anchors.fill: parent

                TextArea {
                    id: textArea
                    text: content
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: TextEdit.Wrap
                    font.pointSize: 15
                    inputMethodHints: Qt.ImhMultiLine
                    selectByMouse: true
                    focus: true
                }
            }
        }

        Control {
            width: 135
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
                    if (textArea.text === "") {
                        var messageBoxParam = {
                            message: "内容不能为空",
                            showCancelButton: false
                        }
                        messageBoxComponent.createObject(textInputWindow, messageBoxParam)
                        return
                    }

                    textInputWindow.content = textArea.text
                    okClicked()
                    textInputWindow.close()
                }
            }

            ButtonBase {                
                width: 60
                height: 36
                anchors.right: parent.right
                text: "取消"
                font.pointSize: 12
                onClicked: {
                    textInputWindow.close()
                }
            }
        }
    }    

    Component {
        id: messageBoxComponent
        MessageBox {}
    }
}
