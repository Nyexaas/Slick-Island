# Slick-Island

# Dynamic Islands for Quickshell (Arch Linux / Hyprland)

A clean, modular, and lightweight Dynamic Island-style desktop shell built with **Quickshell** and **QML** for **Arch Linux** and **Hyprland**.

Designed to stay out of the way while providing instant access to system stats, wallpapers, app launching, calendar, and full PipeWire audio controls.

---

## ✨ Features

* **Left System Island (`LeftIsland.qml`):**
  * Compact Arch Linux pill (automatically displays Wi-Fi and battery icons on laptops).
  * **System Monitor (`SystemStats.qml`):** Real-time CPU, RAM, and GPU usage + temperatures.
  * **Wallpaper Picker (`WallpaperPicker.qml`):** Visual thumbnail grid scanning `~/Images/Wallpapers`, applying wallpapers live via `hyprctl hyprpaper` and saving them automatically to `~/.config/hypr/hyprpaper.conf`.
  * **Power Menu:** Quick Suspend, Reboot, and Poweroff actions.
* **App Launcher Pill (`LauncherIsland.qml`):**
  * Compact search pill next to the system menu (auto-hides when the system menu expands).
  * Native application search using `DesktopEntries` with keyboard navigation (`Enter` to launch, `Esc` to close).
* **Center Clock & Calendar Island (`shell.qml`, `ClockWidget.qml`, `CalendarView.qml`):**
  * **Left-click:** Cycles through 4 time/date formats (`24h`, `12h AM/PM`, `Date`, `Time • Date`).
  * **Right-click:** Expands into an interactive monthly calendar.
* **Right Audio Island & External Mixer (`AudioIsland.qml`, `AudioWidget.qml`, `AudioVisualizer.qml`, `AudioMixerWindow.qml`):**
  * **Live Cava Visualizer:** Automatically appears when audio is playing and hides after 1.5s of silence.
  * **Scroll wheel:** Adjusts master volume (`5%` steps).
  * **Left-click:** Toggles mute with visual feedback.
  * **Right-click:** Opens master volume slider, hardware output switcher (`wpctl`), and a button to open the external per-application **Audio Mixer**.

---

## 📦 Dependencies (Arch Linux)

Install the required packages from the official Arch Linux repositories:

```bash
sudo pacman -S quickshell qt6-declarative pipewire wireplumber cava hyprpaper ttf-jetbrains-mono-nerd
```

---

## 🚀 Installation

1. **Clone this repository into `~/.config/quickshell`:**
   ```bash
   git clone -b Legacy-EN https://github.com/Nyexaas/Slick-Island.git ~/.config/quickshell
   ```

2. **Set up your wallpapers folder:**
   Place your `.jpg`, `.jpeg`, `.png`, or `.webp` wallpapers inside `~/Images/Wallpapers` (or update the path in `WallpaperPicker.qml` and your monitor name in `WallpaperPicker.qml` if not using `DP-2`).

3. **Autostart with Hyprland:**
   Add the following lines to your `~/.config/hypr/hyprland.lua`:
   ```lua
   hypr.exec_once({
       "hyprpaper",
       "qs",
   })
   ```
   *(If you are still using a legacy `.conf` setup, add `exec-once = hyprpaper` and `exec-once = qs` to `hyprland.conf` instead).*

---

/!\ AI HAS BEEN USED
