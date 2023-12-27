import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import Flow 1.0

Window {
    id: managerWindow
    flags: Qt.Window|Qt.FramelessWindowHint|Qt.WindowMinimizeButtonHint
    visible: true
    width: 1200
    height: 600
    title: "流程图管理端"

    function packageFlow(flowId) {
        var selectDialog = fileDialogComponent.createObject(managerWindow)
        selectDialog.selectFinish.connect(function(filePath) {
            var waitingWindowParam = {title: "打包中"}
            var waitingWindow = waitingWindowComponent.createObject(managerWindow, waitingWindowParam)
            waitingWindow.closing.connect(function(close) {
                FlowManager.cancelPackage()
            })

            FlowManager.packageFinish.connect(function(isSuccess) {
                waitingWindow.close()
                var messageBoxParam = {
                    showCancelButton: false,
                    message: isSuccess?"打包成功":"打包失败"
                }
                messageBoxComponent.createObject(managerWindow, messageBoxParam)
            })
            FlowManager.packageFlowItem(flowId, filePath)
        })
    }

    WindowBase {
        id: windowBase
        window: managerWindow
        title: managerWindow.title
        GridView {
            id: gridView
            parent: windowBase.contentArea
            anchors.fill: parent
            clip: true
            cellWidth: width/columnCount
            cellHeight: 125
            property int columnCount: 8
            delegate: Item {
                required property string flowId
                required property bool isAddButton
                required property string content
                required property string iconSource

                id: gridItem
                width: gridView.cellWidth
                height: gridView.cellHeight

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onReleased: {
                        if (gridItem.isAddButton) {
                            return
                        }

                        if (mouse.button === Qt.RightButton) {
                            contextMenu.popup()
                        }
                    }

                    Menu {
                        id: contextMenu
                        width: 60

                        property int fontSize: 15
                        MenuItem {
                            text: "打包"
                            font.pointSize: contextMenu.fontSize
                            onTriggered: {
                                managerWindow.packageFlow(flowId)
                            }
                        }
                        MenuItem {
                            text: "复制"
                            font.pointSize: contextMenu.fontSize
                            onTriggered: {
                                var newFlowId = FlowManager.copyFlowItem(flowId)
                                var flowItem = flowItemComponent.createObject()
                                if (FlowManager.getFlowItem(newFlowId, flowItem)) {
                                    gridModel.addFlowItem(flowItem)
                                }
                            }
                        }
                        MenuItem {
                            text: "删除"
                            font.pointSize: contextMenu.fontSize
                            onTriggered: {
                                FlowManager.deleteFlowItem(flowId)
                                gridModel.deleteFlowItem(flowId)
                            }
                        }
                    }
                }

                // 添加按钮
                BorderImgButton {
                    visible: isAddButton
                    anchors.fill: parent
                    topInset: 10
                    bottomInset: 10
                    leftInset: 10
                    rightInset: 10
                    bgClickImage: "../res/add_button_bg_click.png"
                    bgNormalImage: "../res/add_button_bg_normal.png"
                    bgHoverImage: "../res/add_button_bg_hover.png"
                    bgDisableImage: "../res/add_button_bg_disable.png"
                    padding: 40
                    contentItem: Image {
                        source: "../res/add.png"
                    }
                    onClicked: {
                        var addWindow = addFlowWindowComponent.createObject(managerWindow)
                        addWindow.okClicked.connect(function() {
                            var flowItem = flowItemComponent.createObject()
                            flowItem.id = FlowManager.getUuid()
                            flowItem.name = addWindow.name
                            flowItem.logoFilePath = addWindow.logoPath
                            if (FlowManager.addFlowItem(flowItem)) {
                                // 添加完后，logo路径会变，重新获取
                                if (FlowManager.getFlowItem(flowItem.id, flowItem)) {
                                    gridModel.addFlowItem(flowItem)
                                }
                            }
                        })
                    }
                }

                // 流程图缩略图
                BorderImgButton {
                    visible: !isAddButton
                    anchors.fill: parent
                    padding: 10
                    topInset: padding
                    bottomInset: padding
                    leftInset: padding
                    rightInset: padding
                    contentItem: Column {
                        anchors.fill: parent
                        padding: parent.padding+10
                        topPadding: parent.padding+15
                        spacing: 8                        

                        Image {
                            width: parent.width-2*parent.padding
                            height: 40
                            source: iconSource
                            fillMode: Image.PreserveAspectFit
                            horizontalAlignment: Image.AlignHCenter
                            verticalAlignment: Image.AlignVCenter
                        }

                        Text {
                            width: parent.width-2*parent.padding
                            height: 20
                            text: content
                            color: "white"
                            font.pointSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignTop
                        }
                    }
                    onClicked: {
                        managerWindow.hide()
                        var params = {editable: true, flowId: gridItem.flowId, managerWindow: managerWindow}
                        flowGraphWindowComponent.createObject(null, params)
                    }
                }
            }
            model: gridModel
            Component.onCompleted: {
                var flows = FlowManager.flows;
                for (var index in flows) {
                    var flow = flows[index]
                    gridModel.addFlowItem(flow)
                }
            }
        }
    }

    ListModel {
        id: gridModel

        ListElement {
            flowId: ''
            isAddButton: true
            content: ''
            iconSource: ''
        }

        function addFlowItem(flow) {
            var item = {isAddButton: false, flowId: flow.id, content: flow.name, iconSource: flow.logoFilePath};
            gridModel.insert(gridModel.count-1, item);
        }

        function deleteFlowItem(flowId) {
            for (var i = 0; i < gridModel.count; i++) {
                var item = gridModel.get(i);
                if (item.flowId === flowId) {
                    gridModel.remove(i)
                    break
                }
            }
        }
    }

    Component {
        id: flowItemComponent
        FlowItem {}
    }

    Component {
        id: addFlowWindowComponent
        AddFlowWindow {}
    }

    Component {
        id: flowGraphWindowComponent
        FlowGraphWindow {}
    }

    Component {
        id: waitingWindowComponent
        WaitingWindow {}
    }

    Component {
        id: messageBoxComponent
        MessageBox {}
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            id: fileDialog
            title: "选择安装包"
            folder: shortcuts.desktop
            nameFilters: ["Zip file (*.zip)"]
            signal selectFinish(string filePath)
            onAccepted: {
                var filePath = fileDialog.fileUrl.toString()
                fileDialog.selectFinish(filePath)
            }
        }
    }
}
