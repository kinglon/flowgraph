import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    width: 150
    height: 200
    color: "transparent"

    property string uuid: ""

    property bool middleLineVisible: true

    property alias background: background

    property alias upperContent: upperContent

    property alias lowerContent: lowerContent

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

    // 左边黑点
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 7
        height: 7
        radius: width / 2
        color: "#2D3447"
    }

    // 右边黑点
    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 7
        height: 7
        radius: width / 2
        color: "#2D3447"
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
