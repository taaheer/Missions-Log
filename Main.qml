import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Universal
import QtCore

import MissionsLog

import QWindowKit

ApplicationWindow {
    id: window
    width: 640
    height: 480
    minimumWidth: 200
    minimumHeight: 250
    visible: true
    title: qsTr("Missions Log")

    Settings{
        id: userSettings

        property alias windowWidth: window.width
        property alias windowHeight: window.height

    }

    color: "transparent"

    background: Rectangle{
        color: Qt.alpha(Theme.primaryColor, 0.1)
    }

    WindowAgent{
        id: windowAgent
    }

    Component.onCompleted: {
        windowAgent.setup(window)
        windowAgent.setTitleBar(titleBar)

        windowAgent.setSystemButton(WindowAgent.Minimize, minButton)
        windowAgent.setSystemButton(WindowAgent.Maximize, maxButton)
        windowAgent.setSystemButton(WindowAgent.Close, closeButton)

        windowAgent.setHitTestVisible(minButton, true)
        windowAgent.setHitTestVisible(maxButton, true)
        windowAgent.setHitTestVisible(closeButton, true)

        if(Qt.platform.os === "windows"){
            windowAgent.setWindowAttribute("dwm-blur", false)
            windowAgent.setWindowAttribute("acrylic-material", false)
            windowAgent.setWindowAttribute("mica", false)
        } else if (Qt.platform.os === "osx") {
            windowAgent.setWindowAttribute("blur-effect", "none")
        }
    }

    ColumnLayout{
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            height: 36
            color: "transparent"


            RowLayout{
                anchors.fill: parent
                spacing: 2

                Icon{
                    iconScale: 0.6
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: 6
                }

                AnimatedBullets{
                    spacing: -13
                    Layout.topMargin: -8
                }

                ColumnLayout{
                    spacing: -6
                    DecoderText {
                        id: titleText
                        color: Theme.primaryTextColor
                        font{
                            pointSize: 16
                            capitalization: Font.AllUppercase
                        }
                        Layout.fillWidth: true

                        finalText: window.title
                    }

                    RepeatingCharacter{
                        finalText: "◥".repeat(16)
                        color: Theme.primaryColor
                        font.pointSize: 5
                    }
                }

                RowLayout{
                    Layout.fillHeight: true

                    WindowBarButton{
                        id: minButton
                        Layout.preferredWidth: 45
                        Layout.fillHeight: true
                        text: "⎊"
                        font.pointSize: 20

                        onClicked: window.showMinimized()
                    }

                    WindowBarButton{
                        id: maxButton
                        Layout.preferredWidth: 45
                        Layout.fillHeight: true
                        text: window.visibility === Window.Maximized ? "⏣" : "⬡"
                        font.pointSize: 20


                        onClicked: {
                            if (window.visibility === Window.Maximized) {
                                window.showNormal()
                            } else {
                                window.showMaximized()
                            }
                        }
                    }

                    WindowBarButton{
                        id: closeButton
                        Layout.preferredWidth: 45
                        Layout.fillHeight: true
                        text: "⌬"
                        font.pointSize: 20
                        onClicked: window.close()
                    }
                }
            }
        }

        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

}
