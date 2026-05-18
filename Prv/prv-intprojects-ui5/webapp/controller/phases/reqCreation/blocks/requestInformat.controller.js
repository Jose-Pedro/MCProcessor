// @ts-nocheck
sap.ui.define([
    "prvintprojectsui5/controller/Base",
    "sap/m/upload/UploadSetItem",
    "sap/ui/core/Messaging",
    "sap/ui/core/Core"
],
    /**
     * @param {typeof prvintprojectsui5.controller.Base} Base
     */
    function (Base, UploadSetItem, Messaging, Core) {
        "use strict";

        return Base.extend("prvintprojectsui5.controller.phases.reqCreation.blocks.requestInformat", {

            onInit: function () {
                let oEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'PHASE_0_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_PHASE_0', this._onRequestBindingChange, this)
            },

            onExit: function( ) {
                let oEventBus = Core.getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_0_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_PHASE_0', this._onRequestBindingChange, this)
            },

            onCloseBlock: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oForm = oView.byId('requestInformatForm')
                let aErrors = []
                aErrors = oForm.check()
                if(aErrors.length < 1) {
                    this._closeBlockCall()                    
                    let oView = this.getView()
                    let oModel = oView.getModel()
                    let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                    if(oTable) oTable.rebindTable()

                } else {
                    this._showErrors(aErrors)
                }
            },

            _onRequestBindingChange: function(sChannel, sPath, oData) {
                let oRequestedDate = this.getView().byId('requestedDate')
                if(oRequestedDate) oRequestedDate.setBindingContext(oData.oContext)
                let oCreatedAt = this.getView().byId('createdAt')
                if(oCreatedAt) oCreatedAt.setBindingContext(oData.oContext)
                let oDescription = this.getView().byId('description')
                if(oDescription) oDescription.setBindingContext(oData.oContext)
                let oRequestType = this.getView().byId('requestType')
                if(oRequestType) oRequestType.setBindingContext(oData.oContext)
                let oRequester = this.getView().byId('requester')
                if(oRequester) oRequester.setBindingContext(oData.oContext)
                let oManager = this.getView().byId('manager')
                if(oManager) oManager.setBindingContext(oData.oContext)
                let oProjectObjective = this.getView().byId('projectObjective')
                if(oProjectObjective) oProjectObjective.setBindingContext(oData.oContext)
                let oPMOManager = this.getView().byId('PMOManager')
                if(oPMOManager) oPMOManager.setBindingContext(oData.oContext)
                let oMoaOperation = this.getView().byId('moaOperation')
                if(oMoaOperation) oMoaOperation.setBindingContext(oData.oContext)
            },

            _onPhaseBindingChange: function (sChannel, sPath, oData) {
                if (this.getView().getModel('configuration').getData().stepper.firstActivePhase === 'reqCreation') {
                    let oView = this.getView()
                    let elementPath = this._getContextElement('Blocks','requestInformat', oData.oContext)
                    let bActivated = oView.getParent().getModel().getProperty('/' + elementPath)
                    if (elementPath  && bActivated) {
                        oView.bindElement({
                            path: oData.oContext.getDeepPath() + '/' + elementPath,
                            parameters: { groupId: 'blockRead', expand: 'BlockProvision,BlockStatus',
                            },
                            //NOSONAR events: {
                            //NOSONAR     dataReceived: (oEvent) => {this._bindUploader(oEvent)}
                            //NOSONAR }
                        })
                    } else {
                        let oModel = oView.getModel('configuration')
                        oModel.setProperty('/processInfo/reqCreation/requestInformat/VISIBLE_ON', '')
                    }
                }
            }

        })
    })