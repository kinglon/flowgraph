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

    QPoint GetFlowWindowSize() { return QPoint(m_flowWindowWidth, m_flowWindowHeight); }

    void SetFlowWindowSize(QPoint flowWindowSize);

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

    // 流程图窗口的宽度
    int m_flowWindowWidth = 1000;

    // 流程图窗口的高度
    int m_flowWindowHeight = 660;

    QVector<QString> m_flows;
};
