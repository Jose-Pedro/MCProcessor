const DisplayTypesFC = {
    HIDDEN: 0,
    READONLY: 1,
    OPTIONAL: 3,
    MANDATORY: 7
};

const RequestStatus = {
    REQUEST_NOTINITIALIZED: 2,
    REQUEST_INPROGRESS: 7,
    REQUEST_CANCELLED: 4,
    REQUEST_COMPLETED: 3,
    REQUEST_ON_HOLD: 12,
    REQUEST_REOPENED: 32,

}

const PhaseStatus = {
    PHASE_NOTINITIALIZED: 2,
    PHASE_INPROGRESS: 7,
    PHASE_CANCELLED: 4,
    PHASE_COMPLETED: 3,
}

const BlockStatus = {
    BLOCK_NOTINITIALIZED: 2,
    BLOCK_INPROGRESS: 7,
    BLOCK_CANCELLED: 4,
    BLOCK_COMPLETED: 3,
}

const WorkStatus = {
    WORK_NOTINITIALIZED: 2,
    WORK_INPROGRESS: 7,
    WORK_CANCELLED: 4,
    WORK_COMPLETED: 3,
}

const DocumentStatus = {
    NOT_INIT: 2,
    IN_PROGRESS: 7,
    COMPLETED: 3,
    CANCELLED: 4
}

const DocumentStatusTextCode = {
    Complete: 3,
    NotInit: 2,
    Cancelled: 4,
    InProgress: 7
}

const DocumentValidationValues = {
    valid: '1',
    nonValid: '2',
    validWRestricts: '3'
}

const Actions = {
    ACTION_PHASE_CLOSE: 'close',
    ACTION_BLOCK_CLOSE: 'close',
    ACTION_BLOCK_REOPEN: 'reOpen',
    ACTION_REQUEST_COMPLETED: 'requestCompleted',
    REQUEST_MODIFIED: 'requestModified',
    DOCUMENT_LINE_MODIFIED: 'UpdateDocumentsPerBlocks',
    DOCUMENT_INSTANCE_MODIFIED:'UpdateInstancesPerDocuments',
    DOCUMENT_INSTANCE_ADD: "Document_Instance_Add",
    DOCUMENT_INITIALIZE: "Document_Initialize",
    DOCUMENT_NEXTSTEP: "Document_NextStep",
    DOCUMENT_FINALIZED: "Document_Finalized",
    DOCUMENT_ADD: "Document_Add",
    DOCUMENT_DELETED: "Document_Deleted",
    DOCUMENT_CANCELLED: "Document_Canceled",
    DOCUMENT_REJECTED: "Document_Rejected",
    WORK_CREATE: "Work_Create",
    WORK_UPDATE: "Work_Update",
    WORK_COMPLETE: "Work_Complete",
    WORK_CANCEL: "Work_Cancel",
    WORK_REOPEN: "Work_Reopen",
    CHECKLIST_CREATE: "Checklist_Create",
    CHECKLIST_UPDATE: "Checklist_Update",
    CHECKLIST_DELETED: "Checklist_Deleted",
}

const SubcoTypes = {
    CELLNEX: 1,
    CUSTOMER: 2,
    VENDOR: 3,
    AGENCY: 4   
}

const Validators = {
    NOT_INI: "0",
    RESPONSIBLE: "10",
    CELLNEX: "20",
    SUBCO: "30",
    CUSTOMER: "40",
    SITE_OWNER: "50",
    CANCELLED: "999",
    COMPLETED: "100"
}

const AssignedResponsibleTypes = {
    CELLNEX: '1',
    EXTERNAL: '2'
}

const Roles = {
    //NOSONAR MANAGER_USER_ROL: 'TIS_WF_PRO_ColocationMgr',
    CELLNEX_USER_ROL: 'TIS_Cellnex',
    MANAGER_USER_ROL: 'TIS_WF_PRO_IntProjectsMgr',
    VENDOR_MANAGER_USER_ROL: 'TIS_WF_PRO_SuppColoMng',
    VENDOR_USER_ROL: 'TIS_WF_PRO_Subcontractor',
    AGENCY_USER_ROL: 'TIS_WF_PRO_AgencyRead',
    CUSTOMER_USER_ROL: 'TIS_WF_PRO_Customer',
    REQUESTER_ROL: 'TIS_WF_PRO_Requester',
    READ_ONLY_ROL: 'TIS_PRO_COLOCATION_READ_ONLY',
    REOPEN_USER_ROL: 'TIS_WF_PRO_REACTIVATE_REQUEST'
}

