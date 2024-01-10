import QtQml 2.15
import QtQuick 2.15
import Flow 1.0

QtObject {
    property string flowId

    property bool editable: false

    // 每个模块的数据信息
    property var buildBlocks: []

    // 每个模块对应的控件
    property var buildBlockCtrls: ({})

    // 连接线列表
    property var buildBlockConnections: []

    // 定时保存配置，单位毫秒
    property int autoSaveInterval: 5000

    // 上一次保存配置的时间戳，单位毫秒
    property var lastSaveTime

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

    // 判断指定的模块的前面模块是否已经完成
    function isLastBuildBlockFinish(buildBlockData) {
        if (buildBlockData.last.length === 0) {
            return true
        }

        for (var i=0; i<buildBlockData.last.length; i++) {
            var lastBuildBlockData = getBuildBlockData(buildBlockData.last[i])
            if (lastBuildBlockData === null) {
                continue
            }

            if (!lastBuildBlockData.finish || !isLastBuildBlockFinish(lastBuildBlockData)) {
                return false
            }
        }

        return true
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
            buildBlock.okButton.enabled = !buildBlockData.finish

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
        buildBlock.editable = editable
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

            if (buildBlockData.type !== "text") {
                buildBlockCtrl.canUse = editable || isLastBuildBlockFinish(buildBlockData)
            }

            if (buildBlockData.type === "timer" && buildBlockCtrl.canUse && !buildBlockData.finish) {
                if (buildBlockData.beginTime === 0) {
                    buildBlockData.beginTime = Math.floor(Date.now() / 1000)
                }

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
                var enabled = editable || (isLastBuildBlockFinish(beginBuildBlockData) && beginBuildBlockData.finish)
                var isChanged = connection.enabled===enabled
                connection.enabled = enabled
                if (isChanged) {
                    connection.requestPaint()
                }
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
            item.next = item.next.filter(function(nextUuid){
                return nextUuid !== buildBlockId
            })
            item.last = item.last.filter(function(lastUuid){
                return lastUuid !== buildBlockId
            })
        })

        // 删除模块数据
        buildBlocks = buildBlocks.filter(function(item){
            return item.uuid !== buildBlockId
        })
    }    

    // 删除指定模块的后连接线
    function deleteNextConnection(buildBlockId) {
        // 删除连接线并销毁
        buildBlockConnections = buildBlockConnections.filter(function(connection) {
            if (connection.beginBuildBlock.uuid === buildBlockId) {
                connection.destroy()
                return false
            }
            return true
        })

        // 修改模块的前后模块关系
        buildBlocks.forEach(function(item){
            if (item.uuid === buildBlockId) {
                // 清空自己模块的next
                item.next = []
            }
            else {
                item.last = item.last.filter(function(lastUuid){
                    return lastUuid !== buildBlockId
                })
            }
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
            connection.requestPaint()
            buildBlockConnections.push(connection)
        }
    }

    // 判断2个模块是否连接
    function isBuildBlockConnected(beginBuildBlockData, buildBlockId) {
        if (beginBuildBlockData.next.indexOf(buildBlockId) !== -1) {
            return true
        }

        for (var i=0; i<beginBuildBlockData.next.length; i++) {
            var blockData = getBuildBlockData(beginBuildBlockData.next[i])
            if (blockData !== null && isBuildBlockConnected(blockData, buildBlockId)) {
                return true
            }
        }

        return false
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

        // 自己不能连自己
        if (beginBuildBlockData.uuid === endBuildBlockData.uuid) {
            return
        }

        // 已经连过，不能再连
        if (beginBuildBlockData.next.indexOf(endBuildBlockData.uuid) !== -1) {
            return
        }

        // 不能循环连接
        if (isBuildBlockConnected(endBuildBlockData, beginBuildBlockData.uuid)) {
            return
        }

        beginBuildBlockData.next.push(endBuildBlockData.uuid)
        endBuildBlockData.last.push(beginBuildBlockData.uuid)
        var params = {beginBuildBlock: beginBuildBlockCtrl, endBuildBlock: endBuildBlockCtrl}
        var connection = buildBlockConnectionComponent.createObject(parent, params)        
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
                            "next": [],
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

    // 检查提交的文件是否已经满足完成条件
    function checkIfFinish(buildBlockData) {
        var conditions = []
        buildBlockData.finishCondition.forEach(function(condition){
            if (condition.groupName === buildBlockData.finishConditionGroup) {
                conditions.push(utility.deepCopy(condition))
            }
        })

        if (conditions.length === 0) {
            return true
        }

        buildBlockData.submitFiles.forEach(function(submitFile) {
            var filePath = submitFile.filePath
            var extension = utility.getFileExtension(filePath)
            var size = utility.getFileSize(toAbsolutePath(filePath))
            for (var i=0; i<conditions.length; i++) {
                if (conditions[i].count > 0
                        && conditions[i].suffix === extension
                        && size >= conditions[i].sizeMin*1024*1024
                        && size <= conditions[i].sizeMax*1024*1024) {
                    conditions[i].count -= 1
                    break
                }
            }
        })

        for (var i=0; i<conditions.length; i++) {
            if (conditions[i].count > 0) {
                return false
            }
        }

        return true
    }

    // 计算容纳所有模块所需要的大小
    function calculateBuildBlockContainerSize() {
        var size = Qt.point(0, 0)
        buildBlocks.forEach(function(buildBlock) {
            if (buildBlock.x > size.x) {
                size.x = buildBlock.x
            }
            if (buildBlock.y > size.y) {
                size.y = buildBlock.y
            }
        })

        // 加上默认模块宽度和高度
        size.x += 200
        size.y += 200

        return size
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

    // 检测定时模块是否已经超时，如果超时清除提交文件，更新完成条件
    function checkIfTimeout() {
        var now = Math.floor(Date.now() / 1000)
        buildBlocks.forEach(function(buildBlockData) {
            if (buildBlockData.type === "timer"
                    && !buildBlockData.finish
                    && buildBlockData.beginTime > 0
                    && now - buildBlockData.beginTime > buildBlockData.finishTimeLength*3600) {
                buildBlockData.beginTime = 0
                buildBlockData.submitFiles = []

                var conditionGroupNames = []
                buildBlockData.finishCondition.forEach(function(condition) {
                    if (!conditionGroupNames.includes(condition.groupName)) {
                        conditionGroupNames.push(condition.groupName)
                    }
                })

                if (conditionGroupNames.length > 0) {
                    var nextIndex = (conditionGroupNames.indexOf(buildBlockData.finishConditionGroup)+1)%conditionGroupNames.length
                    buildBlockData.finishConditionGroup = conditionGroupNames[nextIndex]
                }

                updateBuildBlock(buildBlockData)
            }
        })
    }

    function onTimer() {
        // 更新所有模块显示
        updateBuildBlockCtrls()

        // 检测定时模块是否已经超时
        checkIfTimeout()

        // 自动保存配置文件
        if (lastSaveTime === undefined) {
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
}
