import QtQuick 2.15
import QtQuick.Controls 2.15 
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15 
import Qt.labs.folderlistmodel 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    property string currentUser: userModel.lastUser
    property bool isUserSelected: currentUser !== ""

    FontLoader {
        id: localFont
        source: Qt.resolvedUrl("GoogleSans/Google-Sans-Font-master/GoogleSans-Regular.ttf")
    }

    Image {
        id: wallpaperimage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            z: -1
        }
    }

    FolderListModel {
        id: selectModel
        folder: Qt.resolvedUrl("assets/Wallpapers")
        nameFilters: ["*.jpg","*.jpeg","*.png"]

        onStatusChanged: {
            if (status === FolderListModel.Ready && count > 0){
                var randomIndex = Math.floor(Math.random() * count)
                wallpaperimage.source = get(randomIndex, "fileUrl")
            }
        }
    }

    Item {
        id: centerWrapper
        width: Math.max(460, Math.min(parent.width * 0.333, 640))
        height: layoutColumn.implicitHeight
        anchors.centerIn: parent

        Column {
            id: layoutColumn
            anchors.fill: parent
            spacing: 12

            Item {
                id: mainContainer
                width: parent.width
                height: loginRowLayout.implicitHeight + 40

                Item {
                    id: loginBox
                    anchors.fill: parent

                    ShaderEffectSource {
                        id: effectSource
                        sourceItem: wallpaperimage
                        sourceRect: Qt.rect(centerWrapper.x, centerWrapper.y, mainContainer.width, mainContainer.height)
                        visible: false
                    }

                    FastBlur {
                        id: blurEffect
                        source: effectSource
                        radius: 64
                        visible: false
                    }
                    
                    Rectangle {
                        id: maskRect
                        anchors.fill: parent
                        radius: 16
                        visible: false
                    }
                    
                    OpacityMask {
                        anchors.fill: parent
                        source: blurEffect
                        maskSource: maskRect
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: Qt.rgba(0, 0, 0, 0.3)
                        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.15)
                        border.width: 1
                    }
                }

                RowLayout {
                    id: loginRowLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Math.min(25, parent.width * 0.05)
                    anchors.rightMargin: Math.min(25, parent.width * 0.05)
                    spacing: 15

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 10
                    
                        Text {
                            text: isUserSelected ? "Welcome back, " + currentUser : "Login"
                            color: "#ffffff"
                            font.family: localFont.name
                            font.pixelSize: 18
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        TextField {
                            id: usernameField
                            placeholderText: "Username"
                            text: currentUser
                            Layout.fillWidth: true
                            font.family: localFont.name
                            font.pixelSize: 14
                            color: "#ffffff"
                            visible: !isUserSelected

                            background: Rectangle {
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.1)
                                radius: 6
                                border.color: usernameField.activeFocus ? Qt.rgba(1.0, 1.0, 1.0, 0.5) : "transparent"
                            }
                        }
            
                        TextField {
                            id: passwordField
                            placeholderText: "Password"
                            echoMode: TextInput.Password
                            Layout.fillWidth: true
                            font.family: localFont.name
                            font.pixelSize: 14
                            color: "#ffffff"
            
                            background: Rectangle {
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.1)
                                radius: 6
                                border.color: passwordField.activeFocus ? Qt.rgba(1.0, 1.0, 1.0, 0.5) : "transparent"
                            }

                            onAccepted: loginButton.clicked()
                            Component.onCompleted: forceActiveFocus()    
                        }

                        Button {
                            id: loginButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
            
                            contentItem: Text {
                                text: "Login"
                                font.family: localFont.name
                                font.pixelSize: 14
                                font.bold: true
                                color: loginButton.pressed ? "#aaaaaa" : "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: loginButton.hovered ? Qt.rgba(1.0, 1.0, 1.0, 0.25) : Qt.rgba(1.0, 1.0, 1.0, 0.15)
                                radius: 6
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            onClicked: {
                                sddm.login(usernameField.text, passwordField.text, sessionModel.lastIndex)
                            }
                        }

                        Button {
                            id: switchUserButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 25
                            visible: isUserSelected

                            contentItem: Text {
                                text: "Switch User"
                                font.family: localFont.name
                                font.pixelSize: 12
                                color: switchUserButton.hovered ? "#1793D1" : "#aaaaaa"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            background: Rectangle { color: "transparent" }

                            onClicked: {
                                isUserSelected = false
                                usernameField.text = ""
                                usernameField.forceActiveFocus()
                            }
                        }
                    }
                    
                    Item {
                        Layout.preferredWidth: Math.min(90, mainContainer.width * 0.2)
                        Layout.preferredHeight: Layout.preferredWidth
                        Layout.alignment: Qt.AlignVCenter

                        Image {
                            id: avatarImage
                            anchors.fill: parent
                            source: "file:///var/lib/AccountsService/icons/" + usernameField.text
                            fillMode: Image.PreserveAspectCrop 
                            visible: false

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    source = Qt.resolvedUrl("assets/default-avatar.png")
                                }
                            }
                        }
                        
                        Rectangle {
                            id: avatarMask
                            anchors.fill: parent
                            radius: width / 2
                            visible: false
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: avatarImage
                            maskSource: avatarMask
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "transparent"
                            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.3)
                            border.width: 1.5
                        }
                    }

                    Rectangle {
                        id: powermenuContainer
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: powerManagement.height + 20
                        radius: width / 2
                        
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.85)
                        border.color: Qt.rgba(0, 0, 0, 0.1)
                        border.width: 1
                        Layout.alignment: Qt.AlignVCenter

                        Column {
                            id: powerManagement
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 10

                            Button {
                                id: shutdownBtn
                                width: 32
                                height: 32
                                ToolTip.visible: hovered
                                ToolTip.text: "Shut Down"

                                contentItem: Item {
                                    Image {
                                        source: "file:///usr/share/icons/breeze/actions/24/system-shutdown.svg"
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                        opacity: shutdownBtn.hovered ? 1.0 : 0.7
                                        scale: shutdownBtn.hovered ? 1.1 : 1.0
                                    }
                                }
                                background: Rectangle {
                                    color: shutdownBtn.hovered ? Qt.rgba(220/255, 38/255, 38/255, 0.12) : "transparent"
                                    radius: 16 
                                }
                                onClicked: sddm.powerOff()
                            }
            
                            Button {
                                id: rebootBtn
                                width: 32
                                height: 32
                                ToolTip.visible: hovered
                                ToolTip.text: "Reboot"
            
                                contentItem: Item {
                                    Image {
                                        source: "file:///usr/share/icons/breeze/actions/24/system-reboot.svg"
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                        opacity: rebootBtn.hovered ? 1.0 : 0.7
                                        scale: rebootBtn.hovered ? 1.1 : 1.0
                                    }
                                }
                                background: Rectangle {
                                    color: rebootBtn.hovered ? Qt.rgba(37/255, 99/255, 235/255, 0.12) : "transparent"
                                    radius: 16 
                                }
                                onClicked: sddm.reboot()
                            }
                        }
                    }
                }
            }

            Text {
                id: plainTextLabel
                text: "Made by Sulfur_qwq with love"
                color: "#ffffff"
                font.family: localFont.name
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Rectangle {
                id: apiBar
                width: parent.width
                height: 70
                radius: 8
                color: Qt.rgba(0, 0, 0, 0.4) 
                border.color: Qt.rgba(1.0, 1.0, 1.0, 0.15)
                border.width: 1

                Text {
                    text: apiText
                    color: "#cbd5e1"
                    font.family: localFont.name
                    font.pixelSize: 12
                    anchors.fill: parent
                    anchors.margins: 8
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    property string currentTime: "00:00:00"
    property string currentDate: "0000-00-00 Monday"
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            currentTime = Qt.formatTime(new Date(), "hh:mm:ss")
            currentDate = Qt.formatDate(new Date(), "dd MMMM, yyyy dddd")
        }
    }

    Item {
        id: clock
        width: timeText.implicitWidth
        height: clockColumn.implicitHeight
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Math.max(20, parent.width * 0.04)
        anchors.topMargin: Math.max(20, parent.height * 0.04)

        Column { 
            id: clockColumn
            anchors.right: parent.right
            spacing: 5
            
            Text {
                id: timeText
                text: currentTime
                color: "#ffffff"
                font.family: localFont.name
                font.pixelSize: Math.max(40, Math.min(root.width * 0.05, 80)) 
                font.bold: true
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter 
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.2)
            }

            Text {
                id: dateText
                text: currentDate
                color: Qt.rgba(1.0, 1.0, 1.0, 0.85)
                font.family: localFont.name
                font.pixelSize: Math.max(12, Math.min(root.width * 0.012, 16))
                width: parent.width
                horizontalAlignment: Text.AlignRight 
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.2)
            }
        }
    }

    property string apiText: "^-_-^ zzz"
    
    function fetchJokeNetworkData() {
        var xhr = new XMLHttpRequest();
        var url = "https://v2.jokeapi.dev/joke/Programming?format=txt";

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200){ 
                    apiText = xhr.responseText.trim();
                } else {
                    apiText = "Oh my gosh my cat has bitten my network wire again!";
                }
            }
        }
        xhr.open("GET", url, true);
        xhr.send();
    }

    Component.onCompleted: {
        fetchJokeNetworkData();
    }
}
