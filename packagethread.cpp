#include "packagethread.h"
#include "Windows.h"
#include <QFileInfo>
#include <QProcess>
#include <QCoreApplication>

PackageThread::PackageThread(QObject *parent)
    : QThread{parent}
{

}

void PackageThread::run()
{
    // 拷贝一份
    QFileInfo fileInfo(m_originZipFilePath);
    QString newZipFilePath = fileInfo.absolutePath() + "\\" + m_newZipFileName;
    ::DeleteFile(newZipFilePath.toStdWString().c_str());
    if (!::CopyFile(m_originZipFilePath.toStdWString().c_str(), newZipFilePath.toStdWString().c_str(), TRUE))
    {
        qCritical("failed to create the zip file");
        return;
    }
    if (m_cancel)
    {
        return;
    }

    QString workDirectory = QCoreApplication::applicationDirPath() + "\\..\\";
    QString program = workDirectory+"7z\\7z.exe";

    // 添加配置文件configs2.json和data目录
    QStringList addParam;
    addParam.append("a");
    addParam.append(newZipFilePath);
    addParam.append("flowgraph\\Configs\\configs2.json");
    addParam.append(QString("flowgraph\\data\\flows\\")+m_flowId+"\\*");
    QProcess addProcess;
    addProcess.setWorkingDirectory(workDirectory);
    addProcess.start(program, addParam);
    if (!addProcess.waitForStarted(-1))
    {
        qCritical("failed to start 7z process");
        return;
    }
    addProcess.waitForFinished(-1);
    if (addProcess.exitStatus() != QProcess::NormalExit || addProcess.exitCode() != 0)
    {
        qCritical(QString::fromUtf8(addProcess.readAll()).toStdString().c_str());
        return;
    }
    if (m_cancel)
    {
        return;
    }

    // 删除原先的configs.json
    QStringList delParam;
    delParam.append("d");
    delParam.append(newZipFilePath);
    delParam.append("flowgraph\\Configs\\configs.json");
    QProcess delProcess;
    delProcess.setWorkingDirectory(workDirectory);
    delProcess.start(program, delParam);
    if (!delProcess.waitForStarted(-1))
    {
        qCritical("failed to start 7z process");
        return;
    }
    delProcess.waitForFinished(-1);
    if (delProcess.exitStatus() != QProcess::NormalExit || delProcess.exitCode() != 0)
    {
        qCritical(QString::fromUtf8(delProcess.readAll()).toStdString().c_str());
        return;
    }
    if (m_cancel)
    {
        return;
    }

    // 重名名configs2.json为configs.json
    QStringList renameParam;
    renameParam.append("rn");
    renameParam.append(newZipFilePath);
    renameParam.append("flowgraph\\Configs\\configs2.json");
    renameParam.append("flowgraph\\Configs\\configs.json");
    QProcess renameProcess;
    renameProcess.setWorkingDirectory(workDirectory);
    renameProcess.start(program, renameParam);
    if (!renameProcess.waitForStarted(-1))
    {
        qCritical("failed to start 7z process");
        return;
    }
    renameProcess.waitForFinished(-1);
    if (renameProcess.exitStatus() != QProcess::NormalExit || renameProcess.exitCode() != 0)
    {
        qCritical(QString::fromUtf8(renameProcess.readAll()).toStdString().c_str());
        return;
    }
    if (m_cancel)
    {
        return;
    }

    m_success = true;
}
