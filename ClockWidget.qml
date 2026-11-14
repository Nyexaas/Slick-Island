import QtQuick
import Quickshell

Text {
    id: clockText

    // 0: Classique (14:27) | 1: Anglais (02:27 PM) | 2: Date | 3: Heure + Date
    property int mode: 0

    // Fonction appelée par le clic gauche de la bulle centrale
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
            case 2: return Qt.locale("fr_FR").toString(clock.date, "ddd dd MMM");
            case 3: return Qt.formatDateTime(clock.date, "HH:mm • dd/MM");
        }
    }

    color: "#cdd6f4"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    font.bold: true
}
