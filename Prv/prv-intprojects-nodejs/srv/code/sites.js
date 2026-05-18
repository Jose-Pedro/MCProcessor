const { UserCode } = require('./users')

class SitesCode {

    beforeReadSites = async oRequest => {
        await UserCode.currentUserDetails(oRequest)
        if (oRequest.agoraCurrentUserData.country) {
            if (oRequest.query.SELECT.where && oRequest.query.SELECT.where.length > 0) {
                oRequest.query.SELECT.where.push('and')
            } else {
                oRequest.query.SELECT.where = []
            }
            let sExpresion = `aotype = '0${oRequest.agoraCurrentUserData.country}'`
            let oFilter = cds.parse.expr(sExpresion)
            oRequest.query.SELECT.where.push(...oFilter.xpr)
        } else {
            oRequest.error(400, 'userNoCountry')
        }
    }

    afterReadSites = async (oResult, oRequest) => {
        let aResults = oResult.constructor !== Array? [oResult] : oResult
        try {
            for(let oSite of aResults) {
                let oLandlord = await SELECT .one .from `LANDLORD_BY_SITE(p_siteId: ${oSite.siteId})`
                if (oLandlord) oSite.landlordName = oLandlord.fullname
            }
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

}

module.exports = { SitesCode }