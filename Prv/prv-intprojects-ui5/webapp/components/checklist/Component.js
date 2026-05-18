// @ts-nocheck
sap.ui.define([
    "sap/ui/core/UIComponent",
    "sap/ui/Device"
], function (UIComponent, Device) {
    "use strict"

    return UIComponent.extend("prvintprojectsui5.components.checklist.Component", {

        metadata: { 
            manifest: "json"
        },
        
        interfaces: [sap.ui.core.IAsyncContentCreation],

        init: function () {
            // Call the base component's init function
            UIComponent.prototype.init.apply(this, arguments)
        },

        setParentType: function (iParentType, sPhaseType, sBlockType) {
            let oRootView = this.getRootControl()
            if (oRootView) {
                let oController = oRootView.getController();
                if (oController && typeof oController.setParentType === "function") oController.setParentType(iParentType, sPhaseType, sBlockType)
            }            
        }

    })
})