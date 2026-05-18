using {project} from './service';

annotate project.Blocks {
    openAt                @(Common: {FieldControl: openAtFC});
    comments    @(
        UI    : {MultiLineText},
        Common: {FieldControl: commentsFC}
    );
    commentsPLU @(
        UI    : {MultiLineText},
        Common: {FieldControl: commentsPLUFC}
    );
    documentId  @(
        Common: {
            ValueListWithFixedValues,
            ValueList: {                
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
            }
        }
    );
}

annotate project.BlockProvision {
    acceptedDate                @(Common: {FieldControl: acceptedDateFC});
    accepted                    @(
        Common: {
            ValueListWithFixedValues: true,
            Text: AcceptedRejected.name,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'AcceptedRejected',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: accepted},
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            },
            FieldControl: acceptedFC
        }
    );
    activationReason            @(Common: {FieldControl: activationReason});
    adaptionsType               @(Common: {
        ValueListWithFixedValues,
        Text: AdaptionsTypes.name,
        TextArrangement: #TextFirst,
        ValueList: {
            CollectionPath: 'AdaptionsTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: adaptionsType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl : adaptionsTypeFC,
    });
    amount                      @(Common: {FieldControl: amountFC});
    assignedResponsible         @(
        Common: {
            ValueListWithFixedValues,
            Text: ApproverTypes.name,
            TextArrangement: #TextFirst,
            ValueList   : {
                CollectionPath: 'ApproverTypes',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'code',
                        LocalDataProperty: assignedResponsible
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    }
                ]
            },
            FieldControl: assignedResponsibleFC
        }
    );
    automaticManualResponse     @(
        Common: {
            ValueListWithFixedValues,
            Text: AutomaticManualResponses.name,
            TextArrangement: #TextFirst,
            ValueList: {
                CollectionPath : 'AutomaticFields',
                Parameters :
                [
                    { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'code', LocalDataProperty : automaticManualResponse },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            }
        }
    );
    currency                    @(Common: {
        IsCurrency,
        ValueListWithFixedValues,
        Text           : Currencies.name,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'Currencies',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: currency
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl   : currencyFC
    });
    completedDate               @(Common: {FieldControl: completedDateFC});
    completedBy                 @(Common: {FieldControl: completedByFC});
    complexity                  @(
        Common: {
            ValueListWithFixedValues: true,
            Text: Complexities.name,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'Complexities',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: complexity },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            },            
            FieldControl: complexityFC
        }
    );
    debtor                      @(Common: {FieldControl: debtorFC});
    expectedDate                @(Common: {FieldControl: expectedDateFC});
    expectedEndDate             @(Common: {FieldControl: expectedEndDateFC});
    expectedStartDate           @(Common: {FieldControl: expectedStartDateFC}); 
    expectedMadDate             @(Common: {FieldControl: expectedMadDateFC});
    externalResponsible         @(Common: {                
        ValueListWithFixedValues: true,        
        // Text                    : ExternalUsers.name,
        // TextArrangement         : #TextFirst,
        ValueList               : {
            CollectionPath: 'ExternalUsers',
            Parameters    : [
                { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: externalResponsible },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                { $Type: 'Common.ValueListParameterIn', ValueListProperty: 'blockId', LocalDataProperty: ID },
                { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'objectType', Constant: 'block' }
            ]
        },
        FieldControl            : externalResponsibleFC
    });
    estimatedPaymentDate        @(Common: {FieldControl: estimatedPaymentDateFC});
    readyToStartWorksDate        @(Common: {FieldControl: readyToStartWorksDateFC});
    globalEndWorksDate          @(Common: {FieldControl: globalEndWorksDateFC});
    globalStartWorksDate        @(Common: {FieldControl: globalStartWorksDateFC});
    infraMadDate                 @(Common: {FieldControl: infraMadDateFC});
    internalResponsible         @(Common: {
        ValueListWithFixedValues: true,
        //Text           : internalResponsibleName,
        //TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'InternalUsers',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'userId',
                    LocalDataProperty: internalResponsible
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'userName'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'email'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'telephone'
                }
            ]
        },
        FieldControl   : internalResponsibleFC
    });
    kickOffEstimatedVisitDate   @(Common: {FieldControl: kickOffEstimatedVisitDateFC});
    kickOffRealDate             @(Common: {FieldControl: kickOffRealDateFC});
    kickOffVisitNeeded          @(
        Common: {
            ValueListWithFixedValues: true,
            Text: KickOffVisitNeeded.name,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'YesNoFields',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: kickOffVisitNeeded},
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            },
            FieldControl: kickOffVisitNeededFC
        }
    );
    heritageEndDate             @(Common: {FieldControl: heritageEndDateFC});    
    madResult                   @(
        Common: {
            Text                    : MadResults.name,
            TextArrangement         : #TextFirst,
            ValueListWithFixedValues,
            ValueList               : {
                CollectionPath: 'MadResults',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: madResult },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
                ]
            },            
            FieldControl: madResultFC
        }
    );
    permitsFeasibilityExp                    @(
        Common: {
            ValueListWithFixedValues: true,
            Text: PermitsFeasibilityExplanations.name,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'FeasibilityExplanations',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: permitsFeasibilityExp},
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            },
            FieldControl: permitsFeasibilityExpFC
        }
    );
    permitsFeasibility          @(Common: {
        ValueListWithFixedValues,
        Text           : PermitsFeasibilities.name,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'FeasibilitiesWithRisks',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: permitsFeasibility
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl   : permitsFeasibilityFC
    });
    permitsNeeded               @(Common: {
            ValueListWithFixedValues,
            Text: PermitsNeeded.name,
            TextArrangement: #TextFirst,
            ValueList: {
                CollectionPath : 'AdaptionsNeededFields',
                Parameters :
                [
                    { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'code', LocalDataProperty : permitsNeeded },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            },
            FieldControl: permitsNeededFC
        }
    );
    plannedDate                 @(Common: {FieldControl: plannedDateFC});
    plannedKickoffDate          @(Common: {FieldControl: plannedKickoffDateFC});
    realEndDate                 @(Common: {FieldControl: realEndDateFC});
    realStateFeasibility        @(Common: {
        ValueListWithFixedValues,
        Text           : RealStateFeasibilities.name,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'FeasibilitiesWithRisks',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: realStateFeasibility
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl   : realStateFeasibilityFC
    });
    realEstateFeasibilityExp                    @(
        Common: {
            ValueListWithFixedValues: true,
            Text: RealStateFeasibilityExplanations.name,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'FeasibilityExplanations',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: realEstateFeasibilityExp},
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            },
            FieldControl: realEstateFeasibilityExpFC
        }
    );
    realStateFeasibilityRisk    @(Common: {
        ValueListWithFixedValues,
        Text           : RealStateRisks.name,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'Risks',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: realStateFeasibilityRisk
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl   : realStateFeasibilityRiskFC
    });
    realStartDate               @(Common: {FieldControl: realStartDateFC});
    renegoNeeded                @(Common: {
        Text           : RenegoNeeded.name,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath : 'AdaptionsNeededFields',
            Parameters :
            [
                { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'code', LocalDataProperty : renegoNeeded },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
            ]
        },
        FieldControl: renegoNeededFC
    });
    rejectionReason             @(
        Common: {
            ValueListWithFixedValues,
            Text: RejectionReasons.name,
            TextArrangement: #TextFirst,
            ValueList: {
                CollectionPath : 'RejectionReasons',
                Parameters :
                [
                    { $Type : 'Common.ValueListParameterInOut', ValueListProperty : 'code', LocalDataProperty : rejectionReason },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
                ]
            },
            FieldControl: rejectionReasonFC
        }
    ); 
    sendOfferDate               @(Common: {FieldControl: sendOfferDateFC});
    siteSurveyDate              @(Common: {FieldControl: siteSurveyDateFC});
    startDate                   @(Common: {FieldControl: startDateFC});
    repaymentStatus             @(
        Common: {
            Text : RepaymentStatus.name,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList: {
                CollectionPath: 'RepaymentStatus',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'code',
                        LocalDataProperty: repaymentStatus
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    }
                ]
            },
            FieldControl: repaymentStatusFC
        }
    );
    subcontractorType           @(
        Common: {
            ValueListWithFixedValues,
            Text: SubcoTypes.name,
            TextArrangement: #TextFirst,
            ValueList   : {
                CollectionPath: 'SubcoTypes',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'code',
                        LocalDataProperty: subcontractorType
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    }
                ]
            },
            FieldControl: subcontractorTypeFC
        }
    );
    siteSurveyWillBeNeeded      @(
        Common: {
            Text : SiteSurveyNeeded.name,
            TextArrangement : #TextFirst,
            ValueListWithFixedValues,
            ValueList: {
                CollectionPath: 'YesNoFields',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'code',
                        LocalDataProperty: siteSurveyWillBeNeeded
                    },
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    }
                ]
            },
            FieldControl : siteSurveyWillBeNeededFC,
        }
    );
    totalCost                   @(Common: {FieldControl: totalCostFC});
    totalCostClient             @(Common: {FieldControl: totalCostClientFC});
}

