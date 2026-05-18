
class DPRCode {

    onUpdateDocumentsPerRequests = async (oRequest) => {
        if ('ID' in oRequest.data) {
            try {
                for (var key of Object.keys(oRequest.data)) {
                    if(typeof oRequest.data[key] == "boolean"){
                        oRequest.data[key] = oRequest.data[key].toString()
                    }
}
                await UPDATE('project.DocumentsPerBlocks').set(oRequest.data).where({ 'ID': oRequest.data.ID })
                let oReturn = await SELECT.one.from('project.DocumentsPerRequest').where({ 'ID': oRequest.data.ID })
                return oReturn

            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.error(400, 'missingParameters')
        }
    }

    onReadDocumentFlowResponsibles = async (oRequest) => {
        if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
            let aWhere = oRequest.query.SELECT.where
            let aNewWhere = []
            let oParams = {}
            
            for (let i = 0; i < aWhere.length; i++) {
                if (typeof aWhere[i] === 'object' && 'ref' in aWhere[i] && Array.isArray(aWhere[i].ref) && (aWhere[i].ref[0] === 'ID')) {
                    aNewWhere.pop()
                    oParams[aWhere[i].ref[0]] = aWhere[i + 2].val
                    i = i + 3
                } else {
                    aNewWhere.push(aWhere[i])
                }
            }
            try {
                let oRequestHead
                let oDocumentPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oParams.ID}`

                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oDocumentPerBlock.BLOCK_ID})`
                oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oEntities.REQUEST_ID}`

                let sTable
                if (oDocumentPerBlock.RESPONSIBLE_ID === AssignedResponsibleTypes.CELLNEX) {
                    sTable = 'USERSDPB'
                } else {
                    switch (parseInt(oDocumentPerBlock.SUBCONTRATOR_ID, 10)) {
                        case 1:
                            sTable = 'USERSDPB'
                            break
                        case SubcoTypes.CUSTOMER:
                            sTable = 'CUSTOMERS_USERS'
                            break
                        case SubcoTypes.VENDOR:
                            sTable = 'VENDORS_USERS'
                            break
                        case SubcoTypes.AGENCY:
                            sTable = 'AGENCIES_USERS'
                            break
                    }
                }
                let aResults
                if (oDocumentPerBlock.RESPONSIBLE_ID === AssignedResponsibleTypes.CELLNEX) {
                    let oCQLQuery = cds.parse.cql(`SELECT * from ${sTable}(p_country: '${oRequestHead.COUNTRY_ID}')`)
                    oCQLQuery.SELECT.columns = oRequest.query.SELECT?.columns
                    oCQLQuery.SELECT.orderBy = oRequest.query.SELECT?.orderBy
                    oCQLQuery.SELECT.limit = oRequest.query.SELECT?.limit
                    if (aNewWhere.length > 0) oCQLQuery.SELECT.where = aNewWhere
                    aResults = await cds.run(oCQLQuery)
                    oRequest.reply(aResults)
                } else {
                    let aMappedResult = []
                    switch (parseInt(oDocumentPerBlock.SUBCONTRATOR_ID, 10)) {
                        case SubcoTypes.VENDOR:
                            aMappedResult = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                            oRequest.reply(aMappedResult)
                            break
                        case SubcoTypes.AGENCY:
                            aMappedResult = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and entityType = 'F4_GEWRK_AGEN'`;
                            oRequest.reply(aMappedResult)
                            break
                        default:
                            oRequest.reply(aMappedResult)
                    }
                }
            } catch (oError) {
                oRequest.reply(oError.message)
            }
        } else {
            oRequest.reply()
        }
    }

}

module.exports = {
    DPRCode
}