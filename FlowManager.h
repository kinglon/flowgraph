#ifndef CFLOWMANAGER_H
#define CFLOWMANAGER_H

#include <QObject>
#include <qqml.h>

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
    Q_INVOKABLE QString getUuid();

    Q_INVOKABLE bool getFlowItem(const QString& id, FlowItem* flowItem);

    Q_INVOKABLE bool addFlowItem(FlowItem* flowItem);

    Q_INVOKABLE void deleteFlowItem(const QString& id);

    Q_INVOKABLE QString copyFlowItem(const QString& id);

    Q_INVOKABLE void packageFlowItem(const QString& id);

    QQmlListProperty<FlowItem> flows();

private:
    void loadFlows();

    FlowItem* loadFlow(const QString& flowId);

    QString getFlowDataPath(const QString& flowId);

    void deleteDirectory(const QString& dirPath);

private:
    QList<FlowItem*> m_flows;
};

#endif // CFLOWMANAGER_H
