pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Menu {
    id: control

    contentItem: ListView {
        implicitWidth: 200
        implicitHeight: contentHeight + 12
        model: control.contentModel

        spacing: 6

        anchors{
            fill: parent
            margins: 6
        }
        interactive: Window.window
                     ? contentHeight + control.topPadding + control.bottomPadding > control.height
                     : false
        clip: false
        currentIndex: control.currentIndex

        ScrollIndicator.vertical: ScrollIndicator {}
    }

    background: HexagonPanel {
        mirrored: true
        cutLength: 20
    }
}
