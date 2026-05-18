using {project} from './service';

annotate project.Works {
    status @(
        Common: {
            ValueListWithFixedValues,
            ValueList :  {
                CollectionPath : 'Status',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'ID', LocalDataProperty : status },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            },
            FieldControl : statusFC
        }
    );
    type @(
        Common: {
            Text : LocalizedWorkTypesName.name,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList : {
                CollectionPath : 'LocalizedWorkTypes',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'code', LocalDataProperty : type_ID },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            },
            FieldControl : typeFC,
        }
    );
    responsibleType @(
        Common: {
            ValueListWithFixedValues,
            Text           : responsibleTypeName,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'ApproverTypes',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: responsibleType },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
                ]
            },
            FieldControl            : responsibleTypeFC
        }
    );
    externalType @(
        Common: {
            ValueListWithFixedValues,
            Text           : externalTypeName,
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
    internalResponsible @(Common: {
        Text: internalResponsibleName,
        TextArrangement: #TextFirst,
        ValueList: {
            CollectionPath : 'InternalUsers',
            Parameters : [
                { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'userId', LocalDataProperty: internalResponsible },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'userName' },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'email' },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'telephone' }
            ]
        },
        FieldControl : internalResponsibleFC,
    });
    externalResponsible @(Common: {
        ValueListWithFixedValues,
        Text: externalResponsibleName,
        TextArrangement: #TextFirst,
        ValueList: {
            CollectionPath: 'ExternalUsers',
            Parameters    : [
                { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: externalResponsible },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                { $Type: 'Common.ValueListParameterIn', ValueListProperty: 'blockId', LocalDataProperty: ID },
                { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'objectType', Constant: 'work' }
            ]
        },
        FieldControl : externalResponsibleFC,
    });
    description @(UI.MultiLineText : true, Common.FieldControl: descriptionFC );
    startDate @(Common.FieldControl: startDateFC);
    endDate @(Common.FieldControl: endDateFC);
    expectedStartDate @(Common.FieldControl: expectedStartDateFC);
    expectedEndDate @(Common.FieldControl: expectedEndDateFC);
    realStartDate @(Common.FieldControl: realStartDateFC);
    realEndDate @(Common.FieldControl: realEndDateFC);
    comments @(UI.MultiLineText : true, Common.FieldControl: commentsFC);
    documentId @(
        Common: {
            ValueListWithFixedValues,
            ValueList: {
                CollectionPath : 'WorkDocuments',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'ID', LocalDataProperty : documentId },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' },
                    { $Type : 'Common.ValueListParameterIn', LocalDataProperty: ID }
                ]
            }
        }
    );
} actions {
    addDocumentPerBlock(
        documentId @(
            Common: {
                ValueListWithFixedValues,
                ValueList: {
                    CollectionPath : 'WorkDocuments',
                    Parameters : [
                        { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'ID', LocalDataProperty : documentId },
                        { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' },
                        { $Type : 'Common.ValueListParameterIn', LocalDataProperty: ID }
                    ]
                }
            }
        )
    )
}

annotate project.ProjectObjectives with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    ID @(
        Common: {
            Text: name,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.ProjectObjectivesCountry with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]
) {
    ID @(
        Common: {
            Text: name,
            TextArrangement: #TextFirst
        }
    );
};

annotate project.LocalizedWorkTypes with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: name}]    
) {
    code @(
        Common: {
            Text: name,
            TextArrangement: #TextFirst
        }
    )
};
