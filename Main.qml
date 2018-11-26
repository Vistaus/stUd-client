import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 0.1
import QtQuick.LocalStorage 2.0
import Ubuntu.Layouts 1.0

MainView {


    objectName: "mainView"

    applicationName: "stud.matv1"

    automaticOrientation: false

    width: units.gu(100)
    height: units.gu(75)

    //hier de authenticatie functies
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

    function getUserKey() {

        var id6 = ""

        db.transaction(function (tx) {
            var table = tx.executeSql("SELECT studkey FROM studusertbl")
            id6 = table.rows.item(0).studkey
        })
        return id6
    }

    function sendCreds() {

        var id8 = getUserNm()
        var id9 = getUserPwd()
        var vars = "username=" + id8 + "&password=" + id9

        var request2 = new XMLHttpRequest()

        request2.onreadystatechange = function () {
            if (request2.readyState === XMLHttpRequest.DONE) {

                if (request2.readyState == 4) {

                    var response = JSON.parse(request2.responseText)
                    //console.log("antwoord: " + response.id)

                    //doe hier een insert van de user id in localstorage:
                    insertStudRemoteKey(response.id)
                } else {

                    //console.log("Status: " + request2.status + ", Status Text: " + request2.statusText)
                }
            }
        }

        request2.open("POST", "https://studlist.eu/credsload.php", true)
        request2.setRequestHeader("Content-type",
                                  "application/x-www-form-urlencoded")

        request2.send(vars)
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

    //einde authenticatie

    //probeer gegevens online te halen:
    function populateModelRemote() {

        var vars = "userid=" + getUserKey()

        //de nieuwe functie:
        var request = new XMLHttpRequest()

        var timer = Qt.createQmlObject(
                    "import QtQuick 2.4; Timer {interval: 5000; repeat: false; running: true;}",
                    main, "MyTimer")
        timer.triggered.connect(function () {
            request.abort()
            populateModel()
        })

        request.onreadystatechange = function () {

            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {

                    var response = JSON.parse(request.responseText)

                    timer.running = false
                    deleteAllLocal()

                    var studdata = JSON.parse(request.responseText)
                    fLoopArray(studdata)

                    function fLoopArray(arr) {
                        var keycounter = 0
                        for (var key in arr) {
                            //var obj = arr[i];
                            var nameTxt = arr[key].listvalue
                            var gotTxt = Number(arr[key].listgot)
                            keycounter++
                            insertRemotelInLocal(keycounter, nameTxt, gotTxt)

                            stUdModel.append({
                                                 name: nameTxt,
                                                 got: gotTxt
                                             })
                        }
                    }
                } else {
                    // waarom praat studlist.eu niet met mij?
                    //console.log("Status: " + request.status + ", Status Text: " + request.statusText)
                }
            }
        }

        request.open("POST", "https://studlist.eu/studload.php", true)
        request.setRequestHeader("Content-type",
                                 "application/x-www-form-urlencoded")

        request.send(vars)
    }

    function ajax_insert(content) {
        var var0 = getUserKey()
        if (var0 != 0) {

            var hr = new XMLHttpRequest()
            var url = "https://studlist.eu/studinsert.php"

            var var1 = content
            var vars = "item=" + var1 + "&ukey=" + var0

            hr.open("POST", url, true)

            hr.setRequestHeader("Content-type",
                                "application/x-www-form-urlencoded")

            hr.onreadystatechange = function () {
                if (hr.readyState == 4 && hr.status == 200) {

                }
            }

            hr.send(vars)
        } else {
            return
        }
    }

    function ajax_delete() {
        var var0 = getUserKey()
        if (var0 != 0) {

            var hr = new XMLHttpRequest()
            var url = "https://studlist.eu/studdelete.php"

            //var var1 = content
            var vars = "item=deleteit" + "&ukey=" + var0

            hr.open("POST", url, true)

            hr.setRequestHeader("Content-type",
                                "application/x-www-form-urlencoded")

            hr.onreadystatechange = function () {
                if (hr.readyState == 4 && hr.status == 200) {

                }
            }

            hr.send(vars)
        } else {
            return
        }
    }

    function ajax_got(thing, got) {
        var var3 = getUserKey()
        if (var3 != 0) {

            var hr = new XMLHttpRequest()
            var url = "https://studlist.eu/studupdategot.php"
            var var1 = thing
            var var2 = got
            var var3 = getUserKey()
            var vars = "item=" + var1 + "&got=" + var2 + "&ukey=" + var3
            hr.open("POST", url, true)

            hr.setRequestHeader("Content-type",
                                "application/x-www-form-urlencoded")

            hr.onreadystatechange = function () {
                if (hr.readyState == 4 && hr.status == 200) {

                }
            }

            hr.send(vars)
        } else {
            return
        }
    }

    //localstorage db initieren:
    property var db: null

    function openLocalDB() {
        if (db !== null)
            return

        db = LocalStorage.openDatabaseSync("studdb", "1.0",
                                           "SQLite stUd Database", 100000)

        try {
            db.transaction(function (tx) {
                tx.executeSql(
                            'CREATE TABLE IF NOT EXISTS studtbl (studkey INTEGER, studvalue TEXT, studgot INTEGER)')
            })
        } catch (err) {
            console.log("Error creating table in database: " + err)
        }
        ;

        try {
            db.transaction(function (tx) {
                tx.executeSql(
                            'CREATE TABLE IF NOT EXISTS studusertbl (studkey INTEGER, studusername TEXT, studpw TEXT)')
            })
        } catch (err) {
            console.log("Error creating table in database: " + err)
        }
        ;
    }

    function rijen2() {
        var id4 = 0
        db.transaction(function (tx) {
            var table = tx.executeSql("SELECT * FROM studtbl")
            id4 = table.rows.length
        })
        return id4
    }

    function maxStudKey() {
        var id4 = 0
        db.transaction(function (tx) {
            var table = tx.executeSql(
                        "SELECT MAX(studkey)as hoogst FROM studtbl")
            id4 = table.rows.item(0).hoogst
        })
        return id4
    }

    function populateModel() {
        db.transaction(function (tx) {
            var resultSet = tx.executeSql(
                        "SELECT studvalue, studgot FROM studtbl")
            for (var i = 0; i <= resultSet.rows.length - 1; i++) {
                var nameTxt = resultSet.rows.item(i).studvalue
                var gotTxt = resultSet.rows.item(i).studgot
                stUdModel.append({
                                     name: nameTxt,
                                     got: gotTxt
                                 })
            }
        })
    }

    function changedGot(ding, waarde) {

        var id1 = ding
        var id2 = waarde
        db.transaction(function (tx) {
            tx.executeSql("UPDATE studtbl SET studgot = ? WHERE studvalue=?",
                          [id2, id1])
        })
    }

    function deleteGot() {

        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM studtbl WHERE studgot = 0")
        })
        stUdModel.clear()
        populateModel()
    }

    function deleteAllLocal() {

        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM studtbl")
        })
        db.transaction(function (tx) {
            tx.executeSql("COMMIT")
        })
    }

    function insertStudItem(content) {
        var id3 = getUserKey()
        var id2 = content

        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO studtbl VALUES (?,?,?)", [id3, id2, 1])
        })
        db.transaction(function (tx) {
            tx.executeSql("COMMIT")
        })
    }

    //alles van remote in local bij start
    function insertRemotelInLocal(studkey, studval, studgot) {

        var id4 = studkey
        var id5 = studval
        var id6 = studgot

        var id2 = input1.text
        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO studtbl VALUES (?,?,?)", [id4, id5, id6])
        })
        db.transaction(function (tx2) {
            tx2.executeSql("COMMIT")
        })
    }

    function getContentOfFlick() {

        var flickheight = (rijen2() - 1) * 96 + topItem.height
        return flickheight
    }

    PageStack {
        id: pageStack
        Component.onCompleted: {
            push(main)
            openLocalDB()
            sendCreds()
            //populateModelRemote()
            if (getUserKey() === 0) {
                populateModel()
            } else {
                populateModelRemote()
            }
            //console.log("aantalrijen lokaal: " + rijen2())
        }

        Page {

            id: main

            header: PageHeader {
                id: pageHeader
                title: i18n.tr("StUd List")
                StyleHints {
                    foregroundColor: UbuntuColors.orange
                    backgroundColor: UbuntuColors.porcelain
                    dividerColor: UbuntuColors.slate
                }
                trailingActionBar {
                    actions: [
                        Action {
                            iconName: "delete"
                            text: i18n.tr("Delete")
                            onTriggered: {
                                deleteGot()
                                ajax_delete()
                                content.resizeContent(topItem.width,
                                                      getContentOfFlick(),
                                                      Qt.point(100, 100))
                                content.returnToBounds()
                            }
                        },
                        Action {
                            iconName: "reload"
                            text: i18n.tr("Reload")
                            onTriggered: {
                                stUdModel.clear()
                                sendCreds()
                                
                                content.resizeContent(topItem.width,
                                                      getContentOfFlick(),
                                                      Qt.point(100, 100))
                                content.returnToBounds()
                                if (getUserKey() === 0) {
                                    populateModel()
                                } else {
                                    populateModelRemote()
                                }
                            }
                        },
                        Action {
                            iconName: "add"
                            text: i18n.tr("Online account")
                            onTriggered: pageStack.push(accountPage)
                        }
                    ]
                }
            }

            Rectangle {

                id: rect1
                height: 90
                width: parent.width

                radius: 18
                border.color: "grey"
                border.width: 1

                anchors.top: pageHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                anchors.topMargin: 12

                TextField {
                    id: input1
                    font.pixelSize: 40
                    color: "black"

                    width: parent.width
                    height: parent.height

                    placeholderText: i18n.tr("add to stUdlist")

                    style: TextFieldStyle {

                        background: Item {
                        }
                        color: "white"
                    }

                    cursorVisible: false
                    onAccepted: {

                        if (text != "") {
                            insertStudItem(input1.text)
                            ajax_insert(input1.text)
                            stUdModel.clear()
                            //testing12
                            content.resizeContent(topItem.width,
                                                  getContentOfFlick(),
                                                  Qt.point(100, 100))
                            content.returnToBounds()
                            populateModel()
                            input1.text = ""
                        }
                    }
                }
            }

            ListModel {
                id: stUdModel
            }
            Item {
                id: topItem
                anchors.top: rect1.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 10
                anchors.topMargin: 12

                Flickable {

                    id: content
                    //testen of dit beter kan:
                    //contentHeight: units.gu(150)
                    anchors.fill: parent

                    contentHeight: getContentOfFlick()

                    clip: true

                    Column {
                        id: kolom
                        spacing: 6
                        width: parent.width

                        Repeater {

                            model: stUdModel
                            delegate: stUdDelegate
                            clip: true

                            Rectangle {

                                id: rectx

                                anchors.left: kolom.left
                                anchors.right: kolom.right
                                anchors.rightMargin: 10

                                height: 90

                                color: "#C4DEDE"

                                states: [
                                    State {
                                        name: "state1"
                                        when: stUdModel.get(index).got === 0
                                        PropertyChanges {
                                            target: stUdItem
                                            font.strikeout: true
                                            font.bold: false
                                            color: "grey"
                                        }
                                    },

                                    State {
                                        name: "state2"
                                        when: stUdModel.get(index).got === 1
                                        PropertyChanges {
                                            target: stUdItem
                                            font.strikeout: false
                                            font.bold: true
                                            color: "black"
                                        }
                                    }
                                ]

                                Text {
                                    id: stUdItem
                                    text: name
                                    font.pixelSize: 55
                                    height: 90
                                    verticalAlignment: Text.AlignVCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                }

                                Rectangle {
                                    id: stUdItemDone
                                    height: parent.height
                                    color: "white"
                                    border.color: "grey"
                                    border.width: 8
                                    width: units.gu(5)
                                    anchors.right: rectx.right
                                    radius: 25
                                    anchors.leftMargin: 10
                                    anchors.topMargin: 6
                                    Rectangle {
                                        id: rectRound
                                        width: 20
                                        height: 20
                                        color: "#A6D6F2"
                                        border.color: "#A6D6F2"
                                        border.width: 1
                                        radius: width * 0.5
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        onClicked: {
                                            var streep
                                            if (stUdItem.font.strikeout == true) {
                                                streep = 1
                                                stUdItemDone.state = "unclicked"
                                            } else {
                                                streep = 0
                                                stUdItemDone.state = "clicked"
                                            }

                                            changedGot(stUdModel.get(
                                                           index).name, streep)
                                            ajax_got(stUdModel.get(index).name,
                                                     streep)
                                        }
                                    }
                                    states: [
                                        State {
                                            name: "clicked"
                                            PropertyChanges {
                                                target: stUdItem
                                                font.strikeout: true
                                                font.bold: false
                                                color: "grey"
                                            }
                                        },

                                        State {
                                            name: "unclicked"
                                            PropertyChanges {
                                                target: stUdItem
                                                font.strikeout: false
                                                font.bold: true
                                                color: "black"
                                            }
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
            }
        }

        AccountPage {
            id: accountPage
            visible: false
            objectName: "accountpage"
        }
    }
}
