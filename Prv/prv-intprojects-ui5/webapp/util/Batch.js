// @ts-nocheck
sap.ui.define([], function () {
	"use strict";

	function hasBatchError(oData) {
		const batches = oData && oData.__batchResponses;
		if (!Array.isArray(batches)) return false;

		return batches.some(batch => {
			// Check direct response (like your error case)
			if (batch.response && batch.response.statusCode) {
				const statusCode = Number(batch.response.statusCode);
				return statusCode >= 400;
			}

			// Check nested change responses (if they exist)
			if (Array.isArray(batch.__changeResponses)) {
				return batch.__changeResponses.some(change => {
					const s1 = Number(change.statusCode || 0);
					const s2 = Number((change.response && change.response.statusCode) || 0);
					return s1 >= 400 || s2 >= 400;
				});
			}

			return batch.message?.includes("HTTP request failed");
		});
	}

	function submitPendingChanges(oModel) {
		return new Promise((resolve, reject) => {
			if (!oModel || !oModel.hasPendingChanges()) {
				return resolve({ submitted: false });
			}
			oModel.submitChanges({
				success: function (oData) {
					if (hasBatchError(oData)) {
						oModel.resetChanges(null, true, true);
						return resolve({ submitted: true, ok: false, oData });
					}
					resolve({ submitted: true, ok: true, oData });
				},
				error: function (err) {
					oModel.resetChanges(null, true, true);
					reject(err);
				}
			});
		});
	}

	/**
 * Configures a deferred batch group.
 * @param {sap.ui.model.odata.v2.ODataModel} oModel
 * @param {string} sGroupId
 */
	function configureDeferredGroup(oModel, sGroupId) {
		oModel.setUseBatch(true);
		oModel.setDeferredGroups([sGroupId]);
	}

	/**
	 * Submits a specific batch group.
	 * @param {sap.ui.model.odata.v2.ODataModel} oModel
	 * @param {string} sGroupId
	 * @returns {Promise<object>}
	 */
	function submitGroup(oModel, sGroupId) {
		return new Promise((resolve, reject) => {
			oModel.submitChanges({
				groupId: sGroupId,
				success: resolve,
				error: reject
			});
		});
	}

	return { hasBatchError, submitPendingChanges, configureDeferredGroup, submitGroup };
});