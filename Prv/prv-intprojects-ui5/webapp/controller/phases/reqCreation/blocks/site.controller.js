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

        return Base.extend("prvintprojectsui5.controller.phases.reqCreation.blocks.site", {

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
                let oForm = oView.byId('siteForm')
                let aErrors = []
                aErrors = oForm.check()
                if(aErrors.length < 1) {
                    this._closeBlockCall()
                } else {
                    this._showErrors(aErrors)
                }
            },

            _onRequestBindingChange: function(sChannel, sPath, oData) {
                let oSiteId = this.getView().byId('siteId')
                if(oSiteId) oSiteId.setBindingContext(oData.oContext)
                let oSiteName = this.getView().byId('siteName')
                if(oSiteName) oSiteName.setBindingContext(oData.oContext)
                let oCompany = this.getView().byId('company')
                if(oCompany) oCompany.setBindingContext(oData.oContext)
                let oManagingCompany = this.getView().byId('managingCompany')
                if(oManagingCompany) oManagingCompany.setBindingContext(oData.oContext)
                let oCellnexZone = this.getView().byId('cellnexZone')
                if(oCellnexZone) oCellnexZone.setBindingContext(oData.oContext)
                let oZone = this.getView().byId('zone')
                if(oZone) oZone.setBindingContext(oData.oContext)
                let oAbfZone = this.getView().byId('abfZone')
                if(oAbfZone) oAbfZone.setBindingContext(oData.oContext)
                let oInfraOrigin = this.getView().byId('infraOrigin')
                if(oInfraOrigin) oInfraOrigin.setBindingContext(oData.oContext)
                let oInfraOwnership = this.getView().byId('infraOwnership')
                if(oInfraOwnership) oInfraOwnership.setBindingContext(oData.oContext)
                let oInfraStatus = this.getView().byId('infraStatus')
                if(oInfraStatus) oInfraStatus.setBindingContext(oData.oContext)
                let oStreet = this.getView().byId('street')
                if(oStreet) oStreet.setBindingContext(oData.oContext)
                let oPostalCode = this.getView().byId('postalCode')
                if(oPostalCode) oPostalCode.setBindingContext(oData.oContext)
                let oMarketableId = this.getView().byId('marketableId')
                if(oMarketableId) oMarketableId.setBindingContext(oData.oContext)
                let oCellnexProject = this.getView().byId('cellnexProject')
                if(oCellnexProject) oCellnexProject.setBindingContext(oData.oContext)
                let oExploited = this.getView().byId('exploited')
                if(oExploited) oExploited.setBindingContext(oData.oContext)
                let oProductionZoneResponsible = this.getView().byId('productionZoneResponsible')
                if(oProductionZoneResponsible) oProductionZoneResponsible.setBindingContext(oData.oContext)
                let oSiteManagerZoneResponsible = this.getView().byId('siteManagerZoneResponsible')
                if(oSiteManagerZoneResponsible) oSiteManagerZoneResponsible.setBindingContext(oData.oContext)
                let oProductionRegionManager = this.getView().byId('productionRegionManager')
                if(oProductionRegionManager) oProductionRegionManager.setBindingContext(oData.oContext)
                let oRegionSiteManager = this.getView().byId('regionSiteManager')
                if(oRegionSiteManager) oRegionSiteManager.setBindingContext(oData.oContext)
                let oProductionManager = this.getView().byId('productionManager')
                if(oProductionManager) oProductionManager.setBindingContext(oData.oContext)
                let oSiteManager = this.getView().byId('siteManager')
                if(oSiteManager) oSiteManager.setBindingContext(oData.oContext)
                let oLandlordName = this.getView().byId('landlordName')
                if(oLandlordName) oLandlordName.setBindingContext(oData.oContext)
            },

            _onPhaseBindingChange: function (sChannel, sPath, oData) {
                if (this.getView().getModel('configuration').getData().stepper.firstActivePhase === 'reqCreation') {
                    let oView = this.getView()
                    let elementPath = this._getContextElement('Blocks','site', oData.oContext)
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
                        oModel.setProperty('/processInfo/reqCreation/site/VISIBLE_ON', '')
                    }
                }
            }

        })
    })