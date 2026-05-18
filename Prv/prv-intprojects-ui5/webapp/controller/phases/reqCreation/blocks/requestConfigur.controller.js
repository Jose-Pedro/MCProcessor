// @ts-nocheck
sap.ui.define([
    "prvintprojectsui5/controller/Base",
    "sap/m/upload/UploadSetItem",
    "sap/ui/core/Messaging",
    "sap/ui/core/Core",

    "sap/m/MessageToast",
    "sap/ui/core/BusyIndicator",
    "sap/ui/core/routing/History",
    "sap/ui/model/Filter",
    "sap/ui/core/Fragment",
    "sap/ui/core/message/MessageType",
    "sap/m/Text",
    "sap/m/TextArea",

    "sap/m/Dialog",
    "sap/m/Button",
    "sap/m/Label",
    "sap/m/library"
],
    /**
     * @param {typeof prvintprojectsui5.controller.Base} Base
     */
    function (Base, UploadSetItem, Messaging, Core, MessageToast, BusyIndicator, History, Filter, Fragment, MessageType, Text, TextArea, Dialog, Button, Label, mobileLibrary) {
        "use strict";

        return Base.extend("prvintprojectsui5.controller.phases.reqCreation.blocks.requestConfigur", {

            onInit: function () {
                let oEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'PHASE_0_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_PHASE_0', this._onRequestBindingChange, this)
            },

            onExit: function () {
                let oEventBus = Core.getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_0_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_PHASE_0', this._onRequestBindingChange, this)
            },

            onCloseBlock: function (oEvent) {                
                    this._closeBlockCall()
            },

            _onRequestBindingChange: function (sChannel, sPath, oData) {
                if(oData && oData.oContext) {
                    let sPath = oData.oContext.getDeepPath()
                    if (sPath) {
                        let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                        if (oTable) oTable.setTableBindingPath(sPath + '/RequestDocumentsPerBlockDefaultValid')
                        if (oTable) oTable.rebindTable()
                    }
                        let oPreferredProvider = this.getView().byId('preferredProvider')
                        if (oPreferredProvider) oPreferredProvider.setBindingContext(oData.oContext)
                }
            },

            _onPhaseBindingChange: function (sChannel, sPath, oData) {
                if (this.getView().getModel('configuration').getData().stepper.firstActivePhase === 'reqCreation') {
                    let oView = this.getView()
                    let elementPath = this._getContextElement('Blocks', 'requestConfigur', oData.oContext)
                    let bActivated = oView.getParent().getModel().getProperty('/' + elementPath)
                    if (elementPath && bActivated) {
                        oView.bindElement({
                            path: oData.oContext.getDeepPath() + '/' + elementPath,
                            parameters: { groupId: 'blockRead', expand: 'BlockProvision,BlockStatus,BlockProvision/SiteSurveyNeeded' },
                            events: { dataReceived: (oEvent) => { this._bindUploadTable(oEvent) } }
                        })
                    } else {
                        let oModel = oView.getModel('configuration')
                        oModel.setProperty('/processInfo/reqCreation/requestConfigur/VISIBLE_ON', '')
                    }
                }
            },

            _bindUploadTable: function (oEvent) {
                let oUploadTable = this.getView().byId('requestConfigurUploadTable')
                if (oUploadTable) this._bindUploadTableFromView(oEvent.getParameter('data')?.ID, true, 'requestConfigurUploadTable', 30, 'reqCreation', 'requestConfigur')
            },

            /**
            * @description When adding document show Add Document Per Block Dialog
            * @param {oEvent} Object with event data
            */
            onShowAddDocumentPerBlockValidDialog: function (oEvent) {
                this._onShowAddDocumentPerBlockValidDialog("reqCreation--requestConfigurView--OTRequestRequestDocumentsPerBlockDefaultValid", oEvent);
            },

            /**
            * @description Reset data from new document flow if an error ocurred
            */
            _onAddDocFlow: function (oEvent) {
                let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                if (oTable) this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid").rebindTable()
            },

            /**
            * @description Documents per block data change and update
            * @param {oEvent} field changed with new value
            */
            onDocumentsPerBlockDefaultValidFieldChange: function (oEvent) {
                var oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                if (oTable) this._onDocumentsPerBlockDefaultValidFieldChange(oEvent, oTable)
            },

            /**
            * @description Call action cancel documents per block
            * @param {oEvent} Object with event with button delete pressed
            */
            onCallActionCancelDocumentsPerBlocksDefaultValid: function (oEvent) {
                this._callActionCancelDocumentsPerBlocksDefaultValid("reqCreation--requestConfigurView--OTRequestRequestDocumentsPerBlockDefaultValid", oEvent)

            },

            onAddDocFlowPerRequestDefaultValues: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                if (this.oAddDocumentDialog === undefined) this.oAddDocumentDialog = oEvent.getSource().getParent().getParent()

                this.oAddDocumentDialog.getModel().submitChanges({
                    groupId: "changes",
                    success: this._onAddDocFlow.bind(this),
                    error: this._onAddDocFlowError.bind(this)
                })

                this.oAddDocumentDialog.close();
            },

            onCloseAddDocumentPerRequestDefaultValues: function (oEvent) {
                this._oAddDocumentDialogDefaultValid.close();
            },
            /**
            * @description Reset data from new document flow if an error ocurred
            */
            _onAddDocFlowError: function () {
                this.getView().getModel().resetChanges(null, true, true)
            },

            onApproveDeleteAllDocumentsDefault: function (oEvent) {
                let sRequestId = this.getView().getBindingContext().getProperty('ID');
                var i18n = this.getView().getModel("i18n").getResourceBundle()
                var ButtonType = mobileLibrary.ButtonType;
                var DialogType = mobileLibrary.DialogType;
                if (!this.oApproveDialog) {
                    this.oApproveDialog = new Dialog({
                        type: DialogType.Message,
                        title: i18n.getText("DeleteAllDocuments"),
                        content: new Text({ text: i18n.getText("AreYouSureDeleteAllDocuments") }),
                        beginButton: new Button({
                            type: ButtonType.Emphasized,
                            text: i18n.getText("yes"),
                            press: function () {
                                let oModel = this.getView().getModel()
                                oEvent.getSource().getBindingContext().getModel().callFunction("/Requests_deleteAllDocumentsPerBlockDefaultValid", {
                                    method: "POST",
                                    success: function (oError) {
                                        let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                                        if (oTable) oTable.rebindTable();
                                        this.oApproveDialog.close();
                                        this.hideBusy()
                                    }.bind(this),
                                    error: function (oError) {
                                        oModel.resetChanges();
                                        this.oApproveDialog.close();
                                        this.hideBusy()
                                    }.bind(this),
                                    urlParameters: {
                                        'ID': sRequestId
                                    }
                                })
                            }.bind(this),
                            dependentOn: this.getView()
                        }),
                        endButton: new Button({
                            text: i18n.getText("cancel"),
                            press: function () {
                                this.oApproveDialog.close();
                            }.bind(this),
                            dependentOn: this.getView()
                        })
                    });
                }

                this.oApproveDialog.open();
            },
            onExpandRequestConfigur: function () {
                let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                if (oTable) this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid").rebindTable();
            },
            onResetAllDocumentsDefault: function (oEvent) {
                var ButtonType = mobileLibrary.ButtonType;
                var DialogType = mobileLibrary.DialogType;
                let sRequestId = this.getView().getBindingContext().getProperty('ID');
                var i18n = this.getView().getModel("i18n").getResourceBundle()
                if (!this.oApproveDialog2) {
                    this.oApproveDialog2 = new Dialog({
                        type: DialogType.Message,
                        title: i18n.getText("ResetAllDocuments"),
                        content: new Text({ text: i18n.getText("AreyouSureResetAllDocuments") }),
                        beginButton: new Button({
                            type: ButtonType.Emphasized,
                            text: i18n.getText("yes"),
                            press: function () {
                                let oModel = this.getView().getModel()
                                oEvent.getSource().getBindingContext().getModel().callFunction("/Requests_onUpdateToDefaultDocumentsPerBlockDefaultValid", {
                                    method: "POST",
                                    success: function (oError) {
                                        let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                                        if (oTable) this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid").rebindTable();

                                        this.hideBusy()
                                        this.oApproveDialog2.close();
                                    }.bind(this),
                                    error: function (oError) {
                                        oModel.resetChanges();
                                        this.hideBusy()
                                        this.oApproveDialog2.close();
                                    }.bind(this),
                                    urlParameters: {
                                        'ID': sRequestId
                                    }
                                })
                            }.bind(this),
                            dependentOn: this.getView()
                        }),
                        endButton: new Button({
                            text: i18n.getText("cancel"),
                            press: function () {
                                this.oApproveDialog2.close();
                            }.bind(this),
                            dependentOn: this.getView()
                        })
                    });
                }

                this.oApproveDialog2.open();
            },
        })
    })