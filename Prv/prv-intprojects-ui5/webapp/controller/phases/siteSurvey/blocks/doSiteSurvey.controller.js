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

        return Base.extend("prvintprojectsui5.controller.phases.siteSurvey.blocks.doSiteSurvey", {
            /*
                onInit --> Subscribe to REQUEST_CHANGE_EVENT
            */
            onInit: function () {
                let oEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'PHASE_2_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
            },

            onExit: function () {
                let oEventBus = Core.getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_2_BINDING_CHANGE', this._onPhaseBindingChange, this);
                oEventBus.unsubscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
            },
            
            onCloseBlock: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oForm = oView.byId('doSiteSurveyForm')
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
                if (oView.getModel('configuration').getData().stepper.firstActivePhase === 'siteSurvey') {
                    let elementPath = this._getContextElement('Blocks','doSiteSurvey', oData.oContext)
                    if (elementPath) {
                        let oOptions = {
                            path: oData.oContext.getDeepPath() + '/' + elementPath,
                            parameters: { groupId: 'blockRead', expand: 'BlockProvision,BlockStatus,BlockProvision/ApproverTypes,BlockProvision/SubcoTypes' },
                            events: { 'dataReceived': (oEvent) => { this._bindDocumentsPerBlock(oEvent); this._bindWorksPerBlock(oEvent); this._bindChecklist(oEvent); this._bindUploadTable(oEvent) }}
                        }
                        oView.bindElement(oOptions)
                    } else {
                        let oModel = oView.getModel('configuration')
                        oModel.setProperty('/processInfo/siteSurvey/doSiteSurvey/VISIBLE_ON', '')
                    }
                }
            },

            _bindUploadTable: function (oEvent) {
                let oUploadTable = this.getView().byId('doSiteSurveyUploadTable')
                if (oUploadTable) this._bindUploadTableFromView(oEvent.getParameter('data')?.ID, true, 'doSiteSurveyUploadTable', 30, 'siteSurvey', 'doSiteSurvey')
            },

            _bindDocumentsPerBlock: function(oEvent) {
                this._bindDocumentsPerBlockFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.dpbVisibleVF, 'doSiteSurveyApprovalFlow', 30, 'siteSurvey', 'doSiteSurvey')
            },

            _bindWorksPerBlock: function(oEvent) {
                this._bindWorksFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.worksVisibleVF, 'doSiteSurveyWorks', 30, 'siteSurvey', 'doSiteSurvey')
            },

            _bindChecklist: function(oEvent) {
                this._bindChecklistFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.checklistVisibleVF, 'doSiteSurveyChecklist', 30, 'siteSurvey', 'doSiteSurvey')
            },

            _onResponsibleChange: function(sChannel, sPath, oData) {
                if(oData.blockProcessFlowId === 'doSiteSurvey') {
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
                    if(sId === oData.blockId && bVisible ) this._bindDocumentsPerBlockFromView(sId, bVisible, 'doSiteSurveyApprovalFlow', 30, 'siteSurvey', 'doSiteSurvey')
                }
            },

            _onActivateSwitch: function (bActivate, oView){
                let oForm = oView.byId('doSiteSurveyForm')
                if(!bActivate) {
                    if(oForm) oForm.setEditable(false)
                } else {
                    if(oForm) oForm.setEditable(true)
                    //NOSONAR let oComponent = oView.byId("doSiteSurveyWorks")
                    //NOSONAR let oComponentInstance = oComponent.getComponentInstance();
                    //NOSONAR if (oComponentInstance) oComponentInstance.refresh()
                }
            },

        })
    })