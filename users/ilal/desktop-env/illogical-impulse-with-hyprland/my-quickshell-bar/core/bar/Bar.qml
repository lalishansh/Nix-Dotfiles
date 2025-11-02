import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.extensions // Layout_Bar

// import qs.core

Scope {
    Variants {
        // For each monitor, all active (not list dependent)
        model: Quickshell.screens

        LazyLoader {
            id: barLoader
            active: true//GlobalStates.barOpen && !GlobalStates.screenLocked // TODO: rename to `desktopVisible`
            required property ShellScreen modelData
            component: PanelWindow {
                id: bar
                screen: modelData
                // *Config
                // Default: 0 no change, 1 use shorter appearance, 2 use shortest appearance
                //property real useShortenedFormHint: (Appearance.sizes.barHellaShortenScreenWidthThreshold >= screen.width) ? 2 : (Appearance.sizes.barShortenScreenWidthThreshold >= screen.width) ? 1 : 0
                // ~Config

                property bool shouldShow: false
                property bool mustShow: hoverRegion.containsMouse || shouldShow

                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: 40 + 5
                implicitHeight: this.exclusiveZone

                // implicit

                WlrLayershell.namespace: "quickshell:bar"
                mask: Region {
                    item: hoverMaskRegion
                }

                color: "transparent" // "green" // for debugging
                anchors {
                    top: false
                    bottom: true
                    left: true
                    right: true
                }

                MouseArea {
                    id: hoverRegion
                    hoverEnabled: true
                    anchors.fill: parent

                    Item {
                        id: hoverMaskRegion
                        anchors {
                            fill: barContent
                            topMargin: -1
                            bottomMargin: -1
                        }
                    }

                    Layout_Bar {
                        id: barContent

                        implicitHeight: bar.exclusiveZone - 5
                        anchors {
                            fill: parent
                            margins: 3
                            leftMargin: 6
                            rightMargin: 6
                        }

                        // TODO: FixWarning
                        // Background
                        Rectangle {
                            id: barBackground
                            anchors.fill: parent
                            color: "transparent"
                            radius: 18
                            border.width: 3
                            border.color: "maroon"
                        }
                    }
                }
            }
        }
    }
}
