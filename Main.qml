pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Universal
import QtQml.Models

import MissionsLog

import QWindowKit // qmllint disable import

ApplicationWindow {
    id: window
    width: 1320
    height: 579
    minimumWidth: 350
    minimumHeight: 250
    visible: true
    title: qsTr("Missions Log")



    Binding {
        target: Device
        property: "isCompactView"
        value: window.width < 800
    }


    // Settings{
    //     id: userSettings

    //     property alias windowWidth: window.width
    //     property alias windowHeight: window.height

    // }

    color: "transparent"

    background: Rectangle{
        color: Qt.alpha(Theme.colorPrimary, 0.1)
    }
    
    WindowAgent{
        id: windowAgent
    }

    // qmllint disable unqualified

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
    // qmllint enable unqualified

    ColumnLayout{
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: titleBar

            visible: !Device.isMobile

            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: Theme.transparent


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
                        color: Theme.textColorPrimary
                        font{
                            pointSize: Theme.fontSizeM
                            capitalization: Font.AllUppercase
                        }
                        Layout.fillWidth: true

                        finalText: window.title


                    }

                    RepeatingCharacter{
                        finalText: "◥".repeat(16)
                        color: Theme.colorPrimary
                        font.pointSize: 5
                    }
                }

                RowLayout{
                    Layout.fillHeight: true


                    WindowBarButton{
                        id: minButton
                        Layout.preferredWidth: 45
                        Layout.fillHeight: true
                        text: "❖"
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



            ListView{
                id: main

                anchors{
                    fill: parent
                    topMargin: parent.height * 0.0349
                    bottomMargin: parent.height * 0.105
                    rightMargin: parent.width * 0.071
                    leftMargin: parent.width * 0.095
                }


                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                interactive: Device.isCompactView
                clip: false

                spacing: 10

                model: ObjectModel{
                    LeftLayout{
                        id: leftLayout
                        mirrored: true
                        width: Device.isCompactView ? main.width : (main.width / 2) - (main.width * 0.046)
                        height: main.height
                        fillColor: Theme.transparent
                        strokeColor: Theme.accentPrimary

                        opacity: 0

                        transform: Rotation{
                            id: leftRotation
                            axis.x: 0
                            axis.y: 1
                            axis.z: 0

                            origin.x: leftLayout.width
                            origin.y: 0

                            angle: 90
                        }

                        ParallelAnimation{
                            id: leftAnimation
                            running: true
                            NumberAnimation{
                                target: leftLayout
                                property: "opacity"
                                from: 0.0
                                to: 1.0
                                duration: 700
                                easing.type: Easing.OutQuad
                            }

                            NumberAnimation{
                                target: leftRotation
                                property: "angle"
                                from: 90
                                to: 0
                                duration: 700
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    RightLayout{
                        id: rightLayout
                        fillColor: Theme.transparent
                        width: Device.isCompactView ? main.width : (main.width - leftLayout.width - main.spacing)
                        height: main.height
                        cutLength: 26

                        opacity: 0

                        onEditMissionRequested: {
                            newMissionPopup.openForEdit(MissionManager.currentIndex, MissionManager.currentMission);
                        }

                        transform: Rotation{
                            id: rightRotation
                            axis.x: 0
                            axis.y: 1
                            axis.z: 0

                            origin.x: 0
                            origin.y: 0

                            angle: 90
                        }

                        ParallelAnimation{
                            id: rightAnimation
                            running: true
                            NumberAnimation{
                                target: rightLayout
                                property: "opacity"
                                from: 0.0
                                to: 1.0
                                duration: 500
                                easing.type: Easing.OutQuad
                            }

                            NumberAnimation{
                                target: rightRotation
                                property: "angle"
                                from: 90
                                to: 0
                                duration: 500
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }

            RowLayout{
                anchors{
                    top: main.bottom
                    left: main.left
                    right: main.right
                    topMargin: main.height * 0.02
                }

                spacing: 20

                CustomButton{
                    text: qsTr("Current")
                    strokeColor: MissionManager.viewStatus === "current" ? Theme.colorPrimary : Qt.alpha(Theme.colorSecondary, 0.5)
                    onClicked: {
                        MissionManager.viewStatus = "current"
                    }
                    Layout.fillWidth: true
                }

                CustomButton{
                    text: qsTr("Finished")
                    strokeColor: MissionManager.viewStatus === "finished" ? Theme.colorPrimary : Qt.alpha(Theme.colorSecondary, 0.5)
                    onClicked: {
                        MissionManager.viewStatus = "finished"
                    }
                    Layout.fillWidth: true
                }


                CustomButton{
                    text: qsTr("New Mission")
                    visible: !Device.isCompactView
                    strokeColor: hovered ? Theme.colorPrimary : Qt.alpha(Theme.colorSecondary, 0.5)

                    onClicked: {
                        newMissionPopup.openForAdd();
                    }
                    Layout.fillWidth: true
                }
            }

            Item {
                anchors.fill: main
                z: 99

                TapHandler {
                    id: tap

                    longPressThreshold: 0.4

                    onLongPressed: {
                        menu.popup(tap.point.position.x - (menu.implicitContentWidth / 2), tap.point.position.y - (menu.height * (Device.isMobile ? 1.6 : 1.2)))
                    }
                }

                CustomMenu {
                    id: menu
                    strokeColor: Theme.colorPrimary
                    CustomMenuItem {
                        text: qsTr("Add Mission")
                        onTriggered: newMissionPopup.openForAdd()
                    }
                }

            }
        }
    }

    MissionPopup{
        id: newMissionPopup
        anchors.centerIn: parent
        width: parent.width * (Device.isMobile ? 1 : 0.7)
        height: parent.height * (Device.isMobile ? 1 : 0.8)
    }
}
