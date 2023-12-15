import QtQuick 2.15
import QtQuick.Controls 2.15

BuildBlockBase {
    property int initWidth: 105

    property int rowSpacing: 5

    property alias lowerRow: lowerRow

    width: initWidth

    Row {
        id: upperRow
        parent: upperContent
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        spacing: rowSpacing
    }

    Row {
        id: lowerRow
        parent: lowerContent
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        spacing: rowSpacing
    }

    Component {
        id: childComponent
        FileThumb {
            //
        }
    }

    function addUpperChild(type, coverImage, filePath) {
        var child = childComponent.createObject(upperRow)
        child.height = upperRow.height
        child.width = child.height
        child.type = type
        child.coverImage = coverImage
        child.filePath = filePath
        upperRow.children.push(child)
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
