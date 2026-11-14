import QtQuick
import Quickshell.Services.Pipewire

Text {
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    property var sink: Pipewire.defaultAudioSink
    property bool isMuted: sink && sink.audio ? sink.audio.muted : true
    property int volPercent: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    // Choisit l'icône selon l'état (coupé, faible, moyen, fort)
    property string icon: {
        if (isMuted || volPercent === 0) return "  "; // Haut-parleur barré
        if (volPercent < 30) return "  ";             // Volume faible
        if (volPercent < 70) return "  ";             // Volume moyen
        return "  ";                                  // Volume élevé
    }

    text: isMuted ? (icon + " Muet") : (icon + " " + volPercent + "%")

    // Passe en rouge doux quand le son est coupé, sinon gris clair
    color: isMuted ? "#f38ba8" : "#a6adc8"

    // Transition douce de couleur au clic
    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    font.bold: true
}