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
    height: 700

    // 模块JSON对象
    property var buildBlockData

    // 按下确定按钮
    signal okClicked()

    WindowBase {
        id: windowBase
        window: buildBlockEditWindow
        title: buildBlockEditWindow.title
        hasMinButton: false
        bgColor: "black"
        Column {
            parent: windowBase.contentArea
            property int padding: 10
            width: parent.width-2*padding
            height: parent.height-2*padding
            anchors.centerIn: parent

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
                    color: "black"
                    font.pointSize: 12
                    textMargin: 5
                    focus: true
                }

                ButtonBase {
                    id: addFileButton
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
                    id: addConditionButton
                    width: 50
                    height: 30
                    borderRadius: 4
                    anchors.left: addFileButton.right
                    anchors.leftMargin: 6
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                    icon.source: "../res/add.png"
                    onClicked: {
                        console.log("add condition")
                    }
                }
            }

            // 完成时长
            Control {
                id: timeLengthCtrl
                topPadding: 10
                bottomPadding: 10
                width: parent.width
                height: 40
                contentItem: Item {
                    // 时长标题
                    Text {
                        id: timeLengthTitleText
                        width: 30
                        height: parent.height
                        text: "时长"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        font.pointSize: 11
                    }

                    // 时长输入框
                    Rectangle {
                        id: timeLengthRectangle
                        width: 50
                        height: parent.height
                        anchors.left: timeLengthTitleText.right
                        anchors.leftMargin: 5
                        color: "white"
                        TextField {
                            id: timeLengthTextEdit
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 10
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                    }

                    // 时长单位：秒
                    Text {
                        id: secondText
                        width: 30
                        height: parent.height
                        text: "(秒)"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        font.pointSize: 11
                        anchors.left: timeLengthRectangle.right
                        anchors.leftMargin: 3
                    }
                }
            }

            // 提交文件条件
            Item {
                width: parent.width
                height: parent.height-fileListView.height-textArea.height-timeLengthCtrl.height-okArea.height

                ListView {
                    id: submitConditionListView
                    width: parent.width-20
                    height: parent.height-2*spacing
                    anchors.centerIn: parent
                    clip: true
                    spacing:10
                    model: buildBlockEditWindow.submitConditionModel
                    delegate: Item {
                        width: submitConditionListView.width
                        height: 20

                        // 后缀标题
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

                        // 后缀输入框
                        Rectangle {
                            id: suffixTextEdit
                            width: 50
                            height: parent.height
                            anchors.left: suffixText.right
                            anchors.leftMargin: 5
                            color: "white"
                            TextField {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.suffix
                                font.pointSize: 10
                            }
                        }

                        // 大小标题
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

                        // 大小最小输入框
                        Rectangle {
                            id: sizeMinTextEdit
                            width: 30
                            height: parent.height
                            anchors.left: sizeText.right
                            anchors.leftMargin: 5
                            color: "white"
                            TextField {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.sizeMin.toString()
                                font.pointSize: 10
                                inputMethodHints: Qt.ImhDigitsOnly
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

                        // 大小大值
                        Rectangle {
                            id: sizeMaxTextEdit
                            width: 30
                            height: parent.height
                            anchors.left: toImage.right
                            anchors.leftMargin: 10
                            color: "white"
                            TextField {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.sizeMax.toString()
                                font.pointSize: 10
                                inputMethodHints: Qt.ImhDigitsOnly
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
                            anchors.right: groupTextEdit.left
                            verticalAlignment: Text.AlignVCenter
                            anchors.rightMargin: 5
                            width: 30
                            height: parent.height
                            text: "分组"
                            color: "white"
                            font.pointSize: 11
                        }

                        // 分组输入框
                        Rectangle {
                            id: groupTextEdit
                            width: 60
                            height: parent.height
                            anchors.right: countText.left
                            anchors.rightMargin: 10
                            color: "white"
                            TextField {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.groupName
                                font.pointSize: 10
                            }
                        }

                        Text {
                            id: countText
                            anchors.right: countTextEdit.left
                            verticalAlignment: Text.AlignVCenter
                            anchors.rightMargin: 5
                            width: 30
                            height: parent.height
                            text: "数量"
                            color: "white"
                            font.pointSize: 11
                        }

                        // 数量输入框
                        Rectangle {
                            id: countTextEdit
                            width: 30
                            height: parent.height
                            anchors.right: deleteBtn.left
                            anchors.rightMargin: 10
                            color: "white"
                            TextField {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: model.count.toString()
                                font.pointSize: 10
                                inputMethodHints: Qt.ImhDigitsOnly
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

            // 确定取消
            Control {
                id: okArea
                topPadding: 15
                width: parent.width
                height: 55
                contentItem: Item {
                    ButtonBase {
                        width: 60
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: -40
                        text: "确定"
                        onClicked: {
                            if (!checkInputData()) {
                                return
                            }

                            buildBlockEditWindow.updateBuildBlockData()
                            okClicked()
                            buildBlockEditWindow.close()
                        }
                    }

                    ButtonBase {
                        width: 60
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 40
                        text: "取消"
                        onClicked: {
                            buildBlockEditWindow.close()
                        }
                    }
                }
            }
        }
    }

    // 文件列表Model
    ListModel {
        id: fileListModel
//        ListElement {
//            type: "image"
//            coverImage: "../res/template_image.png"
//            filePath: ""
//        }
    }

    // 提交文件条件Model
    ListModel {
        id: submitConditionModel
//        ListElement {
//           "groupName": ""
//            suffix: "png"
//            // 单位MB
//            sizeMin: 1
//            sizeMax: 2
//            count: 3
//        }
    }

    Component.onCompleted: {
        if (buildBlockData.type === "text") {
            fileListView.enabled = false
            textEdit.text = buildBlockData.text
            submitConditionListView.enabled = false
            timeLengthCtrl.enabled = false
            addFileButton.visible = false
            addConditionButton.visible = false
            timeLengthCtrl.visible = false
        } else {
            buildBlockData.studyFiles.forEach(function(item){
                fileListModel.append(item)
            })
            textEdit.enabled = false
            buildBlockData.finishCondition.forEach(function(item){
                submitConditionModel.append(item)
            })

            if (buildBlockData.type === "timer") {
                timeLengthTextEdit.text = buildBlockData.finishTimeLength.toString()
            }
        }
    }

    function checkInputData() {
        // todo by yejinlong, 提示用户
        if (buildBlockData.type === "text") {
            if (textEdit.text.length === 0) {
                return false
            }
        } else {
            if (fileListModel.count === 0) {
                return false
            }

            if (buildBlockData.type === "timer") {
                if (timeLengthTextEdit.text.length === 0) {
                    return false
                }
            }
        }

        return true
    }

    function updateBuildBlockData() {
        if (buildBlockData.type === "text") {
            buildBlockData.text = textEdit.text
        } else {
            buildBlockData.studyFiles = fileListModel
            buildBlockData.finishCondition = submitConditionModel
            buildBlockData.finishTimeLength = parseInt(timeLengthTextEdit.text)
        }
    }
}
