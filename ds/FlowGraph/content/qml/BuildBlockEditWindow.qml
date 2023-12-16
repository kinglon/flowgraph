import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: buildBlockEditWindow
    flags: Qt.Window|Qt.FramelessWindowHint
    visible: true
    modality: Qt.WindowModal
    title: "添加模块"
    width: 800
    height: 600

    property var buildBlockData

    // 备注模块的文本
    property string text: "备注模块"

    // 文件列表
    property ListModel fileListModel: ListModel {
        ListElement {
            type: "image"
            coverImage: "../res/template_image.png"
            filePath: ""
        }

        ListElement {
            type: "image"
            coverImage: "../res/template_image.png"
            filePath: ""
        }

        ListElement {
            type: "video"
            coverImage: "../res/template_image.png"
            filePath: ""
        }
    }

    // 提交文件条件
    property ListModel submitConditionModel: ListModel {
        ListElement {
            suffix: "png"
            // 单位MB
            sizeMin: 1
            sizeMax: 2
            count: 3
        }
    }

    WindowBase {
        id: windowBase
        window: buildBlockEditWindow
        title: buildBlockEditWindow.title
        hasMinButton: false
        bgColor: "black"
        Column {
            parent: windowBase.contentArea
            anchors.fill: parent

            // 文件缩略图列表
            ListView {
                id: fileListView
                width: parent.width
                height: 300
                spacing: 10
                orientation: ListView.Horizontal
                contentWidth: fileListModel.count*height
                model: fileListModel
                clip: true
                delegate: FileThumb {
                    width: height
                    height: fileListView.height
                    type: model.type
                    coverImage: model.coverImage
                    filePath: model.filePath
                }
            }

            // 文本框
            Rectangle {
                id: textArea
                color: "#B4BECD"
                width: parent.width
                height: 100

                TextEdit {
                    id: textEdit
                    color: "white"
                    //text: buildBlockEditWindow.text
                    text: buildBlockEditWindow.buildBlockData?buildBlockEditWindow.buildBlockData.text:""
                    font.pointSize: 12
                    textMargin: 5
                }

                ButtonBase {
                    id: addFileCtrl
                    width: 50
                    height: 30
                    borderRadius: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                    icon.source: "../res/add.png"
                    onClicked: {
                        console.log("add file")
                    }
                }

                ButtonBase {
                    width: 50
                    height: 30
                    borderRadius: 4
                    anchors.left: addFileCtrl.right
                    anchors.leftMargin: 6
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                    icon.source: "../res/add.png"
                    onClicked: {
                        console.log("add condition")
                    }
                }
            }

            // 提交文件条件
            Item {
                width: parent.width
                height: parent.height-fileListView.height-textArea.height

                ListView {
                    id: submitConditionListView
                    width: parent.width-40
                    height: parent.height-2*spacing
                    anchors.centerIn: parent
                    clip: true
                    spacing:10
                    model: buildBlockEditWindow.submitConditionModel
                    delegate: Item {
                        width: submitConditionListView.width
                        height: 20
                        Text {
                            id: suffixText
                            width: 30
                            height: parent.height
                            text: "后缀"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                            font.pointSize: 11
                        }

                        Rectangle {
                            id: suffixTextEdit
                            width: 50
                            height: parent.height
                            anchors.left: suffixText.right
                            anchors.leftMargin: 5
                            color: "white"
                            TextEdit {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.suffix
                                font.pointSize: 10
                                textMargin: 3
                            }
                        }

                        Text {
                            id: sizeText
                            width: 30
                            height: parent.height
                            anchors.left: suffixTextEdit.right
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.leftMargin: 70
                            text: "大小"
                            color: "white"
                            font.pointSize: 11
                        }

                        Rectangle {
                            id: sizeMinTextEdit
                            width: 30
                            height: parent.height
                            anchors.left: sizeText.right
                            anchors.leftMargin: 5
                            color: "white"
                            TextEdit {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.sizeMin.toString()
                                font.pointSize: 10
                                textMargin: 3
                            }
                        }

                        Text {
                            id: sizeMinText
                            anchors.left: sizeMinTextEdit.right
                            verticalAlignment: Text.AlignBottom
                            anchors.leftMargin: 5
                            width: 20
                            height: parent.height
                            text: ".mb"
                            color: "white"
                            font.pointSize: 11
                        }

                        Image {
                            id: toImage
                            anchors.left: sizeMinText.right
                            anchors.leftMargin: 10
                            width: 25
                            height: parent.height
                            source: "../res/to.png"
                        }

                        Rectangle {
                            id: sizeMaxTextEdit
                            width: 30
                            height: parent.height
                            anchors.left: toImage.right
                            anchors.leftMargin: 10
                            color: "white"
                            TextEdit {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.sizeMax.toString()
                                font.pointSize: 10
                                textMargin: 3
                            }
                        }

                        Text {
                            anchors.left: sizeMaxTextEdit.right
                            verticalAlignment: Text.AlignBottom
                            anchors.leftMargin: 5
                            width: 30
                            height: parent.height
                            text: ".mb"
                            color: "white"
                            font.pointSize: 11
                        }

                        Text {
                            anchors.right: countTextEdit.left
                            verticalAlignment: Text.AlignVCenter
                            anchors.rightMargin: 5
                            width: 30
                            height: parent.height
                            text: "数量"
                            color: "white"
                            font.pointSize: 11
                        }

                        Rectangle {
                            id: countTextEdit
                            width: 30
                            height: parent.height
                            anchors.right: deleteBtn.left
                            anchors.rightMargin: 10
                            color: "white"
                            TextEdit {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.count.toString()
                                font.pointSize: 10
                                textMargin: 3
                            }
                        }

                        ButtonBase {
                            id: deleteBtn
                            anchors.right: parent.right
                            width: 20
                            height: parent.height
                            text: "X"
                            font.pointSize: 10
                            borderRadius: 3
                            onClicked: {
                                console.log("delete item")
                            }
                        }
                    }
                }
            }
        }
    }
}
