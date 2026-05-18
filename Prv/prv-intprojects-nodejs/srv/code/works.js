const { setWorkStatus, checkWorkPendingDocuments, checkBlockHasWorkconfig, setVisibilityForFields, checkCreateWorkAuth, checkWorkAuth, getWorkResponsibleDescriptions } = require('../utils/works')
const { WorkStatus, BlockStatus, AssignedResponsibleTypes, SubcoTypes,  Actions, ParentTypes, DisplayTypesFC } = require('../utils/enumerations')
const { UserCode } = require('./users')
const { checkDocument, getDefaultParamForWorkDocument, addDocumentPerBlock } = require('../utils/documentsperblock')
const { checkInputValues, setFCAs } = require('../utils/configurations')
const { logDocumentEvent, saveLog } = require('../utils/AuditLogger')
const { isSameDayLocal } = require('../utils/dates')

class WorksCode {

    beforeCreateWork = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            let oBlock = await SELECT .one .from `project.Blocks` .where `ID = ${oRequest.data.parentId}`
            let oBlockProvision = await SELECT .one .from `project.BlockProvision` .where `ID = ${oRequest.data.parentId}`
            if(!oBlock) oRequest.error(400, 'missingParentId')
            if(oRequest.errors) return
            if(!(checkCreateWorkAuth(oRequest, oBlock, oBlockProvision))) oRequest.error(401, 'notAuthorized')
            if(oRequest.errors) return
            if(oBlock.status !== BlockStatus.BLOCK_INPROGRESS) oRequest.error(400, 'openBlockFirst')
            if(!(await checkBlockHasWorkconfig(oBlock))) oRequest.error(400, 'blockWithoutWork')
            if(oRequest.errors) return
            oRequest.data.status = WorkStatus.WORK_INPROGRESS
            if (!('parentType_ID' in oRequest.data)) oRequest.data.parentType_ID = ParentTypes.BLOCK
            if(oBlockProvision) {
                oRequest.data.responsibleType = oBlockProvision.assignedResponsible
                oRequest.data.externalType = oBlockProvision.subcontractorType
                oRequest.data.internalResponsible = oBlockProvision.internalResponsible
                oRequest.data.externalResponsible = oBlockProvision.externalResponsible
            }
            await logDocumentEvent(oRequest, Actions.WORK_CREATE, {blockId: oRequest.data.parentId, data: {WORK_ID: oRequest.data.ID}})
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    beforeUpdateWork = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            let oWork = await SELECT .one .from `project.Works` .where `ID = ${oRequest.data.ID}`
            if (oWork) {
                let oParent = await SELECT .one .from `WORKS_BLOCK_PHASE_REQUEST(p_workId: ${oRequest.data.ID})`
                if (!(await checkWorkAuth(oRequest, oParent))) oRequest.error(401, 'notAuthorized')
                if (oRequest.errors) return
                if (oParent.BLOCK_STATUS !== BlockStatus.BLOCK_INPROGRESS || oWork.status !== WorkStatus.WORK_INPROGRESS) oRequest.error(400, 'wrongStatus')
                if ('startDate' in oRequest.data) if (!isSameDayLocal(oRequest.data.startDate, oWork.endDate) && oRequest.data.startDate > oWork.endDate && oWork.endDate !== null) oRequest.error(400, 'wrongWorkStartDate')
                if ('endDate' in oRequest.data) if (!isSameDayLocal(oRequest.data.endDate, oWork.startDate) && oWork.startDate > oRequest.data.endDate && oWork.startDate !== null) oRequest.error(400, 'wrongWorkEndDate')
                if ('expectedStartDate' in oRequest.data)if (!isSameDayLocal(oRequest.data.expectedStartDate, oWork.expectedEndDate) && oRequest.data.expectedStartDate > oWork.expectedEndDate && oWork.expectedEndDate !== null) oRequest.error(400, 'wrongWorkExpectedStartDate')
                if ('expectedEndDate' in oRequest.data) if (!isSameDayLocal(oRequest.data.expectedEndDate, oWork.expectedStartDate) && oWork.expectedStartDate > oRequest.data.expectedEndDate && oWork.expectedStartDate !== null) oRequest.error(400, 'wrongWorkExpectedEndDate')
                if ('realStartDate' in oRequest.data) if (!isSameDayLocal(oRequest.data.realStartDate, oWork.realEndDate) && oRequest.data.realStartDate > oWork.realEndDate && oWork.realEndDate !== null) oRequest.error(400, 'wrongWorkRealStartDate')
                if ('realEndDate' in oRequest.data) if (!isSameDayLocal(oRequest.data.realEndDate, oWork.realStartDate) && oWork.realStartDate > oRequest.data.realEndDate && oWork.realStartDate !== null) oRequest.error(400, 'wrongWorkRealEndDate')
                await checkInputValues(oRequest)
                if(oRequest.errors) return
                if (oRequest.data && 'responsibleType' in oRequest.data) {
                    if (parseInt(oRequest.data.responsibleType,10) === parseInt(AssignedResponsibleTypes.CELLNEX,10)) {
                        oRequest.data.externalType = null
                        oRequest.data.externalResponsible = null
                    } else {
                        oRequest.data.internalResponsible = null
                    }
                }
                //NOSONAR if (oRequest.data && 'externalResponsible' in oRequest.data) oRequest.data.externalResponsible = null
                if (oRequest.data && 'expectedStartDate' in oRequest.data) {
                    if (oWork.startDate === null) oRequest.data.startDate = oRequest.timestamp.toJSON()
                }
            } else {
                oRequest.error(400, 'missingWork')
            }
            await saveLog(oRequest, 'project.Works', Actions.WORK_UPDATE)
        } catch (oError) {
            oRequest.error(400, oError.message)
        }

    }

    afterReadWork = async (oResults, oRequest) => {
        try {
            // await UserCode.currentUserDetails(oRequest)
            let aResults = oResults.constructor === Array? oResults: [oResults]
            for (let oResult of aResults) {
                let oParent = await SELECT .one .from `WORKS_BLOCK_PHASE_REQUEST(p_workId: ${oResult.ID})`
                if (!oParent) continue
                let hasDocFlowParam
                let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oParent.REQUEST_ID}`
                let oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oParent.REQUEST_ID}`;
                if (oRequestHead && oRequestHead.manager && oResult.responsibleType === parseInt(AssignedResponsibleTypes.CELLNEX,10) && oResult.internalResponsible === null) {
                    await UPDATE `WORKS`.set({ 'internalResponsible': oRequestHead.manager }).where`ID = ${oResult.ID}`
                    oResult.internalResponsible = oRequestHead.manager
                } else if (oRequestProvision && oRequestProvision.preferredProvider && oResult.externalResponsible === null && (oResult.externalType === parseInt(SubcoTypes.VENDOR,10) || oResult.externalType === null) && oResult.responsibleType === parseInt(AssignedResponsibleTypes.EXTERNAL,10)) {
                    await UPDATE `WORKS`.set({ 'externalResponsible': oRequestProvision.preferredProvider, 'externalType': parseInt(SubcoTypes.VENDOR,10) }).where`ID = ${oResult.ID}`
                    oResult.externalResponsible = oRequestProvision.preferredProvider;
                    oResult.externalType =  parseInt(SubcoTypes.VENDOR ,10)
                }
                let sWhere = `countryId = '${oParent.COUNTRY_ID}' and processFlowId = ${oParent.PROCESS_ID} and phaseTypeId = '${oParent.MASTER_PHASE_ID}' and blockTypeId = '${oParent.MASTER_BLOCK_ID}'`
                if (oParent.TYPE) sWhere = sWhere + ` and workType = ${oParent.TYPE}`
                if (oParent.PROJECT_OBJECTIVE) sWhere = sWhere + ` and objective = ${oParent.PROJECT_OBJECTIVE}`
                hasDocFlowParam = await SELECT .one .from `project.WorkDocuments` .where(sWhere)
                let hasDPBEntrie = await SELECT .one .from `project.DocumentsPerBlocks` .where `workId = ${oResult.ID} and blockId = ${oResult.blockId}`
                oResult.dpbVisibleVF = (hasDocFlowParam !== undefined || hasDPBEntrie !== undefined)
                let oText = await SELECT .one .from `STATUS_TEXTS` .where `STATUS_CODE = ${oResult.status} and LANGUAGE = ${oRequest.locale.toUpperCase()}`
                if (oText) oResult.statusName = oText.STATUS_TEXT
                setVisibilityForFields(oResult, oParent)
                oResult.hasAuthVF = await checkWorkAuth(oRequest, oParent)
                if(!oResult.hasAuthVF) {
                    setFCAs(oRequest, oResult, DisplayTypesFC.READONLY)
                }
                await getWorkResponsibleDescriptions(oRequest, oParent, oResult)
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    beforeReadWorkDocuments = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            let sWorkId
            let aNewWhere = []
            if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
                let aWhere = oRequest.query.SELECT.where
                for (let i = 0; i < aWhere.length; i++) {
                    if (typeof aWhere[i] === 'object' && 'ref' in aWhere[i] && Array.isArray(aWhere[i].ref) && (aWhere[i].ref[0] === 'workId')) {
                        aNewWhere.pop()
                        sWorkId = aWhere[i + 2].val
                        i = i + 3
                        break
                    } else {
                        aNewWhere.push(aWhere[i])
                    }
                }
            }

            if (sWorkId) {
                let oParent = await SELECT .one .from `WORKS_BLOCK_PHASE_REQUEST(p_workId: ${sWorkId})`
                let sNewConditions = `countryId = '${oParent.COUNTRY_ID}' and objective = ${oParent.PROJECT_OBJECTIVE} and processFlowId = ${oParent.PROCESS_ID} and phaseTypeId = '${oParent.MASTER_PHASE_ID}' and blockTypeId = '${oParent.MASTER_BLOCK_ID}' and workType = ${oParent.TYPE}`
                let oNewConditions = cds.parse.expr(sNewConditions)
                if(aNewWhere.length > 0) {
                    aNewWhere.push('and')
                }
                aNewWhere.push(...oNewConditions.xpr)
                oRequest.query.SELECT.where = aNewWhere
            }

        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onCompleteWork = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if (!oRequest.params || oRequest.params.constructor !== Array || oRequest.params.length < 1) oRequest.error(400, 'missingParameters')
            if (oRequest.errors) return
            let oWork = await SELECT .one .from `project.Works` .where `ID = ${oRequest.params[0]}`
            let oParent = await SELECT .one .from `WORKS_BLOCK_PHASE_REQUEST(p_workId: ${oRequest.params[0]})`
            if (!(await checkWorkAuth(oRequest, oParent))) oRequest.error(401, 'notAuthorized')
            if (oRequest.errors) return
            if (oWork.status === WorkStatus.WORK_INPROGRESS){
                if(!oWork.type_ID || oWork.type_id === 0) oRequest.error(400, 'workTypeMissing')
                if(!oWork.expectedStartDate) oRequest.error(400, 'expectedStartDateMissing')
                if(!oWork.expectedEndDate) oRequest.error(400, 'expectedEndDateMissing')
                if(!oWork.realStartDate) oRequest.error(400, 'realStartDateMissing')
                if(!oWork.realEndDate) oRequest.error(400, 'realEndDateMissing')
                // if(await checkWorkPendingDocuments(oWork)) oRequest.error(400, 'workHasPendingDocuments')
                if(oRequest.errors) return 
                await setWorkStatus(oRequest, WorkStatus.WORK_COMPLETED)
                await logDocumentEvent(oRequest, Actions.WORK_COMPLETE, {workId: oRequest.params[0], data: {WORK_ID: oRequest.params[0]}})
            } else {
                oRequest.error(400, 'wrongWorkStatusForAction')
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onCancelWork = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if (!oRequest.params || oRequest.params.constructor !== Array || oRequest.params.length < 1) oRequest.error(400, 'missingParameters')
            if (!oRequest.data || !('comments' in oRequest.data)) oRequest.error(400, 'missingWorkCancellationComments')
            if (oRequest.errors) return
            let oWork = await SELECT .one .from `project.Works` .where `ID = ${oRequest.params[0]}`
            let oParent = await SELECT .one .from `WORKS_BLOCK_PHASE_REQUEST(p_workId: ${oRequest.params[0]})`
            if (!(await checkWorkAuth(oRequest, oParent))) oRequest.error(401, 'notAuthorized')
            if (oRequest.errors) return
            if (oWork.status === WorkStatus.WORK_INPROGRESS){
                await setWorkStatus(oRequest, WorkStatus.WORK_CANCELLED)
                await logDocumentEvent(oRequest, Actions.WORK_CANCEL, {workId: oRequest.params[0], data: {WORK_ID: oRequest.params[0]}})
            } else {
                oRequest.error(400, 'wrongWorkStatusForAction')
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onReopenWork = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if (!oRequest.params || oRequest.params.constructor !== Array || oRequest.params.length < 1) oRequest.error(400, 'missingParameters')
            if (oRequest.errors) return
            let oWork = await SELECT .one .from `project.Works` .where `ID = ${oRequest.params[0]}`
            let oParent = await SELECT .one .from `WORKS_BLOCK_PHASE_REQUEST(p_workId: ${oRequest.params[0]})`
            if (!(await checkWorkAuth(oRequest, oParent))) oRequest.error(401, 'notAuthorized')
            if (oRequest.errors) return
            if (oWork.status === WorkStatus.WORK_COMPLETED || oWork.status === WorkStatus.WORK_CANCELLED){
                await setWorkStatus(oRequest, WorkStatus.WORK_INPROGRESS)
                await logDocumentEvent(oRequest, Actions.WORK_REOPEN, {workId: oRequest.params[0], data: {WORK_ID: oRequest.params[0]}})
            } else {
                oRequest.error(400, 'wrongWorkStatusForAction')
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onAddDocumentPerBlock = async (oRequest) => {
        await UserCode.currentUserDetails(oRequest)
        if ('documentId' in oRequest.data && oRequest.params.constructor === Array && oRequest.params.length > 0 && oRequest.data.documentId !== '' && oRequest.data.documentId !== null) {
            try {
                let oWork = await SELECT .one .from `WORKS` .where `ID = ${oRequest.params[0]}`
                let oParent = await SELECT .one .from `WORKS_BLOCK_PHASE_REQUEST(p_workId: ${oRequest.params[0]})`
                if (!(await checkWorkAuth(oRequest, oParent))) oRequest.error(401, 'notAuthorized')
                if (oRequest.errors) return
                let oBlock = await SELECT .one .from `BLOCK_HEAD` .where `BLOCK_ID = ${oWork.parentId}`
                let oPhase = await SELECT .one .from `PHASE_HEAD` .where `PHASE_ID = ${oBlock.PHASE_ID}`
                let oRequestHead = await SELECT.one .from `REQUEST_HEAD` .where `REQUEST_ID = ${oPhase.REQUEST_ID}`
                let oDocumentsPerBlock = await SELECT .from `DOCUMENTS_PER_BLOCK` .where `WORK_ID = ${oRequest.params[0]}`
                if (oRequestHead) {
                    await checkDocument(oRequest, oPhase.REQUEST_ID, oRequest.data.documentId)
                    if (oRequest.errors) return
                    let aDocumentsPerBlock = []
                    let aInstancesPerDocument = []
                    let oDefaultDocumentConfig = false
                    let oDocumentConfig
                    if (oDocumentConfig === undefined || oDocumentConfig.length === 0) {
                        oDocumentConfig = await getDefaultParamForWorkDocument(oRequest, oRequest.params[0], oRequest.data.documentId)
                        oDefaultDocumentConfig = true
                    }

                    await addDocumentPerBlock(oRequest, oBlock, oWork, oDocumentConfig, aDocumentsPerBlock, aInstancesPerDocument, oRequest.data.documentId, oDocumentsPerBlock.length + 1, '1', null, null, oRequestHead, oDefaultDocumentConfig)

                    await INSERT .into('DOCUMENTS_PER_BLOCK') .entries(aDocumentsPerBlock)
                    await INSERT .into('INSTANCES_PER_DOCUMENT') .entries(aInstancesPerDocument)
                    await logDocumentEvent(
                        oRequest,
                        Actions.DOCUMENT_INSTANCE_ADD, 
                        {
                            documentId: oRequest.data.documentId, 
                            requestId: oRequestHead.REQUEST_ID, 
                            blockId: oBlock.BLOCK_ID, 
                            masterBlockId: oBlock.MASTER_BLOCK_ID, 
                            phaseId: oPhase.PHASE_ID, 
                            masterPhaseId: oPhase.MASTER_PHASE_ID,
                            requestType: oRequestHead.REQUEST_TYPE,
                            workId: oWork ? oWork.ID : null, 
                        }
                    )
                    oRequest.reply(await SELECT.from`project.Blocks`.where`ID = ${oRequest.params[0]}`)
                } else {
                    oRequest.error(400, 'phaseNotFound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
    }

}

module.exports = {
    WorksCode
}