#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QFontDatabase>
#include <QDebug>

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
#include <QWKQuick/qwkquickglobal.h>
#else
// --- DUMMY MOCK FOR MOBILE ---

#include <QObject>
#include <QQmlEngine>

class DummyWindowAgent : public QObject {
    Q_OBJECT
public:
    enum SystemButton { Minimize, Maximize, Close };
    Q_ENUM(SystemButton)
    Q_INVOKABLE void setup(QObject*) {}
    Q_INVOKABLE void setTitleBar(QObject*) {}
    Q_INVOKABLE void setSystemButton(SystemButton, QObject*) {}
    Q_INVOKABLE void setHitTestVisible(QObject*, bool) {}
    Q_INVOKABLE void setWindowAttribute(const QString&, const QVariant&) {}
};
#endif

#ifdef Q_OS_WIN
#include <windows.h>
#endif

int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);
    QGuiApplication app(argc, argv);

    constexpr std::array fonts = {
            "Orbitron-Regular.ttf",
            "Exo2-Regular.ttf",
            "Michroma-Regular.ttf",
            "NotoSansMath-Regular.ttf"
        };

    const QString fontDir{":/qt/qml/MissionsLog/fonts/"};

    for(const auto font : fonts)
    {
        QString fontPath = fontDir + font;
        int fontId{QFontDatabase::addApplicationFont(fontPath)};

        if(fontId == -1)
        {
            qWarning() << "Failed to load font:" << font;
            continue;
        }
    }


    app.setWindowIcon(QIcon(":/qt/qml/MissionsLog/app.png"));
    app.setOrganizationName("Taaheer Labbe");
    app.setOrganizationDomain("taaheer.com");
    app.setApplicationName("Missions Log");
    app.setApplicationVersion(APP_VERSION);
    app.setApplicationDisplayName("Missions Log");
    app.setDesktopFileName("com.taaheer.missionslog");

#ifdef Q_OS_WIN
    HANDLE hMutex = CreateMutexW(NULL, FALSE, L"MissionsLogMutex");
    if(GetLastError() == ERROR_ALREADY_EXISTS) {
        if (hMutex) CloseHandle(hMutex);
        return 0;
    }
#endif

    QQmlApplicationEngine engine;


#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    QWK::registerTypes(&engine); // Real QWindowKit on Desktop
#else
    qmlRegisterType<DummyWindowAgent>("QWindowKit", 1, 0, "WindowAgent"); // Fake QWindowKit on Mobile
#endif

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("MissionsLog", "Main");

    return QGuiApplication::exec();
}

#include "main.moc"