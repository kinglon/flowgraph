#ifndef CFLOWMANAGER_H
#define CFLOWMANAGER_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <qqml.h>
#include "packagethread.h"

class FlowItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id WRITE setId)
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(QString logoFilePath READ logoFilePath WRITE setLogoFilePath)
    QML_ELEMENT

public:
    FlowItem() {}
    FlowItem(const FlowItem& other);

    // Assignment operator
    FlowItem& operator=(const FlowItem &other);

    QString id() const { return m_id;}
    void setId(const QString &id) { m_id = id;}

    QString name() const { return m_name; }
    void setName(const QString &name) { m_name = name; }

    QString logoFilePath() const { return m_logoFilePath; }
    void setLogoFilePath(const QString &logoFilePath) { m_logoFilePath = logoFilePath; }

private:
    QString m_id;

    QString m_name;

    // 带有协议 file:///
    QString m_logoFilePath;
};

class FlowManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<FlowItem> flows READ flows)
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit FlowManager(QObject *parent = nullptr);
    ~FlowManager();

public:
    QQmlListProperty<FlowItem> flows();

    Q_INVOKABLE QString getUuid();

    Q_INVOKABLE bool getFlowItem(const QString& id, FlowItem* flowItem);

    Q_INVOKABLE bool addFlowItem(FlowItem* flowItem);

    Q_INVOKABLE void deleteFlowItem(const QString& id);

    Q_INVOKABLE bool updateFlowItem(FlowItem* flowItem);

    Q_INVOKABLE QString copyFlowItem(const QString& id);

    Q_INVOKABLE void packageFlowItem(const QString& id, const QString& originZipFilePath);

    Q_INVOKABLE void cancelPackage();

    Q_INVOKABLE QString getBuildBlocks(const QString& flowId);

    Q_INVOKABLE void setBuildBlocks(const QString& flowId, QString buildBlocks);

    Q_INVOKABLE QString getFlowDataPath(const QString& flowId);

    // 将文件的图标信息拷贝到流程图目录下，再返回绝对的路径地址（包含file:///），获取失败返回空串
    Q_INVOKABLE QString getFileIcon(const QString& flowId, const QString& filePath);

    // 将filePath拷贝到流程图目录下，返回新文件的绝对路径（包含file:///），拷贝失败返回空串
    Q_INVOKABLE QString copyFile(const QString& flowId, const QString& filePath);

    Q_INVOKABLE QPoint getFlowWindowSize();

    Q_INVOKABLE void setFlowWindowSize(const QPoint& flowWindowSize);

signals:
    void packageFinish(bool isSuccess);

private slots:
    void packageThreadFinish();

private:
    void loadFlows();

    void loadFlow(const QString& flowId);

    void saveFlowConfigure(FlowItem* flowItem);

    void deleteDirectory(const QString& dirPath);

    bool copyFolder(const QString& sourceFolder, const QString& destinationFolder);

private:
    QList<FlowItem*> m_flows;

    QMap<QString, QJsonArray> m_flowId2BuildBlocks;

    PackageThread* m_packageThread = nullptr;
};

#endif // CFLOWMANAGER_H
