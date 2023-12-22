import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: buildBlockBase
    width: 100
    height: 120
    color: "transparent"
    enabled: true

    property string uuid: ""

    property bool canUse: true

    property bool middleLineVisible: true

    property alias background: background

    property alias upperContent: upperContent

    property alias lowerContent: lowerContent

    property alias leftPin: leftPinCtrl

    property alias rightPin: rightPinCtrl

    property alias disableCoverPanel: disableCoverPanel

    signal deleteBuildBlock(string buildBlockId)

    signal editBuildBlock(string buildBlockId)

    signal pressPin(BuildBlockBase buildBlock)

    signal dragPin(BuildBlockBase buildBlock, real x, real y)

    signal releasePin(BuildBlockBase buildBlock)

    // 鼠标拖动
    MouseArea {
        anchors.fill: parent
        z: buildBlockBase.canUse?0:1
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        property point clickPos: Qt.point(1,1)

        Menu {
            id: contextMenu
            width: 60

            property int fontSize: 15
            MenuItem {
                text: "编辑"
                font.pointSize: contextMenu.fontSize
                onTriggered: {
                    buildBlockBase.editBuildBlock(uuid)
                }
            }
            MenuItem {
                text: "删除"
                font.pointSize: contextMenu.fontSize
                onTriggered: {
                    buildBlockBase.deleteBuildBlock(uuid)
                }
            }
        }

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }
        onReleased: {
            if (mouse.button == Qt.RightButton) {
                contextMenu.popup()
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
    }    

    Component {
        id: pinMouseAreaComponent
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onPressed: {
                buildBlockBase.pressPin(buildBlockBase)
            }
            onReleased: {
                buildBlockBase.releasePin(buildBlockBase)
            }
            onPositionChanged: {
                var pos = mapToItem(buildBlockBase, mouse.x, mouse.y)
                buildBlockBase.dragPin(buildBlockBase, pos.x, pos.y)
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

        Component.onCompleted: {
            pinMouseAreaComponent.createObject(leftPinCtrl)
        }
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

        Component.onCompleted: {
            pinMouseAreaComponent.createObject(rightPinCtrl)
        }
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


    // 禁用状态盖板
    Rectangle {
        id: disableCoverPanel
        visible: !buildBlockBase.canUse
        z: 1
        width: background.width
        height: background.height
        anchors.centerIn: parent
        color: "#80FFFFFF"
        radius: background.radius
    }
}
