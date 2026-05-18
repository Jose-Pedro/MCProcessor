using { managed, cuid, sap.common.CodeList as CodeList } from '@sap/cds/common';
using { BLOCK_HEAD, WF_DETAIL_DOCUMENTS, DOCUMENTS_PER_BLOCK } from './cellnex';
using { DOCUMENT_FLOWS } from './document';
using { PROCESS } from './processflow';

@cds.persistence.exists 
entity WORKS : cuid, managed { 
    key ID : UUID;
    status: Integer                     @title: '{i18n>status}';
    description : String(100)           @title: '{i18n>description}';
    responsibleType: Integer            @title: '{i18n>responsibleType}';
    externalType: Integer               @title: '{i18n>externalType}';
    internalResponsible : String(100)   @title: '{i18n>internalResponsible}';
    externalResponsible : String(100)   @title: '{i18n>externalResponsible}';
    comments : String(1000)             @title: '{i18n>comments}';
    startDate : Timestamp               @title: '{i18n>workStart}';
    endDate : Timestamp                 @title: '{i18n>workEnd}';
    expectedStartDate : Timestamp       @title: '{i18n>workStart}';
    expectedEndDate : Timestamp         @title: '{i18n>workEnd}';
    realStartDate : Timestamp           @title: '{i18n>workStart}';
    realEndDate : Timestamp             @title: '{i18n>workEnd}';
    parentId : UUID                     @title: '{i18n>parentId}';
    virtual documentId :String(50)      @title: '{i18n>documentType}' @Core.Computed: false;
    virtual dpbVisibleVF : Boolean default false            @title: '{i18n>dpbVisible}' ;
    virtual statusName : String(200);
    virtual responsibleTypeName : String(200);
    virtual externalTypeName : String (200);
    virtual internalResponsibleName: String(200);
    virtual externalResponsibleName: String(200);
    virtual internalResponsibleFC              : UInt8 default 3;
    virtual externalResponsibleFC              : UInt8 default 3;
    virtual responsibleTypeFC               : UInt8 default 3;
    virtual externalTypeFC                  : UInt8 default 3;
    virtual statusFC: UInt8 default 3;
    virtual descriptionFC : UInt8 default 3;
    virtual commentsFC : UInt8 default 3;
    virtual startDateFC : UInt8 default 3;
    virtual endDateFC : UInt8 default 3;
    virtual expectedStartDateFC : UInt8 default 3;
    virtual expectedEndDateFC : UInt8 default 3;
    virtual realStartDateFC : UInt8 default 3;
    virtual realEndDateFC : UInt8 default 3;
    virtual hasAuthVF : UInt8 default 3;
    parentType: Association to one WORK_PARENT_TYPES;
    block : Association to one BLOCK_HEAD on block.BLOCK_ID = parentId;
    documents : Association to many WF_DETAIL_DOCUMENTS on documents.WORK_ID = ID;
    approvalFlows: Association to many DOCUMENTS_PER_BLOCK on approvalFlows.WORK_ID = ID;
    type : Association to one WORK_TYPES;
}

@cds.persistence.exists
@odata.draft.enabled 
entity PROJECT_OBJECTIVES : managed, CodeList {
    key ID          : Integer    @(Common.Text: name);
        translations: Composition of many PROJECT_OBJECTIVES.texts on translations.ID = ID;
}

@cds.persistence.exists 
entity PROJECT_OBJECTIVES.texts {
    key LOCALE      : String(14)    @title: '{i18n>locale}' ; 
        NAME        : String(255)   @title: '{i18n>name}' ; 
        DESCR       : String(1000)  @title: '{i18n>description}' ; 
    key ID          : Integer       @title: '{i18n>objectiveId}' ;
        parent      : Association to one PROJECT_OBJECTIVES on parent.ID = ID;
}

@cds.persistence.exists 
@odata.draft.enabled 
entity WORK_TYPES : managed, CodeList {
    key ID : Integer    @(Common.Text: name); 
        translations: Composition of many WORK_TYPES.texts on translations.ID = ID;
}

