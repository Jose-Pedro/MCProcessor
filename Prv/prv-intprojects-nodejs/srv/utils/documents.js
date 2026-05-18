const { executeHttpRequest } = require('@sap-cloud-sdk/http-client')
const { retrieveJwt } = require('@sap-cloud-sdk/connectivity')
const { GlobalConstants } = require('./enumerations')
const { FormData: FormDataNode } = require('formdata-node')

const createOTFolder = async (oRequest, oRequestHead) => {
    //local/mocked mode: OpenText is unreachable, fake a folder id so process can advance
    if (cds.env.requires?.auth?.kind === 'mocked') {
        const sFakeFolderId = `LOCAL-${oRequestHead.code || oRequestHead.ID}`
        try { await UPDATE`REQUEST_HEAD`.set`WORKFLOW_NAME = ${sFakeFolderId}`.where`REQUEST_ID = ${oRequestHead.ID}` } catch (e) {}
        oRequestHead.workflowName = sFakeFolderId
        return
    }
    let body = {};
    let data = {
        company: oRequestHead.company,
        country: oRequestHead.country,
        requestName: oRequestHead.code,
        requestNumber: oRequestHead.code,
        requestType: GlobalConstants.OT_REQUEST_TYPE,
        internationalCode: oRequestHead.siteId,
    };

    let urlParam = onGenerateURLKeys('/cellnex-ot-services/api/agora/process/createFolder', data)
    let jwt = (retrieveJwt(oRequest) || retrieveJwt(cds.context))
    let jwtJson = jwt ? { 'jwt': jwt } : {}
    let sDestination = "Agora-CmmOpenText-HTTP"
    body.data = data;
    body.protocol = "POST";
    body.uri = urlParam
    try {
        let oResponse = await executeHttpRequest(
            { destinationName: sDestination, ...jwtJson },
            {
                method: 'POST',
                url: '/callOT',
                headers: {
                    'Content-Type': 'application/json'
                },
                data: JSON.stringify(body)
            },
            { fetchCsrfToken: false }
        )
        console.log(oResponse.data.folderId)
        await UPDATE`REQUEST_HEAD`.set`WORKFLOW_NAME = ${oResponse.data.folderId}`.where`REQUEST_ID = ${oRequestHead.ID}`
        oRequestHead.workflowName = oResponse.data.folderId
    } catch (oError) {
        let msg = oError?.response?.data?.message || oError.message
        oRequest.error(400, msg)
    }
}

