const { Roles } = require('./enumerations')

const getCountries = async (sUserId) => {
    let aResult = await SELECT .from `US_COUNTRIES` .where `USER_ID = ${sUserId}`
    return aResult
}

const getRoles = async (sUserId) => {
    return await SELECT .from `US_ROLES_AGR` .where `USER_ID = ${sUserId}`
}

const getCompanies = async (sUserId) => {
    return await SELECT .from `US_BUKS` .where `USER_ID = ${sUserId}`
}

const getVendor = async (sUserId) => {
    return await SELECT .one .from `US_ZVENDOR` .where `USER_ID = ${sUserId}`
}

const getCustomer = async (sUserId) => {
    return await SELECT .one .from `US_ZAGENCY` .where `USER_ID = ${sUserId}`
}

const getAgency = async (sUserId) => {
    return await SELECT .one .from `US_ZCUSTOMER` .where `USER_ID = ${sUserId}`
}

const checkUserAuth = async (oRequest, sProcessRoleId, sResponsible) => {
    if (oRequest.user.is(Roles.CELLNEX_USER_ROL)) {
        let isManager = oRequest.user.is(Roles.MANAGER_USER_ROL)
        if (oRequest.user.is(sProcessRoleId) || isManager) {
            if (isManager) {
            } else {
                if (sResponsible !== oRequest.user.id) oRequest.reject(401, 'notAuthorizedNotAssigned')
            }
        } else {
            oRequest.reject(401, 'notAuthorizedRole')
        }
    } else {
        if (oRequest.user.is(Roles.VENDOR_USER_ROL)) {
            if (oRequest.agoraCurrentUserData.vendor !== sResponsible || sResponsible === null || sResponsible === '') oRequest.reject(401, 'notAuthorizedNotAssigned')
        } else if (oRequest.user.is(Roles.AGENCY_USER_ROL)) {
            if (oRequest.agoraCurrentUserData.agency !== sResponsible || sResponsible === null || sResponsible === '') oRequest.reject(401, 'notAuthorizedNotAssigned')
        } else if (oRequest.user.is(Roles.CUSTOMER_USER_ROL)) {
            if (oRequest.agoraCurrentUserData.customer !== sResponsible || sResponsible === null || sResponsible === '') oRequest.reject(401, 'notAuthorizedNotAssigned')
        }
    }
}

module.exports = {
    getCountries,
    getRoles,
    getCompanies,
    getVendor,
    getCustomer,
    getAgency,
    checkUserAuth
}