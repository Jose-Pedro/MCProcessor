using {project} from './service';

annotate project.SearchByRequests with @(
    UI: {
        HeaderInfo     : {
            TypeName      : 'request',
            TypeNamePlural: 'requests',
            Title         : {
                $Type: 'UI.DataField',
                Value: code
            }
        },
        LineItem       : [
            { $Type: 'UI.DataField', Value: code },
            { $Type: 'UI.DataField', Value: status, Criticality: objectStatus },
            { $Type: 'UI.DataField', Value: projectType },
            { $Type: 'UI.DataField', Value: projectObjective },
            { $Type: 'UI.DataField', Value: complexity },
            { $Type: 'UI.DataField', Value: siteId },
            { $Type: 'UI.DataField', Value: siteName },
            { $Type: 'UI.DataField', Value: siteRegion },
            { $Type: 'UI.DataField', Value: siteCity },
            { $Type: 'UI.DataField', Value: siteLegacyCode },
            { $Type: 'UI.DataField', Value: manager },
            { $Type: 'UI.DataField', Value: preferredProvider },
            { $Type: 'UI.DataField', Value: requestedDate },
            { $Type: 'UI.DataField', Value: createdAt },
            { $Type: 'UI.DataField', Value: assignationDate }
        ],
        SelectionFields: [
            searchType,
            projectType,
            projectObjective,
            complexity,
            code,
            status,
            siteId,
            manager,
            preferredProvider,
            requestedDate,
        ]
    },
    Capabilities.FilterRestrictions: {
        FilterExpressionRestrictions: [{
            $Type             : 'Capabilities.FilterExpressionRestrictionType',
            Property          : searchType,
            AllowedExpressions: 'SingleValue'
        }],
        RequiredProperties          : [searchType]
    }
) {
    status            @(Common: {
        Text           : statusName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'RequestStatus',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: status
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
    manager @(Common: {
        Text           : managerName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'Managers',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'userId',
                    LocalDataProperty: manager
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'userName'
                }
            ]
        }
    });
    complexity        @(
        Common: {
            ValueListWithFixedValues: true,
            Text: complexityName,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'Complexities',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: complexity },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            }
    });
    siteId @(
        Common: {
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'Sites',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : siteId, ValueListProperty : 'siteId' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'siteName' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'legacyCode' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'primaryLegacyCode' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'siteName' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'legacyCode' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'primaryLegacyCode' },
                ]
            }
        }
    );
    preferredProvider             @(Common: {
        Text           : preferredProviderName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'PreferredProviders',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: preferredProvider
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                }
            ]
        }
    });
    searchType        @(Common: {
        FilterDefaultValue: 0,
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'SearchTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: searchType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
    projectType       @(Common: {
        Text           : projectTypeName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'AuxProjectTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: projectType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                }
            ]
        }
    });
    projectObjective       @(Common: {
        Text           : projectObjectiveName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'ProjectObjectivesCountry',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: projectObjective
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                }
            ]
        }
    });
    cellnexZone       @(Common: {
        Text           : cellnexZoneName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'CellnexZones',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: cellnexZone
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'description',
                }
            ]
        }
    });
    siteRegion      @(Common: {
        Text           : siteRegionName,
        TextArrangement: #TextFirst,
        // ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'Regions',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'country',
                    LocalDataProperty: country
                },
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: siteRegion
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'description',
                }
            ]
        }
    });
    lastBlock @(Common: {
        Text           : lastBlockName,
        TextArrangement: #TextOnly,
        ValueListWithFixedValues: true,
        ValueList: {
            CollectionPath: 'InternalBlocks',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: lastBlock
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'phaseId',
                    LocalDataProperty: lastPhase
                }
            ]
        }
    });
    lastPhase @(Common: {
        Text           : lastPhaseName,
        TextArrangement: #TextOnly,
        ValueListWithFixedValues: true,
        ValueList: {
            CollectionPath: 'InternalPhases',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: lastPhase
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
}

annotate project.SearchByTasks with @(
    UI                             : {
        HeaderInfo     : {
            TypeName      : 'Taks',
            TypeNamePlural: 'Tasks',
            Title         : {
                $Type: 'UI.DataField',
                Value: code
            }
        },
        LineItem       : [
            { $Type: 'UI.DataField', Value: code },
            { $Type: 'UI.DataField', Value: taskType },
            { $Type: 'UI.DataField', Value: requestStatus, Criticality: objectRequestStatus  },
            { $Type: 'UI.DataField', Value: status, Criticality: objectStatus  },
            { $Type: 'UI.DataField', Value: siteId },
            { $Type: 'UI.DataField', Value: siteName },
            { $Type: 'UI.DataField', Value: siteRegion },
            { $Type: 'UI.DataField', Value: siteCity },
            { $Type: 'UI.DataField', Value: phase },
            { $Type: 'UI.DataField', Value: block },
            { $Type: 'UI.DataField', Value: workId, @UI.Hidden: true },
            { $Type: 'UI.DataField', Value: workTypeName},
            { $Type: 'UI.DataField', Value: documentType },
            { $Type: 'UI.DataField', Value: manager },
            { $Type: 'UI.DataField', Value: preferredProvider },
            { $Type: 'UI.DataField', Value: assignedResponsible },
            { $Type: 'UI.DataField', Value: requestedDate }
        ],
        SelectionFields: [
            searchType,
            taskType,
            code,
            requestStatus,
            status,
            projectType,
            projectObjective,
            siteId,
            manager,
            preferredProvider,
            requestedDate
        ]
    },
    Capabilities.FilterRestrictions: {
        FilterExpressionRestrictions: [{
            $Type             : 'Capabilities.FilterExpressionRestrictionType',
            Property          : searchType,
            AllowedExpressions: 'SingleValue'
        }],
        RequiredProperties          : [searchType]
    }
) {
    requestStatus     @(Common: {
        ValueListWithFixedValues,
        Text           : requestStatusName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'RequestStatus',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: requestStatus
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
    status            @(Common: {
        ValueListWithFixedValues,
        Text           : statusName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'BlockStatus',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: status
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
    manager @(Common: {
        Text           : managerName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'Managers',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'userId',
                    LocalDataProperty: manager
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'userName'
                }
            ]
        }
    });
    complexity        @(
        Common: {
            ValueListWithFixedValues: true,
            Text: complexityName,
            TextArrangement: #TextFirst,
            ValueList               : {
                CollectionPath: 'Complexities',
                Parameters    : [
                    { $Type: 'Common.ValueListParameterInOut',  ValueListProperty: 'code', LocalDataProperty: complexity },
                    { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
                ]
            }
    });
    siteId @(
        Common: {
            ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'Sites',
                Parameters : [
                    { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : siteId, ValueListProperty : 'siteId' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'siteName' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'legacyCode' },
                    { $Type : 'Common.ValueListParameterFilterOnly', ValueListProperty : 'primaryLegacyCode' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'siteName' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'legacyCode' },
                    { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'primaryLegacyCode' },
                ]
            }
        }
    );
    preferredProvider             @(Common: {
        Text           : preferredProviderName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'PreferredProviders',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: preferredProvider
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                }
            ]
        }
    });
    documentType      @(Common: {
        ValueListWithFixedValues,
        Text           : documentName,
        TextArrangement: #TextFirst,
        // ValueList      : {
        //     CollectionPath: 'DocumentFlows',
        //     Parameters    : [
        //         {
        //             $Type            : 'Common.ValueListParameterInOut',
        //             ValueListProperty: 'documentId',
        //             LocalDataProperty: documentType
        //         },
        //         {
        //             $Type            : 'Common.ValueListParameterDisplayOnly',
        //             ValueListProperty: 'documentName'
        //         }
        //     ]
        // }
    });
    searchType        @(Common: {
        ValueListWithFixedValues,
        FilterDefaultValue : 0,
        ValueList: {
            CollectionPath: 'SearchTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: searchType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
    taskType          @(Common: {
        Text           : taskTypeName,
        TextArrangement: #TextFirst,        
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'TaskTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: taskType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
    workType   @(Common: {
        Text           : workTypeName,
        TextArrangement: #TextFirst,        
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'WorkTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: workType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
    projectType       @(Common: {
        Text           : projectTypeName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'AuxProjectTypes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: projectType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                }
            ]
        }
    });
    projectObjective       @(Common: {
        Text           : projectObjectiveName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'ProjectObjectivesCountry',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: projectObjective
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                }
            ]
        }
    });
    cellnexZone       @(Common: {
        Text           : cellnexZoneName,
        TextArrangement: #TextFirst,
        ValueListWithFixedValues,
        ValueList      : {
            CollectionPath: 'CellnexZones',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: cellnexZone
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'description',
                }
            ]
        }
    });
    assignedResponsible @(Common: {
        Text           : assignedResponsibleName,
        TextArrangement: #TextFirst
        // ValueListWithFixedValues,
        // ValueList: {
        //     CollectionPath: 'assignedResponsible',
        //     Parameters    : [
        //         {
        //             $Type            : 'Common.ValueListParameterInOut',
        //             ValueListProperty: 'code',
        //             LocalDataProperty: assignedResponsible
        //         },
        //         {
        //             $Type            : 'Common.ValueListParameterDisplayOnly',
        //             ValueListProperty: 'name'
        //         }
        //     ]
        // }
    });
    lastBlock @(Common: {
        Text           : lastBlockName,
        TextArrangement: #TextOnly,
        ValueListWithFixedValues: true,
        ValueList: {
            CollectionPath: 'InternalBlocks',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: lastBlock
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'phaseId',
                    LocalDataProperty: lastPhase
                }
            ]
        }
    });
    lastPhase @(Common: {
        Text           : lastPhaseName,
        TextArrangement: #TextOnly,
        ValueListWithFixedValues: true,
        ValueList: {
            CollectionPath: 'InternalPhases',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: lastPhase
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
    isFirstBlock @(Common: {
        ValueListWithFixedValues,
        TextArrangement : #TextOnly,
        ValueList: {
            CollectionPath: 'BooleanValues',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: isFirstBlock
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    });
}