const cds = require('@sap/cds-dk/lib/cds')
const { Actions } = require('./enumerations')
const { tx } = require('@sap/cds')
const { request } = require('express')

/**
 * Audit Logger Utility
 * Provides comprehensive logging functionality for workflow actions
 */

/**
 * Unified data fetcher that determines the appropriate method based on available parameters
 * @param {Object} oRequest - The request object
 * @param {Object} params - Parameters object containing registerId, blockId, workId, etc.
 * @returns {Promise<Object>} Request data object
 */
const fetchRequestData = async (oRequest, params = {}) => {
    const { registerId, blockId, workId, instanceId } = params

    try {
        // Priority order for fetching data based on available parameters
        // Try instanceId first (most specific)
        if (instanceId) {
            return await getRequestDataByInstanceID(oRequest, instanceId)
        }

        // Try blockId
        if (blockId) {
            return await getRequestDataByBlockID(oRequest, blockId)
        }

        // Try workId
        if (workId) {
            return await getRequestDataByWorkID(oRequest, workId)
        }

        // Try registerId - we need to determine if it's for document or instance
        if (registerId) {
            return await getRequestDataByDocumentID(oRequest, registerId)
        }

        // Fallback to request params
        if (oRequest.params && oRequest.params[0]) {
            return await getRequestDataByDocumentID(oRequest, oRequest.params[0])
        }

        throw new Error('No valid identifier provided for fetching request data')
    } catch (error) {
        throw new Error(`Failed to fetch request data: ${error.message}`)
    }
}

/**
 * Get next available action log ID for a given request
 * @param {string} requestId - The request ID
 * @returns {Promise<Object>} Object containing NEW_ID
 */
const getActionLogID = async (requestId) => {
    if (!requestId) {
        throw new Error('Request ID is required')
    }

    try {
        const logID = await cds.run(
            `SELECT IFNULL(MAX(ACTIONS_LOG_ID), 0) + 1 AS NEW_ID 
             FROM "WF_ACTIONS_LOG" 
             WHERE REQUEST_ID = '${requestId}'`
        )
        return logID[0]
    } catch (error) {
        throw new Error(`Failed to get action log ID: ${error.message}`)
    }
}

/**
 * Get request data by block ID
 * @param {Object} oRequest - The request object
 * @param {string} blockId - Block ID (optional, defaults to request params)
 * @returns {Promise<Object>} Request data
 */
const getRequestDataByBlockID = async (oRequest, blockId = null) => {
    try {
        const id = blockId || oRequest.params[0] || oRequest.data?.ID
        if (!id) {
            throw new Error('Block ID is required')
        }

        const entities = await SELECT.one.from`BLOCK_PHASE_REQUEST(p_blockId: ${id})`
        if (!entities) {
            throw new Error(`Request not found for block ID: ${id}`)
        }
        return entities
    } catch (error) {
        throw new Error(`Failed to get request data by block ID: ${error.message}`)
    }
}

/**
 * Get request data by document ID
 * @param {Object} oRequest - The request object
 * @param {string} registerId - Register ID (optional, defaults to request params)
 * @returns {Promise<Object>} Request data
 */
const getRequestDataByDocumentID = async (oRequest, registerId = null) => {
    try {
        const id = registerId || oRequest.params?.[0] || oRequest.data?.ID
        if (!id) {
            throw new Error('Register ID is required')
        }

        const result = await SELECT.one.from`BLOCK_PHASE_REQUEST_DOCUMENT(p_registerId: ${id})`
        if (!result) {
            throw new Error(`Request not found for register ID: ${id}`)
        }
        return result
    } catch (error) {
        throw new Error(`Failed to get request data by document ID: ${error.message}`)
    }
}

/**
 * Get request data by instance ID
 * @param {Object} oRequest - The request object
 * @param {string} instanceId - Instance ID (optional, defaults to request params)
 * @returns {Promise<Object>} Request data
 */
