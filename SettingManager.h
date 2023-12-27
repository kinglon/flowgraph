#pragma once

#include <QString>
#include <QVector>

class CSettingManager
{
protected:
	CSettingManager();

public:
	static CSettingManager* GetInstance();

public:
    int GetLogLevel() { return m_nLogLevel; }

    bool IsManager() { return m_isManager; }

    QVector<QString> GetFlows() { return m_flows;}

    void SetFlows(const QVector<QString>& flows);

	void Save();

    void CreateNewConfigFile(const QString& confFileName, const QString& flowId);

private:
	void Load();

private:
    int m_nLogLevel = 2;  // debug

    // 标识是否为管理端
    bool m_isManager = false;

    QVector<QString> m_flows;
};
