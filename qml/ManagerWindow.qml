import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Flow 1.0

Window {
    id: managerWindow
    flags: Qt.Window|Qt.FramelessWindowHint|Qt.WindowMinimizeButtonHint
    visible: true
    width: 1200
    height: 600
    title: "流程图管理端"

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

                width: gridView.cellWidth
                height: gridView.cellHeight

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
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onReleased: {
                        if (mouse.button === Qt.RightButton) {
                            contextMenu.popup()
                        }
                    }

                    Menu {
                        id: contextMenu
                        width: 150

                        property int fontSize: 15
                        MenuItem {
                            text: "打包"
                            font.pointSize: contextMenu.fontSize
                            onTriggered: {
                                FlowManager.packageFlowItem(flowId)
                                // todo by yejinlong, 等待提示
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
        FlowItem {
            //
        }
    }

    Component {
        id: addFlowWindowComponent
        AddFlowWindow {
            //
        }
    }
}
