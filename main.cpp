#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

#include <QWKQuick/qwkquickglobal.h>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication app(argc, argv);

    app.setWindowIcon(QIcon(":/qt/qml/MissionsLog/app.png"));

    app.setOrganizationName("Taaheer Labbe");
    app.setOrganizationDomain("taaheer.com");
    app.setApplicationName("Missions Log");
    app.setApplicationVersion(APP_VERSION);

    app.setApplicationDisplayName("Missions Log");
    app.setDesktopFileName("com.taaheer.missionslog");

#ifdef Q_OS_WIN
    HANDLE hMutex = CreateMutexW(NULL, FALSE, L"MissionsLogMutex");
    
    if(GetLastError() == ERROR_ALREADY_EXISTS) 
    {
        if (hMutex) {
            CloseHandle(hMutex);
        }
        return 0; 
    }
#endif

    QQmlApplicationEngine engine;

    QWK::registerTypes(&engine);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("MissionsLog", "Main");

    return QGuiApplication::exec();
}
