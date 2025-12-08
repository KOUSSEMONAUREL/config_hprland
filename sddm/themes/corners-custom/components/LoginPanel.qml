import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Item {
    property string user: userPanel.username
    property string password: passwordField.text
    property int session: sessionPanel.session
    property double inputHeight: Screen.height * 0.175 * 0.25 * config.Scale
    property double inputWidth: Screen.width * 0.175 * config.Scale
    
    // Index des sessions (supposition: 0=Full, 1=Minimal car ordre alpha)
    // Idéalement on chercherait dans le modèle, mais on simplifie.
    property int sessionFullIndex: 0
    property int sessionMinimalIndex: 1
    
    // État basé sur la session sélectionnée
    property bool automationsEnabled: sessionPanel.session === sessionFullIndex

    Column {
        spacing: 8

        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        // Bouton Toggle Automatismes - Contrôle la session
        Button {
            id: automationButton
            
            height: inputHeight
            width: inputHeight
            hoverEnabled: true
            
            icon {
                source: Qt.resolvedUrl("../icons/automation.svg")
                height: inputHeight * 0.5
                width: inputHeight * 0.5
                color: automationsEnabled ? config.PowerIconColor : "#888888"
            }
            
            onClicked: {
                // Basculer la session
                if (automationsEnabled) {
                    sessionPanel.sessionList.currentIndex = sessionMinimalIndex;
                } else {
                    sessionPanel.sessionList.currentIndex = sessionFullIndex;
                }
            }
            
            background: Rectangle {
                id: automationBg
                color: automationsEnabled ? config.PowerButtonColor : "#555555"
                radius: config.Radius
                
                // Indicateur d'état
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: automationsEnabled ? "#00ff00" : "#ff4444"
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        margins: 4
                    }
                }
            }
            
            states: [
                State {
                    name: "hovered"
                    when: automationButton.hovered
                    PropertyChanges {
                        target: automationBg
                        color: Qt.darker(automationsEnabled ? config.PowerButtonColor : "#555555", 1.1)
                    }
                }
            ]
            
            ToolTip.visible: automationButton.hovered
            ToolTip.delay: 300
            ToolTip.text: automationsEnabled ? "Automatismes ON (Full Session)" : "Automatismes OFF (Minimal Session)"
        }

        PowerPanel {}
        
        // On garde le panel visible pour debug ou si l'user veut changer manuellement
        SessionPanel { id: sessionPanel }
    }

    Column {
        spacing: 8
        width: inputWidth

        anchors {
            bottom: parent.bottom
            right: parent.right
        }

        UserPanel { id: userPanel }

        PasswordPanel {
            id: passwordField

            height: inputHeight
            width: parent.width
            onAccepted: loginButton.clicked();
        }

        Button {
            id: loginButton

            height: inputHeight
            width: parent.width
            enabled: user !== "" && password !== ""
            hoverEnabled: true

            onClicked: {
                sddm.login(user, password, session);
            }
            
            states: [
                State {
                    name: "pressed"
                    when: loginButton.down

                    PropertyChanges {
                        target: buttonBackground
                        color: Qt.darker(config.LoginButtonColor, 1.4)
                        opacity: 1
                    }

                    PropertyChanges {
                        target: buttonText
                        opacity: 1
                    }
                },
                State {
                    name: "hovered"
                    when: loginButton.hovered

                    PropertyChanges {
                        target: buttonBackground
                        color: Qt.darker(config.LoginButtonColor, 1.2)
                        opacity: 1
                    }

                    PropertyChanges {
                        target: buttonText
                        opacity: 1
                    }
                },
                State {
                    name: "enabled"
                    when: loginButton.enabled

                    PropertyChanges {
                        target: buttonBackground
                        opacity: 1
                    }

                    PropertyChanges {
                        target: buttonText
                        opacity: 1
                    }
                }
            ]

            Rectangle {
                id: loginAnim

                radius: parent.width / 2
                anchors {centerIn: loginButton }
                color: "black"
                opacity: 1

                NumberAnimation {
                    id: coverScreen

                    target: loginAnim
                    properties: "height, width"
                    from: 0
                    to: root.width * 2
                    duration: 1000
                    easing.type: Easing.InExpo
                }
            }

            contentItem: Text {
                id: buttonText

                font {
                    family: config.FontFamily
                    pointSize: config.FontSize
                    bold: true
                }

                text: config.LoginButtonText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                
                opacity: 0.5
                renderType: Text.NativeRendering
                color: config.LoginButtonTextColor
            }

            background: Rectangle {
                id: buttonBackground

                color: config.LoginButtonColor
                opacity: 0.5
                radius: config.Radius
            }

            transitions: Transition {
                PropertyAnimation {
                    properties: "color, opacity"
                    duration: 150
                }
            }
        }
    }

    Connections {
        function onLoginSucceeded() {
            coverScreen.start();
        }

        function onLoginFailed() {
            passwordField.text = "";
            passwordField.focus = true;
        }

        target: sddm
    }
}
