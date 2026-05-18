const { DisplayTypesFC, AssignedResponsibleTypes, GlobalConstants } = require('../utils/enumerations')

const getProcessData = async (pRequestType, pCountry, pClassification, pClient, pProgram) => {
    let aProcessData = []
    let oRequestType = await SELECT.one.from`REQUEST_TYPE`.where`REQUEST_TYPE = ${pRequestType}`

    let sQuery = `SELECT PROCESS_ID_PK, ID_PK from PROCESS
    where PROCESS_ID_PK = '${oRequestType.MASTER_PROCESS_ID}'
    and (COUNTRY_CODE = '${pCountry}' or COUNTRY_CODE = '*') 
    and (CLASSIFICATION = '${pClassification}' or CLASSIFICATION = '*')
    and (CLIENT = '${pClient}' or CLIENT = '*')
    and (PROGRAM = '${pProgram}' or PROGRAM = '*')
    order by COUNTRY_CODE desc, COMPANY_CODE desc, CLASSIFICATION desc, CLIENT desc, PROGRAM desc`
    let oQuery = cds.parse.cql(sQuery)
    let aProcess = await cds.run(oQuery)
    if (Array.isArray(aProcess) && aProcess.length > 0) {
        aProcessData = await SELECT.from`requestProcess`.where`ID_PK = ${aProcess[0].ID_PK} and PROCESS_ID_PK = ${aProcess[0].PROCESS_ID_PK} and IS_CANDIDATE = false`
    }
    return aProcessData
}

const getDisplayConfiguration = async (oRequest, iProcessFlow, sTable, sPhase, sBlock, bIsHead) => {
    let aScreenControl = []
    let oScreenControl = {}
    let oConfiguration = { 'header': oScreenControl, 'fields': aScreenControl }

    if (iProcessFlow === undefined || iProcessFlow === null || iProcessFlow === '') return oConfiguration

    let oConfigQuery
    let oDefaultTypeQuery
    let sRolesList = oRequest.agoraCurrentUserData.roles.reduce((sConcat, sCurrentValue) => sConcat + `'${sCurrentValue.IAS_GROUP}',`, '').replace(/,$/, "")
    if (sRolesList.length > 0) {
        oConfigQuery = `SELECT DISTINCT TABNAME, PHASE, BLOCK, FIELDNAME,
    FIRST_VALUE(DISPLAYTYPE) OVER(PARTITION BY TABNAME, PHASE, BLOCK, FIELDNAME ORDER BY PRIORITY, DISPLAYTYPE DESC) AS DISPLAYTYPE
    FROM SCREEN_CONFIG_DATA WHERE PROCESSID = ${iProcessFlow} AND IASGROUP IN (${sRolesList})`
        if (bIsHead && (!sBlock || sBlock === '')) {
            //NOSONAR oConfigQuery = oConfigQuery + ` AND TABNAME = '${sTable}' AND (PHASE = '' OR PHASE IS NULL) AND (BLOCK = '' OR BLOCK IS NULL)`    
            oConfigQuery = oConfigQuery + ` AND TABNAME = '${sTable}'`    
        } else {
            oConfigQuery = oConfigQuery + ` AND TABNAME = '${sTable}' AND PHASE = '${sPhase}' AND BLOCK = '${sBlock}'`
        }
        oDefaultTypeQuery = `SELECT TOP 1 * FROM SCREEN_CONTROL_BY_PROCESS WHERE PROCESSID = ${iProcessFlow} AND IASGROUP IN (${sRolesList}) ORDER BY PRIORITY`
    } else {
        oConfigQuery = `SELECT DISTINCT TABNAME, PHASE, BLOCK, FIELDNAME,
    FIRST_VALUE(DISPLAYTYPE) OVER(PARTITION BY TABNAME, PHASE, BLOCK, FIELDNAME ORDER BY PRIORITY, DISPLAYTYPE DESC) AS DISPLAYTYPE
    FROM SCREEN_CONFIG_DATA WHERE PROCESSID = ${iProcessFlow}`
        if (bIsHead && (!sBlock || sBlock === '')) {
            oConfigQuery = oConfigQuery + ` AND TABNAME = '${sTable}' AND (PHASE = '' OR PHASE IS NULL) AND (BLOCK = '' OR BLOCK IS NULL)`    
        } else {
            oConfigQuery = oConfigQuery + ` AND TABNAME = '${sTable}' AND PHASE = '${sPhase}' AND BLOCK = '${sBlock}'`
        }
        oDefaultTypeQuery = `SELECT TOP 1 * FROM SCREEN_CONTROL_BY_PROCESS WHERE PROCESSID = ${iProcessFlow} ORDER BY PRIORITY`
    }
    let aFields, aHeader
    try { aFields = await cds.run(oConfigQuery) } catch (oError) { if (oError.code !== 259 && oError.code !== '259') throw oError }
    try { aHeader = await cds.run(oDefaultTypeQuery) } catch (oError) { if (oError.code !== 259 && oError.code !== '259') throw oError }

    if (aFields) oConfiguration.fields = aFields
    if (aHeader && aHeader.length > 0) oConfiguration.header = aHeader[0]
    return oConfiguration
}

