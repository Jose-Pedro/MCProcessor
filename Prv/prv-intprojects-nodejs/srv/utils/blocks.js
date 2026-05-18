const { Actions, AssignedResponsibleTypes, SubcoTypes, PhaseStatus, BlockStatus, ParentTypes, DocumentStatus, Validators, SubcoHiddenBlocks } = require('./enumerations')

const getResponsible = async (oRequest, sParentType, oParentHead) => {
    let oResponsible = {}
    if (sParentType === ParentTypes.WORK) {
        if (oParentHead) {
            if (String(oParentHead.responsibleType) === AssignedResponsibleTypes.CELLNEX) {
                oResponsible.isInternal = true
                oResponsible.subcoType = null
                oResponsible.ID = oParentHead.internalResponsible
            } else {
                oResponsible.isInternal = false
                oResponsible.subcoType = oParentHead.externalType
                oResponsible.ID = oParentHead.externalResponsible
            }
        }
    } else if (sParentType === ParentTypes.BLOCK) {
        let oBlockProvision = await SELECT.one.from`project.BlockProvision`.where`ID = ${oParentHead.ID}`
        if (oBlockProvision) {
            if (oBlockProvision.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
                oResponsible.isInternal = true
                oResponsible.subcoType = null
                oResponsible.ID = oBlockProvision.internalResponsible
            } else {
                oResponsible.isInternal = false
                oResponsible.subcoType = oBlockProvision.subcontractorType
                oResponsible.ID = oBlockProvision.externalResponsible
            }
        }
    } else {
        if (oParentHead) {
            if (oParentHead.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
                oResponsible.isInternal = true
                oResponsible.subcoType = null
                oResponsible.ID = oParentHead.internalResponsible
            } else {
                oResponsible.isInternal = false
                oResponsible.subcoType = oParentHead.subcontractorType
                oResponsible.ID = oParentHead.externalResponsible
            }
        }
    }
    return oResponsible
}

const checkBlockStatus = (oRequest, oBlock, sAction) => {
    if (sAction === Actions.ACTION_BLOCK_CLOSE) {
        if (oBlock.BLOCK_STATUS !== BlockStatus.BLOCK_INPROGRESS) {
            oRequest.error(400, 'blockCannotBeClosed')
        }
    } else if (sAction === Actions.ACTION_BLOCK_REOPEN) {
        if (oBlock.BLOCK_STATUS !== BlockStatus.BLOCK_COMPLETED) {
            oRequest.error(400, 'blockCannotBeReopened')
        }
    }
}

const checkPhaseStatus = (oRequest, oPhase, sAction) => {
    if (sAction === Actions.ACTION_PHASE_CLOSE) {
        if (oPhase.PHASE_STATUS !== PhaseStatus.PHASE_INPROGRESS) {
            oRequest.error(400, 'phaseCannotBeClosed')
        }
    }
}

const checkBlocks = async (oRequest, oRequestHead, oPhase) => {
    let aBlocks = []
    try {
        aBlocks = await SELECT.from`BLOCK_HEAD`.where`PHASE_ID = ${oPhase.PHASE_ID}`
        for (let oBlock of aBlocks) {
            let oBlockConfig = await SELECT.one.from`BLOCK`.where`ID_PK = ${oRequestHead.PROCES_ID} and PHASE_ID_PK = ${oPhase.MASTER_PHASE_ID} and BLOCK_ID_PK = ${oBlock.MASTER_BLOCK_ID}`
            if (oBlock.ACTIVATED === true && oBlockConfig.VISIBLE_ON === 'X' && oBlock.BLOCK_STATUS !== BlockStatus.BLOCK_COMPLETED) {
                oRequest.error(400, 'closeBlockFirst', oBlock.MASTER_BLOCK_ID, [oBlock.MASTER_BLOCK_ID])

            }
            await checkBlockDocuments(oRequest, oBlockHead)
        }
    } catch (oError) {
        oRequest.error(400, oError.message)
    }
}

