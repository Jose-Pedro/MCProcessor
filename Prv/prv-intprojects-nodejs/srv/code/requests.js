const { RequestStatus, PhaseStatus, BlockStatus, Roles, GlobalConstants, DisplayTypesFC, SubcoTypes, AssignedResponsibleTypes } = require('../utils/enumerations')

const { setRequestStatus, checkCreationData, checkCancelReason, checkOnHoldReason, checkSite, updatePreferredProvider } = require('../utils/requests')
const { UserCode } = require('./users')
const { createOTFolder, addDefaultDocumentsConfig } = require('../utils/documents')
const { getDefaultChecklistItems } = require('../utils/checklists')
const { getProcessData, getDisplayConfiguration, setDisplayConfiguration, setFCAs, checkInputValues, checkEditableFields } = require('../utils/configurations')
const { ComplexFieldsLogic } = require('../utils/complexlogic')
const { saveLog } = require('../utils/AuditLogger')
const { getDefaultWorks } = require('../utils/works')

class RequestsCode {

    beforeCreateRequest = async (oRequest) => {
        await UserCode.currentUserDetails(oRequest)
        if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
        if (oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
    }

    onCreateRequest = async (oRequest) => {
        if ('creationConfig' in oRequest.data) {
            let sCreationConfig = oRequest.data.creationConfig
            await checkCreationData(oRequest, sCreationConfig)
            if (oRequest.errors) return
            let oSite = await checkSite(oRequest)
            if (oRequest.errors) return
            await checkInputValues(oRequest)
            // await isValidcheckProjectObjective(oRequest)
            if (oRequest.errors) return
            let aProcess = await getProcessData(GlobalConstants.REQUEST_TYPE, oRequest.agoraCurrentUserData.country, oRequest.data.classification, null, sCreationConfig)
            if (aProcess) {
                let oRequestHead = { 'REQUEST_ID': cds.utils.uuid(), 'SITE_ID': oSite.siteId, 'COMUNIDAD_ID': oSite.company, 'REQUEST_TYPE': GlobalConstants.REQUEST_TYPE, 'PROCESS_ID': aProcess[0].ID_PK, 'REQUEST_STATUS': RequestStatus.REQUEST_INPROGRESS, 'COUNTRY_ID': oRequest.agoraCurrentUserData.country, 'CUSTOMER_ID': null, 'REQUEST_OWNER_ID': oRequest.agoraCurrentUserData.isManager === true ? oRequest.user.id : null, 'ASSIGNATION_DATE': oRequest.agoraCurrentUserData.isManager === true ? oRequest.timestamp : null, 'STARTED_AT': oRequest.timestamp, 'CREATEDAT': oRequest.timestamp, 'MODIFIEDAT': oRequest.timestamp, 'CREATEDBY': oRequest.user.id, 'MODIFIEDBY': oRequest.user.id, 'WORKFLOW_ID': sCreationConfig }
                let oRequestProvision = { 'REQUEST_ID': oRequestHead.REQUEST_ID, 'PREFERRED_PROVIDER': oRequest.data?.preferredProvider, 'PROJECT_OBJECTIVE': oRequest.data?.projectObjective, 'DELIVERY_GROUP': oRequest.data?.deliveryGroup, 'BUDGET_PROGRAM': oRequest.data?.budgetProgram, 'REQUESTED_DATE': oRequest.data?.requestedDate ? oRequest.data?.requestedDate : Date.now(), 'SF_OPPORTUNITY_ID': oRequest.data?.RequestProvision?.salesforceRequestId ? oRequest.data?.RequestProvision?.salesforceRequestId : null, 'REQUESTER': oRequest.user.id, 'CREATEDAT': oRequest.timestamp, 'MODIFIEDAT': oRequest.timestamp, 'CREATEDBY': oRequest.user.id, 'MODIFIEDBY': oRequest.user.id }
                let aPhaseHead = []
                let aBlockHead = []
                let aBlockProvision = []
                let aChecklistItems = []
                let aDocumentsPerBlock = []
                let aInstancesPerDocument = []
                let aWorks = []
                let prevPhase = ''
                let oPhaseHead = null
                for (let oProcessStep of aProcess) {
                    if (oProcessStep.PHASE_ID !== prevPhase) {
                        oPhaseHead = { 'PHASE_ID': cds.utils.uuid(), 'PHASE_STATUS': oProcessStep.PHASE_ORDER === '01' ? PhaseStatus.PHASE_INPROGRESS : PhaseStatus.PHASE_NOTINITIALIZED, 'STARTED_AT': oProcessStep.PHASE_ORDER === '01' ? oRequest.timestamp : null, 'MASTER_PHASE_ID': oProcessStep.PHASE_ID, 'REQUEST_ID': oRequestHead.REQUEST_ID, 'CREATEDAT': oRequest.timestamp, 'MODIFIEDAT': oRequest.timestamp, 'CREATEDBY': oRequest.user.id, 'MODIFIEDBY': oRequest.user.id }
                        aPhaseHead.push(oPhaseHead)
                        prevPhase = oProcessStep.PHASE_ID
                    }
                    let iBlockStatus = BlockStatus.BLOCK_NOTINITIALIZED
                    let bBlockActivated = false
                    if (oPhaseHead.PHASE_STATUS === PhaseStatus.PHASE_INPROGRESS && (oProcessStep.MANDATORY === 'X' || oProcessStep.ACTIVE === 'X')) iBlockStatus = BlockStatus.BLOCK_INPROGRESS
                    if (oProcessStep.MANDATORY === 'X' || oProcessStep.ACTIVE === 'X') bBlockActivated = true
                    let oBlockHead = { 'BLOCK_ID': cds.utils.uuid(), 'BLOCK_STATUS': iBlockStatus, 'MASTER_BLOCK_ID': oProcessStep.BLOCK_ID_PK, 'PHASE_ID': oPhaseHead.PHASE_ID, 'MANDATORY': oProcessStep.MANDATORY, 'ACTIVATED': bBlockActivated, 'ROLE_ID': oProcessStep.ROLE_ID, 'STARTED_AT': bBlockActivated ? oRequest.timestamp : null, 'CREATEDAT': oRequest.timestamp, 'MODIFIEDAT': oRequest.timestamp, 'CREATEDBY': oRequest.user.id, 'MODIFIEDBY': oRequest.user.id }
                    let oBlockProvision = { 'BLOCK_ID': oBlockHead.BLOCK_ID, 'CREATEDAT': oRequest.timestamp, 'MODIFIEDAT': oRequest.timestamp, 'CREATEDBY': oRequest.user.id, 'MODIFIEDBY': oRequest.user.id }
                    if (oProcessStep.HASRESPONSIBLE === 'X') {
                        //Add responsible configuration if                        
                        oBlockProvision.ASSIGNED_RESPONSIBLE = oProcessStep.APPROVER_TYPE
                        oBlockProvision.SUBCONTRACTOR_TYPE = oProcessStep.SUBCONTRACTOR_TYPE
                    }
                    await getDefaultChecklistItems(oRequest, oRequestHead, oPhaseHead, oBlockHead, aChecklistItems)
                    await getDefaultWorks(oRequest, oRequestHead, oRequestProvision, oPhaseHead, oBlockHead, oBlockProvision, aWorks, aDocumentsPerBlock, aInstancesPerDocument)
                    aBlockHead.push(oBlockHead)
                    aBlockProvision.push(oBlockProvision)
                }

                try {
                    await INSERT.into('REQUEST_HEAD').entries(oRequestHead)
                    await INSERT.into('REQUEST_CHAR_PRO').entries(oRequestProvision)
                    await INSERT.into('PHASE_HEAD').entries(aPhaseHead)
                    await INSERT.into('BLOCK_HEAD').entries(aBlockHead)
                    await INSERT.into('BLOCKS_PROVISIONING').entries(aBlockProvision)
                    if (aChecklistItems.length > 0) await INSERT.into('Checklist.Item').entries(aChecklistItems)
                    if (aWorks.length > 0) await INSERT.into('WORKS').entries(aWorks)
                    if (aDocumentsPerBlock.length > 0) await INSERT.into('DOCUMENTS_PER_BLOCK').entries(aDocumentsPerBlock)
                    if (aInstancesPerDocument.length > 0) await INSERT.into('INSTANCES_PER_DOCUMENT').entries(aInstancesPerDocument)
                    //await addDefaultDocumentsConfig(oRequest, aProcess[0].ID_PK, oRequestHead.REQUEST_ID, oRequestHead.REQUEST_OWNER_ID, oRequestHead.CUSTOMER_ID)
                    let oCreatedRequest
                    try {
                        oCreatedRequest = await SELECT.one.from`project.Requests`.where`ID = ${oRequestHead.REQUEST_ID}`
                    } catch (eSel) {
                        console.error('[onCreateRequest] post-insert SELECT Requests failed:', eSel && eSel.stack ? eSel.stack : eSel)
                        oCreatedRequest = { ID: oRequestHead.REQUEST_ID }
                    }
                    try { await createOTFolder(oRequest, oCreatedRequest) } catch (eOT) { console.error('[onCreateRequest] createOTFolder skipped:', eOT.message) }

                    let oRequestProvisionCreated
                    try {
                        oRequestProvisionCreated = await SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.REQUEST_ID}`
                    } catch (eRP) {
                        console.error('[onCreateRequest] post-insert SELECT RequestProvision failed:', eRP && eRP.stack ? eRP.stack : eRP)
                        oRequestProvisionCreated = { preferredProvider: oRequestHead.preferredProvider || null }
                    }
                    try { await this.#onAddRequestDocumentsDefaultParamPerBlock(oRequest, aProcess[0].ID_PK, oRequestHead.REQUEST_ID, oRequestHead.REQUEST_OWNER_ID, oRequestHead.CUSTOMER_ID, oRequestProvisionCreated.preferredProvider) } catch (eDoc) { console.error('[onCreateRequest] addDefaultDocsParam skipped:', eDoc.message) }
                    oRequest.reply(oCreatedRequest)
                } catch (oError) {
                    console.error('[onCreateRequest] insert error:', oError && oError.stack ? oError.stack : oError)
                    oRequest.error(400, oError.message)
                }
            } else {
                oRequest.error(400, 'missingParameters')
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
    }

    #onAddRequestDocumentsDefaultParamPerBlock = async (oRequest, processId, requestId, btsManagerId, sCustomerId, preferredProvider) => {
        if (processId) {
            try {
                let oDocProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`processId = ${processId}`
                if (oDocProcess) {
                    let oDocsDefaultValidPerProcess = await SELECT.from`DOCUMENT_FLOW_VALIDATORS`.where`DocumentFlowsPerConfig_ID = ${oDocProcess.Configuration_ID}`
                    let oRequestDocumentsPerBlockDefaultValidation = []
                    for (let i = 0; i < oDocsDefaultValidPerProcess.length; i++) {
                        if (oDocsDefaultValidPerProcess[i] && oDocsDefaultValidPerProcess[i].default !== undefined && oDocsDefaultValidPerProcess[i].default) {
                            let oSingleDoc = oDocsDefaultValidPerProcess[i]
                            let sDefaultResponsible = ''
                            if (oSingleDoc.approverType === 1) {//internal
                                sDefaultResponsible = btsManagerId
                            }
                            if (oSingleDoc.approverType === 2 && oSingleDoc.externalType === 2) {//external y customer
                                sDefaultResponsible = sCustomerId
                            }
                            if (parseInt(oSingleDoc.approverType, 10) === 2 && parseInt(oSingleDoc.externalType, 10) === 3) {//external y subco
                                sDefaultResponsible = preferredProvider
                            }
                            let oCheckExistent = await SELECT.from`project.RequestDocumentsPerBlockDefaultValid`.where`DELETED = false and requestId = ${requestId} and documentId = ${oSingleDoc.documentId}`
                            if (oCheckExistent.length === 0) {
                                let oDocumentsPerBlockValid = {
                                    'REQUEST_ID': requestId,
                                    'DOCUMENT_ID': oSingleDoc.documentId,
                                    'APPROVER_TYPE': oSingleDoc.approverType,
                                    'SUBCONTRACTOR': oSingleDoc.externalType,
                                    'DEFAULT_RESPONSIBLE': sDefaultResponsible,
                                    'SUBCO_REQ_VAL': oSingleDoc.subcontractorValidationReq,
                                    'CELLNEX_REQ_VAL': oSingleDoc.cellnexValidationReq,
                                    'CUSTOMER__REQ_VAL': oSingleDoc.customerValidationReq,
                                    'SITEOWNER_REQ_VAL': oSingleDoc.landlordValidationReq,
                                    'CREATEDAT': oRequest.timestamp,
                                    'CREATEDBY': oRequest.user.id,
                                    'MODIFIEDAT': oRequest.timestamp,
                                    'MODIFIEDBY': oRequest.user.id,
                                    'DELETED': false,
                                    'REGISTER_ID': cds.utils.uuid()
                                }
                                oRequestDocumentsPerBlockDefaultValidation.push(oDocumentsPerBlockValid)
                            }
                        }
                    }
                    if (oRequestDocumentsPerBlockDefaultValidation.length > 0) await INSERT.into('REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID').entries(oRequestDocumentsPerBlockDefaultValidation)
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'processIdNotFound')
        }
    }

    beforeReadRequest = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
        } catch (oError) {
            console.error('[beforeReadRequest] FULL', oError.stack || oError.message)
            oRequest.error(400, oError.message)
        }
    }

    afterReadRequest = async (oResult, oRequest) => {
        if (!oResult) return
        if (oRequest.query?.SELECT?.columns?.some(c => c.func === 'count')) return
        let aRequests = oResult.constructor === Array ? oResult : [oResult]

        for (let oRequestHead of aRequests) {
            if (!oRequestHead) continue
            let oConfiguration = await getDisplayConfiguration(oRequest, oRequestHead.processFlowId, 'REQUEST_HEAD', '', '', true)
            if (oRequest.user.is(Roles.MANAGER_USER_ROL)) {
                // only manager user can touch header
                setDisplayConfiguration(oRequest, oRequestHead, oConfiguration, oRequest.target.elements)
                ComplexFieldsLogic.setVisibilityForEntity(true, null, oRequestHead, null)
                if ('RequestProvision' in oRequestHead) {
                    let oConfiguration = await getDisplayConfiguration(oRequest, oRequestHead.processFlowId, 'REQUEST_CHAR_PRO', '', '', true)
                    setDisplayConfiguration(oRequest, oRequestHead.RequestProvision, oConfiguration, oRequest.target.elements.RequestProvision._target.elements)
                    ComplexFieldsLogic.setVisibilityForEntity(true, null, null, oRequestHead.RequestProvision)
                }
            } else {
                setFCAs(oRequest, oRequestHead, DisplayTypesFC.READONLY)
            }
            if ('RequestProvision' in oRequestHead) {
                if (oRequestHead.RequestProvision.PMOManager && oRequestHead.RequestProvision.PMOManager !== null && oRequestHead.RequestProvision.PMOManager !== '') {
                    let oPMOManager = await SELECT.one.from`PMO_MANAGERS`.where`userId = ${oRequestHead.RequestProvision.PMOManager}`
                    if (oPMOManager) oRequestHead.RequestProvision.PMOManagerName = oPMOManager.userName
                }
                if (oRequestHead.RequestProvision.requester && oRequestHead.RequestProvision.requester !== null && oRequestHead.RequestProvision.requester !== '') {
                    let oRequester = await SELECT.one.from`REQUESTERS`.where`userId = ${oRequestHead.RequestProvision.requester}`
                    if (oRequester) oRequestHead.RequestProvision.requesterName = oRequester.userName
                }
                if (oRequestHead.RequestProvision.preferredProvider && oRequestHead.RequestProvision.preferredProvider !== null && oRequestHead.RequestProvision.preferredProvider !== '') {
                    let oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oRequestHead.RequestProvision.preferredProvider} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                    if (oVendor) oRequestHead.RequestProvision.preferredProviderName = oVendor.userName
                }
            }
            if ('RequestDocumentsPerBlockDefaultValid' in oRequestHead) {
                let oRequestDocumentsPerBlockDefaultValids = await SELECT.from`project.RequestDocumentsPerBlockDefaultValid`.where`DELETED != true and requestId = ${oRequestHead.ID}`

                oRequestHead['RequestDocumentsPerBlockDefaultValid'] = await this.afterreadDefaultDocumentsPerBlockDefaultValids(oRequestDocumentsPerBlockDefaultValids, oRequest)
            }

            if ('Site' in oRequestHead) {
                let oLandlord = await SELECT.one.from`LANDLORD_BY_SITE(p_siteId: ${oRequestHead.siteId})`
                if (oLandlord) oRequestHead.Site.landlordName = oLandlord.fullName
            }

            let oConfirmButtons = await SELECT.one.from`CONFIRM_BUTTONS(p_requestId : ${oRequestHead.ID}, p_master_phase_id : 'finalValidation', p_master_block_id : 'validDocument')`;
            if (oConfirmButtons) {
                oRequestHead.inventoryUpdated = oConfirmButtons.BTTN_INV_UPDATED && oConfirmButtons.BTTN_INV_UPDATED !== '' ? true : false
                oRequestHead.servicesUpdated = oConfirmButtons.BTTN_SERV_UPDATED && oConfirmButtons.BTTN_SERV_UPDATED !== '' ? true : false
                oRequestHead.documentUpdated = oConfirmButtons.BTTN_DOC_UPDATED && oConfirmButtons.BTTN_DOC_UPDATED !== '' ? true : false
            }
        }

    }

    inBothArrayOfObjects = async (list1, list2, sProperty1, sProperty2) => {
        return await this.operationWithArrays(list1, list2, true, sProperty1, sProperty2);
    }

    inFirstOnlyArrayOfObjects = async (list1, list2, sProperty1, sProperty2) => {
        return await this.operationWithArrays(list1, list2, false, sProperty1, sProperty2);
    }

    operationWithArrays = async (list1, list2, isUnion, sProperty1, sProperty2) => {
        let result = [];

        for (let i = 0; i < list1.length; i++) {
            let item1 = list1[i];
            let same = false;
            for (let j = 0; j < list2.length && !same; j++) {
                same = item1[sProperty1] === list2[j][sProperty2];
            }
            if (same === !!isUnion) {

                result.push(item1);
            }
        }
        return result;
    }

    onDefaultResponsibleCalculation = async (sResponsibleId, sSubcoId, sDocResponsibleId, oRequest) => {
        let oResult
        if (parseInt(sResponsibleId) === parseInt(AssignedResponsibleTypes.CELLNEX)) {
            oResult = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${sDocResponsibleId}`
            if (oResult) {
                return {
                    code: sDocResponsibleId,
                    name: oResult.USER_NAME
                }
            } else {
                return {
                    code: sDocResponsibleId,
                    name: ""
                }
            }
        } else {
            switch (parseInt(sSubcoId, 10)) {
                case SubcoTypes.CUSTOMER:

                    oResult = await SELECT.one.from`BUT000`.where`PARTNER=${sDocResponsibleId}`
                    if (oResult) {
                        return {
                            code: oResult.PARTNER,
                            name: oResult.NAME_ORG1 + " " + oResult.NAME_ORG2
                        }
                    } else {
                        return {
                            code: sDocResponsibleId,
                            name: ""
                        }
                    }
                case SubcoTypes.VENDOR:
                    oResult = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${sDocResponsibleId} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                    if (oResult) {
                        return {
                            code: oResult.code,
                            name: oResult.name
                        }
                    } else {
                        return {
                            code: sDocResponsibleId,
                            name: ""
                        }
                    }
                case SubcoTypes.AGENCY:
                    oResult = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${sDocResponsibleId} and entityType = 'F4_GEWRK_AGEN'`;
                    if (oResult) {
                        return {
                            code: oResult.code,
                            name: oResult.name
                        }
                    } else {
                        return {
                            code: sDocResponsibleId,
                            name: ""
                        }
                    }
            }
        }
    }

    afterreadDefaultDocumentsPerBlockDefaultValids = async (oDocumentsPerBlockDefaultValids, oRequest) => {
        let aux
        if (oDocumentsPerBlockDefaultValids.length > 0 && oDocumentsPerBlockDefaultValids[0]) {

            let oRequestHead

            let oDocProcess;
            oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oDocumentsPerBlockDefaultValids[0].requestId}`;
            oDocProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`processId = ${oRequestHead.processFlowId}`
            let aDocumentRolesNotVisible = await SELECT.from`DOCUMENT_FLOWS_HIDDEN_PER_ROLE`.where`DocumentFlowsPerConfig_ID = ${oDocProcess.Configuration_ID} and active = true`;

            let aRoles = await SELECT.from`US_ROLES_AGR`.where`USER_ID = ${oRequest.user.id}`;
            let auxNotVisibleDocs = await this.inBothArrayOfObjects(aDocumentRolesNotVisible, aRoles, 'IASGroup', 'IAS_GROUP')
            aux = await this.inFirstOnlyArrayOfObjects(oDocumentsPerBlockDefaultValids, auxNotVisibleDocs, 'documentId', 'documentId')

            let sMasterBlockId = 'requestConfigur'
            let sBlockId = await SELECT.one.from`GET_BLOCK_ID_FROM_MASTERBLOCK_ID(p_requestId: ${oDocumentsPerBlockDefaultValids[0].requestId},p_masterBlockId: ${sMasterBlockId})`

            let oBlockHead = await SELECT.one.from`project.Blocks`.where`ID = ${sBlockId.BLOCK_ID}`
            for (let oResult of aux) {
                if (oResult) {

                    let oDocumentsPerBlockDefaultValid = oResult;
                    oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = ''
                    oDocumentsPerBlockDefaultValid.customerResponsibleName = ''
                    oDocumentsPerBlockDefaultValid.cellnexResponsibleName = ''
                    oDocumentsPerBlockDefaultValid.agencyResponsibleName = ''
                    if (oDocumentsPerBlockDefaultValid.responsibleId) {
                        let oApproverType
                        if (oDocumentsPerBlockDefaultValid.responsibleId) oApproverType = await SELECT.one.from`APPROVER_TYPES`.where`code = ${oDocumentsPerBlockDefaultValid.responsibleId}`;
                        if (oApproverType) oDocumentsPerBlockDefaultValid.approverTypeName = oApproverType.name;
                    }

                    if (oDocumentsPerBlockDefaultValid.subcontractorId) {
                        let oSubcoType
                        if (oDocumentsPerBlockDefaultValid.subcontractorId) oSubcoType = await SELECT.one.from`SUBCO_TYPES`.where`code = ${oDocumentsPerBlockDefaultValid.subcontractorId}`;
                        if (oSubcoType) oDocumentsPerBlockDefaultValid.subcoTypeName = oSubcoType.name;
                    }
                    if (oBlockHead.status !== BlockStatus.BLOCK_INPROGRESS || oBlockHead.activated !== true) {
                        oDocumentsPerBlockDefaultValid.responsibleDefaultFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlockDefaultValid.approverTypeFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlockDefaultValid.subcoTypeFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlockDefaultValid.cellnexValidationFC = DisplayTypesFC.HIDDEN
                        oDocumentsPerBlockDefaultValid.subcontractorValidationFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlockDefaultValid.customerValidationFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlockDefaultValid.siteOwnerValidationFC = DisplayTypesFC.HIDDEN

                        let oRequestHead, oDocumentFlowPerProcess, oDocumentFlowMaster, oDocumentFlowPerConfig
                        if (oDocumentsPerBlockDefaultValid.requestId) oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oDocumentsPerBlockDefaultValid.requestId}`;
                        if (oRequestHead) oDocumentFlowPerProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`processId = ${oRequestHead.PROCESS_ID}`;
                        if (oDocumentFlowPerProcess) oDocumentFlowPerConfig = await SELECT.one.from`DOCUMENT_FLOWS_PER_CONFIG`.where`ID = ${oDocumentFlowPerProcess.Configuration_ID}`;
                        if (oDocumentFlowPerConfig) oDocumentFlowMaster = await SELECT.one.from`DOCUMENT_FLOWS_PER_BLOCK`.where`DocumentFlowsPerConfig_ID = ${oDocumentFlowPerConfig.ID} and documentId = ${oDocumentsPerBlockDefaultValid.documentId}`;

                        if (oDocumentFlowMaster) oDocumentsPerBlockDefaultValid.docOrder = oDocumentFlowMaster.docOrder

                        if (oDocumentsPerBlockDefaultValid.documentId) {
                            let oDocumentMaster = await SELECT.one.from`DOCUMENT_FLOWS`.where`documentId = ${oDocumentsPerBlockDefaultValid.documentId}`
                            if (oDocumentMaster) oDocumentsPerBlockDefaultValid.documentNameVF = oDocumentMaster.documentName
                        }

                        if (oDocumentsPerBlockDefaultValid.responsibleDefault) {
                            let oResponsibleDefault = await this.onDefaultResponsibleCalculation(oDocumentsPerBlockDefaultValid.responsibleId, oDocumentsPerBlockDefaultValid.subcontractorId, oDocumentsPerBlockDefaultValid.responsibleDefault, oRequest)
                            if (oResponsibleDefault) oDocumentsPerBlockDefaultValid.responsibleDefaultName = oResponsibleDefault.name
                        }
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                            oDocumentsPerBlockDefaultValid.subcontractorId = null
                            oDocumentsPerBlockDefaultValid.subcoTypeFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.cellnexValidation = null
                            oDocumentsPerBlockDefaultValid.cellnexValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.subcontractorValidationFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.customerValidationFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.responsibleDefaultFC = DisplayTypesFC.READONLY
                        }
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.EXTERNAL, 10) && !oDocumentsPerBlockDefaultValid.subcontractorId) {
                            oDocumentsPerBlockDefaultValid.subcontractorId = SubcoTypes.VENDOR
                        }
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.EXTERNAL, 10) && oDocumentsPerBlockDefaultValid.subcontractorId === SubcoTypes.VENDOR) {
                            oDocumentsPerBlockDefaultValid.cellnexValidationFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.subcontractorValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.customerValidationFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.responsibleDefaultFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.subcoTypeFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.subcontractorValidation = null
                        }
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.EXTERNAL, 10) && oDocumentsPerBlockDefaultValid.subcontractorId === SubcoTypes.CUSTOMER) {
                            oDocumentsPerBlockDefaultValid.cellnexValidationFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.subcontractorValidationFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.customerValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.responsibleDefaultFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.subcoTypeFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.customerValidation = null
                        }

                        oDocumentsPerBlockDefaultValid.cellnexResponsibleFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlockDefaultValid.agencyResponsibleFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlockDefaultValid.subcontractorResponsibleFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlockDefaultValid.customerResponsibleFC = DisplayTypesFC.READONLY
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                            let oUser
                            if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oUser = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oDocumentsPerBlockDefaultValid.responsibleDefault}`
                            oDocumentsPerBlockDefaultValid.cellnexResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                            oDocumentsPerBlockDefaultValid.cellnexResponsibleName = ''
                            oDocumentsPerBlockDefaultValid.cellnexResponsibleFC = DisplayTypesFC.READONLY
                            if (oUser) oDocumentsPerBlockDefaultValid.cellnexResponsibleName = oUser.USER_NAME
                        } else {
                            switch (parseInt(oDocumentsPerBlockDefaultValid.subcontractorId, 10)) {
                                case parseInt(SubcoTypes.CUSTOMER, 10):
                                    let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oDocumentsPerBlockDefaultValid.requestId}`
                                    oDocumentsPerBlockDefaultValid.customerResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                    oDocumentsPerBlockDefaultValid.customerResponsibleName = ''
                                    oDocumentsPerBlockDefaultValid.customerResponsibleFC = DisplayTypesFC.OPTIONAL
                                    if (oRequestHead) oDocumentsPerBlockDefaultValid.customerResponsibleName = oRequestHead.CUSTOMER_NAME
                                    break
                                case parseInt(SubcoTypes.VENDOR, 10):
                                    let oVendor
                                    if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oDocumentsPerBlockDefaultValid.responsibleDefault} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                                    oDocumentsPerBlockDefaultValid.subcontractorResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                    oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = ''
                                    oDocumentsPerBlockDefaultValid.subcontractorResponsibleFC = DisplayTypesFC.OPTIONAL
                                    if (oVendor) oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = oVendor.name
                                    break
                                case parseInt(SubcoTypes.AGENCY, 10):
                                    let oAgency
                                    if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oAgency = await await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oDocumentsPerBlockDefaultValid.responsibleDefault} and entityType = 'F4_GEWRK_AGEN'`;
                                    oDocumentsPerBlockDefaultValid.agencyResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                    oDocumentsPerBlockDefaultValid.agencyResponsibleName = ''
                                    oDocumentsPerBlockDefaultValid.agencyResponsibleFC = DisplayTypesFC.OPTIONAL
                                    if (oAgency) oDocumentsPerBlockDefaultValid.agencyResponsibleResponsibleName = oAgency.name
                                    break
                            }
                        }


                    } else {


                        let oRequestHead, oDocumentFlowPerProcess, oDocumentFlowMaster, oDocumentFlowPerConfig
                        if (oDocumentsPerBlockDefaultValid.requestId) oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oDocumentsPerBlockDefaultValid.requestId}`;
                        if (oRequestHead) oDocumentFlowPerProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`processId = ${oRequestHead.PROCESS_ID}`;
                        if (oDocumentFlowPerProcess) oDocumentFlowPerConfig = await SELECT.one.from`DOCUMENT_FLOWS_PER_CONFIG`.where`ID = ${oDocumentFlowPerProcess.Configuration_ID}`;
                        if (oDocumentFlowPerConfig) oDocumentFlowMaster = await SELECT.one.from`DOCUMENT_FLOWS_PER_BLOCK`.where`DocumentFlowsPerConfig_ID = ${oDocumentFlowPerConfig.ID} and documentId = ${oDocumentsPerBlockDefaultValid.documentId}`;

                        if (oDocumentFlowMaster) oDocumentsPerBlockDefaultValid.docOrder = oDocumentFlowMaster.docOrder

                        if (oDocumentsPerBlockDefaultValid.documentId) {
                            let oDocumentMaster = await SELECT.one.from`DOCUMENT_FLOWS`.where`documentId = ${oDocumentsPerBlockDefaultValid.documentId}`
                            if (oDocumentMaster) oDocumentsPerBlockDefaultValid.documentNameVF = oDocumentMaster.documentName
                        }

                        if (oDocumentsPerBlockDefaultValid.responsibleDefault) {
                            let oResponsibleDefault = await this.onDefaultResponsibleCalculation(oDocumentsPerBlockDefaultValid.responsibleId, oDocumentsPerBlockDefaultValid.subcontractorId, oDocumentsPerBlockDefaultValid.responsibleDefault, oRequest)
                            if (oResponsibleDefault) oDocumentsPerBlockDefaultValid.responsibleDefaultName = oResponsibleDefault.name
                        }

                        oDocumentsPerBlockDefaultValid.responsibleDefaultFC = DisplayTypesFC.OPTIONAL
                        oDocumentsPerBlockDefaultValid.approverTypeFC = DisplayTypesFC.OPTIONAL
                        oDocumentsPerBlockDefaultValid.subcoTypeFC = DisplayTypesFC.OPTIONAL
                        oDocumentsPerBlockDefaultValid.cellnexValidationFC = DisplayTypesFC.OPTIONAL
                        oDocumentsPerBlockDefaultValid.subcontractorValidationFC = DisplayTypesFC.OPTIONAL
                        oDocumentsPerBlockDefaultValid.customerValidationFC = DisplayTypesFC.OPTIONAL
                        oDocumentsPerBlockDefaultValid.siteOwnerValidationFC = DisplayTypesFC.OPTIONAL
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                            oDocumentsPerBlockDefaultValid.subcontractorId = null
                            oDocumentsPerBlockDefaultValid.subcoTypeFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.cellnexValidation = null
                            oDocumentsPerBlockDefaultValid.cellnexValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.subcontractorValidationFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.customerValidationFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.responsibleDefaultFC = DisplayTypesFC.OPTIONAL
                        }
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.EXTERNAL, 10) && !oDocumentsPerBlockDefaultValid.subcontractorId) {
                            oDocumentsPerBlockDefaultValid.subcontractorId = SubcoTypes.VENDOR
                        }
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.EXTERNAL, 10) && oDocumentsPerBlockDefaultValid.subcontractorId === SubcoTypes.VENDOR) {
                            oDocumentsPerBlockDefaultValid.cellnexValidationFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.subcontractorValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.customerValidationFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.responsibleDefaultFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.subcoTypeFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.subcontractorValidation = null
                        }
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.EXTERNAL, 10) && oDocumentsPerBlockDefaultValid.subcontractorId === SubcoTypes.CUSTOMER) {
                            oDocumentsPerBlockDefaultValid.cellnexValidationFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.subcontractorValidationFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.customerValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlockDefaultValid.responsibleDefaultFC = DisplayTypesFC.READONLY
                            oDocumentsPerBlockDefaultValid.subcoTypeFC = DisplayTypesFC.OPTIONAL
                            oDocumentsPerBlockDefaultValid.customerValidation = null
                        }

                        oDocumentsPerBlockDefaultValid.cellnexResponsibleFC = 1
                        oDocumentsPerBlockDefaultValid.agencyResponsibleFC = 1
                        oDocumentsPerBlockDefaultValid.subcontractorResponsibleFC = 1
                        oDocumentsPerBlockDefaultValid.customerResponsibleFC = 1
                        if (oDocumentsPerBlockDefaultValid.responsibleId === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                            let oUser
                            if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oUser = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oDocumentsPerBlockDefaultValid.responsibleDefault}`
                            oDocumentsPerBlockDefaultValid.cellnexResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                            oDocumentsPerBlockDefaultValid.cellnexResponsibleName = ''
                            oDocumentsPerBlockDefaultValid.cellnexResponsibleFC = 3
                            if (oUser) oDocumentsPerBlockDefaultValid.cellnexResponsibleName = oUser.USER_NAME
                        } else {
                            switch (oDocumentsPerBlockDefaultValid.subcontractorId) {
                                case parseInt(SubcoTypes.CUSTOMER, 10):
                                    let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oDocumentsPerBlockDefaultValid.requestId}`
                                    oDocumentsPerBlockDefaultValid.customerResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                    oDocumentsPerBlockDefaultValid.customerResponsibleName = ''
                                    oDocumentsPerBlockDefaultValid.customerResponsibleFC = DisplayTypesFC.OPTIONAL
                                    if (oRequestHead) oDocumentsPerBlockDefaultValid.customerResponsibleName = oRequestHead.CUSTOMER_NAME
                                    break
                                case parseInt(SubcoTypes.VENDOR, 10):
                                    let oVendor
                                    if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oDocumentsPerBlockDefaultValid.responsibleDefault} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                                    oDocumentsPerBlockDefaultValid.subcontractorResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                    oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = ''
                                    oDocumentsPerBlockDefaultValid.subcontractorResponsibleFC = DisplayTypesFC.OPTIONAL
                                    if (oVendor) oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = oVendor.name
                                    break
                                case parseInt(SubcoTypes.AGENCY, 10):
                                    let oAgency
                                    if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oAgency = await await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oDocumentsPerBlockDefaultValid.responsibleDefault} and entityType = 'F4_GEWRK_AGEN'`;
                                    oDocumentsPerBlockDefaultValid.agencyResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                    oDocumentsPerBlockDefaultValid.agencyResponsibleName = ''
                                    oDocumentsPerBlockDefaultValid.agencyResponsibleFC = DisplayTypesFC.OPTIONAL
                                    if (oAgency) oDocumentsPerBlockDefaultValid.agencyResponsibleResponsibleName = oAgency.name
                                    break
                            }
                        }
                    }
                }
            }
            oDocumentsPerBlockDefaultValids = aux
            oDocumentsPerBlockDefaultValids.sort((a, b) => a.docOrder - b.docOrder);
            return oDocumentsPerBlockDefaultValids
        }
    }

    beforeUpdateRequest = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oRequest.data.ID}`
            if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
            if (oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
            if (oRequest.agoraCurrentUserData.country !== oRequestHead.country) oRequest.error(401, 'notAuthorizedCountry')
            if (oRequest.errors) return
            await checkInputValues(oRequest)
            await checkEditableFields(oRequest, oRequestHead.processFlowId, 'REQUEST_HEAD', null, null, true)
            
            if ('preferredProvider' in oRequest?.data) {
                let oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oRequest.data.preferredProvider} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                if (oVendor) oRequest.data.preferredProviderName = oVendor.name
            }
            await saveLog(oRequest, 'request')
            if (oRequest.data && 'manager' in oRequest.data) {
                oRequest.data.assignationDate = Date.now()
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }

    }

    afterUpdateRequest = async (oRequestHeads, oRequest) => {
        let aRequests = oRequestHeads.constructor === Array ? oRequestHeads : [oRequestHeads]

        for (let oRequest of aRequests) {
            if (oRequest && oRequest.manager) {
                let aRequestDocumentsDefaultValidators = await SELECT.from`REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID`.where`REQUEST_ID = ${oRequest.ID}`
                for (let oRequestDocumentDefaultValidators of aRequestDocumentsDefaultValidators) {
                    if (oRequest.manager && oRequestDocumentDefaultValidators.APPROVER_TYPE === 1) {
                        oRequestDocumentDefaultValidators.DEFAULT_RESPONSIBLE = oRequest.manager
                        await UPDATE.entity('REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID', { 'REGISTER_ID': oRequestDocumentDefaultValidators.REGISTER_ID }).with(oRequestDocumentDefaultValidators)
                    }
                }
            }
        }
    }

    afterReadRequestProvision = async (oResult, oRequest) => {
        let aProvisionHeads = oResult.constructor === Array ? oResult : [oResult]
        try {
            for (let oProvisionHead of aProvisionHeads) {
                let oProcessFlow = await SELECT.one.from`REQUEST_HEAD`.columns`PROCESS_ID`.where`REQUEST_ID = ${oProvisionHead.ID}`
                if (!oProcessFlow) continue
                if (oRequest.user.is(Roles.MANAGER_USER_ROL)) {
                    // only manager user can touch header
                    let oConfiguration = await getDisplayConfiguration(oRequest, oProcessFlow.PROCESS_ID, 'REQUEST_CHAR_PRO', null, null, true)
                    setDisplayConfiguration(oRequest, oProvisionHead, oConfiguration, oRequest.target.elements)
                    ComplexFieldsLogic.setVisibilityForEntity(true, null, null, oProvisionHead)
                } else {
                    setFCAs(oRequest, oProvisionHead, DisplayTypesFC.READONLY)
                }
                if (oProvisionHead.preferredProvider && oProvisionHead.preferredProvider !== null && oProvisionHead.preferredProvider !== '') {
                    let oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oProvisionHead.preferredProvider} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                    if (oVendor) oProvisionHead.preferredProviderName = oVendor.name
                }
                //NOSONAR if (oProvisionHead.PMOManager && oProvisionHead.PMOManager !== null && oProvisionHead.PMOManager !== '') {
                //NOSONAR     let oPMOManager = await SELECT.one.from`PMO_MANAGERS`.where`userId = ${oProvisionHead.PMOManager}`
                //NOSONAR     if (oPMOManager) oProvisionHead.PMOManagerName = oPMOManager.userName
                //NOSONAR }
                //NOSONAR if (oProvisionHead.requester && oProvisionHead.requester !== null && oProvisionHead.requester !== '') {
                //NOSONAR     let oRequester = await SELECT.one.from`REQUESTERS`.where`userId = ${oProvisionHead.requester}`
                //NOSONAR     if (oRequester) oProvisionHead.requesterName = oRequester.userName
                //NOSONAR }
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    beforeUpdateRequestProvision = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oRequest.data.ID}`
            if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
            if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
            if (oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
            if (oRequest.agoraCurrentUserData.country !== oRequestHead.country) oRequest.error(401, 'notAuthorizedCountry')
            if (oRequest.errors) return

            await checkInputValues(oRequest)
            if (oRequest.errors) return

            if ('preferredProvider' in oRequest?.data) updatePreferredProvider(oRequest)
            if ('preferredProvider' in oRequest?.data) {
                let oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oRequest.data.preferredProvider} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                if (oVendor) oRequest.data.preferredProviderName = oVendor.name
            }
            await saveLog(oRequest, 'request')
            await checkEditableFields(oRequest, oRequestHead.processFlowId, 'REQUEST_CHAR_PRO', null, null, true)
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    afterUpdateRequestProvision = async (oResult, oRequest) => {
        if (oResult && oResult.preferredProvider) {
            let aRequestDocumentsDefaultValidators = await SELECT.from`REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID`.where`REQUEST_ID = ${oResult.ID}`
            for (let oRequestDocumentDefaultValidators of aRequestDocumentsDefaultValidators) {
                if (oRequestDocumentDefaultValidators.APPROVER_TYPE === 2 && oRequestDocumentDefaultValidators.SUBCONTRACTOR === 3) {
                    oRequestDocumentDefaultValidators.DEFAULT_RESPONSIBLE = oResult.preferredProvider
                    await UPDATE.entity('REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID', { 'REGISTER_ID': oRequestDocumentDefaultValidators.REGISTER_ID }).with(oRequestDocumentDefaultValidators)
                }
            }
        }
    }

    onReopenRequest = async (oRequest, next) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oRequest.params[0]}`
                if (oRequestHead) {
                    await UserCode.currentUserDetails(oRequest)
                    if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
                    if (oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
                    if (oRequest.agoraCurrentUserData.country !== oRequestHead.country) oRequest.error(401, 'notAuthorizedCountry')
                    if (oRequest.errors) return
                    if (oRequestHead.status === RequestStatus.REQUEST_COMPLETED || oRequestHead.status === RequestStatus.REQUEST_CANCELLED) {
                        setRequestStatus(oRequest, RequestStatus.REQUEST_REOPENED, oRequestHead.ID)
                        if (!oRequest.errors) oRequest.reply(await SELECT.one.from`project.Requests`.where`ID = ${oRequest.params[0]}`)
                    } else {
                        oRequest.error(400, 'wrongRequestStatus')
                    }
                } else {
                    oRequest.error(400, 'requestNotFound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingRequestId')
        }
    }

    onCloseRequest = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oRequest.params[0]}`
                if (oRequestHead) {
                    await UserCode.currentUserDetails(oRequest)
                    if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
                    if (oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
                    if (oRequest.agoraCurrentUserData.country !== oRequestHead.country) oRequest.error(401, 'notAuthorizedCountry')
                    let oConfirmButtons = await SELECT.one.from`CONFIRM_BUTTONS(p_requestId : ${oRequest.params[0]}, p_master_phase_id : 'finalValidation', p_master_block_id : 'validDocument')`;
                    if (!(oConfirmButtons.BTTN_INV_UPDATED && oConfirmButtons.BTTN_SERV_UPDATED
                        && oConfirmButtons.BTTN_DOC_UPDATED)) {
                        if (!(oConfirmButtons.BTTN_INV_UPDATED)) {
                            oRequest.error(400, 'needConfirmationInv')
                        }
                        if (!(oConfirmButtons.BTTN_SERV_UPDATED)) {
                            oRequest.error(400, 'needConfirmationSer')
                        }
                        if (!(oConfirmButtons.BTTN_DOC_UPDATED)) {
                            oRequest.error(400, 'needConfirmationDoc')
                        }

                    }
                    if (oRequest.errors) return
                    if (oRequestHead.status === RequestStatus.REQUEST_REOPENED) {
                        let aOpenPhases = []
                        aOpenPhases = await SELECT.from`PHASE_HEAD`.where`REQUEST_ID = ${oRequest.params[0]} and PHASE_STATUS = ${PhaseStatus.PHASE_INPROGRESS}`
                        if (aOpenPhases.length === 0) {
                            setRequestStatus(oRequest, RequestStatus.REQUEST_COMPLETED, oRequestHead.ID)
                            if (!oRequest.errors) oRequest.reply(await SELECT.one.from`project.Requests`.where`ID = ${oRequest.params[0]}`)
                        } else {
                            oRequest.error(400, 'remainingOpenPhases')
                        }
                    } else {
                        oRequest.error(400, 'wrongRequestStatus')
                    }
                } else {
                    oRequest.error(400, 'requestNotFound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingRequestId')
        }
    }

    onCancelRequest = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.params[0]}`
                if (oRequestHead) {
                    await UserCode.currentUserDetails(oRequest)
                    if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
                    if (oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
                    if (oRequest.agoraCurrentUserData.country !== oRequestHead.COUNTRY_ID) oRequest.error(401, 'notAuthorizedCountry')
                    if (oRequest.errors) return
                    if (oRequestHead.REQUEST_STATUS === RequestStatus.REQUEST_INPROGRESS || oRequestHead.REQUEST_STATUS === RequestStatus.REQUEST_REOPENED) {
                        await checkCancelReason(oRequest, oRequest.data.cancellationReason)
                        if (oRequest.errors) return
                        let oValues = { 'REQUEST_STATUS': RequestStatus.REQUEST_CANCELLED, 'CANCELLATION_COMMENTS': oRequest.data.cancellationComments, 'CANCELLATION_REASON': oRequest.data.cancellationReason, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id }
                        await UPDATE.entity('REQUEST_HEAD', { 'REQUEST_ID': oRequestHead.REQUEST_ID }).with(oValues)
                        //NOSONAR await SalesForceHelper.notifySalesForceRequestStatusChange(oRequestHead.REQUEST_ID, RequestStatus.REQUEST_CANCELLED);
                        oRequest.reply(await SELECT.one.from`project.Requests`.where`ID = ${oRequest.params[0]}`)
                    } else {
                        oRequest.error(400, 'wrongRequestStatus')
                    }
                } else {
                    oRequest.error(400, 'missingRequestId')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingRequestId')
        }
    }

    onRequestSetOnHold = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.params[0]}`
                if (oRequestHead) {
                    await UserCode.currentUserDetails(oRequest)
                    if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
                    if (oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
                    if (oRequest.agoraCurrentUserData.country !== oRequestHead.COUNTRY_ID) oRequest.error(401, 'notAuthorizedCountry')
                    if (oRequest.errors) return
                    if (oRequestHead.REQUEST_STATUS === RequestStatus.REQUEST_INPROGRESS || oRequestHead.REQUEST_STATUS === RequestStatus.REQUEST_ON_HOLD) {
                        // only for inprogress or onhold request
                        let oValues = { 'REQUEST_STATUS': null, 'ON_HOLD_COMMENTS': null, 'ON_HOLD_REASON': null, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id }
                        if (oRequestHead.REQUEST_STATUS === RequestStatus.REQUEST_ON_HOLD) {
                            oValues.REQUEST_STATUS = RequestStatus.REQUEST_INPROGRESS
                        } else {
                            await checkOnHoldReason(oRequest, oRequest.data.onHoldReason)
                            if (oRequest.errors) return
                            oValues.REQUEST_STATUS = RequestStatus.REQUEST_ON_HOLD
                            oValues.ON_HOLD_COMMENTS = oRequest.data.onHoldComments
                            oValues.ON_HOLD_REASON = oRequest.data.onHoldReason
                        }
                        await UPDATE.entity('REQUEST_HEAD', { 'REQUEST_ID': oRequestHead.REQUEST_ID }).with(oValues)
                        //NOSONAR await SalesForceHelper.notifySalesForceRequestStatusChange(oRequestHead.REQUEST_ID, oValues.REQUEST_STATUS);
                        oRequest.reply(await SELECT.one.from`project.Requests`.where`ID = ${oRequest.params[0]}`)
                    } else {
                        // not allowed status
                        oRequest.error(400, 'wrongRequestStatus')
                    }
                } else {
                    oRequest.error(400, 'missingRequestId')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingRequestId')
        }
    }

    onTakeOwnershipRequest = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oRequest.params[0]}`
                if (oRequestHead && oRequestHead.manager !== null && oRequestHead.manager !== '') {
                    await UserCode.currentUserDetails(oRequest)
                    if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
                    if (oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
                    if (oRequest.agoraCurrentUserData.country !== oRequestHead.country) oRequest.error(401, 'notAuthorizedCountry')
                    if (oRequest.errors) return
                    await UPDATE.entity('REQUEST_HEAD', { 'REQUEST_ID': oRequestHead.ID }).with({ 'REQUEST_OWNER_ID': oRequest.user.id, ASSIGNATION_DATE: oRequest.timestamp, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id })
                    oRequest.reply(await SELEC.one.from`project.Requests`.where`ID = ${oRequest.params[0]}`)
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingRequestId')
        }
    }

    onConfirmInventoryCheck = async (oRequest, next, oDataServicesHandler) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.params[0]}`
            if (oRequestHead) {
                if (oRequestHead.SITE_ID && oRequestHead.SITE_ID !== '') {
                    try {
                        let aResult = await oDataServicesHandler.getInventoryStatus(oRequestHead.SITE_ID)
                        if (aResult && aResult.length > 0) {
                            let oResult = aResult.find(oResultSearch => oResultSearch.Status === 'E0001' || oResultSearch.Status === 'E0003')
                            if (oResult) return "true"
                        }
                    } catch (oError) {
                        oRequest.error(400, oError.message)
                    }
                } else {
                    oRequest.error(400, 'siteNotFound')
                }
            } else {
                oRequest.error(400, 'requestNotFound')
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
        return "false"
    }

    onConfirmInventory = async (oRequest, next) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.params[0]}`
            if (oRequestHead) {
                if (oRequestHead.SITE_ID && oRequestHead.SITE_ID !== '') {
                    try {
                        let oPhaseHead = await SELECT.one.from`PHASE_HEAD`.where`REQUEST_ID = ${oRequestHead.REQUEST_ID} and MASTER_PHASE_ID = 'finalValidation'`
                        let oBlockHead = await SELECT.one.from`BLOCK_HEAD`.where`PHASE_ID = ${oPhaseHead.PHASE_ID} and MASTER_BLOCK_ID = 'validDocument'`
                        await UPDATE('BLOCKS_PROVISIONING').set({ 'BTTN_INV_UPDATED': 'true' }).where({ 'BLOCK_ID': oBlockHead.BLOCK_ID })
                    } catch (oError) {
                        oRequest.error(400, oError.message)
                    }
                } else {
                    oRequest.error(400, 'siteNotFound')
                }
            } else {
                oRequest.error(400, 'requestNotFound')
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
        return "false"
    }

    onConfirmServices = async (oRequest, next) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.params[0]}`
            if (oRequestHead) {
                if (oRequestHead.SITE_ID && oRequestHead.SITE_ID !== '') {
                    try {
                        let oPhaseHead = await SELECT.one.from`PHASE_HEAD`.where`REQUEST_ID = ${oRequestHead.REQUEST_ID} and MASTER_PHASE_ID = 'finalValidation'`
                        let oBlockHead = await SELECT.one.from`BLOCK_HEAD`.where`PHASE_ID = ${oPhaseHead.PHASE_ID} and MASTER_BLOCK_ID = 'validDocument'`
                        await UPDATE('BLOCKS_PROVISIONING').set({ 'BTTN_SERV_UPDATED': 'true' }).where({ 'BLOCK_ID': oBlockHead.BLOCK_ID })
                    } catch (oError) {
                        oRequest.error(400, oError.message)
                    }
                } else {
                    oRequest.error(400, 'siteNotFound')
                }
            } else {
                oRequest.error(400, 'requestNotFound')
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
        return "false"
    }

    onConfirmDocuments = async (oRequest, oDataServiceHandler) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.params[0]}`
            if (oRequestHead) {
                if (oRequestHead.SITE_ID && oRequestHead.SITE_ID !== '') {
                    try {
                        let oPhaseHead = await SELECT.one.from`PHASE_HEAD`.where`REQUEST_ID = ${oRequestHead.REQUEST_ID} and MASTER_PHASE_ID = 'finalValidation'`
                        let oBlockHead = await SELECT.one.from`BLOCK_HEAD`.where`PHASE_ID = ${oPhaseHead.PHASE_ID} and MASTER_BLOCK_ID = 'validDocument'`
                        await UPDATE('BLOCKS_PROVISIONING').set({ 'BTTN_DOC_UPDATED': 'true' }).where({ 'BLOCK_ID': oBlockHead.BLOCK_ID })

                    } catch (oError) {
                        oRequest.error(400, oError.message)
                    }
                } else {
                    oRequest.error(400, 'siteNotFound')
                }
            } else {
                oRequest.error(400, 'requestNotFound')
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
        return "false"
    }

}

module.exports = { RequestsCode }