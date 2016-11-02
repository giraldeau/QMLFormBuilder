import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    visible: true
    width: 340
    height: 580
    title: qsTr("Hello World")

    SwipeView {
        id: swipeView
        anchors.fill: parent

        Page {
            id: page
            width: parent.width
            height: parent.height

            property var fields: [
                {"data_type":"string", "field_type":"textfield", "lenght":"150", "field_name":"username", "label":"Username", "value": "Enoque Joseneas"},
                {"data_type":"string", "field_type":"textarea", "lenght":"250", "field_name":"address", "label":"Address", "value": "Rua A Bloco D, nº 350 Ap 21"},
                {"data_type":"char", "field_type":"radio", "lenght":"1", "field_name":"sexo", "checked_option":"M", "checked_label":"Masculino", "options":[{"label":"Masculino","value":"M"},{"label":"Feminino","value":"F"},{"label":"Outro","value":"O"}], "label":"Sex"},
                {"data_type":"string", "field_type":"datepicker", "lenght":"10", "field_name":"data_nascimento", "label":"Birthday", "value": "04-21-1987"},
                {"data_type":"string", "field_type":"textfield", "lenght":"80", "field_name":"email", "label":"Email", "value": "enoquejoseneas@gmail.com"}
            ]

            FormBuild {
                formJson: page.fields
                onFormUpdate: console.log("data: " + JSON.stringify(data))
            }
        }
    }
}
