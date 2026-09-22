pragma ComponentBehavior: Bound
import QtQuick

Text{
    id: control
    property string finalText
    property string displayText: ""
    property int index: 0
    property int interval: 125

    font.pointSize: 5
    color: Theme.primaryColor
    text: displayText

    onFinalTextChanged: {
        control.index = 0
        control.displayText = ""
        revealTimer.restart()
    }

    Timer{
        id: revealTimer
        interval: control.interval
        repeat: true
        running: control.finalText.length > 0

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
