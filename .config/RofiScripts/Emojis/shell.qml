//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: shell
    readonly property string backend: Quickshell.env("EMOJI_MENU_DIR") + "/Emoji.py"
    property var allItems: []
    property var visibleItems: []
    property var colors: ({})
    property string category: "frequent"
    property int selectedIndex: 0
    property string selectedId: ""
    property string errorText: ""
    readonly property var categories: [
        { key: "frequent", icon: "★", label: "Частые" },
        { key: "smileys", icon: "😀", label: "Смайлы" },
        { key: "people", icon: "👋", label: "Люди" },
        { key: "animals", icon: "🐱", label: "Животные" },
        { key: "nature", icon: "🌸", label: "Природа" },
        { key: "food", icon: "🍕", label: "Еда" },
        { key: "travel", icon: "🚗", label: "Места" },
        { key: "activities", icon: "⚽", label: "Досуг" },
        { key: "objects", icon: "💡", label: "Предметы" },
        { key: "symbols", icon: "✅", label: "Символы" },
        { key: "flags", icon: "🏳️", label: "Флаги" },
        { key: "all", icon: "☷", label: "Все" }
    ]
    function color(key, fallback) { return colors[key] || fallback; }
    function updateItems() {
        const query = search.text.toLowerCase().trim();
        let result = allItems.filter(item => {
            if (query) return (category === "frequent" || category === "all" || item.category === category) && (item.name + " " + item.emoji).toLowerCase().indexOf(query) >= 0;
            return category === "all" || (category === "frequent" ? item.count > 0 : item.category === category);
        });
        if (category === "frequent" || query) result.sort((a, b) => b.count - a.count || Number(a.id) - Number(b.id));
        visibleItems = result;
        selectedIndex = 0;
        grid.positionViewAtBeginning();
    }
    function move(delta) {
        if (!visibleItems.length) return;
        selectedIndex = Math.max(0, Math.min(visibleItems.length - 1, selectedIndex + delta));
        grid.positionViewAtIndex(selectedIndex, GridView.Contain);
    }
    function changeCategory(delta) {
        const current = categories.findIndex(item => item.key === category);
        const next = (current + delta + categories.length) % categories.length;
        category = categories[next].key;
        updateItems();
    }
    function choose(item) {
        if (!item || selectProcess.running) return;
        selectedId = item.id;
        selectProcess.command = ["python3", backend, "select", item.id];
        selectProcess.running = true;
    }
    function openLauncher() {
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/RofiScripts/Launcher/Launcher.sh"]);
        Qt.quit();
    }
    Process {
        command: ["python3", shell.backend, "list"]
        running: true
        stdout: StdioCollector {
            id: dataCollector
            onStreamFinished: {
                try {
                    const data = JSON.parse(dataCollector.text);
                    shell.colors = data.palette;
                    shell.allItems = data.items;
                    shell.updateItems();
                } catch (error) { shell.errorText = "Не удалось загрузить эмодзи"; }
            }
        }
        onExited: function(code) { if (code !== 0) shell.errorText = "Не удалось загрузить эмодзи"; }
    }
    Process {
        id: selectProcess
        onExited: function(code) {
            if (code === 0) {
                Quickshell.execDetached(["python3", shell.backend, "type", shell.selectedId]);
                Qt.quit();
            } else shell.errorText = "Не удалось скопировать эмодзи";
        }
    }
    PanelWindow {
        id: window
        screen: Quickshell.screens.find(s => Hyprland.monitorFor(s)?.id === Hyprland.focusedMonitor?.id) ?? Quickshell.screens[0]
        implicitWidth: Math.min(1000, screen ? screen.width - 40 : 1000)
        implicitHeight: Math.min(700, screen ? screen.height - 40 : 700)
        color: "transparent"
        WlrLayershell.namespace: "emoji-menu"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        Rectangle {
            id: panel
            anchors.fill: parent
            radius: 20
            color: shell.color("surface", "#121316")
            border.width: 1
            border.color: shell.color("outline-variant", "#43474e")
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 12
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Эмодзи"; color: shell.color("on-surface", "#e3e2e5"); font.pixelSize: 20; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Text { text: "Tab категории   ↑ ↓ ← → выбор   Enter вставить   Esc закрыть"; color: shell.color("on-surface-variant", "#c3c6cf"); font.pixelSize: 12 }
                    Rectangle {
                        Layout.preferredWidth: 76; Layout.preferredHeight: 32; radius: 10
                        color: backMouse.containsMouse ? shell.color("surface-container-highest", "#333537") : shell.color("surface-container", "#1e2022")
                        Text { anchors.centerIn: parent; text: "← Меню"; color: shell.color("on-surface", "#e3e2e5"); font.pixelSize: 12 }
                        MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; onClicked: shell.openLauncher() }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 44; radius: 12
                    color: shell.color("surface-container", "#1e2022")
                    Text { id: searchIcon; x: 14; anchors.verticalCenter: parent.verticalCenter; text: "⌕"; font.pixelSize: 23; color: shell.color("primary", "#aac9f2") }
                    TextInput {
                        id: search
                        anchors.left: searchIcon.right; anchors.right: parent.right; anchors.leftMargin: 12; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter
                        color: shell.color("on-surface", "#e3e2e5"); selectionColor: shell.color("primary", "#aac9f2"); selectedTextColor: shell.color("on-primary", "#0d3253")
                        font.pixelSize: 15; clip: true; focus: true
                        onTextChanged: shell.updateItems()
                        Text { anchors.verticalCenter: parent.verticalCenter; visible: !search.text; text: "Поиск по английскому названию"; color: shell.color("on-surface-variant", "#c3c6cf"); font.pixelSize: 15 }
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Escape || (event.key === Qt.Key_X && (event.modifiers & Qt.MetaModifier))) { Qt.quit(); event.accepted = true; }
                            else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Tab) { shell.changeCategory(event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier) ? -1 : 1); event.accepted = true; }
                            else if (event.key === Qt.Key_Up) { shell.move(-grid.columns); event.accepted = true; }
                            else if (event.key === Qt.Key_Down) { shell.move(grid.columns); event.accepted = true; }
                            else if (event.key === Qt.Key_Left && !event.modifiers) { shell.move(-1); event.accepted = true; }
                            else if (event.key === Qt.Key_Right && !event.modifiers) { shell.move(1); event.accepted = true; }
                            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { shell.choose(shell.visibleItems[shell.selectedIndex]); event.accepted = true; }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 4
                    Repeater {
                        model: shell.categories
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true; Layout.preferredHeight: 58; radius: 10
                            color: shell.category === modelData.key ? shell.color("surface-container-highest", "#333537") : (categoryMouse.containsMouse ? shell.color("surface-container", "#1e2022") : "transparent")
                            Column {
                                anchors.centerIn: parent; spacing: 1
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.icon; color: shell.color("primary", "#aac9f2"); font.pixelSize: 22 }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; color: shell.color("on-surface", "#e3e2e5"); font.pixelSize: 10 }
                            }
                            MouseArea { id: categoryMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { shell.category = modelData.key; search.text = ""; shell.updateItems(); search.forceActiveFocus(); } }
                        }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: shell.color("outline-variant", "#43474e") }
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    Text {
                        anchors.centerIn: parent; visible: shell.visibleItems.length === 0
                        text: search.text ? "Ничего не найдено" : "Здесь появятся часто используемые эмодзи"
                        color: shell.color("on-surface-variant", "#c3c6cf"); font.pixelSize: 15
                    }
                    GridView {
                        id: grid
                        anchors.fill: parent; clip: true
                        readonly property int columns: Math.max(5, Math.floor(width / 70))
                        cellWidth: width / columns; cellHeight: 64
                        model: shell.visibleItems
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: grid.cellWidth - 4; height: grid.cellHeight - 4; radius: 10
                            color: shell.selectedIndex === index ? shell.color("surface-container-highest", "#333537") : (emojiMouse.containsMouse ? shell.color("surface-container", "#1e2022") : "transparent")
                            border.width: shell.selectedIndex === index ? 1 : 0
                            border.color: shell.color("primary", "#aac9f2")
                            Text { anchors.centerIn: parent; text: modelData.emoji; font.pixelSize: 29 }
                            MouseArea { id: emojiMouse; anchors.fill: parent; hoverEnabled: true; onEntered: shell.selectedIndex = index; onClicked: shell.choose(modelData) }
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: shell.errorText || (shell.visibleItems.length ? shell.visibleItems[shell.selectedIndex].emoji + "  " + shell.visibleItems[shell.selectedIndex].name : "")
                    color: shell.color("on-surface-variant", "#c3c6cf"); font.pixelSize: 12; elide: Text.ElideRight
                }
            }
        }
    }
}