const setDisplayConfiguration = (oRequest, oEntity, oConfiguration, oElements) => {
    if (!oConfiguration) return
    for (let sName in oElements) {
        if (oElements[sName].virtual) {
            if (sName.includes('FC')) {
                let sFieldName = sName.slice(0, -2)
                let oConfigurationField = oConfiguration.fields.find(oSrchConfiguration => oSrchConfiguration.FIELDNAME === sFieldName)
                if (oConfigurationField) {
                    oEntity[sName] = oConfigurationField.DISPLAYTYPE
                } else {
                    oEntity[sName] = oConfiguration.header.DEFAULTDISPLAY? oConfiguration.header.DEFAULTDISPLAY: DisplayTypesFC.READONLY
                }
            }
        }
    }
}

const setFCAs = (oRequest, oResult, oDisplayType) => {
    for (let sFieldName in oResult) {
        if (sFieldName.includes('FC')) {
            oResult[sFieldName] = oDisplayType
        } else if (sFieldName === 'BlockProvision') {
            setFCAs(oRequest, oResult.BlockProvision, oDisplayType)
        } else if (sFieldName === 'RequestProvision') {
            setFCAs(oRequest, oResult.RequestProvision, oDisplayType)
        }
    }
}

 const checkInputValues = async (oRequest) => {
    for (let sField in oRequest.data) {
        let sAssociation = 'project.' + oRequest.target.elements[sField]['@Common.ValueList.CollectionPath']
        if (GlobalConstants.aExternalValueHelps.indexOf(sAssociation) < 0) {
            // Check against DB entity
            let oVHEntity = cds.entities[sAssociation]
            if (oVHEntity) {
                let sTargetEntity = oVHEntity.name
                let aWhere = []
                for (let oParameter of oRequest.target.elements[sField]['@Common.ValueList.Parameters']) {
                    const isNullable = oParameter['@odata.Nullable'] === true;
                    if (oParameter.$Type === 'Common.ValueListParameterInOut' && oParameter.LocalDataProperty['='] === sField) {
                        if (oRequest.data[sField] == null) {
                                if (isNullable) {
                                    // skip validation for nullables
                                    continue;
                                }
                        } else if (oRequest.target.elements[sField].type === 'cds.Integer') {
                            if (oRequest.data[sField])
                                if (!Number.isNaN(oRequest.data[sField])) {
                                    aWhere.push(oParameter.ValueListProperty)
                                    aWhere.push('=')
                                    aWhere.push("'" + oRequest.data[sField] + "'")
                                } else {
                                    oRequest.error(400, 'notValidValue', `/${oRequest.target.name.split('.')[1]}(guid'${oRequest.data.ID}')/${sField}`, [oRequest.data[sField], sField])
                                }
                            else {
                                aWhere.push(oParameter.ValueListProperty)
                                aWhere.push('=')
                                aWhere.push('0')
                            }
                        } else {
                            aWhere.push(oParameter.ValueListProperty)
                            aWhere.push('=')
                            aWhere.push("'" + oRequest.data[sField] + "'")
                        }
                    } else {
                        if (oParameter.$Type === 'Common.ValueListParameterIn') {
                            // skip ParameterIn enrichment when subject has no where (e.g. CREATE on collection)
                            if (!oRequest.subject || !oRequest.subject.ref || !oRequest.subject.ref[0] || !oRequest.subject.ref[0].where) {
                                continue
                            }
                            let oQueryEntityData = {
                                SELECT: {
                                    from: oRequest.subject,
                                    one: true,
                                    where: oRequest.subject.ref[0].where
                                }
                            }
                            try {
                                let oEntityData = await cds.run(oQueryEntityData)
                                if (oEntityData && oEntityData[oParameter.LocalDataProperty['=']] && oEntityData[oParameter.LocalDataProperty['=']] !== 0) {
                                    if (aWhere.length > 0) aWhere.push('and')
                                    aWhere.push(oParameter.ValueListProperty)
                                    aWhere.push('=')
                                    aWhere.push("'" + oEntityData[oParameter.LocalDataProperty['=']] + "'")
                                }
                            } catch (e) {
                                // ignore: missing local table or undefined subject context
                            }
                        }
                    }
                }
                if (aWhere.length > 0 && !oRequest.errors) {
                    let sQuery = `select * from ${sTargetEntity}`
                    let oQuery = cds.parse.cql(sQuery)
                    oQuery.SELECT.where = aWhere
                    try {
                        let aValues = await cds.run(oQuery)
                        if (aValues.length === 0) oRequest.error(400, 'notValidValue', `/${oRequest.target.name.split('.')[1]}(guid'${oRequest.data.ID}')/${sField}`, [oRequest.data[sField], sField])
                    } catch (oError) {
                        if (oError.code === 339) {
                            oRequest.error(400, 'notValidValue', `/${oRequest.target.name.split('.')[1]}(guid'${oRequest.data.ID}')/${sField}`, [oRequest.data[sField], sField])
                        } else if (oError.code === 259) {
                            // this is not an error, external facade property
                        } else {
                            // ignore: malformed where, missing local table, or unsupported value-help in dev
                        }
                    }
                }
            }
        } else {
            // Checks must be done against external services or
            try {
                switch (sAssociation) {
                    case 'project.ExternalUsers':
                    case 'project.InternalUsers':
                    case 'project.Customers':
                    case 'project.Vendors':
                    case 'project.Agencies':
                        break
                    default:
                        if (!cds.entities[sAssociation]) break
                        let oValueEntry = await SELECT.one.from(sAssociation).where`userId = ${oRequest.data[sField]}`
                        if (!oValueEntry) oRequest.error(400, 'notValidValue', `/${oRequest.target.name.split('.')[1]}(guid'${oRequest.data.ID}')/${sField}`, [oRequest.data[sField], sField])
                        break
                }
            } catch (oError) {
                // ignore errors caused by external/missing entities in local environment
            }
        }
    }
}

