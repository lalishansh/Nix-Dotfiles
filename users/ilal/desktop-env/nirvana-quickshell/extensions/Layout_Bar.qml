import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core.bar.helpers

// extensions
import "./Test_ScreenName" as ScreenName
import "./Clock" as Clock
import "./ActiveWindowInfo" as ActiveWindowInfo
import "./SystemTray" as SystemTray
import "./BatteryInfo" as BatteryInfo
import "./QuickSettingsPanel" as QuickSettings

// extensions

RowLayout {
    LeftModules {
        // property real counter: 0
        // onScrollUp: (this.counter++)
        // onScrollDown: (this.counter--)
        // onClicked: (this.counter = 0)
        // Text {
        //     color: "#999"
        //     text: "Count " + parent.parent.counter + " "
        // }
        // ScreenName.BarMod {}
        ActiveWindowInfo.BarMod {}
    }
    CentreModules {
        // there are some issues here !
        // property real counter: 0
        // onScrollUp: (this.counter++)
        // onScrollDown: (this.counter--)
        // onClicked: (this.counter = 0)
        // Text {
        //     color: "#999"
        //     text: "Count " + parent.parent.counter + " "
        // }
        Text {
            color: "#bbb"
            text: "HIIIIIIIIII"
        }
        VerticalBarSeparator {}
        Clock.BarMod {}
    }
    RightModules {
        // property real counter: 0
        // onScrollUp: (this.counter++)
        // onScrollDown: (this.counter--)
        // onClicked: (this.counter = 0)
        // Text {
        //     color: "#999"
        //     text: "Count " + parent.parent.counter + " "
        // }
        SystemTray.BarMod {}
        BatteryInfo.BarMod {}
        QuickSettings.BarMod {}
    }
}
