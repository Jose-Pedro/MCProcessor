const { DisplayTypesFC, ChecklistFieldType, BlockStatus, RequestStatus, Actions, valueFieldMap } = require('../utils/enumerations')
const { AfterCreate, AfterRead, AfterUpdate, } = require('../utils/checklistExitHandlers')
const { logChecklistEvent } = require('../utils/AuditLogger')
const { checkUserAuth } = require('../utils/checklists')
const { UserCode } = require('./users')

class ChecklistItemsCode {

    beforeCreateChecklistItems = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if ('block_ID' in oRequest.data && 'type_ID' in oRequest.data) {
                let oPrevItem = await SELECT.one.from`Checklist.Item`.where`block_ID = ${oRequest.data.block_ID} and type_ID = ${oRequest.data.type_ID} and deleted != true`
                if (oPrevItem) {
                    oRequest.error(400, 'duplicateChecklistItem')
                    return
                }
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.data.block_ID})`
                if (oEntities) {
                    let oBlockProvision = await SELECT.one.from`project.BlockProvision`.where`ID = ${oEntities.BLOCK_ID}`
                    let sResponsible = oBlockProvision.subcontractorType === 0 ? oBlockProvision.internalResponsible : oBlockProvision.externalResponsible
                    if (!(await checkUserAuth(oRequest, oEntities.role, sResponsible))) oRequest.error(401, 'notAuthorized')
                    if (oRequest.errors) return
                    let oItemTypePerBlock = await SELECT.one.from`Checklist.ItemTypesPerBlock`.where`active != false and activeType != false and processId = ${oEntities.PROCESS_ID} and phaseType = ${oEntities.MASTER_PHASE_ID} and blockType = ${oEntities.MASTER_BLOCK_ID} and type = ${oRequest.data.type_ID}`
                    if (oItemTypePerBlock) {
                        let oItemType = await SELECT.one.from`Checklist.ItemType`.where`active = true and ID = ${oItemTypePerBlock.type}`
                        const params = {
                            blockId: oEntities.BLOCK_ID,
                            requestId: oEntities.REQUEST_ID,
                            requestType: oEntities.REQUEST_TYPE,
                            masterBlockId: oEntities.MASTER_BLOCK_ID,
                            masterPhaseId: oEntities.MASTER_PHASE_ID,
                            phaseId: oEntities.PHASE_ID,
                            description: oItemType?.description
                        }
                        if (oItemType) {
                            oRequest.data.description = oItemType.description
                            oRequest.data.mandatory = oItemTypePerBlock.mandatory ? true : false
                            oRequest.data.deleted = false
                            switch (oItemType.valueType_ID) {
                                case ChecklistFieldType.BOOLEAN:
                                    oRequest.data.booleanValue = oItemTypePerBlock.defaultBoolean
                                    break
                                case ChecklistFieldType.STRING:
                                    oRequest.data.stringValue = oItemTypePerBlock.defaultString
                                    break
                                case ChecklistFieldType.DATE:
                                    oRequest.data.dateValue = oItemTypePerBlock.defaultDate
                                    break
                                case ChecklistFieldType.INTEGER:
                                    oRequest.data.integerValue = oItemTypePerBlock.defaultInteger
                                    break
                                case ChecklistFieldType.DECIMAL:
                                    oRequest.data.decimalValue = oItemTypePerBlock.defaulDecimal
                                    break
                                case ChecklistFieldType.PICKLIST:
                                    oRequest.data.pickList = oItemTypePerBlock.defaultPicklist
                                    break
                            }

                            await logChecklistEvent(oRequest, Actions.CHECKLIST_CREATE, params)
                        } else {
                            oRequest.error(400, 'invalidItemType')
                        }
                    } else {
                        oRequest.error(400, 'invalidItemType')
                    }
                } else {
                    oRequest.error(400, 'blockNotFound')
                }
            } else {
                oRequest.error(400, 'missingParameters')
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    afterReadChecklistItems = async (oResult, oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            let aResults = oResult.constructor === Array ? oResult : [oResult]
            let oEntities = null
            let bHasAuth = false
            let sEditable = false
            let oItemTypesPerBlock
            let sDisplayType = DisplayTypesFC.HIDDEN
            for (let oListItem of aResults) {
                let oCheckListItem = await SELECT.one.from`Checklist.Item`.where`ID = ${oListItem.ID}`
                let oItemType = await SELECT.one.from`Checklist.ItemType`.where`ID = ${oCheckListItem.type_ID}`
                if (oItemType && oItemType.valueType_ID === ChecklistFieldType.PICKLIST && oListItem.pickList) {
                    let oItemTypeValue = await SELECT.one.from`project.ItemTypeValues`.where`itemType_ID = ${oItemType.ID} and pickList = ${oListItem.pickList}`
                    oListItem.picklistValueName = oItemTypeValue?.description
                }
                let oItemTypeDesc = await SELECT.one.from`project.ItemTypes`.where`ID = ${oItemType.ID}`
                oListItem.description = oItemTypeDesc?.description
                if (oCheckListItem.mandatory === true) oListItem.rowStatus = 'Error'
                if (!oEntities) {
                    oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oCheckListItem.block_ID})`
                    if (!oEntities) continue
                    let oBlockProvision = await SELECT.one.from`project.BlockProvision`.where`ID = ${oEntities.BLOCK_ID}`
                    if (!oBlockProvision) continue
                    let sResponsible = oBlockProvision.subcontractorType === 0 ? oBlockProvision.internalResponsible : oBlockProvision.externalResponsible
                    bHasAuth = await checkUserAuth(oRequest, oEntities.role, sResponsible)
                    if (oEntities.BLOCK_STATUS === BlockStatus.BLOCK_INPROGRESS && bHasAuth) {
                        sEditable = true
                        sDisplayType = DisplayTypesFC.OPTIONAL
                    } else {
                        sEditable = false
                        sDisplayType = DisplayTypesFC.READONLY
                    }
                }
                oItemTypesPerBlock = await SELECT.one.from`Checklist.ItemTypesPerBlock`.where`defaulted = true and active != false and activeType != false and processId = ${oEntities.PROCESS_ID} and phaseType = ${oEntities.MASTER_PHASE_ID} and blockType = ${oEntities.MASTER_BLOCK_ID} and type = ${oCheckListItem.type_ID}`
                oListItem.order = oItemTypesPerBlock?.order
                oListItem.editable = sEditable
                oListItem.descriptionFC = DisplayTypesFC.READONLY
                oListItem.booleanValueFC = DisplayTypesFC.HIDDEN
                oListItem.stringValueFC = DisplayTypesFC.HIDDEN
                oListItem.dateValueFC = DisplayTypesFC.HIDDEN
                oListItem.integerValueFC = DisplayTypesFC.HIDDEN
                oListItem.decimalValueFC = DisplayTypesFC.HIDDEN
                oListItem.pickListFC = DisplayTypesFC.HIDDEN
                switch (oItemType.valueType_ID) {
                    case ChecklistFieldType.BOOLEAN:
                        oListItem.booleanValueFC = sDisplayType
                        break
                    case ChecklistFieldType.STRING:
                        oListItem.stringValueFC = sDisplayType
                        break
                    case ChecklistFieldType.DATE:
                        oListItem.dateValueFC = sDisplayType
                        break
                    case ChecklistFieldType.INTEGER:
                        oListItem.integerValueFC = sDisplayType
                        break
                    case ChecklistFieldType.DECIMAL:
                        oListItem.decimalValueFC = sDisplayType
                        break
                    case ChecklistFieldType.PICKLIST:
                        oListItem.pickListFC = sDisplayType
                        break
                    default:
                        oListItem.stringValueFC = sDisplayType
                        break
                }
                if (oItemTypesPerBlock) {
                    oListItem.refreshEntity = oItemTypesPerBlock.refreshEntity
                    switch (oListItem.refreshEntity) {
                        case 'block':
                            oListItem.refreshEntity = oListItem.refreshEntity + '@' + oEntities.BLOCK_ID
                            break
                        case 'phase':
                            oListItem.refreshEntity = oListItem.refreshEntity + '@' + oEntities.PHASE_ID
                            break
                        case 'request':
                            oListItem.refreshEntity = oListItem.refreshEntity + '@' + oEntities.REQUEST_ID
                            break
                    }
                }
            }
            aResults.sort((a, b) => a.order - b.order)
        } catch (oError) {
                oRequest.error(400, oError.message)
        }
    }

    beforeUpdateChecklistItems = async (oRequest) => {
        try {
            const oChecklistItem = await SELECT.one.from`Checklist.Item`.where`ID = ${oRequest.data.ID}`;
            if (!oChecklistItem) return;

            const oItemType = await SELECT.one.from`Checklist.ItemType`.where`ID = ${oChecklistItem.type_ID}`;
            const params = await this.#getParamsBase(oChecklistItem);

            if ( oItemType && oItemType.valueType_ID === ChecklistFieldType.PICKLIST && (oRequest.data.pickList || oChecklistItem.pickList) && oRequest.data.pickList !== oChecklistItem.pickList ) {
                const { oItemTypeValueOld, oItemTypeValueNew } = await this.#getItemTypeValues(oItemType, oChecklistItem, oRequest)
                params.oldValue = oItemTypeValueOld? `${oItemTypeValueOld.description} (${oChecklistItem.pickList})`: null
                params.newValue = oItemTypeValueNew? `${oItemTypeValueNew.description} (${oRequest.data.pickList})`: null
            }
            else if (oItemType && oItemType.valueType_ID !== ChecklistFieldType.PICKLIST) {
                const { oldValue, newValue } = this.#getFieldValues(oItemType, oChecklistItem, oRequest)
                params.oldValue = oldValue
                params.newValue = newValue
            }

            await logChecklistEvent(oRequest, Actions.CHECKLIST_UPDATE, params)
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    afterUpdateChecklistItems = async (oData, oRequest) => {
        try {
            let oChecklistItem = await SELECT.one.from`Checklist.Item`.where`ID = ${oData.ID}`
            if (oChecklistItem) {
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oChecklistItem.block_ID})`
                let oItemTypesPerBlock = await SELECT.one.from`Checklist.ItemTypesPerBlock`.where`defaulted = true and active != false and activeType != false and processId = ${oEntities.PROCESS_ID} and phaseType = ${oEntities.MASTER_PHASE_ID} and blockType = ${oEntities.MASTER_BLOCK_ID} and type = ${oChecklistItem.type_ID}`
                if (oItemTypesPerBlock && oItemTypesPerBlock.afterUpdate && oItemTypesPerBlock.afterUpdate !== '') {
                    if (typeof AfterUpdate[oItemTypesPerBlock.afterUpdate] === 'function') {
                        await AfterUpdate[oItemTypesPerBlock.afterUpdate](oRequest, oChecklistItem, oEntities)
                    }
                }
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onReadAfterCreateExits = (oRequest) => {
        let builtIns = ['length', 'name', 'prototype'];
        oRequest.reply(Object.getOwnPropertyNames(AfterCreate)
            .filter(prop => typeof AfterCreate[prop] === 'function' && !builtIns.includes(prop))
            .map((methodName, index) => ({ ID: methodName })))
    }

    onReadAfterReadExits = (oRequest) => {
        let builtIns = ['length', 'name', 'prototype'];
        oRequest.reply(Object.getOwnPropertyNames(AfterRead)
            .filter(prop => typeof AfterRead[prop] === 'function' && !builtIns.includes(prop))
            .map((methodName, index) => ({ ID: methodName })))
    }

    onReadAfterUpdateExits = (oRequest) => {
        let builtIns = ['length', 'name', 'prototype'];
        oRequest.reply(Object.getOwnPropertyNames(AfterUpdate)
            .filter(prop => typeof AfterUpdate[prop] === 'function' && !builtIns.includes(prop))
            .map((methodName, index) => ({ ID: methodName })))
    }

    onDeleteChecklistItems = async (oRequest) => {
        if (oRequest.data && oRequest.data.ID) {
            try {
                let oChecklistItem = await SELECT.one.from`Checklist.Item`.where`ID = ${oRequest.data.ID}`
                if (oChecklistItem) {
                    const params = {
                        blockId: oChecklistItem.block_ID,
                        description: oChecklistItem.description
                    }
                    await logChecklistEvent(oRequest, Actions.CHECKLIST_DELETED, { ...params, })
                }
                await UPDATE('Checklist.Item').set({ deleted: true, deletedAt: oRequest.timestamp, deletedBy: oRequest.user.id }).where({ ID: oRequest.data.ID })

            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        }
    }

    #getItemTypeValues = async (oItemType, oChecklistItem, oRequest) => {
        let oItemTypeValueOld = null;
        let oItemTypeValueNew = null;

        if (oChecklistItem.pickList) {
            oItemTypeValueOld = await SELECT.one.from`Checklist.ItemTypeValue`
                .where`itemType_ID = ${oItemType.ID} and pickList = ${oChecklistItem.pickList}`;
        }

        if (oRequest.data.pickList) {
            oItemTypeValueNew = await SELECT.one.from`Checklist.ItemTypeValue`
                .where`itemType_ID = ${oItemType.ID} and pickList = ${oRequest.data.pickList}`;
        }

        return { oItemTypeValueOld, oItemTypeValueNew };
    }

    #getFieldValues = (oItemType, oChecklistItem, oRequest) => {
        const fieldName = valueFieldMap[oItemType?.valueType_ID];
        if (!fieldName) throw new Error(`Unsupported valueType_ID: ${oItemType?.valueType_ID}`);

        let oldValue = oChecklistItem[fieldName];
        let newValue = oRequest.data[fieldName];

        if (oItemType.valueType_ID === ChecklistFieldType.DATE) {
            const formatDate = (d) => (d ? new Date(d).toISOString().split("T")[0] : null);
            oldValue = formatDate(oldValue);
            newValue = formatDate(newValue);
        }

        return { oldValue: oldValue ?? null, newValue: newValue ?? null };
    }

    #getParamsBase = async (oChecklistItem) => {
        const oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oChecklistItem.block_ID})`;
        return {
            blockId: oEntities.BLOCK_ID,
            requestId: oEntities.REQUEST_ID,
            requestType: oEntities.REQUEST_TYPE,
            masterBlockId: oEntities.MASTER_BLOCK_ID,
            masterPhaseId: oEntities.MASTER_PHASE_ID,
            phaseId: oEntities.PHASE_ID,
            description: oChecklistItem.description
        };
    }

}

module.exports = {
    ChecklistItemsCode
}