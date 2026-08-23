import QtQuick

Text {
    id: control

    property string finalText
    property string displayText: ""
    property int index: 0
    property bool isDecoding: true

    Timer{
        id: decoderTimer
        interval: 70
        repeat: true
        running: true

        onTriggered: {
            if(control.isDecoding){
                if(control.index <= control.finalText.length){
                    let revealed = control.finalText.substring(0, control.index)
                    let remainingLenght = control.finalText.length - control.index
                    let randomCharacter = "_-/\\[{}=+*#><01"
                    let randomNoise = ""

                    for(let i = 0; i < remainingLenght; ++i){
                        randomNoise += randomCharacter.charAt(Math.floor(Math.random() * randomCharacter.length))
                    }

                    control.displayText = revealed  + randomNoise
                    control.index++;
                }
                else{
                    control.isDecoding = false
                    parent.text = control.finalText
                    decoderTimer.stop()
                }
            }
        }
    }

    text: isDecoding ? displayText : finalText

    onFinalTextChanged: {
        index = 0
        isDecoding = true
        decoderTimer.restart()
    }
}