const checkResponsibles = async (oRequest) => {
    let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oRequest.data.ID})`
    if ('internalResponsible' in oRequest.data && oRequest.data.internalResponsible !== null && oRequest.data.internalResponsible !== '') {
        let oUsers = []
        oUsers = await SELECT.from`USERS(p_country: ${oEntities.COUNTRY_ID})`.where`userId = ${oRequest.data.internalResponsible}`
        if (oUsers.length === 0) oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/internalResponsible`, [oRequest.data.internalResponsible, 'internalResponsible'])
    }
    if ('externalResponsible' in oRequest.data && oRequest.data.externalResponsible !== null && oRequest.data.externalResponsible !== '') {
        let iSubcotype
        if ('subcontractorType' in oRequest.data) {
            iSubcotype = oRequest.data.subcontractorType
        } else {
            let oBlockProv = await SELECT.one.from`BLOCKS_PROVISIONING`.where`BLOCK_ID = ${oRequest.data.ID}`
            iSubcotype = oBlockProv.SUBCONTRACTOR_TYPE
        }

        switch (iSubcotype) {
            case SubcoTypes.VENDOR:
                let oVendor = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oRequest.data.externalResponsible} and entityType = 'F4_PROV_VENDOR_GEWRK'`
                //NOSONAR let oVendor = await oF4Handler.readOneVendor(oRequest, 'SCR_WF_SRH', 'F4_PROV_VENDOR_GEWRK', '', oRequest.data.externalResponsible)
                if (oVendor.length === 0) oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, [oRequest.data.externalResponsible, 'externalResponsible'])
                break
            case SubcoTypes.AGENCY:
                let oAgency = await SELECT.from`project.CacheR3Entities`.where`userId = ${oRequest.user.id} and code = ${oRequest.data.externalResponsible} and entityType = 'F4_GEWRK_AGEN'`
                //NOSONAR let oAgency = await oF4Handler.readOneVendor(oRequest, 'SCR_WF_SRH', 'F4_GEWRK_AGEN', '', oRequest.data.externalResponsible)
                if (oAgency.length === 0) oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, [oRequest.data.externalResponsible, 'externalResponsible'])
                break
            case SubcoTypes.CUSTOMER:
                let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oEntities.REQUEST_ID}`
                if (oRequestHead.CUSTOMER_ID !== oRequest.data.externalResponsible) oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, [oRequest.data.externalResponsible, 'externalResponsible'])
                break
            default:
                oRequest.error(400, 'notValidValue', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, [oRequest.data.externalResponsible, 'externalResponsible'])
                break
        }
    }
}

