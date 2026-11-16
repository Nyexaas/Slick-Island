import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: launcherWin
    property bool hiddenByMenu: false
    property int offsetLeft: 56
    visible: !hiddenByMenu

    anchors {
        top: true
        left: true
    }
    exclusionMode: ExclusionMode.Ignore
    focusable: launcherPill.expanded
    implicitWidth: launcherPill.width + launcherWin.offsetLeft + 15
    implicitHeight: launcherPill.height + 10
    color: "transparent"

    mask: Region { item: launcherPill }

    Rectangle {
        id: launcherPill
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: launcherWin.offsetLeft


        property bool expanded: false

        property var filteredApps: {
            let q = searchInput.text.toLowerCase().trim();
            let all = DesktopEntries.applications.values;
            if (q === "") return all.slice(0, 6);
            return all.filter(app =>
                app.name.toLowerCase().includes(q)
            ).slice(0, 7);
        }

        width: expanded ? 260 : 36
        height: expanded ? expandedLauncherCol.implicitHeight + 24 : 32
        radius: expanded ? 18 : 16
        color: "#11111b"
        border.color: "#313244"
        border.width: 1

        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // 1. VUE COMPACTE (Juste une loupe)
        Text {
            anchors.centerIn: parent
            visible: !launcherPill.expanded
            text: ""
            color: "#cba6f7"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    launcherPill.expanded = true;
                    searchInput.forceActiveFocus();
                }
            }
        }

        // 2. VUE OUVERTE (Recherche + liste compacte)
        ColumnLayout {
            id: expandedLauncherCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 8
            visible: launcherPill.expanded

            // Barre de recherche + bouton fermer
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 26
                    radius: 8
                    color: "#1e1e2e"
                    border.color: "#89b4fa"
                    border.width: 1

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        color: "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        clip: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            text: "Lancer une app..."
                            color: "#6c7086"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            visible: searchInput.text === ""
                        }

                        Keys.onEscapePressed: {
                            searchInput.text = "";
                            launcherPill.expanded = false;
                        }
                        Keys.onReturnPressed: {
                            if (launcherPill.filteredApps.length > 0) {
                                launcherPill.filteredApps.execute();
                                searchInput.text = "";
                                launcherPill.expanded = false;
                            }
                        }
                    }
                }

                Text {
                    text: "✕"
                    color: "#6c7086"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchInput.text = "";
                            launcherPill.expanded = false;
                        }
                    }
                }
            }

            // Liste des applications (icônes verrouillées en 16x16px)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: launcherPill.filteredApps
                    Rectangle {
                        Layout.fillWidth: true
                        height: 26
                        radius: 6
                        color: appHover.containsMouse ? "#313244" : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 8

                            Image {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                Layout.maximumWidth: 16
                                Layout.maximumHeight: 16
                                sourceSize: Qt.size(16, 16)
                                fillMode: Image.PreserveAspectFit
                                source: Quickshell.iconPath(modelData.icon, true)
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: "#cdd6f4"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: appHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.execute();
                                searchInput.text = "";
                                launcherPill.expanded = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
