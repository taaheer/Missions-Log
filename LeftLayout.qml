import QtQuick
import QtQuick.Layouts

HexagonPanel {

    HexagonPanel{
        mirrored: true

        strokeColor: Theme.transparent

        anchors{
            fill: parent
            margins: 8
        }
    }
}
