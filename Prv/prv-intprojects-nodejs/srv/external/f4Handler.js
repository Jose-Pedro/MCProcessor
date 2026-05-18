const cds = require("@sap/cds-dk/lib/cds");

class F4Handler {

    constructor () {
        this.logger = cds.log('intProjF4Handler')
    }

    initialize = async () => {
        this.service = await cds.connect.to('ZTIS_F4HELP_SRV')
    }

    onReadProviders = async (oRequest) => {
        if(!oRequest.query.SELECT.columns || oRequest.query.SELECT.columns[0] !== '$count') {
            try {
                oRequest.reply(await this.service.run(oRequest.query))
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.reply(10)
        }
    }

    readVendors = async (oRequest, sScreen, sObject, sSubObject) => {
        try {
        // get data via CQL query with inline filters
            let result = await this.service.run(
                SELECT .columns('Objkey1', 'Description') .from("ZTIS_F4HELP_SRV.CtDataOutSet") .where( `Screen = '${sScreen}' and Object = '${sObject}' and Subobj1 = '${sSubObject}'` )
            )
            return result
        } catch (oError) {
            oRequest.error(400, oError.message)
            this.logger.info('request failed with error: ', oError.message)
        }
    }

    readOneVendor = async (oRequest, sScreen, sObject, sSubObject,sSubcoId) => {
        try {
        // get data via CQL query with inline filters
            let result = await this.service.run(
                SELECT .columns('Objkey1', 'Description') .from("ZTIS_F4HELP_SRV.CtDataOutSet") .where( `Screen = '${sScreen}' and Object = '${sObject}' and Subobj1 = '${sSubObject}'` )
            )
            return result.find(oResult => oResult.Objkey1 === sSubcoId)
        } catch (oError) {
            oRequest.error(400, oError.message)
            this.logger.info('request failed with error: ', oError.message)
        }
    }

}

module.exports = { F4Handler }