import QtQuick
import QtQuick.Layouts
import Quickshell

ColumnLayout {
    id: launcherRoot
    spacing: 6

    signal appLaunched()

    // app filter
    property var filteredApps: {
        let q = searchInput.text.toLowerCase().trim();
        let all = DesktopEntries.applications.values;
        if (q === "") return all.slice(0, 6); // Affiche les 6 premières par défaut
        return all.filter(app =>
            app.name.toLowerCase().includes(q) ||
            (app.comment && app.comment.toLowerCase().includes(q))
        ).slice(0, 8);
    }

    // research bar
    Rectangle {
        Layout.fillWidth: true
        height: 28
        radius: 8
        color: "#1e1e2e"
        border.color: searchInput.activeFocus ? "#89b4fa" : "#313244"
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
                verticalAlignment: Text.AlignVCenter
                text: " Researching app..."
                color: "#6c7086"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                visible: searchInput.text === ""
            }

            // Open the first ass found with enter is pressed
            Keys.onReturnPressed: {
                if (launcherRoot.filteredApps.length > 0) {
                    launcherRoot.filteredApps.execute();
                    searchInput.text = "";
                    launcherRoot.appLaunched();
                }
            }
        }
    }

    // app list
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Repeater {
            model: launcherRoot.filteredApps
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
                        width: 16
                        height: 16
                        source: Quickshell.iconPath(modelData.icon, true)
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
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
                        launcherRoot.appLaunched();
                    }
                }
            }
        }
    }
}
