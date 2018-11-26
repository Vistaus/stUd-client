import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Layouts 1.0

Page {
    id: accountPage

    header: PageHeader {
        id: pageHeader2
        title: i18n.tr("StUd Account")
        StyleHints {
            foregroundColor: UbuntuColors.orange
            backgroundColor: UbuntuColors.porcelain
            dividerColor: UbuntuColors.slate
        }
    }

    function insertStudUser(ukey, uname, upw) {
        var id0 = ukey
        var id1 = uname
        var id2 = upw

        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM studusertbl")
        })
        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO studusertbl VALUES (?,?,?)",
                          [id0, id1, id2])
        })
        db.transaction(function (tx) {
            tx.executeSql("COMMIT")
        })
        nameInput.text = ""
        passwordInput.text = ""
    }

    function getUserNm() {

        var id4 = ""

        db.transaction(function (tx) {
            var table = tx.executeSql("SELECT studusername FROM studusertbl")
            id4 = table.rows.item(0).studusername
        })

        return id4
    }
    function getUserPwd() {

        var id5 = ""

        db.transaction(function (tx) {
            var table = tx.executeSql("SELECT studpw  FROM studusertbl")
            id5 = table.rows.item(0).studpw
        })

        return id5
    }

    function insertStudRemoteKey(skey) {
        var id11 = skey

        db.transaction(function (tx) {
            tx.executeSql("UPDATE studusertbl SET studkey = ?", [id11])
        })
        db.transaction(function (tx) {
            tx.executeSql("COMMIT")
        })
    }

    function sendCreds() {

        var id8 = getUserNm()
        var id9 = getUserPwd()

        var vars = "username=" + id8 + "&password=" + id9

        var request2 = new XMLHttpRequest()

        request2.onreadystatechange = function () {
            if (request2.readyState === XMLHttpRequest.DONE) {

                //if (request2.status == 200) {
                if (request2.readyState == 4) {

                    var response = JSON.parse(request2.responseText)

                    //doe hier een insert van de user id in localstorage:
                    insertStudRemoteKey(response.id)
                } else {


                    //console.log("AP-Status: " + request2.status + ", Status Text: " + request2.statusText)
                }
            }
        }

        request2.open("POST", "https://studlist.eu/credsload.php", true)
        request2.setRequestHeader("Content-type",
                                  "application/x-www-form-urlencoded")

        request2.send(vars)
    }

    Flickable {

        anchors.topMargin: units.gu(6)

        anchors.fill: parent
        id: accFlick
        contentHeight: 1400
        flickableDirection: Flickable.VerticalFlick

        Column {

            id: accrect
            width: parent.width
            spacing: units.gu(2)
            anchors {

                margins: units.gu(2)
                fill: parent
            }

            Label {

                width: parent.width
                id: lab1
                wrapMode: Text.Wrap

                text: i18n.tr("Log in to your account or create one at ")
                      + " <a href=\"https://studlist.eu\">https://studlist.eu</a><br>" + i18n.tr(
                          "(Or ignore and keep stUdlist on your device only):")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            TextField {
                id: nameInput
                width: parent.width
                height: 80
                font.pixelSize: 40
                color: "orange"
                onAccepted: passwordInput.forceActiveFocus()
                placeholderText: i18n.tr("Username")
                KeyNavigation.tab: passwordInput
            }

            TextField {
                id: passwordInput
                width: parent.width
                height: 80
                font.pixelSize: 40
                color: "orange"
                placeholderText: i18n.tr("Password")
                echoMode: TextInput.Password
                KeyNavigation.tab: loginButton
            }


            /*   */
            Row {
                id: row1

                Button {
                    id: loginButton
                    text: i18n.tr("Save")
                    onClicked: {
                        insertStudUser(0, nameInput.text, passwordInput.text)
                        sendCreds()
                        labBottom.text = getUserNm()
                    }
                }
            }
            Rectangle {
                color: "#C4DEDE"
                width: parent.width
                height: 180

                radius: 18

                Label {
                    id: labTop
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    // TRANSLATORS: "Account registered:" in this case meaning: "the account that is registered"
                    text: i18n.tr("Account registered:")
                    font.pixelSize: 40
                    width: parent.width
                    height: 90
                }
                Label {
                    id: labBottom
                    anchors.bottom: parent.bottom
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: getUserNm()
                    font.pixelSize: 40
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                    width: parent.width
                    height: 90
                }
            }
        }
    }
}
