import QtQuick 2.15
import QtQuick.Controls 2.15

BuildBlockBase {
    id: basicBuildBlock
    property int initWidth: 100
    property int rowSpacing: 5
    property alias lowerRow: lowerRow
    width: initWidth
    property bool showOkButton: true
    property int itemWidth: 50

    signal submitFile(BuildBlockBase buildBlock)

    // 上半部分文件列表
    Row {
        id: upperRow
        parent: upperContent
        width: 0
        height: parent.height        
        anchors.centerIn: parent
        spacing: rowSpacing
    }

    // 下半部分文件列表和添加按钮
    Item {
        visible: !showOkButton
        parent: lowerContent
        width: lowerRow.width+submitButton.width
        height: parent.height
        anchors.centerIn: parent

        Row {
            id: lowerRow
            width: 0
            height: parent.height
            anchors.left: parent.left
            spacing: rowSpacing
        }

        // 下半部分添加按钮
        BorderImgButton {
            id: submitButton
            width: basicBuildBlock.itemWidth
            height: 30
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            bgClickImage: "../res/submit_button_bg.png"
            bgNormalImage: "../res/submit_button_bg.png"
            bgHoverImage: "../res/submit_button_bg.png"
            bgDisableImage: "../res/submit_button_bg.png"
            borderWidth: 10
            padding: 15
            contentItem: Image {
                source: "../res/add2.png"
                fillMode: Image.Pad
            }
            onClicked: {
                basicBuildBlock.submitFile(basicBuildBlock)
            }
        }
    }

    // 下半部分确定按钮
    ButtonBase {
        id: okButton
        visible: showOkButton
        parent: lowerContent
        anchors.centerIn: parent
        height: 30
        width: 60
        text: "确定"
        font.pointSize: 12
    }

    Component {
        id: childComponent
        FileThumb {}
    }

    function clearUpperFile() {
        upperRow.children = []
        updateWidth()
    }

    function addUpperFile(icon, filePath) {
        var params = {
            icon: icon,
            filePath: filePath,
            width: basicBuildBlock.itemWidth,
            height: upperRow.height
        }
        childComponent.createObject(upperRow, params)
        updateWidth()
    }

    function clearLowerFile() {
        lowerRow.children = [lowerRow.children[lowerRow.children.length-1]]
        updateWidth()
    }

    function addLowerFile(icon, filePath) {
        var params = {
            icon: icon,
            filePath: filePath,
            width: basicBuildBlock.itemWidth,
            height: lowerRow.height
        }
        childComponent.createObject(lowerRow, params)
        updateWidth()
    }

    function updateWidth() {
        var childCount = Math.max(upperRow.children.length, lowerRow.children.length+1)
        if (childCount <= 1) {
            width = initWidth
        } else {
            width = initWidth + (childCount-1)*(basicBuildBlock.itemWidth+rowSpacing)
        }

        upperRow.width = basicBuildBlock.itemWidth*upperRow.children.length
        if (upperRow.children.length > 1) {
            upperRow.width += (upperRow.children.length-1)*rowSpacing
        }

        lowerRow.width = basicBuildBlock.itemWidth*lowerRow.children.length
        if (lowerRow.children.length > 1) {
            lowerRow.width += lowerRow.children.length*rowSpacing
        }
    }
}
