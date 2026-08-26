import QtQuick

HexagonPanel{
    id: root

    HexagonPanel{
        strokeColor: Theme.transparent
        anchors{
            fill: parent
            margins: 6
        }
        cutLength: 25
    }
}
