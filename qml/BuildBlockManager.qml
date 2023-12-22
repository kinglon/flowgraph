import QtQml 2.15
import QtQuick 2.15
import Flow 1.0

QtObject {
    property string flowId

    // 每个模块的数据信息
    property var buildBlocks: []

    // 每个模块对应的控件
    property var buildBlockCtrls: ({})

    // 连接线列表
    property var buildBlockConnections: []

    // 定时保存配置，单位毫秒
    property int autoSaveInterval: 5000

    // 上一次保存配置的时间戳，单位毫秒
    property int lastSaveTime: 0

    property var textBuildBlockComponent

    property var basicBuildBlockComponent

    property var timerBuildBlockComponent

    property var buildBlockConnectionComponent

    property Utility utility: Utility {}

    function init() {
        textBuildBlockComponent = Qt.createComponent("TextBuildBlock.qml")
        basicBuildBlockComponent = Qt.createComponent("BasicBuildBlock.qml")
        timerBuildBlockComponent = Qt.createComponent("TimerBuildBlock.qml")
        buildBlockConnectionComponent = Qt.createComponent("BuildBlockConnection.qml")
        timer.start()
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
    function saveFlowGraph() {
        // 自动保存模块的位置
        Object.entries(buildBlockCtrls).forEach(function([uuid, buildBlockCtrl]) {
            var buildBlockData = getBuildBlockData(uuid)
            if (buildBlockData !== null) {
                buildBlockData.x = buildBlockCtrl.x
                buildBlockData.y = buildBlockCtrl.y
            }
        })

        var jsonString = JSON.stringify(buildBlocks)
        FlowManager.setBuildBlocks(flowId, jsonString)
    }

    function getBuildBlockData(uuid) {
        for (var i=0; i<buildBlocks.length; i++) {
            if (uuid === buildBlocks[i].uuid) {
                return buildBlocks[i]
            }
        }

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

    function getDefaultFileIcon(filePath) {
        var icon = ""
        var extension = utility.getFileExtension(filePath)
        if (utility.isImageFile(extension)) {
            icon = "../res/type_image.png"
        } else if (utility.isVideoFile(extension)) {
            icon = "../res/type_video.png"
        }
        return icon
    }

    function getFileIcon(filePath) {
        var icon = FlowManager.getFileIcon(flowId, filePath)
        return icon
    }

    function copyFile(filePath) {
        var newFilePath = FlowManager.copyFile(flowId, filePath)
        return newFilePath
    }

    function createBuildBlock(buildBlockData, parent) {
        var buildBlock = null
        var params = {uuid: buildBlockData.uuid}
        if (buildBlockData.type === "text") {
            buildBlock = textBuildBlockComponent.createObject(parent, params)
            buildBlock.text = buildBlockData.text
        } else {
            if (buildBlockData.type === "timer") {
                buildBlock = timerBuildBlockComponent.createObject(parent, params)
            } else {
                buildBlock = basicBuildBlockComponent.createObject(parent, params)
            }

            buildBlockData.studyFiles.forEach(function(filePath) {
                var icon = getDefaultFileIcon(filePath)
                var absolutePath = toAbsolutePath(filePath)
                buildBlock.addUpperFile(icon, absolutePath)
            })
            buildBlockData.submitFiles.forEach(function(item) {
                var icon = toAbsolutePath(item.icon)
                var absolutePath = toAbsolutePath(item.filePath)
                buildBlock.addLowerFile(icon, absolutePath)
            })
            var needSubmitFile = buildBlockData.finishCondition.length > 0
            buildBlock.showOkButton = !needSubmitFile

            if (buildBlockData.type === "timer") {
                var remainTimeLength = getRemainTimeLength(buildBlockData)
                buildBlock.hour = getHourPartString(remainTimeLength)
                buildBlock.minute = getMinutePartString(remainTimeLength)
                buildBlock.second = getSecondPartString(remainTimeLength)
            }

            buildBlock.updateWidth()
        }

        buildBlock.x = buildBlockData.x
        buildBlock.y = buildBlockData.y        
        buildBlock.enabled = isLastBuildBlockFinish(buildBlockData, "")
        buildBlockCtrls[buildBlockData.uuid] = buildBlock
        return buildBlock
    }

    function updateBuildBlock(buildBlockData) {
        if (!buildBlockCtrls.hasOwnProperty(buildBlockData.uuid)) {
            return
        }

        var buildBlock = buildBlockCtrls[buildBlockData.uuid]
        if (buildBlockData.type === "text") {
            buildBlock.text = buildBlockData.text
        } else {
            buildBlock.clearUpperFile()
            buildBlockData.studyFiles.forEach(function(filePath) {
                var icon = getDefaultFileIcon(filePath)
                var absolutePath = toAbsolutePath(filePath)
                buildBlock.addUpperFile(icon, absolutePath)
            })

            buildBlock.clearLowerFile()
            buildBlockData.submitFiles.forEach(function(item) {
                var icon = toAbsolutePath(item.icon)
                var absolutePath = toAbsolutePath(item.filePath)
                buildBlock.addLowerFile(icon, absolutePath)
            })

            var needSubmitFile = buildBlockData.finishCondition.length > 0
            buildBlock.showOkButton = !needSubmitFile

            if (buildBlockData.type === "timer") {
                var remainTimeLength = getRemainTimeLength(buildBlockData)
                buildBlock.hour = getHourPartString(remainTimeLength)
                buildBlock.minute = getMinutePartString(remainTimeLength)
                buildBlock.second = getSecondPartString(remainTimeLength)
            }

            buildBlock.updateWidth()
        }
    }

    function updateBuildBlockCtrls() {
        // 更新模块控件的状态
        Object.entries(buildBlockCtrls).forEach(function([uuid, buildBlockCtrl]) {
            var buildBlockData = getBuildBlockData(uuid)
            if (buildBlockData === null) {
                return
            }

            buildBlockCtrl.enabled = isLastBuildBlockFinish(buildBlockData, "")
            if (buildBlockCtrl.enabled && buildBlockCtrl.type === "timer") {
                var remainTimeLength = getRemainTimeLength(buildBlockData)
                buildBlockCtrl.hour = getHourPartString(remainTimeLength)
                buildBlockCtrl.minute = getMinutePartString(remainTimeLength)
                buildBlockCtrl.second = getSecondPartString(remainTimeLength)
            }
        })

        // 更新连接线的禁用/启用状态
        buildBlockConnections.forEach(function(connection){
            var beginBuildBlockData = getBuildBlockData(connection.beginBuildBlock.uuid)
            if (beginBuildBlockData !== null) {
                connection.enabled = beginBuildBlockData.finish
            }
        })
    }

    function deleteBuildBlock(buildBlockId) {
        // 删除模块控件
        if (buildBlockCtrls.hasOwnProperty(buildBlockId)) {
            buildBlockCtrls[buildBlockId].destroy()
            delete buildBlockCtrls[buildBlockId]
        }

        // 删除该模块控件的连接线
        var toDeleteItems = buildBlockConnections.filter(function(item){
            if (item.beginBuildBlock.uuid === buildBlockId ||
                    item.endBuildBlock.uuid === buildBlockId) {
                return true
            }
            return false
        })
        buildBlockConnections = buildBlockConnections.filter(function(item){
            if (item.beginBuildBlock.uuid === buildBlockId ||
                    item.endBuildBlock.uuid === buildBlockId) {
                return false
            }
            return true
        })
        toDeleteItems.forEach(function(item){            
            item.destroy()
        })

        // 修改模块的前后模块关系
        buildBlocks.forEach(function(item){
            if (item.next === buildBlockId) {
                item.next = ""
            }
            item.last = item.last.filter(function(lastUuid){
                return lastUuid !== buildBlockId
            })
        })

        // 删除模块数据
        buildBlocks = buildBlocks.filter(function(item){
            return item.uuid !== buildBlockId
        })
    }    

    // 只要创建模块与上一个模块之间的连接线，下一个模块的连接线由下一个模块负责创建
    function createBuildBlockConnection(buildBlockData, parent) {
        if (buildBlockData.last.length === 0) {
            return null
        }

        var endBuildBlock = buildBlockCtrls[buildBlockData.uuid]
        if (endBuildBlock === undefined) {
            return null
        }

        for (var i=0; i<buildBlockData.last.length; i++) {
            var beginBuildBlock = buildBlockCtrls[buildBlockData.last[i]]
            if (beginBuildBlock === undefined) {
                continue
            }

            var parames = {beginBuildBlock: beginBuildBlock, endBuildBlock: endBuildBlock}
            var connection = buildBlockConnectionComponent.createObject(parent, parames)
            connection.enabled = isLastBuildBlockFinish(buildBlockData, buildBlockData.last[i])
            connection.requestPaint()
            buildBlockConnections.push(connection)
        }
    }

    function createBuildBlockConnectionV2(beginPoint, endPoint, parent) {
        var beginBuildBlockData = null
        var endBuildBlockData = null
        var beginBuildBlockCtrl = null
        var endBuildBlockCtrl = null
        Object.entries(buildBlockCtrls).forEach(function([key, value]) {
            var beginPointInBuildBlock = parent.mapToItem(value, beginPoint)
            if (value.contains(beginPointInBuildBlock)) {
                beginBuildBlockData = getBuildBlockData(key)
                beginBuildBlockCtrl = value
            }

            var endPointInBuildBlock = parent.mapToItem(value, endPoint)
            if (value.contains(endPointInBuildBlock)) {
                endBuildBlockData = getBuildBlockData(key)
                endBuildBlockCtrl = value
            }
        })

        if (beginBuildBlockData === null || endBuildBlockData === null) {
            return
        }

        if (beginBuildBlockData.uuid === endBuildBlockData.uuid) {
            return
        }

        if (beginBuildBlockData.next !== "") {
            return
        }

        beginBuildBlockData.next = endBuildBlockData.uuid
        endBuildBlockData.last.push(beginBuildBlockData.uuid)
        var params = {beginBuildBlock: beginBuildBlockCtrl, endBuildBlock: endBuildBlockCtrl}
        var connection = buildBlockConnectionComponent.createObject(parent, params)
        connection.enabled = beginBuildBlockData.finish
        connection.requestPaint()
        buildBlockConnections.push(connection)
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
                            "finishTimeLength": 24,
                            "beginTime": 0
                        }'
        var buildBlockData = JSON.parse(jsonString)
        buildBlockData.uuid = FlowManager.getUuid()
        return buildBlockData
    }

    function addBuildBlockData(buildBlockData) {
        buildBlocks.push(buildBlockData)
    }

    function submitFile(buildBlockId, icon, filePath) {
        var buildBlockData = getBuildBlockData((buildBlockId))
        if (buildBlockData === null) {
            return
        }

        var fileName = filePath.split('\\').pop()
        var iconFileName = ""
        if (icon !== null) {
            iconFileName = icon.split('\\').pop()
        }
        buildBlockData.submitFiles.push({icon: iconFileName, filePath: fileName})
    }

    // 获取提交文件的剩余时长，单位秒
    function getRemainTimeLength(buildBlockData) {
        var now = Math.floor(Date.now() / 1000)
        if (now <= buildBlockData.beginTime) {
            return 0
        }

        var useTimeLength = now - buildBlockData.beginTime
        if (useTimeLength >= buildBlockData.finishTimeLength*3600) {
            return 0
        } else {
            return buildBlockData.finishTimeLength*3600 - useTimeLength
        }
    }

    function onTimer() {
        // 更新所有模块显示
        updateBuildBlockCtrls()

        // 自动保存配置文件
        if (lastSaveTime === 0) {
            lastSaveTime = Date.now()
        } else {
            if (Date.now() - lastSaveTime >= autoSaveInterval) {
                saveFlowGraph()
                lastSaveTime = Date.now()
            }
        }
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

    // 转化为绝对路径
    function toAbsolutePath(fileName) {
        var flowDataPath = FlowManager.getFlowDataPath(flowId)
        var absolutePath = "file:///"+flowDataPath+fileName
        return absolutePath
    }

    property Timer timer: Timer{
        id: timer
        interval: 100 // Timer interval in milliseconds
        running: false // Start the timer immediately
        repeat: true // Repeat the timer indefinitely

        onTriggered: {
            buildBlockManager.onTimer()
        }
    }
}