const checkBlockDocuments = async (oRequest, oBlockHead) => {
    try {
        let aDocuments = []
        aDocuments = await SELECT.from`DOCUMENTS_PER_BLOCK`.where`BLOCK_ID = ${oBlockHead.BLOCK_ID} and STATUS = ${DocumentStatus.IN_PROGRESS}`
        if (aDocuments.length > 0) oRequest.error(400, 'documentsInProgress')
    } catch (oError) {
        oRequest.error(400, oError.message)
    }
}

const isLastActiveBlock = async (oEntities, oBlock) => {
    let aBlocks = []
    aBlocks = await SELECT.from`BLOCK_HEAD`.where`PHASE_ID = ${oBlock.PHASE_ID} and ACTIVATED = true and BLOCK_STATUS != ${BlockStatus.BLOCK_COMPLETED}`
    let oPhase = await SELECT.one.from`PHASE_HEAD`.where`PHASE_ID = ${oBlock.PHASE_ID}`

    for (let oBlock of aBlocks) {
        let oBlockConfig = await SELECT.one.from`BLOCK`.where`ID_PK = ${oEntities.PROCESS_ID} and PHASE_ID_PK = ${oPhase.MASTER_PHASE_ID} and BLOCK_ID_PK = ${oBlock.MASTER_BLOCK_ID}`
        if (oBlockConfig.VISIBLE_ON === 'X') {
            return false
        }
    }
    return true
}

const getMasterPhase = async (oRequest, oPhase) => {
    try {
        let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhase.REQUEST_ID}`
        return await SELECT.one.from`PHASE`.where`ID_PK = ${oRequestHead.PROCESS_ID} and PHASE_ID = ${oPhase.MASTER_PHASE_ID}`
    } catch (oError) {
        oRequest.error(400, oError.message)
    }
}

const checkPhaseDependencies = async (oRequest, oPhase) => {
    let aDependencies = []
    let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhase.REQUEST_ID}`
    aDependencies = await SELECT.from`PHASE_DEPENDENCE`.where`ID_PK = ${oRequestHead.processFlowId} and PHASE_ID_PK = ${oPhase.processFlowId}`
    for (let oDependency of aDependencies) {
        let oDepFromPhase = await SELECT.one.from`PHASE_HEAD`.where`MASTER_PHASE_ID = ${oDependency.DEPENDENT_TO_ID_PK} and REQUEST_ID = ${oRequestHead.REQUEST_ID}`
        if (oDepFromPhase.PHASE_STATUS !== PhaseStatus.PHASE_COMPLETED) oRequest.error(400, 'closePhaseFirst', oDepFromPhase.MASTER_PHASE_ID, [oDepFromPhase.MASTER_PHASE_ID])
    }
}

const setPhaseStatus = async (oRequest, status, sId) => {
    if (status === PhaseStatus.PHASE_COMPLETED) {
        await UPDATE`PHASE_HEAD`.set({ 'PHASE_STATUS': status, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id, 'ENDED_AT': oRequest.timestamp }).where`PHASE_ID = ${sId}`
    } else if (status === PhaseStatus.PHASE_INPROGRESS) {
        await UPDATE`PHASE_HEAD`.set({ 'PHASE_STATUS': status, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id, 'STARTED_AT': oRequest.timestamp }).where`PHASE_ID = ${sId}`
    } else {
        await UPDATE`PHASE_HEAD`.set({ 'PHASE_STATUS': status, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id }).where`PHASE_ID = ${sId}`
    }
}

