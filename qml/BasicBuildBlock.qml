﻿import QtQuick 2.15
import QtQuick.Controls 2.15

BuildBlockBase {
    id: basicBuildBlock
    width: initWidth

    property int initWidth: 100
    property int rowSpacing: 5
    property int itemWidth: 50

    property bool showOkButton: true

    property alias lowerRow: lowerRow

    property alias submitButton: submitButton

    property alias okButton: okButton

    // 点击提交文件按钮
    signal submitFile(BuildBlockBase buildBlock)

    // 删除提交的文件
    signal deleteSubmitFile(BuildBlockBase buildBlock, string filePath)

    // 点击确定按钮
    signal okButtonClicked(BuildBlockBase buildBlock)

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
        onClicked: {
            basicBuildBlock.okButtonClicked(basicBuildBlock)
        }
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
            height: upperRow.height,
            editable: false
        }
        childComponent.createObject(upperRow, params)
        updateWidth()
    }

    function clearLowerFile() {
        lowerRow.children = []
        updateWidth()
    }

    function addLowerFile(icon, filePath) {
        var params = {
            icon: icon,
            filePath: filePath,
            width: basicBuildBlock.itemWidth,
            height: lowerRow.height,
            editable: true
        }
        var fileThumb = childComponent.createObject(lowerRow, params)
        fileThumb.deleteFile.connect(function(filePath) {
            basicBuildBlock.deleteSubmitFile(basicBuildBlock, filePath)
            fileThumb.visible = false
            fileThumb.destroy()
            updateWidth()
        })
        updateWidth()
    }

    function updateWidth() {
        // 删除提交文件的时候，不是及时删除，所以不能简单判断子item的数目
        var lowerRowChildrenCount = 0
        for (var i=0; i<lowerRow.children.length; i++) {
            if (lowerRow.children[i].visible) {
                lowerRowChildrenCount += 1
            }
        }

        var childCount = Math.max(upperRow.children.length, lowerRowChildrenCount+1)
        if (childCount <= 1) {
            width = initWidth
        } else {
            width = initWidth + (childCount-1)*(basicBuildBlock.itemWidth+rowSpacing)
        }

        upperRow.width = basicBuildBlock.itemWidth*upperRow.children.length
        if (upperRow.children.length > 1) {
            upperRow.width += (upperRow.children.length-1)*rowSpacing
        }

        lowerRow.width = basicBuildBlock.itemWidth*lowerRowChildrenCount
        if (lowerRowChildrenCount > 1) {
            lowerRow.width += lowerRowChildrenCount*rowSpacing
        }
    }
}
