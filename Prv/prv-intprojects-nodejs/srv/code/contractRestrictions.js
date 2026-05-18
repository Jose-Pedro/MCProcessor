class ContractResctrictionsCode {

    onDeleteContractRestrictions = async oRequest => {
        try {
            await DELETE .from `MASTER_MS_CONTRACT_RESTRICTIONS` .where `BLOCK_ID = ${oRequest.data.BLOCK_ID} and CONTRACT_RESTRICTIONS_ID = ${oRequest.data.CONTRACT_RESTRICTIONS_ID}`
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    beforeCreateContractRestrictions = async oRequest => {
        oRequest.data.CONTRACT_RESTRICTIONS_ID = oRequest.data.contractRestrictionIdUI
    }

    afterReadContractRestrictions = async (aResult, oRequest) => {
        if (aResult.constructor !== Array) aResult = [aResult]
        if (aResult.length > 0) {
            let oBlock = await SELECT .one .from `project.Blocks` .where `ID = ${aResult[0].BLOCK_ID}`
            for(let oResult of aResult) {
                oResult.contractRestrictionIdUI = oResult.contractRestrictionId
                if (oBlock?.contractRestrictionsFC) oResult.contractRestrictionIdFC = oBlock.contractRestrictionsFC
            }
        }
    }

}

module.exports = { 
    ContractResctrictionsCode
}