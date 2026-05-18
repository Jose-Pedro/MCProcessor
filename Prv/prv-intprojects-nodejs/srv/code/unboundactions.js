const { Roles, AssignedResponsibleTypes, GlobalConstants, PhaseStatus } = require('../utils/enumerations')
const { getDefaultCreationObject } = require('../utils/unboundactions')

class UnboundActionsCode {

    getRequestAllowedActions = async (oRequest) => {
        let oResponse = {
            linkedProjects: false,
            forecast: false,
            create: false,
            responsibles: false,
            workOrders: true,
            log: false,
            projectDocuments: false,
            opentextDocuments: false,
            consolidation: false,
            cancel: false,
            onHold: false,
            takeOwnership: false,
            reopen: false,
            close: false,
            confirms: false,
            closePhase: false,
            addDefaultDocuments: false,
            registerCandidates: false,
            launchRenegos: false,
            launchPermits: false
        }
        let bIsManager = oRequest.user.is(Roles.MANAGER_USER_ROL)
        let bIsRequester = oRequest.user.is(Roles.REQUESTER)
        if (bIsManager) {
            oResponse.linkedProjects = true
            oResponse.forecast = true
            oResponse.create = true
            oResponse.responsibles = true
            oResponse.workOrders = true
            oResponse.log = true
            oResponse.projectDocuments = true
            oResponse.opentextDocuments = true
            oResponse.consolidation = true
            oResponse.cancel = true
            oResponse.onHold = true
            oResponse.takeOwnership = true
            oResponse.close = true
            oResponse.confirms = true
            oResponse.closePhase = true
            oResponse.addDefaultDocuments = true
            oResponse.launchRenegos = true
            oResponse.launchPermits = true
        } else if (bIsRequester) {
            oResponse.create = true
        }

        //      Check reopener role
        if (oRequest.user.is(Roles.REOPEN_USER_ROL)) oResponse.reopen = true

        oRequest.reply(oResponse)
    }

