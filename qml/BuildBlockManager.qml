import QtQml 2.15
import QtQuick 2.15
import Flow 1.0

QtObject {
    // 每个模块的数据信息
    property var buildBlocks: []

    // 每个模块对应的控件
    property var buildBlockCtrls: ({})

    // 连接线列表
    property var buildBlockConnections: []

    property var fileItemDataComponent

    property var textBuildBlockComponent

    property var basicBuildBlockComponent

    property var timerBuildBlockComponent

    property var buildBlockConnectionComponent

    function init() {
        fileItemDataComponent = Qt.createComponent("FileItemData.qml")
        textBuildBlockComponent = Qt.createComponent("TextBuildBlock.qml")
        basicBuildBlockComponent = Qt.createComponent("BasicBuildBlock.qml")
        timerBuildBlockComponent = Qt.createComponent("TimerBuildBlock.qml")
        buildBlockConnectionComponent = Qt.createComponent("BuildBlockConnection.qml")
    }

    // load flowgraph
    function loadFlowGraph(flowGraphId) {
        var buildBlockJsonString = FlowManager.getBuildBlocks(flowGraphId)
        var jsonArray = JSON.parse(buildBlockJsonString)
        if (jsonArray != null) {
            buildBlocks = jsonArray
        }
        else {
            console.log("failed to parse buildblock info: "+buildBlockJsonString)
        }

        return buildBlocks
    }

    // save flowgraph
    function saveFlowGraph(flowGraphId) {
        var jsonString = JSON.stringify(buildBlocks)
        FlowManager.setBuildBlocks(flowGraphId, jsonString)
    }

    function createFileItemData(fileItemJsonObject) {
        fileItemData = fileItemDataComponent.createObject()
        fileItemData.type = fileItemJsonObject.type
        fileItemData.coverImage = fileItemJsonObject.coverImage
        fileItemData.filePath = fileItemJsonObject.filePath
        return fileItemData
    }

    function getBuildBlockData(uuid) {
        buildBlocks.forEach(function(item) {
            if (uuid === item.uuid) {
                return item
            }
        })

        return null
    }

    // 如果lastUuid为空，所有上个模块都完成才认为完成
    function isLastBuildBlockFinish(buildBlockData, lastUuid) {
        if (lastUuid !== "") {
            var lastBuildBlockData = getBuildBlockData(lastUuid)
            if (lastBuildBlockData === null) {
                return true
            } else {
                return lastBuildBlockData.finish
            }
        } else {
            buildBlockData.last.forEach(function(item){
                var lastBuildBlockData = getBuildBlockData(item)
                if (lastBuildBlockData !== null && !lastBuildBlockData.finish) {
                    return false
                }
            })
            return true
        }
    }

    function createBuildBlock(buildBlockData, parent) {
        var buildBlock
        var params = {"uuid": buildBlockData.uuid}
        if (buildBlockData.type === "text") {
            buildBlock = textBuildBlockComponent.createObject(parent, params)
            buildBlock.text = buildBlockData.text
        } else {
            if (buildBlockData.type === "timer") {
                buildBlock = timerBuildBlockComponent.createObject(parent, params)
            } else {
                buildBlock = basicBuildBlockComponent.createObject(parent, params)
            }

            buildBlockData.studyFiles.forEach(function(item) {
                fileItemData = createFileItemData(item)
                buildBlock.addUpperFile(fileItemData)
            })
            buildBlockData.submitFiles.forEach(function(item) {
                fileItemData = createFileItemData(item)
                buildBlock.addLowerFile(fileItemData)
            })
            var needSubmitFile = buildBlockData.finishCondition.length > 0
            buildBlock.showOkButton = !needSubmitFile

            if (buildBlockData.type === "timer") {
                buildBlock.hour = getHourPartString(buildBlockData.remainTimeLength)
                buildBlock.minute = getMinutePartString(buildBlockData.remainTimeLength)
                buildBlock.second = getSecondPartString(buildBlockData.remainTimeLength)
            }

            buildBlock.updateWidth()
        }

        buildBlock.x = buildBlockData.x
        buildBlock.y = buildBlockData.y
        buildBlock.enabled = isLastBuildBlockFinish(buildBlockData, "")
        buildBlockCtrls[buildBlockData.uuid] = buildBlock
        return buildBlock
    }

    function createBuildBlockConnection(buildBlockData, parent) {
        if (buildBlockData.last.length === 0) {
            return null
        }

        var endBuildBlock
        if (buildBlockCtrls.has(buildBlockData.uuid)) {
            endBuildBlock = buildBlockCtrls[buildBlockData.uuid]
        }


        for (var i=0; i<buildBlockData.last.length; i++) {
            var beginBuildBlock
            if (!buildBlockCtrls.has(buildBlockData.last[i])) {
                continue
            }

            beginBuildBlock = buildBlockCtrls[buildBlockData.last[i]]
            connection = buildBlockConnectionComponent.createObject(parent)
            connection.beginBuildBlock = beginBuildBlock
            connection.endBuildBlock = endBuildBlock
            connection.enabled = isLastBuildBlockFinish(buildBlockData, buildBlockData.last[i])
            buildBlockConnections.push(connection)
        }
    }

    function createBuildBlockData() {
        var jsonString = '{
                            "uuid": "",
                            "x": 0,
                            "y": 0,
                            "type": "",
                            "last": [],
                            "next": "",
                            "finish": false,
                            "text": "",
                            "studyFiles": [],
                            "submitFiles": [],
                            "finishCondition": [],
                            "finishConditionGroup":"",
                            "finishTimeLength": 3600,
                            "remainTimeLength": 3600
                        }'
        var buildBlockData = JSON.parse(jsonString)
        buildBlockData.uuid = FlowManager.getUuid()
        return buildBlockData
    }

    function addBuildBlockData(buildBlockData) {
        buildBlocks.push(buildBlockData)
    }

    // get hour string, like: 02
    function getHourPartString(totalSeconds) {
        var hours = Math.floor(totalSeconds/3600)
        hours = (hours < 10 ? "0" : "") + hours
        return hours
    }

    // get minute string, like: 02
    function getMinutePartString(totalSeconds) {
        var hours = Math.floor(totalSeconds/3600)
        var minutes = Math.floor((totalSeconds - hours*3600)/60)
        minutes = (minutes < 10 ? "0" : "") + minutes
        return minutes
    }

    // get seconds string, like: 02
    function getSecondPartString(totalSeconds) {
        var seconds = totalSeconds % 60
        seconds = (seconds < 10 ? "0" : "") + seconds
        return seconds
    }
}
