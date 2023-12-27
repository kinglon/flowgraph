import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: waitingWindow
    flags: Qt.Window|Qt.FramelessWindowHint
    visible: true
    modality: Qt.WindowModal
    width: 380
    height: 180
    title: "等待中"

    WindowBase {
        id: windowBase
        window: waitingWindow
        title: waitingWindow.title
        hasLogo: false
        hasMinButton: false
    }

    Item {
        id: windowContent
        parent: windowBase.contentArea
        anchors.fill: parent
        
        BusyIndicator {
            width: 100
            height: 100
            anchors.centerIn: parent
        }        
    }    
}
