import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

PanelWindow {
    id: audioWin
    anchors {
        top: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: audioPill.width + 20
    implicitHeight: audioPill.height + 10
    color: "transparent"

    mask: Region { item: audioPill }

    // Signal pour ouvrir/fermer la fenêtre externe du mélangeur
    signal toggleMixer()

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Process {
        id: switchSinkProc
    }

    Rectangle {
        id: audioPill
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 12

        property bool expanded: false
        property var sink: Pipewire.defaultAudioSink
        property bool isMuted: sink && sink.audio ? sink.audio.muted : false

        width: expanded ? 280 : audioRow.implicitWidth + 24
        height: expanded ? expandedContent.implicitHeight + 24 : 32
        radius: expanded ? 18 : 16
        color: "#11111b"
        border.color: isMuted ? "#f38ba8" : "#313244"
        border.width: 1

        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onWheel: (wheel) => {
                if (audioPill.sink && audioPill.sink.audio) {
                    var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                    audioPill.sink.audio.volume = Math.max(0, Math.min(1, audioPill.sink.audio.volume + step));
                }
            }
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    audioPill.expanded = !audioPill.expanded;
                } else if (mouse.button === Qt.LeftButton && !audioPill.expanded) {
                    if (audioPill.sink && audioPill.sink.audio) {
                        audioPill.sink.audio.muted = !audioPill.sink.audio.muted;
                    }
                }
            }
        }

        // 1. VUE COMPACTE
        RowLayout {
            id: audioRow
            anchors.centerIn: parent
            spacing: 10
            visible: !audioPill.expanded

            AudioVisualizer {}
            AudioWidget {}
        }

        // 2. VUE CONTRÔLE AUDIO (Compacte : Volume + Sorties + Bouton Mélangeur)
        ColumnLayout {
            id: expandedContent
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 10
            visible: audioPill.expanded

            RowLayout {
                Layout.fillWidth: true
                AudioWidget {}
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"
                    color: "#6c7086"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audioPill.expanded = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                radius: 4
                color: "#313244"

                Rectangle {
                    width: audioPill.sink && audioPill.sink.audio
                           ? parent.width * Math.min(1, audioPill.sink.audio.volume) : 0
                    height: parent.height
                    radius: 4
                    color: audioPill.isMuted ? "#f38ba8" : "#cba6f7"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function updateVol(mouseX) {
                        if (audioPill.sink && audioPill.sink.audio) {
                            audioPill.sink.audio.volume = Math.max(0, Math.min(1, mouseX / width));
                        }
                    }
                    onPressed: (mouse) => updateVol(mouse.x)
                    onPositionChanged: (mouse) => { if (pressed) updateVol(mouse.x); }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

            // Sorties matérielles
            Repeater {
                model: Pipewire.nodes
                delegate: Rectangle {
                    PwObjectTracker { objects: [ modelData ] }

                    property bool isAudioSink: modelData.isSink && !modelData.isStream
                    visible: isAudioSink
                    Layout.fillWidth: true
                    height: isAudioSink ? 24 : 0
                    radius: 8
                    color: modelData === Pipewire.defaultAudioSink ? "#313244" : "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        text: (modelData === Pipewire.defaultAudioSink ? "   " : "  ")
                              + (modelData.nickname || modelData.description || modelData.name)
                        color: modelData === Pipewire.defaultAudioSink ? "#cdd6f4" : "#a6adc8"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            switchSinkProc.command = [ "wpctl", "set-default", String(modelData.id) ];
                            switchSinkProc.running = true;
                        }
                    }
                }
            }

            // Bouton pour ouvrir le Mélangeur externe
            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: 8
                color: "#1e1e2e"
                Text {
                    anchors.centerIn: parent
                    text: "   Mélangeur par app"
                    color: "#89b4fa"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        audioPill.expanded = false;
                        audioWin.toggleMixer();
                    }
                }
            }
        }
    }
}
