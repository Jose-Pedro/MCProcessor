// @ts-nocheck
sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/Fragment",
    "sap/ui/core/Messaging",
    "sap/m/upload/UploadSetItem",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/dom/isBehindOtherElement",
    "sap/ui/core/message/MessageType",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/Component",
    "sap/m/library",
    "sap/m/plugins/UploadSetwithTable",
    "sap/ui/core/Core"
], function (Controller, Fragment, Messaging, UploadSetItem, Filter, FilterOperator, isBehindOtherElement, MessageType, JSONModel, Component, Library, UploadSetwithTable, Core) {
    "use strict";

    return Controller.extend("prvintprojectsui5.components.works.controller.Component", {

        UPLOAD_CONFIG_ATTACHMENTS: "workAttachments",

        onInit: function () {
            this._iParentType = null
            this._sPhaseType = null
            this._sBlockType = null

            this.getView().setModel( new JSONModel({ documentId: '', documents: [] }), 'allowedDocuments')
            let oEventBus = Core.getEventBus()
            // oEventBus.subscribe("approvalFlows", "refreshDocumentsTable", this._onRefreshDocumentsTable, this)
            oEventBus.subscribe("approvalFlows", "rebind", this._onRebindTable, this)
        },

        onExit: function () {
            let oEventBus = Core.getEventBus()
            oEventBus.unsubscribe("approvalFlows", "refreshDocumentsTable", this._onRefreshDocumentsTable, this)
            oEventBus.unsubscribe("approvalFlows", "rebind", this._onRebindTable, this)
        },

        setParentType: function (iParentType, sPhaseType, sBlockType) {
            let showAddWork = false
            let oView = this.getView()
            if(iParentType && sPhaseType && sBlockType){
                this._iParentType = iParentType
                this._sPhaseType = sPhaseType
                this._sBlockType = sBlockType
                showAddWork = oView.getModel('configuration').getProperty(`/blockActions/${this._sPhaseType}/${this._sBlockType}/addWork`)
            }
            oView.byId('workTableToolbarBtnAdd').setVisible(showAddWork)
            // oView.byId('workTableToolbarBtnComplete').setVisible(showAddWork)
            // oView.byId('workTableToolbarBtnReopen').setVisible(showAddWork)
            // oView.byId('workTableToolbarBtnCancel').setVisible(showAddWork)
        },

        showBusy: function () {
            this._workAttachmentsList.setBusyIndicatorDelay(0)
            this._workAttachmentsList.setBusy(true)
            // this.getView().byId("uploadTable").setBusy(true)
        },

        hideBusy: function () {
            this._workAttachmentsList.setBusy(false)
            // this.getView().byId("uploadTable").setBusy(false)
        },

        statusIconFormatter: function (key) {
            switch (key) {
                case 2:
                    return 'sap-icon://overlay'
                case 7:
                    return 'sap-icon://alert'
                case 4:
                    return 'sap-icon://error'
                case 3:
                    return 'sap-icon://sys-enter-2'
                case 12:
                    return 'sap-icon://stop'
                case 32:
                    return 'sap-icon://alert'
                default:
                    return 'sap-icon://overlay'
            }
        },

        statusStateFormatter: function (key) {
            switch (key) {
                case 2:
                    return 'None'
                case 7:
                    return 'Warning'
                case 4:
                    return 'Error'
                case 3:
                    return 'Success'
                case 12:
                    return 'Error'
                case 32:
                    return 'Warning'
                default:
                    return 'None'
            }
        },

        validationDateformatter: function (key) {
            if (key) {
                var oDateFormat = sap.ui.core.format.DateFormat.getDateInstance({
                    format: "yMMMd"
                });
                return oDateFormat.format(key)
            } else {
                return null
            }
        },

        onFieldChange: function () {
            if (Messaging) Messaging.removeAllMessages()
            let oModel = this.getView().getModel()
            if (oModel.hasPendingChanges()) oModel.submitChanges({
                success: function (oData) {
                    let bHasError = false
                    if (oData.__batchResponses && oData.__batchResponses.constructor === Array) {
                        for (let oBatchResponse of oData.__batchResponses) {
                            if (oBatchResponse.__changeResponses && oBatchResponse.__changeResponses.constructor === Array) {
                                for (let oChangeResponse of oBatchResponse.__changeResponses) {
                                    if (oChangeResponse.statusCode && oChangeResponse.statusCode >= 400) {
                                        bHasError = true
                                    }
                                    if (oChangeResponse.response && oChangeResponse.response.statusCode && oChangeResponse.response.statusCode >= 400) {
                                        bHasError = true
                                    }
                                }
                            } else if (oBatchResponse.response) {
                                if (oBatchResponse.response.statusCode && oBatchResponse.response.statusCode >= 400) {
                                    bHasError = true
                                }
                                if (oBatchResponse.response && oBatchResponse.response.statusCode && oBatchResponse.response.statusCode >= 400) {
                                    bHasError = true
                                }
                            }
                        }
                    }
                    if (bHasError) {
                        oModel.resetChanges(null, true, true)
                        this._bindSmartTable()
                    }
                }.bind(this)
            })
        },

        //NOSONAR onWorkRowSelectionChange: function(oEvent) {
        //NOSONAR     let oView = this.getView()
        //NOSONAR     let oTable = oEvent.getSource()
        //NOSONAR     let oActionComplete = oView.byId('workTableToolbarBtnComplete')
        //NOSONAR     if(oActionComplete) oActionComplete.setEnabled(oTable.getSelectedIndices().length > 0)
        //NOSONAR     let oActionCancel = oView.byId('workTableToolbarBtnCancel')
        //NOSONAR     if(oActionCancel) oActionCancel.setEnabled(oTable.getSelectedIndices().length > 0)
        //NOSONAR     let oActionReopen = oView.byId('workTableToolbarBtnReopen')
        //NOSONAR     if(oActionReopen) oActionReopen.setEnabled(oTable.getSelectedIndices().length > 0)
        //NOSONAR },

        onBeforeRebindTable: function (oEvent) {
            let mBindingParams = oEvent.getParameter("bindingParams")
            mBindingParams.parameters["expand"] = "type,LocalizedWorkTypesName"
        },

        //NOSONAR onBeforeRebindApprovalFlowsTable: function (oEvent) {
        //NOSONAR     let mBindingParams = oEvent.getParameter("bindingParams")
        //NOSONAR     mBindingParams.parameters["expand"] = "InstancesPerDocuments,InstancesPerDocuments/Documents"
        //NOSONAR },

        createWork: function (oEvent) {
            let oView = this.getView()
            let oModel = oView.getModel()
            let oContext = oView.getBindingContext()

            oModel.create('/Works', {
                    parentId: oContext.getProperty("ID"),
                    parentType_ID: this._iParentType
                }, {
                success: function(oData) {
                    this._bindSmartTable()
                }.bind(this),
                error: function(oError) {
                    this._bindSmartTable()
                }.bind(this)                    
            })
        },

        cancelWork: function (oEvent) {
            this._callWorkAction('/Works_cancel')
        },

        completeWork: function (oEvent) {
            this._callWorkAction('/Works_complete')
        },

        reopenWork: function (oEvent) {
            this._callWorkAction('/Works_reopen')
        },

        onRowActionCancelWork: function (oEvent) {
            let oView = this.getView()
            let oModel = oView.getModel()
            let oContext = oEvent.getSource().getBindingContext()
            let sId = oContext.getProperty('ID')
            let sComments = ''
            sComments = oContext.getProperty('comments')
            if (!sComments) sComments = ''
            if (!this._workDocumentList) {
                Fragment.load({
                    id: this.getView().getId(),
                    name: "prvintprojectsui5.components.works.fragment.cancelWorkDialog",
                    controller: this
                }).then(function (oDialog) {
                    this._workDocumentList = oDialog
                    oView.addDependent(oDialog)
                    this._workDocumentList.setBindingContext(this._setWorkCancelDialogContext(oModel, sId, sComments))
                    this._workDocumentList.open()
                }.bind(this))
            } else {
                this._workDocumentList.setBindingContext(this._setWorkCancelDialogContext(oModel, sId, sComments))
                this._workDocumentList.open()
            }

            //NOSONAR this._callSingleWorkAction('/Works_cancel', sId)
        },

        onRowActionCompleteWork: function (oEvent) {
            let sId = oEvent.getSource().getBindingContext().getProperty('ID');
            this._callSingleWorkAction('/Works_complete', sId)
        },

        onRowActionReopenWork: function (oEvent) {
            let sId = oEvent.getSource().getBindingContext().getProperty('ID');
            this._callSingleWorkAction('/Works_reopen', sId)
        },

        onWorkEditComments: function (oEvent) {
            let oView = this.getView()
            let oSelectedContext = oEvent.getSource().getBindingContext()
            if (!this._workEditComments) {
                Fragment.load({
                    name: "prvintprojectsui5.components.works.fragment.workEditComments",
                    controller: this
                }).then(function (oDialog) {
                    this._workEditComments = oDialog
                    oView.addDependent(oDialog)
                    this._bindWorkToDialog(oDialog, oSelectedContext)
                    this._workEditComments.open()
                }.bind(this))
            } else {
                this._bindWorkToDialog(this._workEditComments, oSelectedContext)
                this._workEditComments.open()
            }
        },

        onWorkEditCommentsConfirm: function () {
            this._workEditComments.close()  
            this._workEditComments.destroy()
            this._workEditComments = null
        },

        onConfirmOnCancelWork: function (oEvent) {
            if (Messaging) Messaging.removeAllMessages()
            let oView = this.getView()
            let oModel = oView.getModel()
            let oTable = oView.byId('worksTable')
            oModel.submitChanges({
                groupId: 'changes',
                success: function (oData) {
                    let bHasError = false
                    if (oData.__batchResponses && oData.__batchResponses.constructor === Array) {
                        for (let oBatchResponse of oData.__batchResponses) {
                            if (oBatchResponse.__changeResponses && oBatchResponse.__changeResponses.constructor === Array) {
                                for (let oChangeResponse of oBatchResponse.__changeResponses) {
                                    if (oChangeResponse.statusCode && oChangeResponse.statusCode >= 400) {
                                        bHasError = true
                                    }
                                    if (oChangeResponse.response && oChangeResponse.response.statusCode && oChangeResponse.response.statusCode >= 400) {
                                        bHasError = true
                                    }
                                }
                            } else if (oBatchResponse.response) {
                                if (oBatchResponse.response.statusCode && oBatchResponse.response.statusCode >= 400) {
                                    bHasError = true
                                }
                                if (oBatchResponse.response && oBatchResponse.response.statusCode && oBatchResponse.response.statusCode >= 400) {
                                    bHasError = true
                                }
                            }
                        }
                    }
                    if (bHasError) {
                        oView.getModel().resetChanges(null, true, true)
                    } else {
                        oTable.rebindTable()
                        this._workDocumentList.close()
                    }
                }.bind(this),
                error: function () {
                    oView.getModel().resetChanges(null, true, true)
                    this._workDocumentList.close()
                }.bind(this)
            })
        },

        onCancelCancelWork: function (oEvent) {
            let oView = this.getView()
            let oModel = oView.getModel()
            if (this._workDocumentList) {
                this._workDocumentList.close()
                this._workDocumentList.destroy()
                this._workDocumentList = null
            }
            if (oModel.hasPendingChanges()) oModel.resetChanges(null, true, true)
        },

        //NOSONAR onWorkDocuments: function (oEvent) {
        //NOSONAR     let oView = this.getView()
        //NOSONAR     let oSelectedContext = oEvent.getSource().getBindingContext()
        //NOSONAR     if (!this._workDocumentList) {
        //NOSONAR         Fragment.load({
        //NOSONAR             id: this.getView().getId(),
        //NOSONAR             name: "prvintprojectsui5.components.works.fragment.approvalFlows",
        //NOSONAR             controller: this
        //NOSONAR         }).then(function (oDialog) {
        //NOSONAR             this._workDocumentList = oDialog
        //NOSONAR             oView.addDependent(oDialog)
        //NOSONAR             this._bindWorkToDocumentListDialog(oDialog, oSelectedContext)
        //NOSONAR             this._workDocumentList.open()
        //NOSONAR         }.bind(this))
        //NOSONAR     } else {
        //NOSONAR         this._bindWorkToDocumentListDialog(this._workDocumentList, oSelectedContext)
        //NOSONAR         this._workDocumentList.open()
        //NOSONAR     }
        //NOSONAR },

        onWorkDocuments: function (oEvent) {
            let oView = this.getView()
            let oSelectedContext = oEvent.getSource().getBindingContext()
            if (!this._workAttachmentsList) {
                Fragment.load({
                    id: this.getView().getId(),
                    name: "prvintprojectsui5.components.works.fragment.attachmentsDialog",
                    controller: this
                }).then(function (oDialog) {
                    this._workAttachmentsList = oDialog
                    oView.addDependent(oDialog)
                    this._bindWorkToDocumentListDialog(oDialog, oSelectedContext)
                    this._workAttachmentsList.open()
                }.bind(this))            
            } else {
                this._bindWorkToDocumentListDialog(this._workAttachmentsList, oSelectedContext)
                this._workAttachmentsList.open()
            }
        },

        onCloseWorkAttachments: function (oEvent) {
            this._workAttachmentsList.close()
        },

        onMessagePopoverPress: function (oEvent) {
            let oSourceControl = oEvent.getSource()
            this._getMessagePopover(oSourceControl)
        },        

        onMessagePopoverClose: function () {
            if (Messaging) Messaging.removeAllMessages()
            this._oMessagePopover.destroy()
            this._oMessagePopover = null
        },

        onMessagePress: function (oEvent) {
            let oItem = oEvent.getParameter("item")
            let oView = this.getView()
            let oMessage = oItem.getBindingContext("message").getObject()
            let oControl = Element.registry.get(oMessage.getControlId())
            if (oControl) {
                oView.getScrollDelegate().scrollToElement(oControl.getDomRef(), 200, [0, -100])
                setTimeout(function () {
                    var bIsBehindOtherElement = isBehindOtherElement(oControl.getDomRef());
                    if (bIsBehindOtherElement) {
                        this.close();
                    }
                    if (oControl.isFocusable()) {
                        oControl.focus();
                    }
                }.bind(this), 300);
            }
        },

        isPositionable: function (sControlId) {
            if (sControlId && sControlId.constructor === Array) {
                return sControlId.length > 0 ? true : false
            } else {
                return sControlId ? true : false
            }
        },

        onAttachmentTablePluginActivated: function (oEvent) {
            let oPlugin = oEvent.getParameter("oPlugin")
            let uploadConfigId = this.UPLOAD_CONFIG_ATTACHMENTS
            this._addTableUploadPlugin(uploadConfigId, oPlugin)
        },

        onAttachmentUploadDialogBrowse: function () {
            //browse and add new files to upload
            const uploadConfigId = this.UPLOAD_CONFIG_ATTACHMENTS
            let oPlugin = this._uploadConfig[uploadConfigId].oPlugin
            oPlugin.fileSelectionHandler()
        },

        onAttachmentUploadFileValidation: function (oItemInfo) {
            this.showBusy()
            let { oItem } = oItemInfo
            return new Promise((resolve, reject) => {
                this._autoCreateAndUpload(oItem)
                .then(() => resolve(oItem)) // ← Resolvemos para que el plugin suba el contenido
                .catch((err) => reject(err)) // ← Rechaza si hubo error (el plugin cancela ese item)
            })
        },

        onTableFileUploadCompleted: function (oEvent) {
            let iStatus = oEvent.getParameter("status")
            let oTable = oEvent.getSource().getParent()

            if (iStatus === 204) {
                // Subida OK → refresca items
                oTable.getBinding("items") && oTable.getBinding("items").refresh(true)
            } else {
                // Error → muestra respuesta del backend
                let resp = oEvent.getParameter("responseText");
                try { resp = JSON.parse(resp).error.message.value; } catch (e) {}
                sap.ui.getCore().getMessageManager().addMessages(
                    new sap.ui.core.message.Message({
                        message: resp || "Error al subir el archivo",
                        type: sap.ui.core.MessageType.Error,
                        persistent: true
                    })
                )
            }
            this.hideBusy()
        },

        onTableFileDownload: function (oEvent) {
            let oDocument = oEvent.getSource().getBindingContext().getObject();

            const documentId = oDocument.fileUrl;
            const filename = oDocument.documentName;
            let sUrl = "/CmmOpentextSrv/callOT";
            if (window.location.pathname.split('/test/flp.html').length === 2 || window.location.pathname.split('/index.html').length === 2) {
                sUrl = "/callOT";
            }
            let oMainAppComponent = Component.get(Component.getOwnerIdFor(this.getOwnerComponent().oContainer))
            if (oMainAppComponent.getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))) {
                sUrl = oMainAppComponent.getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))
            }
            let body = {};
            body.protocol = "GET";
            body.uri = `/cellnex-ot-services/api/agora/document/downloadContent?documentId=${documentId}`

            body = JSON.stringify(body);
            $.ajax({
                type: "POST",
                contentType: "application/json",
                url: sUrl,
                data: body,
                xhrFields: { responseType: 'blob', withCredentials: true },
                success: function (data, textStatus, jqXHR) {
                    let sUrl = URL.createObjectURL(data);
                    let link = document.createElement('a');
                    link.href = sUrl;
                    link.setAttribute('download', filename);
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                },
                error: function (err) {
                    console.log(err)
                }
            })
        },

        onTableFileRemove: function (oEvent) {
            //get file to be deleted
            let oContext = oEvent.getSource().getBindingContext();
            const filename = oContext.getObject().documentName;
            //show confirm message
            const i18nBundle = this.getView().getModel("i18n").getResourceBundle();
            const title = i18nBundle.getText("DeleteFile");
            const confirmMessage = i18nBundle.getText("confirmDeleteFile", [filename]);
            sap.m.MessageBox.confirm(
                confirmMessage,
                {
                    title: title,
                    actions: [sap.m.MessageBox.Action.YES, sap.m.MessageBox.Action.NO],
                    onClose: function (action) {
                        if (action === sap.m.MessageBox.Action.YES) {
                            //remove file
                            let oTable = oEvent.getSource().getParent().getParent();
                            oContext.delete({ groupId: null, refreshAfterChange: true }).then(function () {
                                //refresh table
                                if (oTable.getBinding("items")) {
                                    oTable.getBinding("items").refresh();
                                }
                            }.bind(this), function (oError) {
                                //refresh table
                                if (oTable.getBinding("items")) {
                                    oTable.getBinding("items").refresh();
                                }
                            });
                        }
                    }
                }
            );
        },

        onP13nDialog: function (oEvent) {
			var oSmartTable = this.getView().byId('worksTable')
			if (oSmartTable) oSmartTable.openPersonalisationDialog("Sort")
        },

        _autoCreateAndUpload: function (oItem) {
            let oView = this.getView()
            let oModel = oView.getModel()
            let payload = this._buildLocalDocumentPayload(oItem.getFileName(), this._getMediaType(oItem.getFileName(), oItem.getMediaType()), oView, oModel)
            return new Promise((resolve, reject) => {
                oModel.create("/LocalDocuments", payload, {
                    success: (oData) => {
                        try {
                            let sUrl = this._buildLocalDocumentContentUploadUrl(oData.ID)
                            oItem.setUploadUrl(sUrl);
                            oItem.addHeaderField(new sap.ui.core.Item({
                                key: "Content-Type",
                                text: this._getMediaType(oItem.getFileName(), oItem.getMediaType())
                            }))
                            let oUploadTable = oItem.getParent()
                            oUploadTable.setHttpRequestMethod(sap.m.upload.UploaderHttpRequestMethod.Put)
                            resolve()
                        } catch (oError) {
                            reject(oError)
                            this.hideBusy()
                        }
                    },
                    error: (oError) => {
                        this.hideBusy()
                        reject(oError)
                    }
                })
            })
        },

        _onRebindTable: function (sChannel, sPath, oData) {
            if(oData.bVisible) {
                let oContext = this.getView().getBindingContext()
                if(oContext) {
                    if (oContext.getProperty('ID') === oData.blockId) {
                        this._bindSmartTable()
                    }
                }
            }
        },

        _bindSmartTable: function () {
            this.getView().byId('worksTable').rebindTable()
        },

        _callWorkAction: function (sAction)  {
            let oView = this.getView()
            let oModel = oView.getModel()
            let oTable = oView.byId('worksTable').getTable()
            let oBinding = oTable.getBinding("rows")
            let aSelected = oTable.getSelectedIndices()
            
            let aSelectedContexts = []
            aSelectedContexts = aSelected.map(function(iIndex) { return oBinding.getContexts()[iIndex] })

            for(let oContext of aSelectedContexts) {
                oModel.callFunction(sAction, { 
                    method:"POST", 
                    groupId: 'changes',
                    urlParameters: { 'ID': oContext.getProperty('ID') }, 
                    'success': function (oData) {
                    }.bind(this), 
                    'error': function (oError) {

                    }.bind(this)
                })
            }
            oModel.submitChanges({
                success: function(oData) {
                    oBinding.refresh()
                }.bind(this),
                error: function(oError) {
                    oModel.resetChanges(null, true, true)
                }.bind(this)
            })
        },
            
        _callSingleWorkAction: function (sAction, sId) {
            let oView = this.getView()
            let oModel = oView.getModel()
            let oTable = oView.byId('worksTable')

            oModel.callFunction(sAction, { 
                method:"POST", 
                urlParameters: { 'ID': sId }, 
                'success': function (oData) {
                    oTable.rebindTable()
                }.bind(this), 
                'error': function (oError) {
                    oModel.resetChanges(null, true, true)
                }.bind(this)
            })
        },

        _bindWorkToDialog: function (oDialog, oContext) {
            oDialog.bindElement({ path: oContext.getDeepPath() })
        },

        _bindWorkToDocumentListDialog: function (oDialog, oSelectedContext) {
            oDialog.bindElement({ path: oSelectedContext.getDeepPath() })
        },

        _getMessagePopover: function (oSourceControl) {
            let oView = this.getView()
            if (!this._oMessagePopover) {
                Fragment.load({
                    name: "prvintprojectsui5.components.works.fragment.messagePopOver",
                    controller: this
                }).then(function (oMessagePopover) {
                    oView.addDependent(oMessagePopover)
                    oMessagePopover.openBy(oSourceControl)
                    this._oMessagePopover = oMessagePopover
                }.bind(this))
            }
            return this._oMessagePopover
        },

        _addTableUploadPlugin: function (uploadType, oPlugin) {
            //get upload config
            if (!this._uploadConfig) this._uploadConfig = {}
            //add attachments config
            if (!this._uploadConfig[uploadType]) {
                this._uploadConfig[uploadType] = { oPlugin: oPlugin, aUploadItemsProcessor: [] }
            }
        },

        _buildLocalDocumentPayload: function (filename, mediaType, oView, oModel) {
            let oBindingContext = oView.getBindingContext()
            let sBlockId = oBindingContext.getObject().ID
            let sRequestId = this._getRequestIdFromPath(oBindingContext.getDeepPath())
            let oRequest = oModel.getProperty(`/Requests(guid'${sRequestId}')`)
            let sWorkId = this._workAttachmentsList.getBindingContext().getObject().ID
            let oSupportDocsConfigList = this.getView().getModel("configuration").getProperty("/supportDocuments")
            let oDefaultConfigSupportDocumentCountry = oSupportDocsConfigList[oRequest.country]
            return {
                requestId: sRequestId,
                blockId: sBlockId,
                requestCode: oRequest.code,
                workId: sWorkId,
                documentName: filename,
                documentId: oDefaultConfigSupportDocumentCountry.documentId,
                docType: oDefaultConfigSupportDocumentCountry.documentType,
                subType: oDefaultConfigSupportDocumentCountry.documentSubType,
                subTypeLvl2: oDefaultConfigSupportDocumentCountry.documentSubTypeLvl2,
                finalDocument: false,
                mediaType: mediaType
            }
        },

        _getMediaType: function (fileName, mediaTypeFromItem) {
            let ext = (fileName.split(".").pop() || "").toLowerCase()
            switch (ext) {
                case "dwg": return "application/x-autocad"
                case "msg": return "application/vnd.ms-outlook"
                case "7z":  return "application/x-7z-compressed"
                default:    return mediaTypeFromItem && mediaTypeFromItem !== "" ? mediaTypeFromItem : "application/octet-stream"
            }
        },

        getTableFileIcon: function (mediaType, documentName) {
            return UploadSetwithTable.getIconForFileType(mediaType, documentName);
        },

        _getRequestIdFromPath: function (input) {
            if (!input || input.trim() === "") return null
            if (typeof input !== 'string') return null

            // Límite defensivo a tamaño total de la cadena (ajustable)
            const MAX_INPUT = 8192
            const s = input.length > MAX_INPUT ? input.slice(0, MAX_INPUT) : input

            // Conjunto negado + límite de longitud dentro de paréntesis (ajustable)
            const MAX_PAREN_CONTENT = 256
            const re = new RegExp(`\\(([^()\\/?#]{0,${MAX_PAREN_CONTENT}})\\)`) // sin 'g' para primera

            const m = re.exec(s)
            return m ? m[1] : null
        },

        _buildLocalDocumentContentUploadUrl: function (localDocumentId) {
            let oMainAppComponent = Component.get(Component.getOwnerIdFor(this.getOwnerComponent().oContainer))
            let sUrl = `/odata/v2/service/project/LocalDocuments(${localDocumentId})/content`
            if (oMainAppComponent.getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))) {
                sUrl = oMainAppComponent.getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))
            }
            return sUrl
        },

        _registerForP13n: function () {
			let oTable = this.byId("worksTable").getTable()

			Engine.getInstance().register(oTable, {
				controller: {
					Sorter: new SortController({
						control: oTable
					})
				}
			})
			Engine.getInstance().attachStateChange(this.handleStateChange, this)
		},
    
        _setWorkCancelDialogContext: function (oModel, sId, sComments) {
            oModel.callFunction("/Works_cancel", {
                method: "POST",
                groupId: "changes",
                success: function (oError) {
                }.bind(this),
                error: function (oError) {
                    oModel.resetChanges(null, true, true);
                }.bind(this),
                urlParameters: {
                    'ID': sId,
                    'comment': sComments,
                }
            }).contextCreated().then(function (oContext) {
                oContext.setProperty('comments', sComments)
                this.getView().byId('cancelWorkForm').setBindingContext(oContext)
                return (oContext)
            }.bind(this))
        },


    })
})