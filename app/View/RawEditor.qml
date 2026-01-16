import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 1400
    height: 900
    visible: false
    title: qsTr("Lumio - RAW Editor")
    color: "#FDFCF8"

    // 防抖定时器
    Timer {
        id: updateTimer
        interval: 300  // 300ms 防抖
        repeat: false
        onTriggered: {
            root.applyAdjustments()
        }
    }

    property string currentImagePath: ""
    property string currentFileName: ""
    property real zoomLevel: 1.0
    property string zoomMode: "fit" // "fit", "fill", "100"

    // 图像调整参数
    property real exposure: 0.0      // 曝光 (-2.0 ~ 2.0)
    property real contrast: 0.0      // 对比度 (-50 ~ 50)
    property real highlights: 0.0    // 高光 (-100 ~ 100)
    property real shadows: 0.0       // 阴影 (-100 ~ 100)
    property real saturation: 0.0    // 饱和度 (-100 ~ 100)
    property real temperature: 0.0   // 色温 (-100 ~ 100, 冷 ~ 暖)

    // ==================== 顶部导航栏 ====================
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 64
        color: "#FFFFFF"
        opacity: 0.95

        z: 100

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            spacing: 24

            // Logo 和返回按钮
            RowLayout {
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: "#5D7B8F"

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: "white"
                        anchors.centerIn: parent
                    }
                }

                Text {
                    text: "Lumio"
                    font.family: "Playfair Display"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: "#1A1A1A"
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 24
                    color: "#E5E1D8"
                }

                Text {
                    text: currentFileName
                    font.pixelSize: 14
                    color: "#78716C"
                    elide: Text.ElideMiddle
                }
            }

            Item { Layout.fillWidth: true }

            // 右侧按钮
            RowLayout {
                spacing: 12

                Button {
                    text: "←  Back Home"
                    font.pixelSize: 14
                    font.weight: Font.Medium

                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                    }

                    contentItem: Text {
                        text: "←  Back Home"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#6B7280"
                    }

                    onClicked: {
                        root.visible = false
                    }
                }

                Button {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40

                    text: "Export"

                    background: Rectangle {
                        color: "#5D7B8F"
                        radius: 8
                    }

                    contentItem: Text {
                        text: "↓  Export"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // ==================== 主内容区域 ====================
    RowLayout {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        // ==================== 左侧：图片预览区域 ====================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#F6F4EF"

            Flickable {
                id: flickable
                anchors.fill: parent
                anchors.margins: 32
                clip: true

                Image {
                    id: previewImage
                    source: currentImagePath
                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    // 缩放
                    transform: Scale {
                        origin.x: previewImage.width / 2
                        origin.y: previewImage.height / 2
                        xScale: root.zoomLevel
                        yScale: root.zoomLevel
                    }

                    // 居中显示
                    anchors.centerIn: parent
                }

                // 鼠标拖拽平移
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onPressed: {
                        flickable.interactive = true
                    }
                    onReleased: {
                        flickable.interactive = false
                    }
                }
            }

            // 缩放控制栏
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 32
                anchors.horizontalCenter: parent.horizontalCenter
                width: 280
                height: 44
                radius: 22
                color: "#FFFFFF"
                opacity: 0.95

                RowLayout {
                    anchors.fill: parent
                    anchors.centerIn: parent
                    spacing: 12

                    Button {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        text: "−"
                        font.pixelSize: 18

                        background: Rectangle {
                            color: "transparent"
                            radius: 16
                        }

                        contentItem: Text {
                            text: "−"
                            font.pixelSize: 18
                            color: "#6B7280"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            root.zoomLevel = Math.max(0.1, root.zoomLevel - 0.1)
                            zoomMode = "custom"
                        }
                    }

                    Text {
                        text: zoomMode === "fit" ? "Fit" : (zoomMode === "100" ? "100%" : Math.round(root.zoomLevel * 100) + "%")
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: "#78716C"
                        Layout.preferredWidth: 40
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        text: "+"
                        font.pixelSize: 18

                        background: Rectangle {
                            color: "transparent"
                            radius: 16
                        }

                        contentItem: Text {
                            text: "+"
                            font.pixelSize: 18
                            color: "#6B7280"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            root.zoomLevel = Math.min(5.0, root.zoomLevel + 0.1)
                            zoomMode = "custom"
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        color: "#E5E1D8"
                    }

                    Button {
                        text: "100%"
                        font.pixelSize: 11
                        font.weight: Font.Medium

                        background: Rectangle {
                            color: "transparent"
                            radius: 4
                        }

                        contentItem: Text {
                            text: "100%"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#5D7B8F"
                        }

                        onClicked: {
                            root.zoomLevel = 1.0
                            zoomMode = "100"
                        }
                    }

                    Button {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        text: "⛶"
                        font.pixelSize: 14

                        background: Rectangle {
                            color: "transparent"
                            radius: 16
                        }

                        contentItem: Text {
                            text: "⛶"
                            font.pixelSize: 14
                            color: "#9CA3AF"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (root.zoomLevel === 1.0) {
                                root.zoomLevel = 0.5
                            } else {
                                root.zoomLevel = 1.0
                            }
                            zoomMode = "custom"
                        }
                    }
                }
            }
        }

        // ==================== 右侧：属性面板 ====================
        Rectangle {
            Layout.preferredWidth: 380
            Layout.fillHeight: true
            color: "#FFFFFF"
            border.color: "#E5E1D8"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 标签页
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    spacing: 0

                    Button {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 95
                        text: "ADJUST"

                        background: Rectangle {
                            color: "transparent"
                        }

                        contentItem: Text {
                            text: "ADJUST"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: "#1A1A1A"
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 2
                        Layout.fillHeight: true
                        color: "#5D7B8F"
                    }

                    Button {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 95
                        text: "PRESETS"

                        background: Rectangle {
                            color: "transparent"
                        }

                        contentItem: Text {
                            text: "PRESETS"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: "#9CA3AF"
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 95
                        text: "HISTORY"

                        background: Rectangle {
                            color: "transparent"
                        }

                        contentItem: Text {
                            text: "HISTORY"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: "#9CA3AF"
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 95
                        text: "INFO"

                        background: Rectangle {
                            color: "transparent"
                        }

                        contentItem: Text {
                            text: "INFO"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: "#9CA3AF"
                            font.capitalization: Font.AllUppercase
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // 可滚动控制区域
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 32

                        // 基础调整
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 24
                            Layout.rightMargin: 24
                            Layout.topMargin: 24
                            spacing: 24

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Basic Adjustments"
                                    font.family: "Playfair Display"
                                    font.pixelSize: 18
                                    font.weight: Font.Medium
                                    color: "#1A1A1A"
                                }

                                Item { Layout.fillWidth: true }

                                Button {
                                    text: "Reset"
                                    font.pixelSize: 12

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    contentItem: Text {
                                        text: "Reset"
                                        font.pixelSize: 12
                                        color: "#9CA3AF"
                                        font.underline: true
                                    }

                                    onClicked: {
                                        root.resetAdjustments()
                                    }
                                }
                            }

                            // 曝光滑块
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: "Exposure"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: "#78716C"
                                        font.capitalization: Font.AllUppercase
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.exposure.toFixed(1)
                                        font.pixelSize: 11
                                        font.family: "monospace"
                                        color: "#1A1A1A"
                                    }
                                }

                                Slider {
                                    id: exposureSlider
                                    Layout.fillWidth: true
                                    from: -2.0
                                    to: 2.0
                                    value: root.exposure

                                    onValueChanged: {
                                        root.exposure = value
                                        root.requestUpdate()
                                    }
                                }
                            }

                            // 对比度滑块
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: "Contrast"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: "#78716C"
                                        font.capitalization: Font.AllUppercase
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.contrast.toFixed(0)
                                        font.pixelSize: 11
                                        font.family: "monospace"
                                        color: "#1A1A1A"
                                    }
                                }

                                Slider {
                                    Layout.fillWidth: true
                                    from: -50
                                    to: 50
                                    value: root.contrast

                                    onValueChanged: {
                                        root.contrast = value
                                        root.requestUpdate()
                                    }
                                }
                            }

                            // 高光滑块
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: "Highlights"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: "#78716C"
                                        font.capitalization: Font.AllUppercase
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.highlights.toFixed(0)
                                        font.pixelSize: 11
                                        font.family: "monospace"
                                        color: "#1A1A1A"
                                    }
                                }

                                Slider {
                                    Layout.fillWidth: true
                                    from: -100
                                    to: 100
                                    value: root.highlights

                                    onValueChanged: {
                                        root.highlights = value
                                        root.requestUpdate()
                                    }
                                }
                            }

                            // 阴影滑块
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: "Shadows"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: "#78716C"
                                        font.capitalization: Font.AllUppercase
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.shadows.toFixed(0)
                                        font.pixelSize: 11
                                        font.family: "monospace"
                                        color: "#1A1A1A"
                                    }
                                }

                                Slider {
                                    Layout.fillWidth: true
                                    from: -100
                                    to: 100
                                    value: root.shadows

                                    onValueChanged: {
                                        root.shadows = value
                                        root.requestUpdate()
                                    }
                                }
                            }
                        }

                        // 分隔线
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#F0EEEA"
                        }

                        // 颜色和细节
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 24
                            Layout.rightMargin: 24
                            spacing: 24

                            Text {
                                text: "Color & Detail"
                                font.family: "Playfair Display"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                color: "#1A1A1A"
                            }

                            // 饱和度滑块
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: "Saturation"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: "#78716C"
                                        font.capitalization: Font.AllUppercase
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.saturation.toFixed(0)
                                        font.pixelSize: 11
                                        font.family: "monospace"
                                        color: "#1A1A1A"
                                    }
                                }

                                Slider {
                                    Layout.fillWidth: true
                                    from: -100
                                    to: 100
                                    value: root.saturation

                                    onValueChanged: {
                                        root.saturation = value
                                        root.requestUpdate()
                                    }
                                }
                            }

                            // 色温滑块
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: "Temperature"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: "#78716C"
                                        font.capitalization: Font.AllUppercase
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.temperature.toFixed(0)
                                        font.pixelSize: 11
                                        font.family: "monospace"
                                        color: "#1A1A1A"
                                    }
                                }

                                Slider {
                                    Layout.fillWidth: true
                                    from: -100
                                    to: 100
                                    value: root.temperature

                                    onValueChanged: {
                                        root.temperature = value
                                        root.requestUpdate()
                                    }
                                }
                            }
                        }

                        // 底部工具栏
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: "#F9FAFB"
                            border.color: "#E5E1D8"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 24
                                anchors.rightMargin: 24
                                spacing: 12

                                Button {
                                    text: "↶  Undo"
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    contentItem: Text {
                                        text: "↶  Undo"
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        color: "#6B7280"
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Button {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 32
                                    text: "Apply"

                                    background: Rectangle {
                                        color: "#5D7B8F"
                                        radius: 6
                                    }

                                    contentItem: Text {
                                        text: "Apply"
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        root.applyAdjustments()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== 函数 ====================
    function loadImage(base64Image, fileName) {
        currentImagePath = base64Image
        currentFileName = fileName
        zoomLevel = 1.0
        zoomMode = "fit"
        visible = true
    }

    function updateImage(base64Image) {
        currentImagePath = base64Image
    }

    function resetAdjustments() {
        exposure = 0.0
        contrast = 0.0
        highlights = 0.0
        shadows = 0.0
        saturation = 0.0
        temperature = 0.0
        requestUpdate()
    }

    function applyAdjustments() {
        // 调用 C++ 层设置调整参数
        rawProcessor.setAdjustments(exposure, contrast, highlights, shadows, saturation, temperature)
        // 重新解码图像
        rawProcessor.redecodeWithAdjustments()
    }

    function requestUpdate() {
        // 使用防抖定时器，避免频繁更新
        updateTimer.restart()
    }
}
