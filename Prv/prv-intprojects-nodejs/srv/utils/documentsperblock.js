const {
    DocumentStatus,
    Validators,
    DocumentIcons,
    DocumentMessageType,
    DocumentStatusTextCode,
    DocumentValidationValues,
    AssignedResponsibleTypes,
    SubcoTypes,
    DisplayTypesFC,
    Roles,
    ParentTypes,
    Actions
} = require('./enumerations')
const { getResponsible } = require('./blocks')
const { saveLog, logDocumentEvent } = require('./AuditLogger')

const getHiddenDocumentTypes = async (oRequest, sProcessId) => {
    let aHiddenTypes = []
    if (sProcessId) {
        let aRoles = oRequest.agoraCurrentUserData.roles.map(item => item.IAS_GROUP).filter(group => group !== undefined)
        let oConfig = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`processId = ${sProcessId}`
        if (oConfig && aRoles && aRoles.length > 0) aHiddenTypes = await SELECT.from`DOCUMENT_FLOWS_HIDDEN_PER_ROLE`.where`DocumentFlowsPerConfig_ID = ${oConfig.Configuration_ID} and active = true and IASGroup in ${aRoles}`
    }
    return aHiddenTypes
}

const getDefaultParamForBlockDocument = async (oRequest, sBlockId, sDocumentId) => {
    try {
        let oParent = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${sBlockId})`
        let oDocumentFlowPerProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`PROCESSID = ${oParent.PROCESS_ID}`
        let oDocumentFlowPerConfig = await SELECT.one.from`DOCUMENT_FLOWS_PER_CONFIG`.where`ID = ${oDocumentFlowPerProcess.Configuration_ID}`
        return await SELECT.one.from`DOCUMENT_FLOW_VALIDATORS`.where`DocumentFlowsPerConfig_ID = ${oDocumentFlowPerConfig.ID} and documentId = ${sDocumentId}`;

    } catch (oError) {
        oRequest.error(400, oError.message);
    }
}

const getDefaultParamForWorkDocument = async (oRequest, sId, sDocumentId) => {
    try {
        let oParent = await SELECT.one.from`WORKS_BLOCK_PHASE_REQUEST(p_workId: ${sId})`
        return await SELECT.one.from`WORK_DOCUMENTS_VH`
            .where`countryId = ${oParent.COUNTRY_ID} and documentId = ${sDocumentId} and objective = ${oParent.PROJECT_OBJECTIVE} and processFlowId = ${oParent.PROCESS_ID} and phaseTypeId = ${oParent.MASTER_PHASE_ID} and blockTypeId = ${oParent.MASTER_BLOCK_ID} and workType = ${oParent.TYPE}`
    } catch (oError) {
        oRequest.error(400, oError.message);
    }
}

const getStatusSteps = async (oDocumentsPerBlock, oRequest) => {
    if (oDocumentsPerBlock.InstancesPerDocuments.stepId === Validators.NOT_INI) {
        await setDocumentValidatorsStatusInfo(oRequest, 'responsible', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'cellnex', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'subcontractor', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'customer', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'siteOwner', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
    } else if (oDocumentsPerBlock.InstancesPerDocuments.stepId === Validators.RESPONSIBLE) {
        await setDocumentValidatorsStatusInfo(oRequest, 'responsible', oDocumentsPerBlock, DocumentIcons.InProgress, DocumentMessageType.Warning, DocumentStatusTextCode.InProgress)
        await setDocumentValidatorsStatusInfo(oRequest, 'cellnex', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'subcontractor', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'customer', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'siteOwner', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
    } else if (oDocumentsPerBlock.InstancesPerDocuments.stepId === Validators.CELLNEX) {
        await setDocumentValidatorsStatusInfo(oRequest, 'responsible', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        if (oDocumentsPerBlock.status === DocumentStatus.CANCELLED) {
            await setDocumentValidatorsStatusInfo(oRequest, 'cellnex', oDocumentsPerBlock, DocumentIcons.Cancelled, DocumentMessageType.Error, DocumentStatusTextCode.Cancelled)
        } else {
            await setDocumentValidatorsStatusInfo(oRequest, 'cellnex', oDocumentsPerBlock, DocumentIcons.InProgress, DocumentMessageType.Warning, DocumentStatusTextCode.InProgress)
        }
        await setDocumentValidatorsStatusInfo(oRequest, 'subcontractor', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'customer', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'siteOwner', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
    } else if (oDocumentsPerBlock.InstancesPerDocuments.stepId === Validators.SUBCO) {
        await setDocumentValidatorsStatusInfo(oRequest, 'responsible', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'cellnex', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        if (oDocumentsPerBlock.status === DocumentStatus.CANCELLED) {
            await setDocumentValidatorsStatusInfo(oRequest, 'subcontractor', oDocumentsPerBlock, DocumentIcons.Cancelled, DocumentMessageType.Error, DocumentStatusTextCode.Cancelled)
        } else {
            await setDocumentValidatorsStatusInfo(oRequest, 'subcontractor', oDocumentsPerBlock, DocumentIcons.InProgress, DocumentMessageType.Warning, DocumentStatusTextCode.InProgress)
        }
        await setDocumentValidatorsStatusInfo(oRequest, 'customer', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
        await setDocumentValidatorsStatusInfo(oRequest, 'siteOwner', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
    } else if (oDocumentsPerBlock.InstancesPerDocuments.stepId === Validators.CUSTOMER) {
        await setDocumentValidatorsStatusInfo(oRequest, 'responsible', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'cellnex', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'subcontractor', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        if (oDocumentsPerBlock.status === DocumentStatus.CANCELLED) {
            await setDocumentValidatorsStatusInfo(oRequest, 'customer', oDocumentsPerBlock, DocumentIcons.Cancelled, DocumentMessageType.Error, DocumentStatusTextCode.Cancelled)
        } else {
            await setDocumentValidatorsStatusInfo(oRequest, 'customer', oDocumentsPerBlock, DocumentIcons.InProgress, DocumentMessageType.Warning, DocumentStatusTextCode.InProgress)
        }
        await setDocumentValidatorsStatusInfo(oRequest, 'siteOwner', oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
    } else if (oDocumentsPerBlock.InstancesPerDocuments.stepId === Validators.SITE_OWNER) {
        await setDocumentValidatorsStatusInfo(oRequest, 'responsible', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'cellnex', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'subcontractor', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'customer', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        if (oDocumentsPerBlock.status === DocumentStatus.CANCELLED) {
            await setDocumentValidatorsStatusInfo(oRequest, 'siteOwner', oDocumentsPerBlock, DocumentIcons.Cancelled, DocumentMessageType.Error, DocumentStatusTextCode.Cancelled)
        } else {
            await setDocumentValidatorsStatusInfo(oRequest, 'siteOwner', oDocumentsPerBlock, DocumentIcons.InProgress, DocumentMessageType.Warning, DocumentStatusTextCode.InProgress)
        }
    } else if (oDocumentsPerBlock.InstancesPerDocuments.stepId === Validators.COMPLETED) {
        await setDocumentValidatorsStatusInfo(oRequest, 'responsible', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'cellnex', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'subcontractor', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'customer', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
        await setDocumentValidatorsStatusInfo(oRequest, 'siteOwner', oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
    }
}

const getDocumentStatusInfo = async (oDocumentsPerBlock, oRequest) => {
    switch (oDocumentsPerBlock.status) {
        case DocumentStatus.IN_PROGRESS:
            await setDocumentStatusInfo(oRequest, oDocumentsPerBlock, DocumentIcons.InProgress, DocumentMessageType.Warning, DocumentStatusTextCode.InProgress)
            break
        case DocumentStatus.CANCELLED:
            // maybe has to do status rejected? case 40: 
            await setDocumentStatusInfo(oRequest, oDocumentsPerBlock, DocumentIcons.Cancelled, DocumentMessageType.Error, DocumentStatusTextCode.Cancelled)
            break
        case DocumentStatus.COMPLETED:
            await setDocumentStatusInfo(oRequest, oDocumentsPerBlock, DocumentIcons.Complete, DocumentMessageType.Success, DocumentStatusTextCode.Complete)
            break
        default:
            await setDocumentStatusInfo(oRequest, oDocumentsPerBlock, DocumentIcons.NotInit, DocumentMessageType.None, DocumentStatusTextCode.NotInit)
            break
    }
}

const getDPBDefaultValues = async (oDocumentsPerBlock, oRequest) => {
    oDocumentsPerBlock.stepIdVF = oDocumentsPerBlock.InstancesPerDocuments.stepId
    oDocumentsPerBlock.approverTypeFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.cellnexValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.subcontractorValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.customerValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.responsibleDefaultFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.HIDDEN

    oDocumentsPerBlock.InstancesPerDocuments.blockId = oDocumentsPerBlock.blockId
    oDocumentsPerBlock.InstancesPerDocuments.blockIdVF = oDocumentsPerBlock.blockId
    if (oDocumentsPerBlock.InstancesPerDocuments !== undefined) oDocumentsPerBlock.InstancesPerDocuments["buttonCompleteVF"] = false

    oDocumentsPerBlock.InstancesPerDocuments.contactEmailFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.endDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.startDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.submissionDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.expectedSubmissionDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.expirationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerInformDateFC = DisplayTypesFC.READONLY

    if (oDocumentsPerBlock.responsibleId) {
        let oApproverType = await SELECT.one.from`APPROVER_TYPES`.where`code = ${oDocumentsPerBlock.responsibleId}`;
        if (oApproverType) {
            oDocumentsPerBlock.approverTypeName = oApproverType.name;
            oDocumentsPerBlock.InstancesPerDocuments["approverTypeName"] = oApproverType.name
        }
    }
    if (oDocumentsPerBlock.subcontractorId) {
        let oSubcoType = await SELECT.one.from`SUBCO_TYPES`.where`code = ${oDocumentsPerBlock.subcontractorId}`;
        if (oSubcoType) {
            oDocumentsPerBlock.subcoTypeName = oSubcoType.name;
            oDocumentsPerBlock.InstancesPerDocuments["subcoTypeName"] = oSubcoType.name
        }
    }
    if (oDocumentsPerBlock.documentId) {
        let oDocument = await SELECT.one.from`DOCUMENT_FLOWS`.where`documentId = ${oDocumentsPerBlock.documentId}`
        if (oDocument) {
            oDocumentsPerBlock.documentNameVF = oDocument.documentName
            oDocumentsPerBlock.InstancesPerDocuments["documentNameVF"] = oDocument.documentName
        }
    }
    if (oDocumentsPerBlock.InstancesPerDocuments.cellnexValidator) {
        let oCellnexValidator = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oDocumentsPerBlock.InstancesPerDocuments.cellnexValidator}`
        if (oCellnexValidator) oDocumentsPerBlock.InstancesPerDocuments.cellnexValidatorName = oCellnexValidator.USER_NAME
    }

    if (oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidator) {
        let oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oRequest.data.preferredProvider} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
        if (oVendor) oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorName = oVendor.name;
    }

    if (oDocumentsPerBlock.InstancesPerDocuments.customerValidator) {
        let oCustomerValidator = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oDocumentsPerBlock.InstancesPerDocuments.customerValidator}`
        if (oCustomerValidator) oDocumentsPerBlock.InstancesPerDocuments.customerValidatorName = oCustomerValidator.USER_NAME
    }

    if (oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidator) {
        let oSiteOwnerValidator = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidator}`
        if (oSiteOwnerValidator) oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidatorName = oSiteOwnerValidator.USER_NAME
    }
}

