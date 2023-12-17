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

    // 是否有LOGO
    property bool hasLogo: true

    // ContentArea
    property alias contentArea: contentArea
    
    property color bgColor: "#B4BECD"

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
                anchors.right: closeBtn.left
                anchors.rightMargin: 6
                icon.source: "../res/minimize_button.png"

                onClicked: {
                    if (window != null) {
                        window.visibility = Window.Minimized
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
}
