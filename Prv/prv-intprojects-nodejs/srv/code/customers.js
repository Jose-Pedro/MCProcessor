class CustomersCode {

    onReadImpactedCustomers = async (oRequest) => {
        try {
            let sQuery = `SELECT * FROM REQUEST_CUSTOMERS(p_requestId : '${oRequest.params[0]}')`
            let oNewQuery = cds.parse.cql(sQuery)
            if (oRequest.query.SELECT.columns) oNewQuery.SELECT.columns = oRequest.query.SELECT.columns
            if (oRequest.query.SELECT.orderBy) oNewQuery.SELECT.orderBy = oRequest.query.SELECT.orderBy
            if (oRequest.query.SELECT.where) oNewQuery.SELECT.where = oRequest.query.SELECT.where
            if (oRequest.query.SELECT.limit) oNewQuery.SELECT.limit = oRequest.query.SELECT.limit
            let aReturn = []
            aReturn = await cds.run(oNewQuery)
            if (oRequest.query.SELECT.count) aReturn.$count = String(aReturn.length)
            oRequest.reply(aReturn)
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

    onUpdateImpactedCustomers = async (oRequest) => {
        try {
            let { requestId, customerId, impacted } = oRequest.data;
            let exists = await SELECT .one .from `REQUEST_IMPACTED_CUSTOMERS` .where `requestId = ${requestId} and customer = ${customerId} and ( deleted = false or deleted is null )` 
            if (impacted === true && !exists) await INSERT .into('REQUEST_IMPACTED_CUSTOMERS') .entries({ ID: cds.utils.uuid(), requestId: requestId, customer: customerId })
            if (impacted === false && exists) await UPDATE('REQUEST_IMPACTED_CUSTOMERS') .set({deleted: true, deletedAt: oRequest.timestamp, deletedBy: oRequest.user.id }) .where({ requestId: requestId, customer: customerId })
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
    }

}

module.exports = {
    CustomersCode
}