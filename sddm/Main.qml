import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: root
    width: 640
    height: 480

    Image {
        id: bgImage
// Replace blank with your wallpaper path. IT IS RECOMMENDED TO PUT YOUR WALLPAPER IN YOUR SDDM THEME FOLDER.
// Before, you do these changes, run sudo mkdir -p /usr/share/sddm/themes/frost/
// After, copy your wallpaper to the /themes/frost/ folder: sudo cp /path/to/ur/wallpaper.png /usr/share/sddm/themes/frost/
// Finally, rename blank to your wallpaper's file name (no need to provide path). example source: "flowering-rain.png"
        source: "blank"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date();
            timeDisplay.text = date.toLocaleTimeString(Qt.locale(), "hh:mm");
            dateDisplay.text = date.toLocaleDateString(Qt.locale(), "dddd, MMMM d");
        }
        Component.onCompleted: onTriggered()
    }

    function executeLogin() {
        sddm.login(username.text, password.text, sessionBox.currentIndex)
    }

    component RoundedInput : TextField {
        id: inputRoot
        width: parent.width
        padding: 12
        color: config.textColor
        font.family: config.fontFamily
        font.pointSize: config.fontSize
        placeholderTextColor: "#a6adc8" 

        background: Item {
            ShaderEffectSource {
                id: effectSource
                anchors.fill: parent
                sourceItem: bgImage
                live: true
                sourceRect: {
                    var absolutePos = inputRoot.mapToItem(root, 0, 0);
                    return Qt.rect(absolutePos.x, absolutePos.y, inputRoot.width, inputRoot.height);
                }
            }
            FastBlur {
                anchors.fill: parent
                source: effectSource
                radius: 35 
            }
            Rectangle {
                anchors.fill: parent
                color: "#16a0a5f5" 
                radius: config.cornerRadius
                border.width: 1
                border.color: inputRoot.activeFocus ? "#a0a5f5" : "#45475a" 
            }
        }
    }

    Column {
        id: mainColumn
        anchors.centerIn: parent
        width: 300
        spacing: 20

        Column {
            width: parent.width
            spacing: 5
            
            Text {
                id: timeDisplay
                font.family: config.fontFamily
                font.pointSize: 42
                font.bold: true
                color: config.textColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: dateDisplay
                font.family: config.fontFamily
                font.pointSize: 12
                color: "#a6adc8"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Column {
            width: parent.width
            spacing: 12

            RoundedInput {
                id: username
                placeholderText: "Username"
                text: userModel.lastUser
                focus: true
                
                onAccepted: password.text === "" ? password.forceActiveFocus() : root.executeLogin()
            }

            RoundedInput {
                id: password
                placeholderText: "Password"
                echoMode: TextInput.Password
                
                onAccepted: root.executeLogin()
            }

            Button {
                id: loginBtn
                width: parent.width
                
                contentItem: Text {
                    text: "Login"
                    color: config.textColor
                    font.family: config.fontFamily
                    font.pointSize: config.fontSize
                    font.bold: false
                    horizontalAlignment: Text.AlignHCenter
                }

                background: Item {
                    ShaderEffectSource {
                        id: btnEffectSource
                        anchors.fill: parent
                        sourceItem: bgImage
                        live: true
                        sourceRect: {
                            var absolutePos = loginBtn.mapToItem(root, 0, 0);
                            return Qt.rect(absolutePos.x, absolutePos.y, loginBtn.width, loginBtn.height);
                        }
                    }
                    FastBlur {
                        anchors.fill: parent
                        source: btnEffectSource
                        radius: 35 
                    }
                    Rectangle {
                        anchors.fill: parent
                        color: loginBtn.down ? "#40a0a5f5" : "#26a0a5f5" 
                        radius: config.cornerRadius
                        border.width: 1
                        border.color: loginBtn.hovered ? "#a0a5f5" : "#45475a"
                    }
                }

                onClicked: root.executeLogin()
            }
        }

        ComboBox {
            id: sessionBox
            width: parent.width
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex

            contentItem: Text {
                text: sessionBox.displayText
                font.family: config.fontFamily
                font.pointSize: config.fontSize - 1
                color: config.textColor
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }

            background: Rectangle {
                color: "#16a0a5f5"
                radius: config.cornerRadius
                border.width: 1
                border.color: "#45475a"
            }
        }

        Text {
            id: errorMsg
            text: ""
            color: "#f38ba8"
            font.family: config.fontFamily
            font.pointSize: config.fontSize - 2
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            errorMsg.text = "Invalid credentials, check your username or password."
        }
    }
}
