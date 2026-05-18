using { Checklist } from '../db/checklist';

@path: '/service/checklistconfiguration'
// @requires: 'authenticated-user'
service checklistconfiguration {

    entity FieldTypes as projection on Checklist.FieldType;
    entity FieldTypeTexts as projection on Checklist.FieldType.texts;
    entity ItemTypes as projection on Checklist.ItemType;
    entity ItemTypeTexts as projection on Checklist.ItemType.texts;
    entity ItemTypeValues as projection on Checklist.ItemTypeValue;
    entity ItemTypeValueTexts as projection on Checklist.ItemTypeValue.texts;
    entity ItemConfigurations as projection on Checklist.ItemConfiguration;
    entity ItemConfigurationTypes as projection on Checklist.ItemConfigurationType;
    entity ItemConfigurationProcesses as projection on Checklist.ItemConfigurationProcess;
    entity ItemConfigurationBlocks as projection on Checklist.ItemConfigurationBlock;

}

annotate checklistconfiguration.FieldTypes with @(    
    UI: {
        HeaderInfo: {
            TypeName      : 'Field type',
            TypeNamePlural: 'Field types',
            Title         : { $Type: 'UI.DataField', Value: name }
        },
        LineItem: [
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: name }
        ],  
        SelectionFields: [
            ID,
            name,
            descr
        ],
        Facets: [
            { $Type : 'UI.ReferenceFacet', Target : 'translations/@UI.LineItem', ID : 'Translations', Label : '{i18n>translations}', },
        ]
    }
);

annotate checklistconfiguration.FieldTypeTexts with @(
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: locale },
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: name },
            { $Type: 'UI.DataField', Value: descr }
        ]
     }
);

annotate checklistconfiguration.ItemTypes with @(    
    UI: {
        HeaderInfo: {
            TypeName      : 'Item types',
            TypeNamePlural: 'Item types',
            Title         : { $Type: 'UI.DataField', Value: description }
        },
        LineItem: [
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: description },
            { $Type: 'UI.DataField', Value: active },
            { $Type: 'UI.DataField', Value: valueType.ID },
            { $Type: 'UI.DataField', Value: defaultBoolean },
            { $Type: 'UI.DataField', Value: defaultString },
            { $Type: 'UI.DataField', Value: defaultDate },
            { $Type: 'UI.DataField', Value: defaultInteger },
            { $Type: 'UI.DataField', Value: defaultDecimal },
            { $Type: 'UI.DataField', Value: defaultPickList }
        ],
        SelectionFields: [
            ID,
            description,
            active,
            valueType.ID,
            defaultBoolean,
            defaultString,
            defaultDate,
            defaultInteger,
            defaultDecimal,
            defaultPickList
        ],
        FieldGroup #data : { 
            $Type : 'UI.FieldGroupType',
            Label : '{i18n>data}',
            Data : [
                { $Type : 'UI.DataField', Value : active },
                { $Type : 'UI.DataField', Value : valueType.ID },
                { $Type : 'UI.DataField', Value : defaultBoolean },
                { $Type : 'UI.DataField', Value : defaultString },
                { $Type : 'UI.DataField', Value : defaultDate },
                { $Type : 'UI.DataField', Value : defaultInteger },
                { $Type : 'UI.DataField', Value : defaultDecimal },
                { $Type : 'UI.DataField', Value : defaultPickList }
            ]
        },
        Facets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#data' , Label : '{i18n>data}' },
            { $Type : 'UI.ReferenceFacet', Target : 'values/@UI.LineItem' , Label : '{i18n>itemTypeValues}' },
            { $Type : 'UI.ReferenceFacet', Target : 'translations/@UI.LineItem' , Label : '{i18n>translations}' }
        ]
    }
);

annotate checklistconfiguration.ItemTypeTexts with @(    
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: locale },
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: description }
        ]
    }
);

