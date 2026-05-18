const { RequestStatus, AssignedResponsibleTypes, SubcoTypes } = require('./enumerations')
const { getDefaultCreationObject } = require('./unboundactions')

const setRequestStatus = async (oRequest, status, sId) => {
    if (status === RequestStatus.REQUEST_COMPLETED) {
        await UPDATE`REQUEST_HEAD`.set({ 'REQUEST_STATUS': status, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id, 'ENDED_AT': oRequest.timestamp }).where`REQUEST_ID = ${sId}`
    } else if ( status === RequestStatus.REQUEST_REOPENED ) {
        await UPDATE`REQUEST_HEAD`.set({ 'REQUEST_STATUS': status, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id, 'ENDED_AT': null, 'CANCELLATION_REASON': null, 'CANCELLATION_COMMENTS': null  }).where`REQUEST_ID = ${sId}`
    } else {
        await UPDATE`REQUEST_HEAD`.set({ 'REQUEST_STATUS': status, 'MODIFIEDAT': oRequest.timestamp, 'MODIFIEDBY': oRequest.user.id }).where`REQUEST_ID = ${sId}`
    }
    //NOSONAR await SalesForceHelper.notifySalesForceRequestStatusChange(sId, RequestStatus.status);
}

const checkCreationData = async (oRequest, sCreation) => {
    let oCreationData = await getDefaultCreationObject(oRequest)
    if (oCreationData) {
        let oSelectedCreationConfig
        for (let oCreationConfig of oCreationData.CreationConfigs) {
            if (oCreationConfig && oCreationConfig.ID === sCreation) {
                oSelectedCreationConfig = oCreationConfig
                break
            }
        }
        if (oSelectedCreationConfig) {
            for(let oField of oSelectedCreationConfig.Fields) {
                if (oField.mandatory === true ) {
                    if (oField.name in oRequest.data && oRequest.data[oField.name] ) {
                    } else {
                        let defaultValue = getFieldCreationConfigDefault(oField)
                        if (defaultValue) {
                            oRequest.data[oField.name] = defaultValue
                        } else {
                            oRequest.error(400, 'missingMandatory', `/Requests/${oField.name}`, [oField.name])
                        }
                    }
                } else {
                    let defaultValue = getFieldCreationConfigDefault(oField)
                    if (defaultValue) oRequest.data[oField.name] = defaultValue
                }
            }
        } else {
            oRequest.error(400, 'missingConfiguration')
        }
    } else {
        oRequest.error(400, 'missingConfiguration')
    }
}

const getFieldCreationConfigDefault = (oField) => {
    let defaultValue 
    if(oField.defaultValueInteger) {
        defaultValue = oField.defaultValueInteger
    } else if (oField.defaultValueString) {
        defaultValue = oField.defaultValueString
    } else if (oField.defaultValueDate) {
        defaultValue = oField.defaultValueDate
    }
    return defaultValue
}

const checkCancelReason = async (oRequest, sReason) => {
    if (sReason === null || sReason === '') {
        oRequest.error(400, 'cancelReasonMandatory')
    } else {
        let oReason = await SELECT .one .from `CANCELLATION_REASONS` .where `code = ${sReason}`
        if (!oReason) oRequest.error(400, 'onCancelReasonNotValid')
    }
}

const checkOnHoldReason = async (oRequest, sReason) => {
    if (sReason === null || sReason === '') {
        oRequest.error(400, 'onHoldReasonMandatory')
    } else {
        let oReason = await SELECT .one .from `ON_HOLD_REASONS` .where `code = ${sReason}`
        if (!oReason) oRequest.error(400, 'onHoldReasonNotValid')
    }
}

const checkSite = async (oRequest) => {
    if (oRequest.data.siteId ) {
        let sAotype = '0' + oRequest.agoraCurrentUserData.country
        let oSite = await SELECT .one .from `SITES_BY_AOTYPE(p_aotype: ${sAotype})` .where `siteId = ${oRequest.data.siteId}`

        if (oSite) {
            return oSite
        } else {
            oRequest.error(400, 'noValidSite')
        }
    } else {
        oRequest.error(400, 'noSite')
    }
}

