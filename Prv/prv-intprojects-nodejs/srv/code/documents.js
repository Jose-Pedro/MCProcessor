const { BlockStatus, DocumentStatus, GlobalConstants, Actions } = require('../utils/enumerations')
const { removeDocumentFromOT, sendDocumenttoOT } = require('../utils/documents')
const { logDocumentEvent } = require('../utils/AuditLogger')

class DocumentsCode {

    onCreateDocument = async (oRequest) => {
        let aDocuments = []
        let oDocument = {}
        if (!oRequest.data.blockId || oRequest.data.blockId === '') oRequest.error(400, 'missingBlockId')
        if (oRequest.errors) return
        const oParams = { filename: oRequest.data.documentName, documentId: oRequest.data.documentId }
        let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.data.blockId})`
        if (oRequest.data.documentId === GlobalConstants.SUPPORT_DOCUMENT || (oRequest.data.documentId && !oRequest.data.instanceId)) {
            oParams.blockId = oRequest.data.blockId
            oParams.documentId = oParams.documentId.replace(/\s+/g, "");
            oDocument = {
                REGISTER_ID: cds.utils.uuid(),
                REQUEST_ID: oEntities.REQUEST_ID,
                INSTANCE_ID: null,
                REQUEST_CODE: oEntities.REQUEST_CODE,
                BLOCK_ID: oRequest.data.blockId,
                BLOCK_NAME: oEntities.MASTER_BLOCK_ID,
                TYPE_ID: oRequest.data.docType,
                STEP_ID: 'stepId' in oRequest.data ? oRequest.data.stepId : 0,
                DOCUMENT_NAME: oRequest.data.documentName,
                DOCUMENT_SUBTYPE: oRequest.data.subType,
                DOCUMENT_SUBTYPE_LVL2: oRequest.data.subTypeLvl2,
                DOCUMENT_ID: oRequest.data.documentId,
                FINAL_DOCUMENT: oRequest.data.finalDocument,
                MEDIA_TYPE: oRequest.data.mediaType,
                CREATEDAT: oRequest.timestamp,
                CREATEDBY: oRequest.user.id,
                DELETED: false,
                MODIFIEDAT: oRequest.timestamp,
                MODIFIEDBY: oRequest.user.id,
                WORK_ID: oRequest.data?.workId
            }
        } else {
            oParams.instanceId = oRequest.data.instanceId
            let oDocumentFlow = await SELECT.one.from`DOCUMENT_FLOWS`.where`documentId = ${oRequest.data.documentId}`
            oDocument = {
                REGISTER_ID: cds.utils.uuid(),
                REQUEST_ID: oEntities.REQUEST_ID,
                INSTANCE_ID: oRequest.data.instanceId,
                REQUEST_CODE: oEntities.REQUEST_CODE,
                BLOCK_ID: oRequest.data.blockId,
                BLOCK_NAME: oEntities.MASTER_BLOCK_ID,
                TYPE_ID: oDocumentFlow.documentType,
                STEP_ID: 'stepId' in oRequest.data ? oRequest.data.stepId : 0,
                DOCUMENT_NAME: oRequest.data.documentName,
                DOCUMENT_SUBTYPE: oDocumentFlow.documentSubtype,
                DOCUMENT_SUBTYPE_LVL2: oDocumentFlow.documentSubType2,
                DOCUMENT_ID: oRequest.data.documentId,
                FINAL_DOCUMENT: oRequest.data.finalDocument,
                MEDIA_TYPE: oRequest.data.mediaType,
                CREATEDAT: oRequest.timestamp,
                CREATEDBY: oRequest.user.id,
                DELETED: false,
                MODIFIEDAT: oRequest.timestamp,
                MODIFIEDBY: oRequest.user.id,
                WORK_ID: oRequest.data?.workId
            }
        }
        aDocuments.push(oDocument)
        try {
            await INSERT.into('WF_DETAIL_DOCUMENTS_LOCAL').entries(aDocuments)
            oRequest.reply(await SELECT.from`project.LocalDocuments`.where`ID = ${oDocument.REGISTER_ID}`)
            await logDocumentEvent(oRequest, Actions.DOCUMENT_ADD, oParams);

        } catch (oError) {
            oRequest.error('400', oError.message)
        }
    }

    onUpdateDocument = async (oRequest, next) => {
        let sUrl = oRequest._.req.path
        if (sUrl.includes('content')) {
            // modifications to file            
            try {
                let oDocument = await SELECT.one.from`WF_DETAIL_DOCUMENTS_LOCAL`.where`REGISTER_ID = ${oRequest.data.ID}`
                if (oDocument) {
                    let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oDocument.REQUEST_ID}`
                    if (oRequestHead) {
                        let data = {
                            createUser: oDocument.CREATEDBY,
                            country: oRequestHead.COUNTRY_ID,
                            company: oRequestHead.COMUNIDAD_ID,
                            documentType: oDocument.TYPE_ID,
                            documentSubType: oDocument.DOCUMENT_SUBTYPE,
                            documentTypeLvl2: oDocument.DOCUMENT_SUBTYPE_LVL2,
                            documentDate: new Date().toISOString().split("T")[0].replaceAll("-", "/"),
                            requestType: GlobalConstants.OT_REQUEST_TYPE,
                            requestNumber: oRequestHead.REQUEST_CODE,
                            requestName: oRequestHead.REQUEST_CODE,
                            customerId: oRequestHead.CUSTOMER_ID,
                            customerName: oRequestHead.CUSTOMER_NAME,
                            code: oRequestHead.SITE_ID,
                            folderId: oRequestHead.WORKFLOW_NAME,
                            workId: oDocument.WORK_ID
                        };
                        //NOSONAR let bAmIJoint, oInstancesPerdocument, oDocumenstPerBlock, oRequestHeadJoint, sJointId
                        //NOSONAR bAmIJoint = false
                        //NOSONAR if ('INSTANCE_ID' in oDocument && oDocument.INSTANCE_ID && oDocument.INSTANCE_ID !== null) oInstancesPerdocument = await SELECT.one.from`INSTANCES_PER_DOCUMENT`.where`REGISTER_ID = ${oDocument.INSTANCE_ID}`
                        //NOSONAR if (oInstancesPerdocument) oDocumenstPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oInstancesPerdocument.INSTANCE_ID}`
                        //NOSONAR if (oDocumenstPerBlock) sJointId = oDocumenstPerBlock.PERMIT_ID
                        //NOSONAR if (sJointId) {
                        //NOSONAR     oRequestHeadJoint = await SELECT`CHILD_REQUEST_ID`.from`DT_LINKED_REQUEST`.where`PARENT_INSTANCE_ID = ${sJointId} and DELETED != true`
                        //NOSONAR     bAmIJoint = true
                        //NOSONAR     let oRequestsDirectAccessOtDocument = {
                        //NOSONAR         masterProcess: oRequestHead.REQUEST_CODE,
                        //NOSONAR         childProcesses: oRequestHeadJoint,
                        //NOSONAR         documentId: ""
                        //NOSONAR     }
                        //NOSONAR }

                        await sendDocumenttoOT(oRequest, oDocument, data)
                    } else {
                        oRequest.error(400, 'requestNotFound')
                    }
                } else {
                    oRequest.error(400, 'documentNotFound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            // Other field modifications            
            return next()
        }
    }

    onDeleteDocuments = async (oRequest) => {
        if ('ID' in oRequest?.data) {
            try {
                let oDocument = await SELECT.one.from`WF_DETAIL_DOCUMENTS`.where`REGISTER_ID = ${oRequest.data.ID}`
                if (oDocument) {
                    let oBlockHead = await SELECT.one.from`BLOCK_HEAD`.where`BLOCK_ID = ${oDocument.BLOCK_ID}`
                    if (oBlockHead && oBlockHead.BLOCK_STATUS === BlockStatus.BLOCK_INPROGRESS)
                        if (oDocument.INSTANCE_ID !== null && oDocument.INSTANCE_ID != '') {
                            let oInstance = await SELECT.one.from`INSTANCES_PER_DOCUMENT`.where`REGISTER_ID = ${oDocument.INSTANCE_ID}`
                            if (oInstance) {
                                let oDocumentsPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oInstance.INSTANCE_ID}`
                                if (oDocumentsPerBlock) {
                                    // Documents of cancelled flows can be removed
                                    if (oInstance.STEP_ID === oDocument.STEP_ID || oDocumentsPerBlock.STATUS === DocumentStatus.CANCELLED) {
                                        await removeDocumentFromOT(oRequest, oDocument)
                                        await logDocumentEvent(oRequest, Actions.DOCUMENT_DELETED, { filename: oDocument.DOCUMENT_NAME, registerId: oInstance.INSTANCE_ID });
                                    } else {
                                        oRequest.error(400, 'documentCoulnotBeRemoved')
                                    }
                                } else {
                                    oRequest.error(400, 'documentNotFound')
                                }
                            } else {
                                oRequest.error(400, 'documentNotFound')
                            }
                        } else {
                            await removeDocumentFromOT(oRequest, oDocument)
                            await logDocumentEvent(oRequest, Actions.DOCUMENT_DELETED, { filename: oDocument.DOCUMENT_NAME, documentId: oDocument.DOCUMENT_ID, blockId: oBlockHead.BLOCK_ID });
                        }
                    else {
                        oRequest.error(400, 'documentCoulnotBeRemoved')
                    }
                } else {
                    oRequest.error(400, 'documentNotFound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingParameter')
        }
    }

    afterReadDocuments = async (aDocuments, oRequest, oEntities) => {
        try {
            //get user admin roles
            const userId = oRequest.user.id;
            const aRoles = await SELECT.from`US_ROLES_AGR`.where({ USER_ID: userId });
            const adminRoles = ["TIS_WF_PRO_ColocationMgr", "TIS_WF_PRO_SuppColoMng"];
            const userIsAdmin = aRoles.find((oRole) => adminRoles.find((oAdminRole) => oRole.IAS_GROUP === oAdminRole));
            //get user subco role
            const userIsSubco = aRoles.find((oRole) => oRole.IAS_GROUP === "TIS_WF_PRO_Subcontractor");
            //get user readonly role
            const userIsReadOnly = aRoles.find((oRole) => oRole.IAS_GROUP === "TIS_PRO_COLOCATION_READ_ONLY");
            //get block head
            const entityPath = oRequest.path;
            let oBlockHead = null;
            let oDocumentPerBlock = null;
            switch (entityPath) {
                case "project.Blocks/Documents":
                    const blockId = oRequest.params[0];
                    oBlockHead = await SELECT.one.from`BLOCK_HEAD`.where({ BLOCK_ID: blockId });
                    break;
                case "project.InstancesPerDocuments/Documents":
                    const instancePerDocumentId = oRequest.params[0];
                    oBlockHead = await this.#getBlockHeadInstancePerDocumentId(instancePerDocumentId);
                    //get document per block
                    oDocumentPerBlock = await this.#getDocumentPerBlockByInstancePerDocumentRegisterId(instancePerDocumentId);
                    break;
            }
            if (oBlockHead) {
                //get if block is editable
                const blockIsEditable = (oBlockHead && oBlockHead.ACTIVATED && oBlockHead.BLOCK_STATUS === 7);
                //get request country
                const oPhaseHead = await SELECT.one("REQUEST_ID").from`PHASE_HEAD`.where`PHASE_ID = ${oBlockHead.PHASE_ID}`;
                const oRequestHead = await SELECT.one("COUNTRY_ID").from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhaseHead.REQUEST_ID}`;
                const country = oRequestHead.COUNTRY_ID;
                //get business switch for subcos
                const subcontractorsBusinessSwitch = true;
                //get document types by country
                const aConfiguredDocumentTypes = await SELECT("documentId", "documentName").from`DOCUMENT_FLOWS`.where({
                    countryId: country
                });
                //process documents
                for (let oDocument of aDocuments) {
                    switch (entityPath) {
                        case "project.Blocks/Documents":
                            //set if document can be deleted
                            oDocument.canBeDeleted = false;
                            //check if block is editable and user is not readonly
                            if (blockIsEditable && !userIsReadOnly) {
                                //check if user is manager
                                if (userIsAdmin) {
                                    oDocument.canBeDeleted = true;
                                }
                                else {
                                    //check if user is subco and switch is active
                                    if (subcontractorsBusinessSwitch && userIsSubco) {
                                        //check if document user is current user
                                        if (oDocument.createdBy === userId) {
                                            oDocument.canBeDeleted = true;
                                        }
                                    }
                                }
                            }
                            break;
                        case "project.InstancesPerDocuments/Documents":
                            //set if document can be deleted
                            oDocument.canBeDeleted = false;
                            switch (oDocumentPerBlock?.STATUS) {
                                case DocumentStatus.IN_PROGRESS:
                                case DocumentStatus.CANCELLED:
                                    oDocument.canBeDeleted = true;
                                    break;
                            }
                            break;
                    }
                    //get document type name
                    const oConfiguredDocumentType = aConfiguredDocumentTypes.find((oDocumentType) => oDocumentType.documentId === oDocument.documentId);
                    if (oConfiguredDocumentType) {
                        oDocument.documentTypeName = oConfiguredDocumentType.documentName
                    }
                }
            }
            return aDocuments;
        }
        catch (oError) {
            oRequest.error(400, oError.message);
        }
    }

    onReadSupportDocuments = async (oRequest) => {
        try {
            let sQuery = `SELECT * FROM BLOCK_SUPPORT_DOCUMENTS(p_blockId : '${oRequest.params[0]}')`
            let emptyWorkIdCond = {
                xpr: [
                    '(', { ref: ['workId'] }, 'is', 'null', 'or', { ref: ['workId'] }, '=', { val: '' }, ')',
                    'and', { ref: ['deleted'] }, '!=', { val: true },
                    'and', { ref: ['fileUrl'] }, 'is', 'not', 'null',
                    'and', { ref: ['fileUrl'] }, '!=', { val: '' }
                ]
            }
            let oNewQuery = cds.parse.cql(sQuery)
            if (oRequest.query.SELECT.columns) oNewQuery.SELECT.columns = oRequest.query.SELECT.columns
            if (oRequest.query.SELECT.orderBy) oNewQuery.SELECT.orderBy = oRequest.query.SELECT.orderBy
            if (oRequest.query.SELECT.where) oNewQuery.SELECT.where = oRequest.query.SELECT.where
            if (oRequest.query.SELECT.limit) oNewQuery.SELECT.limit = oRequest.query.SELECT.limit
            if (oNewQuery.SELECT.where && oNewQuery.SELECT.where.length > 0) {
                oNewQuery.SELECT.where.push('and', emptyWorkIdCond)
            } else {
                oNewQuery.SELECT.where = [emptyWorkIdCond]
            }
            let aReturn = []
            aReturn = await cds.run(oNewQuery)
            if (oRequest.query.SELECT.count) aReturn.$count = String(aReturn.length)
            oRequest.reply(aReturn)
        } catch (oError) {
            oRequest.error(400, oError.message)
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

    onDeleteRequestDocumentsPerBlockDefaultValid = async (oRequest) => {
        try {
            await UPDATE('REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID').set({ 'DELETED': true, 'DELETED_BY': oRequest.user.id, 'DELETED_AT': oRequest.timestamp }).where({ 'REGISTER_ID': oRequest.data.registerId })
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    inBothArrayOfObjects = async (list1, list2, sProperty1, sProperty2) => {
        return await this.operationWithArrays(list1, list2, true, sProperty1, sProperty2);
    }

    afterReadRequestDocumentsPerBlockDefaultValid = async (aResult, oRequest) => {
        try {
            let aux = [];
            if (aResult.constructor !== Array) {
                aResult = [aResult];
            }
            if (aResult.length > 0 && aResult[0]) {

                let oRequestHead

                let oDocProcess;
                oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${aResult[0].requestId}`;
                oDocProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`processId = ${oRequestHead.processFlowId}`
                let aDocumentRolesNotVisible = await SELECT.from`DOCUMENT_FLOWS_HIDDEN_PER_ROLE`.where`DocumentFlowsPerConfig_ID = ${oDocProcess.Configuration_ID} and active = true`;

                let aRoles = await SELECT.from`US_ROLES_AGR`.where`USER_ID = ${oRequest.user.id}`;
                let auxNotVisibleDocs = await this.inBothArrayOfObjects(aDocumentRolesNotVisible, aRoles, 'IASGroup', 'IAS_GROUP')
                aux = await this.inFirstOnlyArrayOfObjects(aResult, auxNotVisibleDocs, 'documentId', 'documentId')

                let sMasterBlockId = 'requestCharact'
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
                                if (oDocumentsPerBlockDefaultValid.responsibleDefault && oDocumentsPerBlockDefaultValid.responsibleDefault !== '') {
                                    oUser = await SELECT.one.from`US_USERS_IAS`.where`USER_ID = ${oDocumentsPerBlockDefaultValid.responsibleDefault}`
                                    oDocumentsPerBlockDefaultValid.cellnexResponsible = oDocumentsPerBlockDefaultValid.responsibleDefault
                                    oDocumentsPerBlockDefaultValid.cellnexResponsibleName = ''
                                    oDocumentsPerBlockDefaultValid.cellnexResponsibleFC = 3
                                    if (oUser) oDocumentsPerBlockDefaultValid.cellnexResponsibleName = oUser.USER_NAME
                                }
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
                    aResult = aux
                    aResult.sort((a, b) => a.docOrder - b.docOrder);
                }
                aResult = aux
                aResult.sort((a, b) => a.docOrder - b.docOrder);
            }
            oRequest.reply(aux)
        }
        catch (error) {
            oRequest.reject(400, error.message);
        }
    }

    #getBlockHeadInstancePerDocumentId = async (instancePerDocumentId) => {
        try {
            //get request head
            let aBlockHead = await cds.run(`SELECT TOP 1 BH.* FROM BLOCK_HEAD AS BH
        INNER JOIN DOCUMENTS_PER_BLOCK AS DPB ON DPB.BLOCK_ID = BH.BLOCK_ID
        INNER JOIN INSTANCES_PER_DOCUMENT AS IPD ON IPD.INSTANCE_ID = DPB.REGISTER_ID
        WHERE IPD.REGISTER_ID ='${instancePerDocumentId}'`);
            return (aBlockHead.length > 0) ? aBlockHead[0] : null;
        }
        catch (error) {
            throw new Error("Error in getBlockHeadInstancePerDocumentId: " + error);
        }
    }

    #getDocumentPerBlockByInstancePerDocumentRegisterId = async (instancePerDocumentId) => {
        try {
            //get request head
            let aDocumentsPerBlock = await cds.run(`SELECT TOP 1 DPB.* FROM DOCUMENTS_PER_BLOCK AS DPB
        INNER JOIN INSTANCES_PER_DOCUMENT AS IPD ON IPD.INSTANCE_ID = DPB.REGISTER_ID
        WHERE IPD.REGISTER_ID ='${instancePerDocumentId}'`);
            return (aDocumentsPerBlock.length > 0) ? aDocumentsPerBlock[0] : null;
        }
        catch (error) {
            throw new Error("Error in getDocumentPerBlockByInstancePerDocumentRegisterId: " + error);
        }
    }

}

module.exports = {
    DocumentsCode
}