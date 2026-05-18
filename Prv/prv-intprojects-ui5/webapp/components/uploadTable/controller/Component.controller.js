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
    "sap/ui/core/Element",
    "sap/m/plugins/UploadSetwithTable",
    "sap/ui/core/Core"
], function (Controller, Fragment, Messaging, UploadSetItem, Filter, FilterOperator, isBehindOtherElement, MessageType, JSONModel, Component, Element, UploadSetwithTable, Core) {
    "use strict";

    return Controller.extend("prvintprojectsui5.components.uploadTable.controller.Component", {

        UPLOAD_CONFIG_BLOCK_ATTACHMENTS: "blockAttachments",

        onInit: function () {
            this._iParentType = null
            this._sPhaseType = null
            this._sBlockType = null
            this.getView().setModel(new JSONModel({ documentId: '', documents: [] }), 'allowedDocuments')
            let oEventBus = Core.getEventBus()
            if (oEventBus) oEventBus.subscribe("uploadTable", "refreshTable", this._onRefreshTable, this)
        },

        onExit: function () {
            let oEventBus = Core.getEventBus()
            if (oEventBus) oEventBus.unsubscribe("uploadTable", "refreshTable", this._onRefreshTable, this)
        },

        setParentType: function (iParentType, sPhaseType, sBlockType) {
            this._iParentType = iParentType
            this._sPhaseType = sPhaseType
            this._sBlockType = sBlockType

            let oTable = this.byId("uploadTable");
            oTable.bindItems({
                path: "SupportDocuments",
                templateShareable: false,
                template: new sap.m.ColumnListItem({
                    cells: [
                        new sap.ui.core.Icon({ src: { parts: ["mediaType", "documentName"], formatter: this.getTableFileIcon.bind(this) } }).addStyleClass("sapMUSTItemImage sapMUSTItemIcon"),
                        new sap.m.Link({ text: "{documentName}", press: this.onTableFileDownload.bind(this) }).addStyleClass("sapUiTinyMarginBottom"),
                        new sap.m.Text({ text: "{documentTypeName}" }),
                        new sap.m.Button({ icon: "sap-icon://decline", tooltip: "{i18n>DeleteFile}", enabled: "{canDelete}", press: this.onTableFileRemove.bind(this), type: "Transparent" }).addStyleClass("sapUiTinyMarginBegin")
                    ]
                })
            })
            oTable.getBinding("items").refresh(true)
        },

        showBusy: function () {
            this.getView().byId("uploadTable").setBusy(true)
        },

        hideBusy: function () {
            this.getView().byId("uploadTable").setBusy(false)
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

        onAttachmentTablePluginActivated: function (oEvent) {
            let oPlugin = oEvent.getParameter("oPlugin");
            const uploadConfigId = this.UPLOAD_CONFIG_BLOCK_ATTACHMENTS;
            this._addTableUploadPlugin(uploadConfigId, oPlugin);
        },

        onAttachmentUploadFileValidation: function (oItemInfo) {
            const uploadConfigId = this.UPLOAD_CONFIG_BLOCK_ATTACHMENTS;
            let aUploadItemsProcessor = this._uploadConfig[uploadConfigId].aUploadItemsProcessor;
            //set file upload processors
            const { oItem, iTotalItemsForUpload } = oItemInfo;
            var oItemPromise = new Promise((resolve, reject) => {
                aUploadItemsProcessor.push({
                    item: oItem,
                    resolve: resolve,
                    reject: reject
                });
            });
            //check if file upload items finished
            if (iTotalItemsForUpload === aUploadItemsProcessor.length || iTotalItemsForUpload === 1) {
                this._loadDialogAttachmentUploadFragment();
            }
            return oItemPromise;
        },

        onAttachmentUploadDialogBrowse: function () {
            //browse and add new files to upload
            const uploadConfigId = this.UPLOAD_CONFIG_BLOCK_ATTACHMENTS;
            let oPlugin = this._uploadConfig[uploadConfigId].oPlugin;
            oPlugin.fileSelectionHandler();
        },

        onAttachmentUploadDialogAttachmentTypeSelectionChange: function (oEvent) {
            const oSelectedItem = oEvent.getParameter("selectedItem");
            //initialize document configuration
            let documentType = null;
            let documentSubType = null;
            let documentSubTypeLvl2 = null;
            if (oSelectedItem) {
                //get selected attachment type
                const oAttachmentType = oSelectedItem.getBindingContext().getObject();
                documentType = oAttachmentType.documentType;
                documentSubType = oAttachmentType.documentSubtype;
                documentSubTypeLvl2 = oAttachmentType.documentSubType2;

            }
            //update model data
            const oAttachmentsPendingUploadContext = oSelectedItem.getBindingContext("AttachmentsPendingUpload");
            oAttachmentsPendingUploadContext.setProperty("documentType", documentType);
            oAttachmentsPendingUploadContext.setProperty("documentSubType", documentSubType);
            oAttachmentsPendingUploadContext.setProperty("documentSubTypeLvl2", documentSubTypeLvl2);
        },

        onAttachmentUploadDialogRemoveFile: function (oEvent) {
            //get upload item
            const oUploadFileItem = oEvent.getSource().getBindingContext("AttachmentsPendingUpload").getObject();
            //get all uploaded files
            let oModelAttachments = this._fileUploadFragmentBlockAttachments.getModel("AttachmentsPendingUpload");
            let aFilesToUpload = oModelAttachments.getData().filesToUpload;
            //find selected upload item
            let oItemInstance = oUploadFileItem.itemInstance;
            const iSelectedItemIndex = aFilesToUpload.findIndex(function (oItem) {
                return oItem.itemInstance.getId() === oItemInstance.getId();
            });
            //remove selected file
            aFilesToUpload.splice(iSelectedItemIndex, 1);
            oModelAttachments.setProperty("/filesToUpload", aFilesToUpload);
            //cancel the upload of the current item
            oUploadFileItem.fnReject(oItemInstance);
        },

        onAttachmentUploadDialogAddFiles: function () {
            //check if all upload items have a document type
            this.showBusy()
            let aFilesToUpload = this._fileUploadFragmentBlockAttachments.getModel("AttachmentsPendingUpload").getData().filesToUpload;
            for (const oUploadItem of aFilesToUpload) {
                if (oUploadItem.documentId === null) {
                    //show error message
                    const i18nBundle = this.getView().getModel("i18n").getResourceBundle();
                    const message = i18nBundle.getText("AllFilesMustHaveAttachmentType");
                    sap.m.MessageBox.error(message);
                    return;
                }
            }
            //upload files
            for (const oFileToUpload of aFilesToUpload) {
                let oUploadItem = oFileToUpload.itemInstance;
                let sMediaType = this._getMediaType(oUploadItem.getFileName(), oUploadItem.getMediaType());
                let oOptions = {
                    filename: oUploadItem.getFileName(),
                    mediaType: sMediaType,
                    openTextDocument: {
                        documentId: oFileToUpload.documentId,
                        documentType: oFileToUpload.documentType,
                        documentSubType: oFileToUpload.documentSubType,
                        documentSubTypeLvl2: oFileToUpload.documentSubTypeLvl2
                    },
                    oFileToUploadTableWithUploadPlugin: oFileToUpload
                };
                this._createLocalDocument(oOptions);
            }
            this.onAttachmentUploadDialogClose();
        },

        onAttachmentUploadDialogClose: function () {
           if( this._fileUploadFragmentBlockAttachments){this._fileUploadFragmentBlockAttachments.destroy();} 

            this._fileUploadFragmentBlockAttachments = null;
            const uploadConfigId = this.UPLOAD_CONFIG_BLOCK_ATTACHMENTS;
            this._uploadConfig[uploadConfigId].aUploadItemsProcessor = [];
        },

        getTableFileIcon: function (mediaType, documentName) {
            return UploadSetwithTable.getIconForFileType(mediaType, documentName);
        },

        onTableFileDownload: function (oEvent) {
            //get document data
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

        onTableFileUploadCompleted: function (oEvent) {
            //check if upload went OK
            const iResponseStatus = oEvent.getParameter("status");
            if (iResponseStatus === 204) {
                //refresh table
                let oTable = oEvent.getSource().getParent();
                if (oTable.getBinding("items")) {
                    oTable.getBinding("items").refresh();
                }
            }
            else {
                //add error message
                let errorMessage = oEvent.getParameter("responseText");
                try {
                    errorMessage = JSON.parse(errorMessage).error.message.value;
                }
                catch (err) { }
                Messaging.addMessages(
                    new sap.ui.core.message.Message({
                        message: errorMessage,
                        type: "Error",
                        persistent: true
                    })
                );
            }
            this.hideBusy()
        },

        _onRefreshTable: function (sChannel, sPath, oData) {
            if (oData.bVisible) {
                let oContext = this.getView().getBindingContext()
                if (oContext) {
                    if (oContext.getProperty('ID') === oData.blockId) {
                        this._bindTable()
                    }
                }
            }
        },

        _bindTable: function () {
            let oTable = this.getView().byId('uploadTable')
            let oBinding = oTable.getBinding("items")
            if (oBinding) oBinding.refresh(true)
        },

        _loadDialogAttachmentUploadFragment: function () {
            if (!this._fileUploadFragmentBlockAttachments) {
                this._fileUploadFragmentBlockAttachments = this.loadFragment({
                    name: "prvintprojectsui5.components.uploadTable.fragment.uploadAttachmentDialog",
                    controller: this
                }).then(function (oPopOver) {
                    //set dialog instance
                    this._fileUploadFragmentBlockAttachments = oPopOver;
                    //create attachment model
                    let oModelAttachments = new sap.ui.model.json.JSONModel({
                        filesToUpload: []
                    });
                    this._fileUploadFragmentBlockAttachments.setModel(oModelAttachments, "AttachmentsPendingUpload");
                    //open dialog
                    this.getView().addDependent(oPopOver);
                    this._openDialogAttachmentUpload();
                }.bind(this))
            } else {
                //open dialog
                this._openDialogAttachmentUpload();
            }
        },

        _openDialogAttachmentUpload: function () {
            //get files to upload
            const uploadConfigId = this.UPLOAD_CONFIG_BLOCK_ATTACHMENTS;
            let aUploadItemsProcessor = this._uploadConfig[uploadConfigId].aUploadItemsProcessor;
            let oDefaultConfigSupportDocumentCountry = null
            let oSupportDocsConfigList = this.getView().getModel("configuration").getProperty("/supportDocuments")
            if (sap.ui.getCore().requestData && 'country' in sap.ui.getCore().requestData && oSupportDocsConfigList) {
                let sCountry = sap.ui.getCore().requestData.country
                oDefaultConfigSupportDocumentCountry = oSupportDocsConfigList[sCountry]
            }
            this.getView().getModel("configuration").getProperty("/supportDocuments")
            let aFilesToUpload
            if (oDefaultConfigSupportDocumentCountry) {
                aFilesToUpload = aUploadItemsProcessor.map(function (oItemProcessor) {
                    return {
                        fileName: oItemProcessor.item.getFileName(),
                        documentId: oDefaultConfigSupportDocumentCountry.documentId,
                        documentType: oDefaultConfigSupportDocumentCountry.documentType,
                        documentSubType: oDefaultConfigSupportDocumentCountry.documentSubType,
                        documentSubTypeLvl2: oDefaultConfigSupportDocumentCountry.documentSubTypeLvl2,
                        itemInstance: oItemProcessor.item,
                        fnResolve: oItemProcessor.resolve,
                        fnReject: oItemProcessor.reject
                    };
                }.bind(this));
            } else {
                aFilesToUpload = aUploadItemsProcessor.map(function (oItemProcessor) {
                    return {
                        fileName: oItemProcessor.item.getFileName(),
                        documentId: null,
                        documentType: null,
                        documentSubType: null,
                        documentSubTypeLvl2: null,
                        itemInstance: oItemProcessor.item,
                        fnResolve: oItemProcessor.resolve,
                        fnReject: oItemProcessor.reject
                    };
                }.bind(this));
            }

            //update files to upload
            let oModelAttachments = this._fileUploadFragmentBlockAttachments.getModel("AttachmentsPendingUpload");
            oModelAttachments.setProperty("/filesToUpload", aFilesToUpload);
            //open dialog
            if (this.getView() && this.getView().getBindingContext() && this.getView().getBindingContext().getProperty("BlockProvision") && this.getView().getBindingContext().getProperty("BlockProvision").newUploadTableEnabled) {
                this._fileUploadFragmentBlockAttachments.open();
            } else { 
                this.onAttachmentUploadDialogAddFiles()

            }
        },

        _addTableUploadPlugin: function (uploadType, oPlugin) {
            //get upload config
            if (!this._uploadConfig) {
                this._uploadConfig = {};
            }
            //add attachments config
            if (!this._uploadConfig[uploadType]) {
                this._uploadConfig[uploadType] = {
                    oPlugin: oPlugin,
                    aUploadItemsProcessor: []
                };
            }
        },

        _getMessagePopover: function (oSourceControl) {
            let oView = this.getView()
            if (!this._oMessagePopover) {
                Fragment.load({
                    name: "prvintprojectsui5.components.uploadTable.fragment.messagePopOver",
                    controller: this
                }).then(function (oMessagePopover) {
                    oView.addDependent(oMessagePopover)
                    oMessagePopover.openBy(oSourceControl)
                    this._oMessagePopover = oMessagePopover
                }.bind(this))
            }
            return this._oMessagePopover
        },

        _createLocalDocument: function (oOptions) {
            let { filename, mediaType, openTextDocument, uploadItemUploadSet, oFileToUploadTableWithUploadPlugin } = oOptions;
            //check if mediatype is not empty
            if (mediaType === "") {
                return;
            }
            //build opentext payload
            const data = this._buildLocalDocumentPayload(filename, mediaType, openTextDocument);
            //create local document
            let oDataModel = sap.ui.getCore().requestData.oView.getModel()
            oDataModel.create('/LocalDocuments',
                data,
                {
                    success: function (oData) {
                        //upload file content
                        const localDocumentId = oData.ID;
                        //check if upload is sent from UploadSet (standard) or table with plugin (new feature
                        if (uploadItemUploadSet) {
                            this._uploadLocalDocumentContentFromUploadSet(uploadItemUploadSet, localDocumentId);
                        }
                        else {
                            this._uploadLocalDocumentContentFromTableWithUploadPlugin(oFileToUploadTableWithUploadPlugin, localDocumentId);
                        }
                    }.bind(this)
                }
            );
        },

        _buildLocalDocumentPayload: function (filename, mediaType, openTextDocument) {
            //get media type
            const sMediaType = this._getMediaType(filename, mediaType);
            //get request data
            let oView = this.getView();
            const requestId = sap.ui.getCore().requestData.ID;
            const requestCode = sap.ui.getCore().requestData.code;
            //get block data
            let oBlock = oView.getBindingContext().getObject();
            const blockId = oBlock.ID;
            const blockName = oBlock.processFlowId;
            //build opentext payload
            return {
                documentName: filename,
                mediaType: sMediaType,
                instanceId: null,
                requestId: requestId,
                requestCode: requestCode,
                blockId: blockId,
                blockName: blockName,
                docType: openTextDocument.documentType,
                subType: openTextDocument.documentSubType,
                subTypeLvl2: openTextDocument.documentSubTypeLvl2,
                documentId: openTextDocument.documentId,
                finalDocument: false
            };
        },

        _uploadLocalDocumentContentFromUploadSet: function (oUploadItem, localDocumentId) {
            let sUrl = this._buildLocalDocumentContentUploadUrl(localDocumentId);
            oUploadItem.setUploadUrl(sUrl);
            let oUploadSet = oUploadItem.getParent();
            oUploadItem.addHeaderField(new sap.ui.core.Item({
                key: "Content-Type",
                text: this._getMediaType(oUploadItem.getFileName(), oUploadItem.getMediaType())
            }));
            oUploadSet.setHttpRequestMethod(sap.m.upload.UploaderHttpRequestMethod.Put);
            oUploadSet.uploadItem(oUploadItem);
        },

        _buildLocalDocumentContentUploadUrl: function (localDocumentId) {

            let oMainAppComponent = Component.get(Component.getOwnerIdFor(this.getOwnerComponent().oContainer))
            let sUrl = `/odata/v2/service/project/LocalDocuments(${localDocumentId})/content`

            if (oMainAppComponent.getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))) {
                sUrl = oMainAppComponent.getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))
            }

            return sUrl;
        },

        _uploadLocalDocumentContentFromTableWithUploadPlugin: function (oFileToUpload, localDocumentId) {
            //update content upload url
            let sUrl = this._buildLocalDocumentContentUploadUrl(localDocumentId);
            let oUploadItem = oFileToUpload.itemInstance;
            oUploadItem.setUploadUrl(sUrl);
            //add HTTP content type header
            oUploadItem.addHeaderField(new sap.ui.core.Item({
                key: "Content-Type",
                text: this._getMediaType(oUploadItem.getFileName(), oUploadItem.getMediaType())
            }));
            //set HTTP method => PUT
            let oUploadTable = oUploadItem.getParent();
            oUploadTable.setHttpRequestMethod(sap.m.upload.UploaderHttpRequestMethod.Put);
            //fire file content upload
            oFileToUpload.fnResolve(oUploadItem);
        },

        _getMediaType: function (fileName, mediaTypeFromItem) {
            let fileExtension = fileName.split('.').pop().toLowerCase(); // Obtener la extensión del archivo
            let mediaType = mediaTypeFromItem;

            switch (fileExtension) {
                case 'dwg':
                    mediaType = 'application/x-autocad';
                    break;
                case 'msg':
                    mediaType = 'application/vnd.ms-outlook';
                    break;
                case '7z':
                    mediaType = 'application/x-7z-compressed';
                    break;
                // Otros casos según sea necesario
                default:
                    mediaType = (mediaType === '' ? 'application/octet-stream' : mediaType); // Si no tiene extensión específica, usa el 'mediaType' del item
                    break;
            }

            return mediaType;
        },

    })
})