const openNextPhase = async (oRequest, oPhase, oRequestHead) => {
    let oNextPhase
    let aNextPhases = []
    let oReturn = { oNextPhase: null, bFinal: false }

    try {
        // get next Phase
        aNextPhases = await SELECT.from`PHASE`.where`ID_PK = ${oRequestHead.PROCESS_ID}`.orderBy`ORDER`
        for (let i = 0; i < aNextPhases.length; i++) {
            if (aNextPhases[i].PHASE_ID === oPhase.MASTER_PHASE_ID) {
                // we are in current phase
                if (i === aNextPhases.length - 1) {
                    // current is last phase we have to close request
                    oReturn.bFinal = true
                    break
                }
                oNextPhase = await SELECT.one.from`PHASE_HEAD`.where`MASTER_PHASE_ID = ${aNextPhases[i + 1].PHASE_ID} and REQUEST_ID = ${oPhase.REQUEST_ID}`
                if (!await checkSkipRule(aNextPhases[i + 1], oNextPhase)) {
                    if (oNextPhase.PHASE_STATUS === PhaseStatus.PHASE_NOTINITIALIZED) {
                        // open only not initialized phases
                        await setPhaseStatus(oRequest, PhaseStatus.PHASE_INPROGRESS, oNextPhase.PHASE_ID)
                        await openPhaseBlocks(oRequest, oNextPhase, oRequestHead)

                        await openParallelPhases(oRequest, oNextPhase, oRequestHead)
                        //exit from loop
                        break
                    }
                } else {
                    oPhase = oNextPhase
                }
            }
        }
    } catch (oError) {
        oRequest.error(400, oError.message)
    }
    oReturn.oNextPhase = oNextPhase
    return oReturn
}

const checkSkipRule = async (oNextPhase, oPhase) => {
    let bSkip = false
    if (oNextPhase.SKIP_RULE && oNextPhase.SKIP_RULE !== '') {
        let aParts = oNextPhase.SKIP_RULE.split('.')
        let skipRulePhase = aParts[0];
        let skipRuleBlock = aParts[1];
        let aConditionParts = aParts[2].split(' ');
        let skipRuleField = aConditionParts[0];
        let skipRuleOperator = aConditionParts[1];
        let skipRuleValue = aConditionParts[2];

        let oPhaseRule = await SELECT.one.from`PHASE_HEAD`.where`REQUEST_ID = ${oPhase.REQUEST_ID} and MASTER_PHASE_ID = ${skipRulePhase}`
        if (oPhaseRule) {
            let oBlockRule = await SELECT.one.from`BLOCK_HEAD`.where`PHASE_ID = ${oPhaseRule.PHASE_ID} and MASTER_BLOCK_ID = ${skipRuleBlock}`
            if (oBlockRule) {
                let oBlockRuleData = await SELECT.one.from`BLOCKS_PROVISIONING`.where`BLOCK_ID = ${oBlockRule.BLOCK_ID}`
                if (oBlockRuleData) {
                    if (eval(`${oBlockRuleData[skipRuleField]} ${skipRuleOperator} ${skipRuleValue}`)) {
                        bSkip = true
                    }
                }
            }
        }
    }
    return bSkip
}

const openPhaseBlocks = async (oRequest, oPhase, oRequestHead) => {
    try {
        await UPDATE`BLOCK_HEAD`.set({ 'BLOCK_STATUS': BlockStatus.BLOCK_INPROGRESS, 'STARTED_AT': oRequest.timestamp, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id }).where`PHASE_ID = ${oPhase.PHASE_ID} and (MANDATORY = 'X' or ACTIVATED = true) and BLOCK_STATUS = ${BlockStatus.BLOCK_NOTINITIALIZED}`
        await addDefaultDocuments(oRequest, oPhase, null)
    } catch (oError) {
        oRequest.error(400, oError.message)
    }
}

