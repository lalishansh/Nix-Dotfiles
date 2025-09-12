import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core.bar.helpers

// extensions
import "./ScreenName" as ScreenName
import "./Clock" as Clock
import "./ActiveWindowInfo" as ActiveWindowInfo

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
        ActiveWindowInfo.BarModHyprland {}
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
        VerticalBarSeparator {}
        Clock.BarMod {}
    }
}