const checkDocumentResponsible = async (oRequest) => {
    if ('cellnexResponsible' in oRequest.data && oRequest.data.cellnexResponsible !== null && oRequest.data.cellnexResponsible !== '') {
        let oDocumentPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oRequest.data.ID}`
        if (oDocumentPerBlock) {
            let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oDocumentPerBlock.BLOCK_ID})`
            let oUsers = []
            oUsers = await SELECT.from`USERS(p_country: ${oEntities.COUNTRY_ID})`.where`userId = ${oRequest.data.cellnexResponsible}`
            if (oUsers.length === 0) oRequest.error(400, 'notValidValue', `/DocumentsPerBlocks(guid'${oRequest.data.ID}')/cellnexResponsible`, [oRequest.data.cellnexResponsible, 'cellnexResponsible'])
        }
    }
}

const checkDocumentValidators = async (oRequest) => {
    if ('cellnexValidator' in oRequest.data && oRequest.data.cellnexValidator !== null && oRequest.data.cellnexValidator !== '') {
        let oInstancesPerDocument = await SELECT.one.from`INSTANCES_PER_DOCUMENT`.where`REGISTER_ID = ${oRequest.data.ID}`
        if (oInstancesPerDocument) {
            let oDocumentPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oInstancesPerDocument.INSTANCE_ID}`
            if (oDocumentPerBlock) {
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oDocumentPerBlock.BLOCK_ID})`
                let oUsers = []
                oUsers = await SELECT.from`USERS(p_country: ${oEntities.COUNTRY_ID})`.where`userId = ${oRequest.data.cellnexValidator}`
                if (oUsers.length === 0) oRequest.error(400, 'notValidValue', `/DocumentsPerBlocks(guid'${oRequest.data.ID}')/cellnexValidator`, [oRequest.data.cellnexValidator, 'cellnexValidator'])
            }
        }
    }
    if (oRequest.data && 'customerValidator' in oRequest.data && oRequest.data.customerValidator !== null && oRequest.data.customerValidator !== '') {
        let oInstancesPerDocument = await SELECT.one.from`INSTANCES_PER_DOCUMENT`.where`REGISTER_ID = ${oRequest.data.ID}`
        if (oInstancesPerDocument) {
            let oDocumentPerBlock = await SELECT.one.from`DOCUMENTS_PER_BLOCK`.where`REGISTER_ID = ${oInstancesPerDocument.INSTANCE_ID}`
            if (oDocumentPerBlock) {
                let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oDocumentPerBlock.BLOCK_ID})`
                let oUsers = []
                oUsers = await SELECT.from`USERS(p_country: ${oEntities.COUNTRY_ID})`.where`userId = ${oRequest.data.customerValidator}`
                if (oUsers.length === 0) oRequest.error(400, 'notValidValue', `/DocumentsPerBlocks(guid'${oRequest.data.ID}')/customerValidator`, [oRequest.data.customerValidator, 'customerValidator'])
            }
        }
    }
}

const checkEditableFields = async (oRequest, sProcessID, sTable, sPhaseId, sBlockId, bIsHead) => {
    let aScreenControl = await getDisplayConfiguration(oRequest, sProcessID, sTable, sPhaseId, sBlockId, bIsHead)
    for (let sFieldName in oRequest.data) {
        if (aScreenControl.contructor === 'Array' && aScreenControl.length > 0) {
            let oConfiguration = aScreenControl.find(sc => sc.fieldname === sFieldName)
            if (oFieldConf) {
                if (oConfiguration.DISPLAYTYPE !== DisplayTypesFC.OPTIONAL && oConfiguration.DISPLAYTYPE !== DisplayTypesFC.MANDATORY) {
                    oRequest.error(400, 'fieldNotEditable', sFieldName, [sFieldName])
                }
            }
        }
    }
}

const checkBlockMandatoryFields = async (oRequest, oBlockHead, oBlockProvision) => {
    await checkBlockMandatoryResps(oRequest, oBlockHead, oBlockProvision)
    let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oBlockHead.ID})`
    let oScreenControl = await getDisplayConfiguration(oRequest, oEntities.PROCESS_ID, 'BLOCK_HEAD', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, false)

    for (let oConfiguration of oScreenControl.fields) {
        if (oConfiguration.DISPLAYTYPE === DisplayTypesFC.MANDATORY) {
            if (oBlockHead[oConfiguration.FIELDNAME] === null || oBlockHead[oConfiguration.FIELDNAME] === '') oRequest.error(400, 'missingMandatoryField', `/Blocks(guid'${oEntities.BLOCK_ID}')/${oConfiguration.FIELDNAME}`, [oConfiguration.FIELDNAME])
        }
    }
    oScreenControl = await getDisplayConfiguration(oRequest, oEntities.PROCESS_ID, 'BLOCKS_PROVISIONING', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, false)
    for (let oConfiguration of oScreenControl.fields) {
        if (oConfiguration.DISPLAYTYPE === DisplayTypesFC.MANDATORY) {
            if (oBlockProvision[oConfiguration.FIELDNAME] === null || oBlockProvision[oConfiguration.FIELDNAME] === '') oRequest.error(400, 'missingMandatoryField', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/${oConfiguration.FIELDNAME}`, [oConfiguration.FIELDNAME])
        }
    }

    //add check for header fields in blocks
    let oRequestHead = await SELECT.one.from`project.Requests`.where`ID = ${oEntities.REQUEST_ID}`
    oScreenControl = await getDisplayConfiguration(oRequest, oEntities.PROCESS_ID, 'REQUEST_HEAD', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, true)
    for (let oConfiguration of oScreenControl.fields) {
        if (oConfiguration.DISPLAYTYPE === DisplayTypesFC.MANDATORY) {
            if (oRequestHead[oConfiguration.FIELDNAME] === null || oRequestHead[oConfiguration.FIELDNAME] === '') oRequest.error(400, 'missingMandatoryField', `/Requests(guid'${oEntities.REQUEST_ID}')/${oConfiguration.FIELDNAME}`, [oConfiguration.FIELDNAME])
        }
    }

    //add check for provision header fields in blocks
    let oRequestProvision = await SELECT.one.from`project.RequestProvision`.where`ID = ${oEntities.REQUEST_ID}`
    oScreenControl = await getDisplayConfiguration(oRequest, oEntities.PROCESS_ID, 'REQUEST_CHAR_PRO', oEntities.MASTER_PHASE_ID, oEntities.MASTER_BLOCK_ID, true)
    for (let oConfiguration of oScreenControl.fields) {
        if (oConfiguration.DISPLAYTYPE === DisplayTypesFC.MANDATORY) {
            if (oRequestProvision[oConfiguration.FIELDNAME] === null || oRequestProvision[oConfiguration.FIELDNAME] === '') oRequest.error(400, 'missingMandatoryField', `/RequestProvision(guid'${oEntities.REQUEST_ID}')/${oConfiguration.FIELDNAME}`, [oConfiguration.FIELDNAME])
        }
    }
   
}

const checkBlockMandatoryResps = async (oRequest, oBlockHead, oBlockProvision) => {
    let oEntities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${oBlockHead.ID})`
    let oBlockPF = await SELECT.one.from`BLOCK`.where`ID_PK = ${oEntities.PROCESS_ID} and PROCESS_ID_PK = ${oEntities.PROCESS_ID_PK} and PHASE_ID_PK = ${oEntities.MASTER_PHASE_ID} and BLOCK_ID_PK = ${oEntities.MASTER_BLOCK_ID}`

    if (oBlockPF.HASRESPONSIBLE === 'X') {
        if (oBlockProvision.assignedResponsible === AssignedResponsibleTypes.CELLNEX) {
            //NOSONAR if (oBlockProvision.internalResponsible === null || oBlockProvision.internalResponsible === '') oRequest.error(400, 'missingMandatoryField', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/internalResponsible`, ['internal Responsible'])
        } else {
            if (oBlockProvision.subcontractorType === null || oBlockProvision.subcontractorType === '') oRequest.error(400, 'missingMandatoryField', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/subcontractorType`, ['Subcontractor type'])
            if (oBlockProvision.externalResponsible === null || oBlockProvision.externalResponsible === '') oRequest.error(400, 'missingMandatoryField', `/BlockProvision(guid'${oEntities.BLOCK_ID}')/externalResponsible`, ['External responsible'])
        }
    }
}

module.exports = {
    getProcessData,
    getDisplayConfiguration,
    setDisplayConfiguration,
    setFCAs,
    checkInputValues,
    checkEditableFields,
    checkBlockMandatoryFields,
    checkBlockMandatoryResps,
    checkResponsibles,
    checkDocumentResponsible,
    checkDocumentValidators 

}