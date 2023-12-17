import QtQuick 2.15
import QtQuick.Controls 2.15

BuildBlockBase {
    property int initWidth: 105
    property int rowSpacing: 5
    property alias lowerRow: lowerRow
    width: initWidth
    property bool showOkButton: true

    // 上半部分文件列表
    Row {
        id: upperRow
        parent: upperContent
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        spacing: rowSpacing
    }

    // 下半部分文件列表
    Row {
        id: lowerRow
        visible: !showOkButton
        parent: lowerContent
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        spacing: rowSpacing

        // 添加按钮
        BorderImgButton {
            height: lowerRow.height
            width: height
            bgClickImage: "../res/add_button_bg_click.png"
            bgNormalImage: "../res/add_button_bg_normal.png"
            bgHoverImage: "../res/add_button_bg_hover.png"
            bgDisableImage: "../res/add_button_bg_disable.png"
            padding: 20
            contentItem: Image {
                source: "../res/add.png"
            }
            onClicked: {
            }
        }
    }

    // 下半部分确定按钮
    ButtonBase {
        id: okButton
        visible: showOkButton
        parent: lowerContent
        anchors.centerIn: parent
        height: 40
        width: 70
        text: "确定"
    }

    Component {
        id: childComponent
        FileThumb {}
    }

    function addUpperFile(fileItemData) {
        var child = childComponent.createObject(upperRow)
        child.height = upperRow.height
        child.width = child.height
        child.type = fileItemData.type
        child.coverImage = fileItemData.coverImage
        child.filePath = fileItemData.filePath
        upperRow.children.push(child)
        updateWidth()
    }

    function addLowerFile(fileItemData) {
        var child = childComponent.createObject(lowerRow)
        child.height = lowerRow.height
        child.width = child.height
        child.type = fileItemData.type
        child.coverImage = fileItemData.coverImage
        child.filePath = fileItemData.filePath

        // 添加到添加按钮前面
        var newChildren = []
        for (var i=0; i< lowerRow.children.length-1; i++) {
            newChildren.push(lowerRow.children[i])
        }
        newChildren.push(child)
        newChildren.push(lowerRow.children[lowerRow.children.length-1])
        lowerRow.children = newChildren
        updateWidth()
    }

    function updateWidth() {
        // 每个子Item的宽度跟它的行高度一样
        var itemWidth = upperRow.height
        var childCount = Math.max(upperRow.children.length, lowerRow.children.length)
        if (childCount <= 1) {
            width = initWidth
        } else {
            width = initWidth + (childCount-1)*(itemWidth+rowSpacing)
        }

        upperRow.width = itemWidth*upperRow.children.length
        if (upperRow.children.length > 1) {
            upperRow.width += (upperRow.children.length-1)*rowSpacing
        }

        lowerRow.width = itemWidth*lowerRow.children.length
        if (lowerRow.children.length > 1) {
            lowerRow.width += (lowerRow.children.length-1)*rowSpacing
        }
    }
}
