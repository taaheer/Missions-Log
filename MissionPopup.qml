pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root
    modal: true
    focus: true


    property color missionColor: missionType.checked ? Theme.altPrimaryColor : Theme.primaryColor

    property int editIndex: -1
    property bool isEditMode: editIndex >= 0

    ListModel{
        id: stagedTaskModel
        ListElement{
            task: "";
            detail: ""
            type: "Primary"
            isCompleted: false
        }
    }

    onClosed: {
        taskStack.currentIndex = 0
        stagedTaskModel.clear()
    }

    function openForAdd(){
        root.editIndex = -1;
        missionTitle.text = "";
        missionType.checked = false;
        stagedTaskModel.clear();
        stagedTaskModel.append({task: "", detail: "", type: "Primary", isCompleted: false})
        root.open();
    }

    function openForEdit(index, missionData){
        root.editIndex = index;
        missionTitle.text = missionData.title;
        missionType.checked = (missionData.category === "side");
        stagedTaskModel.clear();

        let batchTasks = [];

        let pTasks = missionData.primary || [];
        for(let i = 0; i < pTasks.length; ++i) {
            batchTasks.push({
                                task: pTasks[i].name,
                                detail: pTasks[i].detail || "",
                                type: "Primary",
                                isCompleted: pTasks[i].isCompleted || false
                            });
        }

        let sTasks = missionData.secondary || [];
        for(let j = 0; j < sTasks.length; ++j) {
            batchTasks.push({
                                task: sTasks[j].name,
                                detail: sTasks[j].detail || "",
                                type: "Secondary",
                                isCompleted: sTasks[j].isCompleted || false
                            });
        }

        batchTasks.push({ task: "", detail: "", type: "Primary", isCompleted: false });

        stagedTaskModel.append(batchTasks);

        root.open();
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
        let primary = [];
        let secondary = [];

        for(let i = 0; i < stagedTaskModel.count; ++i){
            let item = stagedTaskModel.get(i);

            if(item.task.trim() !== ""){
                let taskObj = {
                    "name": item.task.toUpperCase(),
                    "detail": item.detail,
                    "category": item.type.toUpperCase() + " OBJECTIVE",
                    "isCompleted": item.isCompleted
                };

                if(item.type === "Primary"){
                    primary.push(taskObj);
                }
                else{
                    secondary.push(taskObj);
                }
            }
        }

        let isSideQuest = missionType.checked;
        let categoryString = isSideQuest ? "side" : "main"

        let missionObj = {
            "title": missionTitle.text.toUpperCase(),
            "category": categoryString,
            "isActive": !isSideQuest,
            "primary": primary
        };

        if(secondary.length > 0)
        {
            missionObj["secondary"] = secondary;
        }

        if (root.isEditMode) {
            MissionManager.editMission(root.editIndex, missionObj);
        }
        else {
            missionObj["isCompleted"] = false;
            missionObj["isSuccess"] = false;
            MissionManager.addMission(missionObj);
        }

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
                        id: delegateItem 
                        
                        required property string type
                        required property string task
                        required property string detail
                        required property int index

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

                                        text: root.getTaskTypeLabel(delegateItem.type, delegateItem.index)

                                        color: root.missionColor
                                        font{
                                            bold: true
                                            pointSize: 14
                                        }

                                        TapHandler  {
                                            cursorShape: Qt.PointingHandCursor
                                            onTapped: {
                                                let newType = (delegateItem.type === "Primary") ? "Secondary" : "Primary";
                                                stagedTaskModel.setProperty(delegateItem.index, "type", newType);
                                            }
                                        }
                                        HoverHandler {
                                            cursorShape: Qt.PointingHandCursor
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
                                        fillColor: hovered ? root.missionColor : Theme.transparent
                                        color: hovered ? Theme.teritiaryTextColor : Theme.primaryTextColor

                                        onClicked: {
                                            stagedTaskModel.remove(delegateItem.index);
                                        }
                                        strokeWidth: 3
                                    }
                                }

                                CustomTextField{
                                    id: taskTitle
                                    text: delegateItem.task
                                    placeholderText: "Title here..."
                                    font.pointSize: 14
                                    Layout.fillWidth: true
                                    color: Theme.primaryTextColor
                                    strokeColor: root.missionColor

                                    onTextEdited: root.updateTaskField(delegateItem.index, "task", text)
                                }

                                CustomTextField{
                                    id: taskDetail
                                    text: delegateItem.detail
                                    placeholderText: "Detail here..."
                                    font.pointSize: 12
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: Theme.primaryTextColor
                                    strokeColor: root.missionColor
                                    wrapMode: Text.Wrap
                                    mirrored: true
                                    cutLength: 20

                                    onTextEdited: root.updateTaskField(delegateItem.index, "detail", text)
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
                required property int index 

                text: index === taskStack.currentIndex ? "▲" : "△"
                color: root.missionColor
                opacity: index === taskStack.currentIndex ? 1.0 : 0.4
            }
        }

        CustomButton{
            text: root.isEditMode ? "Save Changes" : "Start Mission"
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
