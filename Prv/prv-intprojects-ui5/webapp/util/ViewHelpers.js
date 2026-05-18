// @ts-nocheck
sap.ui.define(["sap/ui/core/Core", "sap/ui/core/ComponentRegistry"], function (Core, ComponentRegistry) {
	"use strict";

	function byId(oView, sId) {
		return oView && oView.byId(sId);
	}

	function openDialog(oDialog) {
		if (oDialog && oDialog.open) oDialog.open();
	}

	function findCellByAriaLabelKey(row, key) {
		const cells = row && row.getCells && row.getCells();
		if (!Array.isArray(cells)) return null;
		return cells.find(c => {
			const a = c.getAriaLabelledBy && c.getAriaLabelledBy();
			return Array.isArray(a) && a[0] && a[0].includes(key);
		}) || null;
	}

	function refreshValueListItems(oField) {
		const edit = oField && oField.getAggregation && oField.getAggregation("edit");
		const inner = edit && edit.getAllInnerControls && edit.getAllInnerControls()[0];
		const binding = inner && inner.getBinding && inner.getBinding("items");
		if (binding) binding.refresh(true);
	}

	function coreById(id) {
		return Core.byId(id);
	}

	/**
 * Sets the same width for all columns in a sap.ui.table.Table.
 * @param {sap.ui.table.Table} oTable
 * @param {string} sWidth - e.g. "0%", "120px"
 */
	function setAllUiTableColumnsWidth(oTable, sWidth) {
		if (!oTable || !oTable.getColumns) return;
		oTable.getColumns().forEach(c => c.setWidth(sWidth));
	}

	/**
	 * Rebinds a SmartTable.
	 * @param {sap.ui.comp.smarttable.SmartTable} [oSmartTable] - Optional SmartTable instance.
	 * @returns {void}
	 * @description
	 * Calls `rebindTable()` on the provided SmartTable if available.
	 * Safe no-op when `oSmartTable` is null/undefined or does not expose `rebindTable`.
	 */
	function rebind(oSmartTable) {
		if (oSmartTable && typeof oSmartTable.rebindTable === "function") {
			oSmartTable.rebindTable();
		}
	}

	function rebindSmartChart(oSmartChart) {
		if (oSmartChart && oSmartChart.rebindChart) oSmartChart.rebindChart();
	}

	function refreshListBinding(oControl, sAggregation = "items") {
		const b = oControl && oControl.getBinding && oControl.getBinding(sAggregation);
		if (b && b.refresh) b.refresh(true);
	}

	
	/**
	 * Finds a component by name and blockId
	 * @param {string} componentName - The component name to find
	 * @param {string} blockId - The block ID to match
	 * @returns {object|null} The found component or null
	 */
	function findComponentByNameAndBlockId(componentName, blockId) {
		try {
			const components = Object.values(ComponentRegistry.all());
			
			return components.find(c => 
				c?._componentConfig?.name === componentName &&
				c?.getVisible?.() &&
				c?.getBlockId?.() === blockId
			) || null;
		} catch (error) {
			console.error("Error finding component:", error);
			return null;
		}
	}
	
	return { byId, openDialog, rebindSmartChart, refreshListBinding, findCellByAriaLabelKey, refreshValueListItems, coreById, setAllUiTableColumnsWidth, rebind, findComponentByNameAndBlockId };
});