import QtQuick
import QtQuick.Layouts

ColumnLayout{
    id: control

    SequentialAnimation{
        running: true
        loops: 1

        NumberAnimation{
            target: bullet1
            property: "opacity"
            from: 0
            to: 1
            duration: 400
        }
        NumberAnimation{
            target: bullet2
            property: "opacity"
            from: 0
            to: 1
            duration: 400
        }
        NumberAnimation{
            target: bullet3
            property: "opacity"
            from: 0
            to: 1
            duration: 400
        }

        PauseAnimation {
            duration: 800
        }
    }

    Text{
        id: bullet1
        text: "•"
        color: Theme.primaryColor
        font.pointSize: 12
        opacity: 0
    }
    Text{
        id: bullet2
        text: "•"
        color: Qt.darker(Theme.primaryColor, 2)
        font.pointSize: 12
        opacity: 0
    }
    Text{
        id: bullet3
        text: "•"
        color: Theme.primaryColor
        font.pointSize: 12
        opacity: 0
    }
}
