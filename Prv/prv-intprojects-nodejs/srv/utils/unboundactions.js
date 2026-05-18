const { TextBundle } = require("@sap/textbundle")

const getDefaultCreationObject = async (oRequest) => {
    let oCountryId = await SELECT.one.from`US_COUNTRIES`.where`USER_ID = ${oRequest.user.id}`
    let oDefaultActions = {}
    if (oCountryId) {
        switch (oCountryId.COUNTRY_ID) {
            case 'FR':
                oDefaultActions = getDefaultActionsFR(oRequest)
                break
            case 'GB':
                oDefaultActions = getDefaultActionsGB(oRequest)
                break
            default:
                oDefaultActions = getDefaultActionsGB(oRequest)
                break
        }
    }
    return oDefaultActions
}

/**************** private methods *******************/
const getDefaultActionsFR = (oRequest) => {
    const oTexts = new TextBundle('../_i18n/i18n', oRequest.locale)
    return {
        defaultOptionId: 'DEF',
        CreationConfigs: [
            {
                ID: 'DEF', //Default Projects
                description: oTexts.getText('creationDEF'), //'Créer un projet Default', 
                Fields: [
                    { name: 'requestedDate', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: oRequest.timestamp },
                    { name: 'siteId', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null },
                    { name: 'projectObjective', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null },
                    { name: 'preferredProvider', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null }
                ]
            },
            {
                ID: 'SIN', //Sinister Projects
                description: oTexts.getText('creationSIN'), //'Créer un projet Sinister',
                Fields: [
                    { name: 'requestedDate', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: oRequest.timestamp },
                    { name: 'siteId', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null },
                    { name: 'projectObjective', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null },
                    { name: 'preferredProvider', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null }
                ]
            },
            {
                ID: 'DIS', //Disassembly projects
                description: oTexts.getText('creationDIS'), //'Créer un projet Disassembly',
                Fields: [
                    { name: 'requestedDate', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: oRequest.timestamp },
                    { name: 'siteId', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null },
                    { name: 'projectObjective', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null },
                    { name: 'preferredProvider', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null }
                ]
            }
        ]
    }
}

const getDefaultActionsGB = (oRequest) => {
    return {
        defaultOptionId: 'NEW',
        CreationConfigs: [
            {
                ID: 'NEW',
                description: 'Create default project',
                Fields: [
                    { name: 'requestedDate', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: oRequest.timeStamp },
                    { name: 'siteId', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null },
                    { name: 'projectObjective', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null },
                    { name: 'preferredProvider', visible: true, editable: true, mandatory: true, defaultValueInteger: null, defaultValueString: null, defaultValueDate: null }
                ]
            }
        ]
    }
}

module.exports = {
    getDefaultCreationObject
}