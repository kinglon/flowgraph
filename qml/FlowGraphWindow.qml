import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3

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

    BuildBlockManager {
        id: buildBlockManager
        flowId: flowGraphWindow.flowId
    }

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
        buildBlockManager.init()
        var buildBlocks = buildBlockManager.loadFlowGraph(flowGraphWindow.flowId)
        buildBlocks.forEach(function(item) {
            var buildBlock = buildBlockManager.createBuildBlock(item, windowBase.contentArea)
            flowGraphWindow.initBuildBlockCtrl(buildBlock)
        })

        buildBlocks.forEach(function(item) {
            buildBlockManager.createBuildBlockConnection(item, windowBase.contentArea)
        })
    }

    function initBuildBlockCtrl(buildBlockCtrl) {
        buildBlockCtrl.editBuildBlock.connect(editBuildBlock)
        buildBlockCtrl.deleteBuildBlock.connect(buildBlockManager.deleteBuildBlock)
        buildBlockCtrl.pressPin.connect(onPressPin)
        buildBlockCtrl.dragPin.connect(onDragPin)
        buildBlockCtrl.releasePin.connect(onReleasePin)
        if (buildBlockCtrl.submitFile !== undefined) {
            buildBlockCtrl.submitFile.connect(function(buildBlock) {
                var fileDialog = fileDialogComponent.createObject(flowGraphWindow)
                fileDialog.selectFileFinish.connect(function(filePath) {
                    var newFilePath = buildBlockManager.copyFile(filePath)
                    if (newFilePath === "") {
                        return
                    }

                    var icon = buildBlockManager.getFileIcon(newFilePath)
                    buildBlock.addLowerFile(icon, newFilePath)
                    buildBlockManager.submitFile(buildBlock.uuid, icon, newFilePath)
                })
                fileDialog.open()
            })
        }
    }

    function addBuildBlock(type, x, y) {
        var buildBlockData = buildBlockManager.createBuildBlockData()
        buildBlockData.x = x
        buildBlockData.y = y
        buildBlockData.type = type
        var params = {buildBlockData: buildBlockData, buildBlockManager: buildBlockManager}
        var editWindow = buildBlockEditWindowComponent.createObject(flowGraphWindow, params)
        editWindow.okClicked.connect(function(){
            buildBlockManager.addBuildBlockData(editWindow.buildBlockData)
            var buildBlock = buildBlockManager.createBuildBlock(editWindow.buildBlockData, windowBase.contentArea)
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
        var pos = buildBlock.mapToItem(windowBase.contentArea, x, y)
        if (!mouseMovingArrowLine.visible) {
            mouseMovingArrowLine.visible = true
            mouseMovingArrowLine.beginPoint = pos
        }
        mouseMovingArrowLine.endPoint = pos
        mouseMovingArrowLine.requestPaint()
    }

    function onReleasePin(buildBlock) {
        mouseMovingArrowLine.visible = false
        buildBlockManager.createBuildBlockConnectionV2(mouseMovingArrowLine.beginPoint, mouseMovingArrowLine.endPoint, windowBase.contentArea)
    }

    WindowBase {
        id: windowBase
        window: flowGraphWindow
        title: flowGraphWindow.title
        Item {
            parent: windowBase.contentArea
            anchors.fill: parent

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
}