const addDefaultDocuments = async (oRequest, oPhase, oBlock) => {
    let aInprogressBlocks = [];
    let aDocumentsPerBlock = [];
    let aInstancesPerDocument = [];

    if (oBlock) {
        aInprogressBlocks = await SELECT.from`BLOCK_HEAD`
            .where`BLOCK_ID = ${oBlock.ID}`;
        oPhase = await SELECT.one.from`PHASE_HEAD`
            .where`PHASE_ID = ${oBlock.phaseId}`;
    } else {
        aInprogressBlocks = await SELECT.from`BLOCK_HEAD`
            .where`PHASE_ID = ${oPhase.PHASE_ID} and BLOCK_STATUS = ${BlockStatus.BLOCK_INPROGRESS}`;
    }
    let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhase.REQUEST_ID}`
    for (let oInprogresBlock of aInprogressBlocks) {
        let aDocumentConfigs = []
        let aDocumentsPerBlock = []
        let aInstancesPerDocument = []
        aDocumentConfigs = await SELECT.from`DEFAULT_DOCUMENTS_PER_REQUEST_CUSTOMIZING`.where`REQUEST_ID = ${oPhase.REQUEST_ID} and phase = ${oPhase.MASTER_PHASE_ID} and block = ${oInprogresBlock.MASTER_BLOCK_ID} and DELETED != true`
        for (let oDocumentConfig of aDocumentConfigs) {
            let oPreviousDocument = await SELECT.from`REQUEST_ALL_DOCUMENTS(p_requestId: ${oPhase.REQUEST_ID})`.where`GENERIC_TYPE_ID = ${oDocumentConfig.documentId}`
            if (oPreviousDocument.length === 0) {
                let oDocumentsPerBlock = await SELECT.from`DOCUMENTS_PER_BLOCK`.where`BLOCK_ID = ${oInprogresBlock.BLOCK_ID}`
                await addDocumentPerBlockFromDefault(oRequest, oInprogresBlock, null, oDocumentConfig, aDocumentsPerBlock, aInstancesPerDocument, oDocumentConfig.documentId, oDocumentsPerBlock.length + 1, '1', null, null, oRequestHead, true)
            }
        }

        if (aDocumentsPerBlock.length > 0 ) await INSERT.into('DOCUMENTS_PER_BLOCK').entries(aDocumentsPerBlock)
        if (aInstancesPerDocument.length > 0 ) await INSERT.into('INSTANCES_PER_DOCUMENT').entries(aInstancesPerDocument)
    }
}

const addDocumentPerBlockFromDefault = async (oRequest, oBlock, oWork, oDocumentConfig, aDocumentsPerBlock, aInstancesPerDocument, documentId, iOrder, sVersion, oPreviousDocumentPerBlock, oPreviousInstancesPerDocument, oRequestHead, oDefaultDocumentConfig) => {
    let sResponsibleId, sSubcoId, sRespType, bClientValidation, bSubcoValidation, bSiteOwnerValidation, bCellnexValidation
    let ssubcontractorValidator, sSiteOwnerValidator, sCustomerValidator, sCellnexValidator
    let oDocumentsPerBlock = {}
    let oInstancesPerDocument = {}

    let sDefaultResponsible = ''
    if (oDocumentConfig.APPROVER_TYPE == 1 && oRequestHead) sDefaultResponsible = oRequestHead.REQUEST_OWNER_ID
    if (oDocumentConfig.APPROVER_TYPE == 2 && oDocumentConfig.SUBCONTRACTOR == 3 && oRequestHead) {
        let oRequestProvision = SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.REQUEST_ID}`
        sDefaultResponsible = oRequestProvision.preferredProvider
    }
    if (oDocumentConfig.APPROVER_TYPE == 2 && oDocumentConfig.SUBCONTRACTOR == 2 && oRequestHead) sDefaultResponsible = oRequestHead.CUSTOMER_ID
    sResponsibleId = oDocumentConfig.APPROVER_TYPE
    sSubcoId = oDocumentConfig.SUBCONTRACTOR
    sRespType = sDefaultResponsible
    bSubcoValidation = oDocumentConfig.SUBCO_REQ_VAL
    bCellnexValidation = oDocumentConfig.CELLNEX_REQ_VAL
    bClientValidation = oDocumentConfig.CUSTOMER__REQ_VAL
    bSiteOwnerValidation = oDocumentConfig.SITEOWNER_REQ_VAL
        let oRequestProvision = SELECT.one.from`project.RequestProvision`.where`ID = ${oRequestHead.REQUEST_ID}`
    if (bSubcoValidation && oRequestHead && oRequestProvision && oRequestProvision.preferredProvider !== null && oRequestProvision.preferredProvider !== 'null') {
        ssubcontractorValidator = oRequestProvision.preferredProvider
    } else {
        ssubcontractorValidator = null
    }
    if (bSiteOwnerValidation && oRequestHead  && oRequestHead.REQUEST_OWNER_ID !== null && oRequestHead.REQUEST_OWNER_ID !== 'null') {
        sSiteOwnerValidator = oRequestHead.REQUEST_OWNER_ID
        sCellnexValidator = oRequestHead.REQUEST_OWNER_ID
        sCustomerValidator = oRequestHead.REQUEST_OWNER_ID
    } else {
        sSiteOwnerValidator = null
        sCustomerValidator = null
        sCellnexValidator = null
    }
    oDocumentsPerBlock = {
        'RESPONSIBLE_ID': sResponsibleId,
        'SUBCONTRATOR_ID': sSubcoId,
        'T_RESPONSIBLE': sRespType,
        'VALIDATION_CELLNEX_CLIENT': bCellnexValidation ? String(bCellnexValidation) : null ,
        'VALIDATION_REQ_CLIENT':        bClientValidation ? String(bClientValidation) : null ,
        'VALIDATION_SUBCO_CLIENT':      bSubcoValidation ? String(bSubcoValidation) : null ,
        'VALIDATION_SITEOWNER_NEEDED': bSiteOwnerValidation ? String(bSiteOwnerValidation) : null ,
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
        'SUBCONTRACTOR_VALIDATOR':ssubcontractorValidator ? String(ssubcontractorValidator) : null ,
        'SITEOWNER_VALIDATOR':           sSiteOwnerValidator ? String(sSiteOwnerValidator) : null ,
        'CUSTOMER_VALIDATOR':          sCustomerValidator ? String(sCustomerValidator) : null ,
        'CELLNEX_VALIDATOR': sCellnexValidator ? String(sCellnexValidator) : null ,
        'VERSION': sVersion,
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

const openParallelPhases = async (oRequest, oPhase, oRequestHead) => {
    let aParallelPhases = []
    try {
        // get parallel phases from customizing
        aParallelPhases = await SELECT .from `PHASE_PARALLEL` .where `ID_PK = ${oRequestHead.PROCESS_ID} and PHASE_ID_PK = ${oPhase.MASTER_PHASE_ID}`
        for (let oParallelPhase of aParallelPhases) {
            //open parallel phases
            let oNextPhase = await SELECT.one.from`PHASE_HEAD`.where`MASTER_PHASE_ID = ${oParallelPhase.PARALLEL_TO_ID_PK} and REQUEST_ID = ${oPhase.REQUEST_ID}`
            if (oNextPhase.PHASE_STATUS === PhaseStatus.PHASE_NOTINITIALIZED) {
                // open only not initialized phases
                await setPhaseStatus(oRequest, PhaseStatus.PHASE_INPROGRESS, oNextPhase.PHASE_ID)
                await openPhaseBlocks(oRequest, oNextPhase, oRequestHead)
                if (oRequest.errors) return
            }
            //check for parallel phases of current phase
            await openParallelPhases(oRequest, oNextPhase, oRequestHead)
        }
    } catch (oError) {
        oRequest.error(400, oError.message)
    }
}

const setCustomerAsResponsible = async (oRequest, sBlockID) => {
    try {
        let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${sBlockID})`
        let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oEntities.REQUEST_ID}`
        oRequest.data.externalResponsible = oRequestHead.CUSTOMER_ID
    } catch (oError) {
        oRequest.error(400, oError.message)
    }
}