const getRequestDataByInstanceID = async (oRequest, instanceId = null) => {
    try {
        const id = instanceId || oRequest.params?.[0] || oRequest.data?.ID
        if (!id) {
            throw new Error('Instance ID is required')
        }

        const result = await SELECT.one.from`BLOCK_PHASE_REQUEST_DOCUMENT_INSTANCE(p_registerId: ${id})`
        if (!result) {
            throw new Error(`Request not found for instance ID: ${id}`)
        }
        return result
    } catch (error) {
        throw new Error(`Failed to get request data by instance ID: ${error.message}`)
    }
}

/**
 * Get request data by work ID
 * @param {Object} oRequest - The request object
 * @param {string} workId - Work ID (optional, defaults to request params)
 * @returns {Promise<Object>} Request data
 */
const getRequestDataByWorkID = async (oRequest, workId = null) => {
    try {
        const id = workId || oRequest.params?.[0] || oRequest.data?.ID
        if (!id) {
            throw new Error('Work ID is required')
        }

        const result = await SELECT.one.from`WORKS_BLOCK_PHASE_REQUEST(p_workId: ${id})`
        if (!result) {
            throw new Error(`Request not found for work ID: ${id}`)
        }
        return result
    } catch (error) {
        throw new Error(`Failed to get request data by work ID: ${error.message}`)
    }
}

/**
 * Get request type by request ID
 * @param {Object} oRequest - The request object
 * @param {string} requestId - Request ID (optional, defaults to request params)
 * @returns {Promise<string>} Request type
 */
const getRequestTypeByRequestID = async (oRequest, requestId = null) => {
    try {
        const id = requestId || oRequest.params?.[0]
        if (!id) {
            throw new Error('Request ID is required')
        }

        const requestHead = await SELECT.one('REQUEST_TYPE')
            .from('REQUEST_HEAD')
            .where({ REQUEST_ID: id })

        if (!requestHead) {
            throw new Error(`Request not found for request ID: ${id}`)
        }

        return requestHead.REQUEST_TYPE
    } catch (error) {
        throw new Error(`Failed to get request type: ${error.message}`)
    }
}

/**
 * Save audit log for entity modifications
 * @param {Object} oRequest - The request object
 * @param {string} entity - Entity type
 * @param {string} action - Action type (defaults to REQUEST_MODIFIED)
 * @returns {Promise<void>}
 */
