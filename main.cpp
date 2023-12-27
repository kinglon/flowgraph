#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "Utility/LogUtil.h"
#include "Utility/DumpUtil.h"
#include "Utility/ImPath.h"
#include "SettingManager.h"

CLogUtil* g_dllLog = nullptr;

QtMessageHandler originalHandler = nullptr;

void logToFile(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    if (g_dllLog)
    {
        ELogLevel logLevel = ELogLevel::LOG_LEVEL_ERROR;
        if (type == QtMsgType::QtDebugMsg)
        {
            logLevel = ELogLevel::LOG_LEVEL_DEBUG;
        }
        else if (type == QtMsgType::QtInfoMsg || type == QtMsgType::QtWarningMsg)
        {
            logLevel = ELogLevel::LOG_LEVEL_INFO;
        }
        g_dllLog->Log(context.file? context.file: "", context.line, logLevel, msg.toStdWString().c_str());
    }

    if (originalHandler)
    {
        (*originalHandler)(type, context, msg);
    }
}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Jeric");
    app.setOrganizationDomain("jeric.com");

    // 单实例
    const wchar_t* mutexName = L"{4ED33E4A-D83A-4D0A-8523-158D74420098}";
    HANDLE mutexHandle = CreateMutexW(nullptr, TRUE, mutexName);
    if (mutexHandle == nullptr || GetLastError() == ERROR_ALREADY_EXISTS)
    {        
        return 0;
    }

    g_dllLog = CLogUtil::GetLog(L"main");

    //初始化崩溃转储机制
    CDumpUtil::SetDumpFilePath(CImPath::GetDumpPath().c_str());
    CDumpUtil::Enable(true);

    int nLogLevel = CSettingManager::GetInstance()->GetLogLevel();
    g_dllLog->SetLogLevel((ELogLevel)nLogLevel);
    originalHandler = qInstallMessageHandler(logToFile);

    QQmlApplicationEngine engine;
    QUrl url(QStringLiteral("qrc:/qml/ManagerWindow.qml"));
    if (!CSettingManager::GetInstance()->IsManager()) {
        url.setUrl("qrc:/qml/FlowGraphWindow.qml");
    }
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);    
    app.exec();

    CloseHandle(mutexHandle);
    return 0;
}
