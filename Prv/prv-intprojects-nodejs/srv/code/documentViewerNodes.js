const { searchByProcessOT } = require('../utils/documents')
const { getHiddenDocumentTypes } = require('../utils/documentsperblock')
class DVNCode {

    onReadDocumentViewerNodes = async (oRequest) => {
        if (oRequest.data?.requestId) {
            let oRequestHead = await SELECT.one.from`REQUEST_HEAD`.where`REQUEST_ID = ${oRequest.data.requestId}`
            if (oRequestHead) {
                let aResults = []
                let aOTDocuments = await searchByProcessOT(oRequest, oRequestHead)
                if (oRequest.errors) return aResults
                if (aOTDocuments.length > 0) {
                    aOTDocuments.sort((a, b) => {
                        let nameA = a.documentSubType.toUpperCase()
                        let nameB = b.documentSubType.toUpperCase()
                        if (nameA < nameB) return -1
                        if (nameA > nameB) return 1
                        return 0;
                    })
                    let aHiddenDocuments = await getHiddenDocumentTypes(oRequest, oRequestHead.PROCESS_ID)
                    if (aHiddenDocuments && aHiddenDocuments.length > 0) {
                        aOTDocuments = aOTDocuments.filter(oResult => {
                            let oWhatEver = aHiddenDocuments.find(oAux => oAux.documentId === oResult.documentId)
                            if (oWhatEver == undefined) return oResult
                        })
                    }

                    let prevSubtype = ''
                    for (let oOTDocument of aOTDocuments) {
                        if (prevSubtype !== oOTDocument.documentSubType) {
                            prevSubtype = oOTDocument.documentSubType
                            aResults.push({
                                nodeId: oOTDocument.documentSubType,
                                hierarchyLevel: 0,
                                parentNodeId: null,
                                drillState: 'expanded',
                                description: null,
                                documentId: null,
                                createdBy: null,
                                createdAt: null,
                                requestId: oRequestHead.REQUEST_ID
                            })
                        }
                        aResults.push({
                            nodeId: oOTDocument.documentName,
                            hierarchyLevel: 1,
                            parentNodeId: prevSubtype,
                            drillState: 'leaf',
                            description: oOTDocument.documentName,
                            documentId: oOTDocument.documentId ? oOTDocument.documentId.toString() : null,
                            createdBy: oOTDocument.createdBy,
                            createdAt: oOTDocument.createdAt,
                            requestId: oRequestHead.REQUEST_ID
                        })
                    }
                    oRequest.reply(aResults)
                }
            } else {
                oRequest.error(400, 'requestNotFound')
            }
        } else {
            oRequest.error(400, 'missingRequestId')
        }
    }


}

module.exports = {
    DVNCode
}