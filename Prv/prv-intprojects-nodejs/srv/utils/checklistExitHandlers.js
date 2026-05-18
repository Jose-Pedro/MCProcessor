class AfterCreate {

}

class AfterRead {

}

class AfterUpdate {

    static determineComplexity = async (oRequest, oItem, oEntities) => {
        if ((oItem.type_ID === 14 || oItem.type_ID === 15 || oItem.type_ID === 16 || oItem.type_ID === 17)) {
            if (oItem.pickList === 1) {
                await UPDATE('BLOCKS_PROVISIONING') .set({complexity: 2}) .where({BLOCK_ID: oItem.block_ID})
            } else {
                let aItems = []
                aItems = await SELECT .from `project.ChecklistItems` .where `block_ID = ${oEntities.BLOCK_ID} and (deleted is null or deleted = false) and type_ID in (14, 15, 16, 17)`
                if (aItems.some(item => item.pickList === 1)) {
                    await UPDATE('BLOCKS_PROVISIONING') .set({complexity: 2}) .where({BLOCK_ID: oItem.block_ID})
                } else {
                    await UPDATE('BLOCKS_PROVISIONING') .set({complexity: 1}) .where({BLOCK_ID: oItem.block_ID})
                }
            }
        }
    }

}

module.exports = {
    AfterCreate,
    AfterRead,
    AfterUpdate
}