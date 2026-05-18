sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/Messaging",
    "sap/ui/core/Core"
], function (Controller, Messaging, Core) {
    "use strict";

    return Controller.extend("prvintprojectsui5.components.checklist.controller.Component", {

        onInit: function () {
            this._iParentType = null
            this._sPhaseType = null
            this._sBlockType = null
            let oEventBus = Core.getEventBus()
            oEventBus.subscribe('checklist', 'rebind', this._rebindTable, this)
        },

        onExit: function () {
            let oEventBus = Core.getEventBus()
            oEventBus.unsubscribe('checklist', 'rebind', this._bindSmartTable, this)
        },

        onRowsUpdated: function (oEvent) {
            let oTable = oEvent.getSource() 
            let iRows = oTable.getBinding('rows').getLength()
            oTable.getRowMode().setRowCount(iRows)
        },

        setParentType: function (iParentType, sPhaseType, sBlockType) {
            let showAdd = false
            let oView = this.getView()
            if(iParentType && sPhaseType && sBlockType){
                this._iParentType = iParentType
                this._sPhaseType = sPhaseType
                this._sBlockType = sBlockType
                showAdd = oView.getModel('configuration').getProperty(`/blockActions/${this._sPhaseType}/${this._sBlockType}/addChecklist`)
            }
            oView.byId('checklistTableToolbarBtnAdd').setVisible(showAdd)
        },

        onCreateItem: function () {
            let sBlockId = this.getView().getBindingContext().getProperty('ID');

            if (!this.oAddChecklistItemDialog) {
                this.loadFragment({
                    name: "prvintprojectsui5.components.checklist.fragment.createItemDialog"
                }).then(function (oDialog) {
                    this.oAddChecklistItemDialog = oDialog
                    this.oAddChecklistItemDialog.setBindingContext(this._callActionAddChecklistItem(sBlockId))
                    this.oAddChecklistItemDialog.open()
                }.bind(this))
            } else {
                this.oAddChecklistItemDialog.setBindingContext(this._callActionAddChecklistItem(sBlockId))
                this.oAddChecklistItemDialog.open()
            }
        },

        onAddChecklistItem: function () {
            if(Messaging) Messaging.removeAllMessages()
            let oModel = this.getView().getModel()
            if (oModel.hasPendingChanges()) oModel.submitChanges({
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
            this.oAddChecklistItemDialog.close()
        },

        onDeleteItem: function (oEvent) {
            let sId = oEvent.getSource().getBindingContext().getProperty('ID');
            this._deleteChecklistItem(sId)
        },

        onCloseChecklistItem: function () {
            let oView = this.getView()
            let oModel = oView.getModel()
            oModel.resetChanges(null, true, true)
            this.oAddChecklistItemDialog.close()
        },

        onFieldChange: function (oEvent) {
            if (Messaging) Messaging.removeAllMessages()
            let oModel = this.getView().getModel()
            if (oModel.hasPendingChanges()) oModel.submitChanges({
                success: function (oData) {
                    let bHasError = false
                    let aRefreshEntities = []
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
                                    if (oChangeResponse.data.refreshEntity && oChangeResponse.data.refreshEntity !== '') aRefreshEntities.push(oChangeResponse.data.refreshEntity)
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
                    } else {
                        if (aRefreshEntities.length > 0) {
                            let [sType, sId] = this._getMostRestrictive(aRefreshEntities).split('@')
                            let oEventData = { entity: sType, id: sId }
                            if (oEventData) Core.getEventBus().publish('AGORA_REQUEST', 'CHECKLIST_CHANGE', oEventData)
                        }
                    }
                }.bind(this)
            })
        },

        onBeforeRebindTable: function (oEvent) {
            let mBindingParams = oEvent.getParameter("bindingParams")
            mBindingParams.parameters["expand"] = "type,type/values"
        },

        _rebindTable: function (sChannel, sPath, oData) {
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
            this.getView().byId('checklistSmartable').rebindTable()
        },

        _callActionAddChecklistItem: function (sBlockId) {
            let oView = this.getView()
            let oModel = oView.getModel()
            return oModel.createEntry("/ChecklistItems", {
                properties: { block_ID: sBlockId }
            })
        },

        _deleteChecklistItem: function (sId) {
            let oView = this.getView()
            let oModel = oView.getModel()
            
            oModel.remove(`/ChecklistItems(guid'${sId}')`, {
                success: function(oData) {
                    this._bindSmartTable()
                }.bind(this),
                error: function(oError) {
                    oModel.resetChanges(null, true, true)
                    this._bindSmartTable()
                }.bind(this)
            });
        },

        _getMostRestrictive: function (aEntities) {
            const oPriority = { block: 0, phase: 1, request: 2 }

            let minPriority = Infinity
            let mostRestrictive = null

            for (let sEntity of aEntities) {
                let [type] = sEntity.split('@')
                let sPriority = oPriority[type]
                if (sPriority !== undefined && sPriority < minPriority) {
                    minPriority = sPriority
                    mostRestrictive = sEntity
                    if (minPriority === 0) break // 'block' found
                }
            }

            return mostRestrictive
        }

    })
})
