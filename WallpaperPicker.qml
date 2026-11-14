import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ColumnLayout {
    id: wpRoot
    spacing: 8

    property var wallList: []

    Process { id: applyProc }

    onVisibleChanged: {
        if (visible) {
            scanProc.running = false;
            scanProc.running = true;
        }
    }

    Process {
        id: scanProc
        command: [
            "sh", "-c",
            "find -L \"$HOME/Images/Wallpapers\" -maxdepth 2 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort"
        ]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                let lines = data.trim().split("\n").filter(s => s !== "");
                wpRoot.wallList = lines;
            }
        }
    }

    Text {
        visible: wpRoot.wallList.length === 0
        text: "Aucune image dans ~/Images/Wallpapers"
        color: "#f38ba8"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    Flickable {
        visible: wpRoot.wallList.length > 0
        Layout.fillWidth: true
        Layout.preferredHeight: 160
        contentHeight: grid.implicitHeight
        clip: true

        GridLayout {
            id: grid
            width: parent.width
            columns: 2
            columnSpacing: 6
            rowSpacing: 6

            Repeater {
                model: wpRoot.wallList
                Rectangle {
                    Layout.fillWidth: true
                    height: 58
                    radius: 8
                    color: "#1e1e2e"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: "file://" + modelData
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 160
                        asynchronous: true
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "transparent"
                        border.color: hoverArea.containsMouse ? "#cba6f7" : "#313244"
                        border.width: hoverArea.containsMouse ? 2 : 1
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            applyProc.running = false;
                            applyProc.command = [
                                "sh", "-c",
                                "hyprctl hyprpaper unload all; hyprctl hyprpaper preload \"$1\"; hyprctl hyprpaper wallpaper \"DP-2,$1\"; printf 'wallpaper {\\n\\tmonitor = DP-2\\n\\tpath = %s\\n}\\n\\nsplash = false\\n' \"$1\" > \"$HOME/.config/hypr/hyprpaper.conf\"",
                                "--",
                                modelData
                            ];
                            applyProc.running = true;
                        }
                    }
                }
            }
        }
    }
}
