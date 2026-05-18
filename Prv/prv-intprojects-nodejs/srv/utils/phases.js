
const { BlockStatus } = require('../utils/enumerations');
const { checkBlockDocuments } = require('../utils/blocks');
const { checkMandatoryChecklistItems } = require('./checklists');
const { checkWorksStatus } = require('./works');
const { checkBlockMandatoryFields } = require('../utils/configurations');
const { populate } = require('./populator');
 
const closePhaseBlocks = async (oRequest, oRequestHead, oPhase) => {
    let aBlocks = []
    aBlocks = await SELECT.from`BLOCK_HEAD`.where`PHASE_ID = ${oPhase.PHASE_ID} and ACTIVATED = true and BLOCK_STATUS = ${BlockStatus.BLOCK_INPROGRESS}`
    for (let oBlock of aBlocks) {
        let oBlockHead = await SELECT.one.from`project.Blocks`.where`ID = ${oBlock.BLOCK_ID}`
        let oBlockProvision = await SELECT.one.from`project.BlockProvision`.where`ID = ${oBlock.BLOCK_ID}`
        let oBlockConfig = await SELECT.one.from`BLOCK`.where`ID_PK = ${oRequestHead.PROCESS_ID} and PHASE_ID_PK = ${oPhase.MASTER_PHASE_ID} and BLOCK_ID_PK = ${oBlock.MASTER_BLOCK_ID}`
        if (oBlockConfig.VISIBLE_ON === 'X') {
            await checkBlockMandatoryFields(oRequest, oBlockHead, oBlockProvision)
            await checkMandatoryChecklistItems(oRequest, oBlockHead.ID)
            await checkWorksStatus(oRequest, oBlockHead.ID)
            await checkBlockDocuments(oRequest, oBlockHead)
            if (!oRequest.errors) {
                await populate(oBlock)
                await UPDATE`BLOCK_HEAD`.set({ 'BLOCK_STATUS': BlockStatus.BLOCK_COMPLETED, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id, 'ENDED_AT': oRequest.timestamp }).where`BLOCK_ID = ${oBlock.BLOCK_ID}`
                await UPDATE`BLOCKS_PROVISIONING`.set({ 'COMPLETED_DATE': oRequest.timestamp, 'COMPLETED_AT': oRequest.timestamp, 'COMPLETED_BY': oRequest.user.id, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id }).where`BLOCK_ID = ${oBlock.BLOCK_ID}`
            }
        }
    }
}

module.exports = { 
    closePhaseBlocks
}