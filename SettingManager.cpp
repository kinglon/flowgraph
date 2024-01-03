#include "SettingManager.h"
#include <QFile>
#include "Utility/ImPath.h"
#include "Utility/ImCharset.h"
#include "Utility/LogMacro.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#define MANAGER_FLAG_KEY  "werouik123456sfsdfd"

CSettingManager::CSettingManager()
{
    Load();
}

CSettingManager* CSettingManager::GetInstance()
{
	static CSettingManager* pInstance = new CSettingManager();
	return pInstance;
}

void CSettingManager::Load()
{
    std::wstring strConfFilePath = CImPath::GetConfPath() + L"configs.json";    
    QFile file(QString::fromStdWString(strConfFilePath));
    if (!file.open(QIODevice::ReadOnly))
    {
        LOG_ERROR(L"failed to open the basic configure file : %s", strConfFilePath.c_str());
        return;
    }
    QByteArray jsonData = file.readAll();
    file.close();

    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonData);
    QJsonObject root = jsonDocument.object();
    m_nLogLevel = root["log_level"].toInt();
    if (root.contains(MANAGER_FLAG_KEY)) {
        m_isManager = true;
    }
    if (root.contains("flow_window_width")) {
        m_flowWindowWidth = root["flow_window_width"].toInt();
    }
    if (root.contains("flow_window_height")) {
        m_flowWindowHeight = root["flow_window_height"].toInt();
    }

    m_flows.clear();
    QJsonArray flows = root["flows"].toArray();
    for (const QJsonValue& value : flows)
    {
        m_flows.append(value.toString());
    }
}

void CSettingManager::Save()
{
    QJsonObject root;
    root["log_level"] = m_nLogLevel;
    if (m_isManager)
    {
        root[MANAGER_FLAG_KEY] = 1;
    }

    QJsonArray flows;
    for (auto flow : m_flows)
    {
        flows.append(flow);
    }
    root["flows"] = flows;
    root["flow_window_width"] = m_flowWindowWidth;
    root["flow_window_height"] = m_flowWindowHeight;

    QJsonDocument jsonDocument(root);
    QByteArray jsonData = jsonDocument.toJson(QJsonDocument::Indented);
    std::wstring strConfFilePath = CImPath::GetConfPath() + L"configs.json";
    QFile file(QString::fromStdWString(strConfFilePath));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        LOG_ERROR(L"failed to open the basic configure file : %s", strConfFilePath.c_str());
        return;
    }
    file.write(jsonData);
    file.close();
}

void CSettingManager::CreateNewConfigFile(const QString& confFileName, const QString& flowId)
{
    QJsonObject root;
    root["log_level"] = 2;

    QJsonArray flows;
    flows.append(flowId);
    root["flows"] = flows;

    QJsonDocument jsonDocument(root);
    QByteArray jsonData = jsonDocument.toJson(QJsonDocument::Indented);
    std::wstring strConfFilePath = CImPath::GetConfPath() + confFileName.toStdWString();
    QFile file(QString::fromStdWString(strConfFilePath));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        LOG_ERROR(L"failed to open the basic configure file : %s", strConfFilePath.c_str());
        return;
    }
    file.write(jsonData);
    file.close();
}

void CSettingManager::SetFlows(const QVector<QString>& flows)
{
    m_flows = flows;
    Save();
}

void CSettingManager::SetFlowWindowSize(QPoint flowWindowSize)
{
    m_flowWindowWidth = flowWindowSize.x();
    m_flowWindowHeight = flowWindowSize.y();
    Save();
}
