import QtQml 2.15
import QtQuick 2.15

QtObject {
    property var buildBlocks: []

    property var buildBlockDataComponent: null

    // load flowgraph
    function loadFlowGraph(flowGraphId) {
        // todo by yejinlong, loadFlowGraph
    }

    // save flowgraph
    function saveFlowGraph(flowGraphId) {
        // todo by yejinlong, saveFlowGraph
    }

    // create build buildBlock
    function createBuildBlock(uuid, type) {
        if (buildBlockDataComponent === null) {
            buildBlockDataComponent = Qt.createComponent("BuildBlockData.qml")
        }
        var buildBlock = buildBlockDataComponent.createObject()
        buildBlock.uuid = uuid
        buildBlock.type = type
        return buildBlock
    }
}
