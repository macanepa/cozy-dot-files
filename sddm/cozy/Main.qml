import QtQuick 2.15

Rectangle {
    id: root
    color: "#0f1212"

    // --- palette (matches the pywal green/sage theme) ---
    readonly property color fg:          "#b2bebc"
    readonly property color muted:       "#607767"
    readonly property color accent:      "#788E7D"
    readonly property color fieldBg:     "#0f1212"
    readonly property color fieldBorder: "#2c2f30"
    readonly property string uiFont:     "JetBrainsMono Nerd Font"

    // --- background: wallpaper + dark overlay for contrast/elegance ---
    Image {
        anchors.fill: parent
        source: "backgrounds/bg.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle { anchors.fill: parent; color: "#0f1212"; opacity: 0.55 }

    // --- clock ticker ---
    function refresh() {
        var d = new Date()
        timeText.text = Qt.formatTime(d, "HH:mm")
        dateText.text = Qt.formatDate(d, "dddd, d 'de' MMMM")
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.refresh() }

    function doLogin() {
        if (pwInput.text.length === 0) return
        msg.text = ""
        sddm.login(userModel.lastUser, pwInput.text, sessionModel.lastIndex)
    }

    // --- centered column ---
    Column {
        anchors.centerIn: parent
        spacing: 16

        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.fg
            font.pixelSize: 92
            font.family: root.uiFont
            font.weight: Font.Light
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.muted
            font.pixelSize: 18
            font.family: root.uiFont
            text: Qt.formatDate(new Date(), "dddd, d 'de' MMMM")
        }

        Item { width: 1; height: 28 }   // spacer

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.fg
            font.pixelSize: 22
            font.family: root.uiFont
            text: userModel.lastUser
        }

        Rectangle {
            id: pwBox
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300; height: 46; radius: 10
            color: root.fieldBg
            opacity: 0.92
            border.width: 1
            border.color: pwInput.activeFocus ? root.accent : root.fieldBorder

            Item {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 14

                TextInput {
                    id: pwInput
                    anchors.left: parent.left
                    anchors.right: arrow.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 8
                    clip: true
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: root.fg
                    font.pixelSize: 18
                    font.family: root.uiFont
                    selectByMouse: true
                    focus: true
                    onAccepted: root.doLogin()
                }
                Text {
                    id: arrow
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "→"
                    font.pixelSize: 20
                    color: pwInput.text.length > 0 ? root.accent : root.fieldBorder
                    MouseArea { anchors.fill: parent; onClicked: root.doLogin() }
                }
            }
        }

        Text {
            id: msg
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.muted
            font.pixelSize: 13
            font.family: root.uiFont
            text: ""
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            msg.text = "Contraseña incorrecta"
            pwInput.selectAll()
            pwInput.forceActiveFocus()
        }
        function onLoginSucceeded() {
            msg.text = "Bienvenido"
        }
    }

    Component.onCompleted: { root.refresh(); pwInput.forceActiveFocus() }
}
