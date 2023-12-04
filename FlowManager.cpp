#include "FlowManager.h"
#include "SettingManager.h"
#include "ImPath.h"
#include <QFile>
#include <QByteArray>
#include "LogMacro.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <shlwapi.h>
#include <QFileInfo>

const std::wstring flowFolder(L"flows");
const std::wstring flowConfFileName(L"flowconf");

FlowItem::FlowItem(const FlowItem& other)
{
    if (this != &other)
    {
        *this = other;
    }
}

FlowItem& FlowItem::operator=(const FlowItem &other)
{    
    m_id = other.m_id;
    m_name = other.m_name;
    m_logoFilePath = other.m_logoFilePath;
    return *this;
}


FlowManager::FlowManager(QObject *parent)
    : QObject{parent}
{
    loadFlows();
}

FlowManager::~FlowManager()
{
    for (int i=0; i<m_flows.size(); i++)
    {
        delete m_flows[i];
    }
    m_flows.clear();
}

void FlowManager::addFlowItem(FlowItem* flowItem)
{
    // remove the file:// of logo path
    QString logoFilePath = flowItem->logoFilePath();
    QUrl url(logoFilePath);
    if (url.isLocalFile())
    {
        logoFilePath = url.toLocalFile();
    }

    // copy logo file
    QFileInfo fileInfo(logoFilePath);
    QString logoFileName = fileInfo.fileName();
    QString flowDataPath = getFlowDataPath(flowItem->id());
    QString flowLogoFilePath = flowDataPath + logoFileName;
    if (!QFile::copy(logoFilePath, flowLogoFilePath))
    {
        LOG_ERROR(L"failed to copy logo file from %s to %s",
                  flowItem->logoFilePath().toStdWString().c_str(),
                  flowLogoFilePath.toStdWString().c_str());
        return;
    }

    // create config file
    QJsonObject root;
    root["id"] = flowItem->id();
    root["name"] = flowItem->name();
    root["logo"] = logoFileName;
    QJsonDocument jsonDocument(root);
    QByteArray jsonData = jsonDocument.toJson(QJsonDocument::Indented);
    QByteArray base64Data = jsonData.toBase64();
    for (int i = 0; i < base64Data.size()/2; ++i)
    {
        char temp = base64Data[i];
        base64Data[i] = base64Data[base64Data.size() - 1 - i];
        base64Data[base64Data.size() - 1 - i] = temp;
    }
    QString flowConfFilePath = flowDataPath + QString::fromStdWString(flowConfFileName);
    QFile file(flowConfFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        LOG_ERROR(L"failed to create the flow configure file : %s", flowConfFilePath.toStdWString().c_str());
        return;
    }
    file.write(base64Data);
    file.close();

    FlowItem* item = new FlowItem(*flowItem);
    item->setLogoFilePath(QString("file:///")+flowLogoFilePath);
    m_flows.append(item);

    // save to config
    QVector<QString> flowIds = CSettingManager::GetInstance()->GetFlows();
    flowIds.append(flowItem->id());
    CSettingManager::GetInstance()->SetFlows(flowIds);
}


void FlowManager::deleteFlowItem(const QString& id)
{
    for (int i=0; i<m_flows.size(); i++)
    {
        if (m_flows[i]->id() == id)
        {
            delete m_flows[i];
            m_flows.removeAt(i);
            break;
        }
    }
}

void FlowManager::updateFlowItem(FlowItem* flowItem)
{
    for (int i=0; i<m_flows.size(); i++)
    {
        if (m_flows[i]->id() == flowItem->id())
        {
            *m_flows[i] = *flowItem;
            break;
        }
    }
}

QQmlListProperty<FlowItem> FlowManager::flows()
{
    return QQmlListProperty<FlowItem>(this, &m_flows);
}

void FlowManager::loadFlows()
{
    QVector<QString> flowIds = CSettingManager::GetInstance()->GetFlows();
    for (int i=0; i<flowIds.size(); i++)
    {
        FlowItem* flowItem = loadFlow(flowIds[i]);
        if (flowItem)
        {
            m_flows.append(flowItem);
        }
    }
}

FlowItem* FlowManager::loadFlow(const QString& flowId)
{
    QString flowDataPath = getFlowDataPath(flowId);
    QString flowConfFilePath = flowDataPath + QString::fromStdWString(flowConfFileName);
    QFile file(flowConfFilePath);
    if (!file.open(QIODevice::ReadOnly)) {
        LOG_ERROR(L"failed to open the flow config file: %s", flowConfFilePath.toStdWString().c_str());
        return nullptr;
    }
    QByteArray binaryData = file.readAll();
    file.close();

    for (int i = 0; i < binaryData.size()/2; ++i)
    {
        char temp = binaryData[i];
        binaryData[i] = binaryData[binaryData.size() - 1 - i];
        binaryData[binaryData.size() - 1 - i] = temp;
    }
    QByteArray decodedData = QByteArray::fromBase64(binaryData);
    QJsonDocument jsonDocument = QJsonDocument::fromJson(decodedData);
    if (jsonDocument.isNull())
    {
        LOG_ERROR(L"failed to parse the flow config file");
        return nullptr;
    }
    QJsonObject root = jsonDocument.object();

    FlowItem* item = new FlowItem();
    item->setId(root["id"].toString());
    item->setName(root["name"].toString());
    QString logoFilePath = QString("file:///") + getFlowDataPath(flowId) + root["logo"].toString();
    item->setLogoFilePath(logoFilePath);
    return item;
}

QString FlowManager::getFlowDataPath(const QString& flowId)
{
    std::wstring flowDataPath = CImPath::GetDataPath() + flowFolder + L"\\";
    if (!PathFileExists(flowDataPath.c_str()))
    {
        CreateDirectory(flowDataPath.c_str(), NULL);
    }
    flowDataPath += flowId.toStdWString() + L"\\";
    if (!PathFileExists(flowDataPath.c_str()))
    {
        CreateDirectory(flowDataPath.c_str(), NULL);
    }
    return QString::fromStdWString(flowDataPath);
}
