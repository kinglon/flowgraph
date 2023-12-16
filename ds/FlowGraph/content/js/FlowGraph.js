.pragma library

var FileItem = {
    type: "",
    coverImage: "",
    filePath: ""
};

var SubmitConditionItem = {
    groupName: "",
    suffix: "",
    sizeMin: 1,
    sizeMax: 2,
    count: 1
};

var BuildBlockItem = {
    uuid: "",
    type: "basic",
    last: "",
    next: "",
    finish: false,
    text: "",
    studyFiles: [],
    submitFiles: [],
    finishCondition: [],
    finishConditionGroup: "",
    finishTimeLength: 7200,
    remainTimeLength: 7200
};

// BuildBlockItem array
var buildBlockData = []

// load flowgraph
function loadFlowGraph(flowGraphId) {
    // todo by yejinlong, loadFlowGraph
}

// save flowgraph
function saveFlowGraph(flowGraphId) {
    // todo by yejinlong, saveFlowGraph
}

// create build buildBlock
function createBuildBlock(type) {
    var buildBlock = new BuildBlockItem()
    buildBlock.uuid = Qt.createUuid()
    buildBlock.type = type
    return buildBlock
}


