// @ts-nocheck
sap.ui.define([
    "prvintprojectsui5/controller/Base",
    "sap/ui/core/Core"
],
    /**
     * @param {typeof prvintprojectsui5.controller.Base} Base
     */
    function (Base, Core) {
        "use strict";

        return Base.extend("prvintprojectsui5.controller.phases.feasibilCheck.feasibilCheck", {
            onInit: function () {
                let oEventBus = Core.getEventBus()
                oEventBus.subscribe('AGORA_REQUEST', 'REFRESH_PHASE_1', this._onRequestBindingChange, this)
                // oEventBus.subscribe('AGORA_REQUEST', 'PHASE_CLOSED', this._onPhaseClosed, this)
            },

            onExit: function( ) {
                let oEventBus = Core.getEventBus();
                oEventBus.unsubscribe('AGORA_REQUEST', 'REFRESH_PHASE_1', this._onRequestBindingChange, this);
                oEventBus.unsubscribe('AGORA_REQUEST', 'PHASE_CLOSED', this._onPhaseClosed, this)
            },
   
            _onRequestBindingChange: function (sChannel, sPath, oData) {
                let oView = this.getView()
                let elementPath = this._getContextElement('Phases','feasibilCheck', oData.oContext)

                if (elementPath) {
                    let bActivated = oView.getParent().getModel().getProperty('/' + elementPath)
                    if (bActivated) {
                        oView.bindElement({
                            path: oData.oContext.getDeepPath() + '/' + elementPath,
                            parameters: {expand: 'Blocks,PhaseStatus'},
                            events : {
                                change: this._onPhaseBindingChange.bind(this),
                            }
                        })
                    }
                }
            },

            _onPhaseClosed: function (sChannel, sPath, oData) {
                //refresh las active phase info
                let oView = this.getView()
                oView.getObjectBinding().refresh(true)
            },

            _onPhaseBindingChange : function (oEvent) {
                let oView = this.getView()
                let oEventBus = Core.getEventBus()
                let oContext =  this.getView().getBindingContext()
                if (oContext) {
                    this._managePhaseClose(oContext)
                    let oConfigModel = oView.getModel('configuration')
                    let iStatus = oContext.getProperty('status')
                    if(iStatus === 3) {
                        oConfigModel.setProperty('/Phases/feasibilCheck/status', 'sap-icon://status-completed')
                    } else {
                        oConfigModel.setProperty('/Phases/feasibilCheck/status', '')
                    }
                    if(iStatus === 2) {
                        oConfigModel.setProperty('/Phases/feasibilCheck/enabled', false)
                    } else {
                        oConfigModel.setProperty('/Phases/feasibilCheck/enabled', true)
                    }
                    oEventBus.publish('AGORA_REQUEST', 'PHASE_1_BINDING_CHANGE', {oContext : oContext} )
                }
            }   

        })
    })