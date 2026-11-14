import QtQuick
import Quickshell.Io

Row {
    id: root
    spacing: 2
    height: 16
    anchors.verticalCenter: parent.verticalCenter

    // Masque complètement le widget (et libère l'espace dans la pilule) quand il n'y a pas de son
    visible: hasAudio

    property bool hasAudio: false
    property var bars:

    // Attend 1.5s de silence complet avant de cacher les barres
    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.hasAudio = false
    }

    Process {
        id: cavaProc
        running: true
        command: [
            "sh", "-c",
            "printf '[general]\\nbars = 6\\nframerate = 60\\n[output]\\nmethod = raw\\nraw_target = /dev/stdout\\ndata_format = ascii\\nascii_max_range = 100\\n' | cava -p /dev/stdin"
        ]

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(";").filter(s => s !== "");
                if (parts.length === 6) {
                    let values = parts.map(Number);
                    root.bars = values;

                    // Vérifie si au moins une barre bouge (seuil > 1 pour ignorer le bruit de fond)
                    let active = values.some(v => v > 1);
                    if (active) {
                        hideTimer.stop();
                        root.hasAudio = true;
                    } else if (root.hasAudio && !hideTimer.running) {
                        hideTimer.start();
                    }
                }
            }
        }
    }

    Repeater {
        model: root.bars
        Rectangle {
            width: 2.5
            height: Math.max(3, (modelData / 100) * 16)
            radius: 1.5
            color: "#cba6f7"
            anchors.bottom: parent.bottom

            Behavior on height {
                NumberAnimation { duration: 60 }
            }
        }
    }
}
