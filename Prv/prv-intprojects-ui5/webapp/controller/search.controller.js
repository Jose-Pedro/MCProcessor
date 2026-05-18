// @ts-nocheck
sap.ui.define([
    "prvintprojectsui5/controller/Base",
    "sap/ui/core/Messaging",
    "sap/m/MessageBox",
    "sap/ui/core/Fragment"
], (Base, Messaging, MessageBox, Fragment) => {
    "use strict";

    return Base.extend("prvintprojectsui5.controller.search", {
        
        onInit() {
            Base.prototype.onInit.call(this)
            this.handleInboundNavigation()
            let oView = this.getView()
            oView.setModel(Messaging.getMessageModel(), "message")

            let oRouter = this.getOwnerComponent().getRouter()
            oRouter.getRoute("Routesearch").attachMatched(this._onRouteMatched, this)

            this._getCreationOptions()
        },
        
        onAfterRendering: function() {
            let oRequestTable = this.byId("searchByRequestsInnerTable")
            if (oRequestTable) oRequestTable.attachBrowserEvent("contextmenu", this.onRightClick, this)
            let oTaskTable = this.byId("searchByTasksInnerTable")
            if (oTaskTable) oTaskTable.attachBrowserEvent("contextmenu", this.onRightClick, this)
        },

        handleInboundNavigation: function(e) {
            let bParameters = false
            let that = this
            try { bParameters = this.getOwnerComponent().getComponentData().startupParameters } catch (e) {}
            if (bParameters && bParameters.projectCode ) {
                //Buscamos el requestId para este requestCode
                let aFilters = [
                    new sap.ui.model.Filter("searchType", sap.ui.model.FilterOperator.EQ, 0 ),
                    new sap.ui.model.Filter("code", sap.ui.model.FilterOperator.EQ, bParameters.projectCode )
                ]
                var i18n =  this.getOwnerComponent().getModel("i18n").getResourceBundle()
                that.showBusy()
                this.getOwnerComponent().getModel().read("/SearchByRequests", {
                    filters: aFilters,
                    urlParameters:{"$select" : "code,ID", "$top": 10, "$skip": 0 },
                    success: function (oData) {
                        if (oData && oData.results.length === 1){
                            that.getOwnerComponent().getRouter().navTo("Routedetail", { requestId: oData.results[0].ID })
                        }else{
                            that.hideBusy()
                            MessageBox.error(i18n.getText("ErrorProjectnotFound"))
                        } 
                    }.bind(this),
                    error: function (oError) {
                        that.hideBusy()
                        MessageBox.error(i18n.getText("ErrorService")+ oError)
                    }
                })
            }else if (bParameters && bParameters.requestID){
                that.getOwnerComponent().getRouter().navTo("Routedetail", { requestId: bParameters.requestID[0] })
            }
        },

        _onRouteMatched: function (oEvent) {
            if (Messaging) Messaging.removeAllMessages()
            if (this.getView().byId('searchByRequestsTable') && this.getView().byId('searchByRequestsTable').isInitialised()) this.getView().byId('searchByRequestsTable').rebindTable()
            if (this.getView().byId('searchByTasksTable') && this.getView().byId('searchByTasksTable').isInitialised()) this.getView().byId('searchByTasksTable').rebindTable()
            this._getRequestAllowedActions()
        },

        _getCreationOptions: function() {
            let oView = this.getView()
            let oModel =  this.getOwnerComponent().getModel()
            let oConfigModel = this.getOwnerComponent().getModel('configuration')
            oModel.callFunction('/getDefaultCreationFields', {
                method: "POST",
                success: function (oData) {
                    console.log(JSON.stringify(oData))
                    let oCreationOptions = { creationConfig: oData.getDefaultCreationFields.defaultOptionId }
                    let oMenuButton = oView.byId('createRequestMenuButton')
                    let oMenu = oMenuButton.getMenu()
                    oMenu.removeAllItems()
                    let order = 0
                    for (let oCreationConfigs of oData.getDefaultCreationFields.CreationConfigs) {
                        let oMenuItem = new sap.m.MenuItem({"text": `${oCreationConfigs.description} (${oCreationConfigs.ID})`, "press": this.onCreateItemPress.bind(this) })
                        oMenuItem.data('requestType', oCreationConfigs.ID)
                        oMenu.addItem(oMenuItem)
                        order++    
                        oCreationOptions[oCreationConfigs.ID] = {}
                        for (let oField of oCreationConfigs.Fields) {
                            oCreationOptions[oCreationConfigs.ID][oField.name] = {
                                visible: oField.visible, 
                                editable: oField.editable, 
                                mandatory: oField.mandatory
                            }
                            if(oField.defaultValueInteger) {
                                oCreationOptions[oCreationConfigs.ID][oField.name].defaultValue = oField.defaultValueInteger
                            } else if (oField.defaultValueString) {
                                oCreationOptions[oCreationConfigs.ID][oField.name].defaultValue = oField.defaultValueString
                            } else if (oField.defaultValueDate){
                                oCreationOptions[oCreationConfigs.ID][oField.name].defaultValue = oField.defaultValueDate
                            } else {
                                oCreationOptions[oCreationConfigs.ID][oField.name].defaultValue = null
                            }
                        }
                    }
                    oConfigModel.setProperty('/creationParametrization', oCreationOptions)
                }.bind(this),
                error: function (oError) {

                }
            })
        }, 

        /*
        * @description Get ID when a cell is clicked
        * @param {oEvent} = Action of the customer
        */
        onCellCliked: function (oEvent) {
            this.getOwnerComponent().getRouter().navTo("Routedetail", { requestId: oEvent.getParameters().rowBindingContext.getProperty("ID") })
            this.showBusy()
        },

        onRightClick: function (oEvent) {
            oEvent.preventDefault()

            let oDomElement = oEvent.target
            let oRowContext = null
            
            let oClickedControl = sap.ui.getCore().byId(oDomElement.id)
            
            let oParentRowControl = null;
            if (oClickedControl) {
                let oCurrentControl = oClickedControl;
                while (oCurrentControl && !(oCurrentControl instanceof sap.ui.table.Row)) {
                    oCurrentControl = oCurrentControl.getParent();
                }
                oParentRowControl = oCurrentControl;
            }
            
            if (!oParentRowControl) {
                const $domRow = $(oDomElement).closest(".sapUiTableRow");
                if ($domRow.length > 0) {
                    oParentRowControl = sap.ui.getCore().byId($domRow.attr("id"));
                }
            }
                        
            if (oParentRowControl && oParentRowControl instanceof sap.ui.table.Row) {
                oRowContext = oParentRowControl.getBindingContext()
                if (oRowContext) this.openRequestInNewTab(oRowContext)
            } 
        },

        openRequestInNewTab: function (oContext) {
            let oTarget = { semanticObject: "InternalProject", action: "manage" }
            let sParam = '?sap-app-origin-hint=saas_approuter&/detail/' + oContext.getProperty('ID')
            let oParams = {
                'sap-app-origin-hint': sParam
            }
            this._navToApp(oTarget, oParams)
        },

        onCreateItemPress: function (oEvent) {
            let oView = this.getView();
            let oConfigModel = oView.getModel('configuration')
            let sRequestType = oEvent.getSource().data('requestType')
            let sConfigPath = '/creationParametrization/' + sRequestType
            let oBtsCreationConfig = oConfigModel.getProperty(sConfigPath)
            oConfigModel.setProperty('/creationParametrization/default', oBtsCreationConfig)
            oConfigModel.setProperty('/creationParametrization/creationConfig', sRequestType)
            this._onShowCreationPopup('int', 40, sRequestType)
        },

        oncreateRequestMenu: function (oEvent) {

        },

        /*
        * @description Close dialog to create Request
        */
        onCloseCreateDialog: function () {
            if (Messaging) Messaging.removeAllMessages()
            this.getView().getModel().resetChanges(null, true, true) //cancel previously created entity
            this.oCreateRequestDialog.close()
        },

        onCreateRequest: function () {
            if (Messaging) Messaging.removeAllMessages()
            this.showBusy()
            this.getView().getModel().submitChanges({
                success: this.onRequestCreated.bind(this),
                error: this.onRequestError.bind(this)
            })
        },

        /*
        * @description "Create" button save data properly
        * @param {oData} Object with event data
        */
        onRequestCreated: function (oData) {
            let bHasError = false
            if(oData.__batchResponses && oData.__batchResponses.constructor === Array) {
                for(let oBatchResponse of oData.__batchResponses) {
                    if(oBatchResponse.__changeResponses && oBatchResponse.__changeResponses.constructor === Array) {
                        for(let oChangeResponse of oBatchResponse.__changeResponses) {
                            if(oChangeResponse.statusCode && oChangeResponse.statusCode >= 400) {
                                bHasError = true
                            }
                            if(oChangeResponse.response && oChangeResponse.response.statusCode && oChangeResponse.response.statusCode >= 400 ) {
                                bHasError = true
                            }
                        }
                    } else { 
                        if (oBatchResponse.response.statusCode >= 400) bHasError = true
                    }
                }
            }       
            if (bHasError) {
                //NOSONAR this.getView().getModel().resetChanges(null, true, true)
                this.hideBusy()
            } else {
                if (Messaging) Messaging.removeAllMessages()
                this.getOwnerComponent().getRouter().navTo("Routedetail", {
                    requestId: oData.__batchResponses[0].__changeResponses[0].data.ID
                })    
            }
        },

        onMessagePopoverSearchPress: function (oEvent) {
            var oSourceControl = oEvent.getSource()
            this._getMessagePopoverSearch().then(function (oMessagePopover) {
                oMessagePopover.openBy(oSourceControl)
            })
        },

        onMessagePopoverSearchClose: function () {
            if (Messaging) Messaging.removeAllMessages()
        },

        /*
        * @description POP-UP dialog to create a new Request
        * @param {oEvent} Object with event data
        */
        _onShowCreationPopup: function (sProcessFlowId, sRequestType, sCreationConfig) {
            this.getView().getModel().resetChanges(undefined, true, undefined) //reset all changes
            let oView = this.getView();
            let oConfigModel = oView.getModel('configuration')
            let defaultTimestamp = parseInt(
                oConfigModel.getProperty('/creationParametrization/default/requestedDate/defaultValue')
                .replace(/\/Date\((\d+)([+-]\d+)?\)\//, '$1'), 10)
            let defaultDate = new Date(defaultTimestamp)
            if (!this.oCreateRequestDialog) {
                this.loadFragment({
                    name: "prvintprojectsui5.fragments.createRequestDialog"
                }).then(function (oDialog) {
                    this.oCreateRequestDialog = oDialog
                    this.oCreationContext = this.getView().getModel().createEntry("/Requests", {
                        refreshAfterChange: true,
                        properties: {
                            creationConfig: sCreationConfig,
                            processFlowId: sProcessFlowId,
                            requestType: sRequestType,
                            requestedDate: defaultDate,
                            siteId: oConfigModel.getProperty('/creationParametrization/default/siteId/defaultValue'), 
                            projectObjective:  oConfigModel.getProperty('/creationParametrization/default/projectObjective/defaultValue')
                        }
                    })
                    this.getView().byId('createRequestForm').setBindingContext(this.oCreationContext)
                    this.oCreateRequestDialog.open()
                }.bind(this))
            } else {
                this.oCreationContext = this.getView().getModel().createEntry("/Requests", {
                    refreshAfterChange: true,
                    properties: {
                            creationConfig: sCreationConfig,
                            processFlowId: sProcessFlowId,
                            requestType: sRequestType,
                            requestedDate: defaultDate,
                            siteId: oConfigModel.getProperty('/creationParametrization/default/siteId/defaultValue'), 
                            projectObjective:  oConfigModel.getProperty('/creationParametrization/default/projectObjective/defaultValue')
                    }
                })
                this.getView().byId('createRequestForm').setBindingContext(this.oCreationContext)
                this.oCreateRequestDialog.open()
            }
        },

        _getMessagePopoverSearch: function () {
            var oView = this.getView();

            if (!this._oMessagePopover) {
                this._oMessagePopover = Fragment.load({
                    name: "prvintprojectsui5.fragments.messagePopOverSearch",
                    controller: this
                }).then(function (oMessagePopover) {
                    oView.addDependent(oMessagePopover)
                    return oMessagePopover
                })
            }
            return this._oMessagePopover
        },

        /*
        * @description Error when creating the new Request
        */
        onRequestError: function (oError) {
            //NOSONAR this.getView().getModel().resetChanges(null, true, true)
            this.hideBusy()
        },

    });
});