import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root
    modal: true
    focus: true

    property color missionColor: missionType.checked ? Theme.altPrimaryColor : Theme.primaryColor

    ListModel{
        id: stagedTaskModel
        ListElement{
            task: "";
            detail: ""
            type: "Primary"
        }
    }

    function updateTaskField(index, name, value){
        stagedTaskModel .setProperty(index, name, value);

        if (index === stagedTaskModel.count - 1 && value.trim() !== "") {
            stagedTaskModel.append({ "task": "", "detail": "", "type": stagedTaskModel.get(index).type });
        }
    }

    function getTaskTypeLabel(currentType, index){
        let relativeCount = 1;
        for(let i = 0; i < index; ++i){
            if(stagedTaskModel.get(i).type === currentType){
                relativeCount++;
            }
        }

        return `${currentType} ${relativeCount}`;

    }

    function startMission(){
        var primary = [];
        var secondary = [];

        for(var i = 0; i < stagedTaskModel.count; ++i){
            var item = stagedTaskModel.get(i);

            if(item.task.trim() !== ""){
                var taskObj = {
                    "name": item.task.toUpperCase(),
                    "detail": item.detail,
                    "category": item.type.toUpperCase() + " OBJECTIVE",
                    "isCompleted": false
                };

                if(item.type === "Primary"){
                    primary.push(taskObj);
                }
                else{
                    secondary.push(taskObj);
                }
            }
        }

        var isSideQuest = missionType.checked;
        var categoryString = isSideQuest ? "side" : "main"
        var generatedId = (isSideQuest ? "s" : "m") + 1

        var missionObj = {
            "title": missionTitle.text.toUpperCase(),
            "category": categoryString,
            "isCompleted": false,
            "isSuccess": false,
            "isActive": !isSideQuest,
            "primary": primary
        };

        if(secondary.length > 0)
        {
            missionObj["secondary"] = secondary;
        }

        MissionManager.addMission(missionObj);

        stagedTaskModel.clear();
        stagedTaskModel.append({ task: "", detail: "", type: "Primary" });
        root.close();
    }

    background: HexagonPanel{
        fillColor: Theme.transparent
        strokeColor: root.missionColor

        mirrored: true

        HexagonPanel{
            anchors{
                fill: parent
                margins: 4
            }
            strokeColor: Theme.transparent
            fillColor: Theme.secondaryColor
            mirrored: true
        }
    }

    contentItem: ColumnLayout{
        anchors{
            fill: parent
            margins: 25
            centerIn: parent
        }

        CustomTextField{
            id: missionTitle
            placeholderText: "Type Mission..."
            font.pointSize: 14
            color: root.missionColor
            Layout.fillWidth: true
            strokeColor: root.missionColor
        }

        RowLayout{
            Layout.fillWidth: true
            Item {
                Layout.fillWidth: true
            }

            Button{
                id: missionType
                text: checked ? "Side Quest" : "Main Mission"
                checkable: true
                checked: false
                Layout.rightMargin: 8
                background: HexagonPanel{
                    mirrored: true
                    strokeColor: root.missionColor
                    fillColor: root.missionColor
                }
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true

            SwipeButton{
                id: prevButton
                text: enabled ? "◁" : "◂"
                enabled: taskStack.currentIndex > 0
                onClicked: taskStack.decrementCurrentIndex()
                Layout.fillHeight: true
                color: root.missionColor
            }

            SwipeView{
                id: taskStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Repeater{
                    model: stagedTaskModel
                    Item{
                        width: taskStack.width
                        height: taskStack.height

                        Rectangle{
                            anchors{
                                fill: parent
                                margins: 4
                            }

                            color: Theme.secondaryColor

                            ColumnLayout{
                                anchors{
                                    fill: parent
                                    margins: 1
                                }

                                Item{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 25

                                    Text{
                                        anchors.centerIn: parent

                                        text: root.getTaskTypeLabel(model.type, index)

                                        color: root.missionColor
                                        font{
                                            bold: true
                                            pointSize: 14
                                        }

                                        TapHandler  {
                                            cursorShape: Qt.PointingHandCursor
                                            onTapped: {
                                                let newType = (model.type === "Primary") ? "Secondary" : "Primary";
                                                stagedTaskModel.setProperty(index, "type", newType);
                                            }
                                        }
                                    }

                                    CustomButton{
                                        anchors.right: parent.right
                                        text: "Delete"
                                        pointSize: 8
                                        visible: stagedTaskModel.count > 1
                                        width: 80
                                        height: 20
                                        strokeColor: root.missionColor
                                        onClicked: {
                                            stagedTaskModel.remove(index);
                                        }
                                    }
                                }

                                CustomTextField{
                                    id: taskTitle
                                    text: model.task
                                    placeholderText: "Title here..."
                                    font.pointSize: 14
                                    Layout.fillWidth: true
                                    color: Theme.primaryTextColor
                                    strokeColor: root.missionColor

                                    onTextEdited: updateTaskField(index, "task", text)
                                }

                                CustomTextField{
                                    id: taskDetail
                                    text: model.detail
                                    placeholderText: "Detail here..."
                                    font.pointSize: 12
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: Theme.primaryTextColor
                                    strokeColor: root.missionColor
                                    wrapMode: Text.Wrap
                                    mirrored: true
                                    cutLength: 20

                                    onTextEdited: updateTaskField(index, "detail", text)
                                }
                            }
                        }
                    }
                }
            }

            SwipeButton{
                id: nextButton
                text: enabled ? "▷" : "▸"
                enabled: taskStack.currentIndex < taskStack.count - 1
                onClicked: taskStack.incrementCurrentIndex()
                Layout.fillHeight: true
                color: root.missionColor
            }
        }

        PageIndicator{
            count: taskStack.count
            currentIndex: taskStack.currentIndex
            Layout.alignment: Qt.AlignHCenter
            delegate: Text {
                text: index === taskStack.currentIndex ? "▲" : "△"
                color: root.missionColor
                opacity: index === taskStack.currentIndex ? 1.0 : 0.4
            }
        }

        CustomButton{
            text: "Start Mission"
            Layout.fillWidth: true
            enabled: missionTitle.text.trim() !== "" && stagedTaskModel.count > 0
            fillColor: enabled ? root.missionColor : Qt.darker(root.missionColor, 3)
            strokeColor: root.missionColor
            color: Theme.secondaryColor
            onClicked: {
                root.startMission();
            }
        }
    }

    Overlay.modal: Rectangle{
        color: Qt.alpha(root.missionColor, 0.1)
    }
}
