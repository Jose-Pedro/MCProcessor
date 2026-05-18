using {project} from './service';

annotate project.DocumentsPerBlocks {
    responsibleId             @(Common: {
        ValueListWithFixedValues,
        Text                    : approverTypeName,
        Text.@UI.TextArrangement: #TextFirst,
        ValueList               : {
            CollectionPath: 'ApproverTypes',
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
    subcontractorId           @(Common: {
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
    responsibleDefault        @(Common: {FieldControl: 0});
    cellnexResponsible        @(Common: {
        Text           : cellnexResponsibleName,
        TextArrangement: #TextFirst,
        ValueList   : {
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
        FieldControl: cellnexResponsibleFC
    });
    agencyResponsible         @(Common: {
        ValueListWithFixedValues: true,
        Text                    : agencyResponsibleName,
        TextArrangement         : #TextFirst,
        ValueList               : {
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
        FieldControl            : agencyResponsibleFC
    }); 
    subcontractorResponsible  @(Common: {
        Text                    : subcontractorResponsibleName,
        TextArrangement         : #TextFirst,
        ValueList               : {
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
        FieldControl            : subcontractorResponsibleFC
    });
    customerResponsible       @(Common: {
        Text           : customerResponsibleName,
        TextArrangement: #TextFirst,
        FieldControl   : customerResponsibleFC
    });
    documentId                @(Common: {
        ValueListWithFixedValues,
        Text        : documentNameVF,
        ValueList   : {
            CollectionPath: 'DocumentFlowDocumentId',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'documentId',
                    LocalDataProperty: documentId
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'ID',
                    LocalDataProperty: ID
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'documentName'
                }
            ]
        },
        FieldControl: documentIdFC
    });
    cellnexValidationVF       @(Common: {FieldControl: cellnexValidationFC});
    subcontractorValidationVF @(Common: {FieldControl: subcontractorValidationFC});
    customerValidationVF      @(Common: {FieldControl: customerValidationFC});
    siteOwnerValidationVF     @(Common: {FieldControl: siteOwnerValidationFC});
}

annotate project.InstancesPerDocuments {
    contactPhone                @(Common: {FieldControl: contactPhoneFC});
    contactEmail                @(Common: {FieldControl: contactEmailFC});
    endDate                     @(Common: {FieldControl: endDateFC});
    startDate                   @(Common: {FieldControl: startDateFC});
    expectedSubmissionDate      @(Common: {FieldControl: expectedSubmissionDateFC});
    submissionDate              @(Common: {FieldControl: submissionDateFC});
    expirationDate              @(Common: {FieldControl: expirationDateFC});
    customerInformDate          @(Common: {FieldControl: customerInformDateFC});
    cellnexComment              @(Common: {FieldControl: cellnexValidationCommentsFC});
    subcontractorComment        @(Common: {FieldControl: subcontractorValidationCommentsFC});
    customerComment             @(Common: {FieldControl: customerValidationCommentsFC});
    siteOwnerComment            @(Common: {FieldControl: siteOwnerValidationCommentsFC});
    cellnexValidationDate       @(Common: {FieldControl: cellnexValidationDateFC});
    subcontractorValidationDate @(Common: {FieldControl: subcontractorValidationDateFC});
    customerValidationDate      @(Common: {FieldControl: customerValidationDateFC});
    siteOwnerValidationDate     @(Common: {FieldControl: siteOwnerValidationDateFC});
    cellnexValidator            @(Common: {FieldControl: cellnexValidatorFC});
    subcontractorValidator      @(Common: {FieldControl: subcontractorValidatorFC});
    customerValidator           @(Common: {FieldControl: customerValidatorFC});
    siteOwnerValidator          @(Common: {FieldControl: siteOwnerValidatorFC});
    cellnexValidation           @(Common: {FieldControl: cellnexValidationFC});
    subcontractorValidation     @(Common: {FieldControl: subcontractorValidationFC});
    customerValidation          @(Common: {FieldControl: customerValidationFC});
    siteOwnerValidation         @(Common: {FieldControl: siteOwnerValidationFC});
    buttonCompleteVF            @(Common: {FieldControl: buttonCompleteFC});
    customerValidation          @(Common: {
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'ValidationDocs',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: customerValidation
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }

    });
    cellnexValidation           @(Common: {
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'ValidationDocs',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: cellnexValidation
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }

    });
    siteOwnerValidation         @(Common: {
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'ValidationDocs',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: siteOwnerValidation
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }

    });
    subcontractorValidation     @(Common: {
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'ValidationDocs',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: subcontractorValidation
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }

    });
    customerValidator           @(Common: {ValueList: {
        Text           :customerValidatorName,
        CollectionPath: 'InternalUsers',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                ValueListProperty: 'userId',
                LocalDataProperty: customerValidator
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'userName'
            }
        ]
    }});
    cellnexValidator            @(Common: {ValueList: {
        Text           :cellnexValidatorName,
        CollectionPath: 'InternalUsers',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                ValueListProperty: 'userId',
                LocalDataProperty: cellnexValidator
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'userName'
            }
        ]
    }});
    siteOwnerValidator          @(Common: {
        ValueListWithFixedValues,
        Text           : siteOwnerValidatorName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'DocumentFlowResponsiblesCellnex',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: siteOwnerValidator
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'ID',
                    LocalDataProperty: ID
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }

    });
    subcontractorValidator      @(Common: {
        Text           :subcontractorValidatorName,
        TextArrangement: #TextFirst,
        ValueList: {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'PreferredProviders',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: subcontractorValidator,
                    ValueListProperty: 'code'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });

// requestCodeOrigin       @(Common: {
}
