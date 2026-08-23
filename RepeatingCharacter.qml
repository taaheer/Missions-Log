import QtQuick

Text{
    id: control
    property string finalText
    property string displayText: ""
    property int index: 0

    font.pointSize: 5
    color: Theme.primaryColor
    text: displayText

    Timer{
        id: revealTimer
        interval: 125
        repeat: true
        running: true

        onTriggered: {
            if(control.index <= control.finalText.length){
                control.displayText =  control.finalText.substring(0, control.index)
                control.index++
            }
            else{
                revealTimer.stop()
            }
        }
    }
}
