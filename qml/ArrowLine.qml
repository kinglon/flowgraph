import QtQuick 2.15
import QtQuick.Controls 2.15

Canvas {
    id: canvas
    anchors.fill: parent

    property point beginPoint: Qt.point(0, 0)

    property point endPoint: Qt.point(100, 100)

    onPaint: {
        var ctx = canvas.getContext("2d");
        ctx.clearRect(0, 0, canvas.width, canvas.height)

        ctx.strokeStyle = canvas.enabled?"#1E2330":"#444A58";
        ctx.lineWidth = 2;

        var startPoint = canvas.beginPoint
        var endPoint = canvas.endPoint

        // Calculate arrowhead position and angle
        var arrowheadSize = 10;
        var angle = Math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x);
        var arrowheadPosition = Qt.point(startPoint.x + (endPoint.x - startPoint.x) / 2, startPoint.y + (endPoint.y - startPoint.y) / 2);

        // Draw the line
        ctx.beginPath();
        ctx.moveTo(startPoint.x, startPoint.y);
        ctx.lineTo(endPoint.x, endPoint.y);
        ctx.stroke();

        // Draw the arrowhead
        ctx.save();
        ctx.translate(arrowheadPosition.x, arrowheadPosition.y);
        ctx.rotate(angle);
        ctx.beginPath();
        ctx.moveTo(-arrowheadSize, -arrowheadSize);
        ctx.lineTo(0, 0);
        ctx.lineTo(-arrowheadSize, arrowheadSize);
        ctx.stroke();
        ctx.restore();
    }
}