const getDPBValidatorNotInit = async (oDocumentsPerBlock) => {
    oDocumentsPerBlock.approverTypeFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.responsibleDefaultFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.cellnexValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.subcontractorValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.customerValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationDateFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidatorFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationDateFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationDateFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationDateFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidatorFC = DisplayTypesFC.HIDDEN
    if (oDocumentsPerBlock.responsibleId && oDocumentsPerBlock.responsibleId !== null && oDocumentsPerBlock.responsibleId !== '') {
        if (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.CELLNEX) {
            oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.OPTIONAL
            oDocumentsPerBlock.subcontractorValidationFC = DisplayTypesFC.OPTIONAL
            oDocumentsPerBlock.customerValidationFC = DisplayTypesFC.OPTIONAL
            if (oDocumentsPerBlock.InstancesPerDocuments) {
                oDocumentsPerBlock.InstancesPerDocuments.cellnexValidator = null
                oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationDateFC = DisplayTypesFC.OPTIONAL
                oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorFC = DisplayTypesFC.OPTIONAL
                oDocumentsPerBlock.InstancesPerDocuments.customerValidationDateFC = DisplayTypesFC.OPTIONAL
                oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.OPTIONAL
            }
        } else {
            oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.MANDATORY
            if (oDocumentsPerBlock.subcontractorId && oDocumentsPerBlock.subcontractorId !== null && oDocumentsPerBlock.subcontractorId !== '') {
                oDocumentsPerBlock.cellnexValidationFC = DisplayTypesFC.OPTIONAL
                oDocumentsPerBlock.customerValidationFC = DisplayTypesFC.OPTIONAL
                if (oDocumentsPerBlock.InstancesPerDocuments) oDocumentsPerBlock.InstancesPerDocuments.cellnexValidatorFC = DisplayTypesFC.OPTIONAL
                if (oDocumentsPerBlock.InstancesPerDocuments) oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.OPTIONAL
                let oSubcoType = await SELECT.one.from`SUBCO_TYPES`.where`code = ${oDocumentsPerBlock.subcontractorId}`
                if (oSubcoType) oDocumentsPerBlock.subcoTypeName = oSubcoType.name
                switch (parseInt(oDocumentsPerBlock.subcontractorId, 10)) {
                    case SubcoTypes.VENDOR:
                        oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.OPTIONAL
                        if (oDocumentsPerBlock.InstancesPerDocuments) oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidator = null
                        break
                    case SubcoTypes.AGENCY:
                        oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.OPTIONAL
                        if (oDocumentsPerBlock.InstancesPerDocuments) oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidator = null
                        break
                    case SubcoTypes.CUSTOMER:
                        oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.READONLY
                        oDocumentsPerBlock.subcontractorValidationFC = DisplayTypesFC.OPTIONAL
                        oDocumentsPerBlock.customerValidationFC = DisplayTypesFC.HIDDEN
                        if (oDocumentsPerBlock.InstancesPerDocuments) {
                            oDocumentsPerBlock.InstancesPerDocuments.customerValidator = null
                            oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.HIDDEN
                            oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorFC = DisplayTypesFC.OPTIONAL
                        }
                        break
                }
            }
        }
    }
}

const getDPBValidatorResponsible = (oDocumentsPerBlock) => {
    oDocumentsPerBlock.InstancesPerDocuments.contactPhoneFC = DisplayTypesFC.OPTIONAL
    oDocumentsPerBlock.InstancesPerDocuments.contactEmailFC = DisplayTypesFC.OPTIONAL
    oDocumentsPerBlock.InstancesPerDocuments.endDateFC = DisplayTypesFC.OPTIONAL
    oDocumentsPerBlock.InstancesPerDocuments.startDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.expectedSubmissionDateFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.submissionDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.expirationDateFC = DisplayTypesFC.OPTIONAL
    oDocumentsPerBlock.InstancesPerDocuments.documentIdVF = oDocumentsPerBlock.documentId
    if (oDocumentsPerBlock.responsibleId && oDocumentsPerBlock.responsibleId !== null && oDocumentsPerBlock.responsibleId !== '') {
        if (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.CELLNEX) {
            oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.READONLY
        } else {
            oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.READONLY
            if (oDocumentsPerBlock.subcontractorId && oDocumentsPerBlock.subcontractorId !== null && oDocumentsPerBlock.subcontractorId !== '') {
                switch (parseInt(oDocumentsPerBlock.subcontractorId, 10)) {
                    case SubcoTypes.VENDOR:
                        oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.AGENCY:
                        oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.CUSTOMER:
                        oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.READONLY
                        break
                }
            }
        }
    }
}

const getDPBValidatorCellnex = (oDocumentsPerBlock) => {
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationCommentsFC = DisplayTypesFC.OPTIONAL
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationDateFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidatorFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.cellnexValidationFC = DisplayTypesFC.HIDDEN
    if (oDocumentsPerBlock.responsibleId && oDocumentsPerBlock.responsibleId !== null && oDocumentsPerBlock.responsibleId !== '') {
        if (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.CELLNEX) {
            oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.READONLY
        } else {
            oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.READONLY
            if (oDocumentsPerBlock.subcontractorId && oDocumentsPerBlock.subcontractorId !== null && oDocumentsPerBlock.subcontractorId !== '') {
                switch (parseInt(oDocumentsPerBlock.subcontractorId, 10)) {
                    case SubcoTypes.VENDOR:
                        oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.AGENCY:
                        oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.CUSTOMER:
                        oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.READONLY
                        break
                }
            }
        }
    }
}

