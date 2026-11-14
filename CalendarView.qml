import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: calRoot
    spacing: 8

    // Signal émis quand on clique sur le bouton fermer
    signal closeRequested()

    property date currentDate: new Date()
    property int displayYear: currentDate.getFullYear()
    property int displayMonth: currentDate.getMonth() // 0 = Janvier, 11 = Décembre

    // Calcule la liste des cases du calendrier (lundi en premier)
    property var daysModel: {
        let firstDay = new Date(displayYear, displayMonth, 1).getDay();
        let offset = (firstDay === 0) ? 6 : firstDay - 1; // Décale pour commencer le Lundi
        let daysInMonth = new Date(displayYear, displayMonth + 1, 0).getDate();

        let cells = [];
        for (let i = 0; i < offset; i++) cells.push(0);
        for (let d = 1; d <= daysInMonth; d++) cells.push(d);
        return cells;
    }

    // En-tête : Mois Année + Navigation + Bouton fermer
    RowLayout {
        Layout.fillWidth: true

        Text {
            text: "<"
            color: "#a6adc8"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (calRoot.displayMonth === 0) {
                        calRoot.displayMonth = 11;
                        calRoot.displayYear--;
                    } else {
                        calRoot.displayMonth--;
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(new Date(calRoot.displayYear, calRoot.displayMonth, 1), "MMMM yyyy")
            color: "#cdd6f4"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            font.capitalization: Font.Capitalize
        }

        Text {
            text: ">"
            color: "#a6adc8"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (calRoot.displayMonth === 11) {
                        calRoot.displayMonth = 0;
                        calRoot.displayYear++;
                    } else {
                        calRoot.displayMonth++;
                    }
                }
            }
        }

        Item { width: 8 }

        Text {
            text: "✕"
            color: "#6c7086"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: calRoot.closeRequested()
            }
        }
    }

    // Jours de la semaine (Lu Ma Me Je Ve Sa Di)
    GridLayout {
        columns: 7
        Layout.fillWidth: true
        columnSpacing: 4

        Repeater {
            model: [ "Lu", "Ma", "Me", "Je", "Ve", "Sa", "Di" ]
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: "#7f849c"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                font.bold: true
            }
        }
    }

    // Grille des numéros du mois
    GridLayout {
        columns: 7
        Layout.fillWidth: true
        columnSpacing: 4
        rowSpacing: 4

        Repeater {
            model: calRoot.daysModel
            Rectangle {
                property bool isToday: modelData === calRoot.currentDate.getDate()
                                    && calRoot.displayMonth === calRoot.currentDate.getMonth()
                                    && calRoot.displayYear === calRoot.currentDate.getFullYear()

                Layout.fillWidth: true
                height: 24
                radius: 6
                color: isToday ? "#cba6f7" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: modelData > 0 ? modelData : ""
                    color: isToday ? "#11111b" : "#cdd6f4"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: isToday
                }
            }
        }
    }
}
