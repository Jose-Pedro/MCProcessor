const cds = require("@sap/cds-dk/lib/cds");

class DataServicesHandler {

    constructor () {
        this.logger = cds.log('intprojoDataServices')
    }

    initialize = async () => {
        this.service = await cds.connect.to('ZTIS_ODATA_SERVICES_SRV')
    }

    getInventoryStatus = async (siteId) => {
        try {
            return await this.service.run( SELECT .one .from `tec_objectSet` .where `Aoid = ${siteId} and Searchtype = 'TREE'` )
        } catch (oError) {
            this.logger.info('request failed with error: ', oError.message)
            throw oError
        }

    }

}

module.exports = { DataServicesHandler }