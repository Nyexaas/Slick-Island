import QtQuick
import Quickshell

Text {
    id: clockText

    // 0: Classical  (14:27) | 1: english (02:27 PM) | 2: Date | 3: hour + Date
    property int mode: 0

    // Function called via left click on the bubble.
    function nextMode() {
        mode = (mode + 1) % 4;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: {
        switch (mode) {
            case 0: return Qt.formatDateTime(clock.date, "HH:mm");
            case 1: return Qt.formatDateTime(clock.date, "hh:mm AP");
            case 2: return Qt.formatDateTime(clock.date, "ddd dd MMM");
            case 3: return Qt.formatDateTime(clock.date, "HH:mm • dd/MM");
        }
    }

    color: "#cdd6f4"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    font.bold: true
}
