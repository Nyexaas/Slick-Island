import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    // 1. Center bubble
    PanelWindow {
        anchors.top: true
        exclusiveZone: 27
        implicitWidth: island.width + 20
        implicitHeight: island.height + 10
        color: "transparent"

        mask: Region { item: island }

        Rectangle {
            id: island
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter

            property bool expanded: false

            // Dynamic size
            width: expanded ? 270 : compactRow.implicitWidth + 28
            height: expanded ? calendarView.implicitHeight + 24 : 32
            radius: expanded ? 18 : 16
            color: "#11111b"
            border.color: "#313244"
            border.width: 1

            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

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

            // Closed view - clock only
            RowLayout {
                id: compactRow
                anchors.centerIn: parent
                visible: !island.expanded

                ClockWidget {
                    id: clockWidget
                }
            }

            // Open view
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

    // 2. Audio bubble
    AudioIsland {
        onToggleMixer: mixerWindow.showMixer = !mixerWindow.showMixer
    }

     // 3. System bubble
    LeftIsland {
        id: leftIsland
    }

     // 4. app launch bubble
    LauncherIsland {
        hiddenByMenu: leftIsland.isExpanded
    }

     // 5. external window mixer
    AudioMixerWindow {
        id: mixerWindow
    }
}
