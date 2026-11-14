import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: statsRoot
    spacing: 6

    property string cpuText: "CPU: --%"
    property string ramText: "RAM: --%"
    property string gpuText: "GPU: --"

    // Refresh stats every 2 seconds only when menu is open
    Timer {
        interval: 2000
        running: statsRoot.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }

    Process {
        id: statsProc
        command: [
            "sh", "-c",
            // Retrieve CPU%, Temp CPU, RAM%, and GPU
            "cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2+$4)}'); " +
            "ctemp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print int($1/1000)}'); " +
            "ram=$(free | awk '/Mem:/ {printf \"%d\", $3/$2 * 100}'); " +
            "if command -v nvidia-smi >/dev/null; then " +
            "  gpu=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk -F', ' '{print $1\"% (\"$2\"°C)\"}'); " +
            "else " +
            "  guse=$(cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -n1); " +
            "  gtemp=$(cat /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1 | awk '{print int($1/1000)}'); " +
            "  gpu=\"${guse:-0}% (${gtemp:-?}°C)\"; " +
            "fi; " +
            "echo \"$cpu% (${ctemp:-?}°C)|$ram%|$gpu\""
        ]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("|");
                if (parts.length === 3) {
                    statsRoot.cpuText = " CPU : " + parts[0];
                    statsRoot.ramText = " RAM : " + parts[1];
                    statsRoot.gpuText = " GPU : " + parts[2];
                }
            }
        }
    }

    Text { text: statsRoot.cpuText; color: "#cdd6f4"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
    Text { text: statsRoot.ramText; color: "#cdd6f4"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
    Text { text: statsRoot.gpuText; color: "#cdd6f4"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
}