annotate checklistconfiguration.ItemTypeValues with @(    
    UI: {
        HeaderInfo: {
            TypeName      : 'Item type values',
            TypeNamePlural: 'Item type values',
            Title         : { $Type: 'UI.DataField', Value: description }
        },
        LineItem: [
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: description },
            { $Type: 'UI.DataField', Value: active },
            { $Type: 'UI.DataField', Value: booleanValue },
            { $Type: 'UI.DataField', Value: stringValue },
            { $Type: 'UI.DataField', Value: dateValue },
            { $Type: 'UI.DataField', Value: integerValue },
            { $Type: 'UI.DataField', Value: decimalValue },
            { $Type: 'UI.DataField', Value: pickList }
        ],
        SelectionFields: [
            ID,
            description,
            active,
            booleanValue,
            stringValue,
            dateValue,
            integerValue,
            decimalValue,
            pickList
        ],
        Facets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#data' , Label : '{i18n>data}' },
            { $Type : 'UI.ReferenceFacet', Target : 'translations/@UI.LineItem' , Label : '{i18n>translations}' },
        ],
        FieldGroup #data : {
            $Type : 'UI.FieldGroupType',
            Label : '{i18n>data}',
            Data  : [
                { $Type : 'UI.DataField', Value : active },
                { $Type : 'UI.DataField', Value : booleanValue },
                { $Type : 'UI.DataField', Value : stringValue },
                { $Type : 'UI.DataField', Value : dateValue },
                { $Type : 'UI.DataField', Value : integerValue },
                { $Type : 'UI.DataField', Value : decimalValue },
                { $Type : 'UI.DataField', Value : pickList }
            ]
        }
    }
);

annotate checklistconfiguration.ItemTypeValueTexts with @(    
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: locale },
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: description }
        ]
    }
);

annotate checklistconfiguration.ItemConfigurations with @(
    UI: {
        HeaderInfo: {
            TypeName      : 'Item configurations',
            TypeNamePlural: 'Item configurations',
            Title         : { $Type: 'UI.DataField', Value: description }
        },
        LineItem: [
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: description },
            { $Type: 'UI.DataField', Value: active }
        ],
        SelectionFields: [
            ID,
            description,
            active
        ],
        Facets: [
            { $Type : 'UI.ReferenceFacet', Target : 'processes/@UI.LineItem' , Label : '{i18n>processes}' },
            { $Type : 'UI.ReferenceFacet', Target : 'blocks/@UI.LineItem' , Label : '{i18n>blocks}' },
            { $Type : 'UI.ReferenceFacet', Target : 'types/@UI.LineItem' , Label : '{i18n>types}' },
        ]
    }    
);

annotate checklistconfiguration.ItemConfigurationTypes with @(
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: ID },
            { $Type: 'UI.DataField', Value: type_ID },
            { $Type: 'UI.DataField', Value: defaulted },
            { $Type: 'UI.DataField', Value: mandatory },
            { $Type: 'UI.DataField', Value: defaultBoolean },
            { $Type: 'UI.DataField', Value: defaultString },
            { $Type: 'UI.DataField', Value: defaultDate },
            { $Type: 'UI.DataField', Value: defaultInteger },
            { $Type: 'UI.DataField', Value: defaultDecimal },
            { $Type: 'UI.DataField', Value: defaultPickList },
            { $Type: 'UI.DataField', Value: beforeCreate },
            { $Type: 'UI.DataField', Value: afterUpdate },
            { $Type: 'UI.DataField', Value: afterRead },
            { $Type: 'UI.DataField', Value: refreshEntity },
            { $Type: 'UI.DataField', Value: order }        
        ]
    }    
);

annotate checklistconfiguration.ItemConfigurationProcesses with @(
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: processId }
        ]
    }    
);

annotate checklistconfiguration.ItemConfigurationBlocks with @(
    UI: {
        LineItem: [
            { $Type: 'UI.DataField', Value: phaseType },
            { $Type: 'UI.DataField', Value: blockType }
        ]
    }    
);
