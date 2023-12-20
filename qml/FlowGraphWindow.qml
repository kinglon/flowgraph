import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

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
            var buidlBlock = buildBlockManager.createBuildBlock(item, windowBase.contentArea)
            buidlBlock.editBuildBlock.connect(editBuildBlock)
            buidlBlock.deleteBuildBlock.connect(buildBlockManager.deleteBuildBlock)
            buidlBlock.pressPin.connect(onPressPin)
            buidlBlock.dragPin.connect(onDragPin)
            buidlBlock.releasePin.connect(onReleasePin)
        })

        buildBlocks.forEach(function(item) {
            buildBlockManager.createBuildBlockConnection(item, windowBase.contentArea)
        })
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
            var buidlBlock = buildBlockManager.createBuildBlock(editWindow.buildBlockData, windowBase.contentArea)
            buidlBlock.editBuildBlock.connect(editBuildBlock)
            buidlBlock.deleteBuildBlock.connect(buildBlockManager.deleteBuildBlock)
            buidlBlock.pressPin.connect(onPressPin)
            buidlBlock.dragPin.connect(onDragPin)
            buidlBlock.releasePin.connect(onReleasePin)
            buildBlockManager.saveFlowGraph()
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
        var beginItem = windowBase.contentArea.childAt(mouseMovingArrowLine.beginPoint.x, mouseMovingArrowLine.beginPoint.y)
        var endItem = windowBase.contentArea.childAt(mouseMovingArrowLine.endPoint.x, mouseMovingArrowLine.endPoint.y)
        buildBlockManager.createBuildBlockConnectionV2(beginItem, endItem, windowBase.contentArea)
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

            // 保存按钮
            ButtonBase {
                x: 15
                y: 15
                width: 60
                height: 40
                text: "保存"
                font.pointSize: 14
                onClicked: {
                   buildBlockManager.saveFlowGraph()
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
}
