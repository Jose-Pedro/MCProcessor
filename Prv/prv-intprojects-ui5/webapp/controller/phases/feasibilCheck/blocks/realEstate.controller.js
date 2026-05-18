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

        return Base.extend("prvintprojectsui5.controller.phases.feasibilCheck.blocks.realEstate", {
            /*
                onInit --> Subscribe to REQUEST_CHANGE_EVENT
            */
            onInit: function () {
                this._aPersisted = []
                this._aTransient = []
                this._aDeleted = []
                let oEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'PHASE_1_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
            },

            onExit: function () {
                let oEventBus = Core.getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_1_BINDING_CHANGE', this._onPhaseBindingChange, this);
                oEventBus.unsubscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
            },
            
            onCloseBlock: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oForm = oView.byId('realEstateForm')
                let aErrors = []
                aErrors = oForm.check()
                if(aErrors.length < 1) {
                    this._closeBlockCall()
                } else {
                    this._showErrors(aErrors)
                }
            },

            onContractRestrictionsDataReceived: function (oEvent) {
                var aData = oEvent.getParameter("data");
                this._aContractRestrictionKeys = aData?.results?.map(function (o) {
                    return o.contractRestrictionIdUI;
                });
                console.log("Keys:", this._aContractRestrictionKeys);
            },

            onMultiInit: function (oEvent) {
                let oModel = this.getView().getModel()
                let oContext = this.getView().getBindingContext()
                if(!oContext) return
                if (oContext.getPath().indexOf("/Blocks(") === -1) return

                this._aTransient = []
                oModel.read(oContext.getPath() + "/ContractRestrictions", {
                    success: function (oData) {
                        this._aPersisted = oData.results.map(function (oPersisted) {
                            return oPersisted.contractRestrictionId
                        });
                    }.bind(this)
                });
            },

            _onPhaseBindingChange : function (sChannel, sPath, oData) {
                let oView = this.getView()
                if (oView.getModel('configuration').getData().stepper.firstActivePhase === 'feasibilCheck') {
                    let elementPath = this._getContextElement('Blocks','realEstate', oData.oContext)
                    if (elementPath) {
                        let oOptions = {
                            path: oData.oContext.getDeepPath() + '/' + elementPath,
                            parameters: { groupId: 'blockRead', expand: 'BlockProvision,BlockStatus,BlockProvision/ApproverTypes,BlockProvision/SubcoTypes,BlockProvision/RealStateFeasibilities,BlockProvision/RealStateRisks,BlockProvision/RenegoNeeded,BlockProvision/RealStateFeasibilityExplanations,ContractRestrictions' },
                            events: { 'dataReceived': (oEvent) => { 
                                this._bindDocumentsPerBlock(oEvent)
                                this._bindWorksPerBlock(oEvent)
                                this._bindChecklist(oEvent) 
                                this._bindUploadTable(oEvent)
                            }}
                        }
                        oView.bindElement(oOptions)
                    } else {
                        let oModel = oView.getModel('configuration')
                        oModel.setProperty('/processInfo/feasibilCheck/realEstate/VISIBLE_ON', '')
                    }
                }
            },

            _bindUploadTable: function (oEvent) {
                let oUploadTable = this.getView().byId('realEstateUploadTable')
                if (oUploadTable) this._bindUploadTableFromView(oEvent.getParameter('data')?.ID, true, 'realEstateUploadTable', 30, 'feasibilCheck', 'realEstate')
            },

            _bindDocumentsPerBlock: function(oEvent) {
                this._bindDocumentsPerBlockFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.dpbVisibleVF, 'realEstateApprovalFlow', 30, 'feasibilCheck', 'realEstate')
            },

            _bindWorksPerBlock: function(oEvent) {
                this._bindWorksFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.worksVisibleVF, 'realStateWorks', 30, 'feasibilCheck', 'realEstate')
            },

            _bindChecklist: function(oEvent) {
                this._bindChecklistFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.checklistVisibleVF, 'realStateChecklist', 30, 'feasibilCheck', 'realEstate')
            },

            _onResponsibleChange: function(sChannel, sPath, oData) {
                if(oData.blockProcessFlowId === 'realEstate') {
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
                    if(sId === oData.blockId && bVisible ) this._bindDocumentsPerBlockFromView(sId, bVisible, 'realEstateApprovalFlow', 30, 'feasibilCheck', 'realEstate')
                }
            },

            _onActivateSwitch: function (bActivate, oView){
                let oForm = oView.byId('realEstateForm')
                if(!bActivate) {
                    if(oForm) oForm.setEditable(false)
                } else {
                    if(oForm) oForm.setEditable(true)
                    //NOSONAR let oComponent = oView.byId("realEstateWorks")
                    //NOSONAR let oComponentInstance = oComponent.getComponentInstance();
                    //NOSONAR if (oComponentInstance) oComponentInstance.refresh()
                }
            },

        })
    })