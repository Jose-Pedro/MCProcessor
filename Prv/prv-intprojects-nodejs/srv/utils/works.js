const { WorkStatus, DocumentStatus, BlockStatus, DisplayTypesFC, ParentTypes, AssignedResponsibleTypes, Roles, SubcoTypes } = require('../utils/enumerations')
const { addDocumentPerWork } = require('./documentsperblock')
const { getResponsible } = require('./blocks')

const setWorkStatus = async (oRequest, iStatus) => {
    if(oRequest?.params && Array.isArray(oRequest.params) && oRequest.params.length === 1 && oRequest.params[0]){
        try{
            if(iStatus === WorkStatus.WORK_COMPLETED) {
                await UPDATE `WORKS` .with ({status: iStatus, endDate: oRequest.timestamp}) .where `ID = ${oRequest.params[0]}`
            } else if(iStatus === WorkStatus.WORK_CANCELLED) {
                await UPDATE `WORKS` .with ({status: iStatus, endDate: oRequest.timestamp, comments: oRequest.data.comments}) .where `ID = ${oRequest.params[0]}`
            } else if(iStatus === WorkStatus.WORK_INPROGRESS) {
                await UPDATE `WORKS` .with ({status: iStatus, endDate: null}) .where `ID = ${oRequest.params[0]}`
            } else {
                await UPDATE `WORKS` .set `status = ${iStatus}` .where `ID = ${oRequest.params[0]}`
            }
            oRequest.reply(200)
        } catch(oError) {
            oRequest.error(400, oError.message)
        }
    } else {
        oRequest.error(400, 'missingWorkId')
    }
}

const checkWorkPendingDocuments = async (oWork) => {
    let bReturn = true
    let pendingDocuments = await SELECT .one .from `DOCUMENTS_PER_BLOCK` .where `WORK_ID = ${oWork.ID} and STATUS = ${DocumentStatus.IN_PROGRESS}`
    bReturn = pendingDocuments? true: false
    return bReturn    
}

const checkBlockHasWorkconfig = async (oBlock) => {
    let bReturn = false
    let oEntities =  await SELECT .one .from `BLOCK_PHASE_REQUEST(p_blockId: ${oBlock.ID})`
    let oWorkConfig = await SELECT .one .from `WORK_CONFIG_BY_PROCESS` .where `processFlowId = ${oEntities.PROCESS_ID} and phaseTypeId = ${oEntities.MASTER_PHASE_ID} and blockTypeId = ${oEntities.MASTER_BLOCK_ID}`
    bReturn = oWorkConfig? true: false
    return bReturn
}

const checkWorksStatus = async (oRequest, sBlockId) => {
    let aWorks = []
    aWorks = await SELECT .from `WORKS` .where `parentId = ${sBlockId} and parentType_ID = ${ParentTypes.BLOCK} and status = ${WorkStatus.WORK_INPROGRESS}`
    if (aWorks.length > 0) oRequest.error(400, 'blockHasPendingWorks')
}

const setVisibilityForFields = (oWork, oParentsData) => {
    if(oParentsData.BLOCK_STATUS === BlockStatus.BLOCK_INPROGRESS ) {
        if (oWork.status === WorkStatus.WORK_INPROGRESS) {
            setWorkVisibility(oWork, DisplayTypesFC.OPTIONAL)
        } else {
            setWorkVisibility(oWork, DisplayTypesFC.READONLY)
        }
    } else {
        setWorkVisibility(oWork, DisplayTypesFC.READONLY)
    }
}

const setWorkVisibility = (oWork, iDisplayType) => {
    oWork.statusFC              = DisplayTypesFC.READONLY
    oWork.typeFC                = iDisplayType
    oWork.descriptionFC         = iDisplayType
    oWork.commentsFC            = iDisplayType
    oWork.startDateFC           = DisplayTypesFC.READONLY
    oWork.endDateFC             = DisplayTypesFC.READONLY
    oWork.expectedStartDateFC   = iDisplayType
    oWork.expectedEndDateFC     = iDisplayType
    oWork.realStartDateFC       = iDisplayType
    oWork.realEndDateFC         = iDisplayType
    setWorkVisibilityResponsible(oWork, iDisplayType)
}

