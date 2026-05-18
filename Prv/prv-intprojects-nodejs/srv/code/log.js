const { GlobalConstants } = require('../utils/enumerations')
const { TextBundle } = require("@sap/textbundle")

class LogCode {

    // After read changes
    afterReadChangesLog = async (aResults, oRequest) => {
        const oTexts = new TextBundle('../_i18n/i18n', oRequest.locale);
        const sRegex = />([^\>].*[^\}])/;

        // Create entity lookup map once
        const entityMap = {
            'Requests': cds.entities['project.Requests'],
            'RequestProvision': cds.entities['project.RequestProvision'],
            'Phases': cds.entities['project.Phases'],
            'Blocks': cds.entities['project.Blocks'],
            'BlockProvision': cds.entities['project.BlockProvision'],
            'Works': cds.entities['project.Works']
        };

        for (let oResult of aResults) {
            // Process user action
            this._processUserAction(oResult, oTexts);

            // Process field descriptions if field exists
            if (oResult.fieldName) {
                await this._processFieldDescriptions(oResult, entityMap, oTexts, sRegex);
            }
        }
    }

    // Helper method 1: Process user action
    _processUserAction = (oResult, oTexts) => {
        const rawAction = oResult.userAction;
        oResult.originalUserAction = rawAction; // preserve the original

        let baseAction = rawAction;
        let suffix = null;

        if (rawAction.includes("--")) {
            [baseAction, suffix] = rawAction.split("--");
        }

        const sKey = baseAction.toUpperCase().replace(/ /g, "");
        const sTranslation = oTexts.getText("WFLOG-" + sKey) || baseAction;

        // show translation but preserve original
        oResult.userActionTranslated = suffix ? `${sTranslation} - ${suffix}` : sTranslation;
        oResult.userActionName = sTranslation === "WFLOG-" + sKey ? oTexts.getText(sKey) : sTranslation;
    }

    // Helper method 2: Process field descriptions
    _processFieldDescriptions = async (oResult, entityMap, oTexts, sRegex) => {

        const { fieldName, userActionName } = oResult;

        // Handle CHECKLIST_UPDATE separately
        if (userActionName === "CHECKLIST_UPDATE") {
            const cleanValue = (val) => {
                if (!val) return val;
                // Remove any "(...)" at the end — e.g. "Yes (1)" → "Yes"
                return val.replace(/\s*\([^)]*\)\s*$/, '').trim();
            };

            Object.assign(oResult, {
                fieldDescription: fieldName,
                oldValueDescription: cleanValue(oResult.oldValue),
                newValueDescription: cleanValue(oResult.newValue)
            });

            return; // Skip normal logic
        }

        // Find the entity that contains this field
        const entity = this._findEntityByField(fieldName, entityMap);

        if (entity) {
            const fieldInfo = await this._getFieldDescriptions(entity, fieldName, oResult.oldValue, oResult.newValue, oTexts, sRegex);
            Object.assign(oResult, fieldInfo);
        }
    }

    // Helper method 3: Find entity by field name  
    _findEntityByField = (fieldName, entityMap) => {
        return Object.values(entityMap).find(entity => fieldName in entity.elements) || null;
    };

    // Helper method 4: Get field descriptions
    _getFieldDescriptions = async (entity, fieldName, oldValue, newValue, oTexts, sRegex) => {
        const title = entity.elements[fieldName]['@title'];
        const titleKey = title?.match(sRegex)?.[1];
        const description = titleKey ? oTexts.getText(titleKey) : oTexts.getText(fieldName);

        const collectionPath = entity.elements[fieldName]['@Common.ValueList.CollectionPath'];
        const fullPath = collectionPath ? 'project.' + collectionPath : null;

        return {
            fieldDescription: description,
            oldValueDescription: fullPath
                ? await this.#getDescriptionForValue(entity, fullPath, fieldName, oldValue)
                : oldValue,
            newValueDescription: fullPath
                ? await this.#getDescriptionForValue(entity, fullPath, fieldName, newValue)
                : newValue
        };
    }

    #getDescriptionForValue = async (oEntity, sAssociation, sField, sValue) => {
        if (sAssociation) {
            if (GlobalConstants.aExternalValueHelps.indexOf(sAssociation) < 0) {
                // Check against DB entity
                let oVHEntity = cds.entities[sAssociation]
                if (oVHEntity) {
                    let sTargetEntity = oVHEntity.name
                    let aWhere = []
                    for (let oParameter of oEntity.elements[sField]['@Common.ValueList.Parameters']) {
                        if (oParameter.$Type === 'Common.ValueListParameterInOut' && oParameter.LocalDataProperty['='] === sField) {
                            if (oEntity.elements[sField].type === 'cds.Integer') {
                                if (sValue)
                                    if (!Number.isNaN(sValue)) {
                                        aWhere.push(oParameter.ValueListProperty)
                                        aWhere.push('=')
                                        aWhere.push("'" + sValue + "'")
                                    } else {
                                        return null
                                    }
                                else {
                                    aWhere.push(oParameter.ValueListProperty)
                                    aWhere.push('=')
                                    aWhere.push('0')
                                }
                            } else {
                                if (sValue) {
                                    aWhere.push(oParameter.ValueListProperty)
                                    aWhere.push('=')
                                    aWhere.push("'" + sValue + "'")
                                } else {
                                    return ''
                                }
                            }
                            break
                        }
                    }
                    if (aWhere.length > 0) {
                        let sQuery = `select * from ${sTargetEntity}`
                        let oQuery = cds.parse.cql(sQuery)
                        oQuery.SELECT.where = aWhere
                        try {
                            let aValues = await cds.run(oQuery)
                            if (aValues && aValues.length > 0) {
                                return aValues[0].name
                            } else {
                                return ''
                            }
                        } catch (oError) {
                            return ''
                        }
                    }
                }
            }
        } else {
            return ''
        }
    }
}

module.exports = {
    LogCode
}