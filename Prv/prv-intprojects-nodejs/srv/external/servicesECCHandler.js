const cds = require("@sap/cds-dk/lib/cds");

class ServicesECCHandler {

    constructor () {
        this.logger = cds.log('intprojectsServicesECCHandler')
    }

    initialize = async () => {
        //local/mocked mode: ZPM destination not configured locally, skip remote bind
        if (cds.env.requires?.auth?.kind === 'mocked') return
        this.service = await cds.connect.to('ZPM_SERVICES_V2_SRV')
    }

    onReadServicesECC = async (oRequest) => {
        //local/mocked mode: return empty list instead of calling remote ZPM_SERVICES_V2_SRV
        if (cds.env.requires?.auth?.kind === 'mocked') {
            if (!oRequest.query.SELECT.columns || oRequest.query.SELECT.columns[0] !== '$count') return oRequest.reply([])
            return oRequest.reply(0)
        }
        if(!oRequest.query.SELECT.columns || oRequest.query.SELECT.columns[0] !== '$count') {
            try {
                let sRequestId = null
                let aResult = []
                if (!oRequest.query.SELECT.where) { return oRequest.reply([]) }
                for (let i = 0; i < oRequest.query.SELECT.where.length; i++) {
                    if (typeof oRequest.query.SELECT.where[i] === 'object' && 'ref' in oRequest.query.SELECT.where[i] && Array.isArray(oRequest.query.SELECT.where[i].ref) && oRequest.query.SELECT.where[i].ref[0] === 'Idrequest') sRequestId = oRequest.query.SELECT.where[i + 2].val
                }

                if (sRequestId) {
                    aResult = await this.service.run(SELECT .from("ZPM_SERVICES_V2_SRV.servicesView") .where( `requestId = '${sRequestId}'` ))
                    let aMappedResult = aResult.map(item => {
                        return {
                            "Idrequest": item.requestId,
                            "Zzclass": item.instanceClass,
                            "Zzclasstxt": item.instanceClassDescription,
                            "Zzidintern": item.serviceId,
                            "Zzservid": item.serviceName,
                            "ZzserviceCatalog": item.catalogId,
                            "ZzservcatDesc": item.catalogName,
                            "ZzopStatus": item.operativeStatus,
                            "ZzopStatusDesc": item.operativeStatusDesc,
                            "ZzinvStatus": item.invoiceStatus,
                            "InvstDesc": item.invoiceStatusDescription,
                            "Zzbusinessprtnr": item.customerId,
                            "ZzbpDesc": item.customerName,
                            "Zzstartdate": this.parseDateFromYYYYMMDD(item.startDate),
                            "Zzenddate": this.parseDateFromYYYYMMDD(item.endDate),
                            "Zzcontractnumber": item.contractNumber,
                            "Zzlegacy": item.legacyId,
                            "Zzsellerdesc": item.companyName,
                            "Zzseller": item.companyCode,
                            "Agreement": item.agreement,
                            "zcompliance": item.zcompliance
                        }
                    })
                    oRequest.reply(aMappedResult)
                } else {
                    oRequest.Error(400, 'missingRequestId')
                }
            } catch (oError) {
                oRequest.error(400, oError.message)
            }
        } else {
            oRequest.reply(10)
        }
    }

    parseDateFromYYYYMMDD = (str) => {
        if (!str || str.length !== 8 || str === '00000000') return null;
        const year = parseInt(str.slice(0, 4), 10);
        const month = parseInt(str.slice(4, 6), 10) - 1; // Mes en Date() es 0-based
        const day = parseInt(str.slice(6, 8), 10);
        return new Date(year, month, day);
      }

}

module.exports = { ServicesECCHandler }