const sendDocumenttoOT = async (oRequest, oDocument, oData) => { // working everything, touching this function faces dead penalty
    //local/mocked mode: skip OT upload, register the document row only with a synthetic URL
    if (cds.env.requires?.auth?.kind === 'mocked') {
        try {
            oDocument.DOCUMENT_URL = `LOCAL-${oDocument.REGISTER_ID || cds.utils.uuid()}`
            await INSERT.into`WF_DETAIL_DOCUMENTS`.entries([oDocument])
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
        return
    }
    let aFile = await getFile(oRequest.data.content)
    let oBlob = new Blob(aFile, { type: oDocument.MEDIA_TYPE })
    let sUrl = onGenerateURLKeys("/cellnex-ot-services/api/agora/document/addDocument", oData)

    let formData = new FormDataNode()
    let jwt = (retrieveJwt(oRequest) || retrieveJwt(cds.context))
    let jwtJson = jwt ? { 'jwt': jwt } : {}
    let sDestination = "Agora-CmmOpenText-HTTP"

    formData.append("protocol", "POST")
    formData.append("uri", sUrl)
    formData.append("file", oBlob, oDocument.DOCUMENT_NAME)
    console.log("Before sending doc to ot URL: " + sUrl)
    try {
        let oResponse = await executeHttpRequest(
            { destinationName: sDestination, ...jwtJson },
            {
                method: 'POST',
                url: '/uploadOT',
                headers: {
                    'Content-Type': 'multipart/form-data',
                    'Accept': '*/*'
                },
                data: formData
            },
            {
                fetchCsrfToken: false
            }
        )

        oDocument.DOCUMENT_URL = oResponse.data.objectId
        await INSERT.into`WF_DETAIL_DOCUMENTS`.entries([oDocument])
    } catch (oError) {
        let msg = oError?.response?.data?.message || oError.message
        let deleteTx = cds.tx()
        await deleteTx.run(DELETE.from('WF_DETAIL_DOCUMENTS_LOCAL').where({ REGISTER_ID: oDocument.REGISTER_ID }))
        await deleteTx.commit()
        oRequest.error(400, msg)
    }
}

const addDefaultDocumentsConfig = async (oRequest, processId, requestId, btsManagerId, sCustomerId) => {
    if (processId) {
        let oDocProcess = await SELECT.one.from`DOCUMENT_FLOWS_PER_PROCESS`.where`processId = ${processId}`
        if (oDocProcess) {
            let oDocsDefaultValidPerProcess = await SELECT.from`DOCUMENT_FLOW_VALIDATORS`.where`DocumentFlowsPerConfig_ID = ${oDocProcess.Configuration_ID}`
            let oRequestDocumentsPerBlockDefaultValidation = []
            for (let i = 0; i < oDocsDefaultValidPerProcess.length; i++) {
                if (oDocsDefaultValidPerProcess[i] && oDocsDefaultValidPerProcess[i].default !== undefined && oDocsDefaultValidPerProcess[i].default) {
                    let oSingleDoc = oDocsDefaultValidPerProcess[i]
                    let oCheckExistent = await SELECT.from`project.RequestDocumentsPerBlockDefaultValid`.where`DELETED = false and requestId = ${requestId} and documentId = ${oSingleDoc.documentId}`
                    if (oCheckExistent.length === 0) {
                        let sDefaultResponsible = ''
                        if (oSingleDoc.approverType === 1) {//internal
                            sDefaultResponsible = btsManagerId
                        }
                        if (oSingleDoc.approverType === 2 && oSingleDoc.externalType === 2) {//external y customer
                            sDefaultResponsible = sCustomerId
                        }
                        let oDocumentsPerBlockValid = {
                            'REQUEST_ID': requestId,
                            'DOCUMENT_ID': oSingleDoc.documentId,
                            'APPROVER_TYPE': oSingleDoc.approverType,
                            'SUBCONTRACTOR': oSingleDoc.externalType,
                            'DEFAULT_RESPONSIBLE': sDefaultResponsible,
                            'SUBCO_REQ_VAL': oSingleDoc.subcontractorValidationReq,
                            'CELLNEX_REQ_VAL': oSingleDoc.cellnexValidationReq,
                            'CUSTOMER__REQ_VAL': oSingleDoc.customerValidationReq,
                            'SITEOWNER_REQ_VAL': oSingleDoc.landlordValidationReq,
                            'CREATEDAT': oRequest.timestamp,
                            'CREATEDBY': oRequest.user.id,
                            'MODIFIEDAT': oRequest.timestamp,
                            'MODIFIEDBY': oRequest.user.id,
                            'DELETED': false,
                            'REGISTER_ID': cds.utils.uuid()
                        }
                        oRequestDocumentsPerBlockDefaultValidation.push(oDocumentsPerBlockValid)
                    }
                }
            }
            if (oRequestDocumentsPerBlockDefaultValidation.length > 0) await INSERT.into('REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID').entries(oRequestDocumentsPerBlockDefaultValidation)
        }
    } else {
        oRequest.error(400, 'processIdNotFound')
    }
}

const onGenerateURLKeys = (url, oParams) => {
    let urlParam
    for (let key in oParams) {
        if (oParams.hasOwnProperty(key)) {
            if (key !== "response" && oParams[key] !== "") {
                let parameters = "";
                if (typeof (oParams[key]) === "string") {
                    parameters = encodeURIComponent(oParams[key]);
                } else if (typeof (oParams[key]) === "object") {
                    var oFile = oParams[key];
                    var bAux = true;
                    for (let keyFile in oFile) {
                        if (bAux) {
                            bAux = false;
                            parameters = encodeURIComponent(oFile[keyFile]);
                        } else {
                            parameters = parameters + "&" + key + "=" + encodeURIComponent(oFile[keyFile]);
                        }
                    }
                }
                if (urlParam) {
                    urlParam = urlParam + "&" + key + "=" + parameters;
                } else {
                    urlParam = url + "?" + key + "=" + parameters;
                }
            }
        }
    }
    return urlParam
}

const removeDocumentFromOT = async (oRequest, oDocument) => {
    //local/mocked mode: skip OT delete call, just flag the local row as deleted
    if (cds.env.requires?.auth?.kind === 'mocked') {
        try {
            await UPDATE('WF_DETAIL_DOCUMENTS').set({ 'DELETED': true, 'DELETED_AT': oRequest.timestamp, 'DELETED_BY': oRequest.user.id }).where({ 'REGISTER_ID': oDocument.REGISTER_ID })
        } catch (oError) {
            oRequest.error(400, oError.message)
        }
        return
    }
    try {
        if (oDocument.DOCUMENT_URL !== null && oDocument.DOCUMENT_URL !== '') {
            let sUrl = "/cellnex-ot-services/api/agora/document/deletes?ids=" + oDocument.DOCUMENT_URL
            let jwt = (retrieveJwt(oRequest) || retrieveJwt(cds.context))
            let jwtJson = jwt ? { 'jwt': jwt } : {}
            let sDestination = "Agora-CmmOpenText-HTTP"

            let formData = new FormDataNode()
            formData.append("protocol", "DELETE")
            formData.append("uri", sUrl)
            formData.append("data", '')
            //Will remove this nonsense declaration for PRE and PRO
            await executeHttpRequest(
                { destinationName: sDestination, ...jwtJson },
                {
                    method: 'POST',
                    url: '/callOT',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': '*/*'
                    },
                    data: formData
                },
                {
                    fetchCsrfToken: false
                }
            )
        }
        await UPDATE('WF_DETAIL_DOCUMENTS').set({ 'DELETED': true, 'DELETED_AT': oRequest.timestamp, 'DELETED_BY': oRequest.user.id }).where({ 'REGISTER_ID': oDocument.REGISTER_ID })
    } catch (oError) {
        let msg = oError?.response?.data?.message || oError.message
        oRequest.error(400, msg)
    }
}

const getFile = async (oFile) => {
    return new Promise((resolve, reject) => {
        let aChunks = []
        oFile.on('data', oChunk => aChunks.push(oChunk))
        oFile.on('end', async function () {
            resolve(aChunks)
        })
        oFile.on('error', function (oError) {
            reject(oError)
        })
    })
}

const sendDocumentStatusToOT = async (oRequest, oData) => {
    //local/mocked mode: skip OT status sync
    if (cds.env.requires?.auth?.kind === 'mocked') return
    let sDestination = "Agora-CmmOpenText-HTTP"
    let oBody = {
        data: oData,
        uri: '/cellnex-ot-services/api/agora/document/updateDocumentStatus',
        protocol: 'POST'
    }
    try {
        let oExternalService = await cds.connect.to(sDestination)
        await oExternalService.send({
            method: 'POST',
            path: '/callOT',
            data: JSON.stringify(oBody),
            headers: { 'content-type': 'application/json' }
        })
    } catch (oError) {
        let msg = oError?.response?.data?.message || oError.message
        oRequest.error(400, msg)
    }

}


const searchByProcessOT = async (oRequest, oRequestHead) => {
    //local/mocked mode: OT search returns empty list (no external attachments tracked locally)
    if (cds.env.requires?.auth?.kind === 'mocked') return []
    let sUrl = '/cellnex-ot-services/api/agora/search/searchByProcess?requestNumber=' + oRequestHead.REQUEST_CODE
    let jwt = (retrieveJwt(oRequest) || retrieveJwt(cds.context))
    let jwtJson = jwt ? { 'jwt': jwt } : {}
    let sDestination = "Agora-CmmOpenText-HTTP" //"Agora-CmmOpenTextClientCred-HTTP"
    let formData = new FormDataNode()
    formData.append("protocol", "GET")
    formData.append("uri", sUrl)
    formData.append("data", '')

    try {
        let oResponse = await executeHttpRequest(
            { destinationName: sDestination, ...jwtJson },
            //NOSONAR { destinationName: sDestination },
            {
                method: 'POST',
                url: '/callOT',
                headers: {
                    'Content-Type': 'application/json'
                },
                data: formData
            },
            { fetchCsrfToken: false }
        )
        let aOTDocuments = []
        if (oResponse?.data && oResponse.data.constructor === Array) {
            for (let oResponseItem of oResponse.data) {
                //NOSONAR console.log(oUtil.inspect(oResponseItem, false, null, false))
                let oOTDocument = {
                    documentId: oResponseItem.documentId,
                    documentType: oResponseItem.documentType,
                    documentSubType: oResponseItem.documentSubType,
                    documentTypeLvl2: oResponseItem.documentTypeLvl2,
                    documentName: oResponseItem.name,
                    createdBy: oResponseItem.createUser,
                    createdAt: new Date(oResponseItem.documentDate)
                }
                aOTDocuments.push(oOTDocument)
            }
        }
        return aOTDocuments
    } catch (oError) {
        let msg = oError?.response?.data?.message || oError.message
        oRequest.error(400, msg)
    }
}

module.exports = {
    createOTFolder,
    sendDocumenttoOT,
    addDefaultDocumentsConfig,
    removeDocumentFromOT,
    sendDocumentStatusToOT,
    searchByProcessOT
}