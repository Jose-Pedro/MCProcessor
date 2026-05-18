// @ts-nocheck
sap.ui.define([
    "sap/ui/core/UIComponent",
    "prvintprojectsui5/model/models",
    "sap/ui/core/Messaging",

    "sap/ui/core/Core"
], (UIComponent, models, Messaging,Core) => {
    "use strict";

    return UIComponent.extend("prvintprojectsui5.Component", {
        metadata: {
            manifest: "json",
            interfaces: [
                "sap.ui.core.IAsyncContentCreation"
            ]
        },

        init() {
            // call the base component's init function
            UIComponent.prototype.init.apply(this, arguments);
            if (window.location.host.includes("applicationstudio.cloud.sap") || window.location.host.includes("cf.launchpad.cfapps") || window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1"){
                // force morning horizon theme in launchpad
                Core.applyTheme('sap_horizon')
            }else{
                Core.applyTheme("cellnex_apolo_light_v1","/comsapuitheming.runtime/themeroot/v1/UI5/");
            }

            // set the device model
            this.setModel(models.createDeviceModel(), "device");

            // enable routing
            this.getRouter().initialize();

            //update ECC cache for user
            this.refreshR3EntitiesCache()
        },

        refreshR3EntitiesCache: function() {
            let oDataModel = this.getModel();
            oDataModel.callFunction('/refreshR3EntitiesCache', {
                method: "POST",
                error: function(error) {
                    sap.m.MessageBox.error("ErrorLoadingR3Cache");
                }.bind(this)
            })
        }

    });
});