@cds.persistence.exists 
entity WORK_TYPES.texts {
    key LOCALE      : String(14)    @title: '{i18n>locale}' ; 
        NAME        : String(255)   @title: '{i18n>name}' ; 
        DESCR       : String(1000)  @title: '{i18n>description}' ; 
    key ID          : Integer       @title: '{i18n>workTypeId}' ; 
        parent      : Association to one WORK_TYPES on parent.ID = ID;
}

@cds.persistence.exists 
@odata.draft.enabled 
entity WORK_PARENT_TYPES : managed, CodeList {
    key ID : Integer    @(Common.Text: name);
        translations: Composition of many WORK_PARENT_TYPES.texts on translations.ID = ID;
}

@cds.persistence.exists 
entity WORK_PARENT_TYPES.texts {
    key LOCALE      : String(14)    @title: '{i18n>locale}' ; 
        NAME        : String(255)   @title: '{i18n>name}' ; 
        DESCR       : String(1000)  @title: '{i18n>description}' ; 
    key ID          : Integer       @title: '{i18n>workTypeId}' ; 
        parent      : Association to one WORK_PARENT_TYPES on parent.ID = ID;
}

@cds.persistence.exists 
@odata.draft.enabled 
entity WORK_CONFIGS: managed, cuid {
    description             : String(200) @title : '{i18n>description}';
    FlowsPerProcess         : Composition of many WORK_CONFIG_PROCESSES on FlowsPerProcess.Configuration = $self;
    Objectives              : Composition of many WORK_CONFIG_OBJECTIVES on Objectives.Configuration = $self;
    Documents               : Composition of many WORK_CONFIG_DOCUMENT_FLOWS on Documents.Configuration = $self;
    DocumentDefaults        : Composition of many WORK_CONFIG_DOCUMENT_DEFAULTS on DocumentDefaults.Configuration = $self;
}

@cds.persistence.exists 
entity WORK_CONFIG_OBJECTIVES: managed, cuid {
    objective               : Association to PROJECT_OBJECTIVES;
    Configuration           : Association to WORK_CONFIGS;
}

@cds.persistence.exists 
entity WORK_CONFIG_PROCESSES: managed, cuid {
    processFlowId           : Integer;
    phaseTypeId             : String(50);
    blockTypeId             : String(50);
    default                 : Boolean;
    Type                    : Association to WORK_TYPES;
    Configuration           : Association to WORK_CONFIGS;
}

@cds.persistence.exists 
entity WORK_CONFIG_DOCUMENT_FLOWS: cuid, managed {
    documentId: String(50) @title: '{i18n>documentId}';
    WorkType: Association to WORK_TYPES;
    Configuration: Association to WORK_CONFIGS;
}

@cds.persistence.exists 
entity WORK_CONFIG_DOCUMENT_DEFAULTS: cuid, managed, CodeList {
    documentId                      : String(50) @title: '{i18n>documentId}';
    approverType                    : Integer    @title: '{i18n>approverType}';
    externalType                    : Integer    @title: '{i18n>externalType}';
    subcontractorValidationReq      : Boolean    @title: '{i18n>subcontractorValidationReq}';
    cellnexValidationReq            : Boolean    @title: '{i18n>cellnexValidationReq}';
    customerValidationReq           : Boolean    @title: '{i18n>customerValidationReq}';
    landlordValidationReq           : Boolean    @title: '{i18n>landlordValidationReq}';
    default                         : Boolean    @title: '{i18n>default}';
    deleted                         : Boolean    @title: '{i18n>deleted}';
    Configuration: Association to WORK_CONFIGS;   
}

@cds.persistence.exists 
entity WORK_CONFIG_DOCUMENT_DEFAULTS.texts {
key     LOCALE: String(14)  @title: 'LOCALE' ; 
key     ID: String(36)  @title: 'ID' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
}

