import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

PanelWindow {
    id: mixerWin
    // only shows when showMixer is true
    visible: showMixer
    property bool showMixer: false

    anchors {
        top: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 320
    implicitHeight: mixerBox.height + 60
    color: "transparent"

    mask: Region { item: mixerBox }

    Rectangle {
        id: mixerBox
        anchors.top: parent.top
        anchors.topMargin: 48
        anchors.right: parent.right
        anchors.rightMargin: 12

        width: 300
        height: Math.min(360, mixerCol.implicitHeight + 24)
        radius: 18
        color: "#11111b"
        border.color: "#313244"
        border.width: 1

        ColumnLayout {
            id: mixerCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 10

            // head + close button
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "  Auudio Mixer"
                    color: "#cba6f7"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"
                    color: "#6c7086"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mixerWin.showMixer = false
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

            // Flickable Zone for app list
            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(280, appsCol.implicitHeight)
                contentHeight: appsCol.implicitHeight
                clip: true

                ColumnLayout {
                    id: appsCol
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: Pipewire.nodes
                        delegate: ColumnLayout {
                            PwObjectTracker { objects: [ modelData ] }

                            property bool isAppStream: modelData.isStream && modelData.isSink
                            visible: isAppStream
                            Layout.fillWidth: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                visible: isAppStream

                                Text {
                                    Layout.fillWidth: true
                                    property string appName: modelData.properties["application.name"] || modelData.description || modelData.name
                                    text: (modelData.audio && modelData.audio.muted ? "   " : "   ") + appName
                                    color: (modelData.audio && modelData.audio.muted) ? "#f38ba8" : "#cdd6f4"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.audio) modelData.audio.muted = !modelData.audio.muted;
                                        }
                                    }
                                }

                                Text {
                                    text: modelData.audio ? Math.round(modelData.audio.volume * 100) + "%" : ""
                                    color: "#a6adc8"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: isAppStream ? 7 : 0
                                visible: isAppStream
                                radius: 3.5
                                color: "#313244"

                                Rectangle {
                                    width: modelData.audio ? parent.width * Math.min(1, modelData.audio.volume) : 0
                                    height: parent.height
                                    radius: 3.5
                                    color: (modelData.audio && modelData.audio.muted) ? "#f38ba8" : "#89b4fa"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    function setAppVol(mouseX) {
                                        if (modelData.audio) {
                                            modelData.audio.volume = Math.max(0, Math.min(1, mouseX / width));
                                        }
                                    }
                                    onPressed: (mouse) => setAppVol(mouse.x)
                                    onPositionChanged: (mouse) => { if (pressed) setAppVol(mouse.x); }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
