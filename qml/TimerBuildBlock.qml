import QtQuick 2.15
import QtQuick.Controls 2.15

BasicBuildBlock {
    id: basicBuildBlock
    property int timerCtrlWidth: 30
    property string hour: "00"
    property string minute: "12"
    property string second: "34"
    initWidth: 130

    background.width: background.parent.width - timerCtrlWidth + 5
    background.anchors.centerIn: undefined
    background.anchors.verticalCenter: background.parent.verticalCenter
    background.anchors.left: background.parent.left
    background.anchors.leftMargin: 3

    Rectangle {
        parent: parent
        width: 30
        height: 100
        color: basicBuildBlock.background.color
        border.color: basicBuildBlock.background.border.color
        border.width: basicBuildBlock.background.border.width
        radius: 5
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 5

        Column {
            id: column
            anchors.fill: parent
            spacing: 3
            property int blackPointMargin: 8
            property int blackPointHeight: 4
            property int textHeight: 27
            Text {
                id: hourCtrl
                text: hour
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 15
                height: column.textHeight
                width: parent.width
            }

            Item {
                width: parent.width
                height: column.blackPointHeight
                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: column.blackPointMargin
                    width: 4
                    height: 4
                    radius: 2
                    color: basicBuildBlock.background.border.color
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: column.blackPointMargin
                    width: 4
                    height: 4
                    radius: 2
                    color: basicBuildBlock.background.border.color
                }
            }

            Text {
                text: minute
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 15
                height: column.textHeight
                width: parent.width
            }

            Item {
                width: parent.width
                height: column.blackPointHeight
                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: column.blackPointMargin
                    width: parent.height
                    height: parent.height
                    radius: parent.height/2
                    color: basicBuildBlock.background.border.color
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: column.blackPointMargin
                    width: parent.height
                    height: parent.height
                    radius: parent.height/2
                    color: basicBuildBlock.background.border.color
                }
            }

            Text {
                text: second
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 15
                height: column.textHeight
                width: parent.width
            }
        }

    }
}
