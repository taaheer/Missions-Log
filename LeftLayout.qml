import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import MissionsLog

HexagonPanel {

    HexagonPanel{
        mirrored: true
        cutLength: 25


        strokeColor: Theme.transparent

        anchors{
            fill: parent
            margins: 7
        }

        ColumnLayout{
            anchors{
                fill: parent
                leftMargin: 10
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView{
                    id: missionList

                    anchors{
                        fill: parent
                        leftMargin: 18
                        topMargin: 1
                    }

                    model: MissionManager.proxyModel
                    clip: true
                    spacing: 25
                    currentIndex: MissionManager.currentIndex

                    Connections{
                        target: MissionManager
                        function onViewStatusChanged(){
                            missionList.currentIndex = 0
                            MissionManager.currentIndex = 0
                        }
                    }

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0)
                        {
                            MissionManager.currentIndex = currentIndex;

                        }
                    }

                    section.property: "category"
                    section.criteria: ViewSection.FullString
                    section.delegate: RowLayout{
                        id: missionHeader
                        spacing: 1

                        property color categoryColor: section == "main" ? Theme.primaryColor : Theme.altPrimaryColor

                        AnimatedBullets{
                            Layout.topMargin: 5
                            spacing: -18
                            Layout.alignment: Qt.AlignVCenter
                            pointSize: 16
                            color: missionHeader.categoryColor
                        }

                        ColumnLayout{
                            spacing: -5
                            Layout.topMargin: 5
                            Text{
                                Layout.topMargin: 3
                                font{
                                    pointSize: 18
                                    capitalization: Font.AllUppercase
                                }
                                color: missionHeader.categoryColor
                                text: section === "main" ? "Main Missions" : "Side Quests"
                            }
                            Row {
                                spacing: 2
                                opacity: 1
                                Repeater {
                                    model: 11

                                    Text {
                                        text: "◥"
                                        color: Theme.altPrimaryColor
                                        font.pointSize: 5
                                        font.weight: Font.Black
                                        opacity: Math.random() * 1.0 + 0.0
                                    }
                                }
                            }
                            Row {
                                spacing: 2
                                opacity: 1
                                Repeater {
                                    model: 11

                                    Text {
                                        text: "◥"
                                        color: Theme.altPrimaryColor
                                        font.pointSize: 5
                                        font.weight: Font.Black
                                        opacity: Math.random() * 1.0 + 0.0
                                    }
                                }
                            }
                        }
                    }

                    delegate: ColumnLayout{
                        id: delegate

                        width: ListView.view.width
                        Layout.fillWidth: true

                        property color containerColor: model.category === "main" ? Theme.primaryColor : Theme.altPrimaryColor
                        property bool isSelected: missionList.currentIndex === index

                        MouseArea{
                            Layout.fillWidth: true
                            Layout.preferredHeight: missionListContainer.implicitHeight
                            hoverEnabled: true
                            onEntered: missionList.currentIndex = index

                            RowLayout{
                                id: missionListContainer
                                anchors.fill: parent

                                spacing: 10

                                HexagonPanel{
                                    mirrored: true
                                    fillColor: Theme.transparent
                                    strokeColor: delegate.isSelected ? delegate.containerColor : Theme.transparent
                                    Layout.preferredHeight: titleId.implicitHeight + 48
                                    Layout.fillWidth: true

                                    Layout.leftMargin: 2

                                    HexagonPanel{
                                        anchors{
                                            fill: parent
                                            margins: 6
                                        }

                                        cutLength: 25

                                        mirrored: true

                                        fillColor: Theme.primaryAccent
                                        strokeColor: Theme.transparent

                                        Text{
                                            anchors{
                                                bottom: parent.bottom
                                                left: parent.left
                                                leftMargin: 16
                                            }
                                            text: "\u005C".repeat(Math.max(10, Math.floor(parent.width / (font.pointSize * 0.6 * 2))))

                                            font{
                                                pointSize: 11
                                                weight: Font.Black
                                                letterSpacing:  -1
                                            }

                                            color: Qt.lighter(parent.fillColor, 1.4)

                                            font{
                                                weight: Font.Black
                                            }

                                            transform: [
                                                Scale{
                                                    xScale: 1.8
                                                    yScale: 1.0
                                                },
                                                Shear{
                                                    xFactor: 0.2
                                                }
                                            ]

                                        }
                                    }

                                    Item{
                                        anchors{
                                            fill: parent
                                            topMargin: 13
                                            leftMargin: 10
                                        }

                                        HexagonPanel{
                                            id: activePanel
                                            anchors{
                                                top: parent.top
                                                left: parent.left
                                            }

                                            mirrored: true

                                            fillColor: MissionManager.viewStatus === "finished"
                                                       ? (model.isSuccess ? delegate.containerColor : "red")
                                                       : (model.isActive ? delegate.containerColor : Theme.secondaryColor)
                                            strokeColor: Theme.transparent

                                            height: 18
                                            width: activeStatus.implicitWidth + 28

                                            Text{
                                                id: activeStatus
                                                anchors.centerIn: parent

                                                font{
                                                    pointSize: 13
                                                    capitalization: Font.AllUppercase
                                                }

                                                text: MissionManager.viewStatus === "finished"
                                                      ? (model.isSuccess ? "COMPLETED" : "FAILED")
                                                      : (model.isActive ? "ACTIVE" : "INACTIVE")

                                                color: MissionManager.viewStatus === "finished"
                                                       ? (model.isSuccess ? Theme.secondaryColor : Theme.primaryTextColor)
                                                       : (model.isActive ? Theme.secondaryColor : Theme.primaryTextColor)
                                            }
                                        }

                                        Text{
                                            id: titleId
                                            anchors{
                                                top: activePanel.bottom
                                                left: parent.left
                                                right: parent.right
                                                leftMargin: 18
                                                topMargin: 1
                                            }

                                            font.pointSize: 16

                                            lineHeight: 0.8

                                            text: model.title
                                            wrapMode: Text.WordWrap
                                            color: Theme.primaryTextColor
                                        }

                                        HexagonPanel{
                                            anchors{
                                                top: parent.top
                                                right: parent.right
                                                topMargin: titleId.implicitHeight + 26
                                                rightMargin: 18
                                            }

                                            visible: MissionManager.viewStatus !== "finished"

                                            mirrored: true
                                            strokeColor: delegate.containerColor
                                            fillColor: Theme.secondaryColor

                                            height: 25
                                            width: activeButton.implicitWidth + 66
                                            opacity: delegate.isSelected ? 1.0 : 0.0

                                            Text{
                                                id: activeButton

                                                anchors.centerIn: parent

                                                font{
                                                    pointSize: 12
                                                    capitalization: Font.AllUppercase

                                                }
                                                color: delegate.containerColor
                                                text: model.isActive ? "Inactive" : "Active"
                                            }

                                            MouseArea{
                                                anchors.fill: parent

                                                onClicked: MissionManager.toggleMissionActive(index)
                                            }
                                        }
                                    }
                                }

                                Item{
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 30

                                    Text{
                                        anchors.centerIn: parent
                                        text: "⫸"
                                        color: delegate.containerColor
                                        font.pointSize: 30
                                        opacity: delegate.isSelected ? 1.0 : 0.0
                                    }
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: CustomScrollBar{
                        policy: ScrollBar.AlwaysOn
                        parent: missionList.parent
                        implicitWidth: 5

                        height: parent.height - 36
                        active: true

                        frontVisible: missionList.contentHeight > missionList.height

                        anchors{
                            left: parent.left
                            top: parent.top
                            topMargin: 13
                            leftMargin: 1
                        }
                    }
                }
            }
        }
    }
}
