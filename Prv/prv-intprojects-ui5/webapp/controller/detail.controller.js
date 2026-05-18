// @ts-nocheck
sap.ui.define([
    "prvintprojectsui5/controller/Base",
    "sap/ui/core/Messaging",
    "sap/ui/core/Fragment",
    "sap/ui/core/Core",
    "sap/m/BusyDialog",
    'sap/ui/model/Filter',
    'sap/ui/model/Sorter',
    "sap/m/MessageBox",
    "prvintprojectsui5/util/Dialogs",
    "prvintprojectsui5/util/OData",
    "prvintprojectsui5/util/Batch",
    "prvintprojectsui5/util/Binding",
    "prvintprojectsui5/util/ViewHelpers",
    "sap/m/upload/UploadSetItem",
    "sap/ui/core/message/MessageType"
],
    /**
     * @param {typeof prvintprojectsui5.controller.Base} Base
     */
    function (Base, Messaging, Fragment, Core, BusyDialog, Filter, Sorter, MessageBox, Dialogs, OData, Batch, Binding, V, UploadSetItem, MessageType) {
        "use strict";
        var oMessageWaringPopover;
        const messageWarningsModelSizeLimit = 1000;
        return Base.extend("prvintprojectsui5.controller.detail", {

            onInit: function () {
                this.loadMessagePopover()
                Base.prototype.onInit.call(this)
                let oRouter = this.getOwnerComponent().getRouter()
                oRouter.getRoute("Routedetail").attachMatched(this._onRouteMatched, this)

                let oView = this.getView()
                oView.setModel(Messaging.getMessageModel(), "message")

                // In onInit or similar
                this._oCountModel = new sap.ui.model.json.JSONModel({
                    linkedRequestCount: 0
                });
                oView.setModel(this._oCountModel, "count");

                // Messaging.registerObject(oView, true)

                // let oEventBus = this.getOwnerComponent().getEventBus()
                let oEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'PHASE_CLOSED', this._onPhaseClosed, this)
                //NOSONAR oEventBus.subscribe('AGORA_REQUEST', 'SITE_CHANGED', this._onSiteChanged, this)
                //NOSONAR oEventBus.subscribe('AGORA_REQUEST', 'DOC_DELETED', this._onDefaultDocumentDeleted, this)
            },

            onExit: function () {
                let oEventBus = Core.getEventBus();
                // let oEventBus = this.getOwnerComponent().getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_CLOSED', this._onPhaseClosed, this)
                //NSONAR     oEventBus.unsubscribe('AGORA_REQUEST', 'SITE_CHANGED', this._onSiteChanged, this)
                //NSONAR     oEventBus.unsubscribe('AGORA_REQUEST', 'DEFAULT_DOC_DELETED', this._onDefaultDocumentDeleted, this)
            },

            onPhaseSelectionChange: function (oEvent) {
                let sSelectedKey = oEvent.getParameter("key")
                this.getView().getModel('configuration').setProperty('/stepper/firstActivePhase', sSelectedKey)
                this._loadSelectedPhase(sSelectedKey)
                // if (oContext) {
                //     this._managePhaseClose(oContext)
                // }
            },

            onNavBack: function () {
                this._navBack()
            },

            onCancelRequest: function (oEvent) {
                let oView = this.getView()
                let oModel = oView.getModel()
                if (Messaging) Messaging.removeAllMessages()
                if (!this._cancelRequestDialog) {
                    this.loadFragment({
                        name: "prvintprojectsui5.fragments.cancelRequestDialog"
                    }).then(function (oDialog) {
                        this._cancelRequestDialog = oDialog
                        oModel.callFunction("/Requests_cancel", {
                            method: "POST",
                            refreshAfterChange: true,
                            groupId: "changes",
                            error: function () {
                                oModel.resetChanges(null, true, true);
                            }.bind(this),
                            urlParameters: {
                                'ID': oView.getBindingContext().getProperty('ID'),
                                'cancellationReason': '',
                                'cancellationComments': ''
                            }
                        }).contextCreated().then(function (oContext) {
                            this._cancelRequestDialog.setBindingContext(oContext)
                        }.bind(this))
                        this._cancelRequestDialog.open()
                    }.bind(this))
                } else {
                    oModel.callFunction("/Requests_cancel", {
                        method: "POST",
                        refreshAfterChange: true,
                        groupId: "changes",
                        error: function () {
                            oModel.resetChanges(null, true, true);
                        }.bind(this),
                        urlParameters: {
                            'ID': oView.getBindingContext().getProperty('ID'),
                            'cancellationReason': '',
                            'cancellationComments': ''
                        }
                    }).contextCreated().then(function (oContext) {
                        this._cancelRequestDialog.setBindingContext(oContext)
                    }.bind(this))
                    this._cancelRequestDialog.open()
                }
            },

            onLaunchRenegos: function () {
                let oView = this.getView()
                let oContext = oView.getBindingContext()
                var that = this;
                var i18n = this.getView().getModel("i18n").getResourceBundle();
                var sTitle = i18n.getText("titleRenegotiation");
                var sMessage = i18n.getText("warningSaveDataLaunch", [sTitle]);
                MessageBox.warning(sMessage, {
                    actions: [MessageBox.Action.YES, MessageBox.Action.NO],
                    onClose: function (oAction) {
                        if (oAction === "YES") {
                            var oTarget = {
                                semanticObject: "Renegotiation",
                                action: "Display"
                            };
                            var oParam = {
                                externalPortal: "true",
                                workflow: "renegotiation",
                                requestId: oContext.getProperty('code'),
                                navFrom: that.getWfId(oContext.getProperty('requestType'))
                            };
                            that._navToApp(oTarget, oParam);

                        }
                    }
                });

            },

            onLaunchPermit: function (oEvent) {
                let oView = this.getView()

                var that = this;
                var i18n = this.getView().getModel("i18n").getResourceBundle();
                var sTitle = i18n.getText("titlePermits");
                var sMessage = i18n.getText("warningSaveDataLaunch", [sTitle]);
                sap.m.MessageBox.warning(sMessage, {
                    actions: [MessageBox.Action.YES, MessageBox.Action.NO],
                    onClose: function (oAction) {
                        if (oAction === "YES") {

                            //NOSONAR let oBlockProvisioning = that.blockProvisionInfo("feasibilCheck", "permits")
                            //NOSONAR if (!oBlockProvisioning) {
                            let sphaseId = that.phaseInfo("feasibilCheck").ID;
                            let aFilters = [
                                new sap.ui.model.Filter("phaseId", sap.ui.model.FilterOperator.EQ, sphaseId),
                                new sap.ui.model.Filter("processFlowId", sap.ui.model.FilterOperator.EQ, "permits")
                            ];
                            that.getView().setBusy(true);
                            oView.getModel().read("/Blocks", {
                                filters: aFilters,
                                urlParameters: {
                                    expand: 'BlockProvision'

                                },
                                success: function (oData) {

                                    oView.getModel().read("/BlockProvision(guid'" + oData.results[0].ID + "')", {
                                        success: function (datos) {
                                            that.getView().setBusy(false);
                                            that.permitsLaunchnav(datos)
                                        }.bind(this),
                                        error: function (oError) {
                                            that.getView().setBusy(false);
                                            console.error("Error fetching data:", oError);
                                        }
                                    });

                                }.bind(this),
                                error: function (oError) {
                                    that.getView().setBusy(false);
                                    console.error("Error:", oError);
                                }
                            });
                            //NOSONAR } else {
                            //NOSONAR     that.permitsLaunchnav(oBlockProvisioning)
                            //NOSONAR }

                        }
                    }.bind(that)
                });
            },

            onCancelRequestConfirm: function () {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oConfigModel = oView.getModel('configuration')
                if (Messaging) Messaging.removeAllMessages()
                oModel.submitChanges({
                    groupId: 'changes',
                    success: function () {
                        oConfigModel.setProperty('/refreshAll', false)
                        oView.getObjectBinding().refresh(true)
                    }.bind(this),
                    error: function () {
                        oModel.resetChanges(null, true, true)
                    }.bind(this)
                })
                this._cancelRequestDialog.close()
            },

            onCancelRequestCancel: function () {
                this.getView().getModel().resetChanges(null, true, true)
                this._cancelRequestDialog.close()
            },

            onHoldRequest: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oContext = this.getView().getBindingContext()
                if (oContext.getProperty('status') === 12) {
                    this._setOnHoldInmediate(this)
                } else {
                    if (!this.onHoldRequestDialog) {
                        this.loadFragment({
                            name: "prvintprojectsui5.fragments.onHoldRequestDialog"
                        }).then(function (oDialog) {
                            this.onHoldRequestDialog = oDialog
                            this._callOnHoldAction(this)
                        }.bind(this))
                    } else {
                        this.onHoldRequestDialog.open()
                    }
                }
            },

            onHoldRequestConfirm: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                this.getView().getModel().submitChanges({
                    groupId: 'changes',
                    success: this._onHoldRequestSuccess.bind(this),
                    error: this._onHoldRequestError.bind(this)
                })
                this.onHoldRequestDialog.close()
            },

            /*
            * @description Close dialog to set "On hold" status
            * @param {oEvent} Object with event data
            */
            onHoldRequestCancel: function (oEvent) {
                this.getView().getModel().resetChanges(null, true, true);
                this.onHoldRequestDialog.close()
            },

            onReopenRequest: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                let oConfigModel = this.getView().getModel('configuration')
                oModel.callFunction('/Requests_reopen', { method: "POST", urlParameters: { 'ID': oContext.getProperty('ID') } })
                oModel.submitChanges({
                    'success': function (oData) {
                        oConfigModel.setProperty('/editMode', true)
                        oConfigModel.setProperty('refreshAll', false)
                        oView.getObjectBinding().refresh(true)
                    },
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                    }
                })
            },

            onGoToTop: function (oEvent) {
                let oView = this.getView()
                oView.byId("mainPage")._setScrollPosition(0)
            },

            onConfirmDocuments: function () {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                oModel.callFunction('/Requests_confirmDocuments', {
                    method: "POST",
                    urlParameters: { 'ID': oContext.getProperty('ID') },
                    'success': function (oData) {
                        oView.getObjectBinding().refresh()
                    }.bind(this),
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                    },
                    refreshAfterChange: true
                })
            },

            onConfirmServices: function () {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                oModel.callFunction('/Requests_confirmService', {
                    method: "POST",
                    urlParameters: { 'ID': oContext.getProperty('ID') },
                    'success': function (oData) {
                        oView.getObjectBinding().refresh()
                    }.bind(this),
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                    },
                    refreshAfterChange: true
                })
            },

            onConfirmInventory: function () {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                oModel.callFunction('/Requests_confirmInventoryCheck', {
                    method: "POST",
                    urlParameters: { 'ID': oContext.getProperty('ID') },
                    'success': function (oData) {
                        if (oData === 'true') {
                            MessageBox.warning(oView.getModel("i18n").getResourceBundle().getText('confirmInventoryText'), {
                                actions: [MessageBox.Action.OK, MessageBox.Action.CANCEL],
                                emphasizedAction: MessageBox.Action.OK,
                                onClose: function (sAction) {
                                    if (sAction === MessageBox.Action.OK) {
                                        this._confirmInventory()
                                    }
                                }.bind(this),
                                dependentOn: this.getView()
                            });
                        } else {
                            this._confirmInventory()
                        }
                    }.bind(this),
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                    },
                    refreshAfterChange: true
                })
            },

            _confirmInventory: function () {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                oModel.callFunction('/Requests_confirmInventory', {
                    method: "POST",
                    urlParameters: { 'ID': oContext.getProperty('ID') },
                    'success': function (oData) {
                        oView.getObjectBinding().refresh()
                    }.bind(this),
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                    },
                    refreshAfterChange: true
                })
            },

            _onRouteMatched: function (oEvent) {
                let oArgs, oView
                let that = this
                oArgs = oEvent.getParameter("arguments")
                oView = this.getView();
                oView.requestId = oArgs.requestId
                if (Messaging) Messaging.removeAllMessages()

                this._getLastPhase(oArgs.requestId)
                this._getFirstPhase(oArgs.requestId)
                this._getSingleRequestProcessRead(oArgs.requestId)
                this._getPhasesStatus(oArgs.requestId)
                this._getRequestAllowedActions()
                this._getBlockAllowedActions(oArgs.requestId)
                this._loadLinkedRequestCount(oArgs.requestId);
                //initialize message warnings model
                this.initializeMessageWarningsModel();

                oView.getModel('configuration').setProperty('/refreshAll', true)
                oView.bindElement({
                    path: `/Requests(${oArgs.requestId})`,
                    parameters: {
                        expand: 'Phases,Site,RequestProvision,RequestDocumentsPerBlockDefaultValid,RequestStatus,OnHoldReasons,CancellationReasons,RequestTypes,Managers,RequestProvision/ProjectObjectives,RequestProvision/MoaOperationTypes,RequestProvision/Classifications,RequestProvision/PMOManagers,RequestProvision/Requesters,RequestProvision/PreferredProviders,Site/CellnexZones,Site/Zones,Site/InfraOrigins,Site/InfraOwnerships,Site/InfraStatus,Site/Marketables,Site/ABFZones,Site/ManagingCompanies,Site/CellnexProjects,Site/Exploiteds,Site/Companies,RequestProvision/CacheR3Entities'
                    },
                    events: {
                        change: this._onBindingChange.bind(this),
                        dataRequested: function (oEvent) {
                            oView.setBusy(true)
                        },
                        dataReceived: function (oEvent) {
                            oView.setBusy(false)
                            that.getWarningRestrictions();

                        }
                    }
                })
                this.hideBusy()
            },

            _loadSelectedPhase(sSelectedKey) {
                let oTabBar = this.byId("requestFlow")

                // Determina la vista a cargar
                let sViewName = "";
                switch (sSelectedKey) {
                    case "reqCreation": sViewName = "prvintprojectsui5.view.phases.reqCreation.reqCreation"; break;
                    case "feasibilCheck": sViewName = "prvintprojectsui5.view.phases.feasibilCheck.feasibilCheck"; break;
                    case "siteSurvey": sViewName = "prvintprojectsui5.view.phases.siteSurvey.siteSurvey"; break;
                    case "techCostAnalys": sViewName = "prvintprojectsui5.view.phases.techCostAnalys.techCostAnalys"; break;
                    case "custOfferAccept": sViewName = "prvintprojectsui5.view.phases.custOfferAccept.custOfferAccept"; break;
                    case "manageAdapt": sViewName = "prvintprojectsui5.view.phases.manageAdapt.manageAdapt"; break;
                    case "instCustEquip": sViewName = "prvintprojectsui5.view.phases.instCustEquip.instCustEquip"; break;
                    case "finalValidation": sViewName = "prvintprojectsui5.view.phases.finalValidation.finalValidation"; break;
                }

                // Cachea vistas para evitar recarga
                if (!this._views) this._views = {}

                if (this._views[sSelectedKey]) {
                    let oView = this._views[sSelectedKey]
                    oTabBar.removeAllContent()
                    oTabBar.addContent(oView)

                    let oRequestContext = this.getView().getBindingContext()
                    if (oRequestContext) this._refreshPhase(sSelectedKey, oRequestContext)
                } else {
                    this.getOwnerComponent().runAsOwner(function () {
                        sap.ui.core.mvc.XMLView.create({ id: sSelectedKey, viewName: sViewName }).then(function (oView) {
                            this._views[sSelectedKey] = oView
                            oTabBar.removeAllContent()
                            oTabBar.addContent(oView)

                            let requestContext = this.getView().getBindingContext()
                            this._refreshPhase(sSelectedKey, requestContext)
                        }.bind(this));
                    }.bind(this))
                }
            },

            _refreshPhase: function (sSelectedKey, oContext) {
                let oEventBus = Core.getEventBus()
                switch (sSelectedKey) {
                    case 'reqCreation':
                        oEventBus.publish('AGORA_REQUEST', 'REFRESH_PHASE_0', { oContext: oContext })
                        break
                    case 'feasibilCheck':
                        oEventBus.publish('AGORA_REQUEST', 'REFRESH_PHASE_1', { oContext: oContext })
                        break
                    case 'siteSurvey':
                        oEventBus.publish('AGORA_REQUEST', 'REFRESH_PHASE_2', { oContext: oContext })
                        break
                    case 'techCostAnalys':
                        oEventBus.publish('AGORA_REQUEST', 'REFRESH_PHASE_3', { oContext: oContext })
                        break
                    case 'custOfferAccept':
                        oEventBus.publish('AGORA_REQUEST', 'REFRESH_PHASE_4', { oContext: oContext })
                        break
                    case 'manageAdapt':
                        oEventBus.publish('AGORA_REQUEST', 'REFRESH_PHASE_5', { oContext: oContext })
                        break
                    case 'instCustEquip':
                        oEventBus.publish('AGORA_REQUEST', 'REFRESH_PHASE_6', { oContext: oContext })
                        break
                    case 'finalValidation':
                        oEventBus.publish('AGORA_REQUEST', 'REFRESH_PHASE_7', { oContext: oContext })
                        break
                }
            },

            _loadLinkedRequestCount: function (sRequestId) {
                const oModel = this.getView().getModel();

                const aFilters = [
                    new sap.ui.model.Filter("parentInstanceID", sap.ui.model.FilterOperator.EQ, sRequestId),
                    new sap.ui.model.Filter({
                        filters: [
                            new sap.ui.model.Filter("associationType", sap.ui.model.FilterOperator.EQ, null),
                            new sap.ui.model.Filter("associationType", sap.ui.model.FilterOperator.EQ, "null")
                        ],
                        and: false // OR between the two associationType filters
                    })
                ];

                oModel.read("/SearchDtLinkedRequestSet/$count", {
                    groupId: 'SearchDtLinkedRequestSet',
                    filters: aFilters,
                    success: (iCount) => {
                        this._oCountModel.setProperty("/linkedRequestCount", iCount);
                    },
                    error: (oError) => {
                        console.error("Error getting linked request count", oError);
                    }
                });
            },

            _getSingleRequestProcessRead: function (sRequestId) {
                let oView = this.getView()
                let oModel = oView.getModel()
                oModel.read(`/singleRequestProcess(${sRequestId})/Set`, {
                    groupId: 'singleRequestProcess',
                    'success': function (oData) {
                        let oConfigModel = oView.getModel('configuration').getData()
                        let data = oData.results
                        for (let i = 0; i < data.length; i++) {
                            if (oConfigModel.processInfo[data[i].PHASE_ID] === undefined) {
                                oConfigModel.processInfo[data[i].PHASE_ID] = [];
                            }
                            oConfigModel.processInfo[data[i].PHASE_ID][data[i].BLOCK_ID_PK] = data[i]
                        }
                    }.bind(this),
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                        this.hideBusy()
                    }.bind(this)
                })
            },

            /*
            * @description Get last active phase with status "In progress" for a Request
            * @param {sRequestId} = Request ID on use
            */
            _getLastPhase: function (sRequestId) {
                let oView = this.getView()
                let oModel = oView.getModel()
                oModel.read(`/lastActivePhases(${sRequestId})/Set`, {
                    groupId: 'lastActivePhases',
                    'success': function (oData) {
                        let oConfigModel = oView.getModel('configuration')
                        oConfigModel.setProperty('/stepper/lastActivePhase', oData.results[0].lastPhase ? oData.results[0].lastPhase : '99')
                    }.bind(this),
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                        this.hideBusy()
                    }.bind(this)
                })
            },

            /*
            * @description Get first active phase with status "In progress" for a Request
            * @param {sRequestId} = Request ID on use
            */
            _getFirstPhase: function (sRequestId) {
                let oView = this.getView()
                let oModel = oView.getModel()
                oModel.read(`/firstInprogressPhase(${sRequestId})/Set`, {
                    groupId: 'firstInprogressPhase',
                    'success': function (oData) {
                        let oConfigModel = oView.getModel('configuration')
                        let sLastPhase = oData.results.length > 0 ? oData.results[0].processFlowId : 'reqCreation'
                        oConfigModel.setProperty('/stepper/firstActivePhase', sLastPhase)
                        oView.byId('requestFlow').setSelectedKey(sLastPhase)
                        this._loadSelectedPhase(sLastPhase)
                    }.bind(this),
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                        this.hideBusy()
                    }.bind(this)
                })
            },

            _onBindingChange: function (oEvent) {
                let oView = this.getView()
                if (oView.getBindingContext()) {
                    // publish request binding change event
                    let oContext = this.getView().getBindingContext()
                    let oConfigModel = oView.getModel('configuration')
                    let sStatus = oContext.getProperty('status')
                    if (sStatus === 7 || sStatus === 12 || sStatus === 32) {
                        oConfigModel.setProperty('/editMode', true)
                    } else {
                        oConfigModel.setProperty('/editMode', false)
                    }

                    if (oConfigModel.getProperty('/refreshAll')) {
                        let sManager = oContext.getProperty('manager')

                        let sSelectedKey = oConfigModel.getProperty('/stepper/firstActivePhase')
                        if (sManager && sManager !== '') {
                            oConfigModel.setProperty('/takeOwnerShip', false)
                        } else {
                            oConfigModel.setProperty('/takeOwnerShip', true)
                        }
                        sap.ui.getCore().requestData = {
                            ID: oContext.getProperty('ID'),
                            code: oContext.getProperty('code'),
                            country: oContext.getProperty('country'),
                            oView: this.getView()
                        }
                        let oChatList = this.getView().byId('chatList')
                        if (oChatList) oChatList.setListBindingPath(oContext.getDeepPath() + '/Chats')

                        this._refreshPhase(sSelectedKey, oContext)
                        oConfigModel.setProperty('/refreshAll', true)
                    }
                } else {
                    // No data for the binding
                    this.getOwnerComponent().getRouter().getTargets().display("notFound");
                }
            },

            _onPhaseClosed: function (sChannel, sPath, oData) {
                //refresh las active phase info
                let oView = this.getView()
                let oConfigModel = oView.getModel('configuration')
                //NOSONAR let oEventBus = Core.getEventBus()
                let oIconTabBar = oView.byId('requestFlow')
                let sRequestId = oView.getBindingContext().getProperty('ID')
                this._getLastPhase(sRequestId)
                this._getPhasesStatus(sRequestId)
                oIconTabBar.setSelectedKey(oData.processFlowId)
                oConfigModel.setProperty('/stepper/firstActivePhase', oData.processFlowId)
                this._loadSelectedPhase(oData.processFlowId)
            },

            /**
             * @description Navigates to the MasterDataSiteEdition application
             * @param {sap.ui.base.Event} oEvent - The triggering event
             */
            onSiteNav: function (oEvent) {
                const oView = this.getView();
                const oBindingContext = oView.getBindingContext();

                const oTarget = {
                    semanticObject: "MasterDataSiteEdition",
                    action: "Display"
                };

                const oParams = {
                    externalPortal: "true",
                    smd: btoa(oBindingContext.getProperty('siteId')),
                    navFrom: "Internal projects"
                };

                this._navToApp(oTarget, oParams);
            },

            /**
            * Shows site information dialog with Agora section content
            * @param {sap.ui.base.Event} oEvent - The triggering event
            */
            onSiteInfoNav: function (oEvent) {
                Dialogs.openOrLoad(
                    this,
                    "prvintprojectsui5.fragments.dialogSiteInfoList",
                    "dialogSiteInfoList",
                    function (oDialog) {
                        // Only load AgoraSection if dialog content is empty (first time)
                        if (!oDialog.getContent() || oDialog.getContent().length === 0) {
                            this.loadFragment({
                                name: "prvintprojectsui5.fragments.AgoraSection"
                            }).then(function (oFragment) {
                                oDialog.addContent(oFragment);
                            }.bind(this)).catch(function (oError) {
                                console.error("Error loading AgoraSection fragment:", oError);
                            });
                        }
                    }.bind(this),
                    true
                );
            },

            navToAgoraProject: function (oEvent) {

                var oTarget, oParam, sParam, requestID;
                oTarget = {
                    semanticObject: "",
                    action: "Display"
                };

                requestID = this.getView().getBindingContext().getProperty('ID') === oEvent.getSource().getBindingContext().getObject().childInstanceID ? oEvent.getSource().getBindingContext().getObject().parentInstanceID : oEvent.getSource().getBindingContext().getObject().childInstanceID;
                switch (oEvent.getSource().getBindingContext().getObject().requestType) {
                    case 1:
                        oTarget.semanticObject = "Renegotiation";
                        oParam = {
                            blockId: "",
                            externalPortal: "true",
                            workflow: "renegotiation",
                            requestId: oEvent.getSource().getText(),
                            navFrom: "commercialRequest"
                        };
                        break;
                    case 3:

                        oTarget.semanticObject = "PermitsPlanning";
                        sParam = "?sap-app-origin-hint=saas_approuter&/PermitsDetail/" + requestID
                        oParam = {
                            'sap-app-origin-hint': sParam
                        }
                        break;
                    case 4:

                    case 10:

                    case 11:
                        oTarget.semanticObject = "CellnexOS_ProvisionUX";
                        oTarget.action = "display"
                        sParam = "?sap-app-origin-hint=saas_approuter&/request/" + requestID
                        oParam = {
                            'sap-app-origin-hint': sParam
                        }
                        break;
                    case 20:
                    case 30:
                        oTarget.semanticObject = "buildtosuit";
                        oTarget.action = "manage"
                        sParam = "?sap-app-origin-hint=saas_approuter&/request/" + requestID
                        oParam = {
                            'sap-app-origin-hint': sParam
                        }
                        break;
                    default:
                        let oMessage = new sap.ui.core.message.Message({ message: "Error Navegation not defined", persistent: true, type: "Error" });
                        Messaging.addMessages(oMessage);

                        break;
                }

                if (oTarget.semanticObject !== "") {
                    this._navToApp(oTarget, oParam);
                }


            },

            /**
             * Handles navigation to the Inventory management application
             * @param {sap.ui.base.Event} oEvent - The triggering event
             */
            onInventoryNav: function (oEvent) {
                const oView = this.getView();
                const oBindingContext = oView.getBindingContext();

                if (!oBindingContext) {
                    console.error("No binding context available for inventory navigation");
                    return;
                }

                const oTarget = {
                    semanticObject: "inventory",
                    action: "manage"
                };

                const oParams = {
                    location: oBindingContext.getProperty('siteId'),
                    requestId: oBindingContext.getProperty('code')
                };

                if (!oParams.location || !oParams.requestId) {
                    console.error("Required navigation parameters missing", oParams);
                    return;
                }

                this._navToApp(oTarget, oParams);
            },

            /**
             * Handles navigation to the Services management application
             * @param {sap.ui.base.Event} oEvent - The triggering event
             */
            onServiceNav: function (oEvent) {
                const oView = this.getView();
                const oBindingContext = oView.getBindingContext();

                if (!oBindingContext) {
                    console.error("No binding context available for service navigation");
                    return;
                }

                const sSiteId = oBindingContext.getProperty('siteId');
                if (!sSiteId) {
                    console.error("Site ID is missing for service navigation");
                    return;
                }

                const oTarget = {
                    semanticObject: "services",
                    action: "manage"
                };

                const oParams = {
                    locationId: sSiteId
                };

                this._navToApp(oTarget, oParams);
            },

            /**
             * Handles opening of the Service List dialog
             * @param {sap.ui.base.Event} oEvent - The triggering event
             */
            onServiceListNav: function () {
                let oModel = this.getView().getModel()
                let oFilter = [new sap.ui.model.Filter("Idrequest", sap.ui.model.FilterOperator.EQ, this.getView().getBindingContext().getProperty('code'))]
                if (!this._dialogServiceList) {
                    this.loadFragment({
                        name: "prvintprojectsui5.fragments.dialogServiceList"
                    }).then(function (oDialog) {
                        this._dialogServiceList = oDialog
                        this._dialogServiceList.setModel(new sap.ui.model.json.JSONModel(), "ServiceListModel")
                        this._getServiceList(oModel, oFilter)
                    }.bind(this))
                } else {
                    this._getServiceList(oModel, oFilter)
                }
            },

            onServiceListClose: function () {
                this._dialogServiceList.close()
            },

            onpressServiceListItem: function (oEvent) {
                let oTarget = { semanticObject: "services", action: "manage" }
                let oParam = { serviceId: oEvent.getSource().getText() }
                this._navToApp(oTarget, oParam)
            },

            onBeforeRebindServiceList: function (oEvent) {
                let oBinding = oEvent.getParameter("bindingParams");
                let oFilter = new sap.ui.model.Filter("Idrequest", sap.ui.model.FilterOperator.EQ, this.getView().getBindingContext().getProperty('code'));
                oBinding.filters.push(oFilter);
            },

            /**
             * Handles navigation to the Work Orders application
             * @param {sap.ui.base.Event} oEvent - The triggering event
             */
            onWONav: function (oEvent) {
                const oView = this.getView();
                const oContext = oView.getBindingContext();

                if (!oContext) {
                    console.error("No binding context available for Work Order navigation");
                    return;
                }

                const oTarget = {
                    semanticObject: "CellnexOS_WorkOrders",
                    action: "display"
                };

                const oParams = {
                    externalPortal: true,
                    requestId: oContext.getProperty('code'),
                    program: oContext.getProperty('customerProgram'),
                    company: oContext.getProperty('company'),
                    site: oContext.getProperty('siteId'),
                    navFrom: "CellnexOS_Provision",
                    btnWorkOrders: true
                };

                this._navToApp(oTarget, oParams);
            },

            onBeforeRebindChatList: function (oEvent) {
                let oBindingParams = oEvent.getParameter("bindingParams");

                // Clear existing sorters
                oBindingParams.sorter = [];

                // Add new sorter (sorting by "date" descending)
                oBindingParams.sorter.push(new sap.ui.model.Sorter("date", true)); // true = descending
            },

            /**
             * Shows the chat popover and binds chat data
             * @param {sap.ui.base.Event} oEvent - The triggering event
             */
            onShowChat: function (oEvent) {
                const oView = this.getView();
                const oSource = oEvent.getSource();
                return Dialogs.openByOrLoadPopover(this, "prvintprojectsui5.fragments.showChatPopover", "chatPopover", oSource, function (oPopOver) {
                    if (!this._chatDataBound) {
                        // First time: bind data
                        const oBindingContext = oView.getBindingContext();
                        if (oBindingContext) {
                            this._bindChatData(oView);
                        }
                        this._chatDataBound = true;
                    } else {
                        // Subsequent times: refresh
                        this._refreshChatList();
                    }
                }.bind(this),
                    true
                );
            },

            /**
             * Binds chat data to the list
             * @private
             * @param {sap.ui.core.mvc.View} oView - Current view
             */
            _bindChatData: function (oView) {
                const oBindingContext = oView.getBindingContext();
                if (!oBindingContext) {
                    console.error("No binding context available for chat");
                    return;
                }

                const oChatList = oView.byId('chatList');
                if (oChatList) {
                    oChatList.setListBindingPath(oBindingContext.getDeepPath() + '/Chats');
                    oChatList.rebindList();
                }
            },

            /**
             * Refreshes the chat list
             * @private
             */
            _refreshChatList: function () {
                const oChatList = this.getView().byId('chatList');
                if (oChatList) {
                    oChatList.rebindList();
                }
            },

            /**
             * Posts a new chat message
             * @param {sap.ui.base.Event} oEvent - The triggering event
             */
            onPostChat: function (oEvent) {
                const sValue = oEvent.getParameter("value");
                if (!sValue || sValue.trim() === "") {
                    return;
                }

                const oView = this.getView();
                const oBindingContext = oView.getBindingContext();

                if (!oBindingContext) {
                    console.error("No binding context available for chat post");
                    return;
                }

                const oModel = oView.getModel();
                const sPath = oBindingContext.getPath() + '/Chats';

                oModel.create(sPath, {
                    'ID': oBindingContext.getProperty('ID'),
                    'text': sValue.trim()
                }, {
                    success: this._handleChatPostSuccess.bind(this),
                    error: this._handleChatPostError.bind(this)
                });
            },

            /**
             * Handles successful chat post
             * @private
             */
            _handleChatPostSuccess: function (oData) {
                const oChatList = this.getView().byId('chatList');
                if (oChatList) {
                    oChatList.rebindList();
                }
            },

            /**
             * Handles chat post error
             * @private
             * @param {object} oError - Error object
             */
            _handleChatPostError: function (oError) {
                console.error("Error posting chat message:", oError);
                // Consider showing a message to the user
            },

            /**
            * Handles the linked request dialog display and initialization
            * @param {sap.ui.base.Event} oEvent - The event that triggered this action
            * @description 
            * This function manages the lifecycle of the linked request dialog. It either:
            * 1. Loads the fragment for the first time and initializes the dialog, or
            * 2. Reopens an already loaded dialog and refreshes its data
            * It also resets any pending model changes before proceeding
            */
            onLinkedRequest: function (oEvent) {
                var oView = this.getView();

                oView.getModel().resetChanges(undefined, true, undefined);
                Dialogs.openOrLoad(
                    this,
                    "prvintprojectsui5.fragments.linkedRequestDialog",
                    "oLinkedRequest",
                    null,
                    true
                );
            },

            onLinkedRequestDialogAfterClose: function () {
                Dialogs.destroy(this, "oCreateLink")
            },

            onCreateLinkRequest: function () {
                this.getView().getModel().resetChanges(undefined, true, undefined);

                Dialogs.openOrLoad(
                    this,
                    "prvintprojectsui5.fragments.createLinkRequestDialog",
                    "oCreateLink",
                    function () {
                        setTimeout(this._configColumnCreateLinkRequestFragment.bind(this), 0);
                    }.bind(this),
                    true
                );
            },

            _configColumnCreateLinkRequestFragment: function () {
                console.log("_configColumnCreateLinkRequestFragment")
                var oTable = this.byId("createLinkedRequestTable").getTable();
                if (oTable) {
                    var aColumns = oTable.getColumns();
                    aColumns.forEach(function (oColumn) {
                        oColumn.setWidth("0%");
                    });
                }
            },

            onCreateLinkedRequest: function () {
                const BATCH_GROUP_NAME = "linkedRequestCreationGroup";
                const that = this;
                const oView = this.getView();
                const oContext = oView.getBindingContext();
                const oRequestParentData = oContext.getObject();

                // Get selected items from table
                const oSmartTable = oView.byId("createLinkedRequestTable");
                const oTable = oSmartTable.getTable();
                const aSelectedIndices = oTable.getSelectedIndices();

                // Validate selection
                if (!aSelectedIndices.length) {
                    sap.m.MessageBox.show("Please select at least one request to link.", {
                        icon: sap.m.MessageBox.Icon.WARNING,
                        title: "No Selection",
                        actions: [sap.m.MessageBox.Action.OK]
                    });
                    return;
                }

                // Prepare model configuration
                const oModel = oView.getModel();
                this._configureModelForBatch(oModel, BATCH_GROUP_NAME);

                // Build payload
                const oPayload = this._buildLinkRequestPayload(oRequestParentData, oTable, aSelectedIndices);

                // Execute the linking operation
                this._executeLinkRequest(oModel, oPayload, that, oRequestParentData.ID, BATCH_GROUP_NAME);
            },

            onUpdateLinkedProjectUnlink: function (oEvent) {
                const UNLINK_GROUP_NAME = "onUpdateLinkedProjectUnlinkGroup";
                const TABLE_ID = "linkedRequestTable";
                const oBusyDialog = new BusyDialog();
                const oView = this.getView();

                // Get selected items from table
                const oSmartTable = oView.byId(TABLE_ID);
                const oTable = oSmartTable.getTable();
                const aSelectedItems = oTable.getSelectedItems();

                // Validate selection
                if (!aSelectedItems.length) {
                    sap.m.MessageToast.show("Please select a request first");
                    return;
                }

                // Get selected request data
                const oContextTable = aSelectedItems[0].getBindingContext();
                const oRequest = oContextTable.getObject();

                // Validate linkID
                if (!oRequest.linkID) {
                    sap.m.MessageToast.show("linkID not found");
                    return;
                }

                // Prepare model and execute unlink
                const oModel = oView.getModel();
                this._configureModelForBatch(oModel, UNLINK_GROUP_NAME);

                const oData = this._buildUnlinkPayload(oRequest.linkID);

                this._executeUnlinkRequest(oModel, oData, oRequest, oBusyDialog);
            },

            /**
             * Configure model for batch operations
             * @param {sap.ui.model.Model} oModel - The model to configure
             * @param {string} groupName - The deferred group name for batch operations
             * @private
             */
            _configureModelForBatch: function (oModel, groupName) {
                oModel.setUseBatch(true);
                oModel.setDeferredGroups([groupName]);
            },

            /**
             * Build payload for link request
             * @param {Object} oRequestParentData - Parent request data
             * @param {sap.ui.table.Table} oTable - The table containing selected items
             * @param {Array} aSelectedIndices - Array of selected indices
             * @returns {Object} The payload object
             * @private
             */
            _buildLinkRequestPayload: function (oRequestParentData, oTable, aSelectedIndices) {
                const children = aSelectedIndices.map(index => {
                    const child = oTable.getContextByIndex(index).getObject();
                    return {
                        childRequestID: child.requestCode,
                        childInstanceID: child.requestID,
                        childWorkflowID: String(child.processFlowID)
                    };
                });

                return {
                    parentRequestID: oRequestParentData.code,
                    parentInstanceID: oRequestParentData.ID,
                    parentWorkflowID: String(oRequestParentData.processFlowId),
                    children: JSON.stringify(children),
                    associationType: null
                };
            },

            /**
             * Build payload for unlink request
             * @param {string} linkID - The link ID to unlink
             * @returns {Object} The payload object
             * @private
             */
            _buildUnlinkPayload: function (linkID) {
                return {
                    deleted: true,
                    deletedAt: new Date().toISOString(),
                    deletedBy: 'DummyUser' // This could be made configurable
                };
            },

            /**
             * Execute the link request operation
             * @param {sap.ui.model.Model} oModel - The model
             * @param {Object} oPayload - The request payload
             * @param {Object} that - Reference to the controller
             * @param {string} parentRequestId - Parent request ID for refresh operations
             * @param {string} groupName - The deferred group name for batch operations
             * @private
             */
            _executeLinkRequest: function (oModel, oPayload, that, parentRequestId, groupName) {
                oModel.callFunction("/linkRequestsDetailed", {
                    method: "POST",
                    urlParameters: oPayload,
                    success: function (oData) {
                        that._handleLinkRequestSuccess(oPayload, that, parentRequestId, oModel, groupName);
                    }.bind(this),
                    error: function (oError) {
                        that._handleLinkRequestError(oError, oModel, groupName);
                    }.bind(this)
                });
            },

            /**
             * Execute the unlink request operation
             * @param {sap.ui.model.Model} oModel - The model
             * @param {Object} oData - The update data
             * @param {Object} oRequest - The request object containing linkID and parentInstanceID
             * @param {Object} oBusyDialog - The busy dialog instance
             * @private
             */
            _executeUnlinkRequest: function (oModel, oData, oRequest, oBusyDialog) {
                const sPath = `/DtLinkedRequest(guid'${oRequest.linkID}')`;
                const that = this;

                oBusyDialog.open();

                oModel.update(sPath, oData, {
                    success: function () {
                        that._handleUnlinkRequestSuccess(oBusyDialog, oRequest);
                    },
                    error: function (oError) {
                        that._handleUnlinkRequestError(oBusyDialog, oError);
                    }
                });
            },

            /**
             * Handle successful link request
             * @param {Object} oPayload - The original payload
             * @param {Object} that - Reference to the controller
             * @param {string} parentRequestId - Parent request ID
             * @param {sap.ui.model.Model} oModel - The model
             * @param {string} groupName - The deferred group name for batch operations
             * @private
             */
            _handleLinkRequestSuccess: function (oPayload, that, parentRequestId, oModel, groupName) {
                const aChildren = JSON.parse(oPayload.children);
                const successMessages = aChildren.map(child => `Success: ${child.childRequestID}`);
                const requestMessages = successMessages.join("\n");

                sap.m.MessageBox.show(requestMessages, {
                    icon: sap.m.MessageBox.Icon.INFORMATION,
                    title: "Linked Results",
                    actions: [sap.m.MessageBox.Action.OK],
                    onClose: function () {
                        that._refreshTableAndData("createLinkedRequestTable");
                    }
                });

                // Submit batch and refresh data
                oModel.submitChanges(groupName);
                that._refreshLinkedRequestTable("linkedRequestTable");
                that._loadLinkedRequestCount(parentRequestId);
            },

            /**
             * Handle successful unlink request
             * @param {Object} oBusyDialog - The busy dialog instance
             * @param {Object} oRequest - The request object
             * @private
             */
            _handleUnlinkRequestSuccess: function (oBusyDialog, oRequest) {
                oBusyDialog.close();
                this._loadLinkedRequestCount(oRequest.parentInstanceID);
                this._refreshLinkedRequestTable("linkedRequestTable");
            },

            /**
             * Handle link request error
             * @param {Object} oError - The error object
             * @param {sap.ui.model.Model} oModel - The model
             * @param {string} groupName - The deferred group name for batch operations
             * @private
             */
            _handleLinkRequestError: function (oError, oModel, groupName) {
                console.error("Error creating linked requests: ", oError);
                oModel.resetChanges(groupName);

                sap.m.MessageBox.show("Failed to create linked requests. Please try again.", {
                    icon: sap.m.MessageBox.Icon.ERROR,
                    title: "Error",
                    actions: [sap.m.MessageBox.Action.OK]
                });
            },

            /**
             * Handle unlink request error
             * @param {Object} oBusyDialog - The busy dialog instance
             * @param {Object} oError - The error object
             * @private
             */
            _handleUnlinkRequestError: function (oBusyDialog, oError) {
                oBusyDialog.close();
                console.error("Error unlinking request: ", oError);

                sap.m.MessageBox.show("Failed to unlink request. Please try again.", {
                    icon: sap.m.MessageBox.Icon.ERROR,
                    title: "Error",
                    actions: [sap.m.MessageBox.Action.OK]
                });
            },

            /**
             * Refresh table and related data
             * @param {string} tableId - The ID of the table to refresh
             * @private
             */
            _refreshTableAndData: function (tableId) {
                const oTable = this.getView().byId(tableId);
                if (oTable) {
                    oTable.rebindTable();
                }
            },

            /**
             * Handle table rebind event for create linked request table
             * @param {sap.ui.base.Event} oEvent - The rebind event
             */
            onBeforeRebindCreateLinkedRequestTable: function (oEvent) {
                console.log("Executing onBeforeRebindCreateLinkedRequestTable");

                const oView = this.getView();
                const oContext = oView.getBindingContext();
                const oObject = oContext.getObject();

                // Apply filters
                this._applyParentInstanceFilter(oEvent, oObject.ID);
                this._applySiteFilter(oEvent, oObject.siteId);
            },

            /**
            * Apply parent instance filter to binding parameters
            * @param {sap.ui.base.Event} oEvent - The rebind event
            * @param {string} parentInstanceID - The parent instance ID
            * @private
            */
            _applyParentInstanceFilter: function (oEvent, parentInstanceID) {
                if (!parentInstanceID) {
                    return;
                }

                const oBindingParams = oEvent.getParameter("bindingParams");
                const oFilter = new sap.ui.model.Filter("parentInstanceID", sap.ui.model.FilterOperator.EQ, parentInstanceID);

                this._addFilterToBindingParams(oBindingParams, oFilter);
            },

            /**
             * Apply site filter to binding parameters
             * @param {sap.ui.base.Event} oEvent - The rebind event
             * @param {string} siteId - The site ID
             * @private
             */
            _applySiteFilter: function (oEvent, siteId) {
                const effectiveSiteId = siteId || this.DEFAULT_SITE_ID;
                console.log("REQUEST SITE ID IS:", effectiveSiteId);

                const oBindingParams = oEvent.getParameter("bindingParams");
                const oFilter = new sap.ui.model.Filter("siteID", sap.ui.model.FilterOperator.EQ, effectiveSiteId);

                this._addFilterToBindingParams(oBindingParams, oFilter);
            },

            /**
             * Add filter to binding parameters
             * @param {Object} oBindingParams - The binding parameters
             * @param {sap.ui.model.Filter} oFilter - The filter to add
             * @private
             */
            _addFilterToBindingParams: function (oBindingParams, oFilter) {
                if (oBindingParams.filters) {
                    oBindingParams.filters = new sap.ui.model.Filter({
                        filters: [].concat(oBindingParams.filters, oFilter),
                        and: true
                    });
                } else {
                    oBindingParams.filters = [oFilter];
                }
            },

            /**
            * Refresh linked request table
            * @returns {Promise} Promise that resolves when table is refreshed
            * @private
            */
            _refreshLinkedRequestTable: function (LINKED_TABLE_ID) {

                return new Promise((resolve, reject) => {
                    const oSmartTable = this.getView().byId(LINKED_TABLE_ID);

                    if (!oSmartTable) {
                        reject(new Error(`SmartTable '${LINKED_TABLE_ID}' not found`));
                        return;
                    }

                    const oTableBinding = oSmartTable.getTable().getBinding("items");

                    if (!oTableBinding) {
                        reject(new Error("No table binding found"));
                        return;
                    }

                    oSmartTable.rebindTable();
                    resolve();
                });
            },

            /**
             * Handles the before-rebind event for the linked request table
             * @param {sap.ui.base.Event} oEvent - The beforeRebindTable event
             * @description
             * Prepares filters for the linked request table rebinding by:
             * 1. Extracting the current request ID from the binding context
             * 2. Adding a filter for parentInstanceID matching the current request
             * Validates the binding context and request ID before applying filters.
             * @throws Will log an error if binding context or request ID is missing
             */
            onBeforeRebindLinkedRequestTable: function (oEvent) {
                const oView = this.getView();
                const oBindingContext = oView.getBindingContext();

                // Validate binding context
                if (!oBindingContext) {
                    console.error("Cannot rebind table: No binding context available");
                    return;
                }

                // Get request ID from context
                const oObject = oBindingContext.getObject();
                const requestID = oObject?.ID;
                const oBindingParams = oEvent.getParameter("bindingParams");

                // Add parent instance filter
                const oFilter = new Filter(
                    "parentInstanceID",
                    sap.ui.model.FilterOperator.EQ,
                    requestID
                );
                oBindingParams.filters.push(oFilter);
            },

            /**
             * Opens the linked request dialog if it exists
             * @private
             * @description
             * Safely opens the linked request dialog after verifying its existence.
             * This serves as a protective wrapper around the open() operation.
             */
            _openLinkedRequestDialog: function () {
                if (this.oLinkedRequest) {
                    this.oLinkedRequest.open();
                }
            },

            onShowChangeLog: function (oEvent) {
                const oView = this.getView();
                const oBindingContext = oView.getBindingContext();

                if (!this.changeLogDialog) {
                    this._initializeChangeLogDialog(oView, oBindingContext);
                } else {
                    this.changeLogDialog
                    this._refreshAndOpenChangeLog(oView, oBindingContext);
                }
            },

            _initializeChangeLogDialog: function (oView, oBindingContext) {
                this.loadFragment({
                    name: "prvintprojectsui5.fragments.changeLogDialog"
                }).then(function (oDialog) {
                    this.changeLogDialog = oDialog;
                    oView.addDependent(oDialog);

                    const oTable = oView.byId('changeLogTable');
                    oTable.setTableBindingPath(oBindingContext.getDeepPath() + '/ChangesLog');

                    this._openChangeLogDialog();
                    oTable.rebindTable();
                }.bind(this)).catch(function (oError) {
                    console.error("Error loading change log dialog:", oError);
                });
            },

            _refreshAndOpenChangeLog: function (oView, oBindingContext) {
                const oTable = oView.byId('changeLogTable');
                oTable.setTableBindingPath(oBindingContext.getDeepPath() + '/ChangesLog');
                oTable.rebindTable();
                this._openChangeLogDialog();
            },

            _openChangeLogDialog: function () {
                if (this.changeLogDialog) {
                    this.changeLogDialog.open();
                } else {
                    console.warn("Change log dialog not initialized");
                }
            },

            /**
              * Prepares filters and sorting for document list rebinding
              * @param {sap.ui.base.Event} oEvent - The rebind event
              * @description
              * Adds request ID filter and optional phase flow filter based on selected tab.
              * Configures grouping by documentId.
              */
            onBeforeRequestDocumentsRebind: function (oEvent) {
                const mBindingParams = oEvent.getParameter("bindingParams");
                const aFilters = mBindingParams.filters || [];
                const oView = this.getView();
                const oContext = oView.getBindingContext();

                if (!oContext) {
                    console.error("No binding context available for document filtering");
                    return;
                }

                // Add request ID filter
                aFilters.push(new Filter("requestId", sap.ui.model.FilterOperator.EQ, oContext.getProperty('ID')));

                // Add phase flow filter if not 'All'
                const oIconTabBar = oView.byId('requestProjectDocumentsFlowFilter');
                if (oIconTabBar && oIconTabBar.getSelectedKey() !== 'All') {
                    aFilters.push(new Filter("phaseFlowId", sap.ui.model.FilterOperator.EQ, oIconTabBar.getSelectedKey()));
                }

                // Configure grouping
                this.mGroupFunctions = {
                    documentId: function (oContext) {
                        return {
                            key: oContext.getProperty("documentId"),
                            text: oContext.getProperty("documentId")
                        };
                    }
                };

                mBindingParams.sorter = new Sorter(
                    'documentId',
                    false,
                    this.mGroupFunctions.documentId
                );
            },

            /**
             * Shows the document list dialog
             * @description
             * Loads the document list fragment if not already loaded,
             * otherwise refreshes and opens the existing dialog.
             */
            onShowDocumentList: function () {
                const oView = this.getView();

                if (this._documentListDialog) {
                    this._refreshDocumentList();
                    this._openDocumentListDialog();
                    return;
                }

                this._initializeDocumentListDialog(oView);
            },

            /**
             * Initializes the document list dialog
             * @private
             * @param {sap.ui.core.mvc.View} oView - The current view
             */
            _initializeDocumentListDialog: function (oView) {
                this.loadFragment({
                    name: "prvintprojectsui5.fragments.documentListDialog"
                }).then(function (oDialog) {
                    oView.addDependent(oDialog);
                    this._documentListDialog = oDialog;
                    this._openDocumentListDialog();
                }.bind(this)).catch(function (oError) {
                    console.error("Error loading document list dialog:", oError);
                });
            },

            /**
             * Refreshes the document list table
             * @private
             */
            _refreshDocumentList: function () {
                const oTable = this.getView().byId('requestDocumentList');
                if (oTable) {
                    oTable.rebindTable();
                }
            },

            /**
             * Opens the document list dialog
             * @private
             */
            _openDocumentListDialog: function () {
                if (this._documentListDialog) {
                    this._documentListDialog.open();
                }
            },

            /**
             * Shows the OT document viewer dialog
             * @description
             * Loads the OT document viewer fragment if not already loaded,
             * otherwise refreshes data and opens the existing dialog.
             */
            onShowOtDocumentList: function () {
                const oView = this.getView();

                if (this._OtDocumentsViewerDialog) {
                    this._getOTDocuments();
                    this._openOTDocumentsViewerDialog();
                    return;
                }

                this._initializeOTDocumentsViewerDialog(oView);
            },

            /**
             * Initializes the OT document viewer dialog
             * @private
             * @param {sap.ui.core.mvc.View} oView - The current view
             */
            _initializeOTDocumentsViewerDialog: function (oView) {
                this.loadFragment({
                    name: "prvintprojectsui5.fragments.OtDocumentsViewer"
                }).then(function (oDialog) {
                    oView.addDependent(oDialog);
                    this._OtDocumentsViewerDialog = oDialog;
                    this._getOTDocuments();
                    this._openOTDocumentsViewerDialog();
                }.bind(this)).catch(function (oError) {
                    console.error("Error loading OT document viewer:", oError);
                });
            },

            /**
             * Opens the OT document viewer dialog
             * @private
             */
            _openOTDocumentsViewerDialog: function () {
                if (this._OtDocumentsViewerDialog) {
                    this._OtDocumentsViewerDialog.open();
                }
            },

            /**
             * Retrieves OT documents data and structures it hierarchically
             * @private
             * @description
             * Fetches document viewer nodes from the model and organizes them
             * into a hierarchical structure for display in the tree.
             */
            _getOTDocuments: function () {
                const oView = this.getView();
                const oModel = oView.getModel();
                const oOTDocumentsModel = oView.getModel('OTDocumentViewer');
                const sRequestPath = oView.getBindingContext()?.getPath();

                if (!sRequestPath) {
                    console.error("No binding context available for OT documents");
                    return;
                }

                this.clearAllOTDocumentsFilters();

                oModel.read(sRequestPath + '/DocumentViewerNodes', {
                    success: function (oData) {
                        const aNodes = [];
                        let oFirstLevelNode = null;

                        oData.results.forEach(oResult => {
                            if (oResult.hierarchyLevel === 0) {
                                oFirstLevelNode = {
                                    nodeId: oResult.nodeId,
                                    description: oResult.description,
                                    createdBy: oResult.createdBy,
                                    createdAt: this.validationDateformatter(oResult.createdAt),
                                    children: []
                                };
                                aNodes.push(oFirstLevelNode);
                            } else if (oFirstLevelNode) {
                                oFirstLevelNode.children.push({
                                    nodeId: oResult.nodeId,
                                    description: oResult.description,
                                    createdBy: oResult.createdBy,
                                    createdAt: this.validationDateformatter(oResult.createdAt),
                                    documentId: oResult.documentId,
                                });
                            }
                        });

                        oOTDocumentsModel.setData(aNodes);
                        oOTDocumentsModel.refresh();
                    }.bind(this),
                    error: function (oError) {
                        console.error("Error fetching OT documents:", oError);
                    }
                });
            },

            /**
             * Handles document download from OT viewer
             * @param {sap.ui.base.Event} oEvent - The press event
             * @description
             * Downloads the selected document from OpenText system.
             * Prevents default event behavior and handles both sandbox and production URLs.
             */
            onOTViewerDocumentPress: function (oEvent) {
                oEvent.preventDefault();

                const oSource = oEvent.getSource();
                const oModel = this.getView().getModel('OTDocumentViewer');
                const oContext = oSource.getBindingContext('OTDocumentViewer');

                if (!oContext) {
                    console.error("No binding context available for document download");
                    return;
                }

                const sPath = oContext.getPath();
                const sDocumentId = oModel.getProperty(sPath + '/documentId');
                const sDocumentName = oModel.getProperty(sPath + '/description');

                // Determine service URL
                let sUrl = "/CmmOpentextSrv/callOT";
                if (window.location.pathname.split('/test/flp.html').length === 2 || window.location.pathname.split('/index.html').length === 2) {
                    sUrl = "/callOT";
                }

                // Resolve manifest URI if available
                try {
                    const sResolvedUri = this.getOwnerComponent().getManifestObject().resolveUri(sUrl.substring(1));
                    if (sResolvedUri) {
                        sUrl = sResolvedUri;
                    }
                } catch (oError) {
                    console.warn("Could not resolve manifest URI:", oError);
                }

                // Prepare request
                const oRequestBody = {
                    protocol: "GET",
                    uri: `/cellnex-ot-services/api/agora/document/downloadContent?documentId=${sDocumentId}`
                };

                $.ajax({
                    type: "POST",
                    contentType: "application/json",
                    url: sUrl,
                    data: JSON.stringify(oRequestBody),
                    xhrFields: {
                        responseType: 'blob',
                        withCredentials: true
                    },
                    success: function (oData, sTextStatus, jqXHR) {
                        const sObjectUrl = URL.createObjectURL(oData);
                        const oLink = document.createElement('a');
                        oLink.href = sObjectUrl;
                        oLink.setAttribute('download', sDocumentName);
                        document.body.appendChild(oLink);
                        oLink.click();
                        setTimeout(() => {
                            document.body.removeChild(oLink);
                            URL.revokeObjectURL(sObjectUrl);
                        }, 100);
                    },
                    error: function (jqXHR, sTextStatus, sErrorThrown) {
                        console.error("Document download failed:", sErrorThrown);
                        // Consider showing a message to the user
                    }
                });
            },

            /**
             * Filters OT documents based on search query
             * @param {sap.ui.base.Event} oEvent - The search event
             * @description
             * Applies global filter to OT documents tree based on search query.
             * Filters on nodeId, description, createdAt, and createdBy fields.
             */
            filterOTDocuments: function (oEvent) {
                const sQuery = oEvent.getParameter("query");
                const oTree = this.byId("OtDocumentsViewerTree");

                if (!oTree) {
                    console.error("OT documents tree not found");
                    return;
                }

                this._oGlobalFilter = sQuery
                    ? new Filter([
                        new Filter("nodeId", 'Contains', sQuery),
                        new Filter("description", 'Contains', sQuery),
                        new Filter("createdAt", 'Contains', sQuery),
                        new Filter("createdBy", 'Contains', sQuery)
                    ], false)
                    : null;

                oTree.getBinding().filter(this._oGlobalFilter, "Application");
            },

            /**
             * Clears all filters from OT documents tree
             * @param {sap.ui.base.Event} [oEvent] - Optional event
             * @description
             * Resets both global filter and column filters on the OT documents tree.
             */
            clearAllOTDocumentsFilters: function (oEvent) {
                const oTable = this.byId("OtDocumentsViewerTree");
                if (!oTable) {
                    console.error("OT documents tree not found");
                    return;
                }

                this._oGlobalFilter = null;

                const aColumns = oTable.getColumns();
                aColumns.forEach(oColumn => {
                    oTable.filter(oColumn, null);
                });
            },

            onRequestDocumentsPhaseSelect: function (oEvent) {
                V.rebind(V.byId(this.getView(), 'requestDocumentList'))
            },

            /**
             * Handles navigation to the Document Consolidation application
             * @param {sap.ui.base.Event} oEvent - The event that triggered the navigation
             * @description
             * Prepares and executes navigation to the Document Consolidation app with required parameters:
             * - Request ID
             * - Request Code
             * - Site ID
             * Validates binding context and required parameters before navigation.
             * @throws Will log an error if binding context or required parameters are missing
             */
            onConsolidationNav: function (oEvent) {
                const oView = this.getView();
                const oBindingContext = oView.getBindingContext();

                // Validate binding context
                if (!oBindingContext) {
                    console.error("Navigation failed: No binding context available");
                    return;
                }

                // Extract required properties with null checks
                const sRequestId = oBindingContext.getProperty('ID');
                const sRequestCode = oBindingContext.getProperty('code');
                const sSiteId = oBindingContext.getProperty('siteId');

                // Prepare navigation target
                const oTarget = {
                    semanticObject: "DocumentConsolidation",
                    action: "Display"
                };

                // Prepare navigation parameters
                const oParams = {
                    externalPortal: "true",
                    requestId: sRequestId,
                    requestCode: sRequestCode,
                    siteId: sSiteId,
                    navFrom: "Internal projects"
                };

                // Execute navigation
                this._navToApp(oTarget, oParams);
            },

            _onAssignResponsibles: function () {
                if (typeof Messaging !== "undefined" && Messaging) Messaging.removeAllMessages();

                const oView = this.getView();
                const openDialog = () => {
                    V.openDialog(this.assignResponsiblesDialog);
                    V.rebind(V.byId(oView, "assignResponsiblesTable"));
                };

                if (!this.assignResponsiblesDialog) {
                    this.loadFragment({ name: "prvintprojectsui5.fragments.assignResponsiblesDialog" })
                        .then(function (oDialog) {
                            this.assignResponsiblesDialog = oDialog;
                            openDialog();
                        }.bind(this));
                } else {
                    openDialog();
                }
            },

            onAssignResponsibles: function () {
                if (typeof Messaging !== "undefined" && Messaging) Messaging.removeAllMessages();
                const oView = this.getView();
                Dialogs.openOrLoad(
                    this,
                    "prvintprojectsui5.fragments.assignResponsiblesDialog",
                    "assignResponsiblesDialog",
                    () => {
                        V.rebind(V.byId(oView, "assignResponsiblesTable"));
                    },
                    true // use controller.loadFragment
                );
            },


            onResponsiblePhaseSelect: function () {
                V.rebind(V.byId(this.getView(), "assignResponsiblesTable"));
            },

            onResponsibleFieldChange: async function (oEvent) {
                const oView = this.getView();
                const oModel = oView.getModel();
                const oTable = V.byId(oView, "assignResponsiblesTable");
                // const oEventBus = this.getOwnerComponent().getEventBus();
                const oEventBus = Core.getEventBus();

                const params = oEvent.getParameters();
                const changeEvent = params && params.changeEvent;
                const src = changeEvent && changeEvent.getSource();
                const isSubcoTypeChange = src && src.getAriaLabelledBy && (src.getAriaLabelledBy()[0] || "").includes("subcoType");
                const oCtx = src && src.getBindingContext && src.getBindingContext();
                const oResponsibleChange = oCtx && oCtx.getObject();

                try {
                    const res = await Batch.submitPendingChanges(oModel);
                    if (!res.submitted) return;

                    if (!res.ok) {
                        V.rebind(oTable);
                        return;
                    }

                    if (isSubcoTypeChange) {
                        const row = V.coreById(src.getId()).getParent().getParent();
                        const externalField = V.findCellByAriaLabelKey(row, "externalResponsible");
                        if (externalField) V.refreshValueListItems(externalField);
                    }

                    oEventBus.publish("AGORA_REQUEST", "RESPONSIBLE_CHANGE", oResponsibleChange);
                } catch (e) {
                    V.rebind(oTable);
                }
            },

            onResponsiblesTableInitialise: function (oEvent) {
                let oSmartTable = oEvent.getSource()
                let oInnerTable = oSmartTable.getTable()
                let aColumns = oInnerTable.getColumns()
                aColumns[4].getAggregation('template').getAggregation('edit').setTextInEditModeSource('ValueListNoValidation')
                aColumns[5].getAggregation('template').getAggregation('edit').setTextInEditModeSource('ValueListNoValidation')
            },

            onBeforerResponsiblesRebind: function (oEvent) {
                const mBindingParams = oEvent.getParameter("bindingParams");
                const oView = this.getView();

                Binding.addFilter(mBindingParams, Binding.eq("requestId", oView.getBindingContext().getProperty("ID")));

                const oIconTabBar = oView.byId("requestFlowFilter");
                const key = oIconTabBar.getSelectedKey();
                if (key !== "All") {
                    Binding.addFilter(mBindingParams, Binding.eq("phaseProcessFlowId", key));
                }
            },

            onCloseAssignRequestDialog: function () {
                Dialogs.close(this, "assignResponsiblesDialog");
            },

            onDocumentsPerRequestFieldChange: async function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                const oView = this.getView();
                const oModel = oView.getModel();
                const oTable = V.byId(oView, "requestDocumentList");
                // const oEventBus = this.getOwnerComponent().getEventBus();
                const oEventBus = Core.getEventBus();
                const oDocumentPath = oEvent.getSource().getBindingContext().getPath()
                const oDocumentData = oModel.getData(oDocumentPath)
                try {
                    const res = await Batch.submitPendingChanges(oModel);
                    if (!res.submitted) return;

                    if (!res.ok) {
                        V.rebind(oTable);
                        return;
                    }
                    oEventBus.publish('AGORA_REQUEST', 'REFRESH_DOCUMENT_PER_BLOCK', { blockId: oDocumentData.blockId })
                } catch (e) {
                    V.rebind(oTable);
                }
            },

            onShowAddDocumentPerRequestDialog: function (oEvent) {
                let oView = this.getView()
                let oModel = oView.getModel('configuration')
                oModel.setProperty('/addDocument/phaseId', undefined)
                oModel.setProperty('/addDocument/blockId', undefined)
                oModel.setProperty('/addDocument/documentId', undefined)
                oModel.setProperty('/addDocument/hasBlocks', false)

                Dialogs.openOrLoad(this, "prvintprojectsui5.fragments.addDocumentPerRequestDialog", "_addDocumentPerRequestDialog", null, true);

            },

            onCloseAddDocumentPerRequest: function (oEvent) {
                Dialogs.close(this, "_addDocumentPerRequestDialog");
            },

            onCloseDialog: function (oEvent) {
                const oButton = oEvent.getSource();
                const sDialogId = oButton.data("dialogName"); // same as getCustomData
                if (!sDialogId) return;
                Dialogs.close(this, sDialogId);
            },

            onDestroyDialog: function (oEvent) {
                const oButton = oEvent.getSource();
                const sDialogId = oButton.data("dialogName"); // same as getCustomData
                if (!sDialogId) return;
                Dialogs.destroy(this, sDialogId);
            },

            onBeforeOpenAddDocumentPerRequest: function () {
                let oView = this.getView()
                let oConfigModel = oView.getModel('configuration')
                let sSelectedPhase = oView.byId('requestProjectDocumentsFlowFilter').getSelectedKey()
                if (sSelectedPhase === 'All') {
                    oConfigModel.setProperty('/addDocument/phaseId', undefined)
                } else {
                    oConfigModel.setProperty('/addDocument/phaseId', sSelectedPhase)
                }
                let sProcessId = oView.getBindingContext().getProperty('processFlowId')
                let sBlockId = oConfigModel.getProperty('/addDocument/blockId') !== '' ? oConfigModel.getProperty('/addDocument/blockId') : 'none'
                this._getPhasesPerSelectedProcess(sProcessId, sSelectedPhase)
                this._getBlocksPerSelectedPhase(sProcessId, sSelectedPhase)
                this._getDocumentsPerSelectedBlock(sProcessId, sSelectedPhase, sBlockId)
            },

            /**
            @description helper to apply EQ filters to a Select by id
            */
            _applyFiltersToSelect: function (sSelectId, aFilterSpecs) {
                let oView = this.getView()
                let oSelect = oView.byId(sSelectId)
                if (!oSelect) { return }
                let oBinding = oSelect.getBinding("items")
                if (!oBinding) { return }
                let aFilters = []
                aFilterSpecs.forEach(function (oSpec) {
                    if (oSpec && oSpec.value !== undefined && oSpec.value !== null && oSpec.value !== '') {
                        aFilters.push(new sap.ui.model.Filter(oSpec.path, 'EQ', oSpec.value))
                    }
                })
                oBinding.filter(aFilters, sap.ui.model.FilterType.Application)
            },

            /**
           @description get all phases per request dropdown Values from server
           */
            _getPhasesPerSelectedProcess: function (sProcessId, sSelectedPhase) {
                let oView = this.getView()
                let oSelect = oView.byId('phasePerProcess')
                if (sSelectedPhase === 'All') {
                    oSelect.setVisible(true)
                } else {
                    oSelect.setVisible(false)
                }
                this._applyFiltersToSelect('phasePerProcess', [
                    { path: 'processFlowId', value: sProcessId }
                ])

            },

            /**
            @description get all blocks per selected phase and request process
            */
            onPhasePerProcessChange: function (oEvent) {
                let oView = this.getView()
                let oConfigModel = oView.getModel('configuration')
                oConfigModel.setProperty('/addDocument/blockId', undefined)
                oConfigModel.setProperty('/addDocument/documentId', undefined)
                oConfigModel.setProperty('/addDocument/hasBlocks', false)

                let sProcessId = oView.getBindingContext().getProperty('processFlowId')
                let sPhaseProcessId = oEvent.getParameters().selectedItem.getBindingContext().getProperty('phaseProcessFlowId')
                this._getBlocksPerSelectedPhase(sProcessId, sPhaseProcessId)
                this._getDocumentsPerSelectedBlock(sProcessId, sPhaseProcessId, 'none')
            },

            /**
            @description get all blocks per selected phase and request process from server
            */
            _getBlocksPerSelectedPhase: function (sProcessId, sPhaseProcessId) {
                this._applyFiltersToSelect('blockPerProcess', [
                    { path: 'processFlowId', value: sProcessId },
                    { path: 'phaseProcessFlowId', value: sPhaseProcessId }
                ])
            },

            /**
            @description get all documents per blocks selected phase and request process
            */
            onBlockPerProcessChange: function (oEvent) {
                let oView = this.getView()
                let oConfigModel = oView.getModel('configuration')
                oConfigModel.setProperty('/addDocument/documentId', undefined)

                let sProcessId = oView.getBindingContext().getProperty('processFlowId')
                let sPhaseProcessId = oConfigModel.getProperty('/addDocument/phaseId')
                let sBlockProcessId = oEvent.getParameters().selectedItem.getBindingContext().getProperty('blockProcessFlowId')
                this._getDocumentsPerSelectedBlock(sProcessId, sPhaseProcessId, sBlockProcessId)

            },

            /**
            @description get all documents per blocks selected phase and request process from server
            */
            _getDocumentsPerSelectedBlock: function (sProcessId, sPhaseProcessId, sBlockProcessId) {
                this._applyFiltersToSelect('documentIdPerProcess', [
                    { path: 'processFlowId', value: sProcessId },
                    { path: 'phaseProcessFlowId', value: sPhaseProcessId },
                    { path: 'blockProcessFlowId', value: sBlockProcessId }
                ])
            },

            /**
             * @description call server to add new document flow
             */
            onAddDocFlowPerRequest: function (oEvent) {
                Messaging.removeAllMessages()
                let oView = this.getView()
                let oModel = oView.getModel()
                let oConfigModel = oView.getModel("configuration")
                let oList = oView.byId("requestDocumentList")
                let oEventBus = Core.getEventBus()
                let sBlockProcessId = oConfigModel.getProperty("/addDocument/blockId")
                let sPhaseId = oConfigModel.getProperty("/addDocument/phaseId")
                let blockId
                //NOSONAR let oPhaseCtx = oView.byId(String(sPhaseId))?.getBindingContext()
                let oPhaseCtx = Core.byId(String(sPhaseId))?.getBindingContext()
                if (oPhaseCtx) {
                    let aBlocks = oPhaseCtx.getProperty("Blocks") || []
                    let oMatch = aBlocks.find(b => {
                        let oBlock = oModel.getObject("/" + b);
                        return oBlock?.processFlowId === sBlockProcessId
                    })
                    blockId = oMatch ? oModel.getObject("/" + oMatch).ID : undefined
                }
                oModel.callFunction("/newRequestDocument", {
                    method: "POST",
                    refreshAfterChange: true,
                    urlParameters: {
                        requestId: oView.getBindingContext().getProperty("ID"),
                        phaseId: sPhaseId,
                        blockId: sBlockProcessId,
                        documentId: oConfigModel.getProperty("/addDocument/documentId")
                    },
                    success: function () {
                        oList.rebindTable()
                        if (blockId) oEventBus.publish("AGORA_REQUEST", "REFRESH_DOCUMENT_PER_BLOCK", { blockId })
                    }.bind(this),
                    error: function (oError) {
                    }.bind(this)
                })
                this.onCloseDialog(oEvent)
            },

            onCallActionCancelDocumentsPerBlocks: function (oEvent) {
                let oView = this.getView()
                let oModel = oView.getModel()
                let sId = oEvent.getSource().getBindingContext().getProperty('ID')
                let sBlockId = oEvent.getSource().getBindingContext().getProperty('blockId')
                if (!this._oCancelDocument) {
                    this.loadFragment({
                        name: "prvintprojectsui5.fragments.onCancelDocument"
                    }).then(function (oDialog) {
                        this._oCancelDocument = oDialog
                        this._oCancelDocument.setBindingContext(this._setDPBCancelDialogContext(oModel, sId, sBlockId))
                        this._oCancelDocument.open()
                    }.bind(this))
                } else {
                    this._oCancelDocument.setBindingContext(this._setDPBCancelDialogContext(oModel, sId, sBlockId))
                    this._oCancelDocument.open()
                }
            },

            _setDPBCancelDialogContext: function (oModel, sId, sBlockId) {
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
                    const oForm = this.getView().byId("onCancelDocumentForm");

                    // set the backend context on the form
                    oForm.setBindingContext(oContext);

                    // enrich the context with your custom BlockId
                    const sPath = oContext.getPath();
                    oModel.setProperty(sPath + "/BlockId", sBlockId);

                    return oContext;
                }.bind(this))
            },

            _onCancelInstancesPerDocumentAction: function (oModel, sId, sBlockId, sDpbId) {
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
                        'cancellationReason': '',
                        'dpbRegisterId': sDpbId
                    }
                }).contextCreated().then(function (oContext) {
                    const oForm = this.getView().byId("onCancelDocumentForm");

                    // set the backend context on the form
                    oForm.setBindingContext(oContext);

                    // enrich the context with your custom BlockId
                    const sPath = oContext.getPath();
                    oModel.setProperty(sPath + "/BlockId", sBlockId);

                    return oContext;
                }.bind(this))
            },

            /*
           * @description Submit changes to set "On hold" status
           * @param {oEvent} Object with event data
           */
            confirmOnCancelDocument: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                // const oEventBus = this.getOwnerComponent().getEventBus();
                const oEventBus = Core.getEventBus();
                const blockId = this.getView().byId('onCancelDocumentForm').getBindingContext().getProperty().BlockId;
                let oTable = this.getView().byId('requestDocumentList')
                this.getView().getModel().submitChanges({
                    groupId: 'changes',
                    success: function (oEvent) {
                        oTable.rebindTable()
                        oEventBus.publish("AGORA_REQUEST", "REFRESH_DOCUMENT_PER_BLOCK", { blockId });
                        this._oCancelDocument.close()
                        if (this._validatorsDetailsDialog) this._validatorsDetailsDialog.close()
                    }.bind(this),
                    error: function () {
                        oView.getModel().resetChanges(null, true, true)
                        this._oCancelDocument.close()
                    }.bind(this)
                })
            },

            onCallActionStartDocumentFlow: function (oEvent) {
                let oView = this.getView()
                // const oEventBus = this.getOwnerComponent().getEventBus();
                let oEventBus = Core.getEventBus()
                let sBlockId = oEvent.getSource().getBindingContext().getProperty('blockId')
                let oTable = oView.byId('requestDocumentList')
                let oModel = oView.getModel()
                let sId = oEvent.getSource().getBindingContext().getProperty('ID');
                this.showBusy()
                oModel.callFunction("/DocumentsPerBlocks_docFlowFirstSave", {
                    method: "POST",
                    success: function (oError) {
                        oTable.rebindTable()
                        oEventBus.publish("AGORA_REQUEST", "REFRESH_DOCUMENT_PER_BLOCK", { blockId: sBlockId });
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

            onCallActionNextStep: function (oEvent) {
                let oView = this.getView()
                let oTable = oView.byId('requestDocumentList')
                let oModel = oView.getModel()
                let sId = this._validatorsDetailsDialog.getBindingContext().getProperty('instanceId')
                this.showBusy()
                oModel.callFunction("/DocumentsPerBlocks_nextStep", {
                    method: "POST",
                    success: function (oResponse, oCallHandler) {
                        this.hideBusy()
                        this._validatorsDetailsDialog.getElementBinding().refresh()
                        if (oResponse.status === oView.getModel('configuration').getProperty('/constants/STATUS_COMPLETED')) {
                            oTable.rebindTable()
                            this._validatorsDetailsDialog.close()
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

            onCallActionCancelInstancesPerDocuments: function (oEvent) {
                let oView = this.getView()
                let oModel = oView.getModel()
                let sId = this._validatorsDetailsDialog.getBindingContext().getProperty('ID')
                let sDpbId = this._validatorsDetailsDialog.getBindingContext().getProperty('instanceId')
                let sBlockId = this._validatorsDetailsDialog.getBindingContext().getProperty('blockId')
                if (!this._oCancelDocument) {
                    this.loadFragment({
                        name: "prvintprojectsui5.fragments.onCancelDocument"
                    }).then(function (oDialog) {
                        this._oCancelDocument = oDialog
                        this._oCancelDocument.setBindingContext(this._onCancelInstancesPerDocumentAction(oModel, sId, sBlockId, sDpbId))
                        this._oCancelDocument.open()
                    }.bind(this))
                } else {
                    this._oCancelDocument.setBindingContext(this._onCancelInstancesPerDocumentAction(oModel, sId, sBlockId, sDpbId))
                    this._oCancelDocument.open()
                }
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
                if (!this._validatorsDetailsDialog) {
                    this.loadFragment({
                        name: "prvintprojectsui5.fragments.validatorsDocumentFlowDialog"
                    }).then(function (oDialog) {
                        this._validatorsDetailsDialog = oDialog
                        this._validatorsDetailsDialog.bindElement({
                            path: oContext,
                            events: {
                                'change': (oEvent) => {
                                    this._bindUploader("docPerRequestdocFlowResponsibleUpload", oConstants.VALIDATOR_RESPONSIBLE, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                    if (oInstancesPerDocuments.siteOwnerValidationVF) {
                                        this._bindUploader("docPerRequestdocFlowSiteOwnerUpload", oConstants.VALIDATOR_SITE_OWNER, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                    }
                                    if (oInstancesPerDocuments.subcontractorValidationVF) {
                                        this._bindUploader("docPerRequestdocFlowSubcontractorUpload", oConstants.VALIDATOR_SUBCO, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                    }
                                    if (oInstancesPerDocuments.customerValidationVF) {
                                        this._bindUploader("docPerRequestdocFlowCustomerUpload", oConstants.VALIDATOR_CUSTOMER, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                    }
                                    if (oInstancesPerDocuments.cellnexValidationVF) {
                                        this._bindUploader("docFlowCeldocPerRequestdocFlowCellnexUploadlnexUpload", oConstants.VALIDATOR_CELLNEX, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                    }
                                }
                            }
                        })
                        this._validatorsDetailsDialog.open()
                        this._onAttachChangeEventsInstancesPerDocument();
                    }.bind(this))
                } else {
                    this._validatorsDetailsDialog.bindElement({
                        path: oContext,
                        events: {
                            'change': (oEvent) => {
                                this._bindUploader("docPerRequestdocFlowResponsibleUpload", oConstants.VALIDATOR_RESPONSIBLE, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                if (oInstancesPerDocuments.siteOwnerValidationVF) {
                                    this._bindUploader("docPerRequestdocFlowSiteOwnerUpload", oConstants.VALIDATOR_SITE_OWNER, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                }
                                if (oInstancesPerDocuments.subcontractorValidationVF) {
                                    this._bindUploader("docPerRequestdocFlowSubcontractorUpload", oConstants.VALIDATOR_SUBCO, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                }
                                if (oInstancesPerDocuments.customerValidationVF) {
                                    this._bindUploader("docPerRequestdocFlowCustomerUpload", oConstants.VALIDATOR_CUSTOMER, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                }
                                if (oInstancesPerDocuments.cellnexValidationVF) {
                                    this._bindUploader("docPerRequestdocFlowCellnexUpload", oConstants.VALIDATOR_CELLNEX, oInstancesPerDocuments.stepId, this._validatorsDetailsDialog.getBindingContext(), bCanDelete)
                                }
                            }
                        }
                    })
                    this._validatorsDetailsDialog.open()
                    this._onAttachChangeEventsInstancesPerDocument();
                }
            },

            _onAttachChangeEventsInstancesPerDocument: function (oEvent) {
                this.getView().byId("IPD_expirationDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_customerInformDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_submissionDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_expectedSubmissionDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_limitSubmissionDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_customerInformDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_endDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_cellnexValidationDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_customerValidationDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_siteOwnerValidationDate1").attachChange(this.onFieldChange, this)
                this.getView().byId("IPD_subcontractorValidationDate1").attachChange(this.onFieldChange, this)
            },

            //NOSONAR onFieldChange: function () {
            //NOSONAR     if (Messaging) Messaging.removeAllMessages()
            //NOSONAR     let oModel = this.getView().getModel()
            //NOSONAR     if (oModel.hasPendingChanges()) oModel.submitChanges({
            //NOSONAR         success: function (oData) {
            //NOSONAR             let bHasError = false
            //NOSONAR             if (oData.__batchResponses && oData.__batchResponses.constructor === Array) {
            //                 for (let oBatchResponse of oData.__batchResponses) {
            //                     if (oBatchResponse.__changeResponses && oBatchResponse.__changeResponses.constructor === Array) {
            //                         for (let oChangeResponse of oBatchResponse.__changeResponses) {
            //                             if (oChangeResponse.statusCode && oChangeResponse.statusCode >= 400) {
            //                                 bHasError = true
            //                             }
            //                             if (oChangeResponse.response && oChangeResponse.response.statusCode && oChangeResponse.response.statusCode >= 400) {
            //                                 bHasError = true
            //                             }
            //                         }
            //                     } else if (oBatchResponse.response) {
            //                         if (oBatchResponse.response.statusCode && oBatchResponse.response.statusCode >= 400) {
            //                             bHasError = true
            //                         }
            //                         if (oBatchResponse.response && oBatchResponse.response.statusCode && oBatchResponse.response.statusCode >= 400) {
            //                             bHasError = true
            //                         }
            //                     }
            //                 }
            //NOSONAR             }
            //NOSONAR             if (bHasError) {
            //NOSONAR                 oModel.resetChanges(null, true, true)
            //NOSONAR                 this._bindSmartTable()
            //NOSONAR             }
            //NOSONAR         }.bind(this)
            //NOSONAR     })
            //NOSONAR },

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

            onAfterItemAddedValidators: function (oEvent) {
                this.uploadedItem = oEvent.getParameter("item")
                this._createEntityUploadValidators(this.uploadedItem)
            },

            /*
            * @description Create metadata file structure to create entity
            * @param {item} Contains metadata
            * @return {Promise} If 'ok', calls to function to upload file
            */
            _createEntityUploadValidators: function (item) {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                let oRequestContext
                let oInstancesPerDocumentPath = this._validatorsDetailsDialog.getBindingContext().getPath()
                let oDocumentsperBlockObject = oModel.getProperty(this._validatorsDetailsDialog.getBindingContext().getDeepPath().split("/InstancesPerDocuments")[0])
                let sStepId = this._validatorsDetailsDialog.getBindingContext().getObject().stepId
                if (oContext.getPath().includes('Requests')) {
                    oRequestContext = oContext
                } else {
                    oRequestContext = oView.getParent().getParent().getBindingContext()
                }

                let data = {
                    requestId: oRequestContext.getProperty('ID'),
                    blockId: oDocumentsperBlockObject.blockId,
                    requestCode: oRequestContext.getProperty('code'),
                    documentName: item.getFileName(),
                    documentId: oDocumentsperBlockObject.documentId,
                    finalDocument: false,
                    mediaType: item.getMediaType(),
                    stepId: sStepId
                }

                oModel.create(oInstancesPerDocumentPath + '/LocalDocuments',
                    data,
                    {
                        'success': function (oData) {
                            this._uploadContent(this.uploadedItem, oData.ID)
                        }.bind(this)
                    })
            },

            onClickCommentsOnHold: function (oEvent) {
                var i18n = this.getView().getModel("i18n").getResourceBundle()
                var sComments = this.getView().getBindingContext().getProperty("onHoldComments")
                MessageBox.information(sComments, { title: i18n.getText("comments") })
            },

            onClickCommentsCancel: function (oEvent) {
                var i18n = this.getView().getModel("i18n").getResourceBundle()
                var sComments = this.getView().getBindingContext().getProperty("cancellationComments")
                MessageBox.information(sComments, { title: i18n.getText("comments") })
            },

            onCloseRequest: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                //NOSONAR let oConfigModel = this.getView().getModel('configuration')
                oModel.callFunction('/Requests_close', {
                    method: "POST",
                    urlParameters: { 'ID': oContext.getProperty('ID') },
                    'success': function (oData) {
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
                        if (!bHasError) {
                            this._navBack()
                            // oConfigModel.setProperty('/editMode', false)
                            // oView.getObjectBinding().refresh(true)
                        }
                    }.bind(this),
                    'error': function (oError) {
                        oModel.resetChanges(null, true, true)
                    }.bind(this)
                })
            },

            /*
            * @description Upload file selected by user
            * @param {item, id} Item contains the file to attach, ID ??
            */
            _uploadContent: function (item, id) {
                let sUrl = `/odata/v2/service/project/LocalDocuments(${id})/content`
                if (this.getOwnerComponent().getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))) {
                    sUrl = this.getOwnerComponent().getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))
                }
                item.setUploadUrl(sUrl);
                let oUploadSet = item.getParent()
                oUploadSet.setHttpRequestMethod(sap.m.upload.UploaderHttpRequestMethod.Put)
                oUploadSet.uploadItem(item)
            },

            _setOnHoldInmediate: function (that) {
                let oView = this.getView()
                let oModel = oView.getModel()
                oModel.callFunction("/Requests_setOnHold", {
                    method: "POST",
                    refreshAfterChange: true,
                    success: this._onHoldRequestSuccess.bind(this),
                    error: this._onHoldRequestError.bind(this),
                    urlParameters: {
                        'ID': oView.getBindingContext().getProperty('ID'),
                        'onHoldComments': '',
                        'onHoldReason': ''
                    }
                })
            },

            _callOnHoldAction: function (that) {
                let oView = this.getView()
                let oModel = oView.getModel()
                oModel.callFunction("/Requests_setOnHold", {
                    method: "POST",
                    refreshAfterChange: true,
                    groupId: "changes",
                    error: function () {
                        oModel.resetChanges(null, true, true);
                    }.bind(this),
                    urlParameters: {
                        'ID': oView.getBindingContext().getProperty('ID'),
                        'onHoldComments': '',
                        'onHoldReason': ''
                    }
                }).contextCreated().then(function (oContext) {
                    this.onHoldRequestDialog.setBindingContext(oContext)
                }.bind(this))
                this.onHoldRequestDialog.open()
            },

            _onHoldRequestSuccess: function () {
                let oView = this.getView()
                let oConfigModel = oView.getModel('configuration')
                oConfigModel.setProperty('/refreshAll', false)
                oView.getObjectBinding().refresh(true)
            },

            /*
            * @description Set "On hold" status error
            */
            _onHoldRequestError: function () {
                this.getView().getModel().resetChanges(null, true, true)
            },

            loadMessagePopover: function () {
                const oLink = new sap.m.Link({
                    text: "{messageWarnings>link/text}",
                    href: "{messageWarnings>link/url}",
                    target: "_blank",
                    press: this.handleMessagePopoverLinkPress.bind(this),
                    customData: [
                        "AlertOwner", "ItemId", "ItemViewed"
                    ].map(key => new sap.ui.core.CustomData({
                        key,
                        value: `{messageWarnings>${key}}`
                    }))
                });

                const oMessageTemplate = new sap.m.MessageItem({
                    type: "{messageWarnings>type}",
                    title: "{messageWarnings>title}",
                    activeTitle: "{messageWarnings>active}",
                    description: "{messageWarnings>description}",
                    subtitle: "{messageWarnings>subtitle}",
                    groupName: "{messageWarnings>groupName}",
                    counter: "{messageWarnings>counter}",
                    markupDescription: true,
                    link: oLink
                });

                oMessageWaringPopover = new sap.m.MessagePopover({
                    id: "messageWarnings",
                    items: {
                        path: "messageWarnings>/",
                        template: oMessageTemplate
                    },
                    growing: true,
                    growingThreshold: 50,
                    groupItems: true
                });

                this.byId("messagePopoverWaringBtn").addDependent(oMessageWaringPopover);
            },

            initializeMessageWarningsModel: function () {
                const model = new sap.ui.model.json.JSONModel([]);
                model.setSizeLimit(messageWarningsModelSizeLimit);
                this.getView().setModel(model, "messageWarnings");
            },

            onMessageWaringsPopoverPress: function (oEvent) {
                if (!oMessageWaringPopover) this.loadMessagePopover();
                oMessageWaringPopover.toggle(oEvent.getSource());
            },

            getWarningRestrictions: function () {
                const oView = this.getView();
                const oWarningsModel = oView.getModel("messageWarnings");
                const oModelRestrictions = oView.getModel("ODATA_RESTRICTION");
                const siteId = oView.getBindingContext().getProperty("siteId");
                const i18n = oView.getModel("i18n").getResourceBundle();

                // Remove old restriction warnings
                oWarningsModel.setData(oWarningsModel.getData().filter(obj => obj.group !== "Restrictions"));

                oModelRestrictions.read("/RestrictionSet", {
                    filters: [new sap.ui.model.Filter("Objectid", sap.ui.model.FilterOperator.EQ, siteId)],
                    success: oData => {
                        const today = new Date();
                        today.setHours(0, 0, 0, 0);

                        const activeRestrictions = oData.results.filter(obj => {
                            const start = new Date(obj.Startdate).setHours(0, 0, 0, 0);
                            const end = new Date(obj.Enddate).setHours(0, 0, 0, 0);
                            return today >= start && today <= end;
                        });

                        const newWarnings = activeRestrictions.map(entry => ({
                            groupName: i18n.getText("Restrictions"),
                            group: "Restrictions",
                            type: "Warning",
                            title: `${i18n.getText("LblTitleWarningRestriction")} ${siteId}`,
                            subtitle: `${entry.Restrictiontypedescription} - ${entry.Familytxt} - ${entry.Enddate}`,
                            description: `
                                <ul>
                                    <li><b>${i18n.getText("RestrictionType")}:</b> ${entry.Restrictiontypedescription}</li>
                                    <li><b>${i18n.getText("Description")}:</b> ${entry.Description}</li>
                                    <li><b>${i18n.getText("Family")}:</b> ${entry.Familytxt}</li>
                                    <li><b>${i18n.getText("StartDate")}:</b> ${entry.Startdate}</li>
                                    <li><b>${i18n.getText("EndDate")}:</b> ${entry.Enddate}</li>
                                    <li><b>${i18n.getText("createDate")}:</b> ${entry.Creationdate || ""}</li>
                                    <li><b>${i18n.getText("createdBy")}:</b> ${entry.CreatorId}</li>
                                </ul>
                            `
                        }));

                        oWarningsModel.getData().push(...newWarnings);
                        oWarningsModel.getData().sort((a, b) => a.groupName.localeCompare(b.groupName, undefined, { sensitivity: "base" }));
                        oWarningsModel.refresh(true);
                    },
                    error: console.error
                });
            },

            handleMessagePopoverLinkPress: function (oEvent) {
                console.log("handleMessagePopoverLinkPress")
            },
            onClosePhase: function () {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oModel = oView.getModel()
                let oConfigModel = oView.getModel('configuration')
                let fnSucess = this.onPhaseClosedSuccess.bind(this)
                let fnError = this.onPhaseCloseError.bind(this)
                this.showBusy()
                oModel.callFunction('/Phases_close', { method: "POST", urlParameters: { 'ID': oConfigModel.getProperty('/selectedPhaseId') }, 'success': fnSucess, 'error': fnError, refreshAfterChange: true })
            },

            onPhaseClosedSuccess: function (oData) {
                this.hideBusy()
                this.getView().getObjectBinding().refresh(true)
                let oEventBus = Core.getEventBus()

                // Notify navigation change to icontabbar                
                oEventBus.publish('AGORA_REQUEST', 'PHASE_CLOSED', { processFlowId: oData.processFlowId })
            },

            onPhaseCloseError: function () {
                this.hideBusy()
                this.getView().getModel().resetChanges(null, true, true)
            },

            _getServiceList: function (oModel, oFilter) {
                oModel.read("/ServicesECC", {
                    filters: oFilter,
                    'success': function (oData) {
                        this._dialogServiceList.getModel("ServiceListModel").setData(oData.results)
                        this._dialogServiceList.open()
                    }.bind(this),
                    'error': function (oError) {
                        let errortext = e?.message
                        let oMessage = new sap.ui.core.message.Message({ message: "Error " + oBundle.getText("servicesList") + ": " + errortext, persistent: true, type: "Error" })
                        Messaging.addMessages(oMessage)
                    }.bind(this)
                })
            }
        })
    })