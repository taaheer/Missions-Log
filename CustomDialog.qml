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
            color: Theme.colorPrimary
            font {
                pointSize: Theme.fontSizeS
                bold: true
                letterSpacing: 2
                capitalization: Font.AllUppercase
                family: Theme.fontFamilyTitle
            }
        }
    }

    background: HexagonPanel {
        fillColor: Theme.transparent
        cutLength: Theme.cutM
        mirrored: true

        HexagonPanel{
            strokeColor: Theme.transparent
            fillColor: Theme.colorSecondary
            cutLength: Theme.cutM
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
            fillColor: hovered ? Theme.colorPrimary : Theme.transparent
            color: hovered ? Theme.textColorTertiary : Theme.textColorPrimary
            implicitWidth: 100
            strokeWidth: 3
        }
    }

    Overlay.modal: Rectangle{
        color: Qt.alpha(Theme.colorPrimary, 0.1)
    }
}
