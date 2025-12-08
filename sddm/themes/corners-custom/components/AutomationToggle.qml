import QtGraphicalEffects 1.15
import QtQuick 2.15
import QtQuick.Controls 2.15

// Bouton toggle pour activer/désactiver les automatismes Hyprland
Item {
    id: automationToggle
    
    // Définir la taille directement (comme PowerPanel)
    property double buttonSize: Screen.height * 0.175 * 0.25 * config.Scale
    
    implicitHeight: buttonSize
    implicitWidth: buttonSize

    property bool automationsEnabled: false
    property string configPath: "/home/aurel/.config/hypr/hypr_automations.conf"

    // Lecture du fichier de config au démarrage
    Component.onCompleted: {
        readConfig();
    }

    function readConfig() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file://" + configPath, false);
        try {
            xhr.send();
            if (xhr.status === 200) {
                var content = xhr.responseText;
                automationsEnabled = content.indexOf("AUTOMATIONS_ENABLED=true") !== -1;
            }
        } catch (e) {
            console.log("Erreur lecture config: " + e);
            automationsEnabled = false;
        }
    }

    Button {
        id: toggleButton

        icon {
            source: Qt.resolvedUrl("../icons/automation.svg")
            height: parent.buttonSize * 0.5
            width: parent.buttonSize * 0.5
            color: automationsEnabled ? config.PowerIconColor : "#888888"
        }

        height: parent.buttonSize
        width: parent.buttonSize
        hoverEnabled: true

        onClicked: {
            automationsEnabled = !automationsEnabled;
        }

        states: [
            State {
                name: "pressed"
                when: toggleButton.down

                PropertyChanges {
                    target: toggleButtonBg
                    color: Qt.darker(automationsEnabled ? config.PowerButtonColor : "#555555", 1.2)
                }
            },
            State {
                name: "hovered"
                when: toggleButton.hovered

                PropertyChanges {
                    target: toggleButtonBg
                    color: Qt.darker(automationsEnabled ? config.PowerButtonColor : "#555555", 1.1)
                }
            }
        ]

        background: Rectangle {
            id: toggleButtonBg

            color: automationsEnabled ? config.PowerButtonColor : "#555555"
            radius: config.Radius

            // Indicateur visuel de l'état
            Rectangle {
                id: statusIndicator
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

        transitions: Transition {
            PropertyAnimation {
                properties: "color"
                duration: 150
            }
        }
    }
    
    // Écriture simplifiée via fichier
    onAutomationsEnabledChanged: {
        var content = "# Configuration des automatismes Hyprland\nAUTOMATIONS_ENABLED=" + (automationsEnabled ? "true" : "false") + "\n";
        // Note: L'écriture sera gérée par un mécanisme externe
        console.log("Toggle: " + (automationsEnabled ? "ACTIVÉ" : "DÉSACTIVÉ"));
    }
}
