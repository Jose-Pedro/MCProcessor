const {ComplexFields, DisplayTypesFC} = require('./enumerations')

class ComplexFieldsLogic {

    static getVisibilityForField = (bIsHeader, fieldName, oEntities, oHead, oProvision) => {
        let iReturn = null
        let aFunctions = this.getLogicForField( bIsHeader, oEntities, fieldName)
        if (aFunctions) {
            for(let sFunction of aFunctions) {
                iReturn = [sFunction](sField, oHead, oProvision, oEntities)
            }
        }
        return iReturn
    }

    static setVisibilityForField = (bIsHeader, fieldName, oEntities, oHead, oProvision) => {
        let aFunctions = this.getLogicForField( bIsHeader, oEntities, fieldName)
        if (aFunctions) {
            for(let sFunction of aFunctions) {
                let iFCValue = ComplexFieldsLogic[sFunction](sField, oHead, oProvision, oEntities)
                if(iFCValue !== null) { 
                    oProvision[sField + 'FC'] = iFCValue
                    if (iFCValue === 0 )oProvision[sField] = null
                }
            }
        }
    }

    static getVisibilityForEntity = (bIsHeader, oEntities, oHead, oProvision) => {
        let aReturn = []
        let oFields = this.getLogicForEntity(bIsHeader, oEntities)
        if (oFields) {
            for(let [sField, oFunctions] of Object.entries(oFields)) {
                for(let sFunction of oFunctions.functions) {
                    let iFCValue = ComplexFieldsLogic[sFunction](sField, oHead, oProvision, oEntities)
                    if(iFCValue !== null) aReturn.push({fieldName: sField, iFCValue: iFCValue})
                }
            }
        }
        return aReturn
    }

    static setVisibilityForEntity = (bIsHeader, oEntities, oHead, oProvision) => {
        let oFields = this.getLogicForEntity(bIsHeader, oEntities)
        if (oFields) {
            for(let [sField, oFunctions] of Object.entries(oFields)) {
                for(let sFunction of oFunctions.functions) {
                    let iFCValue = ComplexFieldsLogic[sFunction](sField, oHead, oProvision, oEntities)
                    if (iFCValue !== null) {
                        oProvision[sField + 'FC'] = iFCValue
                        if(iFCValue === 0 )oProvision[sField] = null
                    }
                }
            }
        }
    }

    static getLogicForField = (bIsHeader, oEntities, fieldName) => {
        let aFunctions = []
        if(bIsHeader) {
            aFunctions = this.getData(ComplexFields, 'Head', fieldName)
        } else {
            aFunctions = this.getData(ComplexFields, 'Blocks', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, fieldName)
        }
        return aFunctions
    }

    static getLogicForEntity = (bIsHeader, oEntities) => {
        let oFields 
        if(bIsHeader) {
            oFields = this.getData(ComplexFields, 'Head')
        } else {
            oFields = this.getData(ComplexFields, 'Blocks', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID)
        }
        return oFields
    }

    static getFeasibilityRisk = (fieldName, oHead, oProvision, oEntities) => {
        let iFCValue = null
        if(oProvision) {
            if(fieldName === 'realStateFeasibilityRisk') {
                if(oProvision?.realStateFeasibility === '3') {
                    iFCValue = DisplayTypesFC.MANDATORY
                } else {
                    iFCValue = DisplayTypesFC.HIDDEN
                }
            }
        }
        return iFCValue
    }

    static getFeasibilityExplanation = (fieldName, oHead, oProvision, oEntities) => {
        let iFCValue = null
        if(oProvision) {
            if(fieldName === 'realEstateFeasibilityExp') {
                if(oProvision?.realStateFeasibility === '3') {
                    iFCValue = DisplayTypesFC.MANDATORY
                } else {
                    iFCValue = DisplayTypesFC.HIDDEN
                }
            }
        }
        return iFCValue
    }

    static getPermtiExplanation = (fieldName, oHead, oProvision, oEntities) => {
        let iFCValue = null
        if(oProvision) {
            if(fieldName === 'permitsFeasibilityExp') {
                if(oProvision?.permitsFeasibility === '3') {
                    iFCValue = DisplayTypesFC.MANDATORY
                } else {
                    iFCValue = DisplayTypesFC.HIDDEN
                }
            }
        }
        return iFCValue
    }

    static getRejectionReason = (fieldName, oHead, oProvision, oEntities) => {
        let iFCValue = null
        if(oProvision) {
            if(fieldName === 'rejectionReason') {
                if(oProvision?.accepted === '2') {
                    iFCValue = DisplayTypesFC.MANDATORY
                } else {
                    iFCValue = DisplayTypesFC.HIDDEN
                }
            }
        }
        return iFCValue
    }

    static getData = (oObject, ...keys) => {
        return keys.reduce((object, key) => object?.[key], oObject);
    }

}

module.exports = {
    ComplexFieldsLogic
}