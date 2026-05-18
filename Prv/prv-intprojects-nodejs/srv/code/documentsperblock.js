const { Roles, Validators, BlockStatus, DocumentStatus, SubcoTypes, AssignedResponsibleTypes, DisplayTypesFC, ParentTypes, Actions, GlobalConstants } = require('../utils/enumerations')
const { UserCode } = require('./users')
const { saveLog, saveLogView, logDocumentEvent } = require('../utils/AuditLogger')
const {
    getHiddenDocumentTypes,
    getDocumentStatusInfo,
    getStatusSteps,
    getDPBDefaultValues,
    getDPBValidatorNotInit,
    getDPBValidatorResponsible,
    getDPBValidatorCellnex,
    getDPBValidatorSubcontractor,
    getDPBValidatorCustomer,
    getDPBValidatorSiteOwner,
    getDPBNotEditable,
    getDPBDeleted,
    getDefaultResponsible,
    getDPBEditabilityFields,
    getNextStep,
    getOTDocumentStatusBody,
    controlDPBActionsVisibility,
    checkDPBResponsible,
    DPBBooleanToText,
    checkDocumentValidators,
    addDocumentPerBlock,
    checkMandatoryFieldsIPD,
    checkCancelFieldIPD,
    udpateFlowTables,
    checkDocumentAuth,
    onNewDocumentPerRequest
} = require('../utils/documentsperblock')
const { getResponsible } = require('../utils/blocks')
const { checkInputValues, checkDocumentResponsible } = require('../utils/configurations')
const { sendDocumentStatusToOT } = require('../utils/documents')

class DPBCode {