const getDPBValidatorSubcontractor = (oDocumentsPerBlock) => {
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationCommentsFC = DisplayTypesFC.OPTIONAL
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationDateFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.subcontractorValidationFC = DisplayTypesFC.HIDDEN
    if (oDocumentsPerBlock.responsibleId && oDocumentsPerBlock.responsibleId !== null && oDocumentsPerBlock.responsibleId !== '') {
        if (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.CELLNEX) {
            oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.READONLY
        } else {
            oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.READONLY
            if (oDocumentsPerBlock.subcontractorId && oDocumentsPerBlock.subcontractorId !== null && oDocumentsPerBlock.subcontractorId !== '') {
                switch (parseInt(oDocumentsPerBlock.subcontractorId, 10)) {
                    case SubcoTypes.VENDOR:
                        oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.AGENCY:
                        oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.CUSTOMER:
                        oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.READONLY
                        break
                }
            }
        }
    }
}

const getDPBValidatorCustomer = (oDocumentsPerBlock) => {
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationCommentsFC = DisplayTypesFC.OPTIONAL
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationDateFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationFC = DisplayTypesFC.MANDATORY

    oDocumentsPerBlock.InstancesPerDocuments.customerInformDateFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.customerValidationFC = DisplayTypesFC.HIDDEN
    if (oDocumentsPerBlock.responsibleId && oDocumentsPerBlock.responsibleId !== null && oDocumentsPerBlock.responsibleId !== '') {
        if (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.CELLNEX) {
            oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.READONLY
        } else {
            oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.READONLY
            if (oDocumentsPerBlock.subcontractorId && oDocumentsPerBlock.subcontractorId !== null && oDocumentsPerBlock.subcontractorId !== '') {
                switch (parseInt(oDocumentsPerBlock.subcontractorId, 10)) {
                    case SubcoTypes.VENDOR:
                        oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.AGENCY:
                        oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.CUSTOMER:
                        oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.READONLY
                        break
                }
            }
        }
    }
}

const getDPBValidatorSiteOwner = (oDocumentsPerBlock) => {
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationCommentsFC = DisplayTypesFC.OPTIONAL
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationDateFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidatorFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationFC = DisplayTypesFC.MANDATORY
    oDocumentsPerBlock.siteOwnervalidationFC = DisplayTypesFC.HIDDEN
    if (oDocumentsPerBlock.responsibleId && oDocumentsPerBlock.responsibleId !== null && oDocumentsPerBlock.responsibleId !== '') {
        if (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.CELLNEX) {
            oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.READONLY
        } else {
            oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.READONLY
            if (oDocumentsPerBlock.subcontractorId && oDocumentsPerBlock.subcontractorId !== null && oDocumentsPerBlock.subcontractorId !== '') {
                switch (parseInt(oDocumentsPerBlock.subcontractorId, 10)) {
                    case SubcoTypes.VENDOR:
                        oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.AGENCY:
                        oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.READONLY
                        break
                    case SubcoTypes.CUSTOMER:
                        oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.READONLY
                        break
                }
            }
        }
    }
}

const getDPBEditabilityFields = (oDocumentsPerBlock) => {
    if (oDocumentsPerBlock.cellnexValidationVF !== true) {
        oDocumentsPerBlock.cellnexValidation = "false"
        oDocumentsPerBlock.InstancesPerDocuments["cellnexValidation"] = false
        oDocumentsPerBlock.cellnexStatusIconVF = null
        oDocumentsPerBlock.cellnexStatusStateVF = null
        oDocumentsPerBlock.cellnexStatusTextVF = null
        oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationCommentsFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationDateFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.cellnexValidatorFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationFC = DisplayTypesFC.HIDDEN
    }
    if (oDocumentsPerBlock.subcontractorValidationVF !== true) {
        oDocumentsPerBlock.subcontractorValidation = "false"
        oDocumentsPerBlock.InstancesPerDocuments["subcontractorValidation"] = false
        oDocumentsPerBlock.subcontractorStatusIconVF = null
        oDocumentsPerBlock.subcontractorStatusStateVF = null
        oDocumentsPerBlock.subcontractorStatusTextVF = null
        oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationCommentsFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationDateFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationFC = DisplayTypesFC.HIDDEN
    }
    if (oDocumentsPerBlock.customerValidationVF !== true) {
        oDocumentsPerBlock.customerValidation = "false"
        oDocumentsPerBlock.InstancesPerDocuments["customerValidationVF"] = false
        oDocumentsPerBlock.customerStatusIconVF = null
        oDocumentsPerBlock.customerStatusStateVF = null
        oDocumentsPerBlock.customerStatusTextVF = null
        oDocumentsPerBlock.InstancesPerDocuments.customerValidationCommentsFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.customerValidationDateFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.customerValidationFC = DisplayTypesFC.HIDDEN
    }
    if (oDocumentsPerBlock.siteOwnerValidationVF !== true) {
        oDocumentsPerBlock.siteOwnerValidation = "false"
        oDocumentsPerBlock.InstancesPerDocuments["siteOwnerValidationVF"] = false
        oDocumentsPerBlock.siteOwnerStatusIconVF = null
        oDocumentsPerBlock.siteOwnerStatusStateVF = null
        oDocumentsPerBlock.siteOwnerStatusTextVF = null
        oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationCommentsFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationDateFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidatorFC = DisplayTypesFC.HIDDEN
        oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
    }
}

const getDPBNotEditable = (oDocumentsPerBlock) => {
    oDocumentsPerBlock.responsibleDefaultFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.approverTypeFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.responsibleDefaultFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.contactPhoneFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.contactEmailFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.endDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.startDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.expectedSubmissionDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.submissionDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.expirationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerInformDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationCommentsFC = DisplayTypesFC.READONLY

    oDocumentsPerBlock.cellnexValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.subcontractorValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.customerValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
}

const getDPBDeleted = (oDocumentsPerBlock) => {
    // oDocumentsPerBlock = await this.#onDocoumentsPerBlockBooleanToText(oDocumentsPerBlock, oInstancesPerDocument)
    oDocumentsPerBlock.InstancesPerDocuments["blockId"] = oDocumentsPerBlock.blockId
    oDocumentsPerBlock.InstancesPerDocuments["blockIdVF"] = oDocumentsPerBlock.blockId
    oDocumentsPerBlock.responsibleDefaultFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.approverTypeFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.subcoTypeFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.responsibleDefaultFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.cellnexResponsibleFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.subcontractorResponsibleFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.agencyResponsibleFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.customerResponsibleFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.cellnexValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.subcontractorValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.customerValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.siteOwnerValidationFC = DisplayTypesFC.HIDDEN
    oDocumentsPerBlock.InstancesPerDocuments.contactEmailFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.contactPhoneFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.endDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.startDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.submissionDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.expectedSubmissionDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.expirationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerInformDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.cellnexValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.customerValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidatorFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationCommentsFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationDateFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidationFC = DisplayTypesFC.READONLY
    oDocumentsPerBlock.InstancesPerDocuments.siteOwnerValidatorFC = DisplayTypesFC.READONLY
}