const saveLog = async (oRequest, entity, action = Actions.REQUEST_MODIFIED) => {
    try {
        let requestData
        // Use entity-specific fetcher based on entity type
        switch (entity) {
            case 'project.Blocks': requestData = await getRequestDataByBlockID(oRequest); break;
            case 'project.DocumentsPerBlocks': requestData = await getRequestDataByDocumentID(oRequest); break;
            case 'project.InstancesPerDocuments': requestData = await getRequestDataByInstanceID(oRequest); break;
            case 'project.Works': requestData = await getRequestDataByWorkID(oRequest, oRequest.data.ID); break;
            default:
                // Default fallback for unknown entities
                requestData = {
                    MASTER_PHASE_ID: 'requestCreat',
                    MASTER_BLOCK_ID: 'requestCharact',
                    REQUEST_ID: oRequest.params[0],
                    REQUEST_TYPE: await getRequestTypeByRequestID(oRequest)
                }
        }

        if (!requestData)  throw new Error('Unable to fetch request data for logging')
        let diff = await oRequest.diff()
        
        const logId = await getActionLogID(requestData.REQUEST_ID)
        let currentLogId = logId.NEW_ID
        let entries = []
        for (let  [fieldName, oldValue] of Object.entries(diff._old)) {
            let newValue = diff[fieldName]
            let entry = {
                ACTIONS_LOG_ID   : currentLogId,
                REQUEST_ID       : requestData.REQUEST_ID,
                REQUEST_TYPE     : requestData.REQUEST_TYPE,
                DATE             : new Date().toISOString(),
                USER             : oRequest.user.id,
                ACTION           : action,
                PHASE_ID_PK      : requestData.MASTER_PHASE_ID,
                BLOCK_ID_PK      : requestData.MASTER_BLOCK_ID,
                FIELD_MOD        : fieldName,
                OLD_VALUE        : oldValue,
                NEW_VALUE        : newValue,
                PHASE_ID         : requestData.PHASE_ID,
                BLOCK_ID         : requestData.BLOCK_ID
            }

            if (entity === 'project.InstancesPerDocument' || entity === 'project.DocumentsPerBlock') entry.DOCUMENT_ID = requestData.GENERIC_TYPE_ID
            if (entity === 'project.Works' && requestData.WORK_ID) entry.WORK_ID = requestData.WORK_ID
            entries.push(entry)
            currentLogId++
        }
        if (entries.length === 0) return
        await INSERT.into('WF_ACTIONS_LOG').entries(entries)
   
        // Process each changed field
        //NOSONAR for (const [fieldName, oldValue] of Object.entries(diff._old)) {
        //NOSONAR     const newValue = diff[fieldName]
        //NOSONAR     const logId = await getActionLogID(requestData.REQUEST_ID)
        //NOSONAR     let currentLogId = logId.NEW_ID
        //NOSONAR     do {
        //NOSONAR         checkExistentLogId = await SELECT.one.from`WF_ACTIONS_LOG`.where`and REQUEST_ID = ${requestData.REQUEST_ID} ACTIONS_LOG_ID = ${currentLogId}`
        //NOSONAR         currentLogId++
        //NOSONAR     } while(checkExistentLogId)
       
        //NOSONAR         ACTIONS_LOG_ID: currentLogId,
        //NOSONAR         REQUEST_ID: requestData.REQUEST_ID,
        //NOSONAR         REQUEST_TYPE: requestData.REQUEST_TYPE,
        //NOSONAR         DATE: new Date().toISOString(),
        //NOSONAR         USER: oRequest.user.id,
        //NOSONAR         ACTION: action,
        //NOSONAR         PHASE_ID_PK: requestData.MASTER_PHASE_ID,
        //NOSONAR         BLOCK_ID_PK: requestData.MASTER_BLOCK_ID,
        //NOSONAR         FIELD_MOD: fieldName,
        //NOSONAR         OLD_VALUE: oldValue,
        //NOSONAR         NEW_VALUE: newValue,
        //NOSONAR         PHASE_ID: requestData.PHASE_ID,
        //NOSONAR         BLOCK_ID: requestData.BLOCK_ID
        //NOSONAR     }

             // Add entity-specific fields
        //NOSONAR     if (entity === 'project.InstancesPerDocument' || entity === 'project.DocumentsPerBlock') {
        //NOSONAR         entry.DOCUMENT_ID = requestData.GENERIC_TYPE_ID
        //NOSONAR     }

        //NOSONAR     if (entity === 'project.Works' && requestData.WORK_ID) {
        //NOSONAR         entry.WORK_ID = requestData.WORK_ID
        //NOSONAR     }

        //NOSONAR     entries.push(entry)
        //NOSONAR     currentLogId++
        //NOSONAR }

        // Insert all entries
        //NOSONAR if (entries.length > 0) {
        //NOSONAR      await INSERT.into('WF_ACTIONS_LOG').entries(entries)
        //NOSONAR }

    } catch (error) {
        oRequest.reject(400, `Audit log creation failed: ${error.message}`)
    }
}

/**
 * Save audit log for entity modifications
 * @param {Object} oRequest - The request object
 * @param {string} entity - Entity type
 * @param {string} action - Action type (defaults to REQUEST_MODIFIED)
 * @returns {Promise<void>}
 */
