import QtQml 2.15

QtObject {
    property string uuid: ""
    property string type: "basic"
    property string last: ""
    property string next: ""
    property bool finish: false
    property string text: ""
    property var studyFiles: []
    property var submitFiles: []
    property var finishCondition: []
    property string finishConditionGroup: ""
    property int finishTimeLength: 7200
    property int remainTimeLength: 7200
}
