import QtQuick 2.15
import QtQuick.Controls 2.15

BuildBlockBase {    
    middleLineVisible: false

    property alias textCtrl: textCtrl

    Text {
        id: textCtrl
        parent: background
        width: parent.width-parent.radius*2
        height: parent.height-parent.radius*2
        anchors.centerIn: parent
        text: "备注模块"
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 15
    }    
}
