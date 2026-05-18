const cds = require("@sap/cds-dk/lib/cds");

class ServicesHandler {

    constructor () {
        this.logger = cds.log('intprojectsServicesHandler')
    }

    initialize = async () => {
        //local/mocked mode: ZTIS_SRV destination is not configured locally, skip remote bind
        if (cds.env.requires?.auth?.kind === 'mocked') return
        this.service = await cds.connect.to('ZTIS_SRV_SERVICES_SRV')
    }

    onReadServices = async (oRequest) => {
        //local/mocked mode: return empty list instead of calling remote ZTIS_SRV
        if (cds.env.requires?.auth?.kind === 'mocked') {
            if (!oRequest.query.SELECT.columns || oRequest.query.SELECT.columns[0] !== '$count') return oRequest.reply([])
            return oRequest.reply(0)
        }
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

}

module.exports = { ServicesHandler }