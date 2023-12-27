import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3

Window {
    id: addFlowWindow
    flags: Qt.Window|Qt.FramelessWindowHint
    visible: true
    modality: Qt.WindowModal
    width: 420
    height: 300
    title: "添加"

    // 名字
    property string name: ""

    // logo图片路径
    property string logoPath: ""

    // 按下确定按钮
    signal okClicked()

    WindowBase {
        id: windowBase
        window: addFlowWindow
        title: addFlowWindow.title
        hasLogo: false
        hasMinButton: false        
    }

    Column {
        id: windowContent
        parent: windowBase.contentArea
        padding: 20
        spacing: 10

        Row {
            height: 40
            Text {
                width: 50
                height: parent.height
                text: "名字"
                font.pointSize: 14
                verticalAlignment: Text.AlignVCenter                
            }

            TextField {
                id: nameCtrl
                width: 300
                height: parent.height
                font.pointSize: 14
                text: addFlowWindow.name
                selectByMouse: true
            }
        }

        Row {
            height: 100
            spacing: 25
            leftPadding: 55
            ButtonBase {
                topInset: 20
                bottomInset: 20
                width: 120
                height: parent.height
                font.bold: false
                font.pointSize: 16
                text: '选择logo'
                onClicked: {
                    var fileDialog = fileDialogComponent.createObject(addFlowWindow)
                    fileDialog.open()
                }
            }

            Image {
                id: logoCtrl
                width: height*4/3
                height: parent.height
                source: "../res/template_image.png"
                fillMode: Image.PreserveAspectFit
                Component.onCompleted: {
                    if (addFlowWindow.logoPath.length > 0) {
                        logoCtrl.source = addFlowWindow.logoPath
                    }
                }
            }
        }

        Row {
            height: 40
            spacing: 15
            leftPadding: 110
            topPadding: 10

            ButtonBase {
                width: 60
                height: parent.height
                text: "确定"
                onClicked: {
                    if (nameCtrl.text.length == 0) {
                        var nameCantEmpty = {
                            message: "名字不能为空",
                            showCancelButton: false
                        }
                        messageBoxComponent.createObject(addFlowWindow, nameCantEmpty)
                        return
                    }

                    if (logoPath.length == 0) {
                        var logoCantEmpty = {
                            message: "logo不能为空",
                            showCancelButton: false
                        }
                        messageBoxComponent.createObject(addFlowWindow, logoCantEmpty)
                        return
                    }

                    addFlowWindow.name = nameCtrl.text
                    okClicked()
                    addFlowWindow.close()
                }
            }

            ButtonBase {
                width: 60
                height: parent.height
                text: "取消"
                onClicked: {
                    addFlowWindow.close()
                }
            }
        }
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            id: fileDialog
            title: "选择logo"
            folder: shortcuts.pictures
            nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp)"]
            onAccepted: {
                addFlowWindow.logoPath = fileDialog.fileUrl
                logoCtrl.source = addFlowWindow.logoPath
            }
        }
    }

    Component {
        id: messageBoxComponent
        MessageBox {}
    }
}
