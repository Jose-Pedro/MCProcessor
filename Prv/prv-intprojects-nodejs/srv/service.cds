using {sap.common.Currencies} from '@sap/cds/common';
using {
    REQUEST_HEAD,
    REQUEST_CHAR_PRO,
    REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID,
    PHASE_HEAD,
    BLOCK_HEAD,
    BLOCKS_PROVISIONING,
    WF_DETAIL_DOCUMENTS,
    MASTER_MS_CONTRACT_RESTRICTIONS,
    WF_CHAT,
    CACHE_R3_ENTITIES,
    DOCUMENTS_PER_BLOCK,
    INSTANCES_PER_DOCUMENT,
    DT_LINKED_REQUEST
} from '../db/cellnex';
using {
    CANCELLATION_REASONS,
    ON_HOLD_REASONS,
    CLASSIFICATIONS,
    YES_NO_FIELDS,
    APPROVER_TYPES,
    SUBCO_TYPES,
    VALIDATIONS_DOCS,
    FEASIBILITIES_WITH_RISKS,
    ADAPTIONS_NEEDED_FIELDS,
    ACCEPTED_REJECTED,
    AUTOMATIC_FIELDS,
    REJECTION_REASONS,
    RISKS,
    COMPLEXITIES,
    MAD_RESULTS,
    ADAPTIONS_TYPES,
    REPAYMENT_STATUS,
    MOA_OPERATION_TYPES,
    FEASIBILITY_EXPLANATION_OPTIONS,
    BOOLEAN_VALUES
} from '../db/selectoptions';
using {
    RequestAllowedActions,
    BlockAllowedActions,
    DefaultCreationOptions,
    PhasesStatus,
    CHANGE_LOG,
    localized_BLOCK_STATUS,
    localized_DOCUMENT_FLOW_STATUS,
    localized_PHASE_STATUS,
    localized_REQUEST_STATUS,
    localized_SEARCH_TYPES,
    localized_STATUS_HEAD,
    localized_TASK_TYPES,
    PREFERRED_PROVIDERS,
    SITES,
    CUSTOMERS,
    CELLNEX_ZONES,
    ZONES,
    REGIONS,
    INFRA_ORIGINS,
    INFRA_OWNERSHIPS,
    INFRA_STATUS,
    MARKETABLES,
    ABF_ZONES,
    MANAGING_COMPANIES,
    CELLNEX_PROJECTS,
    EXPLOITEDS,
    PROJECT_TYPES,
    AUX_PROJECT_TYPES,
    CONTRACT_RESTRICTIONS_OPTIONS
} from '../db/common';
using {
    REQUEST_TYPE,
    PROCESS_TYPES,
    FIRST_INPROGRESS_PHASE,
    LAST_ACTIVE_PHASES,
    SINGLE_REQUEST_PROCESS,
    PHASES_PER_PROCESS,
    BLOCKS_PER_PROCESS,
    INTERNAL_PHASES,
    INTERNAL_BLOCKS
} from '../db/processflow';
using { T001 } from '../db/eccmodel';
using { DOCUMENT_FLOWS, WF_DETAIL_DOCUMENTS_LOCAL, DOCUMENTS_PER_PROCESS, DOCUMENTS_PER_REQUEST, DOCUMENT_VIEWER_NODES } from '../db/document';
using { PMO_MANAGERS, MANAGERS, REQUESTERS } from '../db/userinfo';
using { WORKS, WORK_TYPES, WORK_DOCUMENTS_VH, PROJECT_OBJECTIVES_CONFIG_BY_PROCESS, PROJECT_OBJECTIVES_BY_COUNTRY, LOCALIZED_WORKTYPES } from '../db/works';
using { ZTIS_SRV_SERVICES_SRV } from './external/ZTIS_SRV_SERVICES_SRV';
using { SearchDtLinkedRequest, DtLinkedRequestPossibleChildrenRequest } from '../db/linkedRequests';
using { Checklist } from '../db/checklist';
using { SEARCH_BY_REQUESTS, SEARCH_BY_TASKS } from '../db/searches';

