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
    property bool editable: true

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
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onReleased: {                    
                    if (flowGraphWindow.editable && mouse.button === Qt.RightButton) {
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
                            var buildBlockData = buildBlockManager.createBuildBlock("12345","text")
                            buildBlockData.text = "12345"
                            var editWindow = buildBlockEditWindowComponent.createObject(flowGraphWindow, {buildBlockData=buildBlockData})
                        }
                    }
                    MenuItem {
                        text: "添加基本模块"
                        font.pointSize: contextMenu.fontSize
                        onTriggered: {
                            console.log("添加基本模块")
                        }
                    }
                    MenuItem {
                        text: "添加计时模块"
                        font.pointSize: contextMenu.fontSize
                        onTriggered: {
                            console.log("添加计时模块")
                        }
                    }

                    Component {
                        id: buildBlockEditWindowComponent
                        BuildBlockEditWindow {

                        }
                    }
                }
            }            
        }
    }

    BuildBlockManager {
        id: buildBlockManager
    }

    onVisibilityChanged: {
        if (flowGraphWindow.visibility == Window.Windowed) {
            flowGraphWindow.visibility = Window.Maximized
        }
    }
}
