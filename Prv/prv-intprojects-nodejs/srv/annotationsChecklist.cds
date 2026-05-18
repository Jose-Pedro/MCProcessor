using { project } from './service';

annotate project.ChecklistItems with {
    type @(Common: {
        Text : type.description,
        TextArrangement : #TextOnly,
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'ItemTypes',
            Parameters: [
                { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: 'type_ID', ValueListProperty: 'ID' },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'description' }
            ]
        }
    });
    description @(Common.FieldControl : descriptionFC);
    booleanValue @(Common.FieldControl : booleanValueFC);
    dateValue @(Common.FieldControl : dateValueFC);
    stringValue @(Common.FieldControl : stringValueFC);
    integerValue @(Common.FieldControl : integerValueFC);
    decimalValue @(Common.FieldControl : decimalValueFC);
    pickList @(
        Common: {
            Text : picklistValueName,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList: {
                CollectionPath: 'ItemTypeValues',
                Parameters: [
                    { $Type: 'Common.ValueListParameterIn', LocalDataProperty: type_ID, ValueListProperty: 'itemType_ID' },
                    { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: pickList, ValueListProperty: 'pickList' },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'description' }
                ]
            },
            FieldControl : pickListFC,
        }
    );
};

annotate project.ItemTypeValues with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: description}]
) {
    pickList @(Common.Text: description);
}

annotate project.ItemTypes with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: description}]
) {
    ID @(Common.Text: description);
}