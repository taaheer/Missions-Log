import QtQuick

Text {
    id: control
    property string finalText: ""
    property string displayText: ""
    property int index: 0
    property bool isDecoding: true
    property int interval: 80

    text: isDecoding ? displayText : finalText

    Timer {
        id: decoderTimer
        interval: control.interval
        repeat: true
        running: control.isDecoding

        onTriggered: {
            if (control.index <= control.finalText.length) {
                let revealed = control.finalText.substring(0, control.index);
                let remainingLength = control.finalText.length - control.index;
                let randomCharacter = "_-/\\{}%=+*#><01";
                let randomNoise = "";

                for (let i = 0; i < remainingLength; ++i) {
                    randomNoise += randomCharacter.charAt(Math.floor(Math.random() * randomCharacter.length));
                }

                control.displayText = revealed + randomNoise;
                control.index++;
            } else {
                control.isDecoding = false;
                decoderTimer.stop();
            }
        }
    }

    onFinalTextChanged: {
        index = 0;
        isDecoding = true;
        decoderTimer.restart();
    }
}