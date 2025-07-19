import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

import QtMultimedia

import SddmComponents as SDDM

Pane {
    id: root

    width: 1920
    height: 1080
    padding: 0

    palette.window: "#242455"
    palette.highlight: "#b4d8ff"
    palette.highlightedText: "#000055"
    palette.buttonText: "#fcfcff"

    font.family: "pixelon"
    font.pointSize: 12
    
    focus: true

    Item {
        id: sizeHelper

        width: parent.width
        height: parent.height
        anchors.fill: parent
        
        Rectangle {
            id: tintLayer

            height: parent.height
            width: parent.width
            anchors.fill: parent
            z: 1
            color: "#242455"
            opacity: 0
        }

        Rectangle {
            id: formBackground

            anchors.fill: form
            anchors.centerIn: form
            z: 1

            color: "#242455"
            visible: true
            opacity: 0.3
        }

        ColumnLayout {
            id: form

            SDDM.TextConstants { id: textConstants }

            width: parent.width / 2
            height: parent.height
            anchors.left: parent.left

            z: 1

            // Clock
            Column {
                id: clock

                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.preferredWidth: root.width / 2
                Layout.preferredHeight: root.height / 5
                Layout.leftMargin: 0

                Label {
                    id: time

                    anchors.horizontalCenter: parent.horizontalCenter

                    font.pointSize: root.font.pointSize * 9.25
                    font.bold: true
                    color: "#b4d8ff"
                    renderType: Text.QtRendering

                    function updateTime() {
                        text = new Date().toLocaleTimeString(Qt.locale("id-ID"), "HH:mm:ss")
                    }
                }

                Label {
                    id: date

                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    font.pointSize: root.font.pointSize * 3.25
                    font.bold: true
                    color: "#b4d8ff"
                    renderType: Text.QtRendering

                    function updateDate() {
                        text = new Date().toLocaleDateString(Qt.locale("id-ID"), "dd MMMM yyyy")
                    }
                }

                Timer {
                    interval: 1000
                    repeat: true
                    running: true
                    onTriggered: {
                        time.updateTime()
                        date.updateDate()
                    }
                }

                Component.onCompleted: {
                    date.updateDate()
                    time.updateTime()
                }
            }

            // Input
            Column {
                id: input
                
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.preferredHeight: root.height / 8
                Layout.leftMargin: 0
                Layout.topMargin: 0

                property bool failed

                Item {
                    id: errorMessageField

                    // change also in selectSession
                    width: parent.width / 2
                    height: root.font.pointSize * 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    Label {
                        id: errorMessage

                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        
                        text: input.failed ? `${textConstants.loginFailed}!` : keyboard.capsLock ? textConstants.capslockWarning : null
                        font.pointSize: root.font.pointSize * 1.25
                        font.italic: true
                        color: "#b4d8ff"
                        opacity: 0
                        
                        states: [
                            State {
                                name: "fail"
                                when: input.failed
                                PropertyChanges {
                                    errorMessage.opacity: 1
                                }
                            },
                            State {
                                name: "capslock"
                                when: keyboard.capsLock
                                PropertyChanges {
                                    errorMessage.opacity: 1
                                }
                            }
                        ]
                        transitions: [
                            Transition {
                                PropertyAnimation {
                                    properties: "opacity"
                                    duration: 100
                                }
                            }
                        ]
                    }
                }

                Item {
                    id: usernameField

                    width: parent.width / 2
                    height: root.font.pointSize * 4.5
                    anchors.horizontalCenter: parent.horizontalCenter

                    ComboBox {
                        id: selectUser

                        width: parent.height
                        height: parent.height
                        anchors.left: parent.left
                        z: 2

                        model: userModel
                        currentIndex: model.lastIndex
                        textRole: "name"
                        hoverEnabled: true
                        onActivated: {
                            username.text = currentText
                        }

                        Keys.onPressed: function(event) {
                            if (event.key == Qt.Key_Down && !popup.opened)
                                username.forceActiveFocus();
                            if ((event.key == Qt.Key_Up || event.key == Qt.Key_Left) && !popup.opened)
                                popup.open();
                        }

                        KeyNavigation.down: username
                        KeyNavigation.right: username

                        delegate: ItemDelegate {
                            //  minus padding
                            width: usernamePopup.width - 20
                            anchors.horizontalCenter: usernamePopup.horizontalCenter
                            
                            contentItem: Text {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter

                                text: model.name
                                font.pointSize: root.font.pointSize * 1.25
                                font.capitalization: Font.AllLowercase
                                font.family: root.font.family
                                color: "#000055"
                            }
                            
                            background: Rectangle {
                                color: selectUser.highlightedIndex === index ? "#b4d8ff" : "transparent"
                            }
                        }

                        indicator: Button {
                            id: usernameIcon
                                
                            width: selectUser.height * 1
                            height: parent.height

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: selectUser.height * 0
                            
                            icon.height: parent.height * 0.25
                            icon.width: parent.height * 0.25
                            enabled: false
                            icon.color: "#b4d8ff"
                            icon.source: Qt.resolvedUrl("Assets/User.svg")
                                
                            background: Rectangle {
                                color: "transparent"
                                border.color: "transparent"
                            }
                        }

                        background: Rectangle {
                            color: "transparent"
                            border.color: "transparent"
                        }

                        popup: Popup {
                            id: usernamePopup

                            implicitHeight: contentItem.implicitHeight
                            width: usernameField.width
                            x: 0
                            y: parent.height - username.height / 3
                            padding: 10

                            contentItem: ListView {
                                implicitHeight: contentHeight + 20
                                
                                clip: true
                                model: selectUser.popup.visible ? selectUser.delegateModel : null
                                currentIndex: selectUser.highlightedIndex
                                ScrollIndicator.vertical: ScrollIndicator { }
                            }

                            background: Rectangle {
                                radius: 10
                                color: "#90b4ff"
                                layer.enabled: true
                            }

                            enter: Transition {
                                NumberAnimation { property: "opacity"; from: 0; to: 1 }
                            }
                        }

                        states: [
                            State {
                                name: "pressed"
                                when: selectUser.down
                                PropertyChanges {
                                    usernameIcon.icon.color: Qt.lighter("#fcfcff", 1.1)
                                }
                            },
                            State {
                                name: "hovered"
                                when: selectUser.hovered
                                PropertyChanges {
                                    usernameIcon.icon.color: Qt.lighter("#fcfcff", 1.2)
                                }
                            },
                            State {
                                name: "focused"
                                when: selectUser.activeFocus
                                PropertyChanges {
                                    usernameIcon.icon.color: "#fcfcff"
                                }
                            }
                        ]
                        transitions: [
                            Transition {
                                PropertyAnimation {
                                    properties: "color, border.color, icon.color"
                                    duration: 150
                                }
                            }
                        ]
                    }

                    TextField {
                        id: username

                        anchors.centerIn: parent
                        width: parent.width
                        height: root.font.pointSize * 3
                        horizontalAlignment: TextInput.AlignHCenter
                        z: 1

                        text: selectUser.currentText
                        color: "#b4d8ff"
                        font.bold: true
                        font.capitalization: Font.AllLowercase
                        placeholderText: textConstants.userName
                        placeholderTextColor: "#bbbbbb"
                        selectByMouse: true
                        renderType: Text.QtRendering
                        
                        onFocusChanged:{
                            if(focus) {
                                selectAll()
                            }
                        }

                        background: Rectangle {
                            color: "#111111"
                            opacity: 0.2
                            border.color: "transparent"
                            border.width: parent.activeFocus ? 2 : 1
                            radius: 20
                        }
                        
                        onAccepted: sddm.login(username.text.toLowerCase(), password.text, sessionButton.selectedSession)
                        KeyNavigation.down: passwordIcon

                        states: [
                            State {
                                name: "focused"
                                when: username.activeFocus
                                PropertyChanges {
                                    target: username.background
                                    border.color: "transparent"
                                }
                                PropertyChanges {
                                    username.color: Qt.lighter("#b4d8ff", 1.15)
                                }
                            }
                        ]
                    }
                }
                
                Item {
                    id: passwordField

                    width: parent.width / 2
                    height: root.font.pointSize * 4.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Button {
                        id: passwordIcon
                        
                        width: selectUser.height * 1
                        height: parent.height
                        anchors.left: parent.left
                        anchors.leftMargin: selectUser.height * 0
                        anchors.verticalCenter: parent.verticalCenter
                        z: 2
                        
                        icon.height: parent.height * 0.25
                        icon.width: parent.height * 0.25
                        icon.color: "#b4d8ff"
                        icon.source: Qt.resolvedUrl("Assets/Password2.svg")

                        background: Rectangle {
                            color: "transparent"
                            border.color: "transparent"
                        }

                        states: [
                            State {
                                name: "visiblePasswordFocused"
                                when: passwordIcon.checked && passwordIcon.activeFocus
                                PropertyChanges {
                                    passwordIcon.icon.source: Qt.resolvedUrl("Assets/Password.svg")
                                    passwordIcon.icon.color: "#fcfcff"
                                }
                            },
                            State {
                                name: "visiblePasswordHovered"
                                when: passwordIcon.checked && passwordIcon.hovered
                                PropertyChanges {
                                    passwordIcon.icon.source: Qt.resolvedUrl("Assets/Password.svg")
                                    passwordIcon.icon.color: "#fcfcff"
                                }
                            },
                            State {
                                name: "visiblePassword"
                                when: passwordIcon.checked
                                PropertyChanges {
                                    passwordIcon.icon.source: Qt.resolvedUrl("Assets/Password.svg")
                                }
                            },
                            State {
                                name: "hiddenPasswordFocused"
                                when:  passwordIcon.enabled && passwordIcon.activeFocus
                                PropertyChanges {
                                    passwordIcon.icon.source: Qt.resolvedUrl("Assets/Password2.svg")
                                    passwordIcon.icon.color: "#fcfcff"
                                }
                            },
                            State {
                                name: "hiddenPasswordHovered"
                                when: passwordIcon.hovered
                                PropertyChanges {
                                    passwordIcon.icon.source: Qt.resolvedUrl("Assets/Password2.svg")
                                    passwordIcon.icon.color: "#fcfcff"
                                }
                            }
                        ]

                        onClicked: toggle()
                        Keys.onReturnPressed: toggle()
                        Keys.onEnterPressed: toggle()

                        KeyNavigation.down: password
                    }

                    TextField {
                        id: password

                        width: parent.width
                        height: root.font.pointSize * 3
                        anchors.centerIn: parent
                        horizontalAlignment: TextInput.AlignHCenter
                        
                        font.bold: true
                        color: "#b4d8ff"
                        focus: true
                        echoMode: passwordIcon.checked ? TextInput.Normal : TextInput.Password
                        placeholderText: textConstants.password
                        placeholderTextColor: "#bbbbbb"
                        passwordCharacter: "•"
                        passwordMaskDelay: 0
                        renderType: Text.QtRendering
                        selectByMouse: true
                        
                        background: Rectangle {
                            color: "#111111"
                            opacity: 0.2
                            border.color: "transparent"
                            border.width: parent.activeFocus ? 2 : 1
                            radius: 20
                        }

                        onAccepted: sddm.login(username.text.toLowerCase(), password.text, sessionButton.selectedSession)
                        
                        KeyNavigation.down: loginButton
                    }

                    states: [
                        State {
                            name: "focused"
                            when: password.activeFocus
                            PropertyChanges {
                                target: password.background
                                border.color: "transparent"
                            }
                            PropertyChanges {
                                password.color: Qt.lighter("#b4d8ff", 1.15)
                            }
                        }
                    ]
                    transitions: [
                        Transition {
                            PropertyAnimation {
                                properties: "color, border.color"
                                duration: 150
                            }
                        }
                    ]        
                }

                Item {
                    id: login

                    width: parent.width / 2
                    height: root.font.pointSize * 4.5
                    anchors.horizontalCenter: parent.horizontalCenter

                    visible: true
                    
                    Button {
                        id: loginButton

                        height: root.font.pointSize * 3
                        implicitWidth: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        
                        text: textConstants.login
                        enabled: username.text != "" && password.text != "" ? true : false
                        hoverEnabled: true

                        contentItem: Text {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            font.bold: true
                            font.pointSize: root.font.pointSize
                            font.family: root.font.family
                            color: "#000055"
                            text: parent.text
                            opacity: 0.5
                        }

                        background: Rectangle {
                            id: buttonBackground

                            color: "#b4d8ff"
                            opacity: 0.2
                            radius: 20
                        }

                        states: [
                            State {
                                name: "pressed"
                                when: loginButton.down
                                PropertyChanges {
                                    buttonBackground.color: Qt.darker("#b4d8ff", 1.1)
                                    buttonBackground.opacity: 1
                                }
                                PropertyChanges {
                                    target: loginButton.contentItem
                                }
                            },
                            State {
                                name: "hovered"
                                when: loginButton.hovered
                                PropertyChanges {
                                    buttonBackground.color: Qt.lighter("#b4d8ff", 1.15)
                                    buttonBackground.opacity: 1
                                }
                                PropertyChanges {
                                    loginButton.contentItem.opacity: 1
                                }
                            },
                            State {
                                name: "focused"
                                when: loginButton.activeFocus
                                PropertyChanges {
                                    buttonBackground.color: Qt.lighter("#b4d8ff", 1.2)
                                    buttonBackground.opacity: 1
                                }
                                PropertyChanges {
                                    target: loginButton.contentItem
                                    opacity: 1
                                }
                            },
                            State {
                                name: "enabled"
                                when: loginButton.enabled
                                PropertyChanges {
                                    buttonBackground.color: "#b4d8ff"
                                    buttonBackground.opacity: 1
                                }
                                PropertyChanges {
                                    target: loginButton.contentItem;
                                    opacity: 1
                                }
                            }
                        ]
                        transitions: [
                            Transition {
                                PropertyAnimation {
                                    properties: "opacity, color";
                                    duration: 300
                                }
                            }
                        ]

                        onClicked: sddm.login(username.text.toLowerCase(), password.text, sessionButton.selectedSession)
                        Keys.onReturnPressed: clicked()
                        Keys.onEnterPressed: clicked()
                        
                        KeyNavigation.down: systemButtons.children[0]
                    }
                }

                Connections {
                    target: sddm
                    function onLoginSucceeded() {}
                    function onLoginFailed() {
                        input.failed = true
                        resetError.running ? resetError.stop() && resetError.start() : resetError.start()
                    }
                }

                Timer {
                    id: resetError
                    interval: 2000
                    onTriggered: input.failed = false
                    running: false
                }
            }

            // System buttons
            RowLayout {
                id: systemButtons

                spacing: root.font.pointSize

                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.preferredHeight: root.height / 10
                Layout.maximumHeight: root.height / 10
                Layout.leftMargin: 0

                property var reboot: ["Reboot", textConstants.reboot, sddm.canReboot]
                property var shutdown: ["Shutdown", textConstants.shutdown, sddm.canPowerOff]

                Repeater {
                    id: buttons

                    model: [systemButtons.reboot, systemButtons.shutdown]

                    RoundButton {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.topMargin: root.font.pointSize * 6.5

                        palette.buttonText: "#b4d8ff"
                        display: AbstractButton.TextUnderIcon
                        visible: true
                        hoverEnabled: true

                        text: modelData[1]
                        font.pointSize: root.font.pointSize * 1.25
                        
                        icon.source: modelData ? Qt.resolvedUrl("Assets/" + modelData[0] + ".svg") : ""
                        icon.height: 2 * Math.round((root.font.pointSize * 3) / 2)
                        icon.width: 2 * Math.round((root.font.pointSize * 3) / 2)
                        icon.color: "#b4d8ff"
                        
                        background: Rectangle {
                            height: 2
                            width: parent.width

                            color: "transparent"
                        }

                        Keys.onReturnPressed: clicked()
                        onClicked: {
                            parent.forceActiveFocus()
                            index == 0 ? sddm.reboot() : sddm.powerOff()
                        }
                        KeyNavigation.left: index > 0 ? parent.children[index-1] : null
                        
                        states: [
                            State {
                                name: "pressed"
                                when: parent.children[index].down
                                PropertyChanges {
                                    target: parent.children[index]
                                    icon.color: root.palette.buttonText
                                    palette.buttonText: Qt.darker(root.palette.buttonText, 1.1)
                                }
                            },
                            State {
                                name: "hovered"
                                when: parent.children[index].hovered
                                PropertyChanges {
                                    target: parent.children[index]
                                    icon.color: root.palette.buttonText
                                    palette.buttonText: Qt.lighter(root.palette.buttonText, 1.1)
                                }
                            },
                            State {
                                name: "focused"
                                when: parent.children[index].activeFocus
                                PropertyChanges {
                                    target: parent.children[index]
                                    icon.color: root.palette.buttonText
                                    palette.buttonText: root.palette.buttonText
                                }
                            }
                        ]
                        transitions: [
                            Transition {
                                PropertyAnimation {
                                    properties: "palette.buttonText, border.color"
                                    duration: 150
                                }
                            }
                        ]
                    }
                }
            }

            // Select Session
            Item {
                id: sessionButton

                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.preferredHeight: root.height / 18
                Layout.maximumHeight: root.height / 18
                Layout.leftMargin: 0
                
                property var selectedSession: selectSession.currentIndex

                ComboBox {
                    id: selectSession

                    // important
                    // change also in errorMessage
                    height: root.font.pointSize * 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    hoverEnabled: true
                    model: sessionModel
                    currentIndex: model.lastIndex
                    textRole: "name"
                    
                    Keys.onPressed: (event) => {
                        if ((event.key == Qt.Key_Left || event.key == Qt.Key_Right) && !popup.visible) {
                            popup.open();
                        }
                    }

                    delegate: ItemDelegate {
                        // minus padding
                        width: sessionPopup.width - 20
                        anchors.horizontalCenter: sessionPopup.horizontalCenter
                        
                        contentItem: Text {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            text: model.name
                            font.pointSize: root.font.pointSize * 0.8
                            font.family: root.font.family
                            color: "#000055"
                        }
                        
                        background: Rectangle {
                            color: selectSession.highlightedIndex === index ? "#b4d8ff" : "transparent"
                        }
                    }

                    indicator {
                        visible: false
                    }

                    contentItem: Text {
                        id: displayedItem

                        verticalAlignment: Text.AlignVCenter
                        
                        text: `Session is ${selectSession.currentText}`
                        color: "#b4d8ff"
                        font.pointSize: root.font.pointSize
                        font.family: root.font.family

                        Keys.onReleased: selectSession.popup.open()
                    }

                    background: Rectangle {
                        height: parent.visualFocus ? 2 : 0
                        width: displayedItem.implicitWidth

                        color: "transparent"
                    }

                    popup: Popup {
                        id: sessionPopup

                        width: sessionButton.width
                        implicitHeight: contentItem.implicitHeight
                        x:  -sessionPopup.width/2 + displayedItem.width/2
                        y: parent.height - 1
                        
                        padding: 10

                        contentItem: ListView {
                            implicitHeight: contentHeight + 20

                            clip: true
                            model: selectSession.popup.visible ? selectSession.delegateModel : null
                            currentIndex: selectSession.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            radius: 10
                            color: "#90b4ff"
                            layer.enabled: true
                        }

                        enter: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1 }
                        }
                    }

                    states: [
                        State {
                            name: "pressed"
                            when: selectSession.down
                            PropertyChanges {
                                displayedItem.color: Qt.darker("#fcfcff", 1.1)
                            }
                        },
                        State {
                            name: "hovered"
                            when: selectSession.hovered
                            PropertyChanges {
                                displayedItem.color: Qt.lighter("#fcfcff", 1.1)
                            }
                        },
                        State {
                            name: "focused"
                            when: selectSession.visualFocus
                            PropertyChanges {
                                displayedItem.color: "#fcfcff"
                            }
                        }
                    ]
                    transitions: [
                        Transition {
                            PropertyAnimation {
                                properties: "color"
                                duration: 150
                            }
                        }
                    ]
                }
            }
        }
        
        Image {
            id: backgroundPlaceholderImage

            z: 10
            source: config.BackgroundPlaceholder
            visible: false
        }

        AnimatedImage {
            id: backgroundImage
            
            MediaPlayer {
                id: player
                
                videoOutput: videoOutput
                autoPlay: true
                playbackRate: 1.0
                loops: -1
                onPlayingChanged: {
                    backgroundPlaceholderImage.visible = false;
                }
            }

            VideoOutput {
                id: videoOutput
                
                fillMode: VideoOutput.PreserveAspectCrop
                anchors.fill: parent
            }

            width: parent.width
            height: parent.height

            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter

            speed: 1.0
            paused: false
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            clip: true
            mipmap: true

            Component.onCompleted: {
                backgroundPlaceholderImage.visible = true;
                player.source = Qt.resolvedUrl(config.Background)
                player.play();
            }
        }

        MouseArea {
            anchors.fill: backgroundImage
            onClicked: parent.forceActiveFocus()
        }

        ShaderEffectSource {
            id: blurMask

            height: parent.height
            width: form.width
            anchors.centerIn: form

            sourceItem: backgroundImage
            sourceRect: Qt.rect(x, y, width, height)
            visible: true
        }

        MultiEffect {
            id: blur
            
            width: form.width
            height: parent.height
            anchors.centerIn: form

            source: blurMask
            blurEnabled: true
            autoPaddingEnabled: false
            blur: 2
            blurMax: 8
            visible: true
        }
    }
}