const DocumentMessageType = {
    Error: 'Error',
    Information: 'Information',
    None: 'None',
    Success: 'Success',
    Warning: 'Warning'
}

const DocumentIcons = {
    InProgress: 'sap-icon://alert',
    Responsible: 'sap-icon://retail-store-manager',
    Cellnex: 'sap-icon://manager',
    Subcontractor: 'sap-icon://people-connected',
    Customer: 'sap-icon://customer',
    SiteOwner: 'sap-icon://person-placeholder',
    Complete: 'sap-icon://sys-enter-2',
    NotInit: 'sap-icon://overlay',
    Cancelled: 'sap-icon://error',
    Rejected: 'sap-icon://stop'
}

const DocumentTexts = {
    Responsible: 'STATUS_TEXT_Responsible',
    Cellnex: 'STATUS_TEXT_Cellnex',
    Subcontractor: 'STATUS_TEXT_Subcontractor',
    Customer: 'STATUS_TEXT_Customer',
    SiteOwner: 'STATUS_TEXT_SiteOwner'
}

const GlobalConstants = {
    CACHE_TTL_HOURS: 4,
    OT_LOCAL_CLEAN_HOURS: 1, 
    SEARCH_BY_ROL: 0,
    SEARCH_BY_USER: 1,
    OT_REQUEST_TYPE: 'InternalProj',
    REQUEST_TYPE: 40,
    BTS_ROOT_FOLDER: 'Agora',
    SUPPORT_DOCUMENT: 'Support Document',
    aExternalValueHelps: ['project.Requesters', 'project.PMOManagers', 'project.Managers', 'project.Customers', 'project.CellnexUsers', 'project.ExternalUsers', 'project.InternalUsers']
}

const ComplexFields = {
    Head: {},
    Blocks: {
        feasibilCheck: {
            realEstate: {
                //NOSONAR realStateFeasibilityRisk: {
                //NOSONAR     functions: [
                //NOSONAR         'getFeasibilityRisk'
                //NOSONAR     ]
                //NOSONAR },
                realEstateFeasibilityExp: {
                    functions: [
                        'getFeasibilityExplanation'
                    ]
                }
            },
            permits: {
                permitsFeasibilityExp: {
                    functions: [
                        'getPermtiExplanation'
                    ]
                }
            }
        },
        custOfferAccept: {
            acceptBuildOffe: {
                rejectionReason: {
                    functions: [
                        'getRejectionReason'
                    ]
                }
            }
        }
    }
}

const Populations = {
    manageCandidate: {
        candRealEstate: [
            {
                phase: 'manageCandidate',
                blocks: [
                    {block: 'candGlobalRes', forCandidate: true, fields: ['REAL_ESTATE_FEASIBILITY', 'REAL_ESTATE_FEASIBILITY_RISK']}
                ]
            }
        ],
        candInfra: [
            {
                phase: 'manageCandidate',
                blocks: [
                    { block: 'candGlobalRes', forCandidate: true, fields: ['INFRASTRUCTURE_FEASIBILITY', 'INFRASTRUCTURE_FEASIBILITY_RISK', 'INFRASTRUCTURE_ADAPTATIONS', 'CIVIL_WORK_ADAPTATIONS']}
                ]
            }
        ],
        candPermits: [
            {
                phase: 'manageCandidate',
                blocks: [
                    {block: 'candGlobalRes', forCandidate: true, fields: ['PERMITS_FEASIBILITY']}
                ]
            }
        ],
        candEnergy: [
            {
                phase: 'manageCandidate',
                blocks: [
                    {block: 'candGlobalRes', forCandidate: true, fields: ['ENERGY_FEASIBILITY', 'ENERGY_ADAPTATIONS']}
                ]
            }
        ],
        candCooling: [
            {
                phase: 'manageCandidate',
                blocks: [
                    {block: 'candGlobalRes', forCandidate: true, fields: ['COLLING_FEASIBILTY', 'COOLING_ADAPTATIONS']}
                ]
            }
        ],
        candConnect: [
            {
                phase: 'manageCandidate',
                blocks: [
                    {block: 'candGlobalRes', forCandidate: true, fields: ['CONNECTIVITY_FEASIBILITY', 'CONNECTIVITY_ADAPTATIONS']}
                ]
            }
        ],
        candControl: [
            {
                phase: 'manageCandidate',
                blocks: [
                    {block: 'candGlobalRes', forCandidate: true, fields: ['MON_CTL_FEASIBILITY', 'MON_CTL_ADAPTATIONS']}
                ]
            }
        ],
        candHealth: [
            {
                phase: 'manageCandidate',
                blocks: [
                    {block: 'candGlobalRes', forCandidate: true, fields: ['HEALTH_SAFETY_FEASIBILITY']}
                ]
            }
        ]        
    }
}

