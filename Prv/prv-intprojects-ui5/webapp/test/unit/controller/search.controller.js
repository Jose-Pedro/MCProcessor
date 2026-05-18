/*global QUnit*/

sap.ui.define([
	"prvintprojectsui5/controller/search.controller"
], function (Controller) {
	"use strict";

	QUnit.module("search Controller");

	QUnit.test("I should test the search controller", function (assert) {
		var oAppController = new Controller();
		oAppController.onInit();
		assert.ok(oAppController);
	});

});
