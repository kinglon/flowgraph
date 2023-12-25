#include "qmlutility.h"
#include <QFileInfo>

QmlUtility::QmlUtility(QObject *parent)
    : QObject{parent}
{

}

qint64 QmlUtility::getFileSize(const QString& filePath) {
    QString localFilePath = filePath;
    QUrl url(filePath);
    if (url.isLocalFile()) {
        localFilePath = url.toLocalFile();
    }

    QFileInfo fileInfo(localFilePath);
    qint64 fileSize = fileInfo.size();
    return fileSize;
}