annotate project.BlocksResponsibles with @(UI: {LineItem: [
    { $Type: 'UI.DataField', Value: phaseProcessFlowId },
    { $Type: 'UI.DataField', Value: blockProcessFlowId},
    { $Type: 'UI.DataField', Value: approverType },
    { $Type: 'UI.DataField', Value: subcoType, ![@Common.FieldControl]: subcoTypeFC },
    { $Type: 'UI.DataField', Value: externalResponsible, ![@Common.FieldControl]: subcoTypeFC },
    { $Type: 'UI.DataField', Value: internalResponsible }
]}) {
    phaseProcessFlowId  @(
        Common: {
            Text           : phaseName,
            TextArrangement: #TextFirst
        },
        readonly
    );
    blockProcessFlowId  @(
        Common: {
            Text           : blockName,
            TextArrangement: #TextFirst
        },
        readonly
    );
    approverType        @(Common: {
        ValueListWithFixedValues,
        Text                    : ApproverTypes.name,
        Text.@UI.TextArrangement: #TextFirst,
        ValueList               : {
            CollectionPath: 'ApproverTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: approverType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl            : approverTypeFC
    });
    subcoType           @(Common: {
        ValueListWithFixedValues: true,
        Text                    : SubcoTypes.name,
        TextArrangement         : #TextFirst,
        ValueList               : {
            CollectionPath: 'SubcoTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: subcoType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        FieldControl            : subcoTypeFC
    });
    internalResponsible @(Common: {
        ValueListWithFixedValues: true,
        Text           : internalResponsibleName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'InternalUsers',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'userId',
                    LocalDataProperty: internalResponsible
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'userName'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'email'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'telephone'
                }
            ]
        },
        FieldControl   : internalResponsibleFC
    });
    externalResponsible @(Common: {                
        ValueListWithFixedValues: true,        
        Text                    : externalResponsibleName,
        TextArrangement         : #TextFirst,
        ValueList               : {
            CollectionPath: 'ExternalUsers',
            Parameters    : [
                { $Type: 'Common.ValueListParameterInOut', ValueListProperty: 'code', LocalDataProperty: externalResponsible },
                { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                { $Type: 'Common.ValueListParameterIn', ValueListProperty: 'blockId', LocalDataProperty: ID },
                { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'objectType', Constant: 'block' }
            ]
        },
        FieldControl            : externalResponsibleFC
    });
}
