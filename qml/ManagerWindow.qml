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
        window: managerWindow
        title: managerWindow.title
        content: GridView {
            property int columnCount: 8

            id: gridView
            anchors.fill: parent
            clip: true
            cellWidth: width/columnCount
            cellHeight: 125
            delegate: Item {
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
                        var addFlowWindowComponent = Qt.createComponent("AddFlowWindow.qml")
                        if (addFlowWindowComponent.status === Component.Ready) {
                            var addWindow = addFlowWindowComponent.createObject(managerWindow)
                            addWindow.okClicked.connect(function() {
                                var item = {isAddButton: false, content: addWindow.name, iconSource: addWindow.logoPath}
                                gridModel.insert(gridModel.count-1, item)

                                var flowItem = flowItemComponent.createObject()
                                flowItem.id = String(Math.floor(Date.now()/1000))
                                flowItem.name = addWindow.name
                                flowItem.logoFilePath = addWindow.logoPath
                                FlowManager.addFlowItem(flowItem)
                            })
                        } else {
                            console.log("Error loading AddFlowWindow component:", addFlowWindowComponent.errorString());
                        }
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
            }
            model: ListModel {
                id: gridModel

                ListElement {
                    isAddButton: true
                    content: ''
                    iconSource: ''
                }
            }
            Component.onCompleted: {
                var flows = FlowManager.flows;
                for (var index in flows) {
                    var flow = flows[index]
                    var item = {isAddButton: false, content: flow.name, iconSource: flow.logoFilePath};
                    gridModel.insert(gridModel.count-1, item);
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
}
