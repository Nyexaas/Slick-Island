import QtQuick
import Quickshell.Hyprland

Text {
    text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Bureau"
    color: "#cdd6f4"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
    elide: Text.ElideRight
    horizontalAlignment: Text.AlignHCenter
}
