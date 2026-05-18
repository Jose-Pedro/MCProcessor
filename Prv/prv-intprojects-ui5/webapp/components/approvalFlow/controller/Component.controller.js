// @ts-nocheck
sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/Fragment",
    "sap/ui/core/Messaging",
    "sap/m/upload/UploadSetItem",
    "sap/ui/model/Filter",
    "sap/ui/dom/isBehindOtherElement",
    "sap/ui/core/message/MessageType",
    "sap/ui/core/Component",
    "sap/ui/core/Core"
], function (Controller, Fragment, Messaging, UploadSetItem, Filter, isBehindOtherElement, MessageType, Component, Core) {
    "use strict";

    return Controller.extend("prvintprojectsui5.components.approvalFlow.controller.Component", {

        onInit: function () {
            this._iParentType = null
            this._sPhaseType = null
            this._sBlockType = null
            let oEventBus = Core.getEventBus()
            oEventBus.subscribe('approvalFlows', 'rebind', this._rebindTable, this)
        },

        onExit: function () {
            let oEventBus = Core.getEventBus()
            oEventBus.unsubscribe('approvalFlows', 'rebind', this._rebindTable, this)
        },

        setParentType: function (iParentType, sPhaseType, sBlockType) {
            let showAdd = false
            let oView = this.getView()
            if (iParentType && sPhaseType && sBlockType) {
                this._iParentType = iParentType
                this._sPhaseType = sPhaseType
                this._sBlockType = sBlockType
                showAdd = oView.getModel('configuration').getProperty(`/blockActions/${this._sPhaseType}/${this._sBlockType}/addFlow`)
            }
            oView.byId('AddDocument').setVisible(showAdd)
        },

        showBusy: function () {
            this.getView().byId("approvalFlowsTable").getTable().setBusy(true)
        },

        hideBusy: function () {
            this.getView().byId("approvalFlowsTable").getTable().setBusy(false)
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

        onBeforeRebindTable: function (oEvent) {
            let mBindingParams = oEvent.getParameter("bindingParams")
            mBindingParams.parameters["expand"] = "InstancesPerDocuments,InstancesPerDocuments/Documents"
        },

        _rebindTable: function (sChannel, sPath, oData) {
            if (oData.bVisible) {
                let oContext = this.getView().getBindingContext()
                if (oContext) {
                    if (oContext.getProperty('ID') === oData.blockId) {
                        this._bindSmartTable()
                    }
                }
            }
        },

        _bindSmartTable: function () {
            this.getView().byId('approvalFlowsTable').rebindTable()
        },

        onDPBFieldChange: function (oEvent) {
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
                            }
                        }
                    }
                    if (bHasError) {
                        oModel.resetChanges(null, true, true)
                    }
                },
                error: function (oError) {
                    oModel.resetChanges(null, true, true)
                }
            })
        },

        onAddDocument: function (oEvent) {
            let sBlockId = this.getView().getBindingContext().getProperty('ID');

            if (!this.oAddDocumentDialog) {
                this.loadFragment({
                    name: "prvintprojectsui5.components.approvalFlow.fragment.addDocumentPerBlockDialog"
                }).then(function (oDialog) {
                    this.oAddDocumentDialog = oDialog
                    this.oAddDocumentDialog.setBindingContext(this._callActionAddDocumentPerBlock(sBlockId))
                    this.oAddDocumentDialog.open()
                }.bind(this))
            } else {
                this.oAddDocumentDialog.setBindingContext(this._callActionAddDocumentPerBlock(sBlockId))
                this.oAddDocumentDialog.open()
            }
        },

        onAddDocFlow: function () {
            if (Messaging) Messaging.removeAllMessages()
            this.oAddDocumentDialog.getModel().submitChanges({
                groupId: "changes",
                success: function (oEvent) {
                    let oView = this.getView()
                    oView.byId('approvalFlowsTable').rebindTable()
                }.bind(this),
                error: function () {
                    this.getView().getModel().resetChanges(null, true, true)
                }.bind(this)
            });
            this.oAddDocumentDialog.close()
        },

        onCloseAddDocumentDialog: function () {
            this.getView().getModel().resetChanges(null, true, true)
            this.oAddDocumentDialog.close();
        },

        onShowValidatorsDetailsDialog: function (oEvent) {
            let oView = this.getView()
            let oModel = oView.getModel()
            let oContext = oEvent.getSource().getBindingContext() + "/InstancesPerDocuments"
            let oConstants = oView.getModel("configuration").getProperty("/constants");
            let oInstancesPerDocuments = oView.getModel().getProperty(oContext)
            let oDocumentsPerBlock = oModel.getObject(`/DocumentsPerBlocks('${oInstancesPerDocuments.instanceId}')`)
            let bCanDelete = false
            if (oInstancesPerDocuments && (oInstancesPerDocuments.buttonCompleteVF || oDocumentsPerBlock.status === oConstants.STATUS_CANCELLED)) bCanDelete = true
            if (!this.oValidatorsDetailsDialog) {
                this.loadFragment({
                    name: "prvintprojectsui5.components.approvalFlow.fragment.documentPerBlockDetailDialog"
                }).then(function (oDialog) {
                    this.oValidatorsDetailsDialog = oDialog
                    this.oValidatorsDetailsDialog.bindElement({
                        path: oContext,
                        events: {
                            'change': (oEvent) => {
                                this._bindUploader("docFlowResponsibleUpload", oConstants.VALIDATOR_RESPONSIBLE, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                                if (oInstancesPerDocuments.siteOwnerValidationVF) {
                                    this._bindUploader("docFlowSiteOwnerUpload", oConstants.VALIDATOR_SITE_OWNER, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                                }
                                if (oInstancesPerDocuments.subcontractorValidationVF) {
                                    this._bindUploader("docFlowSubcontractorUpload", oConstants.VALIDATOR_SUBCO, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                                }
                                if (oInstancesPerDocuments.customerValidationVF) {
                                    let oCustomerInformDate = this.getView().byId('IPD_customerInformDate')
                                    if (oCustomerInformDate) oCustomerInformDate.setVisible(true)
                                    this._bindUploader("docFlowCustomerUpload", oConstants.VALIDATOR_CUSTOMER, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                                }
                                if (oInstancesPerDocuments.cellnexValidationVF) {
                                    this._bindUploader("docFlowCellnexUpload", oConstants.VALIDATOR_CELLNEX, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                                }
                            }
                        }
                    })
                    this.oValidatorsDetailsDialog.open()

                    // this._onAttachChangeEventsInstancesPerDocument();
                }.bind(this))
            } else {
                this.oValidatorsDetailsDialog.bindElement({
                    path: oContext,
                    events: {
                        'change': (oEvent) => {
                            this._bindUploader("docFlowResponsibleUpload", oConstants.VALIDATOR_RESPONSIBLE, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                            if (oInstancesPerDocuments.siteOwnerValidationVF) {
                                this._bindUploader("docFlowSiteOwnerUpload", oConstants.VALIDATOR_SITE_OWNER, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                            }
                            if (oInstancesPerDocuments.subcontractorValidationVF) {
                                this._bindUploader("docFlowSubcontractorUpload", oConstants.VALIDATOR_SUBCO, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                            }
                            if (oInstancesPerDocuments.customerValidationVF) {
                                let oCustomerInformDate = this.getView().byId('IPD_customerInformDate')
                                if (oCustomerInformDate) oCustomerInformDate.setVisible(true)
                                this._bindUploader("docFlowCustomerUpload", oConstants.VALIDATOR_CUSTOMER, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                            }
                            if (oInstancesPerDocuments.cellnexValidationVF) {
                                this._bindUploader("docFlowCellnexUpload", oConstants.VALIDATOR_CELLNEX, oInstancesPerDocuments.stepId, this.oValidatorsDetailsDialog.getBindingContext(), bCanDelete)
                            }
                        }
                    }
                })
                this.oValidatorsDetailsDialog.open()

                // this._onAttachChangeEventsInstancesPerDocument();
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
        onCloseValidatorsDetailsDialog: function () {
            this.oValidatorsDetailsDialog.close()
        },

        onStartDocumentFlow: function (oEvent) {
            let oView = this.getView()
            let oTable = oView.byId('approvalFlowsTable')
            let oModel = oView.getModel()
            let sId = oEvent.getSource().getBindingContext().getProperty('ID');
            this.showBusy()
            oModel.callFunction("/DocumentsPerBlocks_docFlowFirstSave", {
                method: "POST",
                success: function (oError) {
                    oTable.rebindTable()
                    this.hideBusy()
                }.bind(this),
                error: function (oError) {
                    oModel.resetChanges(null, true, true);
                    this.hideBusy()
                }.bind(this),
                urlParameters: {
                    'ID': sId
                }
            })
        },

        onCancelDocumentsPerBlocks: function (oEvent) {
            let oView = this.getView()
            let oModel = oView.getModel()
            let sId = oEvent.getSource().getBindingContext().getProperty('ID');
            if (!this.oCancelApprovalFlowDialog) {
                this.loadFragment({
                    name: "prvintprojectsui5.components.approvalFlow.fragment.cancelApprovalFlowDialog"
                }).then(function (oDialog) {
                    this.oCancelApprovalFlowDialog = oDialog
                    this.oCancelApprovalFlowDialog.setBindingContext(this._setDPBCancelDialogContext(oModel, sId))
                    this.oCancelApprovalFlowDialog.open()
                }.bind(this))
            } else {
                this.oCancelApprovalFlowDialog.setBindingContext(this._setDPBCancelDialogContext(oModel, sId))
                this.oCancelApprovalFlowDialog.open()
            }
        },

        onConfirmOnCancelDocument: function (oEvent) {
            if (Messaging) Messaging.removeAllMessages()
            let oView = this.getView()
            let oTable = oView.byId('approvalFlowsTable')
            this.getView().getModel().submitChanges({
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
                        this.oCancelApprovalFlowDialog.close()
                    } else {
                        oTable.rebindTable()
                        this.oCancelApprovalFlowDialog.close()
                        if (this.oValidatorsDetailsDialog) this.oValidatorsDetailsDialog.close()

                    }
                }.bind(this),
                error: function () {
                    oView.getModel().resetChanges(null, true, true)
                    this.oCancelApprovalFlowDialog.close()
                }.bind(this)
            })
        },

        onCancelInstancesPerDocuments: function (oEvent) {
            let oView = this.getView()
            let oModel = oView.getModel()
            let sId = oEvent.getSource().getBindingContext().getProperty('ID');
            if (!this._oCancelDocument) {
                if (!this.oCancelApprovalFlowDialog) {
                    this.loadFragment({
                        name: "prvintprojectsui5.components.approvalFlow.fragment.cancelApprovalFlowDialog"
                    }).then(function (oDialog) {
                        this.oCancelApprovalFlowDialog = oDialog
                        this.oCancelApprovalFlowDialog.setBindingContext(this._setIPDCancelDialogContext(oModel, sId))
                        this.oCancelApprovalFlowDialog.open()
                    }.bind(this))
                } else {
                    this.oCancelApprovalFlowDialog.setBindingContext(this._setIPDCancelDialogContext(oModel, sId))
                    this.oCancelApprovalFlowDialog.open()
                }
            } else {
                this._oCancelDocument.setBindingContext(this._onCancelInstancesPerDocumentAction(oModel, sId))
                this._oCancelDocument.open()
            }
        },

        onCancelCancelDocument: function (oEvent) {
            if (this.oCancelApprovalFlowDialog) {
                this.oCancelApprovalFlowDialog.close()
                this.oCancelApprovalFlowDialog.destroy()
                this.oCancelApprovalFlowDialog = null
            }
            if (this.getView().getModel().hasPendingChanges()) this.getView().getModel().resetChanges(null, true, true)
        },

        onCallActionNextStep: function (oEvent) {
            let oView = this.getView()
            let oTable = oView.byId('approvalFlowsTable')
            let oModel = oView.getModel()
            let sId = this.oValidatorsDetailsDialog.getBindingContext().getProperty('instanceId')
            this.showBusy()
            oModel.callFunction("/DocumentsPerBlocks_nextStep", {
                method: "POST",
                success: function (oResponse, oCallHandler) {
                    this.hideBusy()
                    this.oValidatorsDetailsDialog.getElementBinding().refresh()
                    if (oResponse.status === oView.getModel('configuration').getProperty('/constants/STATUS_COMPLETED')) {
                        oTable.rebindTable()
                        this.oValidatorsDetailsDialog.close()
                    }
                }.bind(this),
                error: function (oError) {
                    this.hideBusy()
                    oModel.resetChanges(null, true, true);
                }.bind(this),
                urlParameters: {
                    'ID': sId
                }
            })
        },

        onAfterItemAdded: function (oEvent) {
            this.uploadedItem = oEvent.getParameter("item")
            this._createDocumentEntity(this.uploadedItem)
        },

        onUploadCompleted: function (oEvent) {
            let oModel = this.getView().getModel()
            let oUploadSet = oEvent.getSource()
            let oParams = oEvent.getParameters()
            if (oParams.status > 399) {
                let oResponse = JSON.parse(oParams.response)
                let oMessage = new sap.ui.core.message.Message({ message: oResponse.error.message.value, persistent: true, type: MessageType.Error });
                Messaging.addMessages(oMessage);
                if (oParams.status > 499) {
                    let sItemUrl = oEvent.getParameter('item').getProperty('uploadUrl')
                    let sGuid = /%28(.*)%29/.exec(sItemUrl)[1]
                    oModel.remove(`/Documents(${sGuid})`, {
                        success: function (oData) {
                            oUploadSet.getBinding("items").refresh()
                        },
                        error: function (oData) {
                            oUploadSet.getBinding("items").refresh()
                        }
                    })
                }
                oUploadSet.removeAllIncompleteItems()
                if (oUploadSet.getBinding("items")) oUploadSet.getBinding("items").refresh()
            }
            if (oUploadSet.getIncompleteItems().length === 0) {
                if (oUploadSet.getBinding("items")) oUploadSet.getBinding("items").refresh()
            }

        },

        onOpenPressed: function (oEvent) {
            oEvent.preventDefault()
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

        onRemovePressed: function (oEvent) {
            oEvent.preventDefault()
            let oResourceBundle = this.getView().getModel("i18n").getResourceBundle()
            let oContext = oEvent.getSource().getBindingContext()
            let oUploadSet = oEvent.getSource().getParent()
            sap.m.MessageBox.confirm(oResourceBundle.getText("documentDeletionConfText"), {
                title: oResourceBundle.getText("documentDeletionConfTitle"),
                onClose: function (oAction) {
                    if (oAction === sap.m.MessageBox.Action.OK) {
                        oContext.delete({ 'groupId': null, 'refreshAfterChange': true }).then(function () {
                            if (oUploadSet.getBinding("items")) {
                                oUploadSet.getBinding("items").refresh()
                            }
                        }.bind(this), function (oError) {
                            if (oUploadSet.getBinding("items")) {
                                oUploadSet.getBinding("items").refresh()
                            }
                        })
                    }
                },                                       //
                actions: [sap.m.MessageBox.Action.OK, sap.m.MessageBox.Action.OK],
                emphasizedAction: sap.m.MessageBox.Action.CANCEL,
            })
        },

        onMessagePopoverPress: function (oEvent) {
            let oSourceControl = oEvent.getSource()
            this._getMessagePopover(oSourceControl)
        },

        onShowAllAttachments: function (oEvent) {
            let oContext = oEvent.getSource().getBindingContext() + "/InstancesPerDocuments"
            if (!this.oShowOtDocumentsFlow) {
                this.loadFragment({
                    name: "prvintprojectsui5.components.approvalFlow.fragment.approvalFlowAttachmentsPopup"
                }).then(function (oDialog) {
                    this.oShowOtDocumentsFlow = oDialog
                    this.oShowOtDocumentsFlow.bindElement({
                        path: oContext,
                        events: {
                            'change': (oEvent) => {
                                let oUploader = this.getView().byId('approvalFlowAttachmentsPopupUploader')
                                let oDialogContext = this.oShowOtDocumentsFlow.getBindingContext()
                                if (oDialogContext) {
                                    let oTemplate = new UploadSetItem({ fileName: "{documentName}", mediaType: "{mediaType}", url: "{ID}", uploadUrl: "{fileUrl}", visibleEdit: false, visibleRemove: false })
                                    oTemplate.attachOpenPressed(this.onOpenPressed, this)
                                    let sPath = oDialogContext + '/Documents'
                                    oUploader.setBindingContext(oDialogContext)
                                    oUploader.setUploadEnabled(false)
                                    oUploader.bindAggregation('items', {
                                        path: sPath,
                                        template: oTemplate,
                                        templateShareable: false
                                    })
                                } else {
                                    if (oUploader) oUploader.unbindAggregation('items', false)
                                }
                            }
                        }
                    })
                    this.oShowOtDocumentsFlow.openBy(oEvent.getSource())
                }.bind(this))
            } else {
                this.oShowOtDocumentsFlow.bindElement({
                    path: oContext,
                    events: {
                        'change': (oEvent) => {
                            let oUploader = this.getView().byId('approvalFlowAttachmentsPopupUploader')
                            let oDialogContext = this.oShowOtDocumentsFlow.getBindingContext()
                            if (oDialogContext) {
                                let oTemplate = new UploadSetItem({ fileName: "{documentName}", mediaType: "{mediaType}", url: "{ID}", uploadUrl: "{fileUrl}", visibleEdit: false, visibleRemove: false })
                                oTemplate.attachOpenPressed(this.onOpenPressed, this)
                                let sPath = oDialogContext + '/Documents'
                                oUploader.setBindingContext(oDialogContext)
                                oUploader.setUploadEnabled(false)
                                oUploader.bindAggregation('items', {
                                    path: sPath,
                                    template: oTemplate,
                                    templateShareable: false
                                })
                            } else {
                                if (oUploader) oUploader.unbindAggregation('items', false)
                            }
                        }
                    }
                })
                this.oShowOtDocumentsFlow.openBy(oEvent.getSource())
            }
        },

        onDialogMessagePopoverPress: function (oEvent) {
            let oSourceControl = oEvent.getSource()
            this._getDialogMessagePopover(oSourceControl)
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

        _callActionAddDocumentPerBlock: function (sBlockId) {
            let oView = this.getView()
            let oModel = oView.getModel()
            this.showBusy()
            oModel.callFunction("/Blocks_addDocumentPerBlock", {
                method: "POST",
                groupId: "changes",
                success: function (oError) {
                    this.hideBusy()
                }.bind(this),
                error: function (oError) {
                    oModel.resetChanges(null, true, true);
                    this.hideBusy()
                }.bind(this),
                urlParameters: {
                    'ID': sBlockId,
                    'documentId': ''
                }
            }).contextCreated().then(function (oContext) {
                this.hideBusy()
                this.getView().byId('addDocumentForm').setBindingContext(oContext)
                return (oContext)
            }.bind(this))
        },

        _bindUploader: function (sIdUploader, sStepId, sCurrentStepId, oContext, bCanDelete) {
            let oUploader = this.getView().byId(sIdUploader)
            if (this.getView().getBindingContext() && oContext && oUploader) {
                let oTemplate = new UploadSetItem({ fileName: "{documentName}", mediaType: "{mediaType}", url: "{ID}", uploadUrl: "{fileUrl}", visibleEdit: false, visibleRemove: bCanDelete })
                oTemplate.attachOpenPressed(this.onOpenPressed, this)
                oTemplate.attachRemovePressed(this.onRemovePressed, this)
                let sPath = oContext + '/Documents'
                oUploader.setBindingContext(oContext)
                oUploader.bindAggregation('items', {
                    path: sPath,
                    filter: [
                        new sap.ui.model.Filter("stepId", sap.ui.model.FilterOperator.EQ, sStepId)
                    ],
                    template: oTemplate,
                    templateShareable: false
                })
                oUploader.getBinding('items').filter([
                    new Filter("stepId", sap.ui.model.FilterOperator.EQ, sStepId, null)
                ])
            } else {
                if (oUploader) oUploader.unbindAggregation('items', false)
            }
        },

        _setDPBCancelDialogContext: function (oModel, sId) {
            oModel.callFunction("/DocumentsPerBlocks_cancel", {
                method: "POST",
                groupId: "changes",
                success: function (oError) {
                }.bind(this),
                error: function (oError) {
                    oModel.resetChanges(null, true, true);
                }.bind(this),
                urlParameters: {
                    'ID': sId,
                    'cancellationReason': '',
                }
            }).contextCreated().then(function (oContext) {
                this.getView().byId('cancelApprovalFlowForm').setBindingContext(oContext)
                return (oContext)
            }.bind(this))
        },

        _setIPDCancelDialogContext: function (oModel, sId) {
            oModel.callFunction("/InstancesPerDocuments_cancel", {
                method: "POST",
                groupId: "changes",
                success: function (oError) {
                }.bind(this),
                error: function (oError) {
                    oModel.resetChanges(null, true, true);
                }.bind(this),
                urlParameters: {
                    'ID': sId,
                    'cancellationReason': ''
                }
            }).contextCreated().then(function (oContext) {
                this.getView().byId('cancelApprovalFlowForm').setBindingContext(oContext)
                return (oContext)
            }.bind(this))

        },

        _createDocumentEntity: function (oItem) {
            let oView = this.getView()
            let oModel = oView.getModel()
            let oInstancesPerDocumentPath = this.oValidatorsDetailsDialog.getBindingContext().getPath()
            let oDocumentsperBlockObject = oModel.getProperty(this.oValidatorsDetailsDialog.getBindingContext().getDeepPath().split("/InstancesPerDocuments")[0])
            let sStepId = this.oValidatorsDetailsDialog.getBindingContext().getObject().stepId

            let data = {
                requestId: this._sRequestId,
                blockId: oDocumentsperBlockObject.blockId,
                requestCode: this._sRequestCode,
                documentName: oItem.getFileName(),
                documentId: oDocumentsperBlockObject.documentId,
                finalDocument: false,
                mediaType: oItem.getMediaType(),
                stepId: sStepId
            }

            oModel.create(oInstancesPerDocumentPath + '/LocalDocuments', data, {
                'success': function (oData) {
                    this._uploadContent(this.uploadedItem, oData.ID)
                }.bind(this)
            })
        },

        _uploadContent: function (oItem, id) {
            let oMainAppComponent = Component.get(Component.getOwnerIdFor(this.getOwnerComponent().oContainer))
            let sUrl = `/odata/v2/service/project/LocalDocuments(${id})/content`
            if (oMainAppComponent.getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))) {
                sUrl = oMainAppComponent.getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))
            }
            oItem.setUploadUrl(sUrl)
            let oUploadSet = oItem.getParent()
            oUploadSet.setHttpRequestMethod(sap.m.upload.UploaderHttpRequestMethod.Put)
            oUploadSet.uploadItem(oItem)
        },

        _getMessagePopover: function (oSourceControl) {
            let oView = this.getView()
            if (!this._oMessagePopover) {
                Fragment.load({
                    name: "prvintprojectsui5.components.approvalFlow.fragment.messagePopOver",
                    controller: this
                }).then(function (oMessagePopover) {
                    oView.addDependent(oMessagePopover)
                    oMessagePopover.openBy(oSourceControl)
                    this._oMessagePopover = oMessagePopover
                })
            }
            return this._oMessagePopover
        },

        _getDialogMessagePopover: function (oSourceControl) {
            if (!this._oMessagePopover) {
                Fragment.load({
                    name: "prvintprojectsui5.components.approvalFlow.fragment.messagePopOver",
                    controller: this
                }).then(function (oMessagePopover) {
                    this.oValidatorsDetailsDialog.addDependent(oMessagePopover)
                    oMessagePopover.openBy(oSourceControl)
                    this._oMessagePopover = oMessagePopover
                }.bind(this))
            }
            return this._oMessagePopover
        },

        _onAttachChangeEventsInstancesPerDocument: function (oEvent) {
            this.getView().byId("IPD_expirationDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_customerInformDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_submissionDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_expectedSubmissionDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_limitSubmissionDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_customerInformDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_endDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_cellnexValidationDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_customerValidationDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_siteOwnerValidationDate").attachChange(this.onFieldChange, this)
            this.getView().byId("IPD_subcontractorValidationDate").attachChange(this.onFieldChange, this)
        }        

    })
})