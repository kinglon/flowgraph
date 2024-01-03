import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15


Rectangle {
    id: windowArea
    anchors.fill: parent
    border.width: 4
    border.color: "#2D3447"

    property Item content: null

    property Window window: null

    property string title: "title"

    // 是否有最小化按钮
    property bool hasMinButton: true

    // 是否有最大化按钮
    property bool hasMaxButton: false

    // 是否有LOGO
    property bool hasLogo: true

    // ContentArea
    property alias contentArea: contentArea
    
    property color bgColor: "#B4BECD"

    // 标志是否可以拖动边框改变窗口大小
    property bool resizable: false

    // 窗口最小宽度，拉动时不低于该值
    property int minWidth: 350

    Component.onCompleted: {
        // 居中显示窗口在屏幕上
        if (windowArea.window != null) {
            windowArea.window.x = (Screen.desktopAvailableWidth-windowArea.window.width)/2
            if (windowArea.window.x < 0) {
                windowArea.window.x = 0
            }
            windowArea.window.y = (Screen.desktopAvailableHeight-windowArea.window.height)/2
            if (windowArea.window.y < 0) {
                windowArea.window.y = 0
            }
        }
    }

    Column {
        width: parent.width-2*windowArea.border.width
        height: parent.height-windowArea.border.width
        x: windowArea.border.width
        y: 0

        // title bar
        Rectangle {
            id: titleBar
            width: parent.width
            height: 44
            color: windowArea.border.color

            MouseArea {
                anchors.fill: parent

                property point clickPos: Qt.point(1,1)

                onPressed: {
                    clickPos  = Qt.point(mouse.x,mouse.y);
                }

                onPositionChanged: {
                    if (window != null) {
                        var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                        window.x += delta.x;
                        window.y += delta.y;
                    }
                }
            }

            // Logo
            Image {
                id: logo
                visible: hasLogo
                width: 26
                height: width
                x: 6
                y: (parent.height - height)/2
                fillMode: Image.PreserveAspectFit
                source: "../res/logo.png"
            }

            // Title text
            Text {
                id: titleText                
                width: 300
                height: parent.height
                anchors.left: hasLogo? logo.right : parent.left
                leftPadding: 6
                text: title
                color: "white"
                font.pixelSize: 22
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: 6
            }

            ButtonBase {
                id: minBtn
                visible: hasMinButton
                width: height
                height: parent.height
                topInset: 4
                bottomInset: 4
                leftInset: 4
                rightInset: 4
                anchors.right: hasMaxButton?maxBtn.left:closeBtn.left
                anchors.rightMargin: 6
                icon.source: "../res/minimize_button.png"

                onClicked: {
                    if (window != null) {
                        window.visibility = Window.Minimized
                    }
                }
            }

            ButtonBase {
                id: maxBtn
                visible: hasMaxButton
                width: height
                height: parent.height
                topInset: 4
                bottomInset: 4
                leftInset: 4
                rightInset: 4
                anchors.right: closeBtn.left
                anchors.rightMargin: 6
                icon.source: window.visibility===Window.Maximized?"../res/restore_button.png":"../res/max_button.png"
                icon.width: 16
                icon.height: 16

                onClicked: {
                    if (window.visibility===Window.Maximized) {
                        window.showNormal()
                    } else {
                        window.visibility = Window.Maximized
                    }
                }
            }

            ButtonBase {
                id: closeBtn
                width: height
                height: parent.height
                topInset: 4
                bottomInset: 4
                leftInset: 4
                rightInset: 4
                anchors.right: parent.right
                anchors.rightMargin: 6
                icon.source: "../res/close_button.png"
                onClicked: {
                    if (window != null) {
                        window.close();
                    }
                }
            }            
        }

        // Main content area
        Rectangle {
            id: contentArea
            width: parent.width
            height: parent.height - titleBar.height
            color: windowArea.bgColor
        }
    }

    // 上边框可拖动改变大小
    MouseArea {
        width: parent.width
        height: border.width
        anchors.top: parent.top
        visible: resizable && window.visibility!==Window.Maximized
        z: 2
        cursorShape: Qt.SizeVerCursor
        acceptedButtons: Qt.LeftButton
        property point clickPos: Qt.point(1,1)

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                if (window != null) {
                    var newHeight = window.height - delta.y
                    if (newHeight > titleBar.height) {
                        window.height = newHeight
                        window.y += delta.y
                    }
                }
            }
        }
    }

    // 下边框可拖动改变大小
    MouseArea {
        width: parent.width
        height: border.width
        anchors.bottom: parent.bottom
        visible: resizable && window.visibility!==Window.Maximized
        z: 2
        cursorShape: Qt.SizeVerCursor
        acceptedButtons: Qt.LeftButton
        property point clickPos: Qt.point(1,1)

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                if (window != null) {
                    var newHeight = window.height + delta.y
                    if (newHeight > titleBar.height) {
                        window.height = newHeight
                    }
                }
            }
        }
    }

    // 左边框可拖动改变大小
    MouseArea {
        width: border.width
        height: parent.height
        anchors.left: parent.left
        visible: resizable && window.visibility!==Window.Maximized
        z: 2
        cursorShape: Qt.SizeHorCursor
        acceptedButtons: Qt.LeftButton
        property point clickPos: Qt.point(1,1)

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                if (window != null) {
                    var newWidth = window.width - delta.x
                    if (newWidth > windowArea.minWidth) {
                        window.width = newWidth
                        window.x += delta.x
                    }
                }
            }
        }
    }

    // 右边框可拖动改变大小
    MouseArea {
        width: border.width
        height: parent.height
        anchors.right: parent.right
        visible: resizable && window.visibility!==Window.Maximized
        z: 2
        cursorShape: Qt.SizeHorCursor
        acceptedButtons: Qt.LeftButton
        property point clickPos: Qt.point(1,1)

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                if (window != null) {
                    var newWidth = window.width + delta.x
                    if (newWidth > windowArea.minWidth) {
                        window.width = newWidth
                    }
                }
            }
        }
    }

    // 左上角可拖动改变大小
    MouseArea {
        width: border.width
        height: border.width
        anchors.top: parent.top
        anchors.left: parent.left
        visible: resizable && window.visibility!==Window.Maximized
        z: 2
        cursorShape: Qt.SizeFDiagCursor
        acceptedButtons: Qt.LeftButton
        property point clickPos: Qt.point(1,1)

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                if (window != null) {
                    var newWidth = window.width - delta.x
                    var newHeight = window.height - delta.y
                    if (newWidth > windowArea.minWidth) {
                        window.width = newWidth
                        window.x += delta.x
                    }
                    if (newHeight > titleBar.height) {
                        window.height = newHeight
                        window.y += delta.y
                    }
                }
            }
        }
    }

    // 右下角可拖动改变大小
    MouseArea {
        width: border.width
        height: border.width
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        visible: resizable && window.visibility!==Window.Maximized
        z: 2
        cursorShape: Qt.SizeFDiagCursor
        acceptedButtons: Qt.LeftButton
        property point clickPos: Qt.point(1,1)

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                if (window != null) {
                    var newWidth = window.width + delta.x
                    var newHeight = window.height + delta.y
                    if (newWidth > windowArea.minWidth) {
                        window.width = newWidth
                    }
                    if (newHeight > titleBar.height) {
                        window.height = newHeight
                    }
                }
            }
        }
    }

    // 左下角可拖动改变大小
    MouseArea {
        width: border.width
        height: border.width
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        visible: resizable && window.visibility!==Window.Maximized
        z: 2
        cursorShape: Qt.SizeBDiagCursor
        acceptedButtons: Qt.LeftButton
        property point clickPos: Qt.point(1,1)

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                if (window != null) {
                    var newWidth = window.width - delta.x
                    var newHeight = window.height + delta.y
                    if (newWidth > windowArea.minWidth) {
                        window.width = newWidth
                        window.x += delta.x
                    }
                    if (newHeight > titleBar.height) {
                        window.height = newHeight
                    }
                }
            }
        }
    }

    // 右上角可拖动改变大小
    MouseArea {
        width: border.width
        height: border.width
        anchors.top: parent.top
        anchors.right: parent.right
        visible: resizable && window.visibility!==Window.Maximized
        z: 2
        cursorShape: Qt.SizeBDiagCursor
        acceptedButtons: Qt.LeftButton
        property point clickPos: Qt.point(1,1)

        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
        }

        onPositionChanged: {
            if (mouse.buttons == Qt.LeftButton) {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                if (window != null) {
                    var newWidth = window.width + delta.x
                    var newHeight = window.height - delta.y
                    if (newWidth > windowArea.minWidth) {
                        window.width = newWidth
                    }
                    if (newHeight > titleBar.height) {
                        window.height = newHeight
                        window.y += delta.y
                    }
                }
            }
        }
    }
}
