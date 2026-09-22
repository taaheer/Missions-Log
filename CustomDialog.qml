pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Dialog {
    id: control
    modal: true
    anchors.centerIn: Overlay.overlay

    padding: 20
    topPadding: 16

    header: Item {
        implicitHeight: titleText.implicitHeight
        Text {
            id: titleText
            anchors {
                left: parent.left
                leftMargin: 20
                top: parent.top
                topMargin: 15
            }
            text: control.title
            color: Theme.primaryColor
            font {
                pointSize: 14
                bold: true
                letterSpacing: 2
                capitalization: Font.AllUppercase
            }
        }
    }

    background: HexagonPanel {
        fillColor: Theme.transparent
        cutLength: 20
        mirrored: true

        HexagonPanel{
            strokeColor: Theme.transparent
            fillColor: Theme.secondaryColor
            cutLength: 20
            mirrored: true

            anchors{
                fill: parent
                margins: 6
            }
        }
    }

    footer: DialogButtonBox {
        background: Item {}
        alignment: Qt.AlignCenter

        spacing: 150

        delegate: CustomButton {
            fillColor: hovered ? Theme.primaryColor : Theme.transparent
            color: hovered ? Theme.teritiaryTextColor : Theme.primaryTextColor
            implicitWidth: 100
            strokeWidth: 3
        }
    }

    Overlay.modal: Rectangle{
        color: Qt.alpha(Theme.primaryColor, 0.1)
    }
}