const setWorkVisibilityResponsible = (oWork, iDisplayType) => {
    oWork.responsibleTypeFC = iDisplayType
    if(parseInt(oWork.responsibleType,10) === parseInt(AssignedResponsibleTypes.CELLNEX,10)) {
        oWork.externalTypeFC                = DisplayTypesFC.HIDDEN
        oWork.internalResponsibleFC         = iDisplayType
        oWork.externalResponsibleFC         = DisplayTypesFC.HIDDEN
    } else {
        oWork.externalTypeFC                = iDisplayType
        oWork.internalResponsibleFC         = DisplayTypesFC.HIDDEN
        oWork.externalResponsibleFC         = iDisplayType
    }
}

const getDefaultWorks = async (oRequest, oRequestHead, oRequestProvision, oPhaseHead, oBlockHead, oBlockProvision, aWorks, aDocumentsPerBlock, aInstancesPerDocument) => {
    let prevWork
    let aWorkConfigs = await SELECT .from `WORK_CONFIG_DOCS_BY_PROCESS` .where ({processFlowId: oRequestHead.PROCESS_ID, phaseTypeId: oPhaseHead.MASTER_PHASE_ID, blockTypeId: oBlockHead.MASTER_BLOCK_ID, objective_ID: oRequestProvision.PROJECT_OBJECTIVE, defaulted: true}) .orderBy (['processFlowId','phaseTypeId','blockTypeId','documentId'])
    for (let oWorkConfig of aWorkConfigs) {
        let oWork
        if (prevWork !== oWorkConfig.type) {
            prevWork = oWorkConfig.type
            oWork = {
                ID : cds.utils.uuid(),
                status: WorkStatus.WORK_INPROGRESS,
                description : null,
                responsibleType: oBlockProvision.ASSIGNED_RESPONSIBLE,
                externalType: oBlockProvision.SUBCONTRACTOR_TYPE,
                internalResponsible : oBlockProvision.RESPONSIBLE_PERSON,
                externalResponsible : oBlockProvision.PROVIDER_NAME,
                comments : null,
                startDate : null,
                endDate : null,
                expectedStartDate : null,
                expectedEndDate : null,
                realStartDate : null,
                realEndDate : null,
                parentId : oBlockHead.BLOCK_ID,
                parentType_ID : ParentTypes.BLOCK,
                type_ID : oWorkConfig.type
            }
            aWorks.push(oWork)
        }
        //Add Work Document
        if (oWorkConfig.documentId && oWorkConfig.documentId !== '') addDocumentPerWork(oRequest, oBlockHead, oWork, oWorkConfig, oWorkConfig.documentId, aDocumentsPerBlock, aInstancesPerDocument)
    }
}

const activateBlockWorks = async (sBlockId) => {
    let aWorks = []
    aWorks = await SELECT .from `WORKS` .where `type_ID is not null and parentId = ${sBlockId} and status = ${WorkStatus.WORK_NOTINITIALIZED}`
    for (let oWork of aWorks) {
        await UPDATE `WORKS` .set `status = ${WorkStatus.WORK_INPROGRESS}` .where `ID = ${oWork.ID}`
    }
}

const checkCreateWorkAuth = async (oRequest, oBlock, oBlockProvision) => {
    let bReturn = false
    let oBlockResponsible = getCreationBlockResponsible(oBlockProvision)
    bReturn = checkBlockUserAuth(oRequest, oBlockResponsible, oBlock)
    return bReturn
}

const checkWorkAuth = async (oRequest, oParent) => {
    let oBlockHead = await SELECT .one .from `project.Blocks` .where `ID = ${oParent.BLOCK_ID}`
    let oWorkDB = await SELECT .one .from `project.Works` .where `ID = ${oParent.WORK_ID}`
    let bReturn = false
    let oWorkResponsible = await getResponsible(oRequest, ParentTypes.WORK, oWorkDB)
    bReturn = checkWorkUserAuth(oRequest, oWorkResponsible, oParent)
    if(!bReturn) {
        let oBlockResponsible = await getResponsible(oRequest, ParentTypes.BLOCK, oBlockHead)
        bReturn = checkBlockUserAuth(oRequest, oBlockResponsible, oParent)
    }
    return bReturn
}

const getCreationBlockResponsible = (oBlockProvision) => {
    let oResponsible = {}
    if (oBlockProvision.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
        oResponsible.isInternal = true
        oResponsible.subcoType = null
        oResponsible.ID = oBlockProvision.internalResponsible
    } else {
        oResponsible.isInternal = false
        oResponsible.subcoType = oBlockProvision.subcontractorType
        oResponsible.ID = oBlockProvision.externalResponsible
    }
    return oResponsible
}