entity WORK_DOCUMENTS_VH as select
    key document.documentId,
        otDocuments.documentName,
        otDocuments.countryId,
        objective.objective.ID as objective,
        process.processFlowId,
        process.phaseTypeId,
        process.blockTypeId,
        process.Type.ID     as workType,
        ''                  as workId:String(36)
    from WORK_CONFIG_DOCUMENT_FLOWS as document
    left outer join DOCUMENT_FLOWS as otDocuments on otDocuments.documentId = document.documentId
    inner join WORK_CONFIGS as configuration on configuration.ID = document.Configuration.ID
    inner join WORK_CONFIG_OBJECTIVES as objective on objective.Configuration.ID = configuration.ID 
    inner join WORK_CONFIG_PROCESSES as process on process.Configuration.ID = configuration.ID;

entity WORK_CONFIG_BY_PROCESS as select
    key tc.ID,
        tp.processFlowId,
        tp.phaseTypeId,
        tp.blockTypeId,
        tp.Type.ID as type,
        tp.default,
        to.objective
from WORK_CONFIGS as tc
inner join WORK_CONFIG_PROCESSES as tp on tp.Configuration.ID = tc.ID
inner join WORK_CONFIG_OBJECTIVES as to on to.Configuration.ID = tc.ID;

entity WORK_CONFIG_DOCS_BY_PROCESS as select
    key tc.ID,
        tp.processFlowId,
        tp.phaseTypeId,
        tp.blockTypeId,
        tp.Type.ID as type,
        tp.default as defaulted,
        to.objective,
        tdf.documentId,
        tdd.approverType,   
        tdd.externalType,   
        tdd.subcontractorValidationReq, 
        tdd.cellnexValidationReq,   
        tdd.customerValidationReq,  
        tdd.landlordValidationReq,  
        tdd.default as docdefaulted
from WORK_CONFIGS as tc
inner join WORK_CONFIG_PROCESSES as tp on tp.Configuration.ID = tc.ID
inner join WORK_CONFIG_OBJECTIVES as to on to.Configuration.ID = tc.ID
left outer join WORK_CONFIG_DOCUMENT_FLOWS as tdf on tdf.Configuration.ID = tc.ID and tdf.WorkType.ID = tp.Type.ID
left outer join WORK_CONFIG_DOCUMENT_DEFAULTS as tdd on tdd.Configuration.ID = tdf.Configuration.ID and tdd.documentId = tdf.documentId;

entity PROJECT_OBJECTIVES_CONFIG_BY_PROCESS as select distinct
    key to.objective.ID,
        COALESCE(pt.NAME, po.name) as name:String(255),
        p.PROGRAM
from WORK_CONFIGS as tc
inner join WORK_CONFIG_PROCESSES as tp on tp.Configuration.ID = tc.ID
inner join PROCESS as p on p.ID_PK = tp.processFlowId
inner join WORK_CONFIG_OBJECTIVES as to on to.Configuration.ID = tc.ID
inner join PROJECT_OBJECTIVES as po on po.ID = to.objective.ID
left outer join PROJECT_OBJECTIVES.texts as pt on pt.ID = po.ID and pt.LOCALE = SESSION_CONTEXT('LOCALE');

entity PROJECT_OBJECTIVES_BY_COUNTRY as select distinct
    key to.objective.ID,
        COALESCE(pt.NAME, po.name) as name:String(255),
        p.COUNTRY_CODE as country
from WORK_CONFIGS as tc
inner join WORK_CONFIG_PROCESSES as tp on tp.Configuration.ID = tc.ID
inner join PROCESS as p on p.ID_PK = tp.processFlowId
inner join WORK_CONFIG_OBJECTIVES as to on to.Configuration.ID = tc.ID
inner join PROJECT_OBJECTIVES as po on po.ID = to.objective.ID
left outer join PROJECT_OBJECTIVES.texts as pt on pt.ID = po.ID and pt.LOCALE = SESSION_CONTEXT('LOCALE');

entity LOCALIZED_WORKTYPES as 
    select 
        key w.ID as code,
        COALESCE(wt.NAME, w.name) as name:String(255)
      from WORK_TYPES as w
      left outer join WORK_TYPES.texts as wt on wt.ID = w.ID
                                            and wt.LOCALE = SESSION_CONTEXT('LOCALE');