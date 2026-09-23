pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

HexagonPanel{
    id: root

    signal editMissionRequested()

    property var currentMission: MissionManager.currentMission
    property color currentColor: currentMission.category === "side" ?  Theme.altPrimaryColor : Theme.primaryColor

    strokeColor: currentColor

    transform: Rotation{
        id: rightRotation
        axis.x: 0
        axis.y: 1
        axis.z: 0

        origin.x: 0
        origin.y: 0

        angle: 20
    }

    ParallelAnimation{
        id: transitionAnimation
        running: true
        NumberAnimation{
            target: root
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 250
            easing.type: Easing.OutQuad
        }

        NumberAnimation{
            target: rightRotation
            property: "angle"
            from: 20
            to: 0
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    property var lastMissionId: root.currentMission?.id

    onCurrentMissionChanged: {
        let newId = root.currentMission?.id;

        if (newId !== lastMissionId) {
            lastMissionId = newId;
            transitionAnimation.restart();
        }
    }

    HexagonPanel{
        strokeColor: Theme.transparent
        anchors{
            fill: parent
            margins: 6
        }
        cutLength: 25

        ColumnLayout{
            anchors{
                fill: parent
                topMargin: 22
                leftMargin: 14
                rightMargin: 10
            }

            HexagonPanel{
                visible: MissionManager.currentIndex >= 0

                Layout.fillWidth: true
                Layout.preferredHeight: title.implicitHeight + 2
                fillColor: Theme.primaryAccent
                strokeColor: Theme.transparent
                Layout.bottomMargin: 2
                cutLength: 20

                ColumnLayout{
                    anchors{
                        fill: parent
                        topMargin: -5
                        leftMargin: 22
                        rightMargin: 20
                    }

                    RowLayout{
                        Layout.fillWidth: true
                        Layout.topMargin: 2

                        AnimatedBullets{
                            spacing: -18
                            pointSize: 14
                            setDarkEven: false
                            Layout.topMargin: -4
                            Layout.alignment: Qt.AlignTop
                            color: Qt.lighter(Theme.primaryAccent, 2)

                            TapHandler {
                                onTapped: missionMenu.popup()
                            }

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }

                            CustomMenu {
                                id: missionMenu
                                strokeColor: root.currentColor
                                CustomMenuItem {
                                    text: qsTr("Edit Mission")
                                    fillColor: hovered ? root.currentColor : Qt.alpha(Theme.secondaryColor, 0.8)
                                    onTriggered: root.editMissionRequested()
                                }
                                CustomMenuItem {
                                    text: root.currentMission?.isCompleted ? qsTr("Reopen Mission") : qsTr("Finish Mission (Failed)")
                                    fillColor: hovered ? root.currentColor : Qt.alpha(Theme.secondaryColor, 0.8)
                                    onTriggered: MissionManager.toggleMissionStatus(MissionManager.currentIndex);
                                }
                            }
                        }

                        Text{
                            id: title
                            text: root.currentMission?.title ?? ""
                            font.pointSize: 18
                            wrapMode: Text.WordWrap
                            color: root.currentColor
                            Layout.fillWidth: true
                            Layout.topMargin: 2
                            lineHeight: 0.8
                            Layout.alignment: Qt.AlignTop
                        }
                    }
                }
            }

            ListView{
                id: taskView
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true

                property real savedScrollY: 0
                property bool isRestoringScroll: false

                onModelChanged: {
                    if(isRestoringScroll){
                        contentY = savedScrollY;
                        isRestoringScroll = false;
                    }
                }

                Layout.leftMargin: 11
                Layout.rightMargin: 22

                model: MissionManager.currentTasks

                section.property: "section"
                section.criteria: ViewSection.FullString

                section.delegate: Item{
                    id: sectionDelegate

                    required property string section 

                    width: taskView.width
                    height: categoryId.implicitHeight + 9

                    Text{
                        id: categoryId
                        anchors{
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            top: parent.top
                            topMargin: 11
                            leftMargin: 25
                        }

                        text: sectionDelegate.section
                        color: root.currentColor
                        font{
                            pointSize: 16
                            capitalization: Font.AllUppercase
                        }
                    }
                }

                delegate: ColumnLayout{
                    id: delegate

                    required property var modelData
                    required property int index

                    width: taskView.width

                    opacity: modelData.isCompleted ? 0.5 : 1.0

                    HexagonPanel{
                        Layout.fillWidth: true
                        Layout.preferredHeight: taskTitle.implicitHeight + 4
                        Layout.topMargin: 7
                        fillColor: Theme.primaryAccent
                        strokeColor: Theme.transparent
                        cutLength: 16

                        RowLayout{
                            anchors{
                                left: parent.left
                                leftMargin: delegate.modelData.isCompleted ? 15 : 24
                                verticalCenter: parent.verticalCenter
                            }

                            spacing: 10

                            Text{
                                text: delegate.modelData.isCompleted ? "✓" : "▶"

                                color: root.currentColor;
                                font.pointSize: delegate.modelData.isCompleted ? 20 : 30
                                Layout.leftMargin: delegate.modelData.isCompleted ? 10 : 2
                                Layout.bottomMargin: 2

                                TapHandler {
                                    onTapped: {
                                        let startMissionId = MissionManager.currentMission.id;
                                        let view = taskView;

                                        taskView.savedScrollY = taskView.contentY;
                                        taskView.isRestoringScroll = true;

                                        MissionManager.toggleTaskCompletion(delegate.modelData.originalIndex);

                                        if (!MissionManager.currentMission || MissionManager.currentMission.id !== startMissionId) {
                                            view.isRestoringScroll = false;
                                        }
                                    }
                                }
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }


                            Text{
                                id: taskTitle
                                text: delegate.modelData.name
                                color: Theme.primaryTextColor

                                Layout.leftMargin: delegate.modelData.isCompleted ? -3 : 3

                                font{
                                    pointSize: 16
                                    capitalization: Font.AllUppercase
                                }
                            }
                        }
                    }
                    Text{
                        id: detail
                        text: delegate.modelData.detail
                        wrapMode: Text.WordWrap
                        color: "white"
                        Layout.fillWidth: true
                        Layout.leftMargin: 59
                        Layout.topMargin: -1
                        Layout.bottomMargin: 11
                        lineHeight: 0.85
                        font{
                            pointSize: 14
                        }
                    }
                }
                ScrollBar.vertical: CustomScrollBar{
                    visible: taskView.contentHeight > taskView.height
                    active: taskView.contentHeight > taskView.height
                    parent: taskView.parent.parent
                    implicitWidth: 5

                    anchors{
                        right: parent.right
                        bottom: parent.bottom
                        bottomMargin: 20
                        rightMargin: 11
                    }

                    height: parent.height - 101
                }
            }
        }
    }
}