    getBlocksAllowedActions = async (oRequest) => {
        //NOSONAR oRequest.user = new User({id: 'UKPRSUBCO1', roles: ['TIS_WF_PRO_Subcontractor']})
        if (!('requestId' in oRequest.data)) oRequest.error(400, 'missingRequestId')
        if (oRequest.errors) return
        let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.data.requestId}`
        if (!oRequestHead) oRequest.error(400, 'requestNotFound')
        if (oRequest.errors) return

        let aPhases = []
        let oBlocksActions = {}

        aPhases = await SELECT.from`PHASE_HEAD`.where`REQUEST_ID = ${oRequest.data.requestId}`
        for (let oPhase of aPhases) {
            let aBlocks = []
            aBlocks = await SELECT.from`BLOCK_HEAD`.where`PHASE_ID = ${oPhase.PHASE_ID}`
            if (aBlocks.length > 0) oBlocksActions[oPhase.MASTER_PHASE_ID] = {}
            for (let oBlock of aBlocks) {
                let oHasAuth = { 'complete': false, 'activate': false, 'reopen': false, 'addFlow': false, 'addWork': false, 'addChecklist': false, 'removeChecklist': false }
                let oBlockProvision = await SELECT.one.from`BLOCKS_PROVISIONING`.where`BLOCK_ID = ${oBlock.BLOCK_ID}`
                oBlocksActions[oPhase.MASTER_PHASE_ID][oBlock.MASTER_BLOCK_ID] = {}
                if (oBlockProvision) {
                    let sResponsible = oBlockProvision.ASSIGNED_RESPONSIBLE === AssignedResponsibleTypes.CELLNEX ? oBlockProvision.RESPONSIBLE_PERSON : oBlockProvision.PROVIDER_NAME
                    await this.#checkBlockActions(oRequest, oBlock.ROLE_ID, sResponsible, oHasAuth)
                }
                oBlocksActions[oPhase.MASTER_PHASE_ID][oBlock.MASTER_BLOCK_ID].complete = oHasAuth.complete
                oBlocksActions[oPhase.MASTER_PHASE_ID][oBlock.MASTER_BLOCK_ID].activate = oHasAuth.activate
                oBlocksActions[oPhase.MASTER_PHASE_ID][oBlock.MASTER_BLOCK_ID].reopen = oHasAuth.reopen
                oBlocksActions[oPhase.MASTER_PHASE_ID][oBlock.MASTER_BLOCK_ID].addFlow = oHasAuth.addFlow
                oBlocksActions[oPhase.MASTER_PHASE_ID][oBlock.MASTER_BLOCK_ID].addWork = oHasAuth.addWork
                oBlocksActions[oPhase.MASTER_PHASE_ID][oBlock.MASTER_BLOCK_ID].addChecklist = oHasAuth.addChecklist
                oBlocksActions[oPhase.MASTER_PHASE_ID][oBlock.MASTER_BLOCK_ID].removeChecklist = oHasAuth.removeChecklist
            }
        }
        oRequest.reply(oBlocksActions)
    }

    getDefaultCreationFields = async (oRequest) => {
        oRequest.reply(await getDefaultCreationObject(oRequest))
    }

    refreshR3EntitiesCache = async (oRequest) => {
        try {
            //get user id
            const userId = oRequest.user.id;
            //local/mocked mode: R3 backend is unreachable; keep any existing cache rows and return.
            if (cds.env.requires?.auth?.kind === 'mocked') return;
            //check if data is stale
            let minTTLTimestamp = new Date();
            minTTLTimestamp.setHours(minTTLTimestamp.getHours() - GlobalConstants.CACHE_TTL_HOURS);
            minTTLTimestamp = minTTLTimestamp.toISOString();
            const cacheIsNotStale = await SELECT.one.from`CACHE_R3_ENTITIES`.where`USER_ID = ${userId} and CREATED_AT >= ${minTTLTimestamp}`;
            if (!cacheIsNotStale) {
                //must refresh cache data
                //delete all cache data for user
                await DELETE.from`CACHE_R3_ENTITIES`.where`USER_ID = ${userId}`;
                //fetch new R3 entities
                const odataF4Service = await cds.connect.to('ZTIS_F4HELP_SRV');
                const R3_ENTITIES_TYPES = ["F4_PROV_VENDOR_GEWRK", "F4_GEWRK_AGEN"];
                let aR3CacheEntitites = [];
                for (const entityType of R3_ENTITIES_TYPES) {
                    //call R3 OData
                    const r3Entities = await odataF4Service.run(SELECT.from('CtDataOutSet').where({ Screen: "SCR_WF_SRH", Object: entityType, Subobj1: "" }));
                    //save R3 entities
                    for (const r3Entity of r3Entities) {
                        let oEntityCache = {
                            ENTITY_TYPE: entityType,
                            ENTITY_ID: r3Entity.Objkey1,
                            ENTITY_NAME: r3Entity.Description
                        };
                        aR3CacheEntitites.push(oEntityCache);
                    }
                }
                //save all new entities in cache
                await INSERT.into("CACHE_R3_ENTITIES").entries(aR3CacheEntitites);
            }
        } catch (oError) {
            oRequest.reject(400, `${oError}`, [oError]);
        }
    }

    getPhasesStatus = async (oRequest) => {
        if (!('requestId' in oRequest.data)) oRequest.error(400, 'missingRequestId')
        if(oRequest.errors) return
        let aPhases = []
        let aResponse = []
        aPhases = await SELECT.from`PHASE_HEAD`.where`REQUEST_ID = ${oRequest.data.requestId}`
        for(let oPhase of aPhases) {
            aResponse.push({
                phaseName: oPhase.MASTER_PHASE_ID,
                status: oPhase.PHASE_STATUS === PhaseStatus.PHASE_COMPLETED? 'sap-icon://status-completed': ''
            })
        }
        oRequest.reply(aResponse)
    }

    #checkBlockActions = async (oRequest, sProcessRoleId, sResponsible, oHasAuth) => {
        oHasAuth.complete = false
        oHasAuth.activate = false
        oHasAuth.reopen = false
        oHasAuth.addFlow = false
        oHasAuth.addWork = false
        oHasAuth.addChecklist = false
        oHasAuth.removeChecklist = false
        if (oRequest.user.is(Roles.CELLNEX_USER_ROL)) {
            let isManager = oRequest.user.is(Roles.MANAGER_USER_ROL)
            if (oRequest.user.is(sProcessRoleId) || isManager) {
                if (isManager) {
                    oHasAuth.complete = true
                    oHasAuth.activate = true
                    oHasAuth.reopen = true
                    oHasAuth.addFlow = true
                    oHasAuth.addWork = true
                    oHasAuth.addChecklist = true
                    oHasAuth.removeChecklist = true
                } else {
                    if (sResponsible === oRequest.user.id && sResponsible !== null && sResponsible !== '') {
                        oHasAuth.complete = true
                        oHasAuth.activate = true
                        oHasAuth.reopen = true
                        oHasAuth.addFlow = true
                        oHasAuth.addWork = true
                        oHasAuth.addChecklist = true
                        oHasAuth.removeChecklist = true
                    }
                }
            }
        } else {
            if (oRequest.user.is(Roles.VENDOR_USER_ROL)) {
                let oBPRecord = await SELECT.one.from`US_ZVENDOR`.where`USER_ID = ${oRequest.user.id}`
                if (oBPRecord?.ZVENDOR_ID === sResponsible && sResponsible !== null && sResponsible !== '') {
                    oHasAuth.complete = true
                    oHasAuth.activate = true
                    oHasAuth.reopen = true
                    oHasAuth.addFlow = true
                    oHasAuth.addWork = true
                    oHasAuth.addChecklist = true
                    oHasAuth.removeChecklist = true
                }
            } else if (oRequest.user.is(Roles.AGENCY_USER_ROL)) {
                let oBPRecord = await SELECT.one.from`US_ZAGENCY`.where`USER_ID = ${oRequest.user.id}`
                if (oBPRecord?.ZAGENCY_ID === sResponsible && sResponsible !== null && sResponsible !== '') {
                    oHasAuth.complete = true
                    oHasAuth.activate = true
                    oHasAuth.reopen = true
                    oHasAuth.addFlow = true
                    oHasAuth.addWork = true
                    oHasAuth.addChecklist = true
                    oHasAuth.removeChecklist = true
                }
            } else if (oRequest.user.is(Roles.CUSTOMER_USER_ROL)) {
                let oBPRecord = await SELECT.one.from`US_ZCUSTOMER`.where`USER_ID = ${oRequest.user.id}`
                if (oBPRecord?.ZCUSTOMER_ID === sResponsible && sResponsible !== null && sResponsible !== '') {
                    oHasAuth.complete = true
                    oHasAuth.activate = true
                    oHasAuth.reopen = true
                    oHasAuth.addFlow = true
                    oHasAuth.addWork = true
                    oHasAuth.addChecklist = true
                    oHasAuth.removeChecklist = true
                }
            }
        }
    }

}

module.exports = {
    UnboundActionsCode
}