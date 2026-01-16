import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    id: root
    width: 1280
    height: 800
    visible: true
    title: qsTr("Lumio - RAW Editor")
    color: "transparent"

    // 无边框窗口
    flags: Qt.FramelessWindowHint | Qt.Window

    // 控制是否显示 Recent Projects
    property bool showRecentProjects: false

    // 背景矩形（带圆角和阴影）
    Item {
        anchors.fill: parent

        // 阴影层
        Rectangle {
            anchors.fill: parent
            anchors.margins: -8
            radius: 16
            color: "#40000000"
            z: -1
        }

        // 主背景（带圆角）
        Rectangle {
            anchors.fill: parent
            color: "#FAFAF9"
            radius: 8
            clip: true
        }
    }

    // 主滚动区域
    ScrollView {
        id: mainContent
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 0

            // ==================== 导航栏 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                color: "#FFFFFF"
                opacity: 0.95
                z: 100

                // 整个导航栏的拖拽区域
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onPressed: function(mouse) {
                        root.startSystemMove()
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 48
                    anchors.rightMargin: 18
                    spacing: 32

                    // Logo
                    RowLayout {
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: "#1C1917"

                            Text {
                                anchors.centerIn: parent
                                text: "\ue883" // layers icon
                                font.family: "Material Design Icons"
                                font.pixelSize: 18
                                color: "white"
                            }

                            // 阻止事件冒泡到拖拽区域
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                            }
                        }

                        Text {
                            text: "Lumio"
                            font.family: "Playfair Display"
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                            color: "#1C1917"

                            // 阻止事件冒泡到拖拽区域
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // 桌面导航
                    RowLayout {
                        spacing: 32
                        visible: true

                        Button {
                            text: "Discover"
                            flat: true
                            font.pixelSize: 14
                            contentItem: Text {
                                text: "Discover"
                                font.pixelSize: 14
                                color: "#78716C"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            background: Rectangle { color: "transparent" }
                        }

                        Button {
                            text: "Cloud Library"
                            flat: true
                            font.pixelSize: 14
                            contentItem: Text {
                                text: "Cloud Library"
                                font.pixelSize: 14
                                color: "#78716C"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            background: Rectangle { color: "transparent" }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 16
                            color: "#E7E5E4"
                        }

                        // 切换开关
                        RowLayout {
                            spacing: 8

                            Text {
                                text: "Recent Projects"
                                font.pixelSize: 13
                                color: "#78716C"
                            }

                            Rectangle {
                                Layout.preferredWidth: 44
                                Layout.preferredHeight: 24
                                radius: 12
                                color: root.showRecentProjects ? "#1C1917" : "#E7E5E4"

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }

                                Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "white"
                                    x: root.showRecentProjects ? parent.width - width - 2 : 2
                                    anchors.verticalCenter: parent.verticalCenter

                                    Behavior on x {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.showRecentProjects = !root.showRecentProjects
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 16
                            color: "#E7E5E4"
                        }

                        RowLayout {
                            spacing: 20

                            Button {
                                icon.source: "qrc:/icons/help-circle.svg"
                                icon.width: 20
                                icon.height: 20
                                flat: true
                                background: Rectangle { color: "transparent" }
                            }

                            Button {
                                icon.source: "qrc:/icons/settings.svg"
                                icon.width: 20
                                icon.height: 20
                                flat: true
                                background: Rectangle { color: "transparent" }
                            }

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 16
                                color: "#E7E5E4"

                                Image {
                                    anchors.fill: parent
                                    source: "https://api.dicebear.com/7.x/avataaars/svg?seed=Felix"
                                    fillMode: Image.PreserveAspectCrop
                                }
                            }
                        }

                        // 窗口控制按钮（右上角）
                        RowLayout {
                            spacing: 0

                            // 最小化按钮
                            Rectangle {
                                Layout.preferredWidth: 46
                                Layout.preferredHeight: 64
                                color: minimizeMouseArea.containsMouse ? "#F5F5F4" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "─"
                                    font.pixelSize: 12
                                    color: "#1C1917"
                                }

                                MouseArea {
                                    id: minimizeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.ArrowCursor
                                    onClicked: root.showMinimized()
                                }
                            }

                            // 最大化/还原按钮
                            Rectangle {
                                Layout.preferredWidth: 46
                                Layout.preferredHeight: 64
                                color: maximizeMouseArea.containsMouse ? "#F5F5F4" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: root.visibility === Window.Maximized ? "❐" : "□"
                                    font.pixelSize: 10
                                    color: "#1C1917"
                                }

                                MouseArea {
                                    id: maximizeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.ArrowCursor
                                    onClicked: {
                                        if (root.visibility === Window.Maximized) {
                                            root.showNormal()
                                        } else {
                                            root.showMaximized()
                                        }
                                    }
                                }
                            }

                            // 关闭按钮
                            Rectangle {
                                Layout.preferredWidth: 46
                                Layout.preferredHeight: 64
                                color: closeMouseArea.containsMouse ? "#E81123" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    font.pixelSize: 12
                                    color: closeMouseArea.containsMouse ? "white" : "#1C1917"
                                }

                                MouseArea {
                                    id: closeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.ArrowCursor
                                    onClicked: root.close()
                                }
                            }
                        }
                    }

                    // 移动端菜单按钮
                    Button {
                        id: mobileMenuBtn
                        visible: false
                        icon.source: "qrc:/icons/menu.svg"
                        flat: true
                        background: Rectangle { color: "transparent" }
                    }
                }
            }

            // ==================== Hero 区域 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                color: "transparent"
                visible: !root.showRecentProjects

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#F5F5F4" }
                        GradientStop { position: 1.0; color: "#FAFAF9" }
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 32
                    width: Math.min(parent.width * 0.8, 700)

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Start Editing Your\n<font style='font-style: italic'>Raw Masterpieces</font>"
                        font.family: "Playfair Display"
                        font.pixelSize: 56
                        font.weight: Font.Normal
                        color: "#292524"
                        lineHeight: 1.2
                        horizontalAlignment: Text.AlignHCenter
                        textFormat: Text.RichText
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: 500
                        text: "Unleash the full potential of your camera sensor with precision tools and a refined workflow designed for clarity."
                        font.pixelSize: 18
                        font.weight: Font.Light
                        color: "#78716C"
                        lineHeight: 1.6
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        Button {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 48

                            text: "Import RAW File"

                            background: Rectangle {
                                color: "#1C1917"
                                radius: 24
                            }

                            contentItem: Text {
                                text: "↑  Import RAW File"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: fileDialog.open()
                        }
                    }
                }
            }

            // ==================== 功能网格 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 280
                color: "#FFFFFF"
                border.color: "#F5F5F4"
                border.width: 1
                visible: !root.showRecentProjects

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 96
                    anchors.rightMargin: 96
                    spacing: 48

                    // 功能 1
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 16
                            color: "#F1F5F9"

                            Text {
                                anchors.centerIn: parent
                                text: "🌡"
                                font.pixelSize: 24
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Color Temperature"
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            color: "#292524"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 280
                            text: "Professional Kelvin adjustments with surgical precision. Correct indoor warmth or emphasize natural golden hour tones."
                            font.pixelSize: 14
                            color: "#78716C"
                            lineHeight: 1.6
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // 功能 2
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 16
                            color: "#FFFBEB"

                            Text {
                                anchors.centerIn: parent
                                text: "☀"
                                font.pixelSize: 24
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Exposure Control"
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            color: "#292524"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 280
                            text: "Dynamic range recovery that preserves highlight detail. Manipulate shadows and highlights with non-destructive depth."
                            font.pixelSize: 14
                            color: "#78716C"
                            lineHeight: 1.6
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // 功能 3
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 16
                            color: "#EFF6FF"

                            Text {
                                anchors.centerIn: parent
                                text: "💧"
                                font.pixelSize: 24
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "White Balance"
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            color: "#292524"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 280
                            text: "Intelligent gray-card sampling and preset matching. Achieve perfect color neutrality across any lighting environment."
                            font.pixelSize: 14
                            color: "#78716C"
                            lineHeight: 1.6
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }

            // ==================== 最近项目 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 500
                color: "#FAFAF9"
                visible: root.showRecentProjects

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 96
                    anchors.rightMargin: 96
                    spacing: 32

                    // 标题行
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        ColumnLayout {
                            spacing: 8

                            Text {
                                text: "Recent Projects"
                                font.family: "Playfair Display"
                                font.pixelSize: 32
                                color: "#292524"
                            }

                            Text {
                                text: "Pick up where you left off"
                                font.pixelSize: 14
                                color: "#78716C"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "View All Projects →"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            flat: true
                            background: Rectangle { color: "transparent" }
                        }
                    }

                    // 项目网格
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        columnSpacing: 32
                        rowSpacing: 32

                        // 项目卡片 1
                        Rectangle {
                            Layout.columnSpan: 1
                            Layout.preferredWidth: 240
                            Layout.preferredHeight: 280
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 180
                                radius: 16
                                color: "#E7E5E4"

                                Image {
                                    anchors.fill: parent
                                    source: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&q=80&w=800"
                                    fillMode: Image.PreserveAspectCrop
                                    opacity: 0.6
                                }

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.top
                                    anchors.margins: 12
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 24
                                    radius: 4
                                    color: "#333333"
                                    opacity: 0.6

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Sony ARW"
                                        font.pixelSize: 10
                                        color: "white"
                                        font.capitalization: Font.AllUppercase
                                    }
                                }
                            }

                            Text {
                                text: "Glacier_Vortex_01"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: "#292524"
                            }

                            Text {
                                text: "Edited 2 hours ago"
                                font.pixelSize: 12
                                color: "#A8A29E"
                            }
                            }
                        }

                        // 项目卡片 2
                        Rectangle {
                            Layout.columnSpan: 1
                            Layout.preferredWidth: 240
                            Layout.preferredHeight: 280
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 180
                                radius: 16
                                color: "#E7E5E4"

                                Image {
                                    anchors.fill: parent
                                    source: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=800"
                                    fillMode: Image.PreserveAspectCrop
                                    opacity: 0.6
                                }

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.top
                                    anchors.margins: 12
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 24
                                    radius: 4
                                    color: "#333333"
                                    opacity: 0.6

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Canon CR3"
                                        font.pixelSize: 10
                                        color: "white"
                                        font.capitalization: Font.AllUppercase
                                    }
                                }
                            }

                            Text {
                                text: "Misty_Alps_Summit"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: "#292524"
                            }

                            Text {
                                text: "Edited Yesterday"
                                font.pixelSize: 12
                                color: "#A8A29E"
                            }
                            }
                        }

                        // 项目卡片 3
                        Rectangle {
                            Layout.columnSpan: 1
                            Layout.preferredWidth: 240
                            Layout.preferredHeight: 280
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 180
                                radius: 16
                                color: "#E7E5E4"

                                Image {
                                    anchors.fill: parent
                                    source: "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&q=80&w=800"
                                    fillMode: Image.PreserveAspectCrop
                                    opacity: 0.6
                                }

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.top
                                    anchors.margins: 12
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 24
                                    radius: 4
                                    color: "#333333"
                                    opacity: 0.6

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Nikon NEF"
                                        font.pixelSize: 10
                                        color: "white"
                                        font.capitalization: Font.AllUppercase
                                    }
                                }
                            }

                            Text {
                                text: "Dusk_Horizon_Series"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: "#292524"
                            }

                            Text {
                                text: "Edited 3 days ago"
                                font.pixelSize: 12
                                color: "#A8A29E"
                            }
                            }
                        }

                        // 新建项目卡片
                        Rectangle {
                            Layout.columnSpan: 1
                            Layout.preferredWidth: 240
                            Layout.preferredHeight: 280
                            radius: 16
                            color: "transparent"
                            border.color: "#E7E5E4"
                            border.width: 2

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 12

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    radius: 20
                                    color: "#F5F5F4"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "+"
                                        font.pixelSize: 24
                                        color: "#A8A29E"
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "New Workspace"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: "#A8A29E"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: fileDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== RAW 编辑器组件 ====================
    RawEditor {
        id: rawEditor

        onVisibleChanged: {
            // 编辑器显示时隐藏首页内容，编辑器隐藏时显示首页内容
            mainContent.visible = !visible
        }
    }

    // ==================== 文件对话框 ====================
    FileDialog {
        id: fileDialog
        title: "选择 RAW 图片"
        nameFilters: ["RAW Images (*.cr2 *.nef *.arw *.dng *.orf *.raf)", "All Files (*)"]
        onAccepted: {
            var path = selectedFile.toString();
            console.log("Selected file: " + path);

            if (rawProcessor.openFile(path)) {
                console.log("File opened successfully");

                // 获取文件名
                var fileName = path.split('/').pop();
                if (fileName.indexOf('\\') > -1) {
                    fileName = path.split('\\').pop();
                }

                // 启动渐进式解码
                rawProcessor.decodeProgressive();
            } else {
                console.log("Failed to open file: " + rawProcessor.getLastError());
            }
        }
    }

    // ==================== 信号连接 ====================
    Connections {
        target: rawProcessor

        function onProgressiveStageFinished(base64Image, stage, total) {
            console.log("Progressive stage " + stage + "/" + total);
            // 更新编辑器中的预览图
            if (stage === 1) {
                // 获取文件名
                var path = rawProcessor.currentFile;
                var fileName = path.split('/').pop();
                if (fileName.indexOf('\\') > -1) {
                    fileName = path.split('\\').pop();
                }
                rawEditor.loadImage(base64Image, fileName);
            }
        }

        function onProgressiveFinished(base64Image) {
            console.log("Progressive finished");
            // 更新编辑器中的最终图像
            rawEditor.updateImage(base64Image);
        }

        function onDecodeFinished(base64Image) {
            console.log("Decode finished");
            // 更新编辑器中的图像（用于调整后的重新解码）
            rawEditor.updateImage(base64Image);
        }

        function onDecodeFailed(error) {
            console.log("Decode failed: " + error);
        }
    }
}
