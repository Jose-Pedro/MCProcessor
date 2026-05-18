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

        return Base.extend("prvintprojectsui5.controller.phases.instCustEquip.blocks.instalService", {
            /*
                onInit --> Subscribe to REQUEST_CHANGE_EVENT
            */
            onInit: function () {
                let oEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'PHASE_6_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
            },

            onExit: function () {
                let oEventBus = Core.getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_6_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
            },
            
            onCloseBlock: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oForm = oView.byId('instalServiceForm')
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
                if (oView.getModel('configuration').getData().stepper.firstActivePhase === 'instCustEquip') {
                    let elementPath = this._getContextElement('Blocks','instalService', oData.oContext)
                    if (elementPath) {
                        let oOptions = {
                            path: oData.oContext.getDeepPath() + '/' + elementPath,
                            parameters: { groupId: 'blockRead', expand: 'BlockProvision,BlockStatus,BlockProvision/ApproverTypes,BlockProvision/SubcoTypes' },
                            events: { 'dataReceived': (oEvent) => { this._bindDocumentsPerBlock(oEvent); this._bindWorksPerBlock(oEvent); this._bindChecklist(oEvent); this._bindUploadTable(oEvent) }}
                        }
                        oView.bindElement(oOptions)
                    } else {
                        let oModel = oView.getModel('configuration')
                        oModel.setProperty('/processInfo/instCustEquip/instalService/VISIBLE_ON', '')
                    }
                }
            },

            _bindUploadTable: function (oEvent) {
                let oUploadTable = this.getView().byId('instalServiceUploadTable')
                if (oUploadTable) this._bindUploadTableFromView(oEvent.getParameter('data')?.ID, true, 'instalServiceUploadTable', 30, 'instCustEquip', 'instalService')
            },

            _bindDocumentsPerBlock: function(oEvent) {
                this._bindDocumentsPerBlockFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.dpbVisibleVF, 'instalServiceApprovalFlow', 30, 'instCustEquip', 'instalService')
            },

            _bindWorksPerBlock: function(oEvent) {
                this._bindWorksFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.worksVisibleVF, 'instalServiceWorks', 30, 'instCustEquip', 'instalService')
            },

            _bindChecklist: function(oEvent) {
                this._bindChecklistFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.checklistVisibleVF, 'instalServiceChecklist', 30, 'instCustEquip', 'instalService')
            },

            _onResponsibleChange: function(sChannel, sPath, oData) {
                if(oData.blockProcessFlowId === 'instalService') {
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
                    if(sId === oData.blockId && bVisible ) this._bindDocumentsPerBlockFromView(sId, bVisible, 'instalServiceApprovalFlow', 30, 'instCustEquip', 'instalService')
                }
            },

            _onActivateSwitch: function (bActivate, oView){
                let oForm = oView.byId('instalServiceForm')
                if(!bActivate) {
                    if(oForm) oForm.setEditable(false)
                } else {
                    if(oForm) oForm.setEditable(true)
                    //NOSONAR let oComponent = oView.byId("instalServiceWorks")
                    //NOSONAR let oComponentInstance = oComponent.getComponentInstance();
                    //NOSONAR if (oComponentInstance) oComponentInstance.refresh()
                }
            },

        })
    })