const checkResponsibles = async (oRequest) => {
    let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.data.ID})`
    if ('internalResponsible' in oRequest.data && oRequest.data.internalResponsible !== null && oRequest.data.internalResponsible !== '') {
        let oUsers = []
        oUsers = await SELECT.from`USERS(p_country: ${oEntities.COUNTRY_ID})`.where`userId = ${oRequest.data.internalResponsible}`
        if (oUsers.length === 0) oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/internalResponsible`, [oRequest.data.internalResponsible, 'internalResponsible'])
    }
    if ('externalResponsible' in oRequest.data && oRequest.data.externalResponsible !== null && oRequest.data.externalResponsible !== '') {
        let iSubcotype
        if ('subcontractorType' in oRequest.data) {
            iSubcotype = oRequest.data.subcontractorType
        } else {
            let oBlockProv = await SELECT.one.from`BLOCKS_PROVISIONING`.where`BLOCK_ID = ${oRequest.data.ID}`
            iSubcotype = oBlockProv.SUBCONTRACTOR_TYPE
        }

        switch (iSubcotype) {
            case SubcoTypes.VENDOR:
                let oVendor = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oRequest.data.externalResponsible} and entityType = 'F4_PROV_VENDOR_GEWRK'`
                if (oVendor.length === 0) oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, [oRequest.data.externalResponsible, 'externalResponsible'])
                break
            case SubcoTypes.AGENCY:
                let oAgency = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oRequest.data.externalResponsible} and entityType = 'F4_GEWRK_AGEN'`
                if (oAgency.length === 0) oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, [oRequest.data.externalResponsible, 'externalResponsible'])
                break
            case SubcoTypes.CUSTOMER:
                let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oEntities.REQUEST_ID}`
                if (oRequestHead.CUSTOMER_ID !== oRequest.data.externalResponsible) oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, [oRequest.data.externalResponsible, 'externalResponsible'])
                break
            default:
                oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, [oRequest.data.externalResponsible, 'externalResponsible'])
                break
        }
    }
}

// Parses a $filter string and extracts requestId and optional phaseProcessFlowId
const parseFilter = ($filter) => {
    if (!$filter || $filter.includes(',')) return { error: 'mandatoryFilterRequest' };

    const extract = (name) => {
        const re = new RegExp(`${name}\\s*(?:=|eq)\\s*'?([^'\\s]+)'?`, 'i');
        const match = $filter.match(re);
        return match ? match[1] : undefined;
    };

    const requestId = extract('REQUEST_ID') || extract('requestId');
    const phaseProcessFlowId = extract('phaseProcessFlowId');

    if (!requestId) return { error: 'mandatoryFilterRequest' };
    return { requestId, phaseProcessFlowId };
}

// Attaches ApproverTypes and SubcoTypes to rows and optionally computes field controls
const attachLookups = async (countryId, rows, options = {}) => {
    const computeFieldControls = options.computeFieldControls;

    const approverCodes = Array.from(new Set(rows.map(r => r.approverType).filter(Boolean)));
    const subcoCodes = Array.from(new Set(rows.map(r => r.subcoType).filter(Boolean)));

    const approverTypes = approverCodes.length
        ? await SELECT.from`project.ApproverTypes`.where({ country: countryId, code: { in: approverCodes } })
        : [];
    const subcoTypes = subcoCodes.length
        ? await SELECT.from`project.SubcoTypes`.where({ country: countryId, code: { in: subcoCodes } })
        : [];

    const approverByCode = new Map(approverTypes.map(a => [a.code, a]));
    const subcoByCode = new Map(subcoTypes.map(s => [s.code, s]));

    for (const row of rows) {
        if (typeof computeFieldControls === 'function') {
            Object.assign(row, computeFieldControls(row));
        }
        if (row.approverType) {
            row.ApproverTypes = approverByCode.get(Number(row.approverType)) || null;
        }
        if (row.subcoType) {
            row.SubcoTypes = subcoByCode.get(row.subcoType) || null;
        }
    }

    return rows;
}

const isHidden = (sMasterPhase, sMasterBlock) => {
    return SubcoHiddenBlocks.some(item => item.masterPhase === sMasterPhase && item.masterBlock === sMasterBlock )
}

module.exports = {
    getResponsible,
    checkBlockStatus,
    checkPhaseStatus,
    checkBlockDocuments,
    isLastActiveBlock,
    getMasterPhase,
    checkPhaseDependencies,
    setPhaseStatus,
    openNextPhase,
    setCustomerAsResponsible,
    checkBlocks,
    checkResponsibles,
    parseFilter,
    attachLookups,
    addDefaultDocuments,
    isHidden
}