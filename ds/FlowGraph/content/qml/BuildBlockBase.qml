import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: buildBlockBase
    width: 150
    height: 200
    color: "transparent"

    property string uuid: ""

    property bool middleLineVisible: true

    property alias background: background

    property alias upperContent: upperContent

    property alias lowerContent: lowerContent

    property alias leftPin: leftPinCtrl

    property alias rightPin: rightPinCtrl


    // 背景
    Rectangle {
        id: background
        width: parent.width-6
        height: parent.height-6
        anchors.centerIn: parent
        color: "#BEC8D7"
        border.color: "#2D3447"
        border.width: 2
        radius: 10
    }

    // 鼠标拖动
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        property point clickPos: Qt.point(1,1)
        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                buildBlockBase.x += delta.x;
                buildBlockBase.y += delta.y;
                if (buildBlockBase.x < 0) {
                    buildBlockBase.x = 0
                }
                if (buildBlockBase.y < 0) {
                    buildBlockBase.y = 0
                }
            }
        }
    }

    // 左边黑点
    Rectangle {
        id: leftPinCtrl
        anchors.verticalCenter: parent.verticalCenter
        width: 7
        height: 7
        radius: width / 2
        color: "#2D3447"
        property point pos: Qt.point(x+width/2, y+height/2)
    }

    // 右边黑点
    Rectangle {
        id: rightPinCtrl
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 7
        height: 7
        radius: width / 2
        color: "#2D3447"
        property point pos: Qt.point(x+width/2, y+height/2)
    }

    // 中线
    Rectangle {
        id: middleLine
        visible: middleLineVisible
        width: parent.width
        height: 2
        color: "#2D3447"
        anchors.verticalCenter: parent.verticalCenter
    }

    // 上半部分
    Item {
        id: upperContent
        width: background.width - background.radius*2
        height: (background.height - background.radius*4)/2
        anchors.top: background.top
        anchors.topMargin: background.radius
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // 下半部分
    Item {
        id: lowerContent
        width: background.width - background.radius*2
        height: (background.height - background.radius*4)/2
        anchors.bottom: background.bottom
        anchors.bottomMargin: background.radius
        anchors.horizontalCenter: parent.horizontalCenter
    }


    // 禁用状态盖板
    Rectangle {
        visible: !parent.enabled
        z: 1
        width: background.width
        height: background.height
        anchors.centerIn: parent
        color: "#80FFFFFF"
        radius: background.radius
    }
}
