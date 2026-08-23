#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

#include <QWKQuick/qwkquickglobal.h>

int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication app(argc, argv);

    app.setOrganizationName("Taaheer Labbe");
    app.setOrganizationDomain("taaheer.com");
    app.setApplicationName("Missions Log");
    app.setApplicationVersion("0.1");

    app.setApplicationDisplayName("Missions Log");
    app.setDesktopFileName("com.taaheer.missionslog");

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
