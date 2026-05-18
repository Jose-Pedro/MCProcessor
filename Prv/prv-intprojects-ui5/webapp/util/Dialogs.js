// @ts-nocheck
sap.ui.define(["sap/ui/core/Fragment"], function (Fragment) {
	"use strict";

	/**
	 * Loads a fragment (if needed), adds it as dependent, and opens it as a dialog.
	 * Stores the instance on the controller at `sControllerProp`.
	 * @param {sap.ui.core.mvc.Controller} oController
	 * @param {string} sFragmentName
	 * @param {string} sControllerProp
	 * @param {(oDialog: sap.ui.core.Control) => void} [fnBeforeOpen] - Optional hook to run after load, before open
	 * @returns {Promise<sap.ui.core.Control>}
	 */
	function openOrLoad(oController, sFragmentName, sControllerProp, fnBeforeOpen, bUseControllerLoad = false) {
		const existing = oController[sControllerProp];
		if (existing && existing.open) {
			existing.open();
			if (typeof fnBeforeOpen === "function") fnBeforeOpen(existing);
			return Promise.resolve(existing);
		}

		const loadPromise = bUseControllerLoad
			? oController.loadFragment({ name: sFragmentName })
			: Fragment.load({
				id: oController.getView().getId(),
				name: sFragmentName,
				controller: oController
			});

		return loadPromise.then(function (oDialog) {
			oController[sControllerProp] = oDialog;
			oController.getView().addDependent(oDialog);
			if (typeof fnBeforeOpen === "function") fnBeforeOpen(oDialog);
			oDialog.open();
			return oDialog;
		});
	}

	/**
	 * Loads a fragment (if needed), adds it as dependent, and opens it as a popover by a source control.
	 * @param {sap.ui.core.mvc.Controller} oController
	 * @param {string} sFragmentName
	 * @param {string} sControllerProp
	 * @param {sap.ui.core.Control} oSource
	 * @param {(oPopover: sap.ui.core.Control) => void} [fnBeforeOpen]
	 * @returns {Promise<sap.ui.core.Control>}
	 */
	function openByOrLoadPopover(oController, sFragmentName, sControllerProp, oSource, fnBeforeOpen, bUseControllerLoad = false) {
		const existing = oController[sControllerProp];
		if (existing && existing.openBy) {
			existing.openBy(oSource);
			if (typeof fnBeforeOpen === "function") fnBeforeOpen(existing);
			return Promise.resolve(existing);
		}

		const loadPromise = bUseControllerLoad
			? oController.loadFragment({ name: sFragmentName })
			: Fragment.load({
				id: oController.getView().getId(),
				name: sFragmentName,
				controller: oController
			});

		return loadPromise.then(function (oPopOver) {
			oController[sControllerProp] = oPopOver;
			oController.getView().addDependent(oPopOver);
			if (typeof fnBeforeOpen === "function") fnBeforeOpen(oPopOver);
			oPopOver.openBy(oSource);
			return oPopOver;
		});
	}

	/**
	 * Destroys a dialog/popover if it exists and nulls the controller prop.
	 * @param {sap.ui.core.mvc.Controller} oController
	 * @param {string} sControllerProp
	 */
	function destroy(oController, sControllerProp) {
		const oCtrl = oController[sControllerProp];
		if (oCtrl && oCtrl.destroy) {
			oCtrl.destroy();
			oController[sControllerProp] = null;
		}
	}

	/**
	 * Close a dialog/popover if it exists.lls the controller prop.
	 * @param {sap.ui.core.mvc.Controller} oController
	 * @param {string} sControllerProp
	 */
	function close(oController, sControllerProp) {
		const oCtrl = oController[sControllerProp];
		if (oCtrl && oCtrl.close) {
			oCtrl.close();
		}
	}


	return { openOrLoad, openByOrLoadPopover, destroy, close };
});