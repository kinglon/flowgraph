import QtQuick 2.15
import QtQuick.Controls 2.15

BasicBuildBlock {
    // 添加按钮
    BorderImgButton {
        parent: lowerRow
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

    Component {
        id: childComponent
        FileThumb {
            //
        }
    }

    function addLowerChild(type, coverImage, filePath) {
        var child = childComponent.createObject(lowerRow)
        child.height = lowerRow.height
        child.width = child.height
        child.type = type
        child.coverImage = coverImage
        child.filePath = filePath

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
}