const saveLogView = async (oRequest, entity, action = Actions.REQUEST_MODIFIED,sOldValue, sNewValue,sFieldName) => {
    try {
        let requestData

        // Use entity-specific fetcher based on entity type
        switch (entity) {
            case 'project.Blocks':
                requestData = await getRequestDataByBlockID(oRequest)
                break
            case 'project.DocumentsPerBlocks':
                
                requestData = await getRequestDataByDocumentID(oRequest)
                break
            case 'project.InstancesPerDocuments':
                requestData = await getRequestDataByInstanceID(oRequest)
                break
            case 'project.Works':
                requestData = await getRequestDataByWorkID(oRequest, oRequest.data.ID)
                break
            default:
                // Default fallback for unknown entities
                requestData = {
                    MASTER_PHASE_ID: 'requestCreat',
                    MASTER_BLOCK_ID: 'requestCharact',
                    REQUEST_ID: oRequest.params[0],
                    REQUEST_TYPE: await getRequestTypeByRequestID(oRequest)
                }
        }

        const entries = []
        if (!requestData) {
            throw new Error('Unable to fetch request data for logging')
        }
        const logId = await getActionLogID(requestData.REQUEST_ID)
        let currentLogId = logId.NEW_ID

        const entry = {
            ACTIONS_LOG_ID: currentLogId,
            REQUEST_ID: requestData.REQUEST_ID,
            REQUEST_TYPE: requestData.REQUEST_TYPE,
            DATE: new Date().toISOString(),
            USER: oRequest.user.id,
            ACTION: action,
            PHASE_ID_PK: requestData.MASTER_PHASE_ID,
            BLOCK_ID_PK: requestData.MASTER_BLOCK_ID,
            FIELD_MOD: sFieldName,
            OLD_VALUE: sOldValue,
            NEW_VALUE: sNewValue,
            PHASE_ID: requestData.PHASE_ID,
            BLOCK_ID: requestData.BLOCK_ID
        }

        // Add entity-specific fields
        if (entity === 'project.InstancesPerDocument' || entity === 'project.DocumentsPerBlock') {
            entry.DOCUMENT_ID = requestData.GENERIC_TYPE_ID
        }

        if (entity === 'project.Works' && requestData.WORK_ID) {
            entry.WORK_ID = requestData.WORK_ID
        }

        entries.push(entry)
        //NOSONAR currentLogId++
        
        // Insert all entries
        if (entries.length > 0) {
            await INSERT.into('WF_ACTIONS_LOG').entries(entries)
        }

    } catch (error) {
        oRequest.reject(400, `Audit log creation failed: ${error.message}`)
    }
}
/**
 * Log document-specific events (uploads, downloads, etc.)
 * @param {Object} oRequest - The request object
 * @param {string} action - The action being performed
 * @param {Object} options - Configuration options
 * @param {string} options.registerId - Document register ID
 * @param {string} options.instanceId - Document instance ID  
 * @param {string} options.blockId - Block ID
 * @param {string} options.workId - Work ID
 * @param {string} options.filename - Document filename
 * @param {Object} options.data - Additional data to include in log
 * @param {string} options.requestId - Pre-fetched request ID (skips data fetching)
 * @param {string} options.requestType - Pre-fetched request type
 * @param {string} options.masterBlockId - Pre-fetched master block ID
 * @param {string} options.masterPhaseId - Pre-fetched master phase ID
 * @param {string} options.phaseId - Pre-fetched phase ID
 * @param {string} options.documentId - Pre-fetched document ID
 * @returns {Promise<void>}
 */
