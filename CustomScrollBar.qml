pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

ScrollBar {
    id: control
    policy: ScrollBar.AlwaysOn

    property bool frontVisible: true

    contentItem: Rectangle {
        visible: control.frontVisible
        color: Theme.colorPrimary
    }

    background: Rectangle {
        color: Qt.darker(Theme.colorPrimary, 3.5)
    }
}
