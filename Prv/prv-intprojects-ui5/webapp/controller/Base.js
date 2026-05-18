// @ts-nocheck
sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/dom/isBehindOtherElement",
    "sap/m/MessageToast",
    "sap/ui/core/Messaging",
    "sap/ui/core/message/MessageType",
    "sap/ui/core/message/Message",
    "sap/ui/core/BusyIndicator",
    "sap/ui/core/routing/History",
    "sap/m/upload/UploadSetItem",
    "sap/ui/model/Filter",
    "sap/ui/core/Fragment",
    'sap/ui/core/Element',
    "sap/ui/core/Core",
    "sap/ui/core/ComponentRegistry"
],
    function (Controller, isBehindOtherElement, MessageToast, Messaging, MessageType, Message, BusyIndicator, History, UploadSetItem, Filter, Fragment, Element, Core, ComponentRegistry) {
        "use strict";

        return Controller.extend("prvintprojectsui5.controller.Base", {

            onInit: function () {
                if (!this.BusyIndicator) this.BusyIndicator = BusyIndicator
            },

            onCopy: function (oEvent) {
                navigator.clipboard.writeText(oEvent.getSource().data("copyData"));
            },

            showBusy: function () {
                BusyIndicator.show()
            },

            hideBusy: function () {
                BusyIndicator.hide()
            },

            statusIconFormatter: function (key) {
                switch (key) {
                    case 2:
                        return 'sap-icon://overlay'
                    case 7:
                        return 'sap-icon://alert'
                    case 4:
                        return 'sap-icon://error'
                    case 3:
                        return 'sap-icon://sys-enter-2'
                    case 12:
                        return 'sap-icon://stop'
                    case 32:
                        return 'sap-icon://alert'
                    default:
                        return 'sap-icon://overlay'
                }
            },

            statusStateFormatter: function (key) {
                switch (key) {
                    case 2:
                        return 'None'
                    case 7:
                        return 'Warning'
                    case 4:
                        return 'Error'
                    case 3:
                        return 'Success'
                    case 12:
                        return 'Error'
                    case 32:
                        return 'Warning'
                    default:
                        return 'None'
                }
            },

            validationDateformatter: function (key) {
                if (key) {
                    var oDateFormat = sap.ui.core.format.DateFormat.getDateInstance({
                        format: "yMMMd"
                    });
                    return oDateFormat.format(key)
                } else {
                    return null
                }
            },

            onHoldButtonTextFormatter: function (key) {
                if (key === 12) {
                    return this.getView().getModel("i18n").getResourceBundle().getText("resumeRequest");
                } else {
                    return this.getView().getModel("i18n").getResourceBundle().getText("onHoldRequest");
                }
            },

            onFieldChangeManager: function (){
            let oView = this.getView()
                let oModel = oView.getModel()
                let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                if (oModel.hasPendingChanges()) oModel.submitChanges({
                    'success':
                        function () {
                           if(oTable) oTable.rebindTable()
                        }.bind(this)
                })
            },
            
            onFieldChange: function () {
                //NOSONAR if (Messaging) Messaging.removeAllMessages()
                let oModel = this.getView().getModel()
                if (oModel.hasPendingChanges()) oModel.submitChanges(
                )
            },

            onMultiSelectionChange: function (oEvent) {
                let bSelected = oEvent.getParameter("selected")
                let oItem = oEvent.getParameter("changedItem")
                let sKey = oItem.getProperty("key")

                if (bSelected) {
                    if (this._aDeleted.indexOf(sKey) > -1) {
                        // Era persistida, se borró y se vuelve a marcar -> cancelar el DELETE
                        oEvent.preventDefault()
                        this._aDeleted = this._aDeleted.filter(function (k) { return k !== sKey })
                        let oModel = this.getView().getModel()
                        let oContext = this.getView().getBindingContext()
                        let sBindingPath = oEvent.getSource().getBinding("value")?.getPath()
                        let sEntity = sBindingPath.substring(0, sBindingPath.indexOf("/"))
                        let sEntityPath = "/" + sEntity + "(contractRestrictionId='" + sKey + "',BLOCK_ID='" + oContext.getProperty("ID") + "')"
                        oModel.resetChanges([sEntityPath])
                    } else {
                        // Nueva selección -> transiente
                        this._aTransient.push(sKey)
                    }
                } else {
                    if (this._aTransient.indexOf(sKey) > -1) {
                        // Era transiente -> simplemente quitarla
                        this._aTransient = this._aTransient.filter(function (k) { return k !== sKey })
                    } else if (this._aPersisted.indexOf(sKey) > -1) {
                        // Era persistida -> DELETE y trackear
                        this._aDeleted.push(sKey);
                        let oModel = this.getView().getModel()
                        let oContext = this.getView().getBindingContext()
                        let sBindingPath = oEvent.getSource().getBinding("value")?.getPath()
                        let sEntity = sBindingPath.substring(0, sBindingPath.indexOf("/"))
                        if (!sEntity) return
                        var sEntityPath = "/" + sEntity + "(contractRestrictionId='" + sKey + "',BLOCK_ID='" + oContext.getProperty("ID") + "')"
                        oModel.remove(sEntityPath)
                    }
                }
            },

            onMultiSelectionFinish: function (oEvent) {
                this._aTransient = []
                this._aDeleted = []
                let oControl = oEvent.getSource()
                let oModel = this.getView().getModel()

                let oPendingChanges = oModel.getPendingChanges()
                Object.keys(oPendingChanges).forEach(function (sTempKey) {
                    let oEntry = oPendingChanges[sTempKey]
                    let sCreatedKey = oEntry?.__metadata?.created?.key
                    if (sCreatedKey) {
                        let sKey = sCreatedKey.match(/contractRestrictionId='(.+?)'/)?.[1]
                        if (sKey && this._aPersisted.indexOf(sKey) > -1) {
                            let oContext = oModel.getContext("/" + sTempKey)
                            oModel.deleteCreatedEntry(oContext)
                        }
                    }
                }, this)
                this._aPersisted = oControl.getTokens().map(function (oToken) { return oToken.getKey() })
                if (oModel.hasPendingChanges()) {
                    oModel.submitChanges()
                }
            },

            onSubcoTypeChange: function () {
                let oModel = this.getView().getModel()
                var that = this
                if (oModel.hasPendingChanges()) oModel.submitChanges({
                    'success':
                        function (oData) {
                            let oExternal = that.getView().byId('selectExternalResponsible')
                            let aInnerControl = oExternal.getAllInnerControls()
                            let oInnerControl
                            aInnerControl.forEach((oControl) => {
                                if (oControl.getId().includes('combo')) oInnerControl = oControl
                            })
                            oInnerControl.getBinding('items').refresh(true)
                        }
                })
            },

            onMessagePopoverPress: function (oEvent) {
                var oSourceControl = oEvent.getSource()
                this._getMessagePopover().then(function (oMessagePopover) {
                    oMessagePopover.openBy(oSourceControl)
                })
            },

            onMessagePopoverClose: function () {
                if (Messaging) Messaging.removeAllMessages()
            },

            onMessagePress: function (oEvent) {
                let oItem = oEvent.getParameter("item")
                let oPage = this.getView().byId('mainPage')
                if (oPage) {
                    let oMessage = oItem.getBindingContext("message").getObject()
                    let oControl = Element.registry.get(oMessage.getControlId())

                    if (oControl) {
                        oPage.getScrollDelegate().scrollToElement(oControl.getDomRef(), 200, [0, -100])
                        setTimeout(function () {
                            var bIsBehindOtherElement = isBehindOtherElement(oControl.getDomRef());
                            if (bIsBehindOtherElement) {
                                this.close();
                            }
                            if (oControl.isFocusable()) {
                                oControl.focus();
                            }
                        }.bind(this), 300);
                    }
                }
            },

            onActiveChange: function (oEvent) {
                let oView = this.getView()
                let oModel = oView.getModel()
                let bSwitchState = oEvent.getParameters().state
                if (oModel.hasPendingChanges()) oModel.submitChanges({
                    'success':
                        function (oData) {
                            oView.getObjectBinding().refresh()
                            this._onActivateSwitch(bSwitchState, oView)
                        }.bind(this)
                })
            },

            onEditBlock: function () {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                oModel.callFunction('/Blocks_reOpen', { 
                    method: "POST", 
                    urlParameters: { 'ID': oContext.getProperty('ID') }, 
                    'success': function (oData) {
                        this.getView().getObjectBinding().refresh(true)
                    }.bind(this), 
                    'error': function () {
                        if(oModel.hasPendingChanges()) oModel.resetChanges(null, true, true)
                    }.bind(this), 
                    refreshAfterChange: true 
                })
            },

            clearAllMessages: function () {
                if (Messaging) Messaging.removeAllMessages()
            },

            isPositionable: function (sControlId) {
                if (sControlId && sControlId.constructor === Array) {
                    return sControlId.length > 0 ? true : false
                } else {
                    return sControlId ? true : false
                }
            },

            onAfterItemAdded: function (oEvent) {
                this.uploadedItem = oEvent.getParameter("item")
                this._createDocumentEntity(this.uploadedItem)
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

            onOpenPressed: function (oEvent) {
                oEvent.preventDefault()
                let oDocument = oEvent.getSource().getBindingContext().getObject();
                const documentId = oDocument.fileUrl;
                const filename = oDocument.documentName;
                let sUrl = "/CmmOpentextSrv/callOT";
                if (window.location.pathname.split('/test/flp.html').length === 2 || window.location.pathname.split('/index.html').length === 2) {
                    sUrl = "/callOT";
                }
                if (this.getOwnerComponent().getManifestObject().resolveUri(sUrl.substring(1, sUrl.length)))
                    sUrl = this.getOwnerComponent().getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))
    
                let body = {};
                body.protocol = "GET";
                body.uri = `/cellnex-ot-services/api/agora/document/downloadContent?documentId=${documentId}`
    
                body = JSON.stringify(body);
                $.ajax({
                    type: "POST",
                    contentType: "application/json",
                    url: sUrl,
                    data: body,
                    xhrFields: { responseType: 'blob', withCredentials: true },
                    success: function (data, textStatus, jqXHR) {
                        let sUrl = URL.createObjectURL(data);
                        let link = document.createElement('a');
                        link.href = sUrl;
                        link.setAttribute('download', filename);
                        document.body.appendChild(link);
                        link.click();
                        document.body.removeChild(link);
    
                    },
                    error: function (err) {
                        console.log(err)
                    }
                })    
            },

            onRemovePressed: function (oEvent) {
                oEvent.preventDefault()
                let oResourceBundle = this.getView().getModel("i18n").getResourceBundle()
                let oContext = oEvent.getSource().getBindingContext()
                let oUploadSet = oEvent.getSource().getParent()
                sap.m.MessageBox.confirm(oResourceBundle.getText("documentDeletionConfText"), {
                    title: oResourceBundle.getText("documentDeletionConfTitle"),
                    onClose: function (oAction) {
                        if (oAction === sap.m.MessageBox.Action.OK) {
                            oContext.delete({ 'groupId': null, 'refreshAfterChange': true }).then(function () {
                                if (oUploadSet.getBinding("items")) {
                                    oUploadSet.getBinding("items").refresh()
                                }
                            }.bind(this), function (oError) {
                                if (oUploadSet.getBinding("items")) {
                                    oUploadSet.getBinding("items").refresh()
                                }
                            })
                        }
                    },                                       //
                    actions: [sap.m.MessageBox.Action.OK, sap.m.MessageBox.Action.CANCEL],
                    emphasizedAction: sap.m.MessageBox.Action.CANCEL,
                })
            },

            onShowOtDocumentsFlow: function (oEvent) {
                let oContext = oEvent.getSource().getBindingContext() + "/InstancesPerDocuments"
                if (!this.oShowOtDocumentsFlow) {
                    this.loadFragment({
                        name: "prvintprojectsui5.fragments.showOtDocumentsFlow"
                    }).then(function (oDialog) {
                        this.oShowOtDocumentsFlow = oDialog
                        this.oShowOtDocumentsFlow.bindElement({
                            path: oContext,
                            events: {
                                'change': (oEvent) => {
                                    let oUploader = this.getView().byId('docFlowOtView')
                                    let oDialogContext = this.oShowOtDocumentsFlow.getBindingContext()
                                    if (oDialogContext) {
                                        let oTemplate = new UploadSetItem({ fileName: "{documentName}", mediaType: "{mediaType}", url: "{ID}", uploadUrl: "{fileUrl}", visibleEdit: false, visibleRemove: false })
                                        oTemplate.attachOpenPressed(this.onOpenPressed, this)
                                        let sPath = oDialogContext + '/Documents'
                                        oUploader.setBindingContext(oDialogContext)
                                        oUploader.setUploadEnabled(false)
                                        oUploader.bindAggregation('items', {
                                            path: sPath,
                                            template: oTemplate,
                                            templateShareable: false
                                        })
                                    } else {
                                        if(oUploader) oUploader.unbindAggregation('items', false)
                                    }
                                }
                            }
                        })
                        this.oShowOtDocumentsFlow.openBy(oEvent.getSource())
                    }.bind(this))
                } else {
                    this.oShowOtDocumentsFlow.bindElement({
                        path: oContext,
                        events: {
                            'change': (oEvent) => {
                                let oUploader = this.getView().byId('docFlowOtView')
                                let oDialogContext = this.oShowOtDocumentsFlow.getBindingContext()
                                if (oDialogContext) {
                                    let oTemplate = new UploadSetItem({ fileName: "{documentName}", mediaType: "{mediaType}", url: "{ID}", uploadUrl: "{fileUrl}", visibleEdit: false, visibleRemove: false })
                                    oTemplate.attachOpenPressed(this.onOpenPressed, this)
                                    let sPath = oDialogContext + '/Documents'
                                    oUploader.setBindingContext(oDialogContext)
                                    oUploader.setUploadEnabled(false)
                                    oUploader.bindAggregation('items', {
                                        path: sPath,
                                        template: oTemplate,
                                        templateShareable: false
                                    })
                                } else {
                                    if(oUploader) oUploader.unbindAggregation('items', false)
                                }
                            }
                        }
                    })
                    this.oShowOtDocumentsFlow.openBy(oEvent.getSource())
                }
            },

            onFieldpreferredProviderChange: function () {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                if (oModel.hasPendingChanges()) oModel.submitChanges({
                    'success':
                        function () {
                           if(oTable)  oTable.rebindTable()
                        }.bind(this)
                })
            },

            phaseInfo: function (faseID) {
                if (faseID) {
                    let oView = this.getView()
                    let oContext = oView.getBindingContext()
                    if (oContext) {
                        let oPhasesBindings = oContext.getProperty('Phases')
                        return oView.getModel().getProperty("/" + oPhasesBindings.find(aphase => oView.getModel().getProperty("/" + aphase).processFlowId === faseID))
                    }
                }
            },

            getWfId: function (requestType) {
                return 'int';
            },

            permitsLaunchnav: function (oBlockProvisioning) {
                let oView = this.getView()
                let oContext = oView.getBindingContext()
                let oTarget = { semanticObject: "PermitsPlanning", action: "Display" }
                let assignedResponsibleId, assignedResponsibleName, customerResponsible, cellnexResponsible = null
                const technicalLocation = "";
                if (oBlockProvisioning?.assignedResponsible === "2") {
                    //customer
                    assignedResponsibleId = oBlockProvisioning?.externalResponsible;
                    customerResponsible = oBlockProvisioning?.externalResponsible;
                    assignedResponsibleName = btoa(customerResponsible);
                }
                else {
                    //cellnex
                    assignedResponsibleId = oBlockProvisioning?.assignedResponsible;
                    cellnexResponsible = "Cellnex";
                    assignedResponsibleName = btoa(cellnexResponsible);
                }
                let permitsText = oBlockProvisioning?.permitAdaptations;
                if (permitsText === null) {
                    permitsText = "";
                } else {
                    permitsText = btoa(permitsText);
                }

                let sParams = "?&/PermitsLauncher/" +
                    assignedResponsibleId + "," + //assignedResponsible
                    assignedResponsibleName + "," + //assignedResponsibleName
                    oContext.getProperty('siteId') + "," + //site
                    oContext.getProperty('code') + "," + //requestCode
                    "true" + "," + //tPath
                    oContext.getProperty('customer') + "," + //customer
                    btoa(oContext.getProperty('customerName')) + "," + //customerName
                    oContext.getProperty('RequestProvision').commercialProgram + "," + //project
                    permitsText + "," + //permitsNeeded
                    technicalLocation + "," + //technicalLocation
                    oContext.getProperty('requestType'); //navform
                sap.ushell.Container.getServiceAsync("CrossApplicationNavigation").then(function (oCrossAppNavigator) {
                    let hash = (oCrossAppNavigator && oCrossAppNavigator.hrefForExternal({
                        target: oTarget
                    })) || ""
                    sap.m.URLHelper.redirect(window.location.href.split('#')[0] + hash + sParams, true)
                }).catch(function (error) {
                    console.error("Error al obtener CrossApplicationNavigation:", error);
                });
            },

            _navBack: function () {
                if (Messaging) Messaging.removeAllMessages()
                this.getOwnerComponent().getRouter().navTo("Routesearch", {}, true)
            },

            _closeBlockCall: function (oEvent) {
                if (Messaging) Messaging.removeAllMessages()
                let oView = this.getView()
                let oModel = oView.getModel()
                let oContext = oView.getBindingContext()
                this.showBusy()
                oModel.callFunction('/Blocks_close', { 
                    method: "POST", 
                    urlParameters: { 'ID': oContext.getProperty('ID') }, 
                    'success': function (oData) {
                        this.hideBusy()
                        oView.getObjectBinding().refresh(true)
                        let oEventBus = Core.getEventBus()
                        if (oData && oData.Blocks_close) {
                            let oTable = this.getView().byId("OTRequestRequestDocumentsPerBlockDefaultValid")
                            if(oTable) oTable.rebindTable()
                            //phase or request has been completed
                            if (oData.Blocks_close === 'requestCompleted') {
                                //notify and leave to search view
                                MessageToast.show(oView.getModel("i18n").getResourceBundle().getText('requestCompleted'))
                                this._navBack()
                            } else {
                                //NOSONAR if (aResponses[0] === 'true') oEventBus.publish('AGORA_REQUEST', 'SITE_CHANGED')
                                if (oData.Blocks_close.includes(',')) {
                                    oEventBus.publish('AGORA_REQUEST', 'POPULATION', { populatedBlocks: oData.Blocks_close })
                                } else {
                                    if (oData.Blocks_close !== '') {
                                        let oConfigModel = oView.getModel('configuration')
                                        oConfigModel.setProperty('/stepper/firstActivePhase', oData.Blocks_close) //set next phase as firstPhase
                                        oView.getParent().getObjectBinding().refresh(true) //refresh parent phase status
                                        oEventBus.publish('AGORA_REQUEST', 'PHASE_CLOSED', { processFlowId: oData.Blocks_close }) // Notify navigation change to icontabbar    
                                    }
                                }
                            }
                        } else {
                            //Do nothing by the moment
                        }
                    }.bind(this), 
                    'error': function () {
                        if (oModel.hasPendingChanges()) oModel.resetChanges(null, true, true)
                        this.hideBusy()
                    }.bind(this), 
                    refreshAfterChange: true })
            },

            _getContextElement: function (entity, flowId, oContext) {
                let oView = this.getView()
                let oModel = oView.getModel()
                if (oModel) {
                    let oElement = oModel.bindList(entity, oContext, undefined, new sap.ui.model.Filter('processFlowId', sap.ui.model.FilterOperator.EQ, flowId))
                    return oElement.aKeys[0]
                }
            },

            /*
            * @description Get messages to show in the POP-OVER
            */
            _getMessagePopover: function () {
                var oView = this.getView();

                if (!this._oMessagePopover) {
                    this._oMessagePopover = Fragment.load({
                        name: "prvintprojectsui5.fragments.messagePopOver",
                        controller: this
                    }).then(function (oMessagePopover) {
                        oView.addDependent(oMessagePopover)
                        return oMessagePopover
                    })
                }
                return this._oMessagePopover
            },

            _getRequestAllowedActions: function () {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oConfigModel = oView.getModel('configuration')
                oModel.callFunction('/getRequestAllowedActions', {
                    groupId: 'getRequestAllowedActions',
                    method: "POST",
                    success: function (oData) {
                        if (oData && 'getRequestAllowedActions' in oData && oData.getRequestAllowedActions) oConfigModel.setProperty('/requestActions', oData.getRequestAllowedActions)
                    }.bind(this),
                    error: function (oError) {
                        oModel.resetChanges(null, true, true)
                        this.hideBusy()
                    }.bind(this)
                })
            },

            _getBlockAllowedActions: function (requestId) {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oConfigModel = oView.getModel('configuration')
                oModel.callFunction('/getBlocksAllowedActions', {
                    method: "POST",
                    groupId: 'getBlocksAllowedActions',
                    success: function (oData) {
                        if (oData.getBlocksAllowedActions) oConfigModel.setProperty('/blockActions', oData.getBlocksAllowedActions)
                    }.bind(this),
                    error: function (oError) {

                    }.bind(this),
                    urlParameters: {
                        requestId: requestId
                    }
                })
            },

            _getPhasesStatus: function (sRequestId) {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oConfigModel = oView.getModel('configuration')
                oModel.callFunction('/getPhasesStatus', {
                    method: "POST",
                    groupId: 'getPhasesStatus',
                    success: function (oData) {
                        if (oData.results) {
                            for(let aPhase of oData.results) {
                                oConfigModel.setProperty(`/Phases/${aPhase.phaseName}/status`, aPhase.status)
                            }
                        }
                    }.bind(this),
                    error: function (oError) {

                    }.bind(this),
                    urlParameters: {
                        requestId: sRequestId
                    }
                })
            },

            _firePhaseEvent: function (sSelectedKey, oContext) {
                let oEventBus = Core.getEventBus()
                switch (sSelectedKey) {
                    case 'reqCreation':
                        oEventBus.publish('AGORA_REQUEST', 'PHASE_0_BINDING_CHANGE', { oContext: oContext })
                        break
                    case 'feasibilCheck':
                        oEventBus.publish('AGORA_REQUEST', 'PHASE_1_BINDING_CHANGE', { oContext: oContext })
                        break
                    case 'siteSurvey':
                        oEventBus.publish('AGORA_REQUEST', 'PHASE_2_BINDING_CHANGE', { oContext: oContext })
                        break
                    case 'techCostAnalys':
                        oEventBus.publish('AGORA_REQUEST', 'PHASE_3_BINDING_CHANGE', { oContext: oContext })
                        break
                    case 'custOfferAccept':
                        oEventBus.publish('AGORA_REQUEST', 'PHASE_4_BINDING_CHANGE', { oContext: oContext })
                        break
                    case 'manageAdapt':
                        oEventBus.publish('AGORA_REQUEST', 'PHASE_5_BINDING_CHANGE', { oContext: oContext })
                        break
                    case 'instCustEquip':
                        oEventBus.publish('AGORA_REQUEST', 'PHASE_6_BINDING_CHANGE', { oContext: oContext })
                        break
                    case 'finalValidation':
                        oEventBus.publish('AGORA_REQUEST', 'PHASE_7_BINDING_CHANGE', { oContext: oContext })
                        break
                }
            },

            _managePhaseClose: function (oContext) {
                let oView = this.getView()
                let oConfigModel = oView.getModel('configuration')
                let sSelectedKey = oConfigModel.getProperty('/stepper/firstActivePhase')
                if (!oContext) {
                    oContext = oView.byId(sSelectedKey).getBindingContext()
                }
                if (oContext && oContext.getProperty('processFlowId') === sSelectedKey) {
                    let sPhaseId = oContext.getProperty('ID')
                    let iStatus = oContext.getProperty('status')
                    let bCloseBlocks = oContext.getProperty('closeBlock')
                    oConfigModel.setProperty('/selectedPhaseId', sPhaseId)
                    if (iStatus === 7 && bCloseBlocks === true) {
                        oConfigModel.setProperty('/showClosePhase', true)
                    } else {
                        oConfigModel.setProperty('/showClosePhase', false)
                    }
                }
            },

            _bindUploadTableFromView: function (sBlockId, bVisible, sContainerId, sParentType, sPhaseType, sBlockType) {
                let oContainer = this.getView().byId(sContainerId)
                let oEventBus = Core.getEventBus()
                if (oContainer) {
                    let oComponent = oContainer.getComponentInstance()
                    if (oComponent) oComponent.setParentType(sParentType, sPhaseType, sBlockType)
                }
                if (oEventBus) oEventBus.publish("uploadTable", "refreshTable", {blockId: sBlockId, bVisible: bVisible})
            },

            _bindDocumentsPerBlockFromView: function(sBlockId, bVisible, sContainerId, sParentType, sPhaseType, sBlockType) {
                let oContainer = this.getView().byId(sContainerId)
                let oEventBus = Core.getEventBus()
                if (oContainer) {
                    let oComponent = oContainer.getComponentInstance()
                    if (oComponent) oComponent.setParentType(sParentType, sPhaseType, sBlockType)
                }
                if (bVisible) oEventBus.publish('approvalFlows', 'rebind', {blockId: sBlockId, bVisible: bVisible})
            },
            
            _bindWorksFromView: function(sBlockId, bVisible, sContainerId, sParentType, sPhaseType, sBlockType) {
                let oContainer = this.getView().byId(sContainerId)
                let oEventBus = Core.getEventBus()
                if (oContainer) {
                    let oComponent = oContainer.getComponentInstance()
                    if (oComponent) oComponent.setParentType(sParentType, sPhaseType, sBlockType)
                }
                if (bVisible) oEventBus.publish('works', 'rebind', {blockId: sBlockId, bVisible: bVisible})
            },

            _bindChecklistFromView: function(sBlockId, bVisible, sContainerId, sParentType, sPhaseType, sBlockType) {
                let oContainer = this.getView().byId(sContainerId)
                let oEventBus = Core.getEventBus()
                if (oContainer) {
                    let oComponent = oContainer.getComponentInstance()
                    if (oComponent) oComponent.setParentType(sParentType, sPhaseType, sBlockType)
                }
                if (bVisible) oEventBus.publish('checklist', 'rebind', {blockId: sBlockId, bVisible: bVisible})
            },

            _createDocumentEntity: function (oItem) {
                let oView = this.getView()
                let oModel = oView.getModel()
                let oRequestContext = oView.getParent().getParent().getBindingContext()
                let oBlockContext = oView.getBindingContext()
                let data = {
                    requestId: oRequestContext.getProperty('ID'),
                    instanceId: null,
                    blockId: oBlockContext.getProperty('ID'),
                    requestCode: oRequestContext.getProperty('code'),
                    blockName: oBlockContext.getProperty('processFlowId'),
                    docType: 'Support Document',
                    documentName: oItem.getFileName(),
                    subType: 'Support Document',
                    subTypeLvl2: 'Support Document',
                    documentId: 'Support Document',
                    finalDocument: false,
                    mediaType: oItem.getMediaType()
                }
                oModel.create('/LocalDocuments', data, {
                    'success': function (oData) { this._uploadDocumentContent(this.uploadedItem, oData.ID) }.bind(this)
                })
            },

            _uploadDocumentContent: function (item, id) {
                let sUrl = `/odata/v2/service/project/LocalDocuments(${id})/content`
                if (this.getOwnerComponent().getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))) {
                    sUrl = this.getOwnerComponent().getManifestObject().resolveUri(sUrl.substring(1, sUrl.length))
                }
                item.setUploadUrl(sUrl);
                let oUploadSet = item.getParent()
                oUploadSet.setHttpRequestMethod(sap.m.upload.UploaderHttpRequestMethod.Put)
                oUploadSet.uploadItem(item)
            },

            _navToApp: async function (oTarget, oParameters) {
                var externalUrl = oParameters['sap-app-origin-hint'];
                sap.ushell.Container.getServiceAsync("CrossApplicationNavigation").then(function (oCrossAppNavigator) {
                    var hash = (oCrossAppNavigator && oCrossAppNavigator.hrefForExternal({
                        target: oTarget,
                        params: externalUrl ? undefined : oParameters
                    })) || "";
                    if (externalUrl) {
                        sap.m.URLHelper.redirect(window.location.href.split('#')[0] + hash + externalUrl, true)
                    } else {
                        sap.m.URLHelper.redirect(window.location.href.split('#')[0] + hash, true)
                    }
                }).catch(function (error) {
                    console.error("Error al obtener CrossApplicationNavigation:", error);
                });
            },

            //NOSONAR _onRequestDocumentChange: function (sChannel, sPath, oData) {
            //NOSONAR     let oView = this.getView();
            //NOSONAR     let oContext = oView.getBindingContext();
            //NOSONAR     if (oContext) {
            //NOSONAR         let sId = oContext.getProperty("ID")
            //NOSONAR         let bVisible = oContext.getProperty("dpbVisibleVF") 
            //NOSONAR         if(sId !== oData.blockId && bVisible ) this._bindDocumentsPerBlockFromView(sId, bVisible)
            //NOSONAR     }
            //NOSONAR },

            _onDocumentsPerBlockDefaultValidFieldChange: function (oEvent, oTable) {
                if (Messaging) Messaging.removeAllMessages()
                let oModel = this.getView().getModel()
                if (oModel.hasPendingChanges()) oModel.submitChanges({
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
                                }
                            }
                        }
                        if (bHasError) {
                            oModel.resetChanges(null, true, true)
                            oTable.rebindTable()
                        }                   
                    }
                })
            },

            _callActionCancelDocumentsPerBlocksDefaultValid: function (sTableId, oEvent) {
                let oView = this.getView()
                let oModel = oView.getModel()
                let sId = oEvent.getSource().getBindingContext().getProperty('ID');
                let sRequestId = oEvent.getSource().getBindingContext().getProperty('requestId');
                let oTable = oView.byId(sTableId)
                oModel.callFunction("/Requests_onCancelDefaultValidators", {
                    method: "POST",
                    success: function (oError) {
                        if(oTable)oTable.rebindTable()
                    }.bind(this),
                    error: function (oError) {
                        oModel.resetChanges(null, true, true);
                        if(oTable) oTable.getTable().setBusy(false)
                        this.hideBusy()
                    }.bind(this),
                    urlParameters: {
                        'ID': sRequestId,
                        'dpbRegisterId': sId
                    }
                })
            },

             /**
            * @description When adding document show Add Document Per Block Dialog
            * @param {oEvent} Object with event data
            */
            _onShowAddDocumentPerBlockValidDialog: function (sTableId, oEvent) {
                let sRequestId = this.getView().getBindingContext().getProperty('ID');
                if (!this._oAddDocumentDialogDefaultValid) {
                    this.loadFragment({
                        name: "prvintprojectsui5.fragments.addDocumentPerRequestDefaultValuesDialog"
                    }).then(function (oDialog) {
                        this._oAddDocumentDialogDefaultValid = oDialog
                        this._oAddDocumentDialogDefaultValid.setBindingContext(this._callActionAddDocumentPerBlockValid(sTableId, sRequestId))
                        this._oAddDocumentDialogDefaultValid.open()
                    }.bind(this))
                } else {
                    this._oAddDocumentDialogDefaultValid.setBindingContext(this._callActionAddDocumentPerBlockValid(sTableId, sRequestId))
                    this._oAddDocumentDialogDefaultValid.open()
                }
            },
            
            _callActionAddDocumentPerBlockValid: function (sTableId, sRequestId) {
                let oView = this.getView().setBindingContext()
                let oModel = oView.getModel()
                this.showBusy()
                oModel.callFunction("/Requests_addRequestDocumentsPerBlockDefaultValid", {
                    method: "POST",
                    groupId: "changes",
                    success: function (oError) {
                        this.hideBusy()
                    }.bind(this),
                    error: function (oError) {
                        oModel.resetChanges(null, true, true);
                        this.hideBusy()
                    }.bind(this),
                    urlParameters: {
                        'ID': sRequestId,
                        'documentId': ''
                    }
                }).contextCreated().then(function (oContext) {
                    this.hideBusy()
                    this.getView().byId('addDocumentPerRequestDefaultValuesForm').setBindingContext(oContext)
                    return (oContext)
                }.bind(this))
            },
            
            _onSubcoChangeSuccess: function (oExternal) {
                if (!oExternal) {
                    return; // or maybe log a warning
                }
                let oCombo = oExternal.getInnerControls().find(c => c.isA("sap.m.ComboBox"));
                if (oCombo) {
                    oCombo.getBinding("items").refresh(true);
                }
            },

            _showErrors: function (aErrors) {
                let oView = this.getView()                
                let oBundle = this.getView().getModel('i18n').getResourceBundle()
                let sText = oBundle.getText('invalidValue')

                for(let sFieldId of aErrors ) {
                    let oControl = oView.byId(sFieldId)
                    let oMessage = new Message({ 
                        message: sText + ' ' + oControl._sAnnotationLabel, 
                        persistent: true, 
                        type: MessageType.Error,
                        fullTarget: oControl.getBinding('value').getContext().getDeepPath() + '/' + oControl.getBinding('value').getPath(),
                        target: oControl.getBinding('value').getContext().getDeepPath() + '/' + oControl.getBinding('value').getPath(),
                        processor: oControl.getBinding("value")?.getModel()
                    })
                    oMessage.addControlId(sFieldId)
                    Messaging.addMessages(oMessage)
                }
            },

            _clearSearchTableFilters: function (sTable) {
                let oSmartTable = this.byId("sTable")
                if (!oSmartTable) return
                let oInnerTable = oSmartTable.getTable()
                if (!oInnerTable) return
                const oBinding = oInnerTable.getBinding('rows')
                if (oBinding) {
                    oBinding.filter([])
                    oBinding.sort(null)
                }
                oInnerTable.getColumns().forEach(function (oCol) {
                    oCol.setSorted(false)
                    if (oCol.setSortOrder) oCol.setSortOrder(tableLibrary.SortOrder.None)
                    if (oCol.setFiltered) oCol.setFiltered(false)
                })
                oSmartTable.rebindTable(true)
                let oSVM = oSmartTable.getSmartVariant()
                if (oSVM && oSVM.currentVariantSetModified) oSVM.currentVariantSetModified(false)
            }

        })
    }
)