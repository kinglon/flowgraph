import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    width: 100
    height: 100
    //text: "OK"
    font.styleName: "Bold"
    font.family: "Arial"
    font.bold: true
    font.pointSize: 16
    palette.buttonText: "#FFFFFF"
    display: AbstractButton.TextBesideIcon
    hoverEnabled: true    

    property string bgNormalImage: "../res/default_button_bg_normal.png"
    property string bgClickImage: "../res/default_button_bg_click.png"
    property string bgHoverImage: "../res/default_button_bg_hover.png"
    property string bgDisableImage: "../res/default_button_bg_disable.png"

    property int borderWidth: 30

    function updateBackgroundImage() {
        if (!enabled) {
            borderImgBackground.source = bgDisableImage
        } else {
            if (down) {
                borderImgBackground.source = bgClickImage
            } else {
                if (hovered) {
                    borderImgBackground.source = bgHoverImage
                } else {
                    borderImgBackground.source = bgNormalImage
                }
            }
        }
    }

    background: BorderImage {
        id: borderImgBackground
        x: parent.leftInset
        y: parent.topInset
        width: parent.width-parent.leftInset-parent.rightInset
        height: parent.height-parent.topInset-parent.bottomInset
        border.left: borderWidth
        border.right: borderWidth
        border.top: borderWidth
        border.bottom: borderWidth
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        source: bgNormalImage
    }

    onDownChanged: { updateBackgroundImage(); }

    onEnabledChanged: { updateBackgroundImage(); }

    onHoveredChanged: { updateBackgroundImage(); }
}
