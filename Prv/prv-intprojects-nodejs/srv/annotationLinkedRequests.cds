using {project} from './service';

annotate project.DtLinkedRequest with {
    deleted @cds.default: false;
};

annotate project.SearchDtLinkedRequestSet with @(UI: {
    HeaderInfo     : {
        TypeName      : 'DtLinked',
        TypeNamePlural: 'DtLinkeds',
        Title         : {
            $Type: 'UI.DataField',
            Value: childRequestID
        }
    },
    LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: childRequestID
        },
        {
            $Type: 'UI.DataField',
            Value: requestTypeName
        },
        {
            $Type: 'UI.DataField',
            Value: siteID
        },
        {
            $Type      : 'UI.DataField',
            Value      : statusName,
            Criticality: statusCritical
        },
    ],
    SelectionFields: [
        childRequestID,
        requestType,
        siteID,
        status
    ]
}) {
    siteID      @(
        UI    : {Placeholder: '{i18n>siteId}'},
        Common: {ValueList: {
            CollectionPath: 'Sites',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'siteID',
                    LocalDataProperty: siteID
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'legacyCode'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'siteName'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'siteAlias'
                }
            ]
        }}
    );
    status      @(
        UI    : {Placeholder: '{i18n>status}'},
        Common: {
            ValueListWithFixedValues: true,
            ValueList               : {
                CollectionPath: 'StatusHead',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    },
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'code',
                        LocalDataProperty: status
                    }
                ]
            }
        }
    );
    requestType @(Common: {
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'RequestTypesLinked',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'REQUEST_TYPE',
                    LocalDataProperty: requestType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'REQUEST_TYPE_DESC'
                }
            ]
        }
    }, );
};


annotate project.DtLinkedRequestPossibleChildrenRequestList with @(UI: {
    HeaderInfo     : {
        TypeName      : 'request',
        TypeNamePlural: 'requests',
        Title         : {
            $Type: 'UI.DataField',
            Value: requestID
        }
    },
    LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: requestCode
        },
        {
            $Type: 'UI.DataField',
            Value: siteID
        },
        {
            $Type: 'UI.DataField',
            Value: requestTypeName
        },
        {
            $Type      : 'UI.DataField',
            Value      : statusName,
            Criticality: statusCritical
        },
        {
            $Type: 'UI.DataField',
            Value: processFlowID
        }
    ],
    SelectionFields: [
        requestCode,
        requestType,
        siteID,
        status,
        processFlowID
    ]
}) {
    siteID      @(
        UI    : {Placeholder: '{i18n>siteId}'},
        Common: {ValueList: {
            CollectionPath: 'Sites',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'siteID',
                    LocalDataProperty: siteID
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'legacyCode'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'siteName'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'siteAlias'
                }
            ]
        }}
    );
    status      @(
        UI    : {Placeholder: '{i18n>status}'},
        Common: {
            ValueListWithFixedValues: true,
            ValueList               : {
                CollectionPath: 'StatusHead',
                Parameters    : [
                    {
                        $Type            : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty: 'name'
                    },
                    {
                        $Type            : 'Common.ValueListParameterInOut',
                        ValueListProperty: 'code',
                        LocalDataProperty: status
                    }
                ]
            },
            
        }
    );
    requestType @(Common: {
        ValueListWithFixedValues,
        ValueList: {
            CollectionPath: 'RequestTypesLinked',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'REQUEST_TYPE',
                    LocalDataProperty: requestType
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'REQUEST_TYPE_DESC'
                }
            ]
        }
    }, );
}