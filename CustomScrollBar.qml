import QtQuick
import QtQuick.Controls

ScrollBar {
    policy: ScrollBar.AlwaysOn

    property bool frontVisible: true

    contentItem: Rectangle {
        visible: frontVisible
        color: Theme.primaryColor
    }

    background: Rectangle {
        color: Qt.darker(Theme.primaryColor, 3.5)
    }
}