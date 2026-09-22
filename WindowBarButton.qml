pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: control

    background: Item{}

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.down ? Theme.primaryTextColor :  Theme.primaryColor

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        scale: control.down ? 0.90 : 1.0

        Behavior on scale{
            NumberAnimation{
                duration: 80
            }
        }

        layer.enabled: true

        layer.effect: MultiEffect{
            shadowEnabled: true
            shadowColor: Theme.primaryColor
            shadowBlur: control.down ? 1.0 : (control.hovered ? 0.5 : 0.0)
            Behavior on shadowBlur {
                NumberAnimation{
                    duration: 150
                    easing: Easing.OutCubic
                }
            }
        }
    }
}
