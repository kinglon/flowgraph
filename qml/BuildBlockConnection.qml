import QtQuick 2.15
import QtQuick.Controls 2.15

ArrowLine {
    id: buildBlockConnection

    property BuildBlockBase beginBuildBlock

    property BuildBlockBase endBuildBlock

    function updateBeginPoint() {
        if (beginBuildBlock == null) {
            return
        }

        beginPoint = beginBuildBlock.mapToItem(beginBuildBlock.parent, beginBuildBlock.rightPin.pos.x, beginBuildBlock.rightPin.pos.y)
    }

    function updateEndPoint() {
        if (endBuildBlock == null) {
            return
        }

        endPoint = endBuildBlock.mapToItem(endBuildBlock.parent, endBuildBlock.leftPin.pos.x, endBuildBlock.leftPin.pos.y)
    }

    Component.onCompleted: {
        buildBlockConnection.updateBeginPoint()
        buildBlockConnection.updateEndPoint()
    }

    Connections {
        target: beginBuildBlock
        onXChanged: {
            buildBlockConnection.updateBeginPoint()
            buildBlockConnection.requestPaint()
        }
    }

    Connections {
        target: beginBuildBlock
        onYChanged: {
            buildBlockConnection.updateBeginPoint()
            buildBlockConnection.requestPaint()
        }
    }

    Connections {
        target: beginBuildBlock
        onWidthChanged: {
            buildBlockConnection.updateBeginPoint()
            buildBlockConnection.requestPaint()
        }
    }

    Connections {
        target: beginBuildBlock
        onHeightChanged: {
            buildBlockConnection.updateBeginPoint()
            buildBlockConnection.requestPaint()
        }
    }

    Connections {
        target: endBuildBlock
        onXChanged: {
            buildBlockConnection.updateEndPoint()
            buildBlockConnection.requestPaint()
        }
    }

    Connections {
        target: endBuildBlock
        onYChanged: {
            buildBlockConnection.updateEndPoint()
            buildBlockConnection.requestPaint()
        }
    }

    Connections {
        target: endBuildBlock
        onWidthChanged: {
            buildBlockConnection.updateEndPoint()
            buildBlockConnection.requestPaint()
        }
    }

    Connections {
        target: endBuildBlock
        onHeightChanged: {
            buildBlockConnection.updateEndPoint()
            buildBlockConnection.requestPaint()
        }
    }
}
