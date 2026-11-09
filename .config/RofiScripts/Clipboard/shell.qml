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

    property var allItems: []
    property var images: []
    property var texts: []
    property var colors: ({})
    property string activeColumn: "text"
    property int imageIndex: 0
    property int textIndex: 0
    property string pendingDeleteId: ""
    property string errorText: ""
    readonly property string backend: Quickshell.env("CLIPBOARD_MENU_DIR") + "/Clipboard.py"
    readonly property string thumbDir: Quickshell.env("CLIPBOARD_MENU_TMP")

    function color(name, fallback) { return colors[name] || fallback; }

    function filterItems() {
        const query = search.text.toLowerCase().trim();
        const filtered = allItems.filter(item => !query || item.search.indexOf(query) !== -1);
        images = filtered.filter(item => item.image);
        texts = filtered.filter(item => !item.image);
        imageIndex = Math.min(imageIndex, Math.max(0, images.length - 1));
        textIndex = Math.min(textIndex, Math.max(0, texts.length - 1));
        if (activeColumn === "image" && images.length === 0 && texts.length) activeColumn = "text";
        if (activeColumn === "text" && texts.length === 0 && images.length) activeColumn = "image";
    }

    function move(delta) {
        if (activeColumn === "image" && images.length) {
            imageIndex = Math.max(0, Math.min(images.length - 1, imageIndex + delta));
            imageList.positionViewAtIndex(imageIndex, ListView.Contain);
        } else if (activeColumn === "text" && texts.length) {
            textIndex = Math.max(0, Math.min(texts.length - 1, textIndex + delta));
            textList.positionViewAtIndex(textIndex, ListView.Contain);
        }
    }

    function choose(item) {
        if (!item || copyProcess.running) return;
        errorText = "";
        copyProcess.command = ["python3", backend, "copy", item.id];
        copyProcess.running = true;
    }

    function chooseCurrent() {
        choose(activeColumn === "image" ? images[imageIndex] : texts[textIndex]);
    }

    function deleteItem(item) {
        if (!item || copyProcess.running || deleteProcess.running) return;
        errorText = "";
        pendingDeleteId = item.id;
        deleteProcess.command = ["python3", backend, "delete", item.id];
        deleteProcess.running = true;
    }

    function openLauncher() {
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/RofiScripts/Launcher/Launcher.sh"]);
        Qt.quit();
    }

    Process {
        id: loadProcess
        command: ["python3", shell.backend, "list"]
        running: true
        stdout: StdioCollector {
            id: dataCollector
            onStreamFinished: {
                try {
                    const data = JSON.parse(dataCollector.text);
                    shell.colors = data.palette;
                    shell.allItems = data.items;
                    shell.activeColumn = data.items.length && data.items[0].image ? "image" : "text";
                    shell.filterItems();
                } catch (error) {
                    shell.errorText = "Не удалось прочитать историю буфера";
                }
            }
        }
        onExited: function(exitCode) {
            if (exitCode !== 0) shell.errorText = "Не удалось прочитать историю буфера";
        }
    }

    Process {
        id: copyProcess
        onExited: function(exitCode) {
            if (exitCode === 0) Qt.quit();
            else shell.errorText = "Не удалось скопировать запись";
        }
    }

    Process {
        id: deleteProcess
        onExited: function(exitCode) {
            if (exitCode === 0) {
                shell.allItems = shell.allItems.filter(item => item.id !== shell.pendingDeleteId)
                    .map((item, index) => Object.assign({}, item, { order: index + 1 }));
                shell.filterItems();
            } else {
                shell.errorText = "Не удалось удалить запись";
            }
            shell.pendingDeleteId = "";
        }
    }

    PanelWindow {
        id: window
        screen: Quickshell.screens.find(s => Hyprland.monitorFor(s)?.id === Hyprland.focusedMonitor?.id) ?? Quickshell.screens[0]
        implicitWidth: Math.min(1300, screen ? screen.width - 40 : 1300)
        implicitHeight: Math.min(775, screen ? screen.height - 40 : 775)
        color: "transparent"
        WlrLayershell.namespace: "clipboard-menu"
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
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        text: "Буфер обмена"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 20
                        font.bold: true
                        color: shell.color("on-surface", "#e3e2e5")
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "← → столбец   ↑ ↓ выбор   Enter копировать   Esc закрыть"
                        font.pixelSize: 12
                        color: shell.color("on-surface-variant", "#c3c6cf")
                    }
                    Rectangle {
                        width: 76; height: 32; radius: 10
                        color: backMouse.containsMouse ? shell.color("surface-container-highest", "#333537") : shell.color("surface-container", "#1e2022")
                        Text { anchors.centerIn: parent; text: "← Меню"; color: shell.color("on-surface", "#e3e2e5"); font.pixelSize: 12 }
                        MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; onClicked: shell.openLauncher() }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: shell.color("surface-container", "#1e2022")
                    Text { id: searchIcon; x: 14; anchors.verticalCenter: parent.verticalCenter; text: "⌕"; font.pixelSize: 23; color: shell.color("primary", "#aac9f2") }
                    TextInput {
                        id: search
                        anchors.left: searchIcon.right; anchors.right: parent.right
                        anchors.leftMargin: 12; anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        color: shell.color("on-surface", "#e3e2e5")
                        selectionColor: shell.color("primary", "#aac9f2")
                        selectedTextColor: shell.color("on-primary", "#0d3253")
                        font.pixelSize: 15
                        clip: true
                        focus: true
                        onTextChanged: shell.filterItems()
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !search.text
                            text: "Поиск по буферу"
                            color: shell.color("on-surface-variant", "#c3c6cf")
                            font.pixelSize: 15
                        }
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_X && (event.modifiers & Qt.MetaModifier) && (event.modifiers & Qt.ShiftModifier)) { Qt.quit(); event.accepted = true; }
                            else if (event.key === Qt.Key_Escape) { Qt.quit(); event.accepted = true; }
                            else if (event.key === Qt.Key_Up) { shell.move(-1); event.accepted = true; }
                            else if (event.key === Qt.Key_Down) { shell.move(1); event.accepted = true; }
                            else if (event.key === Qt.Key_Left && !(event.modifiers & Qt.ControlModifier)) {
                                if (shell.images.length) shell.activeColumn = "image";
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Right && !(event.modifiers & Qt.ControlModifier)) {
                                if (shell.texts.length) shell.activeColumn = "text";
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                shell.chooseCurrent(); event.accepted = true;
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 16

                    ColumnLayout {
                        Layout.preferredWidth: Math.round(window.width * 0.36)
                        Layout.maximumWidth: Math.round(window.width * 0.36)
                        Layout.minimumWidth: Math.round(window.width * 0.36)
                        Layout.fillHeight: true
                        spacing: 8
                        Text {
                            text: "ИЗОБРАЖЕНИЯ  ·  " + shell.images.length
                            color: shell.color("on-surface-variant", "#c3c6cf")
                            font.pixelSize: 11; font.bold: true; font.letterSpacing: 1
                        }
                        Item {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            Text {
                                anchors.centerIn: parent
                                visible: shell.images.length === 0
                                text: "Нет изображений"
                                color: shell.color("on-surface-variant", "#c3c6cf")
                            }
                            ListView {
                                id: imageList
                                anchors.fill: parent
                                model: shell.images
                                spacing: 8
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                delegate: Rectangle {
                                    id: imageCard
                                    required property var modelData
                                    required property int index
                                    width: imageList.width
                                    height: Math.floor((imageList.height - imageList.spacing) / 2)
                                    radius: 14
                                    color: shell.color("surface-container", "#1e2022")
                                    border.width: shell.activeColumn === "image" && shell.imageIndex === index ? 2 : 1
                                    border.color: shell.activeColumn === "image" && shell.imageIndex === index ? shell.color("primary", "#aac9f2") : shell.color("outline-variant", "#43474e")
                                    clip: true
                                    property bool loaded: false
                                    Image {
                                        anchors.fill: parent; anchors.margins: 6; anchors.bottomMargin: 31
                                        source: imageCard.loaded ? "file://" + shell.thumbDir + "/" + imageCard.modelData.id + ".image" : ""
                                        sourceSize.width: 700; sourceSize.height: 450
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                        cache: false
                                    }
                                    Text {
                                        anchors.left: parent.left; anchors.leftMargin: 12
                                        anchors.bottom: parent.bottom; anchors.bottomMargin: 8
                                        text: "#" + imageCard.modelData.order + "  " + imageCard.modelData.text
                                        color: shell.color("on-surface", "#e3e2e5"); font.pixelSize: 12
                                    }
                                    Rectangle {
                                        visible: imageCard.modelData.order === 1
                                        anchors.right: parent.right; anchors.rightMargin: 9
                                        anchors.bottom: parent.bottom; anchors.bottomMargin: 6
                                        width: lastImage.width + 14; height: 22; radius: 8
                                        color: shell.color("primary", "#aac9f2")
                                        Text { id: lastImage; anchors.centerIn: parent; text: "Последнее"; color: shell.color("on-primary", "#0d3253"); font.pixelSize: 11; font.bold: true }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; hoverEnabled: true
                                        onClicked: { shell.activeColumn = "image"; shell.imageIndex = imageCard.index; shell.choose(imageCard.modelData); }
                                    }
                                    Rectangle {
                                        anchors.top: parent.top; anchors.right: parent.right
                                        anchors.topMargin: 9; anchors.rightMargin: 9
                                        width: 28; height: 28; radius: 8
                                        color: deleteImageMouse.containsMouse ? shell.color("surface-container-highest", "#333537") : shell.color("surface-container-high", "#292a2d")
                                        Text { anchors.centerIn: parent; text: "✕"; color: shell.color("on-surface", "#e3e2e5"); font.pixelSize: 16 }
                                        MouseArea { id: deleteImageMouse; anchors.fill: parent; hoverEnabled: true; onClicked: shell.deleteItem(imageCard.modelData) }
                                        ToolTip.visible: deleteImageMouse.containsMouse
                                        ToolTip.text: "Удалить запись"
                                    }
                                    Process {
                                        command: ["python3", shell.backend, "thumbnail", imageCard.modelData.id]
                                        running: true
                                        onExited: function(exitCode) { imageCard.loaded = exitCode === 0; }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: shell.color("outline-variant", "#43474e") }

                    ColumnLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true; spacing: 8
                        Text {
                            text: "ТЕКСТ  ·  " + shell.texts.length
                            color: shell.color("on-surface-variant", "#c3c6cf")
                            font.pixelSize: 11; font.bold: true; font.letterSpacing: 1
                        }
                        Item {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            Text {
                                anchors.centerIn: parent
                                visible: shell.texts.length === 0
                                text: "Нет текстовых записей"
                                color: shell.color("on-surface-variant", "#c3c6cf")
                            }
                            ListView {
                                id: textList
                                anchors.fill: parent
                                model: shell.texts
                                spacing: 4
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                delegate: Rectangle {
                                    id: textCard
                                    required property var modelData
                                    required property int index
                                    width: textList.width
                                    height: Math.floor((textList.height - textList.spacing * 9) / 10)
                                    radius: 9
                                    color: shell.activeColumn === "text" && shell.textIndex === index ? shell.color("surface-container-highest", "#333537") : shell.color("surface-container", "#1e2022")
                                    border.width: shell.activeColumn === "text" && shell.textIndex === index ? 1 : 0
                                    border.color: shell.color("primary", "#aac9f2")
                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 46; spacing: 10
                                        Text { text: "#" + textCard.modelData.order; color: shell.color("primary", "#aac9f2"); font.pixelSize: 11 }
                                        Text {
                                            Layout.fillWidth: true
                                            text: textCard.modelData.text || "(пусто)"
                                            color: shell.color("on-surface", "#e3e2e5")
                                            font.pixelSize: 13; elide: Text.ElideRight; maximumLineCount: 1
                                        }
                                        Rectangle {
                                            visible: textCard.modelData.order === 1
                                            Layout.preferredWidth: lastText.width + 14; Layout.preferredHeight: 22
                                            radius: 8; color: shell.color("primary", "#aac9f2")
                                            Text { id: lastText; anchors.centerIn: parent; text: "Последнее"; color: shell.color("on-primary", "#0d3253"); font.pixelSize: 11; font.bold: true }
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; hoverEnabled: true
                                        onClicked: { shell.activeColumn = "text"; shell.textIndex = textCard.index; shell.choose(textCard.modelData); }
                                    }
                                    Rectangle {
                                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                        anchors.rightMargin: 9
                                        width: 28; height: 28; radius: 8
                                        color: deleteTextMouse.containsMouse ? shell.color("surface-container-highest", "#333537") : shell.color("surface-container-high", "#292a2d")
                                        Text { anchors.centerIn: parent; text: "✕"; color: shell.color("on-surface", "#e3e2e5"); font.pixelSize: 16 }
                                        MouseArea { id: deleteTextMouse; anchors.fill: parent; hoverEnabled: true; onClicked: shell.deleteItem(textCard.modelData) }
                                        ToolTip.visible: deleteTextMouse.containsMouse
                                        ToolTip.text: "Удалить запись"
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: shell.errorText !== ""
                    text: shell.errorText
                    color: "#ffb4ab"; font.pixelSize: 12
                }
            }
        }
    }
}