@path: '/service/project'
// @requires: 'authenticated-user'
service project {

    //Project entities
    @readonly entity SearchByRequests as projection on SEARCH_BY_REQUESTS
    {
        key ID                    : UUID               @title: '{i18n>ID}' @UI.Hidden,
            code                  : String(100)        @title: '{i18n>code}',
            projectType           : String(36)         @title: '{i18n>projectType}',
            projectTypeName       : String(255)        @UI.Hidden,
            projectObjective      : Integer            @title: '{i18n>projectObjective}',            
            projectObjectiveName  : String(255)        @UI.Hidden,
            status                : Integer            @title: '{i18n>status}',
            statusName            : String(50)         @title: '{i18n>statusName}' @UI.Hidden,
            complexity            : String(100)        @title: '{i18n>complexity}',
            complexityName        : String(200)        @title: '{i18n>complexityName}', 
            siteId                : String(36)         @title: '{i18n>siteId}',
            siteName              : String(100)        @title: '{i18n>siteName}',
            siteRegion            : String(100)        @title: '{i18n>region}',
            siteRegionName        : String(100)        @UI.Hidden, 
            siteCity              : String(100)        @title: '{i18n>city}',
            cellnexZone           : String(10)         @title: '{i18n>cellnexZone}',
            cellnexZoneName       : String(60)         @UI.Hidden,
            lastPhase             : String(100)        @title: '{i18n>lastPhase}',  
            lastBlock             : String(100)        @title: '{i18n>lastBlock}',  
            lastPhaseName         : String(100)        @title: '{i18n>lastPhaseName}' @UI.Hidden,
            lastBlockName         : String(100)        @title: '{i18n>lastBlockName}' @UI.Hidden,
            siteLegacyCode        : String(36)         @title: '{i18n>secondaryLegacyCode}',
            requestedDate         : Timestamp          @title: '{i18n>requestedDate}',
            createdAt             : Timestamp          @title: '{i18n>createdAt}',
            manager               : String(36)         @title: '{i18n>colocationManager}',
            managerName           : String(300)        @title: '{i18n>colocationManagerName}' @UI.Hidden,
            preferredProvider     : String(50)         @title: '{i18n>preferredProvider}',
            preferredProviderName : String(100)        @title: '{i18n>preferredProviderName}' @UI.Hidden,
            assignationDate       : Timestamp          @title: '{i18n>assignationDate}',
            searchType            : Integer            @title: '{i18n>searchType}'  @mandatory,
            objectStatus          : Integer            @UI.Hidden
    }

    @readonly entity SearchByTasks as projection on SEARCH_BY_TASKS{
        key ID                      : UUID              @title: '{i18n>ID}' @UI.Hidden,
            code                    : String(100)       @title: '{i18n>code}',
            projectType             : String(36)        @title: '{i18n>projectType} ',
            projectTypeName         : String(255)       @UI.Hidden,
            projectObjective        : Integer           @title: '{i18n>projectObjective}',
            projectObjectiveName    : String(255)       @UI.Hidden,
            requestStatus           : Integer           @title: '{i18n>requestStatus}',
            requestStatusName       : String(50)        @title: '{i18n>statusName}' @UI.Hidden,
            status                  : Integer           @title: '{i18n>status}',
            statusName              : String(50)        @title: '{i18n>statusName}' @UI.Hidden,
            complexity              : String(100)       @title: '{i18n>complexity}',
            complexityName          : String(200)       @title: '{i18n>complexityName}', 
            siteId                  : String(36)        @title: '{i18n>siteId}',
            siteName                : String(100)       @title: '{i18n>siteName}',
            siteRegion              : String(100)       @title: '{i18n>region}',
            siteRegionName          : String(100)       @UI.Hidden, 
            siteCity                : String(100)       @title: '{i18n>city}',
            cellnexZone             : String(10)        @title: '{i18n>cellnexZone}',
            cellnexZoneName         : String(60)        @UI.Hidden,
            siteLegacyCode          : String(36)        @title: '{i18n>secondaryLegacyCode}',
            requestedDate           : Timestamp         @title: '{i18n>requestedDate}',
            createdAt               : Timestamp         @title: '{i18n>createdAt}',
        key masterPhaseId           : String(20)        @UI.Hidden,
            phase                   : String(100)       @title: '{i18n>phase}',
        key masterBlockID           : String(20)        @UI.Hidden,
            block                   : String(100)       @title: '{i18n>block}',
            lastPhase               : String(100)       @title: '{i18n>lastPhase}',  
            lastBlock               : String(100)       @title: '{i18n>lastBlock}',  
            lastPhaseName           : String(100)       @title: '{i18n>lastPhaseName}',
            lastBlockName           : String(100)       @title: '{i18n>lastBlockName}',
            isFirstBlock            : Boolean           @title: '{i18n>isFirstBlock}',
            roleId                  : String(60)        @title: '{i18n>roleId}' @UI.Hidden,
        key workId                  : UUID              @UI.Hidden,             
            work                    : String(100)       @UI.Hidden,
            workType                : Integer           @title: '{i18n>workType}',
        key workTypeName            : String(100)       @title: '{i18n>workType}' @UI.Hidden,
            assignedResponsible     : String(100)       @title: '{i18n>searchAssignedResponsible}',
            assignedResponsibleName : String(100)       @title: '{i18n>assignedResponsibleName}',
            manager                 : String(36)        @title: '{i18n>colocationManager}',
            managerName             : String(300)       @title: '{i18n>colocationManagerName}' @UI.Hidden,
            preferredProvider       : String(50)        @title: '{i18n>preferredProvider}',
            preferredProviderName   : String(100)       @title: '{i18n>preferredProviderName}' @UI.Hidden,
            assignationDate         : Timestamp         @title: '{i18n>assignationDate}',
            searchType              : Integer           @title: '{i18n>searchType}',
            taskType                : Integer           @title: '{i18n>taskType}',
            taskTypeName            : String(50)        @title: '{i18n>taskTypeName}' @UI.Hidden,
        key documentType            : String            @title: '{i18n>documentType}',
            documentName            : String            @title: '{i18n>documentName}' @UI.Hidden,
            // stepId                  : String(5)         @title: '{i18n>stepId}',
            documentValidation      : String(50)        @title: '{i18n>documentValidations}',
            objectStatus            : Integer @UI.Hidden,
            objectRequestStatus     : Integer @UI.Hidden,
    }

    @(restrict: [
        { grant: ['CREATE'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_Requester', 'TIS_WF_PRO_IntProjectsMgr'], where: 'requestType = 40' },
        { grant: ['READ'], where: 'requestType = 40' },
        { grant: ['UPDATE'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'], where: 'requestType = 40' },
        { grant: ['reopen'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['close'], to: [ 'TIS_WF_PRO_ColocationMgr','TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['cancel'], to: [ 'TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['setOnHold'], to: [ 'TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['takeOwnership'], to : ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr']},
        { grant: ['addRequestDocumentsPerBlockDefaultValid'], to: [ 'TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['deleteAllDocumentsPerBlockDefaultValid'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['onUpdateToDefaultDocumentsPerBlockDefaultValid'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        //NOSONAR { grant: ['CREATE'], where: 'requestType = 40' },
        //NOSONAR { grant: ['UPDATE'], where: 'requestType = 40' },
        //NOSONAR { grant: ['reopen'] },
        //NOSONAR { grant: ['cancel'] },
        //NOSONAR { grant: ['setOnHold'] },
        { grant: ['confirmInventoryCheck'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['confirmInventory'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['confirmDocuments'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['confirmService'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        //NOSONAR { grant: ['addRequestDocumentsPerBlockDefaultValid'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        { grant: ['onCancelDefaultValidators'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
    ])
    entity Requests as projection on REQUEST_HEAD {
        key REQUEST_ID               as ID            : UUID,
            ASSIGNATION_DATE         as assignationDate,
            CANCELLATION_COMMENTS    as cancellationComments,
            CANCELLATION_PHASE_ID    as cancellationPhaseID,
            CANCELLATION_REASON      as cancellationReason,
            COMUNIDAD_ID             as company,
            COUNTRY_ID               as country,
            CREATEDAT                as createdAt,
            CREATEDBY                as createdBy,
            DELETED_AT               as deletedAt,
            DELETED_BY               as deletedBy,
            ENDED_AT                 as closedAt,
            MODIFIEDAT               as changedAt,
            MODIFIEDBY               as changedBy,
            PROCESS_ID               as processFlowId,
            // PROGRAM                        as program,
            REQUEST_CODE             as code,
            REQUEST_DESCRIPTION      as description,
            REQUEST_OWNER_ID         as manager,
            REQUEST_STATUS           as status,
            REQUEST_TYPE             as requestType,
            ROLE_ID                  as role,
            SITE_ID                  as siteId,
            STARTED_AT               as opentAt,
            ON_HOLD_COMMENTS         as onHoldComments,
            ON_HOLD_PHASE_ID         as onHoldPhaseId,
            ON_HOLD_REASON           as onHoldReason,
            CLASSIFICATIONVT         as classification,
            WORKFLOW_NAME            as workflowName,
            WORKFLOW_ID              as creationConfig,
            virtual requestedDate: Date @title: '{i18n>requestedDate}' @Core.Computed: false,
            preferredProvider,
            projectObjective,
            documentUpdated,
            inventoryUpdated,
            servicesUpdated,
            requestTypeFC,
            assignationDateFC,
            managerFC,
            classificationFC,
            descriptionFC,
            companyFC,
            createdAtFC,
            siteIdFC,
            DOCUMENT_ID              as documentId,
            RequestProvision                          : Association to one RequestProvision on RequestProvision.ID = ID,
            Phases                                    : Association to many Phases on Phases.requestId = ID,
            Chats                                     : Association to many Chats on Chats.ID = ID,
            ChangesLog                                : Association to many ChangesLog on ChangesLog.requestId = ID,
            ProcessTypes                              : Association to one ProcessTypes on ProcessTypes.code = processFlowId,
            RequestTypes                              : Association to one RequestTypes on RequestTypes.REQUEST_TYPE = requestType,
            RequestStatus                             : Association to one RequestStatus on RequestStatus.code = status,
            OnHoldReasons                             : Association to one OnHoldReasons on OnHoldReasons.code = onHoldReason,
            CancellationReasons                       : Association to one CancellationReasons on CancellationReasons.code = cancellationReason,
            Managers                                  : Association to one Managers on Managers.userId = manager,
            Site                                      : Association to one Sites on Site.siteId = siteId,
            RequestDocumentsPerBlockDefaultValid      : Association to many RequestDocumentsPerBlockDefaultValid on  RequestDocumentsPerBlockDefaultValid.requestId = ID and RequestDocumentsPerBlockDefaultValid.deleted   = false,
            DocumentsPerRequest                       : Association to many DocumentsPerRequest on DocumentsPerRequest.requestId = ID,
            // DocumentsPerJointProjectPerRequest                  : Association to many DocumentsPerJointProjectPerRequest on DocumentsPerJointProjectPerRequest.requestId = ID,
            // OtDocumentsPerRequest                : Association to many OtDocumentsPerRequest on OtDocumentsPerRequest.requestId = ID,
            DocumentViewerNodes                       : Association to many DocumentViewerNodes on DocumentViewerNodes.requestId = ID,
            ImpactedCustomers                         : Association to Many ImpactedCustomers on ImpactedCustomers.requestId = ID
    } actions {
        action reopen()                                                         returns Requests;
        action close()                                                          returns Requests;
        action cancel(cancellationComments: String, cancellationReason: String) returns Requests;
        action setOnHold(onHoldComments: String, onHoldReason: String)          returns Requests;
        action takeOwnership()                                                  returns Requests;
        action confirmInventoryCheck()                                          returns String;
        action confirmInventory()                                               returns String;
        action confirmService()                                                 returns String;
        action confirmDocuments()                                               returns String;
        action addRequestDocumentsPerBlockDefaultValid (documentId : String(50), requestId: String(36)) returns Requests;
        action onCancelDefaultValidators(dpbRegisterId: String(36))                                     returns Requests;
        action deleteAllDocumentsPerBlockDefaultValid(requestId: String(36))                            returns Requests;
        action onUpdateToDefaultDocumentsPerBlockDefaultValid(requestId: String(36))                    returns Requests;
    }

    @(restrict: [
        { grant: ['READ']},
        { grant: ['UPDATE'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr']}
        // { grant: ['UPDATE']}
    ])
    entity RequestProvision as projection on REQUEST_CHAR_PRO {
        key REQUEST_ID         as ID            : UUID,
            REQUESTED_DATE     as requestedDate : Date @title: '{i18n>requestedDate}',
            REQUESTER          as requester,
            FORESCAST_DONE     as forecastDone,
            PMO_MANAGER        as PMOManager,
            PREFERRED_PROVIDER as preferredProvider,
            PREFERRED_PROVIDER_NAME as preferredProviderName,
            CLASIFICATION      as classification,
            SF_OPPORTUNITY_ID  as salesforceRequestId,
            // QUOTE_ID                           as quoteId,
            PROJECT_OBJECTIVE  as projectObjective,
            
            MOA_OPERATION                      as moaOperation,
            moaOperationFC,
            requesterName,
            PMOManagerName,
            requestedDateFC,
            requesterFC,
            PMOManagerFC,
            priorityFC,
            preferredProviderFC,
            classificationFC,
            salesforceRequestIdFC,
            projectObjectiveFC,
            Requests                            : Association to one Requests on Requests.ID = ID,
            Classifications                     : Association to one Classifications on Classifications.code = classification,
            PreferredProviders                  : Association to one PreferredProviders on PreferredProviders.code = preferredProvider,
            MoaOperationTypes                   : Association to one MoaOperationTypes on MoaOperationTypes.code = moaOperation,
            // WhoBuildSites                            : Association to one WhoBuildSites on WhoBuildSites.code = whoBuildSite,
            // EquipmentInstResponsibles                : Association to one EquipmentInstResponsibles on EquipmentInstResponsibles.code = equipmentInstResponsible,
            // CustomerAdaptionsCheckTypes              : Association to one CustomerAdaptionsCheckTypes on CustomerAdaptionsCheckTypes.code = customerAdaptionsCheckType,
            // CustomerInstallationCheckTypes           : Association to one CustomerInstallationCheckTypes on CustomerInstallationCheckTypes.code = customerInstallationCheckType,
            CacheR3Entities                          : Association to one CacheR3Entities on CacheR3Entities.code = preferredProvider,
            PMOManagers                         : Association to one PMOManagers on PMOManagers.userId = PMOManager,
            Requesters                          : Association to one Requesters on Requesters.userId = requester,
            ProjectObjectives                   : Association to one ProjectObjectives on ProjectObjectives.ID = projectObjective,
        // BudgetProgram                            : Association to one BudgetProgram on BudgetProgram.code = budgetProgram,
        // WhoSignsContract                         : Association to one WhoSignsContract on WhoSignsContract.code = whoSignsContract,
        // DeliveryGroups                           : Association to one DeliveryGroups on DeliveryGroups.code = deliveryGroup,
        // DeliveryGroupSubprograms                 : Association to one DeliveryGroups on DeliveryGroupSubprograms.code = deliveryGroupSubProgram,
        // DeliveryGroupPriorities                  : Association to one DeliveryGroups on DeliveryGroupPriorities.code = deliveryGroupPriority
    }

    @(restrict: [
        { grant: ['READ'], where: 'deleted != true' },
        { grant: ['UPDATE'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr']}
    ])
    entity RequestDocumentsPerBlockDefaultValid as projection on REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID {
        key REGISTER_ID         as ID,
            DOCUMENT_ID         as documentId,
            REQUEST_ID          as requestId,
            APPROVER_TYPE       as responsibleId,
            SUBCONTRACTOR       as subcontractorId,
            DEFAULT_RESPONSIBLE as responsibleDefault,
            SUBCO_REQ_VAL       as subcontractorValidation,
            CELLNEX_REQ_VAL     as cellnexValidation,
            CUSTOMER__REQ_VAL   as customerValidation,
            SITEOWNER_REQ_VAL   as siteOwnerValidation,
            CREATEDAT           as createdAt,
            CREATEDBY           as createdBy,
            DELETED             as deleted,
            DELETED_AT          as deletedAt,
            DELETED_BY          as deletebBy,
            MODIFIEDAT          as modifiedAt,
            MODIFIEDBY          as modifiedBy,
            cellnexResponsible,
            subcontractorResponsible,
            agencyResponsible,
            customerResponsible,
            cellnexResponsibleName,
            subcontractorResponsibleName,
            agencyResponsibleName,
            customerResponsibleName,
            cellnexResponsibleFC,
            subcontractorResponsibleFC,
            agencyResponsibleFC,
            customerResponsibleFC,
            documentIdFC,
            documentNameVF,
            approverTypeName,
            approverTypeFC,
            subcoTypeName,
            subcoTypeFC,
            responsibleDefaultName,
            responsibleDefaultFC,
            cellnexValidationFC,
            subcontractorValidationFC,
            customerValidationFC,
            siteOwnerValidationFC,
            Requests                             : Association to many Requests
                                                        on Requests.ID = requestId,
            ApproverTypes                        : Association to one ApproverTypes
                                                        on ApproverTypes.code = responsibleId,
            SubcoTypes                           : Association to one SubcoTypes
                                                        on SubcoTypes.code = subcontractorId,
            DocumentFlowDefaultValidDocumentId   : Association to one DocumentFlowDefaultValidDocumentId
                                                        on DocumentFlowDefaultValidDocumentId.documentId = documentId,
            DocumentFlowResponsiblesDefaultValid : Association to one DocumentFlowResponsiblesDefaultValid
                                                        on DocumentFlowResponsiblesDefaultValid.code = responsibleDefault
    } actions {
        action addRequestDocumentsPerBlockDefaultValid(documentId: String(50), requestId: String(36)) returns RequestDocumentsPerBlockDefaultValid;
        // action remove()
    };

    @(restrict: [
        { grant: ['READ'], where: 'Requests.requestType = 40' },
        { grant: ['UPDATE'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'], where: 'Requests.requestType = 40' },
        { grant: ['close'], to: [ 'TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] },
        //NOSONAR { grant: ['close']},
    ])
    entity Phases as projection on PHASE_HEAD {
        key PHASE_ID        as ID        : UUID,
            CREATEDAT       as createdAt,
            CREATEDBY       as createdBy,
            DELETED         as deleted,
            DELETED_AT      as deletedAt,
            DELETED_BY      as deletedBy,
            ENDED_AT        as closedAt,
            MASTER_PHASE_ID as processFlowId,
            MODIFIEDAT      as changedAt,
            MODIFIEDBY      as changedBy,
            PHASE_OWNER     as owner,
            PHASE_STATUS    as status,
            REQUEST_ID      as requestId : UUID,
            STARTED_AT      as openAt,
            // CANDIDATEID     as candidateId,
            CLOSE_BLOCK     as closeBlock,
            HAS_CANDIDATES  as hasCandidates,
            ACTIVATED       as activated,
            // SITE_ID         as siteId,
            Blocks                       : Association to many Blocks on Blocks.phaseId = ID,
            Requests                     : Association to one Requests on Requests.ID = requestId,
            PhaseStatus                  : Association to one PhaseStatus on PhaseStatus.code = status,            
            SupportDocuments             : Association to many SupportDocuments on SupportDocuments.phaseName = processFlowId and SupportDocuments.requestId = requestId
       } actions {
        action close() returns Phases;
    }

    entity Blocks as projection on BLOCK_HEAD {
        key BLOCK_ID        as ID       : UUID,
            ACTIVATED       as activated,
            BLOCK_STATUS    as status,
            COMMENTS        as comments,
            COMMENTS        as commentsPLU @(title: '{i18n>commentsPLU}'),
            CREATEDAT       as createdAt,
            CREATEDBY       as createdBy,
            DELETED_AT      as deletedAt,
            DELETED_BY      as deletedBy,
            ENDED_AT        as closedAt : Date @title: '{i18n>closedAt}',
            MASTER_BLOCK_ID as processFlowId,
            MODIFIEDAT      as modifiedAt,
            MODIFIEDBY      as modifiedBy,
            PHASE_ID        as phaseId  : UUID,
            ROLE_ID         as role,
            STARTED_AT      as openAt   : Date @title: '{i18n>startDate}',
            MANDATORY       as mandatory,
            OWNER_ID        as owner,
            // CANDIDATE_ID    as candidateId,
            DOCUMENT_ID     as documentId,
            REGISTER_ID     as dpbRegisterId,
            commentsFC,
            commentsPLUFC,
            contractRestrictionsFC,
            openAtFC,
            closedAtFC,
            dpbVisibleVF,
            worksVisibleVF,
            checklistVisibleVF,
            cancellationReason,
            Phases                      : Association to one Phases on Phases.ID = phaseId,
            BlockProvision              : Association to one BlockProvision on BlockProvision.ID = ID,
            Works                       : Association to many Works on  Works.parentId = ID and Works.parentType.ID = 30,
            Checklist                   : Association to many ChecklistItems on Checklist.block_ID = ID,
            BlockStatus                 : Association to one BlockStatus on BlockStatus.code = status,
            Documents                   : Association to many Documents on Documents.blockId = ID and Documents.workId is null,
            SupportDocuments            : Association to many SupportDocuments on SupportDocuments.blockId = ID,
            ContractRestrictions        : Association to many ContractRestrictions on ContractRestrictions.BLOCK_ID = ID,
            DocumentsPerBlocks          : Association to many DocumentsPerBlocks on DocumentsPerBlocks.blockId = ID,
            AttachmentDocumentTypes     : Association to many AttachmentDocumentTypes on AttachmentDocumentTypes.BLOCK_ID = ID
    } actions {
        action close() returns String;
        action reOpen();
        action addDocumentPerBlock(documentId: String(50));
    }

    entity BlockProvision as projection on BLOCKS_PROVISIONING {
        key BLOCK_ID                        as ID                          : UUID @readonly,
            ACCEPTED_REJECTED               as accepted,
            ACCEPTED_REJECTED_DATE          as acceptedDate                : Date @title: '{i18n>acceptedDate}',
            ACTIVATION_REASON               as activationReason,
            ADAPTIONS_TYPE                  as adaptionsType,
            APD_PACK_DELIVERY_EXPECTED_DATE as apdPackDeliveryExpectedDate : Date @(title: '{i18n>apdPackDeliveryExpectedDate}'),
            APD_PACK_DELIVERY_PLANNED_DATE  as apdPackDeliveryPlannedDate  : Date @(title: '{i18n>apdPackDeliveryPlannedDate}'),
            APS_DELIVERY_EXPECTED_DATE      as apsDeliveryExpectedDate     : Date @(title: '{i18n>apsDeliveryExpectedDate}'),
            APS_DELIVERY_PLANNED_DATE       as apsDeliveryPlannedDate      : Date @(title: '{i18n>apsDeliveryPlannedDate}'),
            ASSIGNED_RESPONSIBLE            as assignedResponsible,
            AUTOMATIC_MANUAL_RESPONSE       as automaticManualResponse,
            // BLOCK_STATUS                    as status,
            STATUS                          as repaymentStatus,
            BTTN_DOC_UPDATED                as documentsUpdated,
            BTTN_INV_UPDATED                as inventoryUpdated,
            BTTN_SERV_UPDATED               as servicesUpdated,
            COMPLETED_BY                    as completedBy,
            COMPLETED_DATE                  as completedDate               : Date @title: '{i18n>completedDate}',
            COMPLEXITY                      as complexity,
            CONTRACT_RESTRICTIONS           as contractRestrictions,
            CREATEDAT                       as createdAt,
            CREATEDBY                       as createdBy,
            CURRENCY                        as currency,
            DEBTOR                          as debtor,
            DESCRIPTION                     as description,
            DELETED                         as deleted,
            DELETED_AT                      as deletedAt,
            DELETED_BY                      as deletedBy,
            ENDED_AT                        as closedAt,
            ENERGY_PROVIDER_DOC_DELIVERY_EXPECTED_DATE as energyProvDocExpectedDate     : Date @title: '{i18n>energyProvDocExpectedDate}',
            ENERGY_PROVIDER_VISIT_EXPECTED_DATE        as energyProvVisitExpectedDate   : Date @title: '{i18n>energyProvVisitExpectedDate}',
            ENERGY_PROVIDER_VISIT_DATE                 as energyProviderVisitDate       : Date @title: '{i18n>energyProviderVisitDate}',
            EXPECTED_DATE                   as expectedDate                : Date @(title: '{i18n>expectedDate}'),
            EXPECTED_START_DATE             as expectedStartDate           : Date @(title: '{i18n>expectedStartDate}'),
            EXPECTED_END_DATE               as expectedEndDate             : Date @(title: '{i18n>expectedEndDate}'),
            EXPECTED_MAD_DATE               as expectedMadDate             : Date @(title: '{i18n>expectedMadDate}'),
            ESTIMATED_PAYMENT_DATE          as estimatedPaymentDate        : Date @(title: '{i18n>estimatedPaymentDate}'),
            READY_TO_START_WORKS_DATE       as readyToStartWorksDate       : Date @(title: '{i18n>readyToStartWorksDate}'),
            GLOBAL_END_WORKS_DATE           as globalEndWorksDate          : Date @(title: '{i18n>globalEndWorksDate}'),
            GLOBAL_START_WORKS_DATE         as globalStartWorksDate        : Date @(title: '{i18n>globalStartWorksDate}'),
            HS_VISIT_DATE                   as hsVisitDate                 : Date @(title: '{i18n>hsVisitDate}'),
            HS_VISIT_PLANNED_DATE           as hsVisitPlannedDate          : Date @(title: '{i18n>hsVisitPlannedDate}'),
            INFRASTRUCTURES_MAD_DATE        as infraMadDate                : Date @(title: '{i18n>infraMadDate}'),
            KICK_OFF_ESTIMATED_VISIT_DATE   as kickOffEstimatedVisitDate   : Date @(title: '{i18n>kickOffEstimatedVisitDate}'),
            KICK_OFF_VISIT_NEEDED           as visitNeeded,
            MODIFIEDAT                      as changedAt,
            MODIFIEDBY                      as changedBy,
            PLANNED_DATE                    as plannedDate                 : Date @title: '{i18n>plannedDate}',
            PLANNED_KICK_OFF_DATE           as plannedKickoffDate          : Date @title: '{i18n>plannedKickoffDate}',
            PLANNING_RATING                 as planningRating,
            PROVIDER_NAME                   as externalResponsible,
            REJECTION_CAUSE                 as rejectionReason,
            RENEGO_NEEDED                   as renegoNeeded,
            REAL_DATE_SURVEY                as siteSurveyDate              : Date @title: '{i18n>siteSurveyDate}',
            REAL_END_DATE                   as realEndDate                 : Date @title: '{i18n>realEndDate}',
            REAL_END_DATE                   as kickOffRealDate             : Date @(title: '{i18n>kickOffRealDate}'),
            REAL_END_DATE                   as heritageEndDate             : Date @(title: '{i18n>heritageEndDate}'),
            REAL_START_DATE                 as realStartDate               : Date @title: '{i18n>realStartDate}',
            RESPONSIBLE_PERSON              as internalResponsible,
            RESULT_MAD                      as madResult,
            SEND_OFFER_DATE                 as sendOfferDate               : Date @title: '{i18n>sendOfferDate}',
            START_DATE                      as startDate                   : Date @title: '{i18n>startedAt}',
            END_DATE                        as endDate                     : Date @title: '{i18n>endDate}',
            SITE_SURVEY_WILL_BE_NEEDED      as siteSurveyWillBeNeeded,
            SUBCONTRACTOR_TYPE              as subcontractorType,
            AMOUNT_BUDGET                   as amount,
            TOTAL_COST                      as totalCost,
            TOTAL_COST                      as totalCostClient                    @(title: '{i18n>totalCostClient}'),
            NEED_KICK_OFF_VISIT             as kickOffVisitNeeded,
            OVERALL_FEASIBILITY             as overallFeasibility,
            OVERALL_FEASIBILITY_RISK        as overallFeasibilityRisk,
            PERMITS_NEEDED                  as permitsNeeded,
            PERMITS_FEASIBILITY             as permitsFeasibility,
            PERMITS_FEASIBILITY_EXPLANATION as permitsFeasibilityExp,
            REAL_ESTATE_FEASIBILITY         as realStateFeasibility,
            REAL_ESTATE_FEASIBILITY_RISK    as realStateFeasibilityRisk,
            REAL_ESTATE_FEASIBILITY_EXPLANATION as realEstateFeasibilityExp,
            ASSIGNED_RESPONSIBLE_FC         as assignedResponsibleFC              @readonly,
            SUBCONTRACTOR_TYPE_FC           as subcontractorTypeFC                @readonly,
            PROVIDER_NAME_FC                as externalResponsibleFC              @readonly,
            RESPONSIBLE_PERSON_FC           as internalResponsibleFC              @readonly,
            acceptedDateFC,
            acceptedFC,
            activationReasonFC,
            adaptionsTypeFC,
            amountFC,
            automaticManualResponseFC,
            completedByFC,
            completedDateFC,
            complexityFC,
            confirmInventoryUpdateFC,
            confirmInventoryUpdateRespFC,
            contractRestrictionsFC,
            currencyFC,
            debtorFC,
            descriptionFC,
            energyProvDocExpectedDateFC,
            energyProvVisitExpectedDateFC,
            energyProviderVisitDateFC,
            expectedDateFC,
            expectedMadDateFC,
            expectedStartDateFC,
            expectedEndDateFC,
            estimatedPaymentDateFC,
            globalStartWorksDateFC,
            globalEndWorksDateFC,
            heritageEndDateFC,
            hsVisitDateFC,
            hsVisitPlannedDateFC,
            infraMadDateFC,
            kickOffEstimatedVisitDateFC,
            kickOffDescriptionFC,
            kickOffRealDateFC,
            kickOffVisitNeededFC,
            madResultFC,
            permitsFeasibilityExpFC,
            permitsFeasibilityFC,
            permitsNeededFC,
            plannedKickoffDateFC,
            plannedDateFC,
            readyToStartWorksDateFC,
            realEstateFeasibilityExpFC,
            realStartDateFC,
            realEndDateFC,
            realStateFeasibilityFC,
            realStateFeasibilityRiskFC,
            rejectionReasonFC,
            renegoNeededFC,
            repaymentStatusFC,
            sendOfferDateFC,
            siteSurveyDateFC,
            siteSurveyWillBeNeededFC,
            startDateFC,
            totalCostFC,
            totalCostClientFC,
            newUploadTableEnabled,
            Blocks                                                         : Association to one Blocks on Blocks.ID = ID,
            // BlockStatus                                                    : Association to one BlockStatus on BlockStatus.code = status,
            RepaymentStatus                                                : Association to one RepaymentStatus on RepaymentStatus.code = repaymentStatus,
            ApproverTypes                                                  : Association to one ApproverTypes on ApproverTypes.code = assignedResponsible,
            SiteSurveyNeeded                                               : Association to one YesNoFields on SiteSurveyNeeded.code = siteSurveyWillBeNeeded,
            SubcoTypes                                                     : Association to one SubcoTypes on SubcoTypes.code = subcontractorType,
            KickOffVisitNeeded                                             : Association to one YesNoFields on KickOffVisitNeeded.code = kickOffVisitNeeded,
            RenegoNeeded                                                   : Association to one AdaptionsNeededFields on RenegoNeeded.code = renegoNeeded,
            AutomaticManualResponses                                       : Association to one AutomaticFields on AutomaticManualResponses.code = automaticManualResponse,
            RealStateFeasibilities                                         : Association to one FeasibilitiesWithRisks on RealStateFeasibilities.code = realStateFeasibility,
            PermitsFeasibilities                                           : Association to one FeasibilitiesWithRisks on PermitsFeasibilities.code = permitsFeasibility,
            RealStateRisks                                                 : Association to one Risks on RealStateRisks.code = realStateFeasibilityRisk,
            PermitsNeeded                                                  : Association to one AdaptionsNeededFields on PermitsNeeded.code = permitsNeeded,
            AcceptedRejected                                               : Association to one AcceptedRejected on AcceptedRejected.code = accepted,
            RejectionReasons                                               : Association to one RejectionReasons on RejectionReasons.code = rejectionReason,
            Currencies                                                     : Association to one Currencies on Currencies.code = currency,
            Complexities                                                   : Association to one Complexities on Complexities.code = complexity,
            MadResults                                                     : Association to one MadResults on MadResults.code = madResult,
            AdaptionsTypes                                                 : Association to one AdaptionsTypes on AdaptionsTypes.code = adaptionsType,
            RealStateFeasibilityExplanations                               : Association to one FeasibilityExplanations on RealStateFeasibilityExplanations.code = realEstateFeasibilityExp,
            PermitsFeasibilityExplanations                                 : Association to one FeasibilityExplanations on PermitsFeasibilityExplanations.code = permitsFeasibilityExp
    }

    @Capabilities.Deletable : false
    @Capabilities.Insertable: false
    @(restrict: [
        { grant: ['READ'], where: 'requestType = 40' },
        { grant: ['UPDATE'], to: ['TIS_WF_PRO_ColocationMgr', 'TIS_WF_PRO_IntProjectsMgr'] }
    ])
    entity BlocksResponsibles {
        key ID                      : UUID;
            requestId               : UUID         @readonly;
            requestProcessFlowId    : String(20)   @title: '{i18n>processFlowId}'      @readonly;
            ProcessFlowType         : String(15)   @title: '{i18n>processType}'        @readonly;
            phaseProcessFlowId      : String(36)   @title: '{i18n>phase}'              @readonly;
            phaseName               : String(100)  @title: '{i18n>phaseName}'          @readonly;
            blockProcessFlowId      : String(36)   @title: '{i18n>block}'              @readonly;
            blockName               : String(100)  @title: '{i18n>blockName}'          @readonly;
            approverType            : String       @title: '{i18n>assignedResponsible}';
            approverTypeFC          : UInt8        @readonly;
            approverName            : String(200)  @readonly;
            subcoType               : Integer      @title: '{i18n>subcontractorType}'  @odata.Nullable;
            subcoTypeFC             : UInt8        @readonly;
            subcoName               : String(200)  @readonly;
            externalResponsible     : String(100)  @title: '{i18n>externalResponsible}';
            externalResponsibleName : String(200);
            externalResponsibleFC   : UInt8        @readonly;
            internalResponsible     : String(100)  @title: '{i18n>internalResponsible}';
            internalResponsibleName : String(200);
            internalResponsibleFC   : UInt8        @readonly;
            ApproverTypes           : Association to one ApproverTypes on ApproverTypes.code = approverType;
            SubcoTypes              : Association to one SubcoTypes on SubcoTypes.code = subcoType;
    }

    entity LocalDocuments as projection on WF_DETAIL_DOCUMENTS_LOCAL {
        key REGISTER_ID           as ID            : UUID,
            BLOCK_ID              as blockId       : UUID,
            INSTANCE_ID           as instanceId    : UUID,
            REQUEST_ID            as requestId     : UUID,
            REQUEST_CODE          as requestCode,
            TYPE_ID               as docType,
            STEP_ID               as stepId,
            FIELD                 as field,
            DOCUMENT_NAME         as documentName,
            DOCUMENT_VERSION      as version,
            DOCUMENT_URL          as fileUrl,
            USER_DOC              as user,
            CREATION_DATE_DOC     as documentCreationDate,
            DOCUMENT_SUBTYPE      as subType,
            DOCUMENT_SUBTYPE_LVL2 as subTypeLvl2,
            CREATEDAT             as createdAt,
            CREATEDBY             as createdBy,
            DELETED               as deleted,
            DELETED_BY            as deletedBy,
            MODIFIEDAT            as modifiedAt,
            MODIFIEDBY            as modifiedBy,
            DOCUMENT_ID           as documentId,
            OT_DOCUMENT_ID        as OTDocumentId,
            BLOCK_NAME            as blockName,
            PHASE_NAME            as phaseName,
            FINAL_DOCUMENT        as finalDocument,
            MEDIA_TYPE            as mediaType,
            WORK_ID               as workId,
            
            case
                when MEDIA_TYPE is null
                        then 'text/plain'
                else MEDIA_TYPE
            end                   as virtMediaType : String       @Core.IsMediaType               @core.computed: true,
            virtual null          as content       : LargeBinary  @Core.MediaType: virtMediaType  @Core.Computed: false
    }

    entity Works as projection on WORKS {
        key ID,
            status,
            description,
            responsibleType,
            externalType,
            comments,
            startDate         : Date @title: '{i18n>workStart}',
            endDate           : Date @title: '{i18n>workEnd}',
            expectedStartDate : Date @title: '{i18n>workStart}',
            expectedEndDate   : Date @title: '{i18n>workEnd}',
            realStartDate     : Date @title: '{i18n>workStart}',
            realEndDate       : Date @title: '{i18n>workEnd}',
            parentId,
            documentId,
            statusName,
            responsibleTypeName,
            externalTypeName,
            internalResponsibleName,
            externalResponsibleName,
            internalResponsible,
            externalResponsible,
            responsibleTypeFC,
            externalTypeFC,
            internalResponsibleFC,
            externalResponsibleFC,
            parentType,
            statusFC,
            descriptionFC,
            commentsFC,
            startDateFC,
            endDateFC,
            expectedStartDateFC,
            expectedEndDateFC,
            realStartDateFC,
            realEndDateFC,
            hasAuthVF,
            block             : redirected to Blocks
                                    on block.ID = parentId,
            documents,
            approvalFlows,
            type,
            LocalizedWorkTypesName : Association to one LocalizedWorkTypes on LocalizedWorkTypesName.code = type.ID
    } actions {
        action cancel(comments: String(1000) @UI.MultiLineText: true);
        action complete();
        action reopen();
        action addDocumentPerBlock(documentId: String);
    };

    entity ChecklistItems as projection on Checklist.Item {
        key ID,
            description,
            type,
            mandatory,
            booleanValue,
            stringValue,
            dateValue : Date @title: '{i18n>item.dateValue}',
            integerValue,
            decimalValue,
            pickList,
            block_ID,
            descriptionFC,
            booleanValueFC,
            stringValueFC,
            dateValueFC,
            integerValueFC,
            decimalValueFC,
            pickListFC,
            picklistValueName,
            rowStatus,
            refreshEntity,
            editable,
            block     : redirected to Blocks on block.ID = block_ID,
            deleted
    } where deleted != true;

    @cds.redirection.target
    entity Documents as projection on WF_DETAIL_DOCUMENTS {
        key REGISTER_ID           as ID            : UUID,
            BLOCK_ID              as blockId       : UUID,
            INSTANCE_ID           as instanceId    : UUID,
            REQUEST_ID            as requestId     : UUID,
            REQUEST_CODE          as requestCode,
            TYPE_ID               as docType,
            STEP_ID               as stepId,
            FIELD                 as field,
            DOCUMENT_NAME         as documentName,
            DOCUMENT_VERSION      as version,
            DOCUMENT_URL          as fileUrl,
            USER_DOC              as user,
            CREATION_DATE_DOC     as documentCreationDate,
            DOCUMENT_SUBTYPE      as subType,
            DOCUMENT_SUBTYPE_LVL2 as subTypeLvl2,
            CREATEDAT             as createdAt,
            CREATEDBY             as createdBy,
            DELETED               as deleted,
            DELETED_BY            as deletedBy,
            MODIFIEDAT            as modifiedAt,
            MODIFIEDBY            as modifiedBy,
            DOCUMENT_ID           as documentId,
            OT_DOCUMENT_ID        as OTDocumentId,
            BLOCK_NAME            as blockName,
            PHASE_NAME            as phaseName,
            FINAL_DOCUMENT        as finalDocument,
            MEDIA_TYPE            as mediaType,
            WORK_ID               as workId,
            documentTypeName,
            case
                when MEDIA_TYPE is null
                        then 'text/plain'
                else MEDIA_TYPE
            end                   as virtMediaType : String       @Core.IsMediaType               @core.computed: true,
            virtual null          as content       : LargeBinary  @Core.MediaType: virtMediaType  @Core.Computed: false
    } where DELETED      !=     true and DOCUMENT_URL is not null and DOCUMENT_URL !=     '';

    entity SupportDocuments as projection on WF_DETAIL_DOCUMENTS {
        key REGISTER_ID           as ID            : UUID,
            BLOCK_ID              as blockId       : UUID,
            INSTANCE_ID           as instanceId    : UUID,
            REQUEST_ID            as requestId     : UUID,
            REQUEST_CODE          as requestCode,
            TYPE_ID               as docType,
            STEP_ID               as stepId,
            FIELD                 as field,
            DOCUMENT_NAME         as documentName,
            DOCUMENT_VERSION      as version,
            DOCUMENT_URL          as fileUrl,
            USER_DOC              as user,
            CREATION_DATE_DOC     as documentCreationDate,
            DOCUMENT_SUBTYPE      as subType,
            DOCUMENT_SUBTYPE_LVL2 as subTypeLvl2,
            CREATEDAT             as createdAt,
            CREATEDBY             as createdBy,
            DELETED               as deleted,
            DELETED_BY            as deletedBy,
            MODIFIEDAT            as modifiedAt,
            MODIFIEDBY            as modifiedBy,
            DOCUMENT_ID           as documentId,
            OT_DOCUMENT_ID        as OTDocumentId,
            BLOCK_NAME            as blockName,
            PHASE_NAME            as phaseName,
            FINAL_DOCUMENT        as finalDocument,
            MEDIA_TYPE            as mediaType,
            WORK_ID               as workId,
            documentTypeName,
            canDelete,
            case
                when MEDIA_TYPE is null
                        then 'text/plain'
                else MEDIA_TYPE
            end                   as virtMediaType : String       @Core.IsMediaType               @core.computed: true,
            virtual null          as content       : LargeBinary  @Core.MediaType: virtMediaType  @Core.Computed: false
    };

    entity DocumentsPerBlocks as projection on DOCUMENTS_PER_BLOCK {
        key REGISTER_ID                 as ID,
            BLOCK_ID                    as blockId,
            CREATEDAT                   as createdAt,
            CREATEDBY                   as createdBy,
            DELETED                     as deleted,
            DELETED_AT                  as deletedAt,
            DELETED_BY                  as deletedBy,
            MODIFIEDAT                  as modifiedAt,
            MODIFIEDBY                  as modifiedBy,
            ORDER                       as order,
            RESPONSIBLE_ID              as responsibleId,
            SUBCONTRATOR_ID             as subcontractorId,
            T_RESPONSIBLE               as responsibleDefault,
            VALIDATION_CELLNEX_CLIENT   as cellnexValidation,
            VALIDATION_REQ_CLIENT       as customerValidation,
            VALIDATION_SUBCO_CLIENT     as subcontractorValidation,
            VALIDATION_SITEOWNER_NEEDED as siteOwnerValidation,
            GENERIC_TYPE_ID             as documentId,
            TYPE_ID                     as typeId,
            STATUS                      as status,
            PERMIT_ID                   as jointProjectId,
            STEP_ID                     as masterBlock_id,
            WORK_ID                     as workId,
            cellnexResponsible,
            subcontractorResponsible,
            agencyResponsible,
            customerResponsible,
            cellnexResponsibleName,
            subcontractorResponsibleName,
            agencyResponsibleName,
            customerResponsibleName,
            cellnexResponsibleFC,
            subcontractorResponsibleFC,
            agencyResponsibleFC,
            customerResponsibleFC,
            responsibleDefaultName,
            approverTypeName,
            subcoTypeName,
            approverTypeFC,
            subcoTypeFC,
            responsibleDefaultFC,
            cellnexValidationFC,
            subcontractorValidationFC,
            customerValidationFC,
            siteOwnerValidationFC,
            cellnexValidatorFC,
            subcontractorValidatorFC,
            customerValidatorFC,
            siteOwnerValidatorFC,
            Criticality,
            documentIdFC,
            stepIdVF,
            statusIconVF,
            statusStateVF,
            statusTextVF,
            cellnexStatusIconVF,
            cellnexStatusStateVF,
            cellnexStatusTextVF,
            responsibleStatusIconVF,
            responsibleStatusStateVF,
            responsibleStatusTextVF,
            subcontractorStatusIconVF,
            subcontractorStatusStateVF,
            subcontractorStatusTextVF,
            customerStatusIconVF,
            customerStatusStateVF,
            customerStatusTextVF,
            siteOwnerStatusIconVF,
            siteOwnerStatusStateVF,
            siteOwnerStatusTextVF,
            cellnexValidationVF,
            subcontractorValidationVF,
            customerValidationVF,
            siteOwnerValidationVF,
            cancellationReason,
            documentNameVF,
            siteOwnerValidationName,
            customerValidationName,
            subcontractorValidationName,
            cellnexValidationName,
            canInit,
            canSee,
            canDelete,
            canDownload,
            Blocks                : Association to one Blocks on Blocks.ID = ID,
            InstancesPerDocuments : Association to one InstancesPerDocuments on InstancesPerDocuments.instanceId = ID,
            ApproverTypes         : Association to one ApproverTypes on ApproverTypes.code = responsibleId,
            SubcoTypes            : Association to one SubcoTypes on SubcoTypes.code = subcontractorId,
    // DocumentsPerBlockDocumentIdVh: Association to one DocumentsPerBlockDocumentIdVh on DocumentsPerBlockDocumentIdVh.documentId = documentId and DocumentsPerBlockDocumentIdVh.BLOCK_ID = blockId
    } actions {
        //NOSONAR @(requires: ['TIS_WF_PRO_BTSMgr']) action onDocFlowFirstSave()               returns DocumentsPerBlocks;
        action nextStep() returns DocumentsPerBlocks;
        action docFlowFirstSave();
        action cancel(cancellationReason: String(2000));
    }

    @(restrict: [
        {grant: ['READ']},
        {grant: ['UPDATE']},
        {grant: ['DELETE']}
    ])
    entity DocumentsPerRequest as projection on DOCUMENTS_PER_REQUEST {
        *,
        Blocks                   : Association to one Blocks on Blocks.ID = ID,
        InstancesPerDocuments    : Association to one InstancesPerDocuments on InstancesPerDocuments.instanceId = ID,
        ApproverTypes            : Association to one ApproverTypes on ApproverTypes.code = responsibleId,
        SubcoTypes               : Association to one SubcoTypes on SubcoTypes.code = subcontractorId,
        DocumentFlowResponsibles : Association to one DocumentFlowResponsibles on DocumentFlowResponsibles.code = responsibleDefault
    }

    entity InstancesPerDocuments as projection on INSTANCES_PER_DOCUMENT {
        key REGISTER_ID                   as ID,
            CELLNEX_COMMENT               as cellnexComment,
            CELLNEX_VALIDATION            as cellnexValidation,
            CELLNEX_VALIDATION_DATE       as cellnexValidationDate       : Date @(title: '{i18n>cellnexValidationDate}'),
            CELLNEX_VALIDATOR             as cellnexValidator,
            CONTACT_EMAIL                 as contactEmail,
            CONTACT_PHONE                 as contactPhone,
            CREATEDAT                     as createdAt,
            CREATEDBY                     as createdBy,
            CUSTOMER_COMMENT              as customerComment,
            CUSTOMER_VALIDATION           as customerValidation,
            CUSTOMER_VALIDATION_DATE      as customerValidationDate      : Date @(title: '{i18n>clientValidationDate}'),
            CUSTOMER_VALIDATOR            as customerValidator,
            DELETED                       as deleted,
            DELETED_AT                    as deletedAt,
            DELETED_BY                    as deletedBy,
            DOC_PB_ID                     as jointProjectId,
            DOCUMENT_ID_DOSSIER_ATTACHED  as requestCodeOrigin,
            // DOCUMENT_ID_DOSSIER_ATTACHED: String(36)        @title: 'DOCUMENT_ID_DOSSIER_ATTACHED' ;
            // DOCUMENT_ID_SENT_CUSTOMER: String(36)           @title: 'DOCUMENT_ID_SENT_CUSTOMER' ;
            END_DATE                      as endDate                     : Date @(title: '{i18n>idpEndDate}'),
            INSTANCE_ID                   as instanceId,
            MODIFIEDAT                    as modifiedAt,
            MODIFIEDBY                    as modifiedBy,
            SITEOWNER_COMMENT             as siteOwnerComment,
            SITEOWNER_VALIDATION          as siteOwnerValidation,
            SITEOWNER_VALIDATION_DATE     as siteOwnerValidationDate     : Date @(title: '{i18n>siteOwnerValidationDate}'),
            SITEOWNER_VALIDATOR           as siteOwnerValidator,
            START_DATE                    as startDate                   : Date @(title: '{i18n>startDate}'),
            SUBCONTRACTOR_COMMENT         as subcontractorComment,
            SUBCONTRACTOR_VALIDATION      as subcontractorValidation,
            SUBCONTRACTOR_VALIDATION_DATE as subcontractorValidationDate : Date @(title: '{i18n>subcontractorValidationDate}'),
            SUBCONTRACTOR_VALIDATOR       as subcontractorValidator,
            SUBMISSION_DATE               as submissionDate : Date @(title: '{i18n>submissionDate}'),
            T_GO                          as tasksActivated,
            VERSION                       as version,
            BLOCK_ID                      as blockId,
            STEP_ID                       as stepId,
            STEP_TXT                      as stepName,
            ASSIGNED_ROLE                 as assignedRole,
            EXPECTED_SUBMISSION_DATE      as expectedSubmissionDate      : Date @(title: '{i18n>expectedSubmissionDate}'),
            EXPECTED_CUSTOMER_VAL         as expectedCustValidationDate,
            EXPECTED_CELLNEX_VAL          as expectedCellValidationDate,
            EXPIRATION_DATE               as expirationDate              : Date @(title: '{i18n>expirationDate}'),
            // EXPIRATION_DATE_MANDATORY: String(2)            @title: 'EXPIRATION_DATE_MANDATORY' ;
            // DOCUMENT_RESPONSIBLE_ROL: String(50)            @title: 'DOCUMENT_RESPONSIBLE_ROL' ;
            PLANNED_SUBMISSION_DATE       as plannedSubmissionDate,
            CANCELLATION_REASON           as cancellationReason,
            MODIFIEDBULK_AT               as modifiedBulkAt,
            MODIFIEDBULK_BY               as modifiedBulkBy,
            CREATEDBULK_AT                as createdBulkAt,
            CREATEDBULK_BY                as createdBulkBy,
            DELETEDBULK_AT                as deletedBulkAt,
            DELETEDBULK_BY                as deletedBulkBy,
            ASSIGNED_RESPONSIBLE          as assignedResponsible,
            // GROUP_ASSIGNED_RESPONSIBLE: String(100)         @title: 'GROUP_ASSIGNED_RESPONSIBLE' ;
            SUBCO_ASSIGNED                as assignedSubcontractor,
            // SUBCO_GROUP_ASSIGNED: String(100)               @title: 'SUBCO_GROUP_ASSIGNED' ;
            FORECAST_NA                    as forecastNA,
            DOCUMENT_ID_SENT_CUSTOMER      as taskCode,
            CUSTOMER_INFORM_DATE           as customerInformDate : Date @(title: '{i18n>customerInformDate}'),
            DOCUMENTS_RESPONSIBLE_COMMENTS as documentsResponsibleComments,
            LIMIT_SUBMISSION_DATE          as limitSubmissionDate : Date @(title: '{i18n>limitSubmissionDate}'),
            contactEmailFC,
            contactPhoneFC,
            endDateFC,
            startDateFC,
            submissionDateFC,
            cellnexValidationCommentsFC,
            subcontractorValidationCommentsFC,
            customerValidationCommentsFC,
            siteOwnerValidationCommentsFC,
            cellnexValidationDateFC,
            subcontractorValidationDateFC,
            customerValidationDateFC,
            siteOwnerValidationDateFC,
            cellnexValidatorFC,
            subcontractorValidatorFC,
            customerValidatorFC,
            siteOwnerValidatorFC,
            cellnexValidationFC,
            subcontractorValidationFC,
            customerValidationFC,
            siteOwnerValidationFC,
            expirationDateFC,
            customerInformDateFC,
            expectedSubmissionDateFC,
            approverTypeName,
            subcoTypeName,
            responsibleDefaultNameVF,
            cellnexValidationVF,
            subcontractorValidationVF,
            customerValidationVF,
            siteOwnerValidationVF,
            blockIdVF,
            stepIdFC,
            buttonCompleteVF,
            documentIdVF,
            documentNameVF,
            cellnexValidatorName,
            siteOwnerValidatorName,
            customerValidatorName,
            subcontractorValidatorName,
            taskCodeFC,
            DocumentsPerBlocks                                           : Association to one DocumentsPerBlocks on DocumentsPerBlocks.ID = instanceId,
            Documents                                                    : Association to many Documents on Documents.instanceId = ID,
            LocalDocuments                                               : Association to many LocalDocuments on LocalDocuments.instanceId = ID,
            PreferredProviders                               : Association to one PreferredProviders on PreferredProviders.code = subcontractorValidator
    } actions {
        action cancel(cancellationReason: String(2000));
    }

    @Capabilities.Updatable: false @Capabilities.Deletable: false 
    entity Chats as projection on WF_CHAT {
        key REQUEST_ID as ID,
        key USER_ID    as userId,
        key TIME       as date,
            TEXT       as text,
            READ       as readed,
    }

    @readonly entity Customers(p_siteId: String(30)) as projection on CUSTOMERS(p_siteId: :p_siteId);

    @Capabilities.Insertable: false @Capabilities.Updatable: true @Capabilities.Deletable: false @Capabilities.Readable: true
    entity ImpactedCustomers {
        key requestId:  UUID;
        key siteId: String(30)              @(title: '{i18n>siteId}')           @readonly;    
        key customerId: String(10)          @(title: '{i18n>customer}')         @readonly;
            siteName: String(60)            @(title: '{i18n>siteName}')         @readonly;
            customerName: String(100)       @readonly;
            alias: String(80)               @(title: '{i18n>alias}')            @readonly;
            aliasName: String(80)           @(title: '{i18n>aliasName}')        @readonly;
            aliasServ: String(120)          @(title: '{i18n>aliasService}')     @readonly;
            aliasOther: String(120)         @(title: '{i18n>aliasOther}')       @readonly;
            aliasClientArea: String(30)     @(title: '{i18n>aliasClientArea}')  @readonly;
            aliasKey: String(1)             @(title: '{i18n>aliasKey}')         @readonly;
            impacted: Boolean               @(title: '{i18n>impacted}');
            impactedFC:UInt8;
    }    

    entity ContractRestrictions as projection on MASTER_MS_CONTRACT_RESTRICTIONS {
        key CONTRACT_RESTRICTIONS_ID as contractRestrictionId,
        key BLOCK_ID,
            // contractRestrictionId @(title: '{i18n>contractRestrictions}'),
            CONTRACT_RESTRICTIONS_TXT,
            DELETED,
            DELETEDAT,
            DELETEDBY,
            contractRestrictionIdUI,
            contractRestrictionIdFC,
            ContractRestrictionsVH: Association to one ContractRestrictionVH on ContractRestrictionsVH.code = contractRestrictionId
    } where DELETED = false;

    //Helper Entities for value helps
    @readonly entity AcceptedRejected                           as projection on ACCEPTED_REJECTED;
    @readonly entity BlockStatus                                as projection on localized_BLOCK_STATUS;
    @readonly entity DocumentFlows                              as projection on DOCUMENT_FLOWS;
    @readonly entity DocumentFlowStatus                         as projection on localized_DOCUMENT_FLOW_STATUS;
    @readonly entity OnHoldReasons                              as projection on ON_HOLD_REASONS;
    @readonly entity PhaseStatus                                as projection on localized_PHASE_STATUS;
    @readonly entity ProcessTypes                               as projection on PROCESS_TYPES;
    @readonly entity RequestStatus                              as projection on localized_REQUEST_STATUS;
    @readonly entity RequestTypes                               as projection on REQUEST_TYPE where REQUEST_TYPE = 40;
    @readonly entity SearchTypes                                as projection on localized_SEARCH_TYPES;
    @readonly entity StatusHead                                 as projection on localized_STATUS_HEAD where code in ( 2, 3, 4, 7, 12, 13 );
    @readonly entity TaskTypes                                  as projection on localized_TASK_TYPES;
    @readonly entity CancellationReasons                        as projection on CANCELLATION_REASONS;
    @readonly entity ChangesLog                                 as projection on CHANGE_LOG;
    @readonly entity Classifications                            as projection on CLASSIFICATIONS;
    @readonly entity PreferredProviders                         as projection on PREFERRED_PROVIDERS;
    @readonly entity ApproverTypes                              as projection on APPROVER_TYPES;
    @readonly entity SubcoTypes                                 as projection on SUBCO_TYPES where code in ( 3, 4 );
    @readonly entity YesNoFields                                as projection on YES_NO_FIELDS;
    @readonly entity ValidationDocs                             as projection on VALIDATIONS_DOCS;
    @readonly entity RequestTypesLinked                         as projection on REQUEST_TYPE where REQUEST_TYPE in ( 4, 10, 11, 1, 3, 2, 20, 30, 40 );
    @readonly entity WorkTypes                                  as projection on WORK_TYPES;
    @readonly entity WorkDocuments                              as projection on WORK_DOCUMENTS_VH;
    @readonly @odata.draft.enabled: false entity ProjectObjectives as projection on PROJECT_OBJECTIVES_CONFIG_BY_PROCESS;
    @readonly entity DocumentsPerProcess                        as projection on DOCUMENTS_PER_PROCESS;
    @readonly entity FeasibilitiesWithRisks                     as projection on FEASIBILITIES_WITH_RISKS;
    @readonly entity Risks                                      as projection on RISKS;
    @readonly entity AdaptionsNeededFields                      as projection on ADAPTIONS_NEEDED_FIELDS;
    @readonly entity AutomaticFields                            as projection on AUTOMATIC_FIELDS;
    @readonly entity RejectionReasons                           as projection on REJECTION_REASONS;
    @readonly @odata.draft.enabled: false @cds.redirection.target entity ItemTypeValues as projection on Checklist.localized_ItemTypeValue where active = true;
    @readonly @odata.draft.enabled: false @cds.redirection.target entity ItemTypes      as projection on Checklist.localized_ItemType where active = true;
    @readonly entity Complexities                               as projection on COMPLEXITIES;
    @readonly entity MadResults                                 as projection on MAD_RESULTS;
    @readonly entity AdaptionsTypes                             as projection on ADAPTIONS_TYPES;
    @readonly entity CellnexZones                               as projection on CELLNEX_ZONES;
    @readonly entity Zones                                      as projection on ZONES;
    @readonly entity InfraOrigins                               as projection on INFRA_ORIGINS;
    @readonly entity InfraOwnerships                            as projection on INFRA_OWNERSHIPS;
    @readonly entity InfraStatus                                as projection on INFRA_STATUS;
    @readonly entity Marketables                                as projection on MARKETABLES;
    @readonly entity ABFZones                                   as projection on ABF_ZONES;
    @readonly entity ManagingCompanies                          as projection on MANAGING_COMPANIES;
    @readonly entity CellnexProjects                            as projection on CELLNEX_PROJECTS;
    @readonly entity Exploiteds                                 as projection on EXPLOITEDS;
    @readonly entity Companies                                  as projection on T001;
    @readonly entity Regions                                    as projection on REGIONS;
    @readonly entity RepaymentStatus                            as projection on REPAYMENT_STATUS;
    @readonly entity ProjectTypes                               as projection on PROJECT_TYPES;
    @readonly entity AuxProjectTypes                            as projection on AUX_PROJECT_TYPES;
    @readonly entity MoaOperationTypes                          as projection on MOA_OPERATION_TYPES;
    @readonly entity ProjectObjectivesCountry                   as projection on PROJECT_OBJECTIVES_BY_COUNTRY;
    @readonly entity ContractRestrictionVH                      as projection on CONTRACT_RESTRICTIONS_OPTIONS;
    @readonly entity FeasibilityExplanations                    as projection on FEASIBILITY_EXPLANATION_OPTIONS;
    @readonly entity InternalPhases                             as projection on INTERNAL_PHASES ;//order by ORDER;
    @readonly entity InternalBlocks                             as projection on INTERNAL_BLOCKS order by phaseOrder, blockOrder;
    @readonly entity BooleanValues                              as projection on BOOLEAN_VALUES;
    @readonly entity LocalizedWorkTypes                         as projection on LOCALIZED_WORKTYPES;

    @readonly entity Sites                                      as projection on SITES {
        key siteId,
            AOTYPE,
            primaryLegacyCode,
            legacyCode,
            siteName,
            company,
            cellnexZone,         //ZOPE
            zone,                //ZONE
            infraOrigin,         //ORIG
            infraOwnership,      //OWSH
            infraStatus,         //ICST
            marketableId,        //COME
            abfZone,             //ABFZ
            managingCompany,     //TITU
            cellnexProject,      //PROY
            exploited,           //EXSI
            comunity,
            country,
            region,
            city,
            postalCode                       @(title: '{i18n>postalCode}'),
            street,
            houseNumber,
            floor,
            productionZoneResponsible,
            productionZoneResponsibleName,
            siteManagerZoneResponsible,
            siteManagerZoneResponsibleName,
            productionRegionManager,
            productionRegionManagerName,
            regionSiteManager,
            regionSiteManagerName,
            productionManager,
            productionManagerName,
            siteManager,
            siteManagerName,
            landlordName                    @(title: '{i18n>landlordName}'),
            Companies               : Association to one Companies on Companies.BUKRS = company,
            CellnexZones            : Association to one CellnexZones on CellnexZones.code = cellnexZone,
            Zones                   : Association to one Zones on Zones.code = zone,
            InfraOrigins            : Association to one InfraOrigins on InfraOrigins.code = infraOrigin,
            InfraOwnerships         : Association to one InfraOwnerships on InfraOwnerships.code = infraOwnership,
            InfraStatus             : Association to one InfraStatus on InfraStatus.code = infraStatus,
            Marketables             : Association to one Marketables on Marketables.code = marketableId,
            ABFZones                : Association to one ABFZones on ABFZones.code = abfZone,
            ManagingCompanies       : Association to one ManagingCompanies on ManagingCompanies.code = managingCompany,
            CellnexProjects         : Association to one CellnexProjects on CellnexProjects.code = cellnexProject,
            Exploiteds              : Association to one Exploiteds on Exploiteds.code = exploited,
            Regions                 : Association to one Regions on Regions.country = country and Regions.code = region
    };

    @cds.odata.valuelist @UI.Identification: [{Value: phaseName}]
    @readonly entity PhasesPerProcess                           as projection on PHASES_PER_PROCESS;
    
    @cds.odata.valuelist @UI.Identification: [{Value: blockName}] @readonly
    entity BlocksPerProcess                           as projection on BLOCKS_PER_PROCESS;

    @readonly entity DocumentFlowDocumentId {
        key documentId   : String(10)  @(title: '{i18n>documentId}');
            documentName : String(100) @(title: '{i18n>documentName}');
            ID           : UUID;
    }

    @readonly entity PMOManagers as projection on PMO_MANAGERS {
        key userId   : String(100) @(
                            title      : '{i18n>userId}',
                            Common.Text: userName
                        ),
            userName : String(100) @(title: '{i18n>userName}'),
            country
    };

    @readonly entity Managers as projection on MANAGERS {
        key userId   : String(100) @(title: '{i18n>userId}'),
            userName : String(100) @(title: '{i18n>userName}'),
            country
    };

    @readonly entity Requesters as projection on REQUESTERS {
        key userId   : String(100) @(title: '{i18n>userId}'),
            userName : String(100) @(title: '{i18n>userName}'),
            country
    };

    @readonly entity InternalUsers {
        key userId    : String  @title: '{i18n>userId}'     @(Common.Text   : userName);
            userName  : String  @title: '{i18n>userName}';
            email     : String  @title: '{i18n>email}';
            telephone : String  @title: '{i18n>telephone}';
            country   : String  @title: '{i18n>country}';
            iasGroup  : String  @title: '{i18n>iasgroup}';
            requestId : String  @title: '{i18n>requestId}'  @UI.HiddenFilter: true;
            blockId   : String  @title: '{i18n>blockId}'    @UI.HiddenFilter: true;
    }

    @readonly entity ExternalUsers {
        key code        : String(10)  @( title: '{i18n>userId}', Common.Text: name );
            name        : String(100) @(title          : '{i18n>userName}');
            blockId     : UUID        @(UI.HiddenFilter: true);
            objectType  : String(5);
    }

    //Aux entities
    @(restrict: [{ grant: 'READ', where: 'userId = $user' }])
    @cds.odata.valuelist @UI.Identification: [{Value: name}]
    entity CacheR3Entities as projection on CACHE_R3_ENTITIES {
        key USER_ID     as userId     : String(100)  @assert.target                      @UI.Hidden,
        key ENTITY_TYPE as entityType : String(50)   @assert.target                      @UI.Hidden,
        key ENTITY_ID   as code       : String(50)   @title: '{i18n>preferredProvider}'  @(Common.Text: name),
            ENTITY_NAME as name       : String(120)  @title: '{i18n>name}',
            CREATED_AT  as createdAt  : Timestamp    @assert.target                      @UI.Hidden
    };

    @readonly entity singleRequestProcess(p_requestId: UUID)    as projection on SINGLE_REQUEST_PROCESS(p_requestId : :p_requestId);

    @readonly entity lastActivePhases(p_requestId: UUID)        as projection on LAST_ACTIVE_PHASES(p_requestId : :p_requestId) {
        LAST_PHASE as lastPhase
    }

    @readonly entity Services                                   as projection on ZTIS_SRV_SERVICES_SRV.CtRequestprovisiSet;
    entity ServicesECC {
        key Zzidintern       : String; // Mapeado de item.serviceId
            Idrequest        : String; // Mapeado de item.requestId
            Zzclass          : String; // Mapeado de item.instanceClass
            Zzclasstxt       : String; // Mapeado de item.instanceClassDescription
            Zzservid         : String; // Mapeado de item.serviceName
            ZzserviceCatalog : String; // Mapeado de item.catalogId
            ZzservcatDesc    : String; // Mapeado de item.catalogName
            ZzopStatus       : String; // Mapeado de item.operativeStatus
            ZzopStatusDesc   : String; // Mapeado de item."Active"
            ZzinvStatus      : String; // Mapeado de item.invoiceStatus
            InvstDesc        : String; // Mapeado de item.invoiceStatusDescription
            Zzbusinessprtnr  : String; // Mapeado de item.customerId
            ZzbpDesc         : String; // Mapeado de item.customerName
            Zzstartdate      : Date;   // Mapeado de item.startDate
            Zzenddate        : Date;   // Mapeado de item.endDate
            Zzcontractnumber : String; // Mapeado de item."" MAPPING not found
            Zzlegacy         : String; // Mapeado de item.legacyId
            Zzsellerdesc     : String; // Mapeado de item.companyName
            Zzseller         : String; // Mapeado de item.companyCode
            Agreement        : String; // Mapeado de item."" MAPPING not found
            zcompliance      : Boolean; // Mapeado de item.zcompliance
    }

    @readonly entity DtLinkedRequestPossibleChildrenRequestList as projection on DtLinkedRequestPossibleChildrenRequest;
    @readonly entity SearchDtLinkedRequestSet                   as projection on SearchDtLinkedRequest;

    entity DtLinkedRequest                                      as projection on DT_LINKED_REQUEST {
        key LINK_ID            as linkID,
            ASSOCIATION_TYPE   as associationType,
            PARENT_REQUEST_ID  as parentRequestID,
            PARENT_INSTANCE_ID as parentInstanceID,
            PARENT_WORKFLOW_ID as parentWorkflowID,
            CHILD_REQUEST_ID   as childRequestID,
            CHILD_INSTANCE_ID  as childInstanceID,
            CHILD_WORKFLOW_ID  as childWorkflowID,
            DELETED            as deleted,
            DELETED_AT         as deletedAt,
            DELETED_BY         as deletedBy
    }

    @readonly entity firstInprogressPhase(p_requestId: UUID)    as projection on FIRST_INPROGRESS_PHASE(p_requestId : :p_requestId) {
        MASTER_PHASE_ID as processFlowId
    }

    @readonly entity AfterCreateExits {
        key ID: String(100) @title: '{i18n>exitName}';
    }

    @readonly entity AfterReadExits {
        key ID: String(100) @title: '{i18n>exitName}';
    }

    @readonly entity AfterUpdateExits {
        key ID: String(100) @title: '{i18n>exitName}';
    }

    //Unbound actions
    action newRequestDocument(requestId: UUID, phaseId: String(20), blockId: String(20), documentId: String(50));
    action getRequestAllowedActions()                                 returns RequestAllowedActions;
    action getBlocksAllowedActions(requestId: UUID)                   returns BlockAllowedActions;
    action getDefaultCreationFields()                                 returns DefaultCreationOptions;
    action refreshR3EntitiesCache()                                   returns String;
    action linkRequestsDetailed(parentRequestID: String, parentInstanceID: String, parentWorkflowID: String, children: LargeString, associationType: String default null) returns String;
    action getPhasesStatus(requestId: UUID)                           returns array of PhasesStatus;
    //NOSONAR action newJointDocument(requestId:UUID, phaseId:String(20), blockId:String(20), candidateId: String(20), hasCandidate: Boolean, documentId:String(50));
    //NOSONAR action getCandidateAllowedActions(requestId: UUID, candidateId: String(50)) returns BlockAllowedActions;
    //NOSONAR action cleanOtlocalTable();

    // Standard request linking
    @readonly @cds.odata.valuelist @UI.Identification: [{Value: name}]
    entity DocumentFlowResponsibles {
        key code : String(10)  @(
                title                           : '{i18n>userId}',
                Common.Text                     : name
            );
            name : String(100) @(title          : '{i18n>userName}');
            ID   : UUID        @(UI.HiddenFilter: true);
    }

    entity DocumentViewerNodes as projection on DOCUMENT_VIEWER_NODES {
        key NODE_ID         as nodeId,
            HIERARCHY_LEVEL as hierarchyLevel,
            PARENT_NODE_ID  as parentNodeId,
            DRILL_STATE     as drillState,
            DESCRIPTION     as description,
            DOCUMENT_ID     as documentId,
            CREATED_BY      as createdBy,
            CREATED_AT      as createdAt : Date,
            REQUEST_ID      as requestId,
            Childrens                    : Association to many DocumentViewerNodes
                                                on Childrens.parentNodeId = nodeId
    }

    @readonly @cds.odata.valuelist @UI.Identification: [{Value: name}]
    entity DocumentFlowResponsiblesDefaultValid {
        key code : String(10)  @(
                title                           : '{i18n>userId}',
                Common.Text                     : name
            );
            name : String(100) @(title          : '{i18n>userName}');
            ID   : UUID        @(UI.HiddenFilter: true);
    }

    @readonly @cds.odata.valuelist @UI.Identification: [{Value: documentName}]
    entity DocumentFlowDefaultValidDocumentId {
        key documentId   : String(10)  @(
                title                                   : '{i18n>documentId}',
                Common.Text                             : documentName
            );
            documentName : String(100) @(title          : '{i18n>userName}');
            ID           : UUID        @(UI.HiddenFilter: true);
    }
     entity AttachmentDocumentTypes                                      as
        select
            key DF.documentId,
            key BH.BLOCK_ID,
                DF.documentName,
                DF.documentType,
                DF.documentSubtype,
                DF.documentSubType2
        from DOCUMENT_FLOWS as DF
        inner join REQUEST_HEAD as RH on RH.COUNTRY_ID = DF.countryId
        inner join PHASE_HEAD as PH on PH.REQUEST_ID = RH.REQUEST_ID
        inner join BLOCK_HEAD as BH on BH.PHASE_ID = PH.PHASE_ID
        where
            DF.enableAttachments = true;

}
