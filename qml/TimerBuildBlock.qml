﻿import QtQuick 2.15
import QtQuick.Controls 2.15

BasicBuildBlock {
    id: basicBuildBlock
    property int timerCtrlWidth: 30
    property string hour: "00"
    property string minute: "12"
    property string second: "34"
    initWidth: 130

    background.width: background.parent.width - timerCtrlWidth
    background.anchors.centerIn: undefined
    background.anchors.verticalCenter: background.parent.verticalCenter
    background.anchors.left: background.parent.left
    background.anchors.leftMargin: 3
    disableCoverPanel.anchors.centerIn: undefined
    disableCoverPanel.anchors.verticalCenter: background.parent.verticalCenter
    disableCoverPanel.anchors.left: background.parent.left
    disableCoverPanel.anchors.leftMargin: 3

    Rectangle {
        id: timePanel
        parent: parent
        width: 30
        height: 90
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
            property int blackPointMargin: 8
            property int blackPointHeight: 4
            property int textHeight: (column.height-2*blackPointHeight)/3
            Text {
                id: hourCtrl
                text: hour
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 12
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
                font.pointSize: 12
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
                font.pointSize: 12
                height: column.textHeight
                width: parent.width
            }
        }

    }

    Rectangle {
        visible: disableCoverPanel.visible
        width: timePanel.width
        height: timePanel.height
        anchors.centerIn: timePanel
        radius: timePanel.radius
        border.width: timePanel.border.width
        border.color: disableCoverPanel.border.color
        color: disableCoverPanel.color
    }
}
