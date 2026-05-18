// @ts-nocheck
sap.ui.define([
    "prvintprojectsui5/controller/Base",
    "sap/ui/core/Messaging",
    "sap/ui/core/Core"
],
    /**
     * @param {typeof prvintprojectsui5.controller.Base} Base
     */
    function (Base, Messaging, Core) {
        "use strict";

        return Base.extend("prvintprojectsui5.controller.phases.reqCreation.blocks.customers", {

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

            onBeforeRebindTable: function (oEvent) {
                let oView = this.getView()
                let sSiteId = oView.getBindingContext().getProperty('siteId')
                let sPath = `/Customers(p_siteId='${sSiteId}')/Set`
                oView.byId('siteCustomersTable').setTableBindingPath(sPath)
            },

            _onRequestBindingChange: function(sChannel, sPath, oData) {
                let oView = this.getView()
                oView.setBindingContext(oData.oContext)
                oView.byId('siteCustomersTable').rebindTable()
            },

            _onPhaseBindingChange: function (sChannel, sPath, oData) {
                if (this.getView().getModel('configuration').getData().stepper.firstActivePhase === 'reqCreation') {
                    this.getView().byId('siteCustomersTable').rebindTable()
                }
            },

        })
    })