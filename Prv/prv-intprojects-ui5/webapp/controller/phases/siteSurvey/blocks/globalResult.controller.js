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

        return Base.extend("prvintprojectsui5.controller.phases.siteSurvey.blocks.globalResult", {
            /*
                onInit --> Subscribe to REQUEST_CHANGE_EVENT
            */
            onInit: function () {
                let oEventBus = Core.getEventBus()
                let oGlobalEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'PHASE_2_BINDING_CHANGE', this._onPhaseBindingChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_PHASE_2', this._onRequestBindingChange, this)
                oGlobalEventBus.subscribe('AGORA_REQUEST', 'CHECKLIST_CHANGE', this._onChecklistChange, this)
            },

            onExit: function () {
                let oEventBus = Core.getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_2_BINDING_CHANGE', this._onPhaseBindingChange, this);
                oEventBus.unsubscribe('AGORA_REQUEST', 'RESPONSIBLE_CHANGE', this._onResponsibleChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', this._onRequestDocumentChange, this)
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_PHASE_2', this._onRequestBindingChange, this)
                oGlobalEventBus.unsubscribe('AGORA_REQUEST', 'CHECKLIST_CHANGE', this._onChecklistChange, this)
            },
            
            onCloseBlock: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oForm = oView.byId('siteSurveyglobalResultForm')
                let aErrors = []
                aErrors = oForm.check()
                if(aErrors.length < 1) {
                    this._closeBlockCall()
                } else {
                    this._showErrors(aErrors)
                }
            },

            onFieldChange: function () {
                let oView = this.getView()
                let oModel = oView.getModel()
                if(oModel.hasPendingChanges()) oModel.submitChanges({
                    groupId: "changes", 
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
                        if(bHasError) oModel.resetChanges(null, true, true)
                        this._bindSmartTable()
                    }.bind(this), 
                    error: function () {
                        oModel.resetChanges(null, true, true)
                    }.bind(this)
                })
            },

            _onPhaseBindingChange : function (sChannel, sPath, oData) {
                let oView = this.getView()
                if (oView.getModel('configuration').getData().stepper.firstActivePhase === 'siteSurvey') {
                    let elementPath = this._getContextElement('Blocks','globalResult', oData.oContext)
                    if (elementPath) {
                        let oOptions = {
                            path: oData.oContext.getDeepPath() + '/' + elementPath,
                            parameters: { groupId: 'blockRead', expand: 'BlockProvision,BlockStatus,BlockProvision/ApproverTypes,BlockProvision/SubcoTypes,BlockProvision/Complexities' },
                            events: { 'dataReceived': (oEvent) => { this._bindDocumentsPerBlock(oEvent); this._bindWorksPerBlock(oEvent); this._bindChecklist(oEvent); this._bindUploadTable(oEvent) }}
                        }
                        oView.bindElement(oOptions)
                    } else {
                        let oModel = oView.getModel('configuration')
                        oModel.setProperty('/processInfo/siteSurvey/globalResult/VISIBLE_ON', '')
                    }
                }
            },

            _bindUploadTable: function (oEvent) {
                let oUploadTable = this.getView().byId('siteSurveyGlobalResultUploadTable')
                if (oUploadTable) this._bindUploadTableFromView(oEvent.getParameter('data')?.ID, true, 'siteSurveyGlobalResultUploadTable', 30, 'siteSurvey', 'globalResult')
            },

            _bindDocumentsPerBlock: function(oEvent) {
                this._bindDocumentsPerBlockFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.dpbVisibleVF, 'siteSurveyGlobalResultApprovalFlow', 30, 'siteSurvey', 'globalResult')
            },

            _bindWorksPerBlock: function(oEvent) {
                this._bindWorksFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.worksVisibleVF, 'siteSurveyGlobalResultWorks', 30, 'siteSurvey', 'globalResult')
            },

            _bindChecklist: function(oEvent) {
                this._bindChecklistFromView(oEvent.getParameter('data')?.ID, oEvent.getParameter('data')?.checklistVisibleVF, 'siteSurveyGlobalResultChecklist', 30, 'siteSurvey', 'globalResult')
            },

            _onResponsibleChange: function(sChannel, sPath, oData) {
                if(oData.blockProcessFlowId === 'globalResult') {
                    let oBinding = this.getView().getElementBinding()
                    if (oBinding) {
                        oBinding.refresh(true)
                        this._onSubcoChangeSuccess(this.byId("selectExternalResponsible"))
                    }
                }     
            },

            _onRequestBindingChange: function(sChannel, sPath, oData) {
                let oView = this.getView()
                let oTable = oView.byId('impactedCustomersTable')
                oTable.setBindingContext(oData.oContext)
                oTable.rebindTable()
            },

            _onChecklistChange: function (sChannel, sPath, oData) {
                if (oData.entity === 'block') {
                    let oView = this.getView()
                    let oBinding = oView.getElementBinding()
                    let currentId = oView.getBindingContext().getProperty('ID')
                    if (currentId === oData.id) {
                        oBinding.refresh(true)
                    }
                }
            },

            _onRequestDocumentChange: function (sChannel, sPath, oData) {
                let oView = this.getView();
                let oContext = oView.getBindingContext();
                if (oContext) {
                    let sId = oContext.getProperty("ID")
                    let bVisible = oContext.getProperty("dpbVisibleVF") 
                    if(sId === oData.blockId && bVisible ) this._bindDocumentsPerBlockFromView(sId, bVisible, 'siteSurveyGlobalResultApprovalFlow', 30, 'siteSurvey', 'globalResult')
                }
            },

            _onActivateSwitch: function (bActivate, oView) {
                let oForm = oView.byId('globalResultForm')
                if(!bActivate) {
                    if(oForm) oForm.setEditable(false)
                } else {
                    if(oForm) oForm.setEditable(true)
                    //NOSONAR let oComponent = oView.byId("globalResultWorks")
                    //NOSONAR let oComponentInstance = oComponent.getComponentInstance();
                    //NOSONAR if (oComponentInstance) oComponentInstance.refresh()
                }
            },

            _bindSmartTable: function () {
                this.getView().byId('impactedCustomersTable').rebindTable()
            },

        })
    })