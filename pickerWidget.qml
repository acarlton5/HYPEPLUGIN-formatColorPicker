import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property string myPluginId: "formatColorPicker"
    property bool isEnabled: typeof pluginData !== "undefined" && pluginData.isEnabled ? pluginData.isEnabled : false
    property string mode: {
      if (typeof PluginService !== "undefined" && PluginService) {
        return PluginService.loadPluginData(root.myPluginId, "mode", "HEX") || "HEX"
      }
      return (typeof pluginData !== "undefined" && pluginData.mode) ? pluginData.mode : "HEX"
    }

    ccWidgetIcon: "colorize"
    ccWidgetPrimaryText: "Color Picker"
    ccWidgetSecondaryText: _getModeText()
    ccWidgetIsActive: false

    function _getModeText() {
      const formats = {
        "HEX": "Hex Format", "RGB": "RGB Format", "HSL": "HSL Format",
        "HSV": "HSV Format", "CMYK": "CMYK Format", "JSON": "JSON Format"
      }
      return formats[root.mode] || "Color Format"
    }

    function saveSetting(key, value) {
      if (typeof PluginService !== "undefined" && PluginService) {
        PluginService.savePluginData(root.myPluginId, key, value)
      } else {
        console.error("PluginService is Unavailable")
        ToastService.showInfo("PluginSerice is Unavailable")
      }
    }

    function pickColor() {
      if (typeof PopoutService !== "undefined" && PopoutService) {
        PopoutService.closeControlCenter()
      }

      let flag = (root.mode || "HEX").toLowerCase()
      let cmd = `sleep 0.3; dms color pick --${flag} -a`

      Quickshell.execDetached(["sh", "-c", cmd])
    }

    onCcWidgetToggled: {
      pickColor()
    }

    ccDetailContent: Component {
      Rectangle {
        id: innerRect
        implicitHeight: 100
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)

        GridLayout {
          anchors.centerIn : parent
          columns: 3

          Repeater {
            model: ["HEX", "RGB", "HSL", "HSV", "CMYK", "JSON"]

            delegate: StyledRect {
              width: (innerRect.width - 60) / 3
              height: innerRect.height / 3
              radius: Theme.cornerRadius
              color: root.mode === modelData ? Theme.primary : 'transparent'
              border.width: 2
              border.color: Theme.primary

              StyledText {
                text: modelData
                font.pixelSize: Theme.fontSizeXLarge
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: root.mode === modelData ? Theme.onPrimary : Theme.surfaceText
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.mode = modelData

                  root.saveSetting("mode", modelData)

                  pickColor()
                }
              }
            }
          }
        }
      }
    }

    horizontalBarPill: Component {
        MouseArea {
            width: root.barThickness
            height: root.barThickness
            cursorShape: Qt.PointingHandCursor
            onClicked: root.pickColor()

            DankIcon {
                id: icon
                name: "colorize"
                size: Theme.barIconSize(root.barThickness, -2)
                color: Theme.widgetIconColor
                anchors.centerIn: parent
            }
        }
    }

    verticalBarPill: Component {
        MouseArea {
            width: root.barThickness
            height: root.barThickness
            cursorShape: Qt.PointingHandCursor
            onClicked: root.pickColor()

            DankIcon {
                id: icon
                name: "colorize"
                size: Theme.barIconSize(root.barThickness, -2)
                color: Theme.widgetIconColor
                anchors.centerIn: parent
            }
        }
    }
}
