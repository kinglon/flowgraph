#ifndef PACKAGETHREAD_H
#define PACKAGETHREAD_H

#include <QThread>

class PackageThread : public QThread
{
    Q_OBJECT
public:
    explicit PackageThread(QObject *parent = nullptr);

public:
    void run() override;

public:
    QString m_originZipFilePath;

    QString m_newZipFileName;

    QString m_flowId;

    bool m_success = false;

    bool m_cancel = false;
};

#endif // PACKAGETHREAD_H
