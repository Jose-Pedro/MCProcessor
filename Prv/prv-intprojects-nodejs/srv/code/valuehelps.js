const { SubcoTypes, Roles, ProjectTypes } = require('../utils/enumerations')
const { UserCode } = require('./users')

class ValueHelpsCode {

    onReadExternalUsers = async (oRequest) => {
        if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
            let aWhere = oRequest.query.SELECT.where
            let sBlockId
            let sObjectType
            for (let i = 0; i < aWhere.length; i++) {
                if (typeof aWhere[i] === 'object' && 'ref' in aWhere[i] && Array.isArray(aWhere[i].ref) && (aWhere[i].ref[0] === 'blockId')) {
                    sBlockId = aWhere[i + 2].val
                }
                if (typeof aWhere[i] === 'object' && 'ref' in aWhere[i] && Array.isArray(aWhere[i].ref) && (aWhere[i].ref[0] === 'objectType')) {
                    sObjectType = aWhere[i + 2].val
                }
            }
            try {
                let aMappedResult = []
                let externalType
                if (sObjectType === 'block') {
                    let oBlockProv = await SELECT .one .from `BLOCKS_PROVISIONING` .where `BLOCK_ID = ${sBlockId}`
                    externalType = oBlockProv.SUBCONTRACTOR_TYPE
                } else {
                    let oWork = await SELECT .one .from `WORKS` .where `ID = ${sBlockId}`
                    externalType = oWork.externalType
                }
                switch (externalType) {
                    case SubcoTypes.VENDOR:
                        aMappedResult = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and entityType = 'F4_PROV_VENDOR_GEWRK'`;
                        break
                    case SubcoTypes.AGENCY:
                        aMappedResult = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and entityType = 'F4_GEWRK_AGEN'`;
                        break
                }
                if ( oRequest._.req.query.$count || oRequest.query.SELECT.columns[0].func === 'count') aMappedResult.$count = aMappedResult.length
                oRequest.reply(aMappedResult)
            } catch (oError) {
                oRequest.reply(oError.message)
            }
        } else {
            oRequest.reply()
        }
    }

    onReadInternalUsers = async (oRequest) => {
        let aResults = []
        try {
            await UserCode.currentUserDetails(oRequest)
            if (oRequest.agoraCurrentUserData.country) {
                let aNewWhere = []
                let oCQLQuery = cds.parse.cql(`SELECT DISTINCT * from USERS(p_country: '${oRequest.agoraCurrentUserData.country}')`)
                oCQLQuery.SELECT.columns = oRequest.query.SELECT?.columns
                oCQLQuery.SELECT.orderBy = oRequest.query.SELECT?.orderBy
                oCQLQuery.SELECT.limit = oRequest.query.SELECT?.limit
                if (oRequest.query.SELECT.where) aNewWhere = oRequest.query.SELECT.where
                if (aNewWhere.length > 0) aNewWhere.push('and')
                aNewWhere.push('(')
                aNewWhere.push({ 'ref': ['iasGroup'] })
                aNewWhere.push('=')
                aNewWhere.push({ 'val': Roles.CELLNEX_USER_ROL })
                aNewWhere.push(')')
                oCQLQuery.SELECT.where = aNewWhere
                aResults = await cds.run(oCQLQuery)
            }
            if ( oRequest._.req.query.$count || oRequest.query.SELECT.columns[0].func === 'count') aResults.$count = aResults.length
            oRequest.reply(aResults)
        } catch (oError) {
            oRequest.reply(aResults)
        }
    }

    beforeReadProjectTypes = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if (oRequest.agoraCurrentUserData.country && oRequest.agoraCurrentUserData.country !== '') {
                if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
                    oRequest.query.SELECT.where.push('and')
                } else {
                    oRequest.query.SELECT.where = []
                }
                let sExpresion = `country = '${oRequest.agoraCurrentUserData.country}'`
                let oFilter = cds.parse.expr(sExpresion)
                oRequest.query.SELECT.where.push(...oFilter.xpr)
            } else {
                // oRequest.error(400, 'userNoCountry')
            }
        } catch (oError) {
        }
    }

    beforeReadProjectObjectivesCountry = async (oRequest) => {
        try {
            await UserCode.currentUserDetails(oRequest)
            if (oRequest.agoraCurrentUserData.country && oRequest.agoraCurrentUserData.country !== '') {
                if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
                    oRequest.query.SELECT.where.push('and')
                } else {
                    oRequest.query.SELECT.where = []
                }
                let sExpresion = `country = '${oRequest.agoraCurrentUserData.country}'`
                let oFilter = cds.parse.expr(sExpresion)
                oRequest.query.SELECT.where.push(...oFilter.xpr)
            } else {
                // oRequest.error(400, 'userNoCountry')
            }
        } catch (oError) {
        }
    }

}

module.exports = {
    ValueHelpsCode
}