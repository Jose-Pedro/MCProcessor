const { setCustomerAsResponsible } = require('./blocks')
const { ChecklistFieldType, Roles } = require('./enumerations')

const getDefaultChecklistItems = async (oRequest, oRequestHead, oPhaseHead, oBlockHead, aChecklistItems) => {
    let aItemTypesPerBlock = await SELECT .from `Checklist.ItemTypesPerBlock` .where `defaulted = true and active != false and activeType != false and processId = ${oRequestHead.PROCESS_ID} and phaseType = ${oPhaseHead.MASTER_PHASE_ID} and blockType = ${oBlockHead.MASTER_BLOCK_ID}`
    for (let oItemTypePerBlock of aItemTypesPerBlock) {
        let oItemType = await SELECT .one .from `Checklist.ItemType` .where `active = true and ID = ${oItemTypePerBlock.type}`
        if (oItemType) {
            let oItem = {
                ID              : cds.utils.uuid(),
                createdAt       : oRequest.timestamp,       
                createdBy       : oRequest.user.id,
                modifiedAt      : oRequest.timestamp,
                modifiedBy      : oRequest.user.id,
                description     : oItemType.description,
                deleted         : false,
                type_ID         : oItemType.ID,
                mandatory       : oItemTypePerBlock.mandatory? true: false,
                booleanValue    : oItemTypePerBlock.defaultBoolean? true: false,
                stringValue     : oItemTypePerBlock.defaultString? oItemTypePerBlock.defaultStringue: null,
                dateValue       : oItemTypePerBlock.defaultDate? oItemTypePerBlock.defaultDate: null,
                integerValue    : oItemTypePerBlock.defaultInteger? oItemTypePerBlock.defaultInteger: null,
                decimalValue    : oItemTypePerBlock.defaultDecimal? oItemTypePerBlock.defaultDecimal: null,
                pickList        : oItemTypePerBlock.defaultPicklist? oItemTypePerBlock.defaultPicklist: null,
                block_ID        : oBlockHead.BLOCK_ID
            }
            aChecklistItems.push(oItem)
        }
    }
}

const checkMandatoryChecklistItems = async (oRequest, sBlockId) => {
    let aChecklistItems = await SELECT .from `Checklist.Item` .where `block_ID = ${sBlockId} and mandatory = true and ( deleted is null or deleted = false )`
    for (let oCheckListItem of aChecklistItems) {
        let oChecklistItemType = await SELECT .one .from `Checklist.ItemType` .where `ID = ${oCheckListItem.type_ID}`
        switch (oChecklistItemType.valueType_ID) {
            case ChecklistFieldType.BOOLEAN:
                if (oCheckListItem.booleanValue === null) oRequest.error(400, 'missingMandatoryChecklistItems')
                break
            case ChecklistFieldType.STRING:
                if (!oCheckListItem.stringValue || oCheckListItem.stringValue === '') oRequest.error(400, 'missingMandatoryChecklistItems')
                break
            case ChecklistFieldType.DATE:
                if (!oCheckListItem.dateValue) oRequest.error(400, 'missingMandatoryChecklistItems')
                break
            case ChecklistFieldType.INTEGER:
                if (!oCheckListItem.integerValue) oRequest.error(400, 'missingMandatoryChecklistItems')
                break
            case ChecklistFieldType.DECIMAL:
                if (!oCheckListItem.decimalValue) oRequest.error(400, 'missingMandatoryChecklistItems')
                break
            case ChecklistFieldType.PICKLIST:
                if (!oCheckListItem.pickList) oRequest.error(400, 'missingMandatoryChecklistItems')
                break
        }
    }
}

const checkUserAuth = async (oRequest, roleId, sResponsible) => {
    let bReturn = true
    if (oRequest.user.is(Roles.CELLNEX_USER_ROL)) {
        let isManager = oRequest.user.is(Roles.MANAGER_USER_ROL)
        if (oRequest.user.is(roleId) || isManager) {
            if (isManager) {
            } else {
                if (sResponsible !== oRequest.user.id) bReturn = false
            }
        } else {
            bReturn = false
        }
    } else {
        if (oRequest.user.is(Roles.VENDOR_USER_ROL)) {
            if (oRequest.agoraCurrentUserData.vendor !== sResponsible || sResponsible === null || sResponsible === '') bReturn = false
        } else if (oRequest.user.is(Roles.AGENCY_USER_ROL)) {
            if (oRequest.agoraCurrentUserData.agency !== sResponsible || sResponsible === null || sResponsible === '') bReturn = false
        } else if (oRequest.user.is(Roles.CUSTOMER_USER_ROL)) {
            if (oRequest.agoraCurrentUserData.customer !== sResponsible || sResponsible === null || sResponsible === '') bReturn = false
        }
    }
    return bReturn
}

module.exports = {
    getDefaultChecklistItems,
    checkMandatoryChecklistItems,
    checkUserAuth
}