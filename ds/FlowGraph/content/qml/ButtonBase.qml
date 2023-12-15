import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    width: 100
    height: 100
    //text: "确定"
    font.styleName: "Bold"
    font.family: "Arial"
    font.bold: true
    font.pointSize: 16
    palette.buttonText: "#FFFFFF"
    display: AbstractButton.TextBesideIcon
    hoverEnabled: true

    property color bgNormalColor: "#2D3447"
    property color bgClickColor: "#1E2330"
    property color bgHoverColor: "#3C465F"
    property color bgDisableColor: "#B4BECD"

    property color borderColor: "#ffffff"
    property int borderWidth: 0
    property int borderRadius: 10

    function updateBackgroundColor() {
        if (!enabled) {
            solidBackground.color = bgDisableColor
        } else {
            if (down) {
                solidBackground.color = bgClickColor
            } else {
                if (hovered) {
                    solidBackground.color = bgHoverColor
                } else {
                    solidBackground.color = bgNormalColor
                }
            }
        }
    }

    background: Rectangle {
        id: solidBackground
        x: parent.leftInset
        y: parent.topInset
        width: parent.width-parent.leftInset-parent.rightInset
        height: parent.height-parent.topInset-parent.bottomInset
        color: bgNormalColor
        radius: borderRadius
        border.width: borderWidth
        border.color: borderColor
    }

    onDownChanged: { updateBackgroundColor(); }

    onEnabledChanged: { updateBackgroundColor(); }

    onHoveredChanged: { updateBackgroundColor(); }
}
