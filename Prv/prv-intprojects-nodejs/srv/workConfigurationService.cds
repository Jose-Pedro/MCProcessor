using { APPROVER_TYPES, SUBCO_TYPES } from '../db/selectoptions';
using { WORK_TYPES, WORK_PARENT_TYPES, WORK_CONFIGS, WORK_CONFIG_PROCESSES, WORK_CONFIG_OBJECTIVES, WORK_CONFIG_DOCUMENT_FLOWS, WORK_CONFIG_DOCUMENT_DEFAULTS, PROJECT_OBJECTIVES } from '../db/works';

@path: '/service/workconfiguration'
// @requires: 'authenticated-user'
service workconfiguration {

    entity WorkTypes as projection on WORK_TYPES;
    entity WorkTypesTexts as projection on WORK_TYPES.texts;
    entity WorkParentTypes as projection on WORK_PARENT_TYPES;
    entity MasterObjectives as projection on PROJECT_OBJECTIVES;
    entity MasterObjectivesTexts as projection on PROJECT_OBJECTIVES.texts;
    entity WorkConfigs as projection on WORK_CONFIGS;
    entity FlowsPerProcess as projection on WORK_CONFIG_PROCESSES;
    entity Objectives as projection on WORK_CONFIG_OBJECTIVES;
    entity Documents as projection on WORK_CONFIG_DOCUMENT_FLOWS;
    entity DocumentDefaults as projection on WORK_CONFIG_DOCUMENT_DEFAULTS;
    @readonly entity ApproverTypes as projection on APPROVER_TYPES;
    @readonly entity SubcoTypes as projection on SUBCO_TYPES where code in ( 3, 4 );

}

annotate workconfiguration.WorkTypes with @(    
    UI: {
        HeaderInfo: {
            TypeName      : 'Work type',
            TypeNamePlural: 'Work types',
            Title         : {
                $Type: 'UI.DataField',
                Value: name
            }
        },
        LineItem: [
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: name },
            { $Type: 'UI.DataField', Value: descr }
        ],
        SelectionFields: [
            ID,
            name,
            descr
        ],
        FieldGroup #data : {
            $Type : 'UI.FieldGroupType',
            Label : '{i18n>data}',
            Data  : [
                { $Type : 'UI.DataField', Value : ID },
                { $Type : 'UI.DataField', Value : name },
                { $Type : 'UI.DataField', Value : descr },
            ]
        },
        Facets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#data' , Label : '{i18n>data}' },
            { $Type : 'UI.ReferenceFacet', Target : 'translations/@UI.LineItem' , Label : '{i18n>translations}' },
        ]
});

annotate workconfiguration.WorkTypesTexts with @(    
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: LOCALE },
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: NAME },
            { $Type: 'UI.DataField', Value: DESCR }
        ]
    }
);

annotate workconfiguration.WorkParentTypes with @(    
    UI: {
        HeaderInfo: {
            TypeName      : 'Work parent type',
            TypeNamePlural: 'Work parent types',
            Title         : {
                $Type: 'UI.DataField',
                Value: name
            }
        },
        LineItem: [
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: name },
            { $Type: 'UI.DataField', Value: descr }
        ],
        SelectionFields: [
            ID,
            name,
            descr
        ],
        FieldGroup #data : {
            $Type : 'UI.FieldGroupType',
            Label : '{i18n>data}',
            Data  : [
                { $Type : 'UI.DataField', Value : ID },
                { $Type : 'UI.DataField', Value : name },
                { $Type : 'UI.DataField', Value : descr },
            ]
        },
        Facets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#data' , Label : '{i18n>data}' },
            { $Type : 'UI.ReferenceFacet', Target : 'translations/@UI.LineItem' , Label : '{i18n>translations}' },
        ]
    }
);

