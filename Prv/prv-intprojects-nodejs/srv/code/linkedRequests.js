const { UserCode } = require('./users')

class LinkedRequestsCode {
    async onCreate(oRequest) {
        const { parentRequestID, parentInstanceID, parentWorkflowID, associationType } = oRequest.data;
        const children = typeof oRequest.data.children === 'string'
            ? JSON.parse(oRequest.data.children)
            : [];

        // 0. Prevent parent being its own child
        const invalidSelfLinks = children.filter(child => child.childInstanceID === parentInstanceID);
        if (invalidSelfLinks.length) {
            return oRequest.reject(400,
                `Invalid link: parent request cannot be linked as its own child (${parentRequestID})`);
        }

        // 0.1 Prevent duplicate child IDs
        const childIDs = children.map(c => c.childInstanceID);
        const duplicateIDs = childIDs.filter((id, idx) => childIDs.indexOf(id) !== idx);
        if (duplicateIDs.length) {
            return oRequest.reject(400,
                `Duplicate child instance IDs in request: ${[...new Set(duplicateIDs)].join(', ')}`);
        }

        // 1. Validate parent exists
        const parent = await SELECT.one.from('REQUEST_HEAD')
            .where({ REQUEST_ID: parentInstanceID });
        if (!parent) {
            return oRequest.reject(404, "Parent request not found or data mismatch");
        }

        // 2. Prepare child validations
        const sQuery = `
            SELECT * 
            FROM DT_LINKED_REQUEST
            WHERE 
                PARENT_INSTANCE_ID = '${parentInstanceID}'
                AND CHILD_INSTANCE_ID IN ('${childIDs.join("','")}')
                AND (DELETED = false OR DELETED IS NULL)
        `;
        const [existingChildren, existingLinks] = await Promise.all([
            SELECT.from('REQUEST_HEAD').where({ REQUEST_ID: childIDs }),
            cds.run(sQuery)
        ]);

        // 3. Validate all children exist
        const missingChildren = children.filter(child =>
            !existingChildren.some(c => c.REQUEST_ID === child.childInstanceID));
        if (missingChildren.length) {
            return oRequest.reject(404,
                `Child requests not found: ${missingChildren.map(c => c.childRequestID).join(', ')}`);
        }

        // 4. Check for existing links
        if (existingLinks.length) {
            return oRequest.reject(409,
                `Links already exist: ${existingLinks.map(l => l.CHILD_REQUEST_ID).join(', ')}`);
        }
        
        // 5. Create all links (no transaction)
        const aResults = [];
        for (const child of children) {
            try {
                const result = await INSERT.into('DT_LINKED_REQUEST').entries({
                    ASSOCIATION_TYPE: associationType === 'null' ? null : associationType,
                    PARENT_REQUEST_ID: parentRequestID,
                    PARENT_INSTANCE_ID: parentInstanceID,
                    PARENT_WORKFLOW_ID: parentWorkflowID,
                    CHILD_REQUEST_ID: child.childRequestID,
                    CHILD_INSTANCE_ID: child.childInstanceID,
                    CHILD_WORKFLOW_ID: child.childWorkflowID,
                    DELETED: false
                });
                aResults.push(result);
            } catch (error) {
                aResults.push({
                    error: error.message,
                    childRequestID: child.childRequestID
                });
            }
        }

        // 6. Return results with partial success if needed
        const failures = aResults.filter(r => r.error);
        if (failures.length) {
            return oRequest.error(400, {
                message: `Partial failure: ${failures.length} errors`,
                details: failures
            });
        } 
    }


    async onBeforeCreate(oRequest) {
        const { childRequestID } = oRequest.data;
        const child = await SELECT.one.from('REQUEST_HEAD')
            .where({
                REQUEST_ID: childRequestID,
            });
        if (!child) {
            return oRequest.reject(404, "Child request not found or data mismatch");
        }
    }

    async onBeforeDelete(oRequest) {
        await UserCode.currentUserDetails(oRequest)

        if ('data' in oRequest && oRequest.data.deleted === true) {
            oRequest.data.deletedBy = oRequest.user.id;
        }
    }
    async onAfterCreate(oRequest) {
        await UserCode.currentUserDetails(oRequest)
        if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
    }

    async onBeforeRead(oRequest) {
        await UserCode.currentUserDetails(oRequest)
        if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')
    }

    async dtLinkedRequestPossibleChildrenRequestListBeforeRead(oRequest) {

        let filtersString = oRequest._queryOptions.$filter;
        /**filter to exclude request alredy linked in a request */
        if (!filtersString) {
            oRequest, oRequest.reject(400, 'parent is missing in the URL parameters');
        }
        console.log("filtersString:", filtersString); // Para depuración

        const match = filtersString.match(/parentInstanceID eq ([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})/);
        let parentInstanceID = match ? match[1] : null;



        console.log("Valor de parentInstanceID:", parentInstanceID);

        if (!parentInstanceID) {
            oRequest, oRequest.reject(400, 'parentInstanceID is missing in the URL parameters');
        }

        // Fetch parent to get its requestCode
        let parent;
        try {
            parent = await SELECT.one.from('REQUEST_HEAD')
                .columns('REQUEST_CODE')
                .where({ REQUEST_ID: parentInstanceID });
        } catch (err) {
            console.error("Error fetching parent data:", err);
            return oRequest.reject(400, 'Error fetching parent data');
        }

        if (!parent) {
            return oRequest.reject(404, 'Parent request not found');
        }

        let excludedRequests;

        try {
            excludedRequests = await SELECT.from('DT_LINKED_REQUEST')
                .columns('CHILD_REQUEST_ID')
                .where`PARENT_INSTANCE_ID = ${parentInstanceID} and (DELETED = false or DELETED is null)`;
        } catch (err) {
            console.log("error consulting data")
            oRequest.reject(400, 'excludedRequests data not found. Possible error in db');
        }

        let excludedRequestCodes = excludedRequests.map(request => request.CHILD_REQUEST_ID);
        // Always exclude parent itself
        excludedRequestCodes.push(parent.REQUEST_CODE);

        if (excludedRequestCodes.length > 0) {
            oRequest.query.where('requestCode NOT IN', excludedRequestCodes);
        }

    }

}

module.exports = {
    LinkedRequestsCode
}