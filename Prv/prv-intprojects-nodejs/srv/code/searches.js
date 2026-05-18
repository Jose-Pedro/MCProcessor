const cds = require('@sap/cds-dk/lib/cds')
const { GlobalConstants } = require('../utils/enumerations')
const { UserCode } = require('./users')

class SearchCode {

    constructor() {
        this.logger = cds.log('[InternalProjects][Search]')
    }

    onReadSearch = async (oRequest) => {
        //Check user roles
        let sExpresion
        let oUserVendor
        let oUserAgency
        let oUserCustomer

        await UserCode.currentUserDetails(oRequest)

        let aUserCountries = oRequest.agoraCurrentUserData.countries
        let aUserRoles = oRequest.agoraCurrentUserData.roles
        let isInternal = oRequest.agoraCurrentUserData.isCellnex
        let isManager = oRequest.agoraCurrentUserData.isManager
        let isVendorManager = oRequest.agoraCurrentUserData.isVendorManager
        let isVendor = oRequest.agoraCurrentUserData.isVendor
        let isAgency = oRequest.agoraCurrentUserData.isAgency
        let isCustomer = oRequest.agoraCurrentUserData.isCustomer

        //Get ECC parameters for external users
        if (isVendor || isVendorManager) oUserVendor = oRequest.agoraCurrentUserData.vendor
        if (isAgency) oUserAgency = oRequest.agoraCurrentUserData.agency
        if (isCustomer) oUserCustomer = oRequest.agoraCurrentUserData.customer

        // get searchType
        let aWhere = 'where' in oRequest.query.SELECT ? oRequest.query.SELECT.where : []
        let aNewWhere = []
        let iSearchType
        for (let i = 0; i < aWhere.length; i++) {
            if (typeof aWhere[i] === 'object' && 'ref' in aWhere[i] && Array.isArray(aWhere[i].ref) && aWhere[i].ref[0] === 'searchType') {
                aNewWhere.pop()
                iSearchType = aWhere[i + 2].val
                i = i + 3
            } else {
                aNewWhere.push(aWhere[i])
            }
        }

        if (aNewWhere.length > 0) aNewWhere = ['(', ...aNewWhere, ')' ] //Add parenthesis to handle incoming or

        console.log('[Authlog] User: ' + oRequest.user.id + ' Is internal ' + isInternal + ' is mamager ' + isManager + ' is Vendor ' + isVendor + ' vendorId ' + JSON.stringify(oRequest.agoraCurrentUserData.vendor))
        console.log('[Authlog] Roles: ' + JSON.stringify(oRequest.user.roles))

        if (iSearchType === GlobalConstants.SEARCH_BY_ROL) {
            if (isInternal) {
                if (!isManager) {
                    let aUserGroups = aUserRoles.map((oRol) => { return oRol.IAS_GROUP })
                    if (aUserGroups.length === 1) {
                        sExpresion = `roleId = '${aUserGroups[0]}'`
                    } else {
                        sExpresion = `roleId in (`
                        for (let i = 0; i < aUserGroups.length; i++) {
                            if (i !== 0) sExpresion = sExpresion + ','
                            sExpresion = sExpresion + `'${aUserGroups[i]}'`
                        }
                        sExpresion = sExpresion + ')'
                    }
                }
            } else {
                if (isCustomer) {
                    sExpresion = `( customer = '${oUserCustomer}' or validator = '${oUserCustomer}' )`
                } else if (isVendor) {
                    sExpresion = `( preferredProvider = '${oUserVendor}' or assignedResponsible = '${oUserVendor}' or validator = '${oUserVendor}' )`
                } else if (isAgency) {
                    sExpresion = `( preferredProvider = '${oUserVendor}' or assignedResponsible = '${oUserAgency}' or validator = '${oUserVendor}' )`
                } else {
                    oRequest.error(401, 'notAuthorized')
                }
            }
        } else {
            if (isInternal) {
                if (isManager) {
                    sExpresion = `( assignedResponsible = '${oRequest.user.id}' or manager = '${oRequest.user.id}' )`
                } else {
                    sExpresion = `assignedResponsible = '${oRequest.user.id}'`
                }
            } else {
                if (isCustomer) {
                    sExpresion = `customer = '${oUserCustomer}'`
                } else if (isVendor) {
                    sExpresion = `( preferredProvider = '${oUserVendor}' or assignedResponsible = '${oUserVendor}' or validator = '${oUserVendor}' )`
                } else if (isAgency) {
                    sExpresion = `( preferredProvider = '${oUserVendor}' or assignedResponsible = '${oUserAgency}' or validator = '${oUserAgency}' )`
                } else {
                    oRequest.error(401, 'notAuthorized')
                }
            }
        }

        if (!oRequest.errors) {
            let sTable = oRequest.target.name === 'project.SearchByTasks'? 'SEARCH_BY_TASKS': 'SEARCH_BY_REQUESTS'
            //get internal query
            let oQuery = cds.parse.cql(`SELECT * from ${sTable}`)
            oQuery.SELECT.columns = oRequest.query.SELECT.columns
            oQuery.SELECT.limit = oRequest.query.SELECT.limit
            oQuery.SELECT.orderBy = oRequest.query.SELECT.orderBy
            oQuery.SELECT.where = aNewWhere

            // add filters for users
            if (sExpresion) {
                let oFilter = cds.parse.expr(sExpresion)
                if (aNewWhere.length > 0) {
                    oQuery.SELECT.where.push('and')
                    oQuery.SELECT.where.push('(')
                    oQuery.SELECT.where.push(...oFilter.xpr)
                    oQuery.SELECT.where.push(')')
                } else {
                    oQuery.SELECT.where.push('(')
                    oQuery.SELECT.where.push(...oFilter.xpr)
                    oQuery.SELECT.where.push(')')
                }
            }

            // add user country             
            if (aUserCountries.length > 0) {
                let aCountries = aUserCountries.map((oCountry) => { return oCountry.COUNTRY_ID })
                if (aUserCountries.length === 1) {
                    sExpresion = `country = '${aCountries[0]}'`
                } else {
                    sExpresion = `country in (`
                    for (let i = 0; i < aCountries.length; i++) {
                        if (i !== 0) sExpresion = sExpresion + ','
                        sExpresion = sExpresion + `'${aCountries[i]}'`
                    }
                    sExpresion = sExpresion + ')'
                }

                if (sExpresion) {
                    let oFilter = cds.parse.expr(sExpresion)
                    if (aNewWhere.length > 0) {
                        oQuery.SELECT.where.push('and')
                        oQuery.SELECT.where.push(...oFilter.xpr)
                    } else {
                        oQuery.SELECT.where.push(...oFilter.xpr)
                    }
                }
            } else {
                oRequest.error(400, 'noCountriesForUser')
            }

            if (!oRequest.errors) {
                let bIsCount = oRequest._.req.query.$count || (oQuery.SELECT.columns[0] && oQuery.SELECT.columns[0].func === 'count')
                // group by requested fields (only for non-aggregate listings, to deduplicate rows expanded via $expand)
                if (!bIsCount) {
                    oQuery.SELECT.groupBy = []
                    for (let oColumn of oQuery.SELECT.columns) {
                        if (oColumn && typeof oColumn === 'object' && !('expand' in oColumn) && !('func' in oColumn)) oQuery.SELECT.groupBy.push(oColumn)
                    }
                }
                let aResults = await cds.run(oQuery)
                if ( oRequest._.req.query.$count || oRequest.query.SELECT.columns[0].func === 'count') {
                    let oCountQuery = cds.parse.cql(`SELECT count(*) as count from ${sTable}`)
                    oCountQuery.SELECT.where = oQuery.SELECT.where
                    let aCount = []
                    aCount = await cds.run(oCountQuery)
                    aResults.$count = aCount.length > 0 && aCount[0].count? aCount[0].count: 0
                }
                oRequest.reply(aResults)
            }
        }

    }

}

module.exports = { SearchCode }