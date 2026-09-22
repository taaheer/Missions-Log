pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

ScrollBar {
    id: control
    policy: ScrollBar.AlwaysOn

    property bool frontVisible: true

    contentItem: Rectangle {
        visible: control.frontVisible
        color: Theme.primaryColor
    }

    background: Rectangle {
        color: Qt.darker(Theme.primaryColor, 3.5)
    }
}
