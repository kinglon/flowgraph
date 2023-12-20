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
#include <QIcon>
#include <QtWinExtras>

#pragma comment  (lib, "User32.lib")

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

    FlowItem* item = new FlowItem(*flowItem);
    item->setLogoFilePath(QString("file:///")+flowLogoFilePath);
    m_flows.append(item);
    saveFlowConfigure(item);

    // save to setting config
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

    m_flowId2BuildBlocks.remove(id);

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
    (void)id;
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
        loadFlow(flowIds[i]);
    }
}

void FlowManager::loadFlow(const QString& flowId)
{
    QString flowDataPath = getFlowDataPath(flowId);
    QString flowConfFilePath = flowDataPath + QString::fromStdWString(flowConfFileName);
    QFile file(flowConfFilePath);
    if (!file.open(QIODevice::ReadOnly)) {
        LOG_ERROR(L"failed to open the flow config file: %s", flowConfFilePath.toStdWString().c_str());
        return;
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
        return;
    }
    QJsonObject root = jsonDocument.object();

    FlowItem* item = new FlowItem();
    item->setId(root["id"].toString());
    item->setName(root["name"].toString());
    QString logoFilePath = QString("file:///") + getFlowDataPath(flowId) + root["logo"].toString();
    item->setLogoFilePath(logoFilePath);
    m_flows.append(item);

    if (root.contains("buildBlocks"))
    {
        m_flowId2BuildBlocks[item->id()] = root["buildBlocks"].toArray();
    }
    else
    {
        m_flowId2BuildBlocks[item->id()] = QJsonArray();
    }
}

void FlowManager::saveFlowConfigure(FlowItem* flowItem)
{
    QJsonObject root;
    root["id"] = flowItem->id();
    root["name"] = flowItem->name();

    // 只存文件名
    QString logoFilePath = flowItem->logoFilePath();
    QFileInfo fileInfo(logoFilePath);
    QString fileName = fileInfo.fileName();
    root["logo"] = fileName;
    if (m_flowId2BuildBlocks.contains(flowItem->id()))
    {
        root["buildBlocks"] = m_flowId2BuildBlocks[flowItem->id()];
    }

    QJsonDocument jsonDocument(root);
    QByteArray jsonData = jsonDocument.toJson(QJsonDocument::Indented);
    QByteArray base64Data = jsonData.toBase64();
    for (int i = 0; i < base64Data.size()/2; ++i)
    {
        char temp = base64Data[i];
        base64Data[i] = base64Data[base64Data.size() - 1 - i];
        base64Data[base64Data.size() - 1 - i] = temp;
    }
    QString flowDataPath = getFlowDataPath(flowItem->id());
    QString flowConfFilePath = flowDataPath + QString::fromStdWString(flowConfFileName);
    QFile file(flowConfFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        LOG_ERROR(L"failed to create the flow configure file : %s", flowConfFilePath.toStdWString().c_str());
        return;
    }
    file.write(base64Data);
    file.close();
}

QString FlowManager::getBuildBlocks(const QString& flowId)
{
    if (m_flowId2BuildBlocks.contains(flowId))
    {
        QJsonDocument jsonDoc(m_flowId2BuildBlocks[flowId]);
        QString jsonString = jsonDoc.toJson(QJsonDocument::Compact);
        return jsonString;
    }
    else
    {
        QJsonArray emptyArray;
        QJsonDocument jsonDoc(emptyArray);
        QString jsonString = jsonDoc.toJson(QJsonDocument::Compact);
        return jsonString;
    }
}

void FlowManager::setBuildBlocks(const QString& flowId, QString buildBlocks)
{
    QJsonDocument jsonDoc = QJsonDocument::fromJson(buildBlocks.toUtf8());
    QJsonArray jsonArray = jsonDoc.array();
    m_flowId2BuildBlocks[flowId] = jsonArray;

    FlowItem flowItem;
    if (getFlowItem(flowId, &flowItem))
    {
        saveFlowConfigure(&flowItem);
    }
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

QString FlowManager::getFileIcon(const QString& flowId, const QString& filePath)
{
    QString localFilePath = filePath;
    QUrl url(filePath);
    if (url.isLocalFile())
    {
        localFilePath = url.toLocalFile();
    }

    SHFILEINFO shfi;
    memset(&shfi, 0, sizeof(SHFILEINFO));
    DWORD_PTR result = ::SHGetFileInfo(reinterpret_cast<const WCHAR*>(localFilePath.utf16()), 0, &shfi, sizeof(SHFILEINFO),
                                       SHGFI_ICON | SHGFI_LARGEICON | SHGFI_USEFILEATTRIBUTES);
    if (result == 0)
    {
        LOG_ERROR(L"failed to get the icon of the file: %s", filePath.toStdWString().c_str());
        return "";
    }

    QPixmap pixmap = QtWin::fromHICON(shfi.hIcon);
    ::DestroyIcon(shfi.hIcon);

    QString outputFilePath = getFlowDataPath(flowId) + getUuid() + ".png";
    if (!pixmap.save(outputFilePath))
    {
        LOG_ERROR(L"failed to save the icon file");
        return "";
    }

    return QString("file:///")+outputFilePath;
}

QString FlowManager::copyFile(const QString& flowId, const QString& filePath)
{
    QString localFilePath = filePath;
    QUrl url(filePath);
    if (url.isLocalFile())
    {
        localFilePath = url.toLocalFile();
    }

    QFileInfo fileInfo(localFilePath);
    QString newFilePath = getFlowDataPath(flowId)+getUuid()+"."+fileInfo.suffix();
    if (!::CopyFile(localFilePath.toStdWString().c_str(), newFilePath.toStdWString().c_str(), TRUE))
    {
        LOG_ERROR(L"failed to copy file");
        return "";
    }

    return QString("file:///")+newFilePath;
}
