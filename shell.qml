import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    // 1. Pilule centrale
    PanelWindow {
        anchors.top: true
        exclusiveZone: 27
        implicitWidth: island.width + 20
        implicitHeight: island.height + 10
        color: "transparent"

        // Laisse passer les clics dans la fine marge transparente autour de la pilule
        mask: Region { item: island }

        Rectangle {
            id: island
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter

            property bool expanded: false

            // Taille dynamique : compacte (ajustée à l'heure) ou étendue (ajustée au calendrier)
            width: expanded ? 270 : compactRow.implicitWidth + 28
            height: expanded ? calendarView.implicitHeight + 24 : 32
            radius: expanded ? 18 : 16
            color: "#11111b"
            border.color: "#313244"
            border.width: 1

            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            // Un seul MouseArea pour gérer clic gauche (format) et clic droit (calendrier)
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        island.expanded = !island.expanded;
                    } else if (mouse.button === Qt.LeftButton && !island.expanded) {
                        clockWidget.nextMode();
                    }
                }
            }

            // Vue fermée : uniquement l'horloge
            RowLayout {
                id: compactRow
                anchors.centerIn: parent
                visible: !island.expanded

                ClockWidget {
                    id: clockWidget
                }
            }

            // Vue ouverte : le calendrier (au même niveau que compactRow, pas dedans)
            CalendarView {
                id: calendarView
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 12
                visible: island.expanded
                onCloseRequested: island.expanded = false
            }
        }
    }

    // 2. Pilule audio en haut à droite (au même niveau que PanelWindow dans ShellRoot)
    AudioIsland {
        onToggleMixer: mixerWindow.showMixer = !mixerWindow.showMixer
    }

     // 3. Pilule système & tray en haut à gauche
    LeftIsland {
        id: leftIsland
    }

     // 4. Mini-bulle loupe (Lanceur d'applications)
    LauncherIsland {
        hiddenByMenu: leftIsland.isExpanded
    }

     // 5. Fenêtre externe du mélangeur audio
    AudioMixerWindow {
        id: mixerWindow
    }
}