const countryCurrencies = {
    GB: 'GBP',
    SE: 'SEK',
    PT: 'EUR',
    FR: 'EUR',
    ES: 'EUR',
    IT: 'EUR'
}

const ParentTypes = {
    PROJECT: 10,
    PHASE: 20,
    BLOCK: 30,
    DPB: 40,
    WORK: 50
}

const ChecklistFieldType = {
    BOOLEAN: 1,
    STRING: 2,
    DATE: 3,
    INTEGER: 4,
    DECIMAL: 5,
    PICKLIST: 6
}

const valueFieldMap = {
    [ChecklistFieldType.BOOLEAN]: "booleanValue",
    [ChecklistFieldType.STRING]: "stringValue",
    [ChecklistFieldType.DATE]: "dateValue",
    [ChecklistFieldType.INTEGER]: "integerValue",
    [ChecklistFieldType.DECIMAL]: "decimalValue"
  }

const DocumentFlowHandlers  = {
 ASSIGNED_RESP_CELLNEX : "1",
 ASSIGNED_RESP_SUBCO : "2",
 SUBCO_TYPE_CUSTOMER : 2,
 SUBCO_TYPE_VENDOR : 3,
 SUBCO_TYPE_AGENCY : 4,
 VALIDATOR_NOT_INI : "0",
 VALIDATOR_RESPONSIBLE : "10",
 VALIDATOR_CELLNEX : "20",
 VALIDATOR_SUBCO : "30",
 VALIDATOR_CUSTOMER : "40",
 VALIDATOR_SITE_OWNER : "50",
 VALIDATOR_CANCELLED : "999",
 VALIDATOR_COMPLETED : "100",
 STATUS_NOT_INIT : 0,
 STATUS_IN_PROGRESS : 7,
 STATUS_COMPLETED : 100,
 STATUS_CANCELLED : 999
}

const SubcoHiddenBlocks = [
    {masterPhase: 'custOfferAccept', masterBlock: 'acceptBuildOffe'},
    {masterPhase: 'techCostAnalys', masterBlock: 'costInfraWorks'},
    {masterPhase: 'techCostAnalys', masterBlock: 'costMoveCust'},
    {masterPhase: 'techCostAnalys', masterBlock: 'manageRefunds'}
]

module.exports = {
    RequestStatus, 
    PhaseStatus, 
    BlockStatus, 
    WorkStatus,
    DocumentStatus, 
    DocumentStatusTextCode, 
    DocumentValidationValues, 
    DisplayTypesFC, 
    Actions, 
    SubcoTypes, 
    Validators, 
    AssignedResponsibleTypes, 
    Roles, 
    DocumentMessageType, 
    DocumentIcons, 
    DocumentTexts, 
    GlobalConstants, 
    ComplexFields, 
    Populations,
    countryCurrencies,
    ParentTypes,
    ChecklistFieldType,
    DocumentFlowHandlers,
    valueFieldMap,
    SubcoHiddenBlocks
};