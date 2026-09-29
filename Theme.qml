pragma Singleton
import QtQuick

QtObject {
    readonly property color transparent: "transparent"

    readonly property color colorPrimary: "#f3b71b"
    readonly property color colorSecondary: "#040200"

    readonly property color accentPrimary: "#202020"

    readonly property color colorPrimaryAlt: "#1bf3b7"

    readonly property color textColorPrimary: "#F0F0F0"
    readonly property color textColorSecondary: colorPrimary
    readonly property color textColorTertiary: colorSecondary

    readonly property int fontSizeXS: Device.isMobile ? 14 : 12
    readonly property int fontSizeS: Device.isMobile ? 16 : 14
    readonly property int fontSizeM: Device.isMobile ? 18 : 16
    readonly property int fontSizeL: Device.isMobile ? 20 : 18
    readonly property int fontSizeXL: Device.isMobile ? 25 : 32

    readonly property int strokeNormal: 3
    readonly property int strokeThick: 4

    readonly property int cutXS: 10
    readonly property int cutS: 15
    readonly property int cutM: 20
    readonly property int cutL: 25
    readonly property int cutXL: 30

    readonly property int spaceSmall: 6
    readonly property int spaceNormal: 12
    readonly property int spaceLarge: 20

    readonly property string fontFamilyTitle: "Orbitron"
    readonly property string fontFamilyParagraph: "Exo 2"
    readonly property string fontFamilySubTitle: "Michroma"
    readonly property string fontFamilySymbol: "Noto Sans Math"
}
