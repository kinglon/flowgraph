import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3

Window {
    id: buildBlockEditWindow
    flags: Qt.Window|Qt.FramelessWindowHint
    visible: true
    modality: Qt.WindowModal
    title: "添加模块"
    width: 1288
    // height: 700
    height: 960

    // 模块JSON对象
    property var buildBlockData

    property BuildBlockManager buildBlockManager

    // 按下确定按钮
    signal okClicked()

    Component.onCompleted: {
        buildBlockData.studyFiles.forEach(function(filePath) {
            var absolutePath = buildBlockManager.toAbsolutePath(filePath)
            buildBlockEditWindow.addFile(absolutePath)
        })
        buildBlockData.finishCondition.forEach(function(item) {
            submitConditionModel.append(item)
        })

        if (buildBlockData.type === "timer") {
            timeLengthTextEdit.text = buildBlockData.finishTimeLength.toString()
        } else {
            timeLengthCtrl.visible = false
        }
    }

    function checkInputData() {
        var messageBoxParam = {
            showCancelButton: false
        }

        if (fileListModel.count === 0) {
            messageBoxParam["message"] = "请至少导入一个文件"
            messageBoxComponent.createObject(buildBlockEditWindow, messageBoxParam)
            return false
        }

        for (var i=0; i<submitConditionModel.count; i++) {
            var item = submitConditionModel.get(i)
            if (item.groupName.length === 0 ||
                    item.suffix.length === 0 ||
                    item.sizeMin > item.sizeMax ||
                    item.count === 0) {
                messageBoxParam["message"] = "完成条件不符合规范"
                messageBoxComponent.createObject(buildBlockEditWindow, messageBoxParam)
                return false
            }
        }

        if (buildBlockData.type === "timer") {
            if (timeLengthTextEdit.text.length === 0) {
                messageBoxParam["message"] = "时间不能为空"
                messageBoxComponent.createObject(buildBlockEditWindow, messageBoxParam)
                return false
            }
        }

        return true
    }

    function updateBuildBlockData() {        
        buildBlockData.studyFiles = []
        for (var i=0; i<fileListModel.count; i++) {
            var studyFile = fileListModel.get(i).filePath.split('\\').pop()
            buildBlockData.studyFiles.push(studyFile)
        }

        buildBlockData.finishCondition = []
        for (i=0; i<submitConditionModel.count; i++) {
            buildBlockData.finishCondition.push(submitConditionModel.get(i))
        }
        buildBlockData.finishConditionGroup = ""
        if (submitConditionModel.count > 0) {
            buildBlockData.finishConditionGroup = submitConditionModel.get(0).groupName
        }

        buildBlockData.finishTimeLength = parseInt(timeLengthTextEdit.text)
    }

    function selectFile() {
        var fileDialog = fileDialogComponent.createObject(buildBlockEditWindow)
        fileDialog.open()
    }

    // filePath绝对路径
    function addFile(filePath) {
        var extension = utility.getFileExtension(filePath)
        var icon = ""
        if (utility.isImageFile(extension)) {
            icon = filePath
        } else if (utility.isVideoFile(extension)) {
            icon = "../res/default_video_cover.png"
        }
        fileListModel.append({"icon":icon, "filePath":filePath})
    }

    function addCondition() {
        var item = {
            groupName: "",
            suffix: "png",
            sizeMin: 0, // 单位MB
            sizeMax: 5,
            count: 1
        }
        submitConditionModel.append(item)
    }

    WindowBase {
        id: windowBase
        window: buildBlockEditWindow
        title: buildBlockEditWindow.title
        hasMinButton: false
        bgColor: "#B4BECD"
        Flickable {
            parent: windowBase.contentArea
            anchors.fill: parent
            contentWidth: width
            contentHeight: column.height
            clip: true
            boundsMovement: Flickable.StopAtBounds
            boundsBehavior: Flickable.StopAtBounds
            interactive: false

            ScrollBar.vertical: ScrollBar {
                active: true
            }

            Column {
                id: column
                width: parent.width
                height: fileListView.height+buttonArea.height+submitConditionListView.height+okArea.height

                // 文件缩略图列表
                ListView {
                    id: fileListView
                    width: parent.width
                    height: fileListModel.count*730+(fileListModel.count>1?(fileListModel.count-1)*spacing:0)
                    spacing: 30
                    orientation: ListView.Vertical
                    contentWidth: width
                    contentHeight: height
                    model: fileListModel
                    clip: true
                    delegate: FileThumb {
                        width: fileListView.width
                        height: 704
                        icon: model.icon
                        filePath: model.filePath
                        useSourceSize: false
                        editable: true

                        Connections {
                            function onDeleteFile(filePath) {
                                fileListModel.remove(index, 1)
                            }
                        }
                    }
                }

                // 按钮区域
                Rectangle {
                    id: buttonArea
                    color: "#B4BECD"
                    width: parent.width
                    height: 100

                    ButtonBase {
                        id: addFileButton
                        width: 70
                        height: 50
                        borderRadius: 10
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.top: parent.top
                        anchors.topMargin: 20
                        text: "导入"
                        onClicked: {
                            buildBlockEditWindow.selectFile()
                        }
                    }

                    ButtonBase {
                        id: addConditionButton
                        width: 70
                        height: 50
                        borderRadius: 10
                        anchors.left: addFileButton.right
                        anchors.leftMargin: 15
                        anchors.top: addFileButton.top
                        text: "条件"
                        onClicked: {
                            buildBlockEditWindow.addCondition()
                        }
                    }

                    // 完成时长
                    Rectangle {
                        id: timeLengthCtrl
                        width: 175
                        height: 50
                        color: addConditionButton.bgNormalColor
                        radius: 10
                        anchors.left: addConditionButton.right
                        anchors.leftMargin: 18
                        anchors.top: addConditionButton.top

                        // 时长标题
                        Text {
                            id: timeLengthTitleText
                            width: 70
                            height: parent.height
                            text: "时间:"
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 16
                            color: "white"
                        }

                        // 时长输入框
                        TextField {
                            id: timeLengthTextEdit
                            width: 77
                            height: parent.height-14
                            anchors.left: timeLengthTitleText.right
                            anchors.verticalCenter: parent.verticalCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 14
                            validator: IntValidator { bottom: 1}
                            selectByMouse: true
                        }

                        // 时长单位：时
                        Text {
                            id: secondText
                            width: 30
                            height: parent.height
                            text: "h"
                            anchors.left: timeLengthTextEdit.right
                            anchors.leftMargin: 5
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                            font.pointSize: 16
                        }
                    }
                }

                // 提交文件条件
                ListView {
                    id: submitConditionListView
                    width: parent.width
                    height: submitConditionModel.count*45
                    contentWidth: width
                    contentHeight: height
                    clip: true
                    model: submitConditionModel
                    delegate: Control {
                        width: submitConditionListView.width
                        height: 45
                        topPadding: 5
                        bottomPadding: 5
                        background: Rectangle {
                            color: "#151221"
                        }
                        contentItem: Item {
                            // 后缀标题
                            Text {
                                id: suffixText
                                width: 50
                                height: parent.height
                                text: "后缀"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                                font.pointSize: 13
                            }

                            // 后缀输入框
                            TextField {
                                id: suffixTextField
                                width: 120
                                height: parent.height
                                anchors.left: suffixText.right
                                anchors.leftMargin: 5
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: 11
                                selectByMouse: true                                
                                onTextChanged: {
                                    submitConditionModel.get(index).suffix = text
                                }
                                Component.onCompleted: {
                                    text = model.suffix
                                }
                            }

                            // 大小标题
                            Text {
                                id: sizeText
                                width: 140
                                height: parent.height
                                anchors.left: suffixTextField.right
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                text: "大小"
                                color: "white"
                                font.pointSize: 13
                            }

                            // 大小最小输入框
                            TextField {
                                id: sizeMinTextField
                                width: 120
                                height: parent.height
                                anchors.left: sizeText.right
                                anchors.leftMargin: 5
                                verticalAlignment: Text.AlignVCenter                                
                                font.pointSize: 11
                                validator: IntValidator { bottom: 0}
                                selectByMouse: true
                                onTextChanged: {                                    
                                    if (text === "") {
                                        submitConditionModel.get(index).sizeMin = 0
                                    } else {
                                        var value = parseInt(text, 10)
                                        submitConditionModel.get(index).sizeMin = value
                                    }
                                }
                                Component.onCompleted: {
                                    text = model.sizeMin.toString()
                                }
                            }

                            Text {
                                id: sizeMinText
                                anchors.left: sizeMinTextField.right
                                verticalAlignment: Text.AlignBottom
                                anchors.leftMargin: 5
                                width: 20
                                height: parent.height
                                text: ".mb"
                                color: "white"
                                font.pointSize: 13
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
                            TextField {
                                id: sizeMaxTextField
                                width: 120
                                height: parent.height
                                anchors.left: toImage.right
                                anchors.leftMargin: 30
                                verticalAlignment: Text.AlignVCenter                                
                                font.pointSize: 11
                                validator: IntValidator { bottom: 1}
                                selectByMouse: true                                
                                onTextChanged: {
                                    if (text === "") {
                                        submitConditionModel.get(index).sizeMax = 0
                                    } else {
                                        var value = parseInt(text, 10)
                                        submitConditionModel.get(index).sizeMax = value
                                    }
                                }
                                Component.onCompleted: {
                                    text = model.sizeMax.toString()
                                }
                            }

                            Text {
                                id: sizeMaxText
                                anchors.left: sizeMaxTextField.right
                                verticalAlignment: Text.AlignBottom
                                anchors.leftMargin: 5
                                width: 30
                                height: parent.height
                                text: ".mb"
                                color: "white"
                                font.pointSize: 13
                            }

                            Text {
                                id: groupText
                                width: 180
                                height: parent.height
                                anchors.right: groupTextField.left
                                anchors.rightMargin: 5
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                text: "分组"
                                color: "white"
                                font.pointSize: 13
                            }

                            // 分组输入框
                            TextField {
                                id: groupTextField
                                width: 120
                                height: parent.height
                                anchors.right: countText.left
                                verticalAlignment: Text.AlignVCenter                                
                                font.pointSize: 11
                                selectByMouse: true
                                onTextChanged: {
                                    submitConditionModel.get(index).groupName = text
                                }
                                Component.onCompleted: {
                                    text = model.groupName
                                }
                            }

                            Text {
                                id: countText
                                anchors.right: countTextField.left
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                anchors.rightMargin: 5
                                width: 50
                                height: parent.height
                                text: "数量"
                                color: "white"
                                font.pointSize: 13
                            }

                            // 数量输入框
                            TextField {
                                id: countTextField
                                width: 120
                                height: parent.height
                                anchors.right: deleteBtn.left
                                anchors.rightMargin: 10
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: 11
                                selectByMouse: true
                                validator: IntValidator { bottom: 1}
                                onTextChanged: {
                                    if (text === "") {
                                        submitConditionModel.get(index).count = 0
                                    } else {
                                        var value = parseInt(text, 10)
                                        submitConditionModel.get(index).count = value
                                    }
                                }
                                Component.onCompleted: {
                                    text = model.count.toString()
                                }
                            }

                            ButtonBase {
                                id: deleteBtn
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                width: 20
                                height: parent.height
                                text: "X"
                                font.pointSize: 10
                                borderRadius: 3
                                onClicked: {
                                    submitConditionModel.remove(index, 1)
                                }
                            }
                        }
                    }
                }

                // 确定取消
                Control {
                    id: okArea
                    topPadding: 15
                    bottomPadding: 15
                    width: parent.width
                    height: 70
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
    }

    // 文件列表Model
    ListModel {
        id: fileListModel
//        ListElement {
//            icon: "../res/default_video_cover.png"
//            filePath: ""
//        }
    }

    // 提交文件条件Model
    ListModel {
        id: submitConditionModel
//        ListElement {
//            groupName: ""
//            suffix: "png"
//            // 单位MB
//            sizeMin: 1
//            sizeMax: 2
//            count: 3
//        }
    }

    Utility {
        id: utility
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            id: fileDialog
            title: "选择文件"
            folder: shortcuts.pictures
            nameFilters: ["Image|Video files (*.png *.jpg *.jpeg *.bmp *.mp4 *.avi)"]
            onAccepted: {
                var filePath = fileDialog.fileUrl.toString()
                var newFilePath = buildBlockManager.copyFile(filePath)
                if (newFilePath === "") {
                    return
                }
                buildBlockEditWindow.addFile(newFilePath)
            }
        }
    }

    Component {
        id: messageBoxComponent
        MessageBox {}
    }
}
