pragma Singleton
import QtQuick

QtObject {
    readonly property color primaryColor: "#f3b71b"
    readonly property color secondaryColor: "#040200"


    readonly property color primaryTextColor: "#F0F0F0"
    readonly property color secondaryTextColor: primaryColor
    readonly property color teritiaryTextColor: secondaryColor
}