const checkWorkUserAuth = (oRequest, oResponsible, oParent) => {
    let bReturn = false
    if (oRequest.user.is(Roles.MANAGER_USER_ROL)) {
        bReturn = true
    } else if(oResponsible.isInternal) {
        if (oRequest.user.is(Roles.CELLNEX_USER_ROL) && oRequest.user.id === oResponsible.ID) bReturn = true
    } else {
        if (oResponsible.ID === oRequest.agoraCurrentUserData?.vendor && oRequest.agoraCurrentUserData?.vendor !== null && oRequest.agoraCurrentUserData?.vendor !== '') bReturn = true
        if (oResponsible.ID === oRequest.agoraCurrentUserData?.agency && oRequest.agoraCurrentUserData?.agency !== null && oRequest.agoraCurrentUserData?.agency !== '') bReturn = true
    }
    return bReturn
}

const checkBlockUserAuth = (oRequest, oResponsible, oParent) => {
    let bReturn = false
    if (oRequest.user.is(Roles.MANAGER_USER_ROL)) {
        bReturn = true
    } else if((oRequest.user.is(oParent.ROLE_ID) && oRequest.agoraCurrentUserData.isInternal === true)) { 
        bReturn = true
    } else if(oResponsible.isInternal) {
        if (oRequest.user.is(Roles.CELLNEX_USER_ROL) && oRequest.user.id === oResponsible.ID)  bReturn = true
    } else {
        if (oResponsible.ID === oRequest.agoraCurrentUserData?.vendor && oRequest.agoraCurrentUserData?.vendor !== null && oRequest.agoraCurrentUserData.vendor !== '') bReturn = true
        if (oResponsible.ID === oRequest.agoraCurrentUserData?.agency && oRequest.agoraCurrentUserData?.agency !== null && oRequest.agoraCurrentUserData.agency !== '') bReturn = true
    }
    return bReturn
}

const getWorkResponsibleDescriptions = async (oRequest, oParent, oResult) => {
    if ('responsibleType' in oResult && oResult.responsibleType) {
        let oRespType = await SELECT .one .from `project.ApproverTypes` .where `code = ${oResult.responsibleType}`
        oResult.responsibleTypeName = oRespType? oRespType.name: null
        if (oResult.responsibleType === parseInt(AssignedResponsibleTypes.CELLNEX,10)) {
            if( 'internalResponsible' in oResult && oResult.internalResponsible && oResult.internalResponsible !== '') {
                let oUser = await SELECT .one .from `US_USERS_IAS` .where `USER_ID = ${oResult.internalResponsible}`
                oResult.externalResponsibleName = oUser? oUser.USER_NAME: null     
            }
        } else {
            if('externalType' in oResult && oResult.externalType) {
                let oExtType = await SELECT .one .from `project.SubcoTypes` .where `code = ${oResult.externalType}`
                oResult.externalTypeName = oExtType? oExtType.name: null
                switch (oResult.externalType) {
                    case SubcoTypes.VENDOR:
                        if ( 'externalResponsible' in oResult && oResult.externalResponsible) {
                            let oVendor = await SELECT .one .from `project.CacheR3Entities` .where `userId = ${oRequest.user.id} and code = ${oResult.externalResponsible} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                            oResult.externalResponsibleName = oVendor? oVendor.name: null
                        }
                        break
                    case SubcoTypes.AGENCY:
                        if ( 'externalResponsible' in oResult && oResult.externalResponsible) {
                            let oAgency = await SELECT .one .from`project.CacheR3Entities` .where `userId = ${oRequest.user.id} and code = ${oResult.externalResponsible} and entityType = 'F4_GEWRK_AGEN'`;
                            oResult.externalResponsibleName = oAgency? oAgency.name: null
                        }
                        break
                    case SubcoTypes.CUSTOMER:
                        oResult.externalResponsibleName = null
                        break
                }
            }
        }
    }
}

module.exports = {
    setWorkStatus,
    checkWorkPendingDocuments,
    checkBlockHasWorkconfig,
    checkWorksStatus,
    setVisibilityForFields,
    getDefaultWorks,
    activateBlockWorks,
    checkCreateWorkAuth,
    checkWorkAuth,
    getWorkResponsibleDescriptions
}