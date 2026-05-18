// @ts-nocheck
sap.ui.define([
    "prvintprojectsui5/controller/Base",
    "sap/m/upload/UploadSetItem",
    "sap/ui/core/Messaging",
    "sap/ui/core/Core"
],
    /**
     * @param {typeof prvintprojectsui5.contoller.Base} Base
     */
    function (Base, UploadSetItem, Messaging, Core) {
        "use strict";

        return Base.extend("prvintprojectsui5.controller.phases.techCostAnalys.blocks.doTechDoc", {
            /*
                onInit --> Subscribe to REQUEST_CHANGE_EVENT
            */
            onInit: function () {
                let oEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'PHASE_3_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
            },

            onExit: function () {
                let oEventBus = Core.getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_3_BINDING_CHANGE', this._onPhaseBindingChange, this);
                oEventBus.unsubscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
            },
            
            onCloseBlock: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oForm = oView.byId('doTechDocForm')
                let aErrors = []
                aErrors = oForm.check()
                if(aErrors.length < 1) {
                    this._closeBlockCall()
                } else {
                    this._showErrors(aErrors)
                }
            },

            _onPhaseBindingChange : function (sChannel, sPath, oData) {
                let oView = this.getView()
                if (oView.getModel('configuration').getData().stepper.firstActivePhase === 'techCostAnalys') {
                    let elementPath = this._getContextElement('Blocks','doTechDoc', oData.oContext)
                    if (elementPath) {
                        let oOptions = {
                            path: oData.oContext.getDeepPath() + '/' + elementPath,
                            parameters: { groupId: 'blockRead', expand: 'BlockProvision,BlockStatus,BlockProvision/ApproverTypes,BlockProvision/SubcoTypes' },
                            events: { 'dataReceived': (oEvent) => { this._bindDocumentsPerBlock(oEvent); this._bindWorksPerBlock(oEvent); this._bindChecklist(oEvent); this._bindUploadTable(oEvent) }}
                        }
                        oView.bindElement(oOptions)
                    } else {
                        let oModel = oView.getModel('configuration')
                        oModel.setProperty('/processInfo/techCostAnalys/doTechDoc/VISIBLE_ON', '')
                    }
                }
            },

            _bindUploadTable: function (oEvent) {
                let oUploadTable = this.getView().byId('doTechDocUploadTable')
                if (oUploadTable) this._bindUploadTableFromView(oEvent.getParameter('data')?.ID, true, 'doTechDocUploadTable', 30, 'techCostAnalys', 'doTechDoc')
            },

            _bindDocumentsPerBlock: function(oEvent) {
                this._bindDocumentsPerBlockFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.dpbVisibleVF, 'doTechDocApprovalFlow', 30, 'techCostAnalys', 'doTechDoc')
            },

            _bindWorksPerBlock: function(oEvent) {
                this._bindWorksFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.worksVisibleVF, 'doTechDocWorks', 30, 'techCostAnalys', 'doTechDoc')
            },

            _bindChecklist: function(oEvent) {
                this._bindChecklistFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.checklistVisibleVF, 'doTechDocChecklist', 30, 'techCostAnalys', 'doTechDoc')
            },

            _onResponsibleChange: function(sChannel, sPath, oData) {
                if(oData.blockProcessFlowId === 'doTechDoc') {
                    const oBinding = this.getView().getElementBinding();
                    if (oBinding) {
                        oBinding.refresh(true);
                        this._onSubcoChangeSuccess(this.byId("selectExternalResponsible"))
                    }
                }     
            },

            _onRequestDocumentChange: function (sChannel, sPath, oData) {
                let oView = this.getView();
                let oContext = oView.getBindingContext();
                if (oContext) {
                    let sId = oContext.getProperty("ID")
                    let bVisible = oContext.getProperty("dpbVisibleVF") 
                    if(sId === oData.blockId && bVisible ) this._bindDocumentsPerBlockFromView(sId, bVisible, 'doTechDocApprovalFlow', 30, 'techCostAnalys', 'doTechDoc')
                }
            },

            _onActivateSwitch: function (bActivate, oView){
                let oForm = oView.byId('doTechDocForm')
                if(!bActivate) {
                    if(oForm) oForm.setEditable(false)
                } else {
                    if(oForm) oForm.setEditable(true)
                    //NOSONAR let oComponent = oView.byId("doTechDocWorks")
                    //NOSONAR let oComponentInstance = oComponent.getComponentInstance();
                    //NOSONAR if (oComponentInstance) oComponentInstance.refresh()
                }
            },

        })
    })