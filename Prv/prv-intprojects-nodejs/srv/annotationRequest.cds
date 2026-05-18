using { project } from './service';

annotate project.Requests {
    siteId @(
        Common: {
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'Sites',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : siteId, ValueListProperty : 'siteId' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'legacyCode' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'siteName' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'company' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'cellnexZone' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'legacyCode' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'siteName' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'company' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'cellnexZone' }
                ]
            },
            FieldControl : siteIdFC,
        }
    );
    requestType @(
        Common: {
            Text : RequestTypes.REQUEST_TYPE_DESC,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'RequestTypes',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : requestType, ValueListProperty : 'REQUEST_TYPE' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'REQUEST_TYPE_DESC' }
                ]
            },
            FieldControl : requestTypeFC,
        }
    );
    // classification @(
    //     Common: {
    //         ValueListWithFixedValues,
    //         ValueList: {
    //             CollectionPath: 'Classifications',
    //             Parameters    : [
    //                 {
    //                     $Type            : 'Common.ValueListParameterInOut',
    //                     ValueListProperty: 'code',
    //                     LocalDataProperty: classification
    //                 },
    //                 {
    //                     $Type            : 'Common.ValueListParameterDisplayOnly',
    //                     ValueListProperty: 'name'
    //                 }
    //             ]
    //         },
    //         FieldControl : classificationFC,
    //     }
    // );
    manager @(
        Common: {
            Text : Managers.userName,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'Managers',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : manager, ValueListProperty : 'userId' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'userName' }
                ]
            },
            FieldControl : managerFC
        },
    );
    requestedDate    @(Common.FieldControl : requestedDateFC);
    
    preferredProvider @(
        Common: {            
            Text           : PreferredProviders.name,
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'PreferredProviders',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : preferredProvider, ValueListParameterInOut : 'code' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            }
        }
    );
    projectObjective @(
        Common: {
            Text: ProjectObjectives.name,
            ValueListWithFixedValues,
            ValueList: {
                CollectionPath: 'ProjectObjectives',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterIn',
                        ValueListProperty: 'PROGRAM',
                        LocalDataProperty: creationConfig
                    },
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'ID',
                        LocalDataProperty: projectObjective
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    }
                ]
            },
            FieldControl : projectObjectiveFC,
        }
    );
    documentId       @(
        title : '{i18n>documentId}',
        Common: {
            ValueListWithFixedValues,
            // Text: candidateDescription,
            ValueList: {
                CollectionPath: 'DocumentFlowDefaultValidDocumentId',
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
            }
        }
    );
    onHoldReason     @(
        Common: {
            ValueListWithFixedValues,
            Text           : OnHoldReasons.name,
            TextArrangement: #TextFirst,
            ValueList      : {
                CollectionPath: 'OnHoldReasons',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: onHoldReason },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
                ]
            }
        }
    );
    cancellationReason      @(
        Common: {
            ValueListWithFixedValues,
            Text           : CancellationReasons.name,
            TextArrangement: #TextFirst,
            ValueList      : {
                CollectionPath: 'CancellationReasons',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: cancellationReason },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
                ]
            }
        }
    );
    createdAt        @(Common.FieldControl: createdAtFC );
    description      @(Common.FieldControl: descriptionFC );
    onHoldComments          @(title: '{i18n>Comments}',  UI.MultiLineText);
    cancellationComments    @(title: '{i18n>Comments}',  UI.MultiLineText);
}
    
annotate project.RequestProvision {
    requester @(
        Common: {
            Text : Requesters.userName,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'Requesters',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : requester, ValueListProperty : 'userId' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'userName' }
                ]
            },
            FieldControl : requesterFC,
        }
    );
    preferredProvider @(
        Common: {
            Text : preferredProviderName,
            TextArrangement : #TextFirst,
            ValueList : {
                CollectionPath : 'PreferredProviders',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : preferredProvider, ValueListProperty : 'code' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name'}
                ]
            },
            FieldControl : preferredProviderFC,
        }
    );
    classification @(
        Common: {
            Text : Classifications.name,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList: {
                CollectionPath: 'Classifications',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'code',
                        LocalDataProperty: classification
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    }
                ]
            },
            FieldControl : classificationFC,
        }
    );
    projectObjective @(
        Common: {
            Text: ProjectObjectives.name,
            ValueListWithFixedValues,
            ValueList: {
                CollectionPath: 'ProjectObjectives',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'ID',
                        LocalDataProperty: projectObjective
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    }
                ]
            },
            FieldControl : projectObjectiveFC,
        }
    );
    PMOManager @(
        Common: {
            Text : PMOManagers.userName,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList: {
                $Type : 'Common.ValueListType',
                CollectionPath: 'PMOManagers',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'userId',
                        LocalDataProperty: PMOManager
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'userName'
                    }
                ]
            },
            FieldControl : PMOManagerFC,
        }
    );
    moaOperation             @(
        Common: {
            Text : RepaymentStatus.name,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList: {
                CollectionPath: 'MoaOperationTypes',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'code',
                        LocalDataProperty: moaOperation
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    }
                ]
            },
            FieldControl: moaOperationFC
        }
    );
    requestedDate @(Common.FieldControl: requestedDateFC );
    preferredProviderName @(Common.FieldControl: 1 );
}

annotate project.RequestDocumentsPerBlockDefaultValid {
    responsibleId   @(Common: {
        ValueListWithFixedValues,        
        Text                    : approverTypeName,
        Text.@UI.TextArrangement: #TextFirst,
        ValueList: {
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
    subcontractorId @(Common: {
        ValueListWithFixedValues,
        
        Text                    : subcoTypeName,
        Text.@UI.TextArrangement: #TextFirst,
        ValueList: {
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
    responsibleDefault      @(Common: {
        // ValueListWithFixedValues,
        // Text           : responsibleDefaultName,
        // TextArrangement: #TextFirst,
        // ValueList      : {
        //     CollectionPath: 'DocumentFlowResponsiblesDefaultValid',
        //     Parameters    : [
        //         {
        //             $Type            : 'Common.ValueListParameterInOut',
        //             ValueListProperty: 'code',
        //             LocalDataProperty: responsibleDefault
        //         },
        //         {
        //             $Type            : 'Common.ValueListParameterIn',
        //             ValueListProperty: 'ID',
        //             LocalDataProperty: ID
        //         },
        //         {
        //             $Type            : 'Common.ValueListParameterDisplayOnly',
        //             ValueListProperty: 'name'
        //         }
        //     ]
        // },
        FieldControl   : 0
    });
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
    documentId      @(
        title : '{i18n>documentId}',
        Common: {
            ValueListWithFixedValues,
            Text: documentNameVF,
        FieldControl: #ReadOnly
        }
    );
    subcontractorValidation @(Common: {FieldControl: subcontractorValidationFC});
    cellnexValidation @(Common: {FieldControl: cellnexValidationFC});
    customerValidation @(Common: {FieldControl: customerValidationFC});
    siteOwnerValidation @(Common: {FieldControl: siteOwnerValidationFC});
    
}
