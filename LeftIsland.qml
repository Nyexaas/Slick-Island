import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

PanelWindow {
    id: leftWin
    property alias isExpanded: leftPill.expanded
    
    anchors {
        top: true
        left: true
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: leftPill.width + 20
    implicitHeight: leftPill.height + 10
    color: "transparent"

    mask: Region { item: leftPill }

    Process { id: actionProc }

    property string wifiIcon: ""
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wifiProc.running = true
    }
    Process {
        id: wifiProc
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE device 2>/dev/null | grep '^wifi:' | head -n1"]
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (line === "") wifiIcon = "";
                else if (line.includes("connected")) wifiIcon = "";
                else wifiIcon = "睊";
            }
        }
    }

    Rectangle {
        id: leftPill
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 12

        property bool expanded: false
        property bool showWallpapers: false

        width: expanded ? 260 : compactLeftRow.implicitWidth + 24
        height: expanded ? expandedLeftCol.implicitHeight + 24 : 32
        radius: expanded ? 18 : 16
        color: "#11111b"
        border.color: "#313244"
        border.width: 1

        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // 1. Compact view
        RowLayout {
            id: compactLeftRow
            anchors.centerIn: parent
            spacing: 10
            visible: !leftPill.expanded

            Text {
                text: ""
                color: "#89b4fa"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: leftPill.expanded = true
                }
            }

            Text {
                visible: wifiIcon !== ""
                text: wifiIcon
                color: wifiIcon === "" ? "#a6e3a1" : "#f38ba8"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
            }

            Text {
                property var bat: UPower.displayDevice
                visible: bat && bat.isLaptopBattery
                text: bat ? (" " + Math.round(bat.percentage * 100) + "%") : ""
                color: (bat && bat.percentage < 0.2) ? "#f38ba8" : "#cdd6f4"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.bold: true
            }
        }

        // 2. Open view
        ColumnLayout {
            id: expandedLeftCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 10
            visible: leftPill.expanded

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: " System"
                    color: "#89b4fa"
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
                        onClicked: {
                            leftPill.showWallpapers = false;
                            leftPill.expanded = false;
                        }
                    }
                }
            }

            SystemStats {}

            Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: 8
                color: leftPill.showWallpapers ? "#313244" : "#1e1e2e"
                Text {
                    anchors.centerIn: parent
                    text: " Choose a Wallpaper"
                    color: "#cdd6f4"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: leftPill.showWallpapers = !leftPill.showWallpapers
                }
            }

            WallpaperPicker {
                Layout.fillWidth: true
                visible: leftPill.showWallpapers
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true; height: 30; radius: 8; color: "#313244"
                    Text { anchors.centerIn: parent; text: ""; color: "#89b4fa"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { actionProc.command = ["systemctl", "suspend"]; actionProc.running = true; }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 30; radius: 8; color: "#313244"
                    Text { anchors.centerIn: parent; text: ""; color: "#f9e2af"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { actionProc.command = ["systemctl", "reboot"]; actionProc.running = true; }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 30; radius: 8; color: "#313244"
                    Text { anchors.centerIn: parent; text: "⏻"; color: "#f38ba8"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { actionProc.command = ["systemctl", "poweroff"]; actionProc.running = true; }
                    }
                }
            }
        }
    }
}
