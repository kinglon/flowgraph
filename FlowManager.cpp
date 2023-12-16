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
#include <QUuid>
#include <QDir>

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

QString FlowManager::getUuid()
{
    // Generate a UUID
    QUuid uuid = QUuid::createUuid();

    // Convert the UUID to a string
    QString uuidString = uuid.toString();

    return uuidString;
}

bool FlowManager::getFlowItem(const QString& id, FlowItem* flowItem)
{
    for (int i=0; i<m_flows.size(); i++)
    {
        if (m_flows[i]->id() == id)
        {
            *flowItem = *m_flows[i];
            return true;
        }
    }

    return false;
}

bool FlowManager::addFlowItem(FlowItem* flowItem)
{
    // remove the protocal: file://
    QString logoFilePath = flowItem->logoFilePath();
    QUrl url(logoFilePath);
    if (url.isLocalFile())
    {
        logoFilePath = url.toLocalFile();
    }

    // copy logo file
    QFileInfo fileInfo(logoFilePath);
    QString logoFileName = getUuid()+'.'+fileInfo.suffix();
    QString flowDataPath = getFlowDataPath(flowItem->id());
    QString flowLogoFilePath = flowDataPath + logoFileName;
    if (!QFile::copy(logoFilePath, flowLogoFilePath))
    {
        LOG_ERROR(L"failed to copy logo file from %s to %s",
                  flowItem->logoFilePath().toStdWString().c_str(),
                  flowLogoFilePath.toStdWString().c_str());
        return false;
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
        return false;
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

    return true;
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

    // 删除资源文件目录
    QString flowDataPath = getFlowDataPath(id);
    deleteDirectory(flowDataPath);

    // save to config
    QVector<QString> flowIds = CSettingManager::GetInstance()->GetFlows();
    flowIds.removeAll(id);
    CSettingManager::GetInstance()->SetFlows(flowIds);
}

void FlowManager::deleteDirectory(const QString& dirPath)
{
    QDir dir(dirPath);

    // Check if the directory exists
    if (!dir.exists())
        return;

    // Get the list of entries in the directory
    QStringList entries = dir.entryList(QDir::NoDotAndDotDot | QDir::Files | QDir::Dirs | QDir::Hidden | QDir::System);

    // Iterate over the entries
    foreach (QString entry, entries)
    {
        QFileInfo fileInfo(dirPath + QDir::separator() + entry);

        // Recursively delete subdirectories
        if (fileInfo.isDir())
        {
            deleteDirectory(fileInfo.filePath());
        }
        // Delete files
        else
        {
            QFile::remove(fileInfo.filePath());
        }
    }

    // Remove the empty directory
    dir.rmdir(dirPath);
}

QString FlowManager::copyFlowItem(const QString& id)
{
    FlowItem flowItem;
    if (!getFlowItem(id, &flowItem)) {
        return "";
    }

    flowItem.setId(getUuid());
    flowItem.setName(flowItem.name()+"_2");
    addFlowItem(&flowItem);
    return flowItem.id();
}

void FlowManager::packageFlowItem(const QString& id)
{
    // todo by yejinlong, packageFlowItem
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