annotate workconfiguration.MasterObjectives with @(    
    UI: {
        HeaderInfo: {
            TypeName      : 'Objective',
            TypeNamePlural: 'Objectives',
            Title         : {
                $Type: 'UI.DataField',
                Value: name
            }
        },
        LineItem       : [
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: name },
            { $Type: 'UI.DataField', Value: descr }
        ],
        SelectionFields: [
            ID,
            name,
            descr
        ],
        FieldGroup #data : {
            $Type : 'UI.FieldGroupType',
            Label : '{i18n>data}',
            Data  : [
                { $Type : 'UI.DataField', Value : ID },
                { $Type : 'UI.DataField', Value : name },
                { $Type : 'UI.DataField', Value : descr },
            ]
        },
        Facets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#data' , Label : '{i18n>data}' },
            { $Type : 'UI.ReferenceFacet', Target : 'translations/@UI.LineItem' , Label : '{i18n>translations}' },
        ]
    }
);

annotate workconfiguration.MasterObjectivesTexts with @(    
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: LOCALE },
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: NAME },
            { $Type: 'UI.DataField', Value: DESCR }
        ]
    }
);

annotate workconfiguration.WorkConfigs with @(
    UI: {
        HeaderInfo: {
            TypeName      : 'Work configuration',
            TypeNamePlural: 'Work configurations',
            Title         : {
                $Type: 'UI.DataField',
                Value: description
            }
        },
        LineItem       : [
            { $Type: 'UI.DataField', Value: description }
        ],
        SelectionFields: [
            description
        ],
        Facets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#data' , Label : '{i18n>data}' },
            { $Type : 'UI.ReferenceFacet', Target : 'FlowsPerProcess/@UI.LineItem' , Label : '{i18n>FlowsPerProcess}' },
            { $Type : 'UI.ReferenceFacet', Target : 'Objectives/@UI.LineItem' , Label : '{i18n>Objectives}' },
            { $Type : 'UI.ReferenceFacet', Target : 'Documents/@UI.LineItem' , Label : '{i18n>Documents}' },
            { $Type : 'UI.ReferenceFacet', Target : 'DocumentDefaults/@UI.LineItem' , Label : '{i18n>DocumentDefaults}' }
        ],
        FieldGroup #data : {
            $Type : 'UI.FieldGroupType',
            Label : '{i18n>data}',
            Data : [
                { $Type : 'UI.DataField', Value : description }
            ]
        }
    }
);

annotate workconfiguration.FlowsPerProcess with @(
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: processFlowId },
            { $Type: 'UI.DataField', Value: phaseTypeId },
            { $Type: 'UI.DataField', Value: blockTypeId },
            { $Type: 'UI.DataField', Value: default },
            { $Type: 'UI.DataField', Value: Type_ID }
        ]
    }
) {
    Type @(
        Common: {
            Text : Type.name,
            TextArrangement: #TextLast,
            ValueListProperty,
            ValueList: {
                CollectionPath : 'WorkTypes',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'ID', LocalDataProperty : Type_ID },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            }
        }
    )
};

annotate workconfiguration.Objectives with @(
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: objective_ID }
        ]
    }
) {
    objective @(
        Common: {
            ValueListWithFixedValues,
            ValueList : {
                CollectionPath : 'MasterObjectives',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'ID', LocalDataProperty : objective_ID },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            },
        }
    );
};

annotate workconfiguration.Documents with @(
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: WorkType_ID },
            { $Type: 'UI.DataField', Value: documentId }
        ]
    }
);

annotate workconfiguration.DocumentDefaults with @(
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: documentId },
            { $Type: 'UI.DataField', Value: approverType },
            { $Type: 'UI.DataField', Value: externalType },
            { $Type: 'UI.DataField', Value: subcontractorValidationReq },
            { $Type: 'UI.DataField', Value: cellnexValidationReq },
            { $Type: 'UI.DataField', Value: customerValidationReq },
            { $Type: 'UI.DataField', Value: landlordValidationReq },
            { $Type: 'UI.DataField', Value: default }
        ]
    }
) {
    approverType @(
        Common: {
            ValueListWithFixedValues,
            Text                    : approverTypeName,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'ApproverTypes',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: approverType },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
                ]
            },
            FieldControl            : responsibleFC
        }
    );
    externalType @(
        Common: {
            ValueListWithFixedValues,
            Text           : subcoTypeName,
            TextArrangement: #TextFirst,
            ValueList      : {
                CollectionPath: 'SubcoTypes',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: externalType },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
                ]
            },
            FieldControl   : externalTypeFC
        }
    );
};
