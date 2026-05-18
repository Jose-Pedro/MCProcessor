const { getCountries, getRoles, getCompanies, getAgency, getVendor, getCustomer } = require('../utils/userInfo')
const { Roles } = require('../utils/enumerations')

const UserCode = {

    _requestPromiseCache: new Map(),

    currentUserDetails: async oRequest => {

        const requestId = oRequest.id

        if (UserCode._requestPromiseCache.has(requestId)) {
            await UserCode._requestPromiseCache.get(requestId)
            return
        }

        const processingPromise = (async () => {
            try {
                let aCountries = await getCountries(oRequest.user.id)
                let aCompanies = await getCompanies(oRequest.user.id)
                let aRoles = await getRoles(oRequest.user.id)
                let oVendor = await getVendor(oRequest.user.id)
                let oAgency = await getAgency(oRequest.user.id)
                let oCustomer = await getCustomer(oRequest.user.id)

                oRequest.agoraCurrentUserData = {
                    roles: aRoles? aRoles: [],
                    countries: aCountries? aCountries: [],
                    country: aCountries && aCountries.length > 0? aCountries[0].COUNTRY_ID: null,
                    companies: aCompanies? aCompanies: [],
                    hasNoCountry: aCountries.length <= 0,
                    isMultiCountry: aCountries.length > 1,
                    isManager: oRequest.user.is( Roles.MANAGER_USER_ROL ),
                    isVendor: oRequest.user.is( Roles.VENDOR_USER_ROL ),
                    isVendorManager: oRequest.user.is(Roles.VENDOR_MANAGER_USER_ROL),
                    isCustomer: oRequest.user.is(Roles.CUSTOMER_USER_ROL),
                    isAgency: oRequest.user.is(Roles.AGENCY_USER_ROL),
                    isCellnex: oRequest.user.is( Roles.CELLNEX_USER_ROL )
                }
                if(oVendor) oRequest.agoraCurrentUserData.vendor = oVendor.ZVENDOR_ID
                if(oAgency) oRequest.agoraCurrentUserData.agency = oAgency.ZAGENCY_ID
                if(oCustomer) oRequest.agoraCurrentUserData.customer = oCustomer.ZCUSTOMER_ID

            } catch (oError) {
                oRequest.reject(400, oError.message)
                throw oError
            } finally {
                UserCode._requestPromiseCache.delete(requestId)
            }
        })()

        UserCode._requestPromiseCache.set(requestId, processingPromise)
        await processingPromise
    }

}

module.exports = {
    UserCode
}