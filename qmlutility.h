#ifndef QMLUTILITY_H
#define QMLUTILITY_H

#include <QObject>
#include <qqml.h>

// 配合QML Utility
class QmlUtility : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit QmlUtility(QObject *parent = nullptr);

public:
    // 获取指定文件（file:///）的大小（字节数）
    Q_INVOKABLE qint64 getFileSize(const QString& filePath);
};

#endif // QMLUTILITY_H