const logDocumentEvent = async (oRequest, action, options = {}) => {
    let insertTx = cds.tx()
    try {
        const {
            registerId,
            instanceId,
            blockId,
            workId,
            filename,
            data = {},
            // Pre-fetched data fields
            requestId,
            requestType,
            masterBlockId,
            masterPhaseId,
            phaseId,
            documentId
        } = options

        let requestData

        // Check if we already have all the required data
        if (requestId && requestType && masterBlockId && masterPhaseId) {
            // Use pre-fetched data - no need to query database
            requestData = {
                REQUEST_ID: requestId,
                REQUEST_TYPE: requestType,
                MASTER_BLOCK_ID: masterBlockId,
                MASTER_PHASE_ID: masterPhaseId,
                PHASE_ID: phaseId,
                BLOCK_ID: blockId,
                GENERIC_TYPE_ID: documentId,
                WORK_ID: workId
            }
        } else {
            // Fetch data from database using available parameters
            const fetchParams = { registerId, instanceId, blockId, workId }
            requestData = await fetchRequestData(oRequest, fetchParams)

            if (!requestData) {
                throw new Error('Unable to fetch request data for document event logging')
            }
        }

        // Get next log ID
        const logIdResult = await getActionLogID(requestData.REQUEST_ID)
        const logId = logIdResult.NEW_ID

        // Build log entry
        const entry = {
            ACTIONS_LOG_ID: logId,
            REQUEST_ID: requestData.REQUEST_ID,
            REQUEST_TYPE: requestData.REQUEST_TYPE || await getRequestTypeByRequestID(oRequest, requestData.REQUEST_ID),
            DATE: new Date().toISOString(),
            USER: oRequest.user.id,
            ACTION: action,
            PHASE_ID_PK: requestData.MASTER_PHASE_ID,
            BLOCK_ID_PK: requestData.MASTER_BLOCK_ID,
            DOCUMENT_ID: documentId || requestData.GENERIC_TYPE_ID,
            PHASE_ID: requestData.PHASE_ID,
            BLOCK_ID: requestData.BLOCK_ID,
            FIELD_MOD: null,
            OLD_VALUE: null,
            NEW_VALUE: filename || null,
            ...data // Include any additional data fields
        }

        // Insert log entry
        await insertTx.run( INSERT.into('WF_ACTIONS_LOG').entries([entry]) )
        await insertTx.commit()
    } catch (error) {
        if(insertTx) insertTx.rollback()
        oRequest.reject(400, `Document event logging failed: ${error.message}`)
    }
}

const logChecklistEvent = async (oRequest, action, options = {}) => {
    try {

        const {
            description,
            newValue,
            oldValue,
            requestId,
            requestType,
            masterBlockId,
            masterPhaseId,
            blockId,
            phaseId
        } = options

        let requestData

        if (requestId && requestType && masterBlockId && masterPhaseId) {
            // Use pre-fetched data - no need to query database
            requestData = {
                REQUEST_ID: requestId,
                REQUEST_TYPE: requestType,
                MASTER_BLOCK_ID: masterBlockId,
                MASTER_PHASE_ID: masterPhaseId,
                PHASE_ID: phaseId,
                BLOCK_ID: blockId,
            }
        } else {
            // Fetch data from database using available parameters
            const fetchParams = { blockId }
            requestData = await fetchRequestData(oRequest, fetchParams)

            if (!requestData) {
                throw new Error('Unable to fetch request data for document event logging')
            }
        }

        // Get next log ID
        const logIdResult = await getActionLogID(requestData.REQUEST_ID)
        const logId = logIdResult.NEW_ID

        // Build log entry
        const entry = {
            ACTIONS_LOG_ID: logId,
            REQUEST_ID: requestData.REQUEST_ID,
            REQUEST_TYPE: requestData.REQUEST_TYPE,
            DATE: new Date().toISOString(),
            USER: oRequest.user.id,
            ACTION: action,
            PHASE_ID_PK: requestData.MASTER_PHASE_ID,
            BLOCK_ID_PK: requestData.MASTER_BLOCK_ID,
            DOCUMENT_ID: null,
            PHASE_ID: requestData.PHASE_ID,
            BLOCK_ID: requestData.BLOCK_ID,
            FIELD_MOD: description,
            OLD_VALUE: oldValue || null,
            NEW_VALUE: newValue || null,
            WORK_ID: null
        }

        // Insert log entry
        await INSERT.into('WF_ACTIONS_LOG').entries([entry])

    } catch (error) {
        oRequest.reject(400, `Checklist change logging failed: ${error.message}`);
    }
};

module.exports = {
    saveLog,
    saveLogView,
    logDocumentEvent,
    logChecklistEvent,
    fetchRequestData,
    getActionLogID,
    getRequestDataByBlockID,
    getRequestDataByDocumentID,
    getRequestDataByInstanceID,
    getRequestDataByWorkID,
    getRequestTypeByRequestID
}
