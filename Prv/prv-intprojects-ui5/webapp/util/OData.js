// @ts-nocheck
sap.ui.define([], function () {
	"use strict";

	/**
	 * Promisified OData read.
	 * @param {sap.ui.model.odata.v2.ODataModel} oModel
	 * @param {string} sPath
	 * @param {object} [mParameters]
	 * @returns {Promise<object>}
	 */
	function read(oModel, sPath, mParameters = {}) {
		return new Promise((resolve, reject) => {
			oModel.read(sPath, Object.assign({}, mParameters, {
				success: resolve,
				error: reject
			}));
		});
	}

	/**
	 * Promisified OData create.
	 * @param {sap.ui.model.odata.v2.ODataModel} oModel
	 * @param {string} sPath
	 * @param {object} oData
	 * @param {object} [mParameters]
	 * @returns {Promise<object>}
	 */
	function create(oModel, sPath, oData, mParameters = {}) {
		return new Promise((resolve, reject) => {
			oModel.create(sPath, oData, Object.assign({}, mParameters, {
				success: resolve,
				error: reject
			}));
		});
	}

	/**
	 * Promisified OData update.
	 * @param {sap.ui.model.odata.v2.ODataModel} oModel
	 * @param {string} sPath
	 * @param {object} oData
	 * @param {object} [mParameters]
	 * @returns {Promise<object>}
	 */
	function update(oModel, sPath, oData, mParameters = {}) {
		return new Promise((resolve, reject) => {
			oModel.update(sPath, oData, Object.assign({}, mParameters, {
				success: resolve,
				error: reject
			}));
		});
	}

	/**
	 * Promisified OData function import.
	 * @param {sap.ui.model.odata.v2.ODataModel} oModel
	 * @param {string} sFunctionName
	 * @param {"GET"|"POST"} sMethod
	 * @param {object} [mUrlParameters]
	 * @param {object} [mParameters]
	 * @returns {Promise<object>}
	 */
	function callFunction(oModel, sFunctionName, sMethod, mUrlParameters, mParameters = {}) {
		return new Promise((resolve, reject) => {
			oModel.callFunction(sFunctionName, Object.assign({}, mParameters, {
				method: sMethod,
				urlParameters: mUrlParameters,
				success: resolve,
				error: reject
			}));
		});
	}

	return { read, create, update, callFunction };
});