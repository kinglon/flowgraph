import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

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
                        var item = {isAddButton: false, content: '流程图名字', iconSource: '../res/logo.png'};
                        gridModel.insert(gridModel.count-1, item);
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
        }
    }
}
