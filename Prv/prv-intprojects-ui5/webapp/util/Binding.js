// @ts-nocheck
sap.ui.define(["sap/ui/model/Filter", "sap/ui/model/FilterOperator"], function (Filter, FilterOperator) {
	"use strict";

	/**
	 * Adds a filter to bindingParams, safely combining with existing filters.
	 * @param {{filters?: any}} oBindingParams
	 * @param {sap.ui.model.Filter} oFilter
	 * @param {boolean} [bAnd=true]
	 */
	function addFilter(oBindingParams, oFilter, bAnd = true) {
		if (!oBindingParams) return;
		const existing = oBindingParams.filters;
		if (Array.isArray(existing)) {
			oBindingParams.filters = new Filter({ filters: existing.concat(oFilter), and: bAnd });
		} else if (existing instanceof Filter) {
			oBindingParams.filters = new Filter({ filters: [existing, oFilter], and: bAnd });
		} else {
			oBindingParams.filters = [oFilter];
		}
	}

	/**
	 * Convenience EQ filter.
	 * @param {string} sPath
	 * @param {any} vValue
	 * @returns {sap.ui.model.Filter}
	 */
	function eq(sPath, vValue) {
		return new Filter(sPath, FilterOperator.EQ, vValue);
	}

	/**
	 * OR-combine filters.
	 * @param {sap.ui.model.Filter[]} aFilters
	 */
	function or(aFilters) {
		return new Filter({ filters: aFilters, and: false });
	}

	/**
	 * AND-combine filters.
	 * @param {sap.ui.model.Filter[]} aFilters
	 */
	function and(aFilters) {
		return new Filter({ filters: aFilters, and: true });
	}

	return { addFilter, eq, or, and };
});