    onReadDocumentFlowDocumentId = async (oRequest) => {
        if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
            let aResponse = []
            let aWhere = oRequest.query.SELECT.where
            let sBlockId
            for (let i = 0; i < aWhere.length; i++) {
                if (typeof aWhere[i] === 'object' && 'ref' in aWhere[i] && Array.isArray(aWhere[i].ref) && (aWhere[i].ref[0] === 'ID')) {
                    sBlockId = aWhere[i + 2].val
                    break
                }
            }
            try {
                await UserCode.currentUserDetails(oRequest)
                let oParent = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${sBlockId})`
                let oDocumentFlowPerProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`PROCESSID = ${oParent.PROCESS_ID}`
                let oDocumentFlowPerConfig = await SELECT.one.from`DOCUMENT_FLOWS_PER_CONFIG`.where`ID = ${oDocumentFlowPerProcess.Configuration_ID}`
                let oDocumentFlowPerBlock = await SELECT.from`DOCUMENT_FLOWS_PER_BLOCK`.where`DocumentFlowsPerConfig_ID = ${oDocumentFlowPerConfig.ID} and phase = ${oParent.MASTER_PHASE_ID} and block = ${oParent.MASTER_BLOCK_ID}`
                let aHiddenDocuments = await getHiddenDocumentTypes(oRequest, oParent.PROCESS_ID)
                for (let oDocumentFlow of oDocumentFlowPerBlock) {
                    if (oDocumentFlow.documentId !== null) {
                        if (!aHiddenDocuments.some((objeto) => objeto.documentId === oDocumentFlow.documentId)) {
                            let oDocumentMaster = await SELECT.one.from`DOCUMENT_FLOWS`.where`documentId = ${oDocumentFlow.documentId}`
                            if (oDocumentMaster) {
                                aResponse.push({
                                    'ID': sBlockId,
                                    'documentId': oDocumentMaster.documentId,
                                    'documentName': oDocumentMaster ? oDocumentMaster.documentName : ''
                                })
                            }
                        }
                    }
                }
                aResponse = aResponse.sort((a, b) => a.documentName.localeCompare(b.documentName));
                oRequest.reply(aResponse);
            } catch (oError) {
                oRequest.error(oError.message)
            }
        } else {
            oRequest.reply()
        }
    }

    /**
     * REFACTORED: afterReadDocumentsPerBlock with reduced cognitive complexity
     * This function processes documents per block with complex validation and authorization logic2
     * @param oResult: 
     */
    afterReadDocumentsPerBlock = async (oResult, oRequest) => {
        try {
            // Prepare request data
            const { aResults, oEntities, aHiddenDocuments } = await this.#prepareRequestData(oResult, oRequest);

            const aResponse = [];
            //collection-level reads or rows whose parent block is not (yet) materialized
            if (!oEntities || aResults.length === 0) { oRequest.reply([]); return }

            // Process each document result
            for (const oResult of aResults) {
                let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`
                let oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oEntities.REQUEST_ID}`;
                if (oRequestHead && oRequestHead.manager && parseInt(oResult.responsibleId, 10) === parseInt(AssignedResponsibleTypes.CELLNEX, 10) && oResult.responsibleDefault === null) {
                    await UPDATE`DOCUMENTS_PER_BLOCK`.set({ 'T_RESPONSIBLE': oRequestHead.manager }).where`REGISTER_ID = ${oResult.ID}`
                    oResult.responsibleDefault = oRequestHead.manager
                    oResult.cellnexResponsible = oRequestHead.manager
                } else if (oRequestProvision && oRequestProvision.preferredProvider && oResult.responsibleDefault === null && (parseInt(oResult.subcontractorId, 10) === SubcoTypes.VENDOR || oResult.subcontractorId === null) && parseInt(oResult.responsibleId, 10) === parseInt(AssignedResponsibleTypes.EXTERNAL, 10)) {
                    await UPDATE`DOCUMENTS_PER_BLOCK`.set({ 'T_RESPONSIBLE': oRequestProvision.preferredProvider, 'SUBCONTRATOR_ID': SubcoTypes.VENDOR.toString() }).where`REGISTER_ID = ${oResult.ID}`
                    oResult.responsibleDefault = oRequestProvision.preferredProvider
                    oResult.subcontractorResponsible = oRequestProvision.preferredProvider
                    oResult.subcontractorId = SubcoTypes.VENDOR.toString()
                    let oInstancesPerDocument = await SELECT.one.from`INSTANCES_PER_DOCUMENT`.where`INSTANCE_ID = ${oResult.ID}`;
                    if (oInstancesPerDocument.CELLNEX_VALIDATION && oInstancesPerDocument.CELLNEX_VALIDATOR === null) {
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oResult.ID }).with(
                            { CELLNEX_VALIDATOR: oRequestHead.manager }
                        )
                    } else {
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oResult.ID }).with(
                            {
                                CELLNEX_VALIDATOR:
                                    null
                            }
                        )
                    } 
                }

                const processedResult = await this.#processDocumentResult(oResult, oRequest, oEntities, aHiddenDocuments);
                if (processedResult) {
                    aResponse.push(processedResult);
                }
            }

            // Sort and return results
            oRequest.reply(this.#sortResultsByStatus(aResponse));
        } catch (oError) {
            oRequest.reject(400, oError.message);
        }
    }

    beforeUpdateDocumentsPerBlocks = async (oRequest) => {
        if (oRequest.params && oRequest.params.length > 0) {
            let oBlockHead, oRequestHead, oPhaseHead, oRequestProvision
            await checkInputValues(oRequest)
            if (oRequest.errors) return
            await checkDPBResponsible(oRequest)
            if (oRequest.errors) return


            if (oRequest.data && 'cellnexResponsible' in oRequest.data) {
                oRequest.data.responsibleDefault = oRequest.data.cellnexResponsible
            }
            if (oRequest.data && 'subcontractorResponsible' in oRequest.data) {
                oRequest.data.responsibleDefault = oRequest.data.subcontractorResponsible
            }
            if (oRequest.data && 'agencyResponsible' in oRequest.data) {
                oRequest.data.responsibleDefault = oRequest.data.agencyResponsible
            }
            let oDocumentsPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oRequest.data.ID}`;
            if (oDocumentsPerBlock && oDocumentsPerBlock.BLOCK_ID) oBlockHead = await SELECT.one.from`BLOCK_HEAD`.where`BLOCK_ID = ${oDocumentsPerBlock.BLOCK_ID}`;
            if (oBlockHead && oBlockHead.PHASE_ID) oPhaseHead = await SELECT.one.from`PHASE_HEAD`.where`PHASE_ID = ${oBlockHead.PHASE_ID}`;
            if (oPhaseHead && oPhaseHead.REQUEST_ID) oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oPhaseHead.REQUEST_ID}`;
            if (oRequestHead && oRequestHead.ID) oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.ID}`;
            if (oRequest.data && 'cellnexValidationVF' in oRequest.data) {
                oRequest.data.cellnexValidation = oRequest.data.cellnexValidationVF ? 'true' : 'false'
                if (oRequest.data.cellnexValidation) {
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        { CELLNEX_VALIDATOR: oRequestHead.manager }
                    )
                } else {
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        {
                            CUSTOMER_VALIDATOR:
                                null
                        }
                    )
                }
            } 
            if (oRequest.data && 'customerValidationVF' in oRequest.data) {
                oRequest.data.customerValidation = oRequest.data.customerValidationVF ? 'true' : 'false'
                if (oRequest.data.customerValidationVF) {
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        { CUSTOMER_VALIDATOR: oRequestHead.manager }
                    )
                } else {
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        {
                            CUSTOMER_VALIDATOR:
                                null
                        }
                    )
                }

            }
            if (oRequest.data && 'subcontractorValidationVF' in oRequest.data) {
                oRequest.data.subcontractorValidation = oRequest.data.subcontractorValidationVF ? 'true' : 'false'
                if (oRequest.data.subcontractorValidationVF) {
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        { SUBCONTRACTOR_VALIDATOR: oRequestProvision.preferredProvider }
                    )
                } else {
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        {
                            SUBCONTRACTOR_VALIDATOR:
                                null
                        }
                    )
                }

            }
            if (oRequest.data && 'siteOwnerValidationVF' in oRequest.data) oRequest.data.siteOwnerValidation = oRequest.data.siteOwnerValidationVF ? 'true' : 'false'



            if (oRequest.data && 'subcontractorId' in oRequest.data) {
                switch (parseInt(oRequest.data.subcontractorId, 10)) {
                    case SubcoTypes.VENDOR:
                        if (oRequestProvision) oRequest.data.responsibleDefault = oRequestProvision.preferredProvider
                        oRequest.data.cellnexValidation = true
                        oRequest.data.subcontractorValidation = false
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                            { SUBCONTRACTOR_VALIDATOR: null }
                        )
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                            { CELLNEX_VALIDATOR: oRequestHead.manager }
                        )
                        oRequest.data.customerValidation = true
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                            { CUSTOMER_VALIDATOR: oRequestHead.manager }
                        )
                        oRequest.data.subcontractorValidator = null
                        break
                    case SubcoTypes.AGENCY:
                        oRequest.data.responsibleDefault = null
                        oRequest.data.subcontractorValidator = null
                        oRequest.data.cellnexValidation = true
                        oRequest.data.subcontractorValidation = false
                        oRequest.data.customerValidation = true
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                            { CUSTOMER_VALIDATOR: oRequestProvision.preferredProvider }
                        )
                        break
                    case SubcoTypes.CUSTOMER:
                        oRequest.data.customerValidator = null
                        oRequest.data.responsibleDefault = oRequestHead.customer
                        oRequest.data.cellnexValidation = true

                        oRequest.data.subcontractorValidation = true
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                            { SUBCONTRACTOR_VALIDATOR: null }
                        )
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                            { CUSTOMER_VALIDATOR: null }
                        )
                        break
                    default:
                        oRequest.data.responsibleDefault = null
                        oRequest.data.cellnexValidation = false
                        oRequest.data.subcontractorValidation = false
                        oRequest.data.customerValidation = false
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                            { SUBCONTRACTOR_VALIDATOR: null }
                        )
                        await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                            { CUSTOMER_VALIDATOR: null }
                        )
                        break
                }
            }

            if (oRequest.data && 'responsibleId' in oRequest.data) {
                if (parseInt(oRequest.data.responsibleId, 10) === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                    if (oRequestHead) oRequest.data.responsibleDefault = oRequestHead.manager;
                    oRequest.data.subcontractorId = null;
                    oRequest.data.cellnexValidation = false
                    oRequest.data.subcontractorValidation = true
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        { CUSTOMER_VALIDATOR: oRequestProvision.preferredProvider }
                    )
                    oRequest.data.customerValidation = true
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        { CUSTOMER_VALIDATOR: oRequestHead.manager }
                    )
                } else if (parseInt(oRequest.data.responsibleId, 10) === parseInt(AssignedResponsibleTypes.EXTERNAL, 10)) {
                    if (oRequestProvision) oRequest.data.responsibleDefault = oRequestProvision.preferredProvider;
                    oRequest.data.subcontractorId = '3';
                    oRequest.data.cellnexValidation = true
                    oRequest.data.subcontractorValidation = false
                    oRequest.data.customerValidation = true
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        { CUSTOMER_VALIDATOR: oRequestHead.manager }
                    )
                } else {
                    oRequest.data.responsibleDefault = null;
                    oRequest.data.cellnexValidation = false
                    oRequest.data.subcontractorValidation = false
                    oRequest.data.customerValidation = false
                    await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': oRequest.data.ID }).with(
                        { CUSTOMER_VALIDATOR: null }
                    )
                }
            }

            if (oRequest.entity === 'project.DocumentsPerRequest') {
                let sOldValue, sNewValue, sFieldName
                let DocumentsPerRequest = await SELECT.one.from`project.DocumentsPerRequest`.where`ID = ${oRequest.data.ID}`;
                if (Object.keys(oRequest.data)[0] !== 'ID') {
                    sFieldName = Object.keys(oRequest.data)[0]
                    sNewValue = oRequest.data[Object.keys(oRequest.data)[0]]
                    sOldValue = DocumentsPerRequest[sFieldName]
                } else if (Object.keys(oRequest.data)[1]) {
                    sFieldName = Object.keys(oRequest.data)[1]
                    sNewValue = oRequest.data[Object.keys(oRequest.data)[1]]
                    sOldValue = DocumentsPerRequest[sFieldName]
                }
                if (sOldValue !== sNewValue) await saveLogView(oRequest, 'project.DocumentsPerBlocks', Actions.DOCUMENT_LINE_MODIFIED, sOldValue, sNewValue, sFieldName);
            } else {

                await saveLog(oRequest, 'project.DocumentsPerBlocks', Actions.DOCUMENT_LINE_MODIFIED);
            }
        } else {
            oRequest.error(400, 'missingBlockId')
        }
    }

    afterReadInstancesPerDocument = async (aResult, oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if (aResult.constructor !== Array) aResult = [aResult]
            let oDocumentsPerBlock, oEntities
            if (aResult.length > 0) {
                oDocumentsPerBlock = await SELECT.one.from`project.DocumentsPerBlocks`.where`ID = ${aResult[0].instanceId}`
                if (oDocumentsPerBlock) oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oDocumentsPerBlock.blockId})`
            }
            for (let oResult of aResult) {
                if (oResult) {
                    if (oResult.Documents === undefined) oResult.Documents = await SELECT.from`project.Documents`.where`instanceId = ${oResult.ID}`
                    if (oDocumentsPerBlock) {
                        oDocumentsPerBlock.InstancesPerDocuments = oResult
                        DPBBooleanToText(oDocumentsPerBlock)
                        if (oDocumentsPerBlock.responsibleId) {
                            let oApproverType = await SELECT.one.from`APPROVER_TYPES`.where`code = ${oDocumentsPerBlock.responsibleId}`
                            if (oApproverType) oResult["approverTypeName"] = oApproverType.name
                        }
                        if (oDocumentsPerBlock.subcontractorId && oDocumentsPerBlock.subcontractorId !== '' && oDocumentsPerBlock.subcontractorId !== 'null') {
                            let oSubcoType = await SELECT.one.from`SUBCO_TYPES`.where`code = ${oDocumentsPerBlock.subcontractorId}`
                            if (oSubcoType) oResult["subcoTypeName"] = oSubcoType.name
                        }
                        if (oDocumentsPerBlock.documentId) {
                            let documentOT = await SELECT.one.from`DOCUMENT_FLOWS`.where`documentId = ${oDocumentsPerBlock.documentId}`
                            if (documentOT) oResult["documentNameVF"] = documentOT.documentName
                        }
                        if (oDocumentsPerBlock.responsibleDefault) {
                            let oResponsibleDefault = await getDefaultResponsible(oDocumentsPerBlock.responsibleId, oDocumentsPerBlock.subcontractorId, oDocumentsPerBlock.responsibleDefault, oRequest)
                            if (oResponsibleDefault) oResult["responsibleDefaultNameVF"] = oResponsibleDefault.name
                        }
                        oResult["documentIdVF"] = oDocumentsPerBlock.documentId
                        oResult["blockId"] = oDocumentsPerBlock.blockId
                        oResult["blockIdVF"] = oDocumentsPerBlock.blockId
                        oResult["siteOwnerValidationVF"] = oDocumentsPerBlock.siterOwnerValidationVF
                        oResult["cellnexValidationVF"] = oDocumentsPerBlock.cellnexValidationVF
                        oResult["customerValidationVF"] = oDocumentsPerBlock.customerValidationVF
                        oResult["subcontractorValidationVF"] = oDocumentsPerBlock.subcontractorValidationVF
                        oDocumentsPerBlock["InstancesPerDocuments"] = oResult

                        let sParentType
                        let oParentHead
                        if (oResult.workId) {
                            sParentType = ParentTypes.WORK
                            oParentHead = await SELECT.one.from`project.Works`.where`ID = ${oResult.workId}`
                        } else {
                            sParentType = ParentTypes.BLOCK
                            oParentHead = await SELECT.one.from`project.Blocks`.where`ID = ${oDocumentsPerBlock.blockId}`
                        }

                        if (oResult !== undefined) oResult["buttonCompleteVF"] = false
                        await getDocumentStatusInfo(oDocumentsPerBlock, oRequest)
                        await getStatusSteps(oDocumentsPerBlock, oRequest)
                        let oBlockResponsible = await getResponsible(oRequest, sParentType, oParentHead)
                        let bAllAuth = oRequest.user.is(Roles.MANAGER_USER_ROL) ||
                            (oRequest.user.id === oBlockResponsible.ID && oBlockResponsible.isInternal && oRequest.user.is(Roles.CELLNEX_USER_ROL)) || // internal user assigned to block
                            (oRequest.user.is(oEntities.ROLE_ID)) || //User has block role
                            (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.CELLNEX && oRequest.user.id === oDocumentsPerBlock.responsibleDefault) //Internal user assigned to document
                        if (oResult.stepId === Validators.NOT_INI) {
                            if (bAllAuth ||
                                (!oBlockResponsible.isInternal && oBlockResponsible.ID === oRequest.agoraCurrentUserData?.vendor && oRequest.agoraCurrentUserData?.vendor !== null && oRequest.agoraCurrentUserData?.vendor !== '') ||
                                (!oBlockResponsible.isInternal && oBlockResponsible.ID === oRequest.agoraCurrentUserData?.agency && oRequest.agoraCurrentUserData?.agency !== null && oRequest.agoraCurrentUserData?.agency !== '')) {
                                await getDPBValidatorNotInit(oDocumentsPerBlock)
                                oResult = oDocumentsPerBlock.InstancesPerDocuments
                                if (oDocumentsPerBlock.status !== DocumentStatus.COMPLETED && oDocumentsPerBlock.status !== DocumentStatus.CANCELLED && oResult !== undefined) oResult["buttonCompleteVF"] = true
                            }
                        } else if (oResult.stepId === Validators.RESPONSIBLE) {
                            if (bAllAuth ||
                                (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.EXTERNAL && oRequest.agoraCurrentUserData?.vendor === oDocumentsPerBlock.responsibleDefault && oRequest.agoraCurrentUserData?.vendor !== null && oRequest.agoraCurrentUserData?.vendor !== '') || // external user assigned to document
                                (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.EXTERNAL && oRequest.agoraCurrentUserData?.agency === oDocumentsPerBlock.responsibleDefault && oRequest.agoraCurrentUserData?.agency !== null && oRequest.agoraCurrentUserData?.agency !== '')
                            ) {
                                oResult.contactPhoneFC = DisplayTypesFC.OPTIONAL
                                oResult.contactEmailFC = DisplayTypesFC.OPTIONAL
                                oResult.endDateFC = DisplayTypesFC.OPTIONAL
                                oResult.startDateFC = DisplayTypesFC.READONLY
                                oResult.submissionDateFC = DisplayTypesFC.READONLY
                                oResult.expectedSubmissionDateFC = DisplayTypesFC.MANDATORY
                                oResult.expirationDateFC = DisplayTypesFC.OPTIONAL
                                if (oDocumentsPerBlock.status !== DocumentStatus.COMPLETED && oDocumentsPerBlock.status !== DocumentStatus.CANCELLED && oResult !== undefined) oResult["buttonCompleteVF"] = true
                            }
                        } else if (oResult.stepId === Validators.CELLNEX) {
                            if (bAllAuth) {//internal user assigned to document
                                oResult.cellnexValidationCommentsFC = DisplayTypesFC.OPTIONAL
                                oResult.cellnexValidationDateFC = DisplayTypesFC.MANDATORY
                                oResult.cellnexValidatorFC = DisplayTypesFC.MANDATORY
                                oResult.cellnexValidationFC = DisplayTypesFC.MANDATORY
                                if (oDocumentsPerBlock.status !== DocumentStatus.COMPLETED && oDocumentsPerBlock.status !== DocumentStatus.CANCELLED && oResult !== undefined) oResult["buttonCompleteVF"] = true
                            }
                        } else if (oResult.stepId === Validators.SUBCO) {
                            if (bAllAuth ||
                                ((oResult.subcontractorValidator === oRequest.agoraCurrentUserData?.vendor && oRequest.agoraCurrentUserData?.vendor !== null && oRequest.agoraCurrentUserData?.vendor !== '') ||
                                    (oResult.subcontractorValidator === oRequest.agoraCurrentUserData?.agency && oRequest.agoraCurrentUserData?.agency !== null && oRequest.agoraCurrentUserData?.agency !== ''))) {
                                oResult.subcontractorValidationCommentsFC = DisplayTypesFC.OPTIONAL
                                oResult.subcontractorValidationDateFC = DisplayTypesFC.MANDATORY
                                oResult.subcontractorValidatorFC = DisplayTypesFC.MANDATORY
                                oResult.subcontractorValidationFC = DisplayTypesFC.MANDATORY
                                if (oDocumentsPerBlock.status !== DocumentStatus.COMPLETED && oDocumentsPerBlock.status !== DocumentStatus.CANCELLED && oResult !== undefined) oResult["buttonCompleteVF"] = true
                            }
                        } else if (oResult.stepId === Validators.CUSTOMER) {
                            if (bAllAuth || (oResult.customerValidator = oRequest.agoraCurrentUserData.customer?.ZCUSTOMER_ID && oRequest.agoraCurrentUserData.customer?.ZCUSTOMER_ID !== null && oRequest.agoraCurrentUserData.customer?.ZCUSTOMER_ID !== '')) { //external user assigned to instance step
                                oResult.customerValidationCommentsFC = DisplayTypesFC.OPTIONAL
                                oResult.customerValidationDateFC = DisplayTypesFC.MANDATORY
                                oResult.customerValidatorFC = DisplayTypesFC.MANDATORY
                                oResult.customerValidationFC = DisplayTypesFC.MANDATORY
                                oResult.customerInformDateFC = DisplayTypesFC.MANDATORY
                                if (oDocumentsPerBlock.status !== DocumentStatus.COMPLETED && oDocumentsPerBlock.status !== DocumentStatus.CANCELLED && oResult !== undefined) oResult["buttonCompleteVF"] = true
                            }
                        } else if (oResult.stepId === Validators.SITE_OWNER) {
                            if (bAllAuth) {
                                oResult.siteOwnerValidationCommentsFC = DisplayTypesFC.OPTIONAL
                                oResult.siteOwnerValidationDateFC = DisplayTypesFC.MANDATORY
                                oResult.siteOwnerValidatorFC = DisplayTypesFC.OPTIONAL
                                oResult.siteOwnervalidationFC = DisplayTypesFC.MANDATORY
                            }
                        } else {
                            oResult.contactPhoneFC = DisplayTypesFC.READONLY
                            oResult.contactEmailFC = DisplayTypesFC.READONLY
                            oResult.endDateFC = DisplayTypesFC.READONLY
                            oResult.startDateFC = DisplayTypesFC.READONLY
                            oResult.submissionDateFC = DisplayTypesFC.READONLY
                            oResult.expectedSubmissionDateFC = DisplayTypesFC.READONLY
                            oResult.expirationDateFC = DisplayTypesFC.READONLY
                            oResult.customerInformDateFC = DisplayTypesFC.READONLY
                            oResult.cellnexValidationCommentsFC = DisplayTypesFC.READONLY
                            oResult.cellnexValidationDateFC = DisplayTypesFC.READONLY
                            oResult.cellnexValidatorFC = DisplayTypesFC.READONLY
                            oResult.cellnexValidationFC = DisplayTypesFC.READONLY
                            oResult.subcontractorValidationCommentsFC = DisplayTypesFC.READONLY
                            oResult.subcontractorValidationDateFC = DisplayTypesFC.READONLY
                            oResult.subcontractorValidatorFC = DisplayTypesFC.READONLY
                            oResult.subcontractorValidationFC = DisplayTypesFC.READONLY
                            oResult.customerValidationCommentsFC = DisplayTypesFC.READONLY
                            oResult.customerValidationDateFC = DisplayTypesFC.READONLY
                            oResult.customerValidatorFC = DisplayTypesFC.READONLY
                            oResult.customerValidationFC = DisplayTypesFC.READONLY
                            oResult.siteOwnerValidationCommentsFC = DisplayTypesFC.READONLY
                            oResult.siteOwnerValidationDateFC = DisplayTypesFC.READONLY
                            oResult.siteOwnerValidatorFC = DisplayTypesFC.READONLY
                            oResult.siteOwnervalidationFC = DisplayTypesFC.READONLY
                        }
                        if (oDocumentsPerBlock.cellnexValidationVF !== true) {
                            oResult["cellnexValidationVF"] = false
                            oResult.cellnexValidationCommentsFC = DisplayTypesFC.HIDDEN
                            oResult.cellnexValidationDateFC = DisplayTypesFC.HIDDEN
                            oResult.cellnexValidatorFC = DisplayTypesFC.HIDDEN
                            oResult.cellnexValidationFC = DisplayTypesFC.HIDDEN
                        }
                        if (oDocumentsPerBlock.subcontractorValidationVF !== true) {
                            oResult["subcontractorValidationVF"] = false
                            oResult.subcontractorValidationCommentsFC = DisplayTypesFC.HIDDEN
                            oResult.subcontractorValidationDateFC = DisplayTypesFC.HIDDEN
                            oResult.subcontractorValidatorFC = DisplayTypesFC.HIDDEN
                            oResult.subcontractorValidationFC = DisplayTypesFC.HIDDEN
                        }
                        if (oDocumentsPerBlock.customerValidationVF !== true) {
                            oResult["customerValidationVF"] = false
                            oResult.customerValidationCommentsFC = DisplayTypesFC.HIDDEN
                            oResult.customerValidationDateFC = DisplayTypesFC.HIDDEN
                            oResult.customerValidatorFC = DisplayTypesFC.HIDDEN
                            oResult.customerValidationFC = DisplayTypesFC.HIDDEN
                        }
                        if (oDocumentsPerBlock.siteOwnerValidationVF !== true) {
                            oResult["siteOwnerValidationVF"] = false
                            oResult.siteOwnerValidationCommentsFC = DisplayTypesFC.HIDDEN
                            oResult.siteOwnerValidationDateFC = DisplayTypesFC.HIDDEN
                            oResult.siteOwnerValidatorFC = DisplayTypesFC.HIDDEN
                            oResult.siteOwnervalidationFC = DisplayTypesFC.HIDDEN
                        }
                    } else {
                        if (oResult.InstancesPerDocuments !== undefined) oResult["buttonCompleteVF"] = false
                        oResult.contactPhoneFC = DisplayTypesFC.READONLY
                        oResult.contactEmailFC = DisplayTypesFC.READONLY
                        oResult.endDateFC = DisplayTypesFC.READONLY
                        oResult.startDateFC = DisplayTypesFC.READONLY
                        oResult.submissionDateFC = DisplayTypesFC.READONLY
                        oResult.expectedSubmissionDateFC = DisplayTypesFC.READONLY
                        oResult.expirationDateFC = DisplayTypesFC.READONLY

                        oResult.customerInformDateFC = DisplayTypesFC.READONLY
                        oResult.cellnexValidationCommentsFC = DisplayTypesFC.READONLY
                        oResult.cellnexValidationDateFC = DisplayTypesFC.READONLY
                        oResult.cellnexValidatorFC = DisplayTypesFC.READONLY
                        oResult.cellnexValidationFC = DisplayTypesFC.READONLY
                        oResult.subcontractorValidationCommentsFC = DisplayTypesFC.READONLY
                        oResult.subcontractorValidationDateFC = DisplayTypesFC.READONLY
                        oResult.subcontractorValidatorFC = DisplayTypesFC.READONLY
                        oResult.subcontractorValidationFC = DisplayTypesFC.READONLY
                        oResult.customerValidationCommentsFC = DisplayTypesFC.READONLY
                        oResult.customerValidationDateFC = DisplayTypesFC.READONLY
                        oResult.customerValidatorFC = DisplayTypesFC.READONLY
                        oResult.customerValidationFC = DisplayTypesFC.READONLY
                        oResult.siteOwnerValidationCommentsFC = DisplayTypesFC.READONLY
                        oResult.siteOwnerValidationDateFC = DisplayTypesFC.READONLY
                        oResult.siteOwnerValidatorFC = DisplayTypesFC.READONLY
                        oResult.siteOwnervalidationFC = DisplayTypesFC.READONLY
                    }
                    let oVendor, oCellnexValidator, oCustomerValidator
                    if (oResult.subcontractorValidator && oResult.subcontractorValidator !== '') oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oResult.subcontractorValidator} and ( entityType = 'F4_PROV_VENDOR_GEWRK' or entityType = 'F4_GEWRK_AGEN' )`;
                    if (oVendor) oResult.subcontractorValidatorName = oVendor.name
                    if (oResult.cellnexValidator && oResult.cellnexValidator !== '') oCellnexValidator = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oResult.cellnexValidator}`
                    if (oCellnexValidator) oResult.cellnexValidatorName = oCellnexValidator.USER_NAME
                    if (oResult.customerValidator && oResult.customerValidator !== '') oCustomerValidator = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oResult.customerValidator}`
                    if (oCustomerValidator) oResult.customerValidatorName = oCustomerValidator.USER_NAME
                }
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    beforeUpdateInstancesPerDocument = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            await checkInputValues(oRequest)
            await checkDocumentValidators(oRequest)
            await saveLog(oRequest, 'project.InstancesPerDocuments', Actions.DOCUMENT_LINE_MODIFIED);
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onDocFlowFirstSave = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                let oDocumentsPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oRequest.params[0]}`
                if (oDocumentsPerBlock) {
                    if ((oDocumentsPerBlock.RESPONSIBLE_ID !== null) && (oDocumentsPerBlock.RESPONSIBLE_ID == AssignedResponsibleTypes.CELLNEX ||
                        (oDocumentsPerBlock.RESPONSIBLE_ID === AssignedResponsibleTypes.EXTERNAL))) {
                        await udpateFlowTables(oRequest, oDocumentsPerBlock.REGISTER_ID, DocumentStatus.IN_PROGRESS, Validators.RESPONSIBLE, false, null, Validators.NOT_INI, null)
                        //NOSONAR oRequest.reply(await SELECT .from `project.DocumentsPerBlocks` .where`ID = ${oDocumentsPerBlock.REGISTER_ID}`)
                        if (oRequest.errors) return
                        await logDocumentEvent(oRequest, Actions.DOCUMENT_INITIALIZE);
                    } else {
                        oRequest.error(400, 'fillMandatoryFields')
                    }
                } else {
                    oRequest.error(400, 'dpbnotfound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
    }

    beforeNextStep = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
                let bHasAuth = checkDocumentAuth(oRequest, oRequest.params[0])
                if (!bHasAuth) {
                    oRequest.error(400, 'notAuthorized')
                }
            } else {
                oRequest.error(400, 'missingParameters')
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onNextStep = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                //NOSONAR Maybe a rare experiment this.sendProcessSToCreatDirectAccessToOT(oRequest) 
                let oDocumentsPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oRequest.params[0]}`
                let oInstancesPerDocument = await SELECT.one.from`INSTANCES_PER_DOCUMENT`.where`INSTANCE_ID = ${oRequest.params[0]}`
                let oDocuments, oStatusOtToSend
                if (oInstancesPerDocument) {
                    let sNextStep = getNextStep(oInstancesPerDocument.STEP_ID, oDocumentsPerBlock.VALIDATION_CELLNEX_CLIENT, oDocumentsPerBlock.VALIDATION_SUBCO_CLIENT, oDocumentsPerBlock.VALIDATION_REQ_CLIENT, oDocumentsPerBlock.VALIDATION_SITEOWNER_NEEDED, oInstancesPerDocument.CELLNEX_VALIDATION, oInstancesPerDocument.SUBCONTRACTOR_VALIDATION, oInstancesPerDocument.CUSTOMER_VALIDATION, oInstancesPerDocument.SITEOWNER_VALIDATION)
                    await checkMandatoryFieldsIPD(oRequest, oInstancesPerDocument)
                    if (oRequest.errors) return
                    if (sNextStep !== Validators.COMPLETED) {
                        await udpateFlowTables(oRequest, oDocumentsPerBlock.REGISTER_ID, DocumentStatus.IN_PROGRESS, sNextStep, false, null, oInstancesPerDocument.STEP_ID, oInstancesPerDocument)
                        oDocuments = await SELECT.from`project.Documents`.where`instanceId = ${oInstancesPerDocument.REGISTER_ID}`
                        if (oDocuments) oStatusOtToSend = getOTDocumentStatusBody(oDocuments, oDocumentsPerBlock.STATUS, oInstancesPerDocument.STEP_ID)
                        if (oStatusOtToSend) sendDocumentStatusToOT(oRequest, oStatusOtToSend)
                        //NOSONAR Maybe a rare experiment this.sendProcessSToCreatDirectAccessToOT()
                        oRequest.reply(await SELECT.from`project.DocumentsPerBlocks`.where`ID = ${oRequest.params[0]}`)
                        if (oRequest.errors) return
                        await logDocumentEvent(oRequest, Actions.DOCUMENT_NEXTSTEP);
                    } else if (sNextStep === Validators.COMPLETED) {
                        await udpateFlowTables(oRequest, oDocumentsPerBlock.REGISTER_ID, DocumentStatus.COMPLETED, sNextStep, false, null, oInstancesPerDocument.STEP_ID, oInstancesPerDocument)
                        oDocuments = await SELECT.from`project.Documents`.where`instanceId = ${oInstancesPerDocument.REGISTER_ID}`
                        if (oDocuments) oStatusOtToSend = getOTDocumentStatusBody(oDocuments, oDocumentsPerBlock.STATUS, oInstancesPerDocument.STEP_ID,)
                        if (oStatusOtToSend) sendDocumentStatusToOT(oRequest, oStatusOtToSend)
                        oRequest.reply(await SELECT.from`project.DocumentsPerBlocks`.where`ID = ${oRequest.params[0]}`)
                        if (oRequest.errors) return
                        await logDocumentEvent(oRequest, Actions.DOCUMENT_FINALIZED);
                    } else {
                        oRequest.error(400, 'nextValidatorCouldNotBeDetermined')
                    }
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

    onCancelDocument = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0 && 'cancellationReason' in oRequest.data) {
            try {
                let oDocumentsPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oRequest.params[0]}`
                await udpateFlowTables(oRequest, oDocumentsPerBlock.REGISTER_ID, DocumentStatus.CANCELLED, null, true, oRequest.data.cancellationReason, null, null)
                await logDocumentEvent(oRequest, Actions.DOCUMENT_CANCELLED);
                //NOSONAR oRequest.reply(await SELECT .from `project.DocumentsPerBlocks` .where `ID = ${oDocumentsPerBlock.REGISTER_ID}`)
                if (oRequest.errors) return
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
    }

    beforeCancelIPDocument = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0 && 'cancellationReason' in oRequest.data) {
            try {
                let oIPD = await SELECT.one.from`INSTANCES_PER_DOCUMENTS`.where`REGISTER_ID = ${oRequest.params[0]}`
                let oDPB = await SELECT.one.from`DOCUMENTS_OER_BLOCKS`.where`REGISTER_ID = ${oIPD.INSANCE_ID}`
                let bHasAuth = checkDocumentAuth(oRequest, oDPB.REGSITER_ID)
                if (!bHasAuth) {
                    oRequest.error(400, 'notAuthorized')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
    }

    /**
     * REFACTORED: Cancels an IP Document and creates a new version
     * This method has been simplified by extracting helper functions to reduce cognitive complexity
     */
    onCancelIPDocument = async (oRequest) => {
        // Early validation - fail fast if request is invalid
        if (!this.#validateCancellationRequest(oRequest)) {
            oRequest.error(400, 'missingParameters');
            return;
        }

        try {
            await this.#handleDocumentCancellationWorkflow(oRequest);

            // Check for any errors that occurred during processing
            if (oRequest.errors) {
                return;
            }
        } catch (error) {
            oRequest.error(400, error.message);
        }
    }

    sortByList = (list, arr) => arr.sort(
        (a, b) => list.indexOf(a.status) - list.indexOf(b.status)
    )

    onAddDocumentsPerRequest = async (oRequest) => {
        await onNewDocumentPerRequest(oRequest)
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

    inBothArrayOfObjects = async (list1, list2, sProperty1, sProperty2) => {
        return await this.operationWithArrays(list1, list2, true, sProperty1, sProperty2);
    }

    inFirstOnlyArrayOfObjects = async (list1, list2, sProperty1, sProperty2) => {
        return await this.operationWithArrays(list1, list2, false, sProperty1, sProperty2);
    }

    inSecondOnlyArrayOfObjects = async (list1, list2, sProperty1, sProperty2) => {
        return await this.inFirstOnly(list2, list1, false, sProperty1, sProperty2);
    }

    onDeleteRequestDocumentsPerBlockDefaultValid = async (oRequest) => {
        try {
            await UPDATE('REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID').set({ 'DELETED': true, 'DELETED_BY': oRequest.user.id, 'DELETED_AT': oRequest.timestamp }).where({ 'REGISTER_ID': oRequest.data.registerId })
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    afterReadRequestDocumentsPerBlockDefaultValid = async (aResult, oRequest) => {
        try {
            let aux = [];
            if (aResult.constructor !== Array) {
                aResult = [aResult];
            }
            if (aResult.length > 0 && aResult[0] && aResult[0].requestId) {

                let oRequestHead

                let oDocProcess;
                oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${aResult[0].requestId}`;
                if (!oRequestHead) { oRequest.reply(aux); return }
                oDocProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`processId = ${oRequestHead.processFlowId}`
                if (!oDocProcess) { oRequest.reply(aux); return }
                let aDocumentRolesNotVisible = await SELECT.from`DOCUMENT_FLOWS_HIDDEN_PER_ROLE`.where`DocumentFlowsPerConfig_ID = ${oDocProcess.Configuration_ID} and active = true`;

                let aRoles = await SELECT.from`US_ROLES_AGR`.where`USER_ID = ${oRequest.user.id}`;
                let auxNotVisibleDocs = await this.inBothArrayOfObjects(aDocumentRolesNotVisible, aRoles, 'IASGroup', 'IAS_GROUP')
                aux = await this.inFirstOnlyArrayOfObjects(aResult, auxNotVisibleDocs, 'documentId', 'documentId')

                let sMasterBlockId = 'requestConfigur'
                let sBlockId = await SELECT.one.from`GET_BLOCK_ID_FROM_MASTERBLOCK_ID(p_requestId: ${aResult[0].requestId},p_masterBlockId: ${sMasterBlockId})`

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
                                        oDocumentsPerBlockDefaultValid.customerResponsibleFC = DisplayTypesFC.READONLY
                                        if (oRequestHead) oDocumentsPerBlockDefaultValid.customerResponsibleName = oRequestHead.CUSTOMER_NAME
                                        break
                                    case parseInt(SubcoTypes.VENDOR, 10):
                                        let oVendor
                                        if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oDocumentsPerBlockDefaultValid.responsibleDefault} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                                        oDocumentsPerBlockDefaultValid.subcontractorResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                        oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = ''
                                        oDocumentsPerBlockDefaultValid.subcontractorResponsibleFC = DisplayTypesFC.READONLY
                                        if (oVendor) oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = oVendor.name
                                        break
                                    case parseInt(SubcoTypes.AGENCY, 10):
                                        let oAgency
                                        if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oAgency = await await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oDocumentsPerBlockDefaultValid.responsibleDefault} and entityType = 'F4_GEWRK_AGEN'`;
                                        oDocumentsPerBlockDefaultValid.agencyResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                        oDocumentsPerBlockDefaultValid.agencyResponsibleName = ''
                                        oDocumentsPerBlockDefaultValid.agencyResponsibleFC = DisplayTypesFC.READONLY
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
                                switch (parseInt(oDocumentsPerBlockDefaultValid.subcontractorId, 10)) {
                                    case parseInt(SubcoTypes.CUSTOMER, 10):
                                        let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oDocumentsPerBlockDefaultValid.requestId}`
                                        oDocumentsPerBlockDefaultValid.customerResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                        oDocumentsPerBlockDefaultValid.customerResponsibleName = ''
                                        oDocumentsPerBlockDefaultValid.customerResponsibleFC = 1
                                        if (oRequestHead) oDocumentsPerBlockDefaultValid.customerResponsibleName = oRequestHead.CUSTOMER_NAME
                                        break
                                    case parseInt(SubcoTypes.VENDOR, 10):
                                        let oVendor
                                        if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oDocumentsPerBlockDefaultValid.responsibleDefault} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                                        oDocumentsPerBlockDefaultValid.subcontractorResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                        oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = ''
                                        oDocumentsPerBlockDefaultValid.subcontractorResponsibleFC = 3
                                        if (oVendor) oDocumentsPerBlockDefaultValid.subcontractorResponsibleName = oVendor.name
                                        break
                                    case parseInt(SubcoTypes.AGENCY, 10):
                                        let oAgency
                                        if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') oAgency = await await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oDocumentsPerBlockDefaultValid.responsibleDefault} and entityType = 'F4_GEWRK_AGEN'`;
                                        oDocumentsPerBlockDefaultValid.agencyResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                        oDocumentsPerBlockDefaultValid.agencyResponsibleName = ''
                                        oDocumentsPerBlockDefaultValid.agencyResponsibleFC = 3
                                        if (oAgency) oDocumentsPerBlockDefaultValid.agencyResponsibleResponsibleName = oAgency.name
                                        break
                                }
                            }
                        }
                    }
                }
            }
            aResult = aux
            aResult.sort((a, b) => a.docOrder - b.docOrder);
            oRequest.reply(aux)
        }
        catch (error) {
            oRequest.reject(400, error.message);
        }
    }

    onReadDocumentFlowDefaultValidDocumentId = async (oRequest) => {
        if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
            try {
                let aWhere = oRequest.query.SELECT.where
                let sBlockId
                for (let i = 0; i < aWhere.length; i++) {
                    if (typeof aWhere[i] === 'object' && 'ref' in aWhere[i] && Array.isArray(aWhere[i].ref) && (aWhere[i].ref[0] === 'ID')) {
                        sBlockId = aWhere[i + 2].val
                        break
                    }
                }
                let oParent = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${sBlockId})`
                let oDocumentFlowPerProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`PROCESSID = ${oParent.PROCESS_ID}`
                let oDocumentFlowPerConfig = await SELECT.one.from`DOCUMENT_FLOWS_PER_CONFIG`.where`ID = ${oDocumentFlowPerProcess.Configuration_ID}`
                let aDocumentFlowPerBlock = await SELECT.distinct.from`DOCUMENT_FLOWS_PER_BLOCK`.where`DocumentFlowsPerConfig_ID = ${oDocumentFlowPerConfig.ID}`
                let aDocumentRolesNotVisible = await SELECT.from`DOCUMENT_FLOWS_HIDDEN_PER_ROLE`.where`DocumentFlowsPerConfig_ID = ${oDocumentFlowPerConfig.ID} and active = true`;
                let aResponse = []
                let aux = []

                let aRoles = await SELECT.from`US_ROLES_AGR`.where`USER_ID = ${oRequest.user.id}`
                if (aDocumentRolesNotVisible && aDocumentRolesNotVisible.length > 0) {
                    for (let sRole of aRoles) {
                        let aFilteredDocs = aDocumentRolesNotVisible.filter(oDocRole => oDocRole.IASGroup === sRole.IAS_GROUP)
                        if (aFilteredDocs && aFilteredDocs.length > 0) aux = aux.concat(aFilteredDocs)
                    }
                }
                if (aux && aux.length > 0) {
                    aDocumentFlowPerBlock = aDocumentFlowPerBlock.filter(oResult => {
                        let oWhatEver = aux.find(oAux => oAux.documentId === oResult.documentId)
                        if (oWhatEver == undefined) return oResult
                    })
                }

                for (let oDocumentFlowPerBlock of aDocumentFlowPerBlock) {
                    let oDocumentName = await SELECT.one.from`DOCUMENT_FLOWS`.where`documentId = ${oDocumentFlowPerBlock.documentId}`
                    let oResponse
                    if (oDocumentName) {
                        oResponse = {
                            'documentId': oDocumentFlowPerBlock.documentId,
                            'documentName': oDocumentName.documentName
                        }
                    } else {
                        oResponse = {
                            'documentId': oDocumentFlowPerBlock.documentId,
                            'documentName': null
                        }
                    }
                    aResponse.push(oResponse)
                }
                oRequest.reply(aResponse)
            } catch (oError) {
                oRequest.reply(oError.message)
            }
        } else {
            oRequest.reply()
        }
    }

    onReadDocumentFlowResponsiblesDefaultValid = async (oRequest) => {
        if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
            let aWhere = oRequest.query.SELECT.where
            let aNewWhere = []
            let oParams = {}
            for (let i = 0; i < aWhere.length; i++) {
                if (typeof aWhere[i] === 'object' && 'ref' in aWhere[i] && Array.isArray(aWhere[i].ref) && (aWhere[i].ref[0] === 'ID')) {
                    aNewWhere.pop()
                    oParams[aWhere[i].ref[0]] = aWhere[i + 2].val
                    i = i + 3
                } else {
                    aNewWhere.push(aWhere[i])
                }
            }
            try {
                let oRequestHead

                let oDocumentDefaultValid = await SELECT.one.from`REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID`.where`REGISTER_ID = ${oParams.ID}`
                oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oDocumentDefaultValid.REQUEST_ID}`
                let sTable
                if (oDocumentDefaultValid.APPROVER_TYPE === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                    sTable = 'USERSDPB'
                } else {
                    switch (parseInt(oDocumentDefaultValid.SUBCONTRACTOR, 10)) {
                        case 1:
                            sTable = 'USERSDPB'
                            break
                        case SubcoTypes.CUSTOMER:
                            sTable = 'CUSTOMERS_USERS'
                            break
                        case SubcoTypes.VENDOR:
                            sTable = 'VENDORS_USERS'
                            break
                        case SubcoTypes.AGENCY:
                            sTable = 'AGENCIES_USERS'
                            break
                    }
                }
                if (oDocumentDefaultValid.APPROVER_TYPE === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                    let oCQLQuery = cds.parse.cql(`SELECT * from ${sTable}(p_country: '${oRequestHead.COUNTRY_ID}')`)
                    oCQLQuery.SELECT.columns = oRequest.query.SELECT?.columns
                    oCQLQuery.SELECT.orderBy = oRequest.query.SELECT?.orderBy
                    oCQLQuery.SELECT.limit = oRequest.query.SELECT?.limit
                    if (aNewWhere.length > 0) oCQLQuery.SELECT.where = aNewWhere
                    let aResults = await cds.run(oCQLQuery)
                    oRequest.reply(aResults)
                } else {
                    let aMappedResult = []
                    switch (parseInt(oDocumentDefaultValid.SUBCONTRACTOR, 10)) {
                        case SubcoTypes.CUSTOMER:

                            Request.reply(aMappedResult)
                            break
                        case SubcoTypes.VENDOR:
                            aMappedResult = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and entityType = 'F4_PROV_VENDOR_GEWRK'`;

                            oRequest.reply(aMappedResult)
                            break
                        case SubcoTypes.AGENCY:
                            aMappedResult = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and entityType = 'F4_GEWRK_AGEN'`;

                            oRequest.reply(aMappedResult)
                            break
                    }
                }
            } catch (oError) {
                oRequest.reply(oError.message)
            }
        } else {
            oRequest.reply()
        }
    }

    onAddRequestDocumentsPerBlockDefaultValid = async (oRequest) => {
        if ('documentId' in oRequest.data && oRequest.params.constructor === Array && oRequest.params.length > 0 && oRequest.data.documentId !== '' && oRequest.data.documentId !== null) {
            try {
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.params[0]})`
                let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`
                let oCheckExistent = await SELECT.from`project.RequestDocumentsPerBlockDefaultValid`.where`DELETED = false and requestId = ${oEntities.REQUEST_ID} and documentId = ${oRequest.data.documentId}`
                if (oCheckExistent.length > 0) {
                    oRequest.error(400, 'documentEntryAlreadyExists')
                } else {
                    let oDocumentsPerBlockValid = {
                        'REQUEST_ID': oEntities.REQUEST_ID,
                        'DOCUMENT_ID': oRequest.data.documentId,
                        'APPROVER_TYPE': 1,
                        'SUBCONTRACTOR': null,
                        'DEFAULT_RESPONSIBLE': oRequestHead.colocationManager,
                        'SUBCO_REQ_VAL': true,
                        'CELLNEX_REQ_VAL': false,
                        'CUSTOMER__REQ_VAL': true,
                        'SITEOWNER_REQ_VAL': false,
                        'CREATEDAT': oRequest.timestamp,
                        'CREATEDBY': oRequest.user.id,
                        'MODIFIEDAT': oRequest.timestamp,
                        'MODIFIEDBY': oRequest.user.id,
                        'DELETED': false,
                        'REGISTER_ID': cds.utils.uuid()
                    }
                    await INSERT.into('REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID')
                        .entries(oDocumentsPerBlockValid)
                    oRequest.reply(await SELECT.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`)
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
    }

    deleteAllDocumentsPerBlockDefaultValid = async (oRequest) => {
        try {
            let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.params[0]})`
            //NOSONAR let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`
            let oCheckExistents = await SELECT.from`project.RequestDocumentsPerBlockDefaultValid`.where`DELETED = false and requestId = ${oEntities.REQUEST_ID}`
            for (let oDefaultExistingDoc of oCheckExistents) {
                await UPDATE('REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID').set({ 'DELETED': true, 'DELETED_BY': oRequest.user.id, 'DELETED_AT': oRequest.timestamp }).where({ 'REGISTER_ID': oDefaultExistingDoc.ID })
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onUpdateToDefaultDocumentsPerBlockDefaultValid = async (oRequest) => {
        try {
            let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.params[0]})`
            let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oEntities.REQUEST_ID}`
            let oRequestProvision
            if (oRequestHead) oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oEntities.REQUEST_ID}`
            if (oRequestHead && oRequestProvision) await this.#onAddRequestDocumentsDefaultParamPerBlock(oRequest, oEntities.PROCESS_ID, oRequestHead.REQUEST_ID, oRequestHead.REQUEST_OWNER_ID, oRequestHead.CUSTOMER_ID, oRequestProvision.preferredProvider)

        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onCancelDefaultValidators = async (oRequest) => {
        if (
            "dpbRegisterId" in oRequest.data &&
            oRequest.params.constructor === Array &&
            oRequest.params.length > 0 &&
            oRequest.data.dpbRegisterId !== "" &&
            oRequest.data.dpbRegisterId !== null
        ) {
            try {
                await UPDATE.entity("REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID", {
                    REGISTER_ID: oRequest.data.dpbRegisterId,
                }).with({
                    DELETED: true,
                    DELETED_AT: oRequest.timestamp,
                    DELETED_BY: oRequest.user.id,
                });
                if (oRequest.errors) return;
            } catch (oError) {
                oRequest.error(400, oError.message);
            }
        } else {
            oRequest.error(400, "missingParameters");
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

    checkInputValues = async (oRequest) => {
        for (let sField in oRequest.data) {
            let sAssociation = 'project.' + oRequest.target.elements[sField]['@Common.ValueList.CollectionPath']
            if (GlobalConstants.aExternalValueHelps.indexOf(sAssociation) < 0) {
                // Check against DB entity
                let oVHEntity = cds.entities[sAssociation]
                if (oVHEntity) {
                    let sTargetEntity = oVHEntity.name
                    let aWhere = []
                    for (let oParameter of oRequest.target.elements[sField]['@Common.ValueList.Parameters']) {
                        const isNullable = oParameter['@odata.Nullable'] === true;
                        if (oParameter.$Type === 'Common.ValueListParameterInOut' && oParameter.LocalDataProperty['='] === sField) {
                            if (oRequest.data[sField] == null) {
                                if (isNullable) {
                                    // skip validation for nullables
                                    continue;
                                }
                            } else if (oRequest.target.elements[sField].type === 'cds.Integer') {
                                if (oRequest.data[sField])
                                    if (!Number.isNaN(oRequest.data[sField])) {
                                        aWhere.push(oParameter.ValueListProperty)
                                        aWhere.push('=')
                                        aWhere.push("'" + oRequest.data[sField] + "'")
                                    } else {
                                        oRequest.error(400, 'notValidValue', `/${oRequest.target.name.split('.')[1]}(guid'${oRequest.data.ID}')/${sField}`, [oRequest.data[sField], sField])
                                    }
                                else {
                                    aWhere.push(oParameter.ValueListProperty)
                                    aWhere.push('=')
                                    aWhere.push('0')
                                }
                            } else {
                                aWhere.push(oParameter.ValueListProperty)
                                aWhere.push('=')
                                aWhere.push("'" + oRequest.data[sField] + "'")
                            }
                        } else {
                            if (oParameter.$Type === 'Common.ValueListParameterIn') {
                                let oQueryEntityData = {
                                    SELECT: {
                                        from: oRequest.subject,
                                        one: true,
                                        where: oRequest.subject.ref[0].where
                                    }
                                }
                                let oEntityData = await cds.run(oQueryEntityData)
                                if (oEntityData && oEntityData[oParameter.LocalDataProperty['=']] && oEntityData[oParameter.LocalDataProperty['=']] !== 0) {
                                    if (aWhere.length > 0) aWhere.push('and')
                                    aWhere.push(oParameter.ValueListProperty)
                                    aWhere.push('=')
                                    aWhere.push("'" + oEntityData[oParameter.LocalDataProperty['=']] + "'")
                                }
                            }
                        }
                    }
                    if (aWhere.length > 0 && !oRequest.errors) {
                        let sQuery = `select * from ${sTargetEntity}`
                        let oQuery = cds.parse.cql(sQuery)
                        oQuery.SELECT.where = aWhere
                        try {
                            let aValues = await cds.run(oQuery)
                            if (aValues.length === 0) oRequest.error(400, 'notValidValue', `/${oRequest.target.name.split('.')[1]}(guid'${oRequest.data.ID}')/${sField}`, [oRequest.data[sField], sField])
                        } catch (oError) {
                            if (oError.code === 339) {
                                oRequest.error(400, 'notValidValue', `/${oRequest.target.name.split('.')[1]}(guid'${oRequest.data.ID}')/${sField}`, [oRequest.data[sField], sField])
                            } else if (oError.code === 259) {
                                // this is not an error, external facade property                            
                            } else {
                                oRequest.error(400, oError.message)
                            }
                        }
                    }
                }
            } else {
                // Checks must be done against external services or 
                try {
                    switch (sAssociation) {
                        case 'project.ExternalUsers':
                        case 'project.InternalUsers':
                        case 'project.Customers':
                            break
                        default:
                            let oValueEntry = await SELECT.one.from(sAssociation).where`userId = ${oRequest.data[sField]}`
                            if (!oValueEntry) oRequest.error(400, 'notValidValue', `/${oRequest.target.name.split('.')[1]}(guid'${oRequest.data.ID}')/${sField}`, [oRequest.data[sField], sField])
                            break
                    }
                } catch (oError) {
                    oRequest.error(400, oError.message)
                }
            }
        }
    }

    beforeUpdateDocumentsPerBlocksDefaultValid = async (oRequest) => {
        if (oRequest.params && oRequest.params.length > 0) {

            await checkDocumentResponsible(oRequest)
            let aRequestDocumentsDefaultValidators = await SELECT.one.from`REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID`.where`REGISTER_ID = ${oRequest.data.ID}`

            let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${aRequestDocumentsDefaultValidators.REQUEST_ID}`
            let oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${aRequestDocumentsDefaultValidators.REQUEST_ID}`

            if (oRequest.data && 'cellnexResponsible' in oRequest.data) {
                oRequest.data.responsibleDefault = oRequest.data.cellnexResponsible
            }
            if (oRequest.data && 'subcontractorResponsible' in oRequest.data) {
                oRequest.data.responsibleDefault = oRequest.data.subcontractorResponsible
            }
            if (oRequest.data && 'agencyResponsible' in oRequest.data) {
                oRequest.data.responsibleDefault = oRequest.data.agencyResponsible
            }
            if (oRequest.data && 'customerResponsible' in oRequest.data) {
                oRequest.data.responsibleDefault = oRequest.data.customerResponsible
            }

            if (oRequest.data && 'responsibleId' in oRequest.data) {
                if (oRequest.data.responsibleId === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                    oRequest.data.subcontractorId = null
                    oRequest.data.subcoTypeFC = DisplayTypesFC.HIDDEN
                    oRequest.data.responsibleDefault = oRequestHead.manager
                } else if (oRequest.data.responsibleId === parseInt(AssignedResponsibleTypes.EXTERNAL, 10)) {
                    oRequest.data.subcontractorId = SubcoTypes.VENDOR
                    oRequest.data.responsibleDefault = oRequestProvision.preferredProvider
                    oRequest.data.subcoTypeFC = DisplayTypesFC.MANDATORY
                }
            }
            if (oRequest.data && 'subcontractorId' in oRequest.data && oRequest.data.subcontractorId === SubcoTypes.VENDOR) {
                oRequest.data.responsibleDefault = oRequestProvision.preferredProvider
            }
            if (oRequest.data && 'subcontractorId' in oRequest.data && oRequest.data.subcontractorId === SubcoTypes.CUSTOMER) {
                oRequest.data.responsibleDefault = oRequestHead.customer

            }
            if (oRequest.data && 'cellnexValidationVF' in oRequest.data) {
                oRequest.data.cellnexValidation = oRequest.data.cellnexValidationVF ? "true" : "false"

            }
            if (oRequest.data && 'subcontractorValidationVF' in oRequest.data) {
                oRequest.data.subcontractorValidation = oRequest.data.subcontractorValidationVF ? "true" : "false"

            }
            if (oRequest.data && 'customerValidationVF' in oRequest.data) {
                oRequest.data.customerValidation = oRequest.data.customerValidationVF ? "true" : "false"

            }
            if (oRequest.data && 'siteOwnerValidationVF' in oRequest.data) {
                oRequest.data.siteOwnerValidation = oRequest.data.siteOwnerValidationVF ? "true" : "false"

            }
        } else {
            oRequest.error(400, 'missingBlockId')
        }
    }

    /**
     * Validates request parameters for cancellation
     */
    #validateCancellationRequest(oRequest) {
        return oRequest.params.constructor === Array &&
            oRequest.params.length > 0 &&
            'cancellationReason' in oRequest.data;
    }

    /**
     * Fetches all related entities for document cancellation
     */
    async #fetchRelatedEntitiesForCancellation(instancesPerDocument) {
        const documentsPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`
            .where`REGISTER_ID = ${instancesPerDocument.INSTANCE_ID}`;

        const work = documentsPerBlock.WORK_ID
            ? await SELECT.one.from`WORKS`.where`ID = ${documentsPerBlock.WORK_ID}`
            : null;

        const block = await SELECT.one.from`BLOCK_HEAD`
            .where`BLOCK_ID = ${documentsPerBlock.BLOCK_ID}`;

        const phase = await SELECT.one.from`PHASE_HEAD`
            .where`PHASE_ID = ${block.PHASE_ID}`;

        const requestHead = await SELECT.one.from`REQUEST_HEAD`
            .where`REQUEST_ID = ${phase.REQUEST_ID}`;

        return {
            documentsPerBlock,
            work,
            block,
            phase,
            requestHead
        };
    }

    /**
     * Creates a new version of the document after cancellation
     */
    async #createNewDocumentVersion(params) {
        const { oRequest, entities, instancesPerDocument } = params;
        const newVersion = (parseInt(instancesPerDocument.VERSION, 10) + 1).toString();

        const documentsPerBlock = [];
        const instancesPerDocumentNew = [];

        await addDocumentPerBlock(
            oRequest,
            entities.block,
            entities.work,
            null,
            documentsPerBlock,
            instancesPerDocumentNew,
            entities.documentsPerBlock.GENERIC_TYPE_ID,
            entities.documentsPerBlock.ORDER,
            newVersion,
            entities.documentsPerBlock,
            instancesPerDocument,
            entities.requestHead,
            false
        );

        await INSERT.into('DOCUMENTS_PER_BLOCK').entries(documentsPerBlock);
        await INSERT.into('INSTANCES_PER_DOCUMENT').entries(instancesPerDocumentNew);

        return { workId: entities.work ? entities.work.ID : null };
    }

    /**
     * Handles the document cancellation workflow
     */
    async #handleDocumentCancellationWorkflow(oRequest) {
        const instancesPerDocument = await SELECT.one.from`INSTANCES_PER_DOCUMENT`
            .where`REGISTER_ID = ${oRequest.params[0]}`;

        await checkCancelFieldIPD(oRequest, instancesPerDocument)
        if (oRequest.errors) return

        const entities = await this.#fetchRelatedEntitiesForCancellation(instancesPerDocument);

        if (!entities.requestHead) {
            throw new Error('phaseNotFound');
        }

        // Update flow tables to mark as cancelled
        await udpateFlowTables(
            oRequest,
            entities.documentsPerBlock.REGISTER_ID,
            DocumentStatus.CANCELLED,
            null,
            true,
            oRequest.data.cancellationReason,
            null,
            null
        );

        // Create new document version
        const newDocResult = await this.#createNewDocumentVersion({
            oRequest,
            entities,
            instancesPerDocument
        });

        // Log the rejection event
        await logDocumentEvent(oRequest, Actions.DOCUMENT_REJECTED, {
            registerId: instancesPerDocument.INSTANCE_ID,
            data: { WORK_ID: newDocResult.workId }
        });
    }

    /**
 * Validates and prepares the request data
 * @param {Object} oResult - The result array
 * @param {Object} oRequest - The request object
 * @returns {Promise<Object>} Prepared data with entities and hidden documents
 */
    async #prepareRequestData(oResult, oRequest) {
        await UserCode.currentUserDetails(oRequest);

        const aResults = oResult.constructor === Array ? oResult : [oResult];
        let oEntities = null;
        let aHiddenDocuments = [];

        if (aResults.length > 0 && aResults[0] && aResults[0].blockId) {
            aResults.sort((a, b) => a.order - b.order);
            oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${aResults[0].blockId})`;
            if (oEntities) aHiddenDocuments = await getHiddenDocumentTypes(oRequest, oEntities.PROCESS_ID);
        }

        return {
            aResults,
            oEntities,
            aHiddenDocuments
        };
    }

    /**
     * Determines the parent type and fetches parent head data
     * @param {Object} oResult - The document result
     * @returns {Promise<Object>} Parent type and parent head data
     */
    async #determineParentTypeAndHead(oResult) {
        let oParentHead;
        let sParentType;

        if (oResult.workId) {
            sParentType = ParentTypes.WORK;
            oParentHead = await SELECT.one.from`project.Works`.where`ID = ${oResult.workId}`;
        } else {
            sParentType = ParentTypes.BLOCK;
            oParentHead = await SELECT.one.from`project.Blocks`.where`ID = ${oResult.blockId}`;
        }

        return { sParentType, oParentHead };
    }

    /**
     * Checks if user has authorization for document operations
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oEntities - Entities data
     * @param {Object} oResult - Document result
     * @returns {boolean} True if user has authorization
     */
    #checkUserAuthorization(oRequest, oBlockResponsible, oEntities, oResult) {
        return oRequest.user.is(Roles.MANAGER_USER_ROL) ||
            (oRequest.user.id === oBlockResponsible.ID && oBlockResponsible.isInternal && oRequest.user.is(Roles.CELLNEX_USER_ROL)) ||
            (oRequest.user.is(oEntities.ROLE_ID)) ||
            (oResult.responsibleId === AssignedResponsibleTypes.CELLNEX && oRequest.user.id === oResult.responsibleDefault);
    }

    /**
     * Checks if external user is authorized for document operations
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oResult - Document result
     * @returns {boolean} True if external user is authorized
     */
    #checkExternalUserAuthorization(oRequest, oBlockResponsible) {
        const { agoraCurrentUserData } = oRequest;

        return (!oBlockResponsible.isInternal &&
            oBlockResponsible.ID === agoraCurrentUserData?.vendor &&
            agoraCurrentUserData?.vendor !== null &&
            agoraCurrentUserData?.vendor !== '') ||
            (!oBlockResponsible.isInternal &&
                oBlockResponsible.ID === agoraCurrentUserData?.agency &&
                agoraCurrentUserData?.agency !== null &&
                agoraCurrentUserData?.agency !== '');
    }

    /**
     * Processes validator-specific logic for NOT_INI step
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oEntities - Entities data
     * @param {Object} oResult - Document result
     */
    async #processNotInitValidator(oRequest, oBlockResponsible, oEntities, oResult) {
        const bAllAuth = this.#checkUserAuthorization(oRequest, oBlockResponsible, oEntities, oResult);
        const bExternalAuth = this.#checkExternalUserAuthorization(oRequest, oBlockResponsible);

        if (bAllAuth || bExternalAuth) {
            await getDPBValidatorNotInit(oResult);
            if (oResult.status !== DocumentStatus.COMPLETED &&
                oResult.status !== DocumentStatus.CANCELLED &&
                oResult.InstancesPerDocuments !== undefined) {
                oResult.InstancesPerDocuments["buttonCompleteVF"] = true;
            }
        }
    }

    /**
     * Processes validator-specific logic for RESPONSIBLE step
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oEntities - Entities data
     * @param {Object} oResult - Document result
     */
    #processResponsibleValidator(oRequest, oBlockResponsible, oEntities, oResult) {
        const bAllAuth = this.#checkUserAuthorization(oRequest, oBlockResponsible, oEntities, oResult);
        const { agoraCurrentUserData } = oRequest;

        const bExternalDocumentAuth = (oResult.responsibleId === AssignedResponsibleTypes.EXTERNAL &&
            agoraCurrentUserData.vendor === oResult.responsibleDefault &&
            agoraCurrentUserData.vendor !== null &&
            agoraCurrentUserData.vendor !== '') ||
            (oResult.responsibleId === AssignedResponsibleTypes.EXTERNAL &&
                agoraCurrentUserData.agency === oResult.responsibleDefault &&
                agoraCurrentUserData.agency !== null &&
                agoraCurrentUserData.agency !== '');

        if (bAllAuth || bExternalDocumentAuth) {
            getDPBValidatorResponsible(oResult);
            oResult.canSee = true
            oResult.canDownload = true
            if (oResult.status !== DocumentStatus.COMPLETED &&
                oResult.status !== DocumentStatus.CANCELLED &&
                oResult.InstancesPerDocuments !== undefined) {
                oResult.InstancesPerDocuments["buttonCompleteVF"] = true;
            }
        }
    }

    /**
     * Processes validator-specific logic for CELLNEX step
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oEntities - Entities data
     * @param {Object} oResult - Document result
     */
    #processCellnexValidator(oRequest, oBlockResponsible, oEntities, oResult) {
        const bAllAuth = this.#checkUserAuthorization(oRequest, oBlockResponsible, oEntities, oResult);

        if (bAllAuth) {
            getDPBValidatorCellnex(oResult);
            if (oResult.status !== DocumentStatus.COMPLETED &&
                oResult.status !== DocumentStatus.CANCELLED &&
                oResult.InstancesPerDocuments !== undefined) {
                oResult.InstancesPerDocuments["buttonCompleteVF"] = true;
            }
        }
    }

    /**
     * Processes validator-specific logic for SUBCO step
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oEntities - Entities data
     * @param {Object} oResult - Document result
     */
    #processSubcoValidator(oRequest, oBlockResponsible, oEntities, oResult) {
        const bAllAuth = this.#checkUserAuthorization(oRequest, oBlockResponsible, oEntities, oResult);
        const { agoraCurrentUserData } = oRequest;

        const bExternalInstanceAuth = ((oResult.InstancesPerDocuments.subcontractorValidator === agoraCurrentUserData?.vendor &&
            agoraCurrentUserData?.vendor !== null &&
            agoraCurrentUserData?.vendor !== '') ||
            (oResult.InstancesPerDocuments.subcontractorValidator === agoraCurrentUserData?.agency &&
                agoraCurrentUserData?.agency !== null &&
                agoraCurrentUserData?.agency !== ''));

        if (bAllAuth || bExternalInstanceAuth) {
            getDPBValidatorSubcontractor(oResult);
            oResult.canSee = true;
            if (oResult.status !== DocumentStatus.COMPLETED &&
                oResult.status !== DocumentStatus.CANCELLED &&
                oResult.InstancesPerDocuments !== undefined) {
                oResult.InstancesPerDocuments["buttonCompleteVF"] = true;
            }
        }
    }

    /**
     * Processes validator-specific logic for CUSTOMER step
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oEntities - Entities data
     * @param {Object} oResult - Document result
     */
    #processCustomerValidator(oRequest, oBlockResponsible, oEntities, oResult) {
        const bAllAuth = this.#checkUserAuthorization(oRequest, oBlockResponsible, oEntities, oResult);
        const { agoraCurrentUserData } = oRequest;

        const bExternalCustomerAuth = (oResult.InstancesPerDocuments.customerValidator === agoraCurrentUserData?.customer &&
            agoraCurrentUserData?.customer !== null &&
            agoraCurrentUserData?.customer !== '');

        if (bAllAuth || bExternalCustomerAuth) {
            getDPBValidatorCustomer(oResult);
            oResult.canSee = true;
            if (oResult.status !== DocumentStatus.COMPLETED &&
                oResult.status !== DocumentStatus.CANCELLED &&
                oResult.InstancesPerDocuments !== undefined) {
                oResult.InstancesPerDocuments["buttonCompleteVF"] = true;
            }
        }
    }

    /**
     * Processes validator-specific logic for SITE_OWNER step
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oEntities - Entities data
     * @param {Object} oResult - Document result
     */
    #processSiteOwnerValidator(oRequest, oBlockResponsible, oEntities, oResult) {
        const bAllAuth = this.#checkUserAuthorization(oRequest, oBlockResponsible, oEntities, oResult);

        if (bAllAuth) {
            getDPBValidatorSiteOwner(oResult);
        }
    }

    /**
     * Processes validator logic based on step ID
     * @param {Object} oRequest - The request object
     * @param {Object} oBlockResponsible - Block responsible data
     * @param {Object} oEntities - Entities data
     * @param {Object} oResult - Document result
     */
    async #processValidatorLogic(oRequest, oBlockResponsible, oEntities, oResult) {
        const stepId = oResult.InstancesPerDocuments.stepId;

        switch (stepId) {
            case Validators.NOT_INI:
                await this.#processNotInitValidator(oRequest, oBlockResponsible, oEntities, oResult);
                break;
            case Validators.RESPONSIBLE:
                this.#processResponsibleValidator(oRequest, oBlockResponsible, oEntities, oResult);
                break;
            case Validators.CELLNEX:
                this.#processCellnexValidator(oRequest, oBlockResponsible, oEntities, oResult);
                break;
            case Validators.SUBCO:
                this.#processSubcoValidator(oRequest, oBlockResponsible, oEntities, oResult);
                break;
            case Validators.CUSTOMER:
                this.#processCustomerValidator(oRequest, oBlockResponsible, oEntities, oResult);
                break;
            case Validators.SITE_OWNER:
                this.#processSiteOwnerValidator(oRequest, oBlockResponsible, oEntities, oResult);
                break;
        }
    }

    /**
     * Sets up responsible virtual fields based on responsible type
     * @param {Object} oResult - Document result
     * @param {Object} oEntities - Entities data
     * @param {Object} oRequest - Request object
     */
    async #setupResponsibleVirtualFields(oResult, oEntities, oRequest) {
        if (oResult.responsibleId === AssignedResponsibleTypes.CELLNEX) {
            await this.#setupCellnexResponsibleFields(oResult);
        } else {
            await this.#setupExternalResponsibleFields(oResult, oEntities, oRequest);
        }
    }

    /**
     * Sets up Cellnex responsible fields
     * @param {Object} oResult - Document result
     */
    async #setupCellnexResponsibleFields(oResult) {
        let oUser = null;
        if (oResult.responsibleDefault && oResult.responsibleDefault !== '') {
            oUser = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oResult.responsibleDefault}`;
        }

        oResult.cellnexResponsible = oResult.responsibleDefault;
        oResult.cellnexResponsibleName = oUser ? oUser.USER_NAME : '';
    }

    /**
     * Sets up external responsible fields based on subcontractor type
     * @param {Object} oResult - Document result
     * @param {Object} oEntities - Entities data
     * @param {Object} oRequest - Request object
     */
    async #setupExternalResponsibleFields(oResult, oEntities, oRequest) {
        const subcontractorId = parseInt(oResult.subcontractorId, 10);

        switch (subcontractorId) {
            case SubcoTypes.CUSTOMER:
                await this.#setupCustomerResponsibleFields(oResult, oEntities);
                break;
            case SubcoTypes.VENDOR:
                await this.#setupVendorResponsibleFields(oResult, oRequest);
                break;
            case SubcoTypes.AGENCY:
                await this.#setupAgencyResponsibleFields(oResult, oRequest);
                break;
        }
    }

    /**
     * Sets up customer responsible fields
     * @param {Object} oResult - Document result
     * @param {Object} oEntities - Entities data
     */
    async #setupCustomerResponsibleFields(oResult, oEntities) {
        const oPhaseHead = await SELECT.one.from`PHASE_HEAD`.where`PHASE_ID = ${oEntities.PHASE_ID}`;
        let oRequestHead = null;

        if (oPhaseHead) {
            oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhaseHead.REQUEST_ID}`;
        }

        oResult.customerResponsible = oResult.responsibleDefault;
        oResult.customerResponsibleName = oRequestHead ? oRequestHead.CUSTOMER_NAME : '';
    }

    /**
     * Sets up vendor responsible fields
     * @param {Object} oResult - Document result
     * @param {Object} oRequest - Request object
     */
    async #setupVendorResponsibleFields(oResult, oRequest) {
        let oVendor = null;
        if (oResult.responsibleDefault && oResult.responsibleDefault !== '') {
            oVendor = await SELECT.one.from`project.CacheR3Entities`
                .where`userId = ${oRequest.user.id} and code = ${oResult.responsibleDefault} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
        }
        oResult.subcontractorResponsible = oResult.responsibleDefault;
        oResult.subcontractorResponsibleName = oVendor ? oVendor.name : '';
    }

    /**
     * Sets up agency responsible fields
     * @param {Object} oResult - Document result
     * @param {Object} oRequest - Request object
     */
    async #setupAgencyResponsibleFields(oResult, oRequest) {
        let oAgency = null;
        if (oResult.responsibleDefault && oResult.responsibleDefault !== '') {
            oAgency = await SELECT.one.from`project.CacheR3Entities`
                .where`userId = ${oRequest.user.id} and code = ${oResult.responsibleDefault} and entityType = 'F4_GEWRK_AGEN'`;
        }
        oResult.agencyResponsible = oResult.responsibleDefault;
        oResult.agencyResponsibleName = oAgency ? oAgency.name : '';
    }

    /**
     * Processes a single document result
     * @param {Object} oResult - Document result
     * @param {Object} oRequest - Request object
     * @param {Object} oEntities - Entities data
     * @param {Array} aHiddenDocuments - Hidden documents array
     * @returns {Promise<Object>} Processed document result or null if hidden
     */
    async #processDocumentResult(oResult, oRequest, oEntities, aHiddenDocuments) {
        // Skip hidden documents
        if (aHiddenDocuments.some((objeto) => objeto.documentId === oResult.documentId)) {
            return null;
        }

        // Determine parent type and get parent head
        const { sParentType, oParentHead } = await this.#determineParentTypeAndHead(oResult);

        // Get block responsible and authorization 
        const oBlockResponsible = await getResponsible(oRequest, sParentType, oParentHead);

        // Get instances per document
        oResult.InstancesPerDocuments = await SELECT.one.from`project.InstancesPerDocuments`
            .where`instanceId = ${oResult.ID}`;
        if (oResult.InstancesPerDocuments && 'ID' in oResult.InstancesPerDocuments && oResult.InstancesPerDocuments.ID !== undefined) {
            oResult.InstancesPerDocuments.Documents = await SELECT.from`project.Documents`.where`instanceId = ${oResult.InstancesPerDocuments.ID}`
        }
        // Apply transformations and get status info
        DPBBooleanToText(oResult);
        await getDocumentStatusInfo(oResult, oRequest);
        await getStatusSteps(oResult, oRequest);
        await getDPBDefaultValues(oResult, oRequest);

        // Check authorization and control actions visibility
        const bAllAuth = this.#checkUserAuthorization(oRequest, oBlockResponsible, oEntities, oResult);
        controlDPBActionsVisibility(oRequest, bAllAuth, oResult, oBlockResponsible);

        // Process validator-specific logic
        await this.#processValidatorLogic(oRequest, oBlockResponsible, oEntities, oResult);

        // Get editability fields
        getDPBEditabilityFields(oResult);

        // Check editability by status
        this.#applyStatusBasedEditability(oResult, oParentHead);

        // Setup responsible virtual fields
        await this.#setupResponsibleVirtualFields(oResult, oEntities, oRequest);

        return oResult;
    }

    /**
     * Applies status-based editability rules
     * @param {Object} oResult - Document result
     * @param {Object} oParentHead - Parent head data
     */
    #applyStatusBasedEditability(oResult, oParentHead) {
        // Check editability by status
        if (oParentHead.status !== BlockStatus.BLOCK_INPROGRESS || (oParentHead.activated && oParentHead.activated !== true)) {
            getDPBNotEditable(oResult);
            oResult.canInit = false;
            oResult.canDelete = false;
            if (oResult.InstancesPerDocuments !== undefined) {
                oResult.InstancesPerDocuments["buttonCompleteVF"] = false;
            }
        }

        if (oResult.deleted === true || oResult.status === DocumentStatus.COMPLETED) {
            getDPBDeleted(oResult);
            oResult.canInit = false;
            if (oResult.deleted === true) oResult.canDelete = false;
            if (oResult.InstancesPerDocuments !== undefined) {
                oResult.InstancesPerDocuments["buttonCompleteVF"] = false;
            }
        }
    }

    /**
     * Sorts results by status priority
     * @param {Array} aResponse - Response array
     * @returns {Array} Sorted response array
     */
    #sortResultsByStatus(aResponse) {
        const orderArrayStatus = [2, 7, 3, 4];
        return this.sortByList(orderArrayStatus, aResponse);
    }

}

module.exports = {
    DPBCode
}