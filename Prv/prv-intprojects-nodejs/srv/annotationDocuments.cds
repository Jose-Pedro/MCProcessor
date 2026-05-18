using {project} from './service';

annotate project.DocumentFlowDocumentId with @(
    cds.odata.valuelist,
    UI.Identification: [{Value: documentName}]
) {
    documentId @(Common.Text: documentName );
    ID @(UI.HiddenFilter: true);    
}

// annotate project.DocumentsPerProcess with @(
//     cds.odata.valuelist, 
//     UI.Identification: [{Value: documentName}] 
// )


annotate project.DocumentsPerRequest  {
    responsibleId           @(Common: {
        ValueListWithFixedValues,
        Text                    : approverTypeName,
        Text.@UI.TextArrangement: #TextFirst,
        ValueList               : {
            CollectionPath: 'ApproverTypes',
            //NOSONAR Criticality : 1
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: responsibleId
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl            : approverTypeFC
    });
    subcontractorId         @(Common: {
        ValueListWithFixedValues,
        Text           : subcoTypeName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'SubcoTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: subcontractorId
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl   : subcoTypeFC
    });
    responsibleDefault      @(Common: { FieldControl   : 0 });
    cellnexResponsible      @(Common: {
        // Text           : cellnexResponsibleName,
        // TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'InternalUsers',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'userId',
                    LocalDataProperty: cellnexResponsible
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'userName'
                }
            ]
        },
        FieldControl   : cellnexResponsibleFC
    });
    agencyResponsible      @(Common: {                
        ValueListWithFixedValues: true,        
        Text           : agencyResponsibleName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'CacheR3Entities',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: agencyResponsible
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                },
                {
                    $Type            : 'Common.ValueListParameterConstant',
                    ValueListProperty: 'entityType',
                    Constant         : 'F4_GEWRK_AGEN'
                }
            ]
        },
        FieldControl   : agencyResponsibleFC
    });
    subcontractorResponsible      @(Common: {        
        ValueListWithFixedValues: true,        
        Text           : subcontractorResponsibleName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'CacheR3Entities',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: subcontractorResponsible
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                },
                {
                    $Type            : 'Common.ValueListParameterConstant',
                    ValueListProperty: 'entityType',
                    Constant         : 'F4_PROV_VENDOR_GEWRK'
                }
            ]
        },
        FieldControl   : subcontractorResponsibleFC
    });
    customerResponsible      @(Common: {
        Text           : customerResponsibleName,
        TextArrangement: #TextFirst,
        FieldControl   : customerResponsibleFC
    });
    documentId              @(Common: {
        FieldControl: documentIdFC
    });
    phaseId                 @(Common: {
        ValueListWithFixedValues,
        // Text: candidateDescription,
        ValueList   : {
            CollectionPath: 'Phases',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: phaseId
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'requestId',
                    LocalDataProperty: requestId
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'processFlowId'
                }
            ]
        },
    });             
    blockId                 @(Common: {
        ValueListWithFixedValues,
        // Text: candidateDescription,
        ValueList   : {
            CollectionPath: 'Blocks',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: blockId
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'phaseId',
                    LocalDataProperty: phaseId
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'processFlowId'
                }
            ]
        },
    });
    cellnexValidationVF       @(Common: {FieldControl: cellnexValidationFC});
    subcontractorValidationVF @(Common: {FieldControl: subcontractorValidationFC});
    customerValidationVF      @(Common: {FieldControl: customerValidationFC});
    siteOwnerValidationVF     @(Common: {FieldControl: siteOwnerValidationFC});                
}