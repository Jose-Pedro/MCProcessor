const { PhaseStatus, Actions } = require('../utils/enumerations')
const { UserCode } = require('./users')
const { closePhaseBlocks } = require('../utils/phases')
const { checkPhaseStatus, checkBlocks, setPhaseStatus, openNextPhase } = require('../utils/blocks')

class PhasesCode {

    beforeReadPhase = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            const sId = (oRequest.data && oRequest.data.ID) || (oRequest.params && oRequest.params[0])
            if (!sId) return
            let oPhaseHead = await SELECT.one.from`project.Phases`.where`ID = ${sId}`
            if (!oPhaseHead) return
            let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oPhaseHead.requestId}`
            if (!oRequestHead) return
            if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
            if (oRequest.agoraCurrentUserData.country !== oRequestHead.country ) oRequest.error(401, 'notAuthorizedCountry')
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    afterReadPhase = async (oPhase, oRequest) => {
        let aPhases = oPhase.constructor === Array? oPhase: [oPhase]
        try {
            for (let oPhase of aPhases) {
                let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhase.requestId}`
                let oMasterPhase = await SELECT.one.from`PHASE`.where`ID_PK = ${oRequestHead.PROCESS_ID} and PHASE_ID = ${oPhase.processFlowId}`
                if (oMasterPhase) {
                    // Complete customizing info for phase
                    oPhase.closeBlock = oMasterPhase.CLOSE_BLOCK
                    oPhase.hasCandidates = oMasterPhase.HAS_CANDIDATES
                    oPhase.activated = oMasterPhase.PASS_OVER === 'X' ? false : true
                }
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    beforePhaseClose = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            let oPhaseHead = await SELECT.one.from`project.Phases`.where`ID = ${oRequest.data.ID}`
            if(oPhaseHead === undefined) oPhaseHead = await SELECT.one.from`project.Phases`.where`ID = ${oRequest.params[0]}`
            let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oPhaseHead.requestId}`
            if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
            if (oRequest.agoraCurrentUserData.country !== oRequestHead.country ) oRequest.error(401, 'notAuthorizedCountry')
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onPhaseClose = async (oRequest) => {
        //NOSONAR TODO: response with an array of open phases
        if (oRequest.params.constructor === Array && oRequest.params.length > 0) {
            try {
                let oPhase = await SELECT.one.from`PHASE_HEAD`.where`PHASE_ID = ${oRequest.params[0]}`
                let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oPhase.REQUEST_ID}`
                if (oPhase) {
                    checkPhaseStatus(oRequest, oPhase, Actions.ACTION_PHASE_CLOSE)
                    if (oRequest.errors) return
                    let oMasterPhase = await SELECT .one .from `PHASE` .where `ID_PK = ${oRequestHead.PROCESS_ID} and PHASE_ID = ${oPhase.MASTER_PHASE_ID}`
                    if (oMasterPhase && oMasterPhase.CLOSE_BLOCK) {
                        // Phase with automagic block closing
                        await closePhaseBlocks(oRequest, oRequestHead, oPhase)
                        if (oRequest.errors) return
                    } else {
                    // Normal processing, active blocks had to be manually close before Phase close
                        await checkBlocks(oRequest, oRequestHead, oPhase)
                        if (oRequest.errors) return
                    }

                    // close current Phase
                    await setPhaseStatus(oRequest, PhaseStatus.PHASE_COMPLETED, oPhase.PHASE_ID)

                    // open next Phases
                    let oNextPhase = await openNextPhase(oRequest, oPhase, oRequestHead)
                    if (oRequest.errors) return

                    // return updated entity
                    if (oNextPhase.oNextPhase) oRequest.reply(await SELECT.one.from`project.Phases`.where`ID = ${oNextPhase.oNextPhase.PHASE_ID}`)
                } else {
                    oRequest.error(400, 'phaseNotFound')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingPhaseId')
        }
    }
}

module.exports = {
    PhasesCode
}