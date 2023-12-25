﻿import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import Flow 1.0

Window {
    id: flowGraphWindow
    flags: Qt.Window|Qt.FramelessWindowHint|Qt.WindowMinimizeButtonHint|Qt.WindowMaximizeButtonHint
    visible: true
    visibility: Window.Maximized
    title: "流程图"
    width: 800
    height: 600
    property bool editable: false
    property string flowId: ''
    property var managerWindow: null    

    onClosing: {
        buildBlockManager.saveFlowGraph()
        if (managerWindow !== null) {
            managerWindow.show()
        }
    }

    onVisibilityChanged: {
        if (flowGraphWindow.visibility == Window.Windowed) {
            flowGraphWindow.visibility = Window.Maximized
        }
    }

    Component.onCompleted: {
        if (flowGraphWindow.flowId === "") {
            flowGraphWindow.flowId = FlowManager.flows[0].id
        }

        buildBlockManager.init()
        var buildBlocks = buildBlockManager.loadFlowGraph(flowGraphWindow.flowId)
        buildBlocks.forEach(function(item) {
            var buildBlock = buildBlockManager.createBuildBlock(item, contentPanel.contentItem)
            flowGraphWindow.initBuildBlockCtrl(buildBlock)
        })

        buildBlocks.forEach(function(item) {
            buildBlockManager.createBuildBlockConnection(item, contentPanel.contentItem)
        })

        timer.start()
    }

    function initBuildBlockCtrl(buildBlockCtrl) {
        buildBlockCtrl.editBuildBlock.connect(editBuildBlock)
        buildBlockCtrl.deleteBuildBlock.connect(buildBlockManager.deleteBuildBlock)
        buildBlockCtrl.pressPin.connect(onPressPin)
        buildBlockCtrl.dragPin.connect(onDragPin)
        buildBlockCtrl.releasePin.connect(onReleasePin)

        buildBlockCtrl.deleteNextConnection.connect(buildBlockManager.deleteNextConnection)

        if (buildBlockCtrl.submitFile !== undefined) {
            buildBlockCtrl.submitFile.connect(onSubmitFile)
        }

        if (buildBlockCtrl.deleteSubmitFile !== undefined) {
            buildBlockCtrl.deleteSubmitFile.connect(function(buildBlockCtrl, filePath) {
                var buildBlockData = buildBlockManager.getBuildBlockData(buildBlockCtrl.uuid)
                if (buildBlockData !== null) {
                    buildBlockData.submitFiles = buildBlockData.submitFiles.filter(function(submitFile) {
                        return submitFile.filePath !== filePath
                    })
                }
            })
        }

        if (buildBlockCtrl.okButtonClicked !== undefined) {
            buildBlockCtrl.okButtonClicked.connect(function(buildBlockCtrl){
                var buildBlockData = buildBlockManager.getBuildBlockData(buildBlockCtrl.uuid)
                if (buildBlockData !== null) {
                    buildBlockData.finish = true
                    buildBlockCtrl.okButton.enabled = false
                }
            })
        }
    }

    function onSubmitFile(buildBlock) {
        var buildBlockData = buildBlockManager.getBuildBlockData(buildBlock.uuid)
        if (buildBlockData === null) {
            return
        }

        if (buildBlockData.finish) {
            var canntSubmitParam = {
                message: "任务已完成，无法提交",
                showCancelButton: false
            }
            messageBoxComponent.createObject(flowGraphWindow, canntSubmitParam)
        } else {
            if (buildBlockManager.checkIfFinish(buildBlockData)) {
                var askFinishParam = {
                    message: "确定提交所有文件，完成任务？"
                }
                var messageBox = messageBoxComponent.createObject(flowGraphWindow, askFinishParam)
                messageBox.okClicked.connect(function() {
                    buildBlockData.finish = true
                })
            } else {
                var fileDialog = fileDialogComponent.createObject(flowGraphWindow)
                fileDialog.selectFileFinish.connect(function(filePath) {
                    var newFilePath = buildBlockManager.copyFile(filePath)
                    if (newFilePath === "") {
                        return
                    }

                    var icon = buildBlockManager.getFileIcon(newFilePath)
                    buildBlock.addLowerFile(icon, newFilePath)
                    buildBlockManager.submitFile(buildBlock.uuid, icon, newFilePath)
                    if (buildBlockManager.checkIfFinish(buildBlockData)) {
                        var askFinishParam = {
                            message: "确定提交所有文件，完成任务？"
                        }
                        messageBoxComponent.createObject(flowGraphWindow, askFinishParam)
                        messageBoxComponent.okClicked.connect(function() {
                            buildBlockData.finish = true
                        })
                    }
                })
                fileDialog.open()
            }
        }
    }

    function addBuildBlock(type, x, y) {
        var buildBlockData = buildBlockManager.createBuildBlockData()
        buildBlockData.x = x
        buildBlockData.y = y
        buildBlockData.type = type
        if (type === "text") {
            buildBlockData.finish = true
        }

        var params = {buildBlockData: buildBlockData, buildBlockManager: buildBlockManager}
        var editWindow = buildBlockEditWindowComponent.createObject(flowGraphWindow, params)
        editWindow.okClicked.connect(function(){
            buildBlockManager.addBuildBlockData(editWindow.buildBlockData)
            var buildBlock = buildBlockManager.createBuildBlock(editWindow.buildBlockData, contentPanel.contentItem)
            flowGraphWindow.initBuildBlockCtrl(buildBlock)
        })
    }

    function editBuildBlock(buildBlockId) {
        var buildBlockData = buildBlockManager.getBuildBlockData(buildBlockId)
        if (buildBlockData === null) {
            return
        }

        var params = {buildBlockData: buildBlockData, buildBlockManager: buildBlockManager}
        var editWindow = buildBlockEditWindowComponent.createObject(flowGraphWindow, params)
        editWindow.okClicked.connect(function(){
            buildBlockManager.updateBuildBlock(buildBlockData)
        })
    }

    function onPressPin(buildBlock) {
        //
    }

    function onDragPin(buildBlock, x, y) {
        var pos = buildBlock.mapToItem(contentPanel.contentItem, x, y)
        if (!mouseMovingArrowLine.visible) {
            mouseMovingArrowLine.visible = true
            mouseMovingArrowLine.beginPoint = pos
        }
        mouseMovingArrowLine.endPoint = pos
        mouseMovingArrowLine.requestPaint()
    }

    function onReleasePin(buildBlock) {
        mouseMovingArrowLine.visible = false
        buildBlockManager.createBuildBlockConnectionV2(mouseMovingArrowLine.beginPoint, mouseMovingArrowLine.endPoint, contentPanel.contentItem)
    }

    function onTimer() {
        // 调整画布大小
        var size = buildBlockManager.calculateBuildBlockContainerSize()
        if (size.x > contentPanel.contentWidth) {
            contentPanel.contentWidth = size.x
        }
        if (size.y > contentPanel.contentHeight) {
            contentPanel.contentHeight = size.y
        }
    }

    BuildBlockManager {
        id: buildBlockManager
        flowId: flowGraphWindow.flowId
        editable: flowGraphWindow.editable
    }

    WindowBase {
        id: windowBase
        window: flowGraphWindow
        title: flowGraphWindow.title
        Flickable {
            id: contentPanel
            parent: windowBase.contentArea
            anchors.fill: parent
            contentWidth: width
            contentHeight: height
            clip: true
            boundsMovement: Flickable.StopAtBounds
            boundsBehavior: Flickable.StopAtBounds
            interactive: false

            ScrollBar.horizontal: ScrollBar {
                active: true
            }

            ScrollBar.vertical: ScrollBar {
                active: true
            }

            Image {
                anchors.fill: parent
                source: "../res/flow_graph_window_bg.png"
                fillMode: Image.Tile
                horizontalAlignment: Image.AlignLeft
                verticalAlignment: Image.AlignTop
            }

            MouseArea {
                id: contentMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                property int mouseXWhenClick: 0
                property int mouseYWhenClick: 0
                onReleased: {
                    if (flowGraphWindow.editable && mouse.button === Qt.RightButton) {
                        mouseXWhenClick = mouse.x
                        mouseYWhenClick = mouse.y
                        contextMenu.popup()
                    }
                }

                Menu {
                    id: contextMenu
                    width: 150

                    property int fontSize: 15
                    MenuItem {
                        text: "添加备注模块"
                        font.pointSize: contextMenu.fontSize
                        onTriggered: {
                            flowGraphWindow.addBuildBlock("text", contentMouseArea.mouseXWhenClick, contentMouseArea.mouseYWhenClick)
                        }
                    }
                    MenuItem {
                        text: "添加基本模块"
                        font.pointSize: contextMenu.fontSize
                        onTriggered: {
                            flowGraphWindow.addBuildBlock("basic", contentMouseArea.mouseXWhenClick, contentMouseArea.mouseYWhenClick)
                        }
                    }
                    MenuItem {
                        text: "添加计时模块"
                        font.pointSize: contextMenu.fontSize
                        onTriggered: {
                            flowGraphWindow.addBuildBlock("timer", contentMouseArea.mouseXWhenClick, contentMouseArea.mouseYWhenClick)
                        }
                    }

                    Component {
                        id: buildBlockEditWindowComponent
                        BuildBlockEditWindow {}
                    }
                }
            }

            // 鼠标拖动时箭头连线
            ArrowLine {
                id: mouseMovingArrowLine
                visible: false
                anchors.fill: parent
            }
        }
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            id: fileDialog
            title: "选择文件"
            folder: shortcuts.pictures
            nameFilters: ["All files (*.*)"]
            signal selectFileFinish(string filePath)
            onAccepted: {
                var filePath = fileDialog.fileUrl.toString()
                fileDialog.selectFileFinish(filePath)
            }
        }
    }

    Component {
        id: messageBoxComponent
        MessageBox {}
    }

    Timer {
        id: timer
        interval: 1000 // Timer interval in milliseconds
        running: false // Start the timer immediately
        repeat: true // Repeat the timer indefinitely

        onTriggered: {
            buildBlockManager.onTimer()
            flowGraphWindow.onTimer()
        }
    }
}
