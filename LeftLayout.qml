pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import MissionsLog

HexagonPanel {
    id: root

    HexagonPanel{
        mirrored: true
        cutLength: Theme.cutL


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

                        required property string section 

                        property color categoryColor: section == "main" ? Theme.colorPrimary : Theme.colorPrimaryAlt

                        AnimatedBullets{
                            Layout.topMargin: Device.isMobile ? 3 : 5
                            spacing: Device.isMobile ? -15 : -18
                            Layout.alignment: Qt.AlignVCenter
                            pointSize: Theme.fontSizeM
                            color: missionHeader.categoryColor

                            TapHandler {
                                onTapped: menu.popup()
                                margin: 15
                            }

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }

                            CustomMenu {
                                id: menu
                                strokeColor: missionHeader.categoryColor
                                CustomMenuItem {
                                    text: qsTr("Reset Everything")
                                    onTriggered: confirmResetDialog.open()
                                }
                            }

                            CustomDialog {
                                id: confirmResetDialog
                                title: "RESET DATA"
                                standardButtons: Dialog.Yes | Dialog.No

                                Text {
                                    width: root.width
                                    text: qsTr("Are you sure you want to reset all missions? All unsaved progress will be lost.")
                                    color: Theme.textColorPrimary
                                    font{
                                        pointSize: Theme.fontSizeXS
                                        family: Theme.fontFamilyParagraph
                                    }
                                    wrapMode: Text.WordWrap
                                }

                                onAccepted: {
                                    MissionManager.resetToDefault()
                                }
                            }
                        }

                        ColumnLayout{
                            spacing: Device.isMobile ? -1 : -5
                            Layout.topMargin: 5
                            Layout.bottomMargin: Device.isMobile ? 3 : 0
                            Text{
                                id: sectionText
                                Layout.topMargin: 3
                                Layout.bottomMargin: -3
                                font{
                                    pointSize: Theme.fontSizeL
                                    capitalization: Font.AllUppercase
                                }
                                color: missionHeader.categoryColor
                                text: missionHeader.section === "main" ? qsTr("Main Missions") : qsTr("Side Quests")
                            }
                            Row {
                                spacing: 2
                                opacity: 1
                                Repeater {
                                    model: 11

                                    Text {
                                        text: "◥"
                                        color: Theme.colorPrimaryAlt
                                        font.pointSize: Device.isMobile ? 4 : 5
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
                                        color: Theme.colorPrimaryAlt
                                        font.pointSize: Device.isMobile ? 4 : 5
                                        font.weight: Font.Black
                                        opacity: Math.random() * 1.0 + 0.0
                                    }
                                }
                            }
                        }
                    }

                    delegate: ColumnLayout{
                        id: delegate

                        required property var model 
                        required property int index 

                        width: ListView.view.width
                        Layout.fillWidth: true

                        property color containerColor: model.category === "main" ? Theme.colorPrimary : Theme.colorPrimaryAlt
                        property bool isSelected: missionList.currentIndex === index

                        Item{
                            Layout.fillWidth: true
                            Layout.preferredHeight: missionListContainer.implicitHeight

                            HoverHandler{
                                onHoveredChanged: {
                                    missionList.currentIndex = delegate.index
                                }
                            }

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

                                        cutLength: Theme.cutL

                                        mirrored: true

                                        fillColor: Theme.accentPrimary
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
                                                       ? (delegate.model.isSuccess ? delegate.containerColor : "red")
                                                       : (delegate.model.isActive ? delegate.containerColor : Theme.colorSecondary)
                                            strokeColor: Theme.transparent

                                            height: 18
                                            width: activeStatus.implicitWidth + 28

                                            Text{
                                                id: activeStatus
                                                anchors.centerIn: parent

                                                font{
                                                    pointSize: Theme.fontSizeXS
                                                    capitalization: Font.AllUppercase
                                                }

                                                text: MissionManager.viewStatus === "finished"
                                                      ? (delegate.model.isSuccess ? "COMPLETED" : "FAILED")
                                                      : (delegate.model.isActive ? "ACTIVE" : "INACTIVE")

                                                color: MissionManager.viewStatus === "finished"
                                                       ? (delegate.model.isSuccess ? Theme.colorSecondary : Theme.textColorPrimary)
                                                       : (delegate.model.isActive ? Theme.colorSecondary : Theme.textColorPrimary)
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

                                            font{
                                                pointSize: Theme.fontSizeM
                                            }

                                            lineHeight: 0.8

                                            text: delegate.model.title
                                            wrapMode: Text.WordWrap
                                            color: Theme.textColorPrimary
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
                                            fillColor: Theme.colorSecondary

                                            height: 25
                                            width: activeButton.implicitWidth + 66
                                            opacity: delegate.isSelected ? 1.0 : 0.0

                                            enabled: delegate.isSelected

                                            Text{
                                                id: activeButton

                                                anchors.centerIn: parent

                                                font{
                                                    pointSize: Theme.fontSizeXS
                                                    capitalization: Font.AllUppercase
                                                }
                                                color: delegate.containerColor
                                                text: delegate.model.isActive ? qsTr("Inactive") : qsTr("Active")
                                            }

                                            TapHandler {
                                                gesturePolicy: TapHandler.ReleaseWithinBounds
                                                margin: 15
                                                onTapped: MissionManager.toggleMissionActive(delegate.index)
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
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: missionList.count === 0
                    spacing: 12

                    Text {
                        text: qsTr("NO MISSION")
                        color: Theme.colorPrimary
                        font {
                            pointSize: Theme.fontSizeM
                            bold: true
                            letterSpacing: 2
                            family: Theme.fontFamilyTitle
                        }
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
