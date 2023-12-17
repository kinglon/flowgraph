import QtQml 2.15

QtObject {
    // 文件类型：image, video, 空串表示未知
    property string type: ""

    // 封面图片地址
    property string coverImage: ""

    // 文件绝对路径
    property string filePath: ""
}
