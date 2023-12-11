import QtQuick 2.15
import QtQuick.Controls 2.15

BuildBlockBase {
    property int initWidth: 105

    width: initWidth

    Row {
        id: upperRow
        parent: upperContent
        anchors.fill: parent
        spacing: 5
    }

    Component {
        id: upperChildComponent
        FileThumb {
            //
        }
    }

    function addUpperChild(type, coverImage, filePath) {
        var child = upperChildComponent.createObject(upperRow)
        child.height = upperRow.height
        child.width = child.height
        child.type = type
        child.coverImage = coverImage
        child.filePath = filePath
        upperRow.children.push(child)
    }

    function updateWidth() {
        if (upperRow.children.length <= 1) {
            width = initWidth
        } else {
            var thumbWidth = upperRow.height + upperRow.spacing
            width = initWidth + (upperRow.children.length-1)*thumbWidth
        }
    }
}
