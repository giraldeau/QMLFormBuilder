import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.2 as Dialogs

Item {
    anchors.fill: parent

    property real fieldWidth: parent && parent.width > 0 ? parent.width * 0.80 : 250

    /**
     * a array with object fields name:value - like this:
     *  {"username":"enoque joseneas","email":"enoquejoseneas@gmail.com"}
     * The values will be saved after any change or enter new characters in the field
     */
    property var formData: ({})

    /**
     * a array with object to build the form fields. This property needs to be equals this:
     * [{"data_type":"string", "field_type":"textfield", "lenght":"150", "field_name":"username", "label":"Username", "value": "Enoque Joseneas"},
     * {"data_type":"string", "field_type":"textarea", "lenght":"250", "field_name":"address", "label":"Address", "value": "Rua A Bloco D, nº 350 Ap 21"},
     * {"data_type":"char", "field_type":"radio", "lenght":"1", "field_name":"sexo", "checked_option":"M", "checked_label":"Masculino", "options":[{"label":"Masculino","value":"M"},{"label":"Feminino","value":"F"},{"label":"Outro","value":"O"}], "label":"Sex"},
     * {"data_type":"string", "field_type":"datepicker", "lenght":"10", "field_name":"data_nascimento", "label":"Birthday", "value": "04-21-1987"},
     * {"data_type":"string", "field_type":"textfield", "lenght":"80", "field_name":"email", "label":"Email", "value": "enoquejoseneas@gmail.com"}]
     */
    property var formJson: []

    /**
      * a flag to turn the fields form editable, empty values or with values in the fields.
      * The possible values for action is: "newRegister", "edition", "view" (default)
      * 1) if isset to "view" all fields will in "readonly" mode
      * 2) if isset to "edition" all fields will not in "readonly" mode and fields have the value setted (if exists)
      * 3) if isset to "newRegister" all fields will not in "readonly" mode and fields have a empty value or not selected any value
      */
    property string actionType: "view"

    /**
      * on each field change, the value will be saved in formData and this signal will be emitted
      * to client use for catch the new values.
      * Client can create a conection to this signal to get the new values after edition
      */
    onFormDataChanged: formUpdate(formData)

    signal formUpdate(var data)

    function save(fieldName, fieldValue) {
        var objectTemp = formData
        objectTemp[fieldName] = fieldValue
        formData = objectTemp
    }

    Component {
        id: radioComponent

        Item {
            width: fieldWidth
            height: radioRepeater.implicitHeight < 40 ? 40 : radioRepeater.implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter

            property var args: ({})

            TextField {
                id: optionRadioAction
                text: actionType === "newRegister" ? "" : args["checked_label"]
                anchors.horizontalCenter: parent.horizontalCenter
                width: fieldWidth
                readOnly: actionType !== "edit"
                onActiveFocusChanged: {
                    if (!readOnly && focus)
                        dialogRadio.open()
                    else
                        dialogRadio.close()
                }
            }

            Dialogs.Dialog {
                id: dialogRadio
                standardButtons: Dialogs.StandardButton.Save | Dialogs.StandardButton.Cancel
                onVisibleChanged: {
                    if (!dialogRadio.visible)
                        optionRadioAction.focus = false
                }
                onAccepted: {
                    optionRadioAction.focus = false
                    optionRadioAction.text = radioOptionGroup.checkedButton.text
                    save(args["field_name"], radioOptionGroup.checkedButton.value)
                }
                onDiscard: {
                    optionRadioAction.focus = false
                }
                onRejected: {
                    optionRadioAction.focus = false
                }

                ButtonGroup {
                    id: radioOptionGroup
                }

                Column {
                    anchors {
                        fill: parent
                        horizontalCenter: parent.horizontalCenter
                    }

                    Repeater {
                        id: radioRepeater
                        model: args["options"]

                        RadioButton {
                            checked: actionType !== "newRegister" && modelData.value === args["checked_option"]
                            text: modelData.label
                            width: fieldWidth

                            ButtonGroup.group: radioOptionGroup

                            property string value: modelData.value
                        }
                    }
                }
            }
        }
    }

    Component {
        id: datePickerComponent

        Item {
            width: fieldWidth
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter

            property var args: ({})

            Dialogs.Dialog {
                id: dialogDateChoose
                standardButtons: Dialogs.StandardButton.Save | Dialogs.StandardButton.Cancel
                onVisibleChanged: {
                    if (!dialogDateChoose.visible)
                        dateChooseAction.focus = false
                }
                onAccepted: {
                    dateChooseAction.focus = false
                    dateChooseAction.text = dateChooser.month + "-" + dateChooser.day + "-" + dateChooser.year
                    save(args["field_name"], dateChooseAction.text)
                }
                onDiscard: {
                    dateChooseAction.focus = false
                }
                onRejected: {
                    dateChooseAction.focus = false
                }

                DateChooser {
                    id: dateChooser
                    width: fieldWidth
                    valueSelected: actionType === "newRegister" ? "" : args["value"]
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            TextField {
                id: dateChooseAction
                text: actionType === "newRegister" ? "" : args["value"]
                width: parent.width
                readOnly: actionType !== "edit"
                anchors.horizontalCenter: parent.horizontalCenter
                onActiveFocusChanged: {
                    if (!readOnly && focus)
                        dialogDateChoose.open()
                    else
                        dialogDateChoose.close()
                }
            }
        }
    }

    Component {
        id: textFieldComponent

        TextField {
            width: fieldWidth
            inputMethodHints: args["field_name"].indexOf("email") ? Qt.ImhEmailCharactersOnly|Qt.ImhLowercaseOnly : Qt.ImhNone
            maximumLength: args["lenght"]
            text: actionType === "newRegister" ? "" : args["value"]
            readOnly: actionType !== "edit"
            anchors.horizontalCenter: parent.horizontalCenter
            onTextChanged: save(args["field_name"], text)

            property var args: ({})
        }
    }

    Component {
        id: textAreaComponent

        TextArea {
            width: fieldWidth
            text: actionType === "newRegister" ? "" : args["value"]
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#444"
            readOnly: actionType !== "edit"
            onTextChanged: save(args["field_name"], text)

            property var args: ({})
        }
    }

    Flickable {
        id: flickable
        contentHeight: Math.max(formContent.implicitHeight + 50, height)
        anchors {
            fill: parent
            top: parent.top
            topMargin: 16
        }

        ColumnLayout {
            id: formContent
            spacing: 16
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: formJson
                width: parent.width

                Column {
                    id: column
                    spacing: 0
                    width: parent.width

                    Label {
                        color: "#777"
                        font.bold: true
                        text: modelData.label
                    }

                    QtObject {
                        Component.onCompleted: {
                            switch (modelData.field_type) {
                                case "textfield":
                                    textFieldComponent.createObject(column, {"args":modelData})
                                    break
                                case "textarea":
                                    textAreaComponent.createObject(column, {"args":modelData})
                                    break
                                case "radio":
                                    radioComponent.createObject(column, {"args":modelData})
                                    break
                                case "datepicker":
                                    datePickerComponent.createObject(column, {"args":modelData})
                                    break
                            }
                        }
                    }
                }
            }

            RowLayout {
                width: flickable.implicitWidth * 10
                height: Button.height + 10

                Button {
                    text: actionType === "edit" ? "lock fields" : "edit"
                    onClicked: actionType = actionType === "edit" ? "view" : "edit"
                }

                Button {
                    text: "Save"
                    enabled: actionType === "edit"
                    onClicked: formUpdate(formData)
                }
            }
        }
    }
}
