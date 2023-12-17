import QtQuick 2.15
import QtQuick.Controls 2.15

BuildBlockBase {
    id: buildBlockBase
    middleLineVisible: false    
    property string text: "标题文本"
    property alias textCtrl: textCtrl

    Text {
        id: textCtrl
        parent: background
        width: parent.width-parent.radius*2
        height: parent.height-parent.radius*2
        anchors.centerIn: parent
        text: buildBlockBase.text
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 15
    }    
}
