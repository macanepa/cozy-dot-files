import QtQuick 2.15

// =============================================================================
//  Cozy — minimal, elegant SDDM greeter  (clock-centred, two-mode auth)
//
//  SDDM 0.21 can only run ONE PAM conversation at a time (no Windows/GDM-style
//  "password OR finger in parallel"). So we expose TWO explicit modes:
//
//    • FINGER mode (default): the reader is armed -> sddm.login(user,"",sess).
//      Touch the sensor and you're in. With `auth sufficient pam_fprintd.so`
//      first, a single touch authenticates.
//    • PASSWORD mode: type your password and press Enter. Switch into it by
//      clicking "Usar contraseña" OR just by starting to type (the first key
//      flips the mode and is captured into the field). "Usar huella" switches
//      back and re-arms the reader.
//
//  Caveats (inherent to SDDM, not bugs):
//    - Password is still checked AFTER fprintd in the PAM stack, so the password
//      path waits up to the fprintd `timeout` (kept short — see
//      scripts/fingerprint-setup.sh). Touch = instant; password = small wait.
//    - Finger is armed on load, so resting a finger on the sensor (the E14 power
//      button) as the screen appears logs you straight in.
//    - NO auto retry loop: pam_faillock counts each failed empty-password
//      fall-through, so after a finger timeout we wait for a deliberate retry.
//
//  Colours + background come from theme.conf so scripts/sddm-sync.sh can recolour
//  the login screen to match any cozy-dot-files theme.
// =============================================================================
Rectangle {
    id: root

    // ── palette (theme.conf overrides, with safe fallbacks) ──────────────────
    readonly property color cBg:     config.bg     ? config.bg     : "#0E0F11"
    readonly property color cFg:     config.fg     ? config.fg     : "#E8EBEA"
    readonly property color cDim:    config.fgDim  ? config.fgDim  : "#828B89"
    readonly property color cAccent: config.accent ? config.accent : "#A7BCB1"
    readonly property color cField:  config.field  ? config.field  : "#15181A"
    readonly property color cBorder: config.border ? config.border : "#2A2E30"
    readonly property color cBad:    "#C9817E"
    readonly property string uiFont: "JetBrainsMono Nerd Font"

    color: cBg

    // ── state ────────────────────────────────────────────────────────────────
    // autoArm=true: the reader is armed on load, so touching the sensor logs you
    // straight in (a finger resting on the E14 power button as the screen appears
    // will skip the greeter). Set false to require a deliberate tap of the
    // fingerprint icon (or Enter) first — the greeter then always stays visible.
    property bool   autoArm:            true
    property int    sessionIndex:       sessionModel.lastIndex
    property string mode:               "finger"   // "finger" | "password"
    property bool   fingerArmed:        false
    property bool   submittingPassword: false
    property string fingerMsg:          "Toca el sensor para entrar"
    property int    fingerKind:         1          // 0 neutral · 1 armed(pulse) · 2 error
    property string pwMsg:              ""

    function armFinger() {
        if (fingerArmed) return
        fingerArmed = true
        submittingPassword = false
        fingerKind = 1
        fingerMsg = "Toca el sensor para entrar"
        sddm.login(userModel.lastUser, "", root.sessionIndex)
    }
    function enterFingerMode() {
        pwInput.text = ""
        pwMsg = ""
        mode = "finger"
        armFinger()
    }
    function enterPasswordMode() {
        mode = "password"
        pwMsg = ""
        pwInput.forceActiveFocus()
    }
    function submitPassword() {
        if (pwInput.text.length === 0) return
        submittingPassword = true
        fingerArmed = false
        pwMsg = ""
        sddm.login(userModel.lastUser, pwInput.text, root.sessionIndex)
    }

    // ── clock ────────────────────────────────────────────────────────────────
    function refresh() {
        var d = new Date()
        timeText.text = Qt.formatTime(d, "HH:mm")
        var s = d.toLocaleDateString(Qt.locale("es_CL"), "dddd, d 'de' MMMM")
        dateText.text = s.charAt(0).toUpperCase() + s.slice(1)
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.refresh() }

    // ── background: wallpaper + dark gradient scrim ──────────────────────────
    Image {
        anchors.fill: parent
        source: config.background ? config.background : "backgrounds/bg.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(root.cBg.r, root.cBg.g, root.cBg.b, 0.78) }
            GradientStop { position: 0.5; color: Qt.rgba(root.cBg.r, root.cBg.g, root.cBg.b, 0.62) }
            GradientStop { position: 1.0; color: Qt.rgba(root.cBg.r, root.cBg.g, root.cBg.b, 0.86) }
        }
    }

    // ── key catcher: in FINGER mode, typing a printable key flips to PASSWORD
    //    mode and seeds the field; Enter re-arms the reader. ───────────────────
    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: root.mode === "finger"
        Keys.onPressed: function(event) {
            if (root.mode !== "finger") return
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.armFinger(); event.accepted = true; return
            }
            if (event.text.length > 0 && event.text >= " ") {   // printable char
                root.enterPasswordMode()
                pwInput.text = event.text
                pwInput.cursorPosition = pwInput.text.length
                event.accepted = true
            }
        }
    }

    // ── centred column ────────────────────────────────────────────────────────
    Column {
        anchors.centerIn: parent
        spacing: 14

        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cFg
            font { family: root.uiFont; pixelSize: 96; weight: Font.Light }
            text: "00:00"
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cDim
            font { family: root.uiFont; pixelSize: 17 }
            text: ""
        }

        Item { width: 1; height: 26 }   // spacer

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cFg
            font { family: root.uiFont; pixelSize: 20; weight: Font.Medium }
            text: userModel.lastUser
        }

        // ── mode area (fixed height so the column never jumps) ────────────────
        Item {
            width: 340; height: 124
            anchors.horizontalCenter: parent.horizontalCenter

            // FINGER block
            Column {
                anchors.centerIn: parent
                spacing: 12
                opacity: root.mode === "finger" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 180 } }

                Text {
                    id: fpBig
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u{F0237}"                 // nf-md-fingerprint
                    font { family: root.uiFont; pixelSize: 46 }
                    color: root.fingerKind === 2 ? root.cBad
                         : fpArea.containsMouse    ? root.cFg : root.cAccent
                    SequentialAnimation on opacity {
                        running: root.mode === "finger" && root.fingerKind === 1
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.35; duration: 850; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.35; to: 1.0; duration: 850; easing.type: Easing.InOutQuad }
                    }
                    // tap the icon to (re)arm the reader — needed when autoArm is
                    // off, or to retry after a failed/timed-out scan
                    MouseArea {
                        id: fpArea
                        anchors.fill: parent; anchors.margins: -14
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: root.armFinger()
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 320
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: root.fingerMsg
                    font { family: root.uiFont; pixelSize: 13 }
                    color: root.fingerKind === 2 ? root.cBad : root.cDim
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u{F0341}  Usar contraseña"   // lock glyph + label
                    font { family: root.uiFont; pixelSize: 12.5 }
                    color: toPwArea.containsMouse ? root.cFg : root.cAccent
                    Behavior on color { ColorAnimation { duration: 130 } }
                    MouseArea {
                        id: toPwArea
                        anchors.fill: parent; anchors.margins: -8
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: root.enterPasswordMode()
                    }
                }
            }

            // PASSWORD block
            Column {
                anchors.centerIn: parent
                spacing: 12
                opacity: root.mode === "password" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 180 } }

                Rectangle {
                    id: pwBox
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 320; height: 48; radius: 12
                    color: Qt.rgba(root.cField.r, root.cField.g, root.cField.b, 0.78)
                    border.width: 1
                    border.color: pwInput.activeFocus ? root.cAccent : root.cBorder
                    Behavior on border.color { ColorAnimation { duration: 160 } }

                    Text {
                        id: lockIcon
                        anchors.left: parent.left; anchors.leftMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u{F0341}"
                        font { family: root.uiFont; pixelSize: 16 }
                        color: root.cDim
                    }
                    TextInput {
                        id: pwInput
                        anchors {
                            left: lockIcon.right; leftMargin: 12
                            right: arrow.left;    rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        clip: true
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        color: root.cFg
                        font { family: root.uiFont; pixelSize: 18 }
                        selectByMouse: true
                        focus: root.mode === "password"
                        onAccepted: root.submitPassword()
                    }
                    Text {
                        id: arrow
                        anchors.right: parent.right; anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: "→"
                        font { family: root.uiFont; pixelSize: 20 }
                        color: pwInput.text.length > 0 ? root.cAccent : root.cBorder
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.submitPassword() }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.pwMsg
                    visible: root.pwMsg.length > 0
                    font { family: root.uiFont; pixelSize: 12.5 }
                    color: root.cBad
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u{F0237}  Usar huella"        // fingerprint glyph + label
                    font { family: root.uiFont; pixelSize: 12.5 }
                    color: toFpArea.containsMouse ? root.cFg : root.cAccent
                    Behavior on color { ColorAnimation { duration: 130 } }
                    MouseArea {
                        id: toFpArea
                        anchors.fill: parent; anchors.margins: -8
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: root.enterFingerMode()
                    }
                }
            }
        }
    }

    // ── session switcher (discreet, bottom-centre) ────────────────────────────
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 26
        spacing: 16
        visible: sessionModel.count > 1
        Repeater {
            model: sessionModel
            delegate: Text {
                text: model.name
                font { family: root.uiFont; pixelSize: 12 }
                color: index === root.sessionIndex ? root.cAccent : root.cDim
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.sessionIndex = index
                }
            }
        }
    }

    // ── power controls (bottom-right) ─────────────────────────────────────────
    Row {
        anchors.right: parent.right; anchors.rightMargin: 28
        anchors.bottom: parent.bottom; anchors.bottomMargin: 22
        spacing: 22
        Repeater {
            model: [
                { glyph: "\u{F0904}", act: "suspend" },   // md-sleep
                { glyph: "\u{F0709}", act: "reboot"  },   // md-restart
                { glyph: "\u{F0425}", act: "poweroff"}    // md-power
            ]
            delegate: Text {
                text: modelData.glyph
                font { family: root.uiFont; pixelSize: 19 }
                color: pwr.containsMouse ? root.cFg : root.cDim
                Behavior on color { ColorAnimation { duration: 130 } }
                MouseArea {
                    id: pwr
                    anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.act === "suspend")  sddm.suspend()
                        else if (modelData.act === "reboot")  sddm.reboot()
                        else if (modelData.act === "poweroff") sddm.powerOff()
                    }
                }
            }
        }
    }

    // ── PAM / SDDM wiring ─────────────────────────────────────────────────────
    Connections {
        target: sddm
        function onLoginSucceeded() {
            root.fingerMsg = "Bienvenido"
            root.fingerKind = 0
        }
        function onLoginFailed() {
            if (root.submittingPassword) {
                root.submittingPassword = false
                root.pwMsg = "Contraseña incorrecta"
                pwInput.text = ""
                pwInput.forceActiveFocus()
            } else if (root.mode === "finger") {
                // finger attempt failed/timed out — wait for a deliberate retry
                root.fingerArmed = false
                root.fingerKind = 2
                root.fingerMsg = "No se leyó la huella — Enter para reintentar, o escribe tu clave"
            }
            // else: a stale finger transaction resolving after we switched to
            // password mode — ignore it.
        }
        function onInformationMessage(message) {
            if (root.fingerArmed && root.mode === "finger") {
                var m = ("" + message).toLowerCase()
                if (m.indexOf("finger") !== -1 || m.indexOf("swipe") !== -1 || m.indexOf("place") !== -1)
                    root.fingerMsg = "Toca el sensor para entrar"
                else if (m.indexOf("again") !== -1 || m.indexOf("retry") !== -1)
                    root.fingerMsg = "Inténtalo otra vez"
                else
                    root.fingerMsg = message
            }
        }
    }

    Component.onCompleted: {
        refresh()
        if (root.autoArm) {
            // arm once the greeter is fully realised
            armTimer.start()
        } else {
            root.fingerKind = 0
            root.fingerMsg = "Toca el ícono o Enter para usar tu huella"
        }
    }
    Timer { id: armTimer; interval: 650; repeat: false; onTriggered: root.armFinger() }
}
