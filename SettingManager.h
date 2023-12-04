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

    QVector<QString> GetFlows() { return m_flows;}

    void SetFlows(const QVector<QString>& flows);

	void Save();

private:
	void Load();

private:
    int m_nLogLevel = 2;  // debug

    QVector<QString> m_flows;
};
