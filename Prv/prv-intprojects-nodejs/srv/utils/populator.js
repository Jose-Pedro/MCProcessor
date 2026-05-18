const { Populations } = require('./enumerations')

const getSamePhasePopulations = async (oBlock) => {
    let oSamePhaseBlocks = ''
    let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oBlock.BLOCK_ID})`
    let aPhasePopulations = getPopulations(Populations, oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID)
    if(aPhasePopulations) {
        for(let oPhasePopulation of aPhasePopulations) {
            if (oPhasePopulation.phase === oEntities.MASTER_PHASE_ID) {
                for(let oBlockPopulation of oPhasePopulation.blocks) {
                    oSamePhaseBlocks = oSamePhaseBlocks + ',' + oBlockPopulation.block
                }
            }
        }
    }
    return oSamePhaseBlocks
}

const populate = async (oBlock) => {
    let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oBlock.BLOCK_ID})`
    let oBlockProvision = await SELECT .one .from `BLOCKS_PROVISIONING` .where `BLOCK_ID = ${oBlock.BLOCK_ID}`
    if(oEntities) {
        let aPhasePopulations = getPopulations(Populations, oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID)
        if (aPhasePopulations) {
            for(let oPhasePopulation of aPhasePopulations) {
                let oTargetPhase = await SELECT .one .from `PHASE_HEAD` .where `REQUEST_ID = ${oEntities.REQUEST_ID} and MASTER_PHASE_ID = ${oPhasePopulation.phase}`
                if (oTargetPhase) {
                    for(let oBlockPopulation of oPhasePopulation.blocks){
                        let oTargetBlock
                        if(oBlockPopulation.forCandidate) {
                            oTargetBlock = await SELECT .one .from `BLOCK_HEAD` .where `PHASE_ID = ${oTargetPhase.PHASE_ID} and MASTER_BLOCK_ID = ${oBlockPopulation.block} and CANDIDATE_ID = ${oBlock.CANDIDATE_ID}`
                        } else {
                            oTargetBlock = await SELECT .one .from `BLOCK_HEAD` .where `PHASE_ID = ${oTargetPhase.PHASE_ID} and MASTER_BLOCK_ID = ${oBlockPopulation.block}`
                        }
                        if (oTargetBlock) {
                            let oTargetBlockProvision = await SELECT .one .from `BLOCKS_PROVISIONING` .where `BLOCK_ID = ${oTargetBlock.BLOCK_ID}`
                            let oData = {}
                            for(let oBlockField of oBlockPopulation.fields) {
                                if(oTargetBlockProvision[oBlockField] === null || oTargetBlockProvision[oBlockField] === '') {
                                    oData[oBlockField] = oBlockProvision[oBlockField]
                                }
                            }
                            if(oData) await UPDATE('BLOCKS_PROVISIONING') .set(oData) .where({BLOCK_ID: oTargetBlock.BLOCK_ID})
                        }
                    }
                }
            }
        }
    }
}

const getPopulations = (oObject, ...keys) => {
    return keys.reduce((object, key) => object?.[key], oObject);
}

module.exports = {
    getSamePhasePopulations,
    populate    
}