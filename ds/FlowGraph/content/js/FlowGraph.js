.pragma library

var FileItem = {
    type: "",
    coverImage: "",
    filePath: ""
};

var SubmitConditionItem = {
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
    finishCondition: {
        selIndex: 0,
        groups:[]
    },
    finishTimeLength: 3600,
    remainTimeLength: 3600
};

// BuildBlockItem array
var buildBlockData = []

// load flowgraph
function loadFlowGraph(flowGraphId) {
    // todo by yejinlong, loadFlowGraph
}

// save flowgraph
function saveFlowGraph(flowGraphId) {
    //
}