//NOSONAR const isValidcheckProjectObjective = async (oRequest) => {
//NOSONAR     let oObjective = await SELECT .one .from `PROJECT_OBJECTIVES` .where `ID = ${oRequest.data.projectObjective}`
//NOSONAR     if(!oObjective) oRequest.error(400, 'invalidProjectObjective')
//NOSONAR }

const updatePreferredProvider = async (oRequest) => {
    let sPreferredProvider = oRequest.data.preferredProvider

    try {
        let sBlocksQuery = `UPDATE BLOCKS_PROVISIONING AS bp
            SET bp.PROVIDER_NAME = '${sPreferredProvider}'
            WHERE bp.ASSIGNED_RESPONSIBLE = '${AssignedResponsibleTypes.EXTERNAL}'
            AND bp.SUBCONTRACTOR_TYPE = '${SubcoTypes.VENDOR}'
            AND (bp.PROVIDER_NAME IS NULL OR bp.PROVIDER_NAME = '')
            AND bp.BLOCK_ID IN (SELECT bh.BLOCK_ID
                FROM BLOCK_HEAD AS bh
                INNER JOIN PHASE_HEAD AS ph ON bh.PHASE_ID = ph.PHASE_ID
                INNER JOIN REQUEST_HEAD AS rh ON ph.REQUEST_ID = rh.REQUEST_ID
                WHERE rh.REQUEST_ID = '${oRequest.data.ID}')`.replace(/[\r\n\t]+/g, ' ').replace(/\s+/g, ' ').trim()
        let sWorksQuery = `UPDATE WORKS as w
            SET w.externalResponsible = '${sPreferredProvider}'
            WHERE w.responsibleType = '${AssignedResponsibleTypes.EXTERNAL}'
            AND w.externalType = '${SubcoTypes.VENDOR}'
            AND (w.externalResponsible IS NULL OR w.externalResponsible = '')
            AND w.parentId IN (SELECT bh.BLOCK_ID
                FROM BLOCK_HEAD as bh
                INNER JOIN PHASE_HEAD as ph ON bh.PHASE_ID = ph.PHASE_ID
                INNER JOIN REQUEST_HEAD as rh ON ph.REQUEST_ID = rh.REQUEST_ID
                WHERE rh.REQUEST_ID = '${oRequest.data.ID}')`.replace(/[\r\n\t]+/g, ' ').replace(/\s+/g, ' ').trim()
        let sDPBQuery = `UPDATE DOCUMENTS_PER_BLOCK as dpb
            SET dpb.T_RESPONSIBLE = ${sPreferredProvider}
            WHERE dpb.RESPONSIBLE_ID = ${AssignedResponsibleTypes.EXTERNAL}
            AND dpb.SUBCONTRATOR_ID = ${SubcoTypes.VENDOR}
            AND (dpb.T_RESPONSIBLE IS NULL OR dpb.T_RESPONSIBLE = '')
            AND dpb.BLOCK_ID IN (SELECT bh.BLOCK_ID
                FROM BLOCK_HEAD as bh
                INNER JOIN PHASE_HEAD as ph ON bh.PHASE_ID = ph.PHASE_ID
                INNER JOIN REQUEST_HEAD as rh ON ph.REQUEST_ID = rh.REQUEST_ID
                WHERE rh.REQUEST_ID = '${oRequest.data.ID}')`.replace(/[\r\n\t]+/g, ' ').replace(/\s+/g, ' ').trim()

        await cds.run(sWorksQuery)
        await cds.run(sBlocksQuery)
        await cds.run(sDPBQuery)
    } catch (oError) {
        console.log (oError.message)
    }
}

module.exports = {
    setRequestStatus,
    checkCreationData,
    checkCancelReason,
    checkOnHoldReason,
    checkSite,
    //NOSONAR isValidcheckProjectObjective,
    updatePreferredProvider
}