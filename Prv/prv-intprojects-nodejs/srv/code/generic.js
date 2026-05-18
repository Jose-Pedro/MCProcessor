const { UserCode } = require('./users')

class GenericCode {

    addFilterByCountry = async (oRequest) => {
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
            oRequest.error(400, 'userNoCountry')
        }

    }

}

module.exports = {
    GenericCode
}