const getDefaultResponsible = async (sResponsibleId, sSubcoId, sDocResponsibleId, oRequest) => {
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

const getNextStep = (sStepId, bCellnexValidation, bSubcoValidation, bCustomerValidation, bSiteOwnerValidation, bCellnexValidationIdp, bSubcoValidationIdp, bCustomerValidationIdp, bSiteOwnerValidationIdp) => {
    if (sStepId === Validators.RESPONSIBLE) {
        if (bCellnexValidation === 'true' && (bCellnexValidationIdp !== DocumentValidationValues.valid && bCellnexValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.CELLNEX
        } else if (bSubcoValidation === 'true' && (bSubcoValidationIdp !== DocumentValidationValues.valid && bSubcoValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.SUBCO
        } else if (bCustomerValidation === 'true' && (bCustomerValidationIdp !== DocumentValidationValues.valid && bCustomerValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.CUSTOMER
        } else if (bSiteOwnerValidation === 'true' && (bSiteOwnerValidationIdp !== DocumentValidationValues.valid && bSiteOwnerValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.SITE_OWNER
        } else {
            return Validators.COMPLETED
        }
    } else if (sStepId === Validators.CELLNEX) {
        if (bSubcoValidation === 'true' && (bSubcoValidationIdp !== DocumentValidationValues.valid && bSubcoValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.SUBCO
        } else if (bCustomerValidation === 'true' && (bCustomerValidationIdp !== DocumentValidationValues.valid && bCustomerValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.CUSTOMER
        } else if (bSiteOwnerValidation === 'true' && (bSiteOwnerValidationIdp !== DocumentValidationValues.valid && bSiteOwnerValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.SITE_OWNER
        } else {
            return Validators.COMPLETED
        }
    } else if (sStepId === Validators.SUBCO) {
        if (bCustomerValidation === 'true' && (bCustomerValidationIdp !== DocumentValidationValues.valid && bCustomerValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.CUSTOMER
        } else if (bSiteOwnerValidation === 'true' && (bSiteOwnerValidationIdp !== DocumentValidationValues.valid && bSiteOwnerValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.SITE_OWNER
        } else {
            return Validators.COMPLETED
        }
    } else if (sStepId === Validators.CUSTOMER) {
        if (bSiteOwnerValidation === 'true' && (bSiteOwnerValidationIdp !== DocumentValidationValues.valid && bSiteOwnerValidationIdp !== DocumentValidationValues.validWRestricts)) {
            return Validators.SITE_OWNER
        } else {
            return Validators.COMPLETED
        }
    } else {
        return Validators.COMPLETED
    }
}

const getOTDocumentStatusBody = (aListOTId, iDocStatus, stepId) => {
    let oStatus = mapStepToOTStatus(stepId, iDocStatus)
    const documentStatusList = aListOTId.map(item => ({
        "dataID": item.fileUrl,
        "documentStatusValue": oStatus
    }))
    return { "documentStatusList": documentStatusList }
}

const mapStepToOTStatus = (sStepId, iDocStatus) => {
    if (iDocStatus === DocumentStatus.CANCELLED) {
        return "Cancelled";
    } else {
        switch (String(sStepId)) {
            case Validators.RESPONSIBLE:
                return "In Progress";
            case Validators.SUBCO:
                return "In Validation - Subcontractor";
            case Validators.CELLNEX:
                return "In Validation - Cellnex";
            case Validators.CUSTOMER:
                return "In Validation - Customer";
            case Validators.SITE_OWNER:
                return "In Validation - Site Owner";
            case Validators.COMPLETED:
                return "Completed";
            default:
                return "Completed";
        }
    }
}

const setDocumentStatusInfo = async (oRequest, oDocumentsPerBlock, sIcon, smessageType, sStatusText) => {
    oDocumentsPerBlock.statusIconVF = sIcon
    oDocumentsPerBlock.statusStateVF = smessageType
    oDocumentsPerBlock.statusTextVF = await SELECT.one.from`DOCUMENT_FLOW_STATUS_TEXTS`.where`code = ${sStatusText} and locale =  ${oRequest.locale}`
    oDocumentsPerBlock.statusTextVF = oDocumentsPerBlock.statusTextVF?.DESCR
}

const setDocumentValidatorsStatusInfo = async (oRequest, sFieldname, oDocumentsPerBlock, sIcon, smessageType, sStatusText) => {
    oDocumentsPerBlock[sFieldname + 'StatusIconVF'] = sIcon
    oDocumentsPerBlock[sFieldname + 'StatusStateVF'] = smessageType
    oDocumentsPerBlock[sFieldname + 'StatusTextVF'] = await SELECT.one.from`DOCUMENT_FLOW_STATUS_TEXTS`.where`code = ${sStatusText} and locale =  ${oRequest.locale}`
    oDocumentsPerBlock[sFieldname + 'StatusTextVF'] = oDocumentsPerBlock.statusTextVF?.DESCR
}

const checkDPBResponsible = async (oRequest) => {
    if ('cellnexResponsible' in oRequest.data && oRequest.data.cellnexResponsible !== null && oRequest.data.cellnexResponsible !== '') {
        let oDocumentPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oRequest.data.ID}`
        if (oDocumentPerBlock) {
            let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oDocumentPerBlock.BLOCK_ID})`
            let oUsers = []
            oUsers = await SELECT.from`USERS(p_country: ${oEntities.COUNTRY_ID})`.where`userId = ${oRequest.data.cellnexResponsible}`
            if (oUsers.length === 0) oRequest.error(400, 'notValidValue', `/DocumentsPerBlocks(guid'${oRequest.data.ID}')/cellnexResponsible`, [oRequest.data.cellnexResponsible, 'cellnexResponsible'])
        }
    }
}

const checkDocument = async (oRequest, sRequestId, sDocumentId, sCandidateId) => {
    try {
        let oDocument = await SELECT.one.from`REQUEST_ALL_DOCUMENTS(p_requestId: ${sRequestId})`.where`GENERIC_TYPE_ID = ${sDocumentId}`
        if (oDocument) oRequest.error(400, 'documentAlreadyExist', [oDocument.GENERIC_TYPE_ID, oDocument.MASTER_PHASE_ID, oDocument.MASTER_BLOCK_ID])
    } catch (oError) {
        oRequest.error(400, oError.message)
    }
}

const checkDocumentValidators = async (oRequest) => {
    if ('cellnexValidator' in oRequest.data && oRequest.data.cellnexValidator !== null && oRequest.data.cellnexValidator !== '') {
        let oInstancesPerDocument = await SELECT.one.from`INSTANCES_PER_DOCUMENT`.where`REGISTER_ID = ${oRequest.data.ID}`
        if (oInstancesPerDocument) {
            let oDocumentPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oInstancesPerDocument.INSTANCE_ID}`
            if (oDocumentPerBlock) {
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oDocumentPerBlock.BLOCK_ID})`
                let oUsers = []
                oUsers = await SELECT.from`USERS(p_country: ${oEntities.COUNTRY_ID})`.where`userId = ${oRequest.data.cellnexValidator}`
                if (oUsers.length === 0) oRequest.error(400, 'notValidValue', `/DocumentsPerBlocks(guid'${oRequest.data.ID}')/cellnexValidator`, [oRequest.data.cellnexValidator, 'cellnexValidator'])
            }
        }
    }
    if (oRequest.data && 'customerValidator' in oRequest.data && oRequest.data.customerValidator !== null && oRequest.data.customerValidator !== '') {
        let oInstancesPerDocument = await SELECT.one.from`INSTANCES_PER_DOCUMENT`.where`REGISTER_ID = ${oRequest.data.ID}`
        if (oInstancesPerDocument) {
            let oDocumentPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oInstancesPerDocument.INSTANCE_ID}`
            if (oDocumentPerBlock) {
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oDocumentPerBlock.BLOCK_ID})`
                let oUsers = []
                oUsers = await SELECT.from`USERS(p_country: ${oEntities.COUNTRY_ID})`.where`userId = ${oRequest.data.customerValidator}`
                if (oUsers.length === 0) oRequest.error(400, 'notValidValue', `/DocumentsPerBlocks(guid'${oRequest.data.ID}')/customerValidator`, [oRequest.data.customerValidator, 'customerValidator'])
            }
        }
    }
}

const checkDocumentAuth = async (oRequest, sId) => {
    let bHasAuth = false
    if (oRequest.user.is(Roles.MANAGER_USER_ROL)) {
        bHasAuth = true
    } else {
        let oDocument = await SELECT.one.from`project.DocumentsPerBlocks`.where`ID = ${sId}`
        if (oDocument) {
            let sParentType
            let oParentHead
            if (oDocument.workId) {
                sParentType = ParentTypes.WORK
                oParentHead = await SELECT.one.from`project.Works`.where`ID = ${oDocument.workId}`
            } else {
                sParentType = ParentTypes.BLOCK
                oParentHead = await SELECT.one.from`project.Blocks`.where`ID = ${oDocument.blockId}`
            }
            let oInstance = await SELECT.one.from`project.InstancesPerDocuments`.where`instanceId = ${oDocument.ID}`
            let oResponsible = await getResponsible(oRequest, sParentType, oParentHead)
            if ((oRequest.user.id === oResponsible.ID && oResponsible.isInternal && oRequest.user.is(Roles.CELLNEX_USER_ROL)) || //internal user assigned to block
                (oDocument.responsibleId === AssignedResponsibleTypes.CELLNEX && oRequest.user.id === oDocument.responsibleDefault) || //internal user assigned to Document
                (oInstance.STEP_ID === Validators.RESPONSIBLE && oDocument.responsibleId === AssignedResponsibleTypes.EXTERNAL && (oRequest.agoraCurrentUserData?.vendor === oDocument.responsibleDefault || oRequest.agoraCurrentUserData?.agency === oDocument.responsibleDefault)) || //external user assigned to Document
                (oInstance.STEP_ID === Validators.CELLNEX && oRequest.user.id(Roles.CELLNEX_USER_ROL) && oRequest.user.id === oInstance.cellnexValidator) || //cellnex validator
                (oInstance.STEP_ID === Validators.SUBCO && oRequest.user.id(Roles.VENDOR_USER_ROL) && oExternals.vendor === oInstance.subcontractorValidator) || // subcontractor Validator
                (oInstance.STEP_ID === Validators.SUBCO && oRequest.user.id(Roles.AGENCY_USER_ROL) && oExternals.agency === oInstance.subcontractorValidator) || // subcontractor Validator
                (oInstance.STEP_ID === Validators.CUSTOMER && oRequest.user.id(Roles.CUSTOMER_USER_ROL) && oExternals.customer === oInstance.customerValidator) // Customer Validator
            ) {
                bHasAuth = true
            }
        } else {
            oRequest.error(400, 'missingDocument')
        }
    }
    return bHasAuth
}

const checkMandatoryFieldsIPD = async (oRequest, oInstancesPerDocument) => {
    let sStepId = oInstancesPerDocument.STEP_ID
    if (sStepId === Validators.RESPONSIBLE) {
        if (oInstancesPerDocument.EXPECTED_SUBMISSION_DATE === null || oInstancesPerDocument.EXPECTED_SUBMISSION_DATE === undefined) oRequest.error(400, 'documentExpectedSubmissionDateMissing')
        await checkDocumentLoaded(oRequest, oInstancesPerDocument)
    } else if (sStepId === Validators.CELLNEX) {
        if (oInstancesPerDocument.CELLNEX_VALIDATOR === null || oInstancesPerDocument.CELLNEX_VALIDATOR === '') {
            oRequest.error(400, 'validatorMissing')
        }
        if (oInstancesPerDocument.CELLNEX_VALIDATION !== DocumentValidationValues.valid && oInstancesPerDocument.CELLNEX_VALIDATION !== DocumentValidationValues.validWRestricts) {
            if (oInstancesPerDocument.CELLNEX_VALIDATION === DocumentValidationValues.nonValid) {
                oRequest.error(400, 'mustReject')
            } else {
                oRequest.error(400, 'validationMissing')
            }
        }
        if (oInstancesPerDocument.CELLNEX_VALIDATION_DATE === null || oInstancesPerDocument.CELLNEX_VALIDATION_DATE === undefined) {
            oRequest.error(400, 'validationDateMissing')
        }
    } else if (sStepId === Validators.SUBCO) {
        if (oInstancesPerDocument.SUBCONTRACTOR_VALIDATOR === null || oInstancesPerDocument.SUBCONTRACTOR_VALIDATOR === '') {
            oRequest.error(400, 'validatorMissing')
        }
        if (oInstancesPerDocument.SUBCONTRACTOR_VALIDATION !== DocumentValidationValues.valid && oInstancesPerDocument.SUBCONTRACTOR_VALIDATION !== DocumentValidationValues.validWRestricts) {
            if (oInstancesPerDocument.SUBCONTRACTOR_VALIDATION === DocumentValidationValues.nonValid) {
                oRequest.error(400, 'mustReject')
            } else {
                oRequest.error(400, 'validationMissing')
            }
        }
        if (oInstancesPerDocument.SUBCONTRACTOR_VALIDATION_DATE === null || oInstancesPerDocument.SUBCONTRACTOR_VALIDATION_DATE === undefined) {
            oRequest.error(400, 'validationDateMissing')
        }
    } else if (sStepId === Validators.CUSTOMER) {
        if (oInstancesPerDocument.CUSTOMER_INFORM_DATE === null || oInstancesPerDocument.CUSTOMER_INFORM_DATE === undefined) oRequest.error(400, 'documentCustomerInformDateMissing')
        if (oInstancesPerDocument.CUSTOMER_VALIDATOR === null || oInstancesPerDocument.CUSTOMER_VALIDATOR === '') {
            oRequest.error(400, 'validatorMissing')
        }
        if (oInstancesPerDocument.CUSTOMER_VALIDATION !== DocumentValidationValues.valid && oInstancesPerDocument.CUSTOMER_VALIDATION !== DocumentValidationValues.validWRestricts) {
            if (oInstancesPerDocument.CUSTOMER_VALIDATION === DocumentValidationValues.nonValid) {
                oRequest.error(400, 'mustReject')
            } else {
                oRequest.error(400, 'validationMissing')
            }
        }
        if (oInstancesPerDocument.CUSTOMER_VALIDATION_DATE === null || oInstancesPerDocument.CUSTOMER_VALIDATION_DATE === undefined) {
            oRequest.error(400, 'validationDateMissing')
        }
    } else if (sStepId === Validators.SITE_OWNER) {
        if (oInstancesPerDocument.SITEOWNER_VALIDATOR === null || oInstancesPerDocument.SITEOWNER_VALIDATOR === '') {
            oRequest.error(400, 'validatorMissing')
        }
        if (oInstancesPerDocument.SITEOWNER_VALIDATION !== DocumentValidationValues.valid && oInstancesPerDocument.SITEOWNER_VALIDATION !== DocumentValidationValues.validWRestricts) {
            if (oInstancesPerDocument.SITEOWNER_VALIDATION === DocumentValidationValues.nonValid) {
                oRequest.error(400, 'mustReject')
            } else {
                oRequest.error(400, 'validationMissing')
            }
        }
        if (oInstancesPerDocument.SITEOWNER_VALIDATION_DATE === null || oInstancesPerDocument.SITEOWNER_VALIDATION_DATE === undefined) {
            oRequest.error(400, 'validationDateMissing')
        }
    }
}

const checkCancelFieldIPD = async (oRequest, oInstancesPerDocument) => {
    let sStepId = oInstancesPerDocument.STEP_ID
    if (sStepId === Validators.CELLNEX) {
        if (oInstancesPerDocument.CELLNEX_VALIDATION !== DocumentValidationValues.nonValid) {
            oRequest.error(400, 'rejectionMissing')
        }
    } else if (sStepId === Validators.SUBCO) {
        if (oInstancesPerDocument.SUBCONTRACTOR_VALIDATION !== DocumentValidationValues.nonValid) {
            oRequest.error(400, 'rejectionMissing')
        }
    } else if (sStepId === Validators.CUSTOMER) {
        if (oInstancesPerDocument.CUSTOMER_VALIDATION !== DocumentValidationValues.nonValid) {
            oRequest.error(400, 'rejectionMissing')
        }
    } else if (sStepId === Validators.SITE_OWNER) {
        if (oInstancesPerDocument.SITEOWNER_VALIDATION !== DocumentValidationValues.nonValid) {
            oRequest.error(400, 'rejectionMissing')
        }
    }
}

const checkDocumentId = async (oRequest, sProcessId, sPhaseProcessFlowId, sBlockProcessFlowId, sDocumentId) => {
    if (!sDocumentId) {
        oRequest.error(400, 'missingDocumentId')
        return
    }
    let oDocumentId = await SELECT.one.from`DOCUMENTS_PER_PROCESS`.where`processFlowId = ${sProcessId} and phaseProcessFlowId = ${sPhaseProcessFlowId} and blockProcessFlowId = ${sBlockProcessFlowId} and documentId = ${sDocumentId}`
    if (!oDocumentId) oRequest.error(400, nonValidDocumentId)
}

const checkDocumentLoaded = async (oRequest, oInstancesPerDocument) => {
    //local/mocked mode: OpenText is unreachable, skip mandatory attachment guard so process can advance
    if (cds.env.requires?.auth?.kind === 'mocked') return
    try {
        let oAttachment = await SELECT.one.from`WF_DETAIL_DOCUMENTS`.where`INSTANCE_ID = ${oInstancesPerDocument.REGISTER_ID} and DELETED != true`
        if (!oAttachment) oRequest.error(400, 'uploadAttachmentMandatory')
    } catch (oError) {
        oRequest.error(400, 'uploadAttachmentMandatory')
    }
}

const addDocumentPerBlock = async (oRequest, oBlock, oWork, oDocumentConfig, aDocumentsPerBlock, aInstancesPerDocument, documentId, iOrder, sVersion, oPreviousDocumentPerBlock, oPreviousInstancesPerDocument, oRequestHead, oDefaultDocumentConfig) => {
    let sResponsibleId, sSubcoId, sRespType, bClientValidation, bSubcoValidation, bSiteOwnerValidation, bCellnexValidation
    let ssubcontractorValidator, sSiteOwnerValidator, sCustomerValidator, sCellnexValidator
    let oDocumentsPerBlock = {}
    let oInstancesPerDocument = {}
    if (oDocumentConfig && oDefaultDocumentConfig) {
        let sDefaultResponsible = ''
        if (parseInt(oDocumentConfig.approverType, 10) === 1 && oRequestHead) sDefaultResponsible = oRequestHead.REQUEST_OWNER_ID
        if (parseInt(oDocumentConfig.approverType, 10) === 2 && parseInt(oDocumentConfig.externalType, 10) === 3 && oRequestHead) {
            let oRequestProvision = SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.REQUEST_ID}`
            sDefaultResponsible = oRequestProvision.preferredProvider
        }
        if (parseInt(oDocumentConfig.approverType, 10) === 2 && parseInt(oDocumentConfig.externalType, 10) === 2 && oRequestHead) sDefaultResponsible = oRequestHead.CUSTOMER_ID
        sResponsibleId = oDocumentConfig.approverType
        sSubcoId = oDocumentConfig.externalType
        sRespType = sDefaultResponsible
        bSubcoValidation = oDocumentConfig.subcontractorValidationReq
        bCellnexValidation = oDocumentConfig.cellnexValidationReq
        bClientValidation = oDocumentConfig.customerValidationReq
        bSiteOwnerValidation = oDocumentConfig.landlordValidationReq
        if (bSubcoValidation && oRequestHead) {
            let oRequestProvision = SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.REQUEST_ID}`
            ssubcontractorValidator = oRequestProvision.preferredProvider
        } else {
            ssubcontractorValidator = null
        }
        if (bSiteOwnerValidation && oRequestHead) {
            sSiteOwnerValidator = oRequestHead.REQUEST_OWNER_ID
        } else {
            sSiteOwnerValidator = null
        }
        if (bClientValidation && oRequestHead) {
            sCustomerValidator = oRequestHead.REQUEST_OWNER_ID
        } else {
            sCustomerValidator = null
        }
        if (bCellnexValidation && oRequestHead) {
            sCellnexValidator = oRequestHead.REQUEST_OWNER_ID
        } else {
            sCellnexValidator = null
        }
    } else if (oDocumentConfig) {
        sResponsibleId = oDocumentConfig.APPROVER_TYPE
        sSubcoId = oDocumentConfig.SUBCONTRACTOR
        if (parseInt(sResponsibleId, 10) === 1 && oRequestHead) oDocumentConfig.DEFAULT_RESPONSIBLE = oRequestHead.REQUEST_OWNER_ID
        if (parseInt(sResponsibleId, 10) === 2 && parseInt(sSubcoId, 10) === 3 && oRequestHead) {
            let oRequestProvision2 = SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.REQUEST_ID}`
            oDocumentConfig.DEFAULT_RESPONSIBLE = oRequestProvision2.preferredProvider
        }
        sRespType = oDocumentConfig.DEFAULT_RESPONSIBLE
        bCellnexValidation = oDocumentConfig.CELLNEX_REQ_VAL
        bClientValidation = oDocumentConfig.CUSTOMER__REQ_VAL
        bSubcoValidation = oDocumentConfig.SUBCO_REQ_VAL
        bSiteOwnerValidation = oDocumentConfig.SITEOWNER_REQ_VAL
        if (bSubcoValidation && oRequestHead) {
            let oRequestProvision = SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.REQUEST_ID}`
            ssubcontractorValidator = oRequestProvision.preferredProvider
        } else {
            ssubcontractorValidator = null
        }
        if (bSiteOwnerValidation && oRequestHead) {
            sSiteOwnerValidator = oRequestHead.REQUEST_OWNER_ID
        } else {
            sSiteOwnerValidator = null
        }
        if (bClientValidation && oRequestHead) {
            sCustomerValidator = oRequestHead.REQUEST_OWNER_ID
        } else {
            sCustomerValidator = null
        }
        if (bCellnexValidation && oRequestHead) {
            sCellnexValidator = oRequestHead.REQUEST_OWNER_ID
        } else {
            sCellnexValidator = null
        }
    } else if (oPreviousDocumentPerBlock) {
        sResponsibleId = oPreviousDocumentPerBlock.RESPONSIBLE_ID
        sSubcoId = oPreviousDocumentPerBlock.SUBCONTRATOR_ID
        sRespType = oPreviousDocumentPerBlock.T_RESPONSIBLE
        bCellnexValidation = oPreviousDocumentPerBlock.VALIDATION_CELLNEX_CLIENT
        bClientValidation = oPreviousDocumentPerBlock.VALIDATION_REQ_CLIENT
        bSubcoValidation = oPreviousDocumentPerBlock.VALIDATION_SUBCO_CLIENT
        bSiteOwnerValidation = oPreviousDocumentPerBlock.VALIDATION_SITEOWNER_NEEDED
        ssubcontractorValidator = oPreviousInstancesPerDocument.SUBCONTRACTOR_VALIDATOR
        sSiteOwnerValidator = oPreviousInstancesPerDocument.SITEOWNER_VALIDATOR
        sCustomerValidator = oPreviousInstancesPerDocument.CUSTOMER_VALIDATOR
        sCellnexValidator = oPreviousInstancesPerDocument.CELLNEX_VALIDATOR
    }
    if (oPreviousDocumentPerBlock || oDocumentConfig) {
        oDocumentsPerBlock = {
            'RESPONSIBLE_ID': sResponsibleId,
            'SUBCONTRATOR_ID': sSubcoId,
            'T_RESPONSIBLE': sRespType,
            'VALIDATION_CELLNEX_CLIENT': String(bCellnexValidation),
            'VALIDATION_REQ_CLIENT': String(bClientValidation),
            'VALIDATION_SUBCO_CLIENT': String(bSubcoValidation),
            'VALIDATION_SITEOWNER_NEEDED': String(bSiteOwnerValidation),
            'ORDER': iOrder,
            'STATUS': DocumentStatus.NOT_INIT,
            'REGISTER_ID': cds.utils.uuid(),
            'BLOCK_ID': oBlock.BLOCK_ID,
            'WORK_ID': oWork ? oWork.ID : null,
            'CREATEDAT': oRequest.timestamp,
            'CREATEDBY': oRequest.user.id,
            'MODIFIEDAT': oRequest.timestamp,
            'MODIFIEDBY': oRequest.user.id,
            'GENERIC_TYPE_ID': documentId
        }

        oInstancesPerDocument = {
            'SUBCONTRACTOR_VALIDATOR': ssubcontractorValidator,
            'SITEOWNER_VALIDATOR': sSiteOwnerValidator,
            'CUSTOMER_VALIDATOR': sCustomerValidator,
            'CELLNEX_VALIDATOR': sCellnexValidator,
            'VERSION': sVersion,
            'REGISTER_ID': cds.utils.uuid(),
            'STEP_ID': Validators.NOT_INI,
            'INSTANCE_ID': oDocumentsPerBlock.REGISTER_ID,
            'CREATEDAT': oRequest.timestamp,
            'MODIFIEDAT': oRequest.timestamp,
            'CREATEDBY': oRequest.user.id,
            'MODIFIEDBY': oRequest.user.id
        }
    } else {
        if (!oRequest.user.is(Roles.MANAGER_USER_ROL) && oRequest.user.is(Roles.VENDOR_USER_ROL)) {
            if (oRequestHead) {
                let oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.REQUEST_ID}`
                oDocumentsPerBlock = {
                    RESPONSIBLE_ID: AssignedResponsibleTypes.EXTERNAL,
                    SUBCONTRATOR_ID: SubcoTypes.VENDOR,
                    T_RESPONSIBLE: oRequestProvision.preferredProvider,
                    ORDER: iOrder,
                    STATUS: DocumentStatus.NOT_INIT,
                    REGISTER_ID: cds.utils.uuid(),
                    BLOCK_ID: oBlock.BLOCK_ID,
                    WORK_ID: oWork ? oWork.ID : null,
                    GENERIC_TYPE_ID: documentId,
                };
            } else {
                oDocumentsPerBlock = {
                    ORDER: iOrder,
                    STATUS: DocumentStatus.NOT_INIT,
                    REGISTER_ID: cds.utils.uuid(),
                    BLOCK_ID: oBlock.BLOCK_ID,
                    WORK_ID: oWork ? oWork.ID : null,
                    GENERIC_TYPE_ID: documentId,
                };
            }
        } else {
            if (oRequestHead) {
                oDocumentsPerBlock = {
                    RESPONSIBLE_ID: "1",
                    T_RESPONSIBLE: oRequestHead.REQUEST_OWNER_ID,
                    ORDER: iOrder,
                    STATUS: DocumentStatus.NOT_INIT,
                    REGISTER_ID: cds.utils.uuid(),
                    BLOCK_ID: oBlock.BLOCK_ID,
                    WORK_ID: oWork ? oWork.ID : null,
                    GENERIC_TYPE_ID: documentId,
                };
            } else {
                oDocumentsPerBlock = {
                    ORDER: iOrder,
                    STATUS: DocumentStatus.NOT_INIT,
                    REGISTER_ID: cds.utils.uuid(),
                    BLOCK_ID: oBlock.BLOCK_ID,
                    WORK_ID: oWork ? oWork.ID : null,
                    GENERIC_TYPE_ID: documentId,
                };
            }
        }
        oInstancesPerDocument = { 'VERSION': sVersion, 'REGISTER_ID': cds.utils.uuid(), 'STEP_ID': Validators.NOT_INI, 'INSTANCE_ID': oDocumentsPerBlock.REGISTER_ID, 'CREATEDAT': oRequest.timestamp, 'MODIFIEDAT': oRequest.timestamp, 'CREATEDBY': oRequest.user.id, 'MODIFIEDBY': oRequest.user.id }

    }
    aDocumentsPerBlock.push(oDocumentsPerBlock)
    aInstancesPerDocument.push(oInstancesPerDocument)

    //NOSONAR //Calculate milestone for document
    //NOSONAR let aMilestones = [];
    //NOSONAR await oForecastHandler.setProject(oRequestHead.REQUEST_ID);
    //NOSONAR aMilestones = await oForecastHandler.getMilestonesConfig(oRequest);
    //NOSONAR if (aMilestones.length > 0) {
    //NOSONAR     await oForecastHandler.processNewDocuments(aMilestones, oDocumentsPerBlock, oInstancesPerDocument);
    //NOSONAR }
}

const addDocumentPerWork = async (oRequest, oBlock, oWork, oWorkConfig, documentId, aDocumentsPerBlock, aInstancesPerDocument) => {
    let oDocumentsPerBlock = {
        'RESPONSIBLE_ID': oWorkConfig.approverType,
        'SUBCONTRATOR_ID': oWorkConfig.externalType,
        //NOSONAR 'T_RESPONSIBLE': oWorkConfig.DEFAULT_RESPONSIBLE,
        'VALIDATION_CELLNEX_CLIENT': String(oWorkConfig.cellnexValidationReq),
        'VALIDATION_REQ_CLIENT': String(oWorkConfig.customerValidationReq),
        'VALIDATION_SUBCO_CLIENT': String(oWorkConfig.subcontractorValidationReq),
        'VALIDATION_SITEOWNER_NEEDED': String(oWorkConfig.landlordValidationReq),
        'ORDER': aDocumentsPerBlock.length + 1,
        'STATUS': DocumentStatus.NOT_INIT,
        'REGISTER_ID': cds.utils.uuid(),
        'BLOCK_ID': oBlock.BLOCK_ID,
        'WORK_ID': oWork.ID,
        'CREATEDAT': oRequest.timestamp,
        'CREATEDBY': oRequest.user.id,
        'MODIFIEDAT': oRequest.timestamp,
        'MODIFIEDBY': oRequest.user.id,
        'GENERIC_TYPE_ID': documentId
    }

    let oInstancesPerDocument = {
        'SUBCONTRACTOR_VALIDATOR': null,
        'SITEOWNER_VALIDATOR': null,
        'CUSTOMER_VALIDATOR': null,
        'CELLNEX_VALIDATOR': null,
        'VERSION': 1,
        'REGISTER_ID': cds.utils.uuid(),
        'STEP_ID': Validators.NOT_INI,
        'INSTANCE_ID': oDocumentsPerBlock.REGISTER_ID,
        'CREATEDAT': oRequest.timestamp,
        'MODIFIEDAT': oRequest.timestamp,
        'CREATEDBY': oRequest.user.id,
        'MODIFIEDBY': oRequest.user.id
    }

    aDocumentsPerBlock.push(oDocumentsPerBlock)
    aInstancesPerDocument.push(oInstancesPerDocument)
}

const controlDPBActionsVisibility = (oRequest, bAllAuth, oDocumentsPerBlock, oBlockResponsible) => {
    if (bAllAuth) {
        oDocumentsPerBlock.canInit = true
        oDocumentsPerBlock.canSee = true
        oDocumentsPerBlock.canDelete = true
        oDocumentsPerBlock.canDownload = true
    } else {
        oDocumentsPerBlock.canInit = false
        oDocumentsPerBlock.canDelete = false
        oDocumentsPerBlock.canSee = false
        oDocumentsPerBlock.canDownload = false
        if (((oBlockResponsible.ID === oRequest.agoraCurrentUserData?.vendor && oRequest.agoraCurrentUserData?.vendor !== null && oRequest.agoraCurrentUserData?.vendor !== '') ||
            (oBlockResponsible.ID === oRequest.agoraCurrentUserData?.agency && oRequest.agoraCurrentUserData?.agency !== null && oRequest.agoraCurrentUserData?.agency !== '')) && !oBlockResponsible.isInternal) {
            oDocumentsPerBlock.canInit = true
            oDocumentsPerBlock.canDownload = true
        }
        if ((oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.EXTERNAL && oRequest.agoraCurrentUserData?.vendor === oDocumentsPerBlock.responsibleDefault) || // external user assigned to document
            (oDocumentsPerBlock.responsibleId === AssignedResponsibleTypes.EXTERNAL && oRequest.agoraCurrentUserData?.agency === oDocumentsPerBlock.responsibleDefault) ||
            ((oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidator === oRequest.agoraCurrentUserData?.vendor && oRequest.agoraCurrentUserData?.vendor !== null && oRequest.agoraCurrentUserData?.vendor !== '') ||
                (oDocumentsPerBlock.InstancesPerDocuments.subcontractorValidator === oRequest.agoraCurrentUserData?.agency && oRequest.agoraCurrentUserData?.agency !== null && oRequest.agoraCurrentUserData.agency !== ''))) {
            oDocumentsPerBlock.canSee = true
            oDocumentsPerBlock.canDownload = true
        }
    }
}

const DPBBooleanToText = (oDocumentsPerBlock) => {
    if (oDocumentsPerBlock.cellnexValidation !== null) {
        oDocumentsPerBlock["cellnexValidationVF"] = oDocumentsPerBlock.cellnexValidation === "true" ? true : false
        oDocumentsPerBlock.InstancesPerDocuments["cellnexValidationVF"] = oDocumentsPerBlock.cellnexValidation === "true" ? true : false

    }
    if (oDocumentsPerBlock.subcontractorValidation !== null) {
        oDocumentsPerBlock["subcontractorValidationVF"] = oDocumentsPerBlock.subcontractorValidation === "true" ? true : false
        oDocumentsPerBlock.InstancesPerDocuments["subcontractorValidationVF"] = oDocumentsPerBlock.subcontractorValidation === "true" ? true : false

    }
    if (oDocumentsPerBlock.customerValidation !== null) {
        oDocumentsPerBlock["customerValidationVF"] = oDocumentsPerBlock.customerValidation === "true" ? true : false
        oDocumentsPerBlock.InstancesPerDocuments["customerValidationVF"] = oDocumentsPerBlock.customerValidation === "true" ? true : false

    }
    if (oDocumentsPerBlock.siteOwnerValidation !== null) {
        oDocumentsPerBlock["siteOwnerValidationVF"] = oDocumentsPerBlock.siteOwnerValidation === "true" ? true : false
        oDocumentsPerBlock.InstancesPerDocuments["siteOwnerValidationVF"] = oDocumentsPerBlock.siteOwnerValidation === "true" ? true : false

    }
}

const udpateFlowTables = async (oRequest, sRegisterId, iStatus, sNewStepID, bDeleted, sCancellationReason, sOldStepID, oInstancesPerDocument) => {
    try {
        if (bDeleted) {
            await UPDATE.entity('DOCUMENTS_PER_BLOCK', { 'REGISTER_ID': sRegisterId }).with(
                {
                    'STATUS': iStatus,
                    'MODIFIEDAT': oRequest.timestamp,
                    'MODIFIEDBY': oRequest.user.id,
                    'DELETED': bDeleted,
                    'DELETED_AT': oRequest.timestamp,
                    'DELETED_BY': oRequest.user.id
                }
            )
            await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': sRegisterId }).with({
                'CANCELLATION_REASON': sCancellationReason,
                'MODIFIEDAT': oRequest.timestamp,
                'MODIFIEDBY': oRequest.user.id,
                'DELETED': bDeleted,
                'DELETED_AT': oRequest.timestamp,
                'DELETED_BY': oRequest.user.id
            })
        } else {
            let oNewInstancesPerDocument = {
                'STEP_ID': sNewStepID,
                'MODIFIEDAT': oRequest.timestamp,
                'MODIFIEDBY': oRequest.user.id
            }
            if (iStatus === DocumentStatus.IN_PROGRESS && sNewStepID === Validators.RESPONSIBLE) {
                oNewInstancesPerDocument["START_DATE"] = oRequest.timestamp
            } else if (sOldStepID === Validators.RESPONSIBLE) {
                oNewInstancesPerDocument["SUBMISSION_DATE"] = oRequest.timestamp
            } else if (sOldStepID === Validators.CELLNEX) {
                if (oInstancesPerDocument) oNewInstancesPerDocument["CELLNEX_VALIDATION_DATE"] = oInstancesPerDocument?.CELLNEX_VALIDATION_DATE === null ? oRequest.timestamp : oInstancesPerDocument.CELLNEX_VALIDATION_DATE
            } else if (sOldStepID === Validators.SUBCO) {
                if (oInstancesPerDocument) oNewInstancesPerDocument["SUBCONTRACTOR_VALIDATION_DATE"] = oInstancesPerDocument?.SUBCONTRACTOR_VALIDATION_DATE === null ? oRequest.timestamp : oInstancesPerDocument.SUBCONTRACTOR_VALIDATION_DATE
            } else if (sOldStepID === Validators.CUSTOMER) {
                if (oInstancesPerDocument) oNewInstancesPerDocument["CUSTOMER_VALIDATION_DATE"] = oInstancesPerDocument?.CUSTOMER_VALIDATION_DATE === null ? oRequest.timestamp : oInstancesPerDocument.CUSTOMER_VALIDATION_DATE
            } else if (sOldStepID === Validators.SITE_OWNER) {
                if (oInstancesPerDocument) oNewInstancesPerDocument["SITEOWNER_VALIDATION_DATE"] = oInstancesPerDocument?.SITEOWNER_VALIDATION_DATE === null ? oRequest.timestamp : oInstancesPerDocument.SITEOWNER_VALIDATION_DATE
            }
            await UPDATE.entity('INSTANCES_PER_DOCUMENT', { 'INSTANCE_ID': sRegisterId }).with(
                oNewInstancesPerDocument
            )
            await UPDATE.entity('DOCUMENTS_PER_BLOCK', { 'REGISTER_ID': sRegisterId }).with(
                {
                    'STATUS': iStatus,
                    'MODIFIEDAT': oRequest.timestamp,
                    'MODIFIEDBY': oRequest.user.id
                }
            )
        }
    } catch (oError) {
        oRequest.error(400, oError.message)
    }

}

const onNewDocumentPerRequest = async (oRequest) => {
    if ('documentId' in oRequest.data && 'phaseId' in oRequest.data && 'blockId' in oRequest.data && 'requestId' in oRequest.data) {
        try {
            let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.data.requestId}`
            let oPhase = await SELECT.one.from`PHASE_HEAD`.where`REQUEST_ID = ${oRequest.data.requestId} and MASTER_PHASE_ID = ${oRequest.data.phaseId}`
            let oBlock = await SELECT.one.from`BLOCK_HEAD`.where`PHASE_ID = ${oPhase.PHASE_ID} and MASTER_BLOCK_ID = ${oRequest.data.blockId}`
            let oDocumentsPerBlock = await SELECT.from`DOCUMENTS_PER_BLOCK`.where`BLOCK_ID = ${oBlock.BLOCK_ID}`

            if (oRequestHead) {
                await checkDocument(oRequest, oRequest.data.requestId, oRequest.data.documentId, oBlock.CANDIDATE_ID)
                if (oRequest.errors) return
                let aDocumentsPerBlock = []
                let aInstancesPerDocument = []

                let oDefaultDocumentConfig = false
                let oDocumentConfig = await SELECT.one.from`DEFAULT_DOCUMENTS_PER_REQUEST_CUSTOMIZING`.where`REQUEST_ID = ${oPhase.REQUEST_ID} and phase = ${oPhase.MASTER_PHASE_ID} and block = ${oBlock.MASTER_BLOCK_ID} and documentId = ${oRequest.data.documentId} and DELETED != true`;
                if (oDocumentConfig === undefined || oDocumentConfig.length === 0) {
                    oDocumentConfig = await getDefaultParamForBlockDocument(oRequest, oBlock.BLOCK_ID, oRequest.data.documentId)
                    oDefaultDocumentConfig = true
                }

                await addDocumentPerBlock(oRequest, oBlock, null, oDocumentConfig, aDocumentsPerBlock, aInstancesPerDocument, oRequest.data.documentId, oDocumentsPerBlock.length + 1, '1', null, null, oRequestHead, oDefaultDocumentConfig)

                await INSERT.into('DOCUMENTS_PER_BLOCK').entries(aDocumentsPerBlock)
                await INSERT.into('INSTANCES_PER_DOCUMENT').entries(aInstancesPerDocument)

                //-- add log
                await logDocumentEvent(
                    oRequest,
                    Actions.DOCUMENT_INSTANCE_ADD,
                    {
                        documentId: oRequest.data.documentId,
                        requestId: oRequest.data.requestId,
                        blockId: oBlock.BLOCK_ID,
                        masterBlockId: oBlock.MASTER_BLOCK_ID,
                        phaseId: oPhase.PHASE_ID,
                        masterPhaseId: oPhase.MASTER_PHASE_ID,
                        requestType: oRequestHead.REQUEST_TYPE
                    }
                )
                //-- add log    

            } else {
                oRequest.error(400, 'requestNotFound')
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    } else {
        oRequest.error(400, 'missingParameters')
    }
}

module.exports = {
    getHiddenDocumentTypes,
    getDefaultParamForBlockDocument,
    getDefaultParamForWorkDocument,
    getDocumentStatusInfo,
    getStatusSteps,
    getDPBDefaultValues,
    getDPBValidatorNotInit,
    getDPBValidatorResponsible,
    getDPBValidatorCellnex,
    getDPBValidatorSubcontractor,
    getDPBValidatorCustomer,
    getDPBValidatorSiteOwner,
    getDPBEditabilityFields,
    getDPBNotEditable,
    getDPBDeleted,
    getDefaultResponsible,
    getNextStep,
    getOTDocumentStatusBody,
    checkDocumentId,
    checkDPBResponsible,
    checkMandatoryFieldsIPD,
    checkCancelFieldIPD,
    checkDocumentValidators,
    checkDocumentAuth,
    controlDPBActionsVisibility,
    checkDocument,
    addDocumentPerBlock,
    addDocumentPerWork,
    DPBBooleanToText,
    udpateFlowTables,
    onNewDocumentPerRequest
}