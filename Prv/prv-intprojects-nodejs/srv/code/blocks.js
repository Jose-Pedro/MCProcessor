
const { RequestStatus, PhaseStatus, BlockStatus, Roles, Actions, DisplayTypesFC, SubcoTypes, AssignedResponsibleTypes, ParentTypes } = require('../utils/enumerations')
const { getDisplayConfiguration, setDisplayConfiguration, setFCAs, checkInputValues, checkEditableFields, checkBlockMandatoryFields } = require('../utils/configurations')
const { ComplexFieldsLogic } = require('../utils/complexlogic')
const { UserCode } = require('./users')
const { checkUserAuth } = require('../utils/userInfo')
const { getResponsible, checkBlockStatus, isLastActiveBlock, checkPhaseDependencies, checkBlockDocuments, setPhaseStatus, openNextPhase, setCustomerAsResponsible, checkResponsibles, parseFilter, attachLookups, addDefaultDocuments, isHidden } = require('../utils/blocks')
const { getSamePhasePopulations, populate } = require('../utils/populator')
const { saveLog, logDocumentEvent } = require('../utils/AuditLogger')
const { checkDocument, checkDocumentId, addDocumentPerBlock, getDefaultParamForBlockDocument } = require('../utils/documentsperblock')
const { activateBlockWorks, checkWorksStatus } = require('../utils/works')
const { checkMandatoryChecklistItems } = require('../utils/checklists')

class BlocksCode {

    beforeUpdateBlock = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.data.ID})`
            let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`
            if ('agoraCurrentUserData' in oRequest && 'hasNoCountry' in oRequest.agoraCurrentUserData && oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
            if ('agoraCurrentUserData' in oRequest && 'isMultiCountry' in oRequest.agoraCurrentUserData && oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
            if ('agoraCurrentUserData' in oRequest && 'country' in oRequest.agoraCurrentUserData && oRequest.agoraCurrentUserData.country !== oRequestHead.country) oRequest.error(401, 'notAuthorizedCountry')
            if (oRequest.errors) return

            let oBlockHead = await SELECT.one.from`project.Blocks`.where`ID = ${oRequest.data.ID}`
            let oBlockProvision = await SELECT.one.from`project.BlockProvision`.where`ID = ${oRequest.data.ID}`
            let sResponsible = oBlockProvision.subcontractorType === 0 ? oBlockProvision.internalResponsible : oBlockProvision.externalResponsible
            await checkUserAuth(oRequest, oBlockHead.role, sResponsible)

            if (oBlockHead.status === BlockStatus.BLOCK_COMPLETED) {
                await checkBlockMandatoryFields(oRequest, oBlockHead, oBlockProvision)
                if (oRequest.errors) return
            }

            await checkInputValues(oRequest)
            await checkEditableFields(oRequest, oEntities.PROCESS_ID, 'BLOCK_HEAD', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, false)

            // modify status and create defaulted documents
            if (oRequest.data && 'activated' in oRequest.data) {
                if (oRequest.data.activated === true) {
                    oRequest.data.status = BlockStatus.BLOCK_INPROGRESS
                    oRequest.data.openAt = oRequest.timestamp.toJSON()
                    await activateBlockWorks(oRequest.data.ID)
                    let oPhase = await SELECT.one.from`PHASE_HEAD`.where`PHASE_ID = ${oEntities.PHASE_ID}`
                    await addDefaultDocuments(oRequest, oPhase, oBlockHead)
                } else {
                    oRequest.data.status = BlockStatus.BLOCK_NOTINITIALIZED
                    oRequest.data.openAt = null
                }
            }
        } catch (oError) {

        }
    }

    afterReadBlock = async (aResult, oRequest) => {
        if (aResult.constructor !== Array) aResult = [aResult]
        try {
            await UserCode.currentUserDetails(oRequest)
            for (let oResult of aResult) {
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oResult.ID})`
                if (!oEntities) continue
                let oConfiguration = await getDisplayConfiguration(oRequest, oEntities.PROCESS_ID, 'BLOCK_HEAD', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, false)
                let oBlockResponsible = await getResponsible(oRequest, ParentTypes.BLOCK, oResult)
                let hasDocFlowParam = await SELECT.one.from`project.DocumentsPerProcess`.where`phaseProcessFlowId = ${oEntities.MASTER_PHASE_ID} and blockProcessFlowId = ${oEntities.MASTER_BLOCK_ID} and processFlowId = ${oEntities.PROCESS_ID}`
                let hasDPBEntrie = await SELECT.one.from`project.DocumentsPerBlocks`.where`blockId = ${oResult.ID}`
                let hasWorkConfig = await SELECT.one.from`WORK_CONFIG_BY_PROCESS`.where`processFlowId = ${oEntities.PROCESS_ID} and phaseTypeId  = ${oEntities.MASTER_PHASE_ID} and blockTypeId = ${oEntities.MASTER_BLOCK_ID}`
                let hasWorks = await SELECT.one.from`WORKS`.where`PARENTID = ${oResult.ID}`
                let hasChecklistConfig = await SELECT.one.from`Checklist.ItemTypesPerBlock`.where`active != false and activeType != false and processId = ${oEntities.PROCESS_ID} and phaseType = ${oEntities.MASTER_PHASE_ID} and blockType = ${oEntities.MASTER_BLOCK_ID}`
                let hasChecklist = await SELECT.one.from`Checklist.Item`.where`block_ID = ${oResult.ID}`
                oResult.dpbVisibleVF = (hasDocFlowParam !== undefined || hasDPBEntrie !== undefined)
                oResult.worksVisibleVF = (hasWorkConfig !== undefined || hasWorks !== undefined)
                oResult.checklistVisibleVF = (hasChecklist !== undefined || hasChecklistConfig !== undefined)
                if ('BlockProvision' in oResult) {
                    let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`
                    let oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oEntities.REQUEST_ID}`;
                    if (oRequestHead && oRequestHead.manager && oResult.BlockProvision.assignedResponsible === AssignedResponsibleTypes.CELLNEX && oResult.BlockProvision.internalResponsible === null) {
                        await UPDATE`BLOCKS_PROVISIONING`.set({ 'RESPONSIBLE_PERSON': oRequestHead.manager }).where`BLOCK_ID = ${oResult.ID}`
                        oResult.BlockProvision.internalResponsible = oRequestHead.manager
                    } else if (oRequestProvision && oRequestProvision.preferredProvider && oResult.BlockProvision.externalResponsible === null && (oResult.BlockProvision.subcontractorType === SubcoTypes.VENDOR || oResult.BlockProvision.subcontractorType === null) && oResult.BlockProvision.assignedResponsible === AssignedResponsibleTypes.EXTERNAL) {
                        await UPDATE`BLOCKS_PROVISIONING`.set({ 'PROVIDER_NAME': oRequestProvision.preferredProvider, 'SUBCONTRACTOR_TYPE': SubcoTypes.VENDOR }).where`BLOCK_ID = ${oResult.ID}`
                        oResult.BlockProvision.externalResponsible = oRequestProvision.preferredProvider;
                    }

                    oResult.BlockProvision.newUploadTableEnabled = false;
                    await this.#enableNewUploadTableFeature(oResult.BlockProvision);
                }

                let bAllAuth = oRequest.user.is(Roles.MANAGER_USER_ROL) ||
                    (oRequest.user.id === oBlockResponsible.ID && oBlockResponsible.isInternal && oRequest.user.is(Roles.CELLNEX_USER_ROL)) || // internal user assigned to block
                    (oRequest.user.is(aResult.role)) || //User has block role
                    (!oBlockResponsible.isInternal && (oBlockResponsible.ID === oRequest.agoraCurrentUserData.vendor || oBlockResponsible.ID === oRequest.agoraCurrentUserData.agency))

                if (bAllAuth) {
                    setDisplayConfiguration(oRequest, oResult, oConfiguration, oRequest.target.elements)
                    ComplexFieldsLogic.setVisibilityForEntity(false, oEntities, oResult, null)
                    if ('BlockProvision' in oResult) {
                        oConfiguration = await getDisplayConfiguration(oRequest, oEntities.PROCESS_ID, 'BLOCKS_PROVISIONING', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, false)
                        setDisplayConfiguration(oRequest, oResult.BlockProvision, oConfiguration, oRequest.target.elements.BlockProvision._target.elements)
                        //set screen control for fields with complex logic
                        if ('currencyFC' in oResult.BlockProvision && (oResult.BlockProvision.currencyFC === DisplayTypesFC.OPTIONAL || oResult.BlockProvision.currencyFC === DisplayTypesFC.MANDATORY) && 'currency' in oResult.BlockProvision && oResult.BlockProvision.currency === null) {
                            await UPDATE`BLOCKS_PROVISIONING`.set({ 'CURRENCY': 'EUR' }).where`BLOCK_ID = ${oResult.ID}`
                            oResult.BlockProvision.currency = 'EUR'
                        }
                        ComplexFieldsLogic.setVisibilityForEntity(false, oEntities, oResult, oResult.BlockProvision)
                        if (oRequest.user.is(Roles.MANAGER_USER_ROL)) {
                            oResult.BlockProvision.assignedResponsibleFC = DisplayTypesFC.OPTIONAL
                            if (oResult.BlockProvision.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
                                oResult.BlockProvision.subcontractorTypeFC = DisplayTypesFC.HIDDEN
                                oResult.BlockProvision.externalResponsibleFC = DisplayTypesFC.HIDDEN
                                oResult.BlockProvision.internalResponsibleFC = DisplayTypesFC.OPTIONAL
                            } else {
                                oResult.BlockProvision.subcontractorTypeFC = DisplayTypesFC.MANDATORY
                                if (oResult.BlockProvision.subcontractorType !== 0 && oResult.subcontractorType !== null) {
                                    oResult.BlockProvision.externalResponsibleFC = DisplayTypesFC.MANDATORY
                                } else {
                                    oResult.BlockProvision.externalResponsibleFC = DisplayTypesFC.OPTIONAL
                                }
                                oResult.BlockProvision.internalResponsibleFC = DisplayTypesFC.HIDDEN
                            }
                        } else {
                            oResult.BlockProvision.assignedResponsibleFC = DisplayTypesFC.READONLY
                            // for external users this fields are readonly                        
                            if (oResult.BlockProvision.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
                                oResult.BlockProvision.subcontractorTypeFC = DisplayTypesFC.HIDDEN
                                oResult.BlockProvision.externalResponsibleFC = DisplayTypesFC.HIDDEN
                                oResult.BlockProvision.internalResponsibleFC = DisplayTypesFC.READONLY
                            } else {
                                oResult.BlockProvision.subcontractorTypeFC = DisplayTypesFC.READONLY
                                if (oResult.BlockProvision.subcontractorType !== 0 && oResult.BlockProvision.subcontractorType !== null) oResult.BlockProvision.externalResponsibleFC = DisplayTypesFC.READONLY
                                oResult.BlockProvision.internalResponsibleFC = DisplayTypesFC.HIDDEN
                            }
                            if (oEntities.siteId !== null && oEntities.siteId !== '') oResult.BlockProvision.chosenFC = DisplayTypesFC.READONLY
                        }
                    }
                } else {
                    if ('BlockProvision' in oResult) {
                        oResult.BlockProvision.newUploadTableEnabled = false;
                        await this.#enableNewUploadTableFeature(oResult.BlockProvision);
                    }
                    if (isHidden(oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID)) {
                        setFCAs(oRequest, oResult, DisplayTypesFC.HIDDEN)
                    } else {
                        setFCAs(oRequest, oResult, DisplayTypesFC.READONLY)
                    }
                }
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    beforeCloseBlock = async (oRequest) => {
        if (oRequest.params && oRequest.params.length === 1) {
            try {
                await UserCode.currentUserDetails(oRequest)
                let oBlockHead = await SELECT.one.from`project.Blocks`.where`ID = ${oRequest.params[0]}`
                if (oBlockHead && oBlockHead.activated === true) {
                    let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.params[0]})`
                    if (oEntities.COUNTRY_ID !== oRequest.agoraCurrentUserData.country) oRequest.reject(401, 'notAuthorizedCountry', 'country', [oEntities.COUNTRY_ID])
                    let oBlockProvision = await SELECT.one.from`project.BlockProvision`.where`ID = ${oRequest.params[0]}`
                    let sResponsible = oBlockProvision.subcontractorType === 0 ? oBlockProvision.internalResponsible : oBlockProvision.externalResponsible
                    await checkUserAuth(oRequest, oBlockHead.role, sResponsible)
                    //validate mandatory fields for blocks
                    await checkBlockMandatoryFields(oRequest, oBlockHead, oBlockProvision)
                    await checkMandatoryChecklistItems(oRequest, oBlockHead.ID)
                    await checkWorksStatus(oRequest, oBlockHead.ID)
                    let oBlockHeadCellnex = await SELECT.one.from`BLOCK_HEAD`.where`BLOCK_ID = ${oRequest.params[0]}`
                    await checkBlockDocuments(oRequest, oBlockHeadCellnex)
                    if (oRequest.errors) return
                } else {
                    oRequest.error(400, 'notActiveBlock')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingBlockId')
        }
    }

    onCloseBlock = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                let oBlock = await SELECT.one.from`BLOCK_HEAD`.where`BLOCK_ID = ${oRequest.params[0]}`
                if (oBlock) {
                    checkBlockStatus(oRequest, oBlock, Actions.ACTION_BLOCK_CLOSE)
                    if (oRequest.errors) return
                    await populate(oBlock)
                    await UPDATE`BLOCK_HEAD`.set({ 'BLOCK_STATUS': BlockStatus.BLOCK_COMPLETED, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id, 'ENDED_AT': oRequest.timestamp }).where`BLOCK_ID = ${oBlock.BLOCK_ID}`
                    await UPDATE`BLOCKS_PROVISIONING`.set({ 'COMPLETED_DATE': oRequest.timestamp, 'COMPLETED_BY': oRequest.user.id, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id }).where`BLOCK_ID = ${oBlock.BLOCK_ID}`
                    let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.params[0]})`
                    if (await isLastActiveBlock(oEntities, oBlock)) {
                        //close phase on last block
                        let oPhase = await SELECT.one.from`PHASE_HEAD`.where`PHASE_ID = ${oBlock.PHASE_ID}`
                        if (oRequest.errors) return
                        await checkPhaseDependencies(oRequest, oPhase)
                        if (oRequest.errors) return
                        await setPhaseStatus(oRequest, PhaseStatus.PHASE_COMPLETED, oPhase.PHASE_ID)
                        // open next Phases
                        let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhase.REQUEST_ID}`
                        let oNextPhase = await openNextPhase(oRequest, oPhase, oRequestHead)
                        if (oRequest.errors) return
                        // get Open Phases
                        let openPhases = []
                        openPhases = await SELECT.from`PHASE_HEAD`.where`REQUEST_ID = ${oRequestHead.REQUEST_ID} and PHASE_STATUS = 7`

                        if (openPhases.length < 1) {
                            let oConfirmButtons = await SELECT.one.from`CONFIRM_BUTTONS(p_requestId : ${oRequestHead.REQUEST_ID}, p_master_phase_id : 'finalValidation', p_master_block_id : 'validDocument')`;
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



                            } else {
                                await UPDATE`REQUEST_HEAD`.set({ 'REQUEST_STATUS': RequestStatus.REQUEST_COMPLETED, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id, 'ENDED_AT': oRequest.timestamp }).where`REQUEST_ID = ${oRequestHead.REQUEST_ID}`

                                oRequest.reply(Actions.ACTION_REQUEST_COMPLETED)
                            }

                        } else {
                            // still remaining phases actives                                                        
                            if (oNextPhase.bFinal) {
                                // Last phase stay on it
                                oRequest.reply(oPhase.MASTER_PHASE_ID)
                            } else {
                                // other phase, go to next phase
                                oRequest.reply(oNextPhase.oNextPhase.MASTER_PHASE_ID)
                            }
                        }
                    } else {
                        oRequest.reply(await getSamePhasePopulations(oBlock))
                    }
                } else {
                    oRequest.error(400, 'blockNotFound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingBlockId')
        }
    }

    onReopenBlock = async (oRequest) => {
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                await UserCode.currentUserDetails(oRequest)
                let oBlock = await SELECT.one.from`BLOCK_HEAD`.where`BLOCK_ID = ${oRequest.params[0]}`
                if (oBlock) {
                    checkBlockStatus(oRequest, oBlock, Actions.ACTION_BLOCK_REOPEN)
                    if (oRequest.errors) return
                    await UPDATE`BLOCK_HEAD`.set({ 'BLOCK_STATUS': BlockStatus.BLOCK_INPROGRESS, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id, 'ENDED_AT': oRequest.timestamp }).where`BLOCK_ID = ${oBlock.BLOCK_ID}`
                    let oPhase = await SELECT.one.from`PHASE_HEAD`.where`PHASE_ID = ${oBlock.PHASE_ID}`
                    if (oPhase.PHASE_STATUS !== PhaseStatus.PHASE_INPROGRESS) await UPDATE`PHASE_HEAD`.set({ 'PHASE_STATUS': PhaseStatus.PHASE_INPROGRESS, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id }).where({ 'PHASE_ID': oBlock.PHASE_ID })
                } else {
                    oRequest.error(400, 'blockNotFound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingBlockId')
        }
    }

    onAddDocumentPerBlock = async (oRequest) => {
        if ('documentId' in oRequest.data && oRequest.params.constructor === Array && oRequest.params.length > 0 && oRequest.data.documentId !== '' && oRequest.data.documentId !== null) {
            try {
                if (oRequest.errors) return
                let oBlock = await SELECT.one.from`BLOCK_HEAD`.where`BLOCK_ID = ${oRequest.params[0]}`
                let oPhase = await SELECT.one.from`PHASE_HEAD`.where`PHASE_ID = ${oBlock.PHASE_ID}`
                let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhase.REQUEST_ID}`
                let oDocumentsPerBlock = await SELECT.from`DOCUMENTS_PER_BLOCK`.where`BLOCK_ID = ${oRequest.params[0]}`
                if (oRequestHead) {
                    await checkDocumentId(oRequest, oRequestHead.PROCESS_ID, oPhase.MASTER_PHASE_ID, oBlock.MASTER_BLOCK_ID, oRequest.data.documentId)
                    if (oRequest.errors) return
                    await checkDocument(oRequest, oPhase.REQUEST_ID, oRequest.data.documentId)
                    if (oRequest.errors) return
                    let aDocumentsPerBlock = []
                    let aInstancesPerDocument = []
                    let oDefaultDocumentConfig = false
                    let oDocumentConfig = await SELECT.one.from`DEFAULT_DOCUMENTS_PER_REQUEST_CUSTOMIZING`.where`REQUEST_ID = ${oPhase.REQUEST_ID} and phase = ${oPhase.MASTER_PHASE_ID} and block = ${oBlock.MASTER_BLOCK_ID} and documentId = ${oRequest.data.documentId} and DELETED != true`;
                    if (oDocumentConfig === undefined || oDocumentConfig.length === 0) {
                        oDocumentConfig = await getDefaultParamForBlockDocument(oRequest, oRequest.params[0], oRequest.data.documentId)
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
                            requestId: oRequestHead.REQUEST_ID,
                            blockId: oBlock.BLOCK_ID,
                            masterBlockId: oBlock.MASTER_BLOCK_ID,
                            phaseId: oPhase.PHASE_ID,
                            masterPhaseId: oPhase.MASTER_PHASE_ID,
                            requestType: oRequestHead.REQUEST_TYPE
                        }
                    )
                    //-- add log  end

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

    afterReadBlockProvision = async (aResult, oRequest) => {
        if (aResult.constructor !== Array) aResult = [aResult]
        try {
            for (let oResult of aResult) {

                oResult.newUploadTableEnabled = false;
                await this.#enableNewUploadTableFeature(oResult);
                let oBlockHead = await SELECT.one.from`project.Blocks`.where`ID = ${oResult.ID}`
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oResult.ID})`
                if (!oEntities) continue
                let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`
                let oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oEntities.REQUEST_ID}`;
                if (oRequestHead && oResult.assignedResponsible === AssignedResponsibleTypes.CELLNEX && oResult.internalResponsible === null) {
                    oResult.internalResponsible = oRequestHead.manager
                } else if (oRequestProvision && parseInt(oResult.subcontractorType, 10) === parseInt(SubcoTypes.VENDOR, 10) && oResult.internalResponsible === null) {

                    oResult.externalResponsible = oRequestProvision.preferredProvider;
                }

                let oBlockResponsible = await getResponsible(oRequest, ParentTypes.BLOCK, oResult)
                let bAllAuth = oRequest.user.is(Roles.MANAGER_USER_ROL) ||
                    (oRequest.user.id === oBlockResponsible.ID && oBlockResponsible.isInternal && oRequest.user.is(Roles.CELLNEX_USER_ROL)) || // internal user assigned to block
                    (oRequest.user.is(oBlockHead.role)) || //User has block role
                    (!oBlockResponsible.isInternal && (oBlockResponsible.ID === oRequest.agoraCurrentUserData.vendor || oBlockResponsible.ID === oRequest.agoraCurrentUserData.agency)) //User has block role

                if (bAllAuth) {
                    let oConfiguration = await getDisplayConfiguration(oRequest, oEntities.PROCESS_ID, 'BLOCKS_PROVISIONING', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, false)
                    setDisplayConfiguration(oRequest, oResult, oConfiguration, oRequest.target.elements)
                    ComplexFieldsLogic.setVisibilityForEntity(false, oEntities, null, oResult)

                    if (oRequest.user.is(Roles.MANAGER_USER_ROL)) {
                        oResult.assignedResponsibleFC = DisplayTypesFC.OPTIONAL
                        if (oResult.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
                            oResult.subcontractorTypeFC = DisplayTypesFC.HIDDEN
                            oResult.externalResponsibleFC = DisplayTypesFC.HIDDEN
                            oResult.internalResponsibleFC = DisplayTypesFC.OPTIONAL
                        } else {
                            oResult.subcontractorTypeFC = DisplayTypesFC.MANDATORY
                            if (oResult.subcontractorType !== 0 && oResult.subcontractorType !== null) {
                                oResult.externalResponsibleFC = DisplayTypesFC.MANDATORY
                            } else {
                                oResult.externalResponsibleFC = DisplayTypesFC.OPTIONAL
                            }
                            oResult.internalResponsibleFC = DisplayTypesFC.HIDDEN
                        }
                        // if (oEntities.siteId !== null && oEntities.siteId !== '') oResult.BlockProvision.chosenFC = DisplayTypesFC.READONLY
                    } else {
                        oResult.assignedResponsibleFC = DisplayTypesFC.READONLY
                        // for external users this fields are readonly                        
                        if (oResult.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
                            oResult.subcontractorTypeFC = DisplayTypesFC.HIDDEN
                            oResult.externalResponsibleFC = DisplayTypesFC.HIDDEN
                            oResult.internalResponsibleFC = DisplayTypesFC.READONLY
                        } else {
                            oResult.subcontractorTypeFC = DisplayTypesFC.READONLY
                            if (oResult.subcontractorType !== 0 && oResult.subcontractorType !== null) oResult.externalResponsibleFC = DisplayTypesFC.READONLY
                            oResult.internalResponsibleFC = DisplayTypesFC.HIDDEN
                        }
                    }
                    //set if new upload table feature is enabled
                } else {
                    if (isHidden(oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID)) {
                        setFCAs(oRequest, oResult, DisplayTypesFC.HIDDEN)
                    } else {
                        setFCAs(oRequest, oResult, DisplayTypesFC.READONLY)
                    }
                }
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    beforeUpdateBlockProvision = async (oRequest) => {
        if (oRequest.params && oRequest.params.length > 0) {
            try {
                await UserCode.currentUserDetails(oRequest)
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.data.ID})`
                let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`
                if ('agoraCurrentUserData' in oRequest && 'hasNoCountry' in oRequest.agoraCurrentUserData && oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
                if ('agoraCurrentUserData' in oRequest && 'isMultiCountry' in oRequest.agoraCurrentUserData && oRequest.agoraCurrentUserData.isMultiCountry) oRequest.error(401, 'notAuthorizedMultiCountry')
                if ('agoraCurrentUserData' in oRequest && 'country' in oRequest.agoraCurrentUserData && oRequest.agoraCurrentUserData.country !== oRequestHead.country) oRequest.error(401, 'notAuthorizedCountry')

                let oBlockHead = await SELECT.one.from`project.Blocks`.where`ID = ${oRequest.data.ID}`
                let oBlockProvision = await SELECT.one.from`project.BlockProvision`.where`ID = ${oRequest.data.ID}`
                let sResponsible = oBlockProvision.subcontractorType === 0 ? oBlockProvision.internalResponsible : oBlockProvision.externalResponsible
                await checkUserAuth(oRequest, oBlockHead.role, sResponsible)

                //this check always has to be done before blocks responsibles checks
                await checkInputValues(oRequest)
                if (oBlockHead.status === BlockStatus.BLOCK_COMPLETED) {
                    await checkBlockMandatoryFields(oRequest, oBlockHead, oBlockProvision)
                    if (oRequest.errors) return
                }

                await saveLog(oRequest, 'project.Blocks');

                if (oRequest.data && 'realStateFeasibility' in oRequest.data) {
                    if (oRequest.data.realStateFeasibility === 2 || oRequest.data.realStateFeasibility === 3) oRequest.data.realEstateFeasibilityExp = null
                }
                if (oRequest.data && 'assignedResponsible' in oRequest.data) {
                    if (oRequest.data.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
                        oRequest.data.subcontractorType = null
                        oRequest.data.externalResponsible = null
                    } else {
                        //NOSONAR oRequest.data.internalResponsible = null
                        oRequest.data.subcontractorType = SubcoTypes.VENDOR
                        let oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oEntities.REQUEST_ID}`
                        if (oRequestProvision) oRequest.data.externalResponsible = oRequestHead.preferredProvider
                    }
                }
                if (oRequest.data && 'subcontractorType' in oRequest.data) {
                    oRequest.data.externalResponsible = null
                    if (oRequest.data.subcontractorType === SubcoTypes.CUSTOMER) await setCustomerAsResponsible(oRequest, oRequest.params[0])
                }
                let oRequestProvision
                if (oRequest.data && "subcontractorType" in oRequest.data) {
                    oRequest.data.externalResponsible = null;
                    if (oRequest.data.subcontractorType === SubcoTypes.CUSTOMER) await setCustomerAsResponsible(oRequest, oRequest.params[0])
                    if (parseInt(oRequest.data.subcontractorType, 10) === parseInt(SubcoTypes.VENDOR, 10)) {

                        oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oEntities.REQUEST_ID}`;
                        if (oRequestProvision) oRequest.data.externalResponsible = oRequestProvision.preferredProvider;
                    }
                }
                if (oRequest.data && "assignedResponsible" in oRequest.data) {
                    if (parseInt(oRequest.data.assignedResponsible, 10) === parseInt(AssignedResponsibleTypes.CELLNEX, 10)) {
                        if (oRequestHead) oRequest.data.responsiblePerson = oRequestHead.manager;
                        oRequest.data.subcontractorType = null;
                        oRequest.data.externalResponsible = null;
                        oRequest.data.responsibleCoordinator = null;
                    } else if (parseInt(oRequest.data.assignedResponsible, 10) === parseInt(SubcoTypes.VENDOR, 10)) {
                        oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oEntities.REQUEST_ID}`;
                        if (oRequestProvision) oRequest.data.externalResponsible = oRequestProvision.preferredProvider;
                        oRequest.data.subcontractorType = SubcoTypes.VENDOR;
                    } else {
                        oRequest.data.responsiblePerson = null;
                    }
                }
                if (oRequest.data && !('assignedResponsible' in oRequest.data) && !('subcontractorType' in oRequest.data)) await checkResponsibles(oRequest)
                await checkEditableFields(oRequest, oEntities.PROCESS_ID, 'BLOCKS_PROVISIONING', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, true)
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingBlockId')
        }
    }

    /************** Block Responsibles handlers **************/

    computeFieldControls = ({ status, approverType, subcoType }) => {
        const isEditable =
            status === BlockStatus.BLOCK_INPROGRESS ||
            status === BlockStatus.BLOCK_NOTINITIALIZED;

        if (!isEditable) {
            return {
                approverTypeFC: DisplayTypesFC.READONLY,
                subcoTypeFC: DisplayTypesFC.READONLY,
                externalResponsibleFC: DisplayTypesFC.READONLY,
                internalResponsibleFC: DisplayTypesFC.READONLY,
            };
        }

        if (approverType === AssignedResponsibleTypes.CELLNEX) {
            return {
                approverTypeFC: DisplayTypesFC.OPTIONAL,
                subcoTypeFC: DisplayTypesFC.READONLY,
                externalResponsibleFC: DisplayTypesFC.READONLY,
                internalResponsibleFC: DisplayTypesFC.OPTIONAL,
            };
        }

        return {
            approverTypeFC: DisplayTypesFC.OPTIONAL,
            subcoTypeFC: DisplayTypesFC.OPTIONAL,
            externalResponsibleFC:
                subcoType === SubcoTypes.CUSTOMER
                    ? DisplayTypesFC.READONLY
                    : DisplayTypesFC.OPTIONAL,
            internalResponsibleFC: DisplayTypesFC.READONLY,
        };
    }

    onReadBlocksResponsibles = async (oRequest) => {
        const $filter = oRequest._queryOptions?.$filter;
        const { error, requestId, phaseProcessFlowId } = parseFilter($filter);
        if (error) return oRequest.error(400, error);

        try {
            const requestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${requestId}`;
            if (!requestHead) return oRequest.error(404, 'requestNotFound');

            const cql = cds.parse.cql(
                `SELECT FROM BLOCKS_RESPONSIBLES(p_requestId: '${requestId}')`
            );
            if (phaseProcessFlowId) {
                cql.SELECT.where = ['phaseProcessFlowId', '=', { val: phaseProcessFlowId }];
            }

            const rows = await cds.run(cql);
            const enriched = await attachLookups(
                requestHead.COUNTRY_ID,
                rows,
                { computeFieldControls: this.computeFieldControls }
            );
            return oRequest.reply(enriched);
        } catch (e) {
            return oRequest.error(400, e.message);
        }
    }

    afterReadBlocksResponsibles = async (oResults, oRequest) => {

        await UserCode.currentUserDetails(oRequest)
        let userId = oRequest.user.id;
        let aResults = oResults.constructor === Array ? oResults : [oResults]
        for (let oResult of aResults) {
            let oParent = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oResult.ID})`


            await this.getBlocksResponsiblesResponsibleDescriptions(userId, oResult)
        }


    }

    getBlocksResponsiblesResponsibleDescriptions = async (userId, oResult) => {
        if (oResult.internalResponsible) {
            if (oResult.approverType === AssignedResponsibleTypes.CELLNEX) {
                if (oResult.internalResponsible && oResult.internalResponsible !== '') {
                    let oUser = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oResult.internalResponsible}`
                    oResult.internalResponsibleName = oUser ? oUser.USER_NAME : null
                }
            }
        }
        if (oResult.externalResponsible) {
            switch (parseInt(oResult.subcoType, 10)) {
                case SubcoTypes.VENDOR:
                    if (oResult.externalResponsible) {
                        let oVendor = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${userId} and code = ${oResult.externalResponsible} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                        oResult.externalResponsibleName = oVendor ? oVendor.name : null
                    }
                    break
                case SubcoTypes.AGENCY:
                    if (oResult.externalResponsible) {
                        let oAgency = await SELECT.one.from`project.CacheR3Entities`.where`userId = ${userId} and code = ${oResult.externalResponsible} and entityType = 'F4_GEWRK_AGEN'`;
                        oResult.externalResponsibleName = oAgency ? oAgency.name : null
                    }
                    break
                case SubcoTypes.CUSTOMER:
                    oResult.externalResponsibleName = null
                    break
            }
        }

    }

    beforeUpdateBlocksResponsibles = async (oRequest) => {
        const data = oRequest.data || {};

        if ('approverType' in data) {
            if (data.approverType === AssignedResponsibleTypes.CELLNEX) {
                data.subcoType = null;
                data.externalResponsible = null;
            } else {
                data.internalResponsible = null;
            }
        }

        if ('subcoType' in data) {
            data.externalResponsible = null;
        }

        await checkInputValues(oRequest);
        await checkResponsibles(oRequest);
    }

    onUpdateBlocksResponsibles = async (oRequest) => {
        if (!oRequest.params || oRequest.params.length !== 1) {
            return oRequest.error(400, 'missingId');
        }

        try {
            const blockId = oRequest.data.ID;
            const head = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${blockId})`;
            if (!head || !head.REQUEST_ID) return oRequest.error(404, 'requestNotFound');

            const fieldMap = {
                approverType: 'ASSIGNED_RESPONSIBLE',
                subcoType: 'SUBCONTRACTOR_TYPE',
                externalResponsible: 'PROVIDER_NAME',
                internalResponsible: 'RESPONSIBLE_PERSON',
            };

            const updatePayload = {};
            for (const [key, value] of Object.entries(oRequest.data)) {
                const mappedKey = fieldMap[key];
                if (mappedKey !== undefined) updatePayload[mappedKey] = value ?? null;
            }

            if (Object.keys(updatePayload).length > 0) {
                await UPDATE.entity('BLOCKS_PROVISIONING')
                    .set(updatePayload)
                    .where({ BLOCK_ID: blockId });
            }

            const refreshed = await cds.run(
                cds.parse.cql(
                    `SELECT FROM BLOCKS_RESPONSIBLES(p_requestId: '${head.REQUEST_ID}')`
                )
            );
            return oRequest.reply(refreshed);
        } catch (e) {
            return oRequest.error(400, e.message);
        }
    }

    #enableNewUploadTableFeature = async (oBlockProvision) => {
        try {
            //get request country

            const blockId = oBlockProvision.ID;
            const oRequestHead = await this.#getRequestHeadByBlockId(blockId);
            //get user country
            if (oRequestHead) {
                const country = oRequestHead.COUNTRY_ID;
                //get business switch for subcos
                const company = "";
                const oBusinessSwitch = await this.getBusinessSwitchFromDB("PRV_REQ_ENABLE_NEW_UPLOAD", country, company);
                //check if switch is active
                if (oBusinessSwitch[0].ACTIVE) {
                    oBlockProvision.newUploadTableEnabled = true;
                }
            }
        }
        catch (oError) {
            // local-dev: GET_ACTIVE_BUSINESS_SWITCH procedure not deployed in HXE; treat as switch inactive
            console.warn('[#enableNewUploadTableFeature] business switch unavailable, defaulting to disabled:', oError.message)
        }
    }

    #getRequestHeadByBlockId = async (blockId) => {
        try {
            const sql = `SELECT TOP 1 RH.* FROM REQUEST_HEAD AS RH
              INNER JOIN PHASE_HEAD AS PH ON PH.REQUEST_ID = RH.REQUEST_ID
              INNER JOIN BLOCK_HEAD AS BH ON BH.PHASE_ID = PH.PHASE_ID
              WHERE BH.BLOCK_ID = '${blockId}'`;
            const results = await cds.run(sql);
            return (results.length) ? results[0] : null;
        }
        catch (error) {
            throw new Error("Error in getRequestHeadByBlockId: " + error);
        }
    }

    /**
     * @async
     * @method getBusinessSwitchFromDB
     * @description Fetches a business switch configuration from the database based on the provided parameters.
     *              It also caches the retrieved data for future use.
     * @param {string} businessSwitch - The code of the business switch to retrieve.
     * @param {string} country - The country code associated with the business switch.
     * @param {string} company - The company code associated with the business switch.
     * @returns {Promise<Array<object>>} A promise that resolves to an array of business switch configuration objects.
     * @throws {Error} Throws an error if there is an issue querying the database.
     * @private
     */
    getBusinessSwitchFromDB = async (businessSwitch, country, company) => {
        // Define the CQL query to fetch the business switch
        const oQuery = {
            SELECT: {
                from: {
                    ref: [
                        {
                            id: 'GET_ACTIVE_BUSINESS_SWITCH', // Name of the database view/function
                            args: {
                                country: { val: country },
                                companyCode: { val: company },
                                switch: { val: businessSwitch },
                            },
                        },
                    ],
                },
                columns: ['*'], // Select all columns
            },
        };

        try {
            // Execute the query
            const aResult = await cds.run(oQuery);

            return aResult;
        } catch (error) {
            throw new Error(`Error in getting Business Switch ${businessSwitch} for country ${country}` + error);
        }
    };

}

module.exports = {
    BlocksCode
}