pragma Singleton
import QtQuick

QtObject{
    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    property bool isCompactView: false
}
