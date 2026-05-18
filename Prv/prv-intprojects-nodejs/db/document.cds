using { cuid, managed } from '@sap/cds/common';
using {
    BLOCK_HEAD,
    REQUEST_HEAD,
    PHASE_HEAD,
    REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID,
    DT_LINKED_REQUEST,
    DOCUMENTS_PER_BLOCK,
    INSTANCES_PER_DOCUMENT,
    WF_DETAIL_DOCUMENTS
} from './cellnex';
using {
    PROCESS,
    PHASE,
    MASTER_PHASE,
    MASTER_BLOCK,
    BLOCK
} from './processflow';
using { WORKS } from './works';

@cds.persistence.exists
entity DOCUMENT_FLOWS : cuid, managed {
    documentId       : String(50)   @title: '{i18n>documentId}';
    documentName     : String(500)  @title: '{i18n>documentName}';
    documentType     : String(500)  @title: '{i18n>documentType}';
    documentSubtype  : String(500)  @title: '{i18n>documentSubtype}';
    documentSubType2 : String(500)  @title: '{i18n>documentSubtype2}';
    countryId        : String(3)    @title: '{i18n>countryId}';
    enableAttachments: Boolean      @title: '{i18n>enableAttachments}';
}

@cds.persistence.exists
entity DOCUMENT_FLOWS_PER_CONFIG : cuid, managed {
    // key ID                              : UUID       @title: '{i18n>Id}';
    // documentId                      : String(50) @title: '{i18n>documentId}';
    // configurationId                 : Integer64  @title: '{i18n>processFlowId}';
    configurationDescription        : String(50) @title: '{i18n>configurationDescription}';
    virtual documentIdFC            : UInt8 default 1;
    virtual processFlowIdFC         : UInt8 default 1;
    DELETED                         : Boolean    @title: '{i18n>deleted}';
    DELETED_AT                      : Timestamp    @title: '{i18n>deletedAt}';
    DELETED_BY                      : String(100) @title: '{i18n>deletedBy}';
    DocumentFlowValidators     : Composition of many DOCUMENT_FLOW_VALIDATORS
                                     on DocumentFlowValidators.DocumentFlowsPerConfig = $self;
    DocumentFlowsPerBlock      : Composition of many DOCUMENT_FLOWS_PER_BLOCK
                                     on DocumentFlowsPerBlock.DocumentFlowsPerConfig = $self;
    DocumentFlowsHiddenPerRole : Composition of many DOCUMENT_FLOWS_HIDDEN_PER_ROLE
                                     on DocumentFlowsHiddenPerRole.DocumentFlowsPerConfig = $self;
    DocumentFlowsPerProcess    : Composition of many DOCUMENT_FLOWS_PER_PROCESS on DocumentFlowsPerProcess.Configuration = $self;
}

@cds.persistence.exists
entity DOCUMENT_FLOWS_PER_PROCESS: cuid, managed {
    processId:              Integer64                     @title: '{i18n>processFlowId}';
    Configuration:          Association to DOCUMENT_FLOWS_PER_CONFIG;
}

@cds.persistence.exists
entity DOCUMENT_FLOWS_PER_BLOCK : cuid, managed {
    // ID                          : UUID       @title: '{i18n>Id}';
    documentId                  : String(50) @title: '{i18n>documentId}';
    // configurationId             : Integer64  @title: '{i18n>processFlowId}';
    virtual documentIdFC        : UInt8 default 3;
    virtual configurationIdFC   : UInt8 default 1;
    virtual processFlowIdFC        : UInt8 default 1;
    phase                       : String(20) @title: '{i18n>phase}';
    block                       : String(20) @title: '{i18n>block}';
    DocumentFlowsPerConfig      : Association to DOCUMENT_FLOWS_PER_CONFIG;
    DELETED                     : Boolean    @title: '{i18n>deleted}';
    DELETED_AT                  : Timestamp    @title: '{i18n>deletedAt}';
    DELETED_BY                  : String(100) @title: '{i18n>deletedBy}';
    docOrder                    : UInt8;
}

@cds.persistence.exists
entity DOCUMENT_FLOW_VALIDATORS : cuid, managed {
    // ID                             : UUID       @title: '{i18n>Id}';
    documentId                     : String(50) @title: '{i18n>documentId}';
    // configurationId                : Integer64  @title: '{i18n>processFlowId}';
    approverType                   : Integer    @title: '{i18n>approverType}';
    externalType                   : Integer    @title: '{i18n>externalType}';
    subcontractorValidationReq     : Boolean    @title: '{i18n>subcontractorValidationReq}';
    cellnexValidationReq           : Boolean    @title: '{i18n>cellnexValidationReq}';
    customerValidationReq          : Boolean    @title: '{i18n>customerValidationReq}';
    landlordValidationReq          : Boolean    @title: '{i18n>landlordValidationReq}';
    virtual documentIdFC           : UInt8 default 3;
    virtual processFlowIdFC        : UInt8 default 1;
    virtual approverTypeName       : String(200);
    virtual approverTypeFC         : UInt8 default 1;
    virtual subcoTypeName          : String(200);
    virtual subcoTypeFC            : UInt8 default 1;
    DocumentFlowsPerConfig         : Association to DOCUMENT_FLOWS_PER_CONFIG;
    DELETED                        : Boolean    @title: '{i18n>deleted}';
    DELETED_AT                     : Timestamp    @title: '{i18n>deletedAt}';
    DELETED_BY                     : String(100) @title: '{i18n>deletedBy}';
    default                        : Boolean    @title : '{i18n>isDefaultDocument}';
}

@cds.persistence.exists
entity DOCUMENT_FLOWS_HIDDEN_PER_ROLE : cuid, managed {
    // ID                          : UUID       @title: '{i18n>Id}';
    // configurationId             : Integer64    @title: '{i18n>processFlowId}'  @readonly;
    IASGroup                    : String(100)  @title: '{i18n>IASGroup}'       @readonly;
    virtual documentIdFC        : UInt8 default 1;
    virtual processFlowIdFC   : UInt8 default 1;
    documentId                  : String(50)   @title: '{i18n>documentId}';
    active                      : Boolean      @title: '{i18n>active}';
    DocumentFlowsPerConfig      : Association to DOCUMENT_FLOWS_PER_CONFIG;
    DELETED                     : Boolean    @title: '{i18n>deleted}';
    DELETED_AT                  : Timestamp    @title: '{i18n>deletedAt}';
    DELETED_BY                  : String(100) @title: '{i18n>deletedBy}';
}

@cds.persistence.exists
entity DOCUMENT_FLOWS_PER_REQUEST : cuid, managed {
    // ID                    : UUID       @title: '{i18n>Id}';
    requestId             : UUID       @title: '{i18n>requestId}';
    documentId            : String(50) @title: '{i18n>documentId}';
    approverType          : Integer    @title: '{i18n>approverType}';
    subcontractorId       : Integer    @title: '{i18n>subcontractorId}';
    subcontractorValidationReq    : Boolean    @title: '{i18n>subcontractorValidationReq}';
    cellnexValidationReq  : Boolean    @title: '{i18n>cellnexValidationReq}';
    customerValidationReq : Boolean    @title: '{i18n>customerValidationReq}';
    landlordValidationReq : Boolean    @title: '{i18n>landlordValidationReq}';
    responsibleDefault    : String(15) @title: '{i18n>responsibleDefault}';
    subcontractorValidator        : String(15) @title: '{i18n>subcontractorValidator}';
    cellnexValidator      : String(15) @title: '{i18n>cellnexValidator}';
    customerValidator     : String(15) @title: '{i18n>customerValidator}';
    landlordValidator     : String(15) @title: '{i18n>landlordValidator}';
    DELETED               : Boolean    @title: '{i18n>deleted}';
    DELETED_AT            : Timestamp    @title: '{i18n>deletedAt}';
    DELETED_BY            : String(100) @title: '{i18n>deletedBy}';
}

@cds.persistence.exists
entity OT_DOCUMENTS_CONSOLIDATION : cuid, managed {
    // ID                  : UUID       @title: '{i18n>Id}';
    documentId          : String(50) @title: '{i18n>documentId}';
    configurationId     : Integer  @title: '{i18n>configurationId}';
    DELETED             : Boolean    @title: '{i18n>deleted}';
    DELETED_AT          : Timestamp    @title: '{i18n>deletedAt}';
    DELETED_BY          : String(100) @title: '{i18n>deletedBy}';
}

entity WF_DETAIL_DOCUMENTS_LOCAL {
    key REGISTER_ID           : String(36)                       @title           : 'REGISTER_ID';
        BLOCK_ID              : String(36)                       @title           : 'BLOCK_ID';
        INSTANCE_ID           : String(36)                       @title           : 'INSTANCE_ID';
        REQUEST_ID            : String(36)                       @title           : 'REQUEST_ID';
        REQUEST_CODE          : String(100) not null             @title           : 'REQUEST_CODE';
        TYPE_ID               : String(50) not null              @title           : 'TYPE_ID';
        STEP_ID               : String(50) not null              @title           : 'STEP_ID';
        FIELD                 : String(50)                       @title           : 'FIELD';
        DOCUMENT_NAME         : String(1000)                     @title           : 'DOCUMENT_NAME';
        DOCUMENT_VERSION      : String(10)                       @title           : 'DOCUMENT_VERSION';
        DOCUMENT_URL          : String(250)                      @title           : 'DOCUMENT_URL';
        USER_DOC              : String(250)                      @title           : 'USER_DOC';
        CREATION_DATE_DOC     : String(50)                       @title           : 'CREATION_DATE_DOC';
        DOCUMENT_SUBTYPE      : String(100)                      @title           : 'DOCUMENT_SUBTYPE';
        DOCUMENT_SUBTYPE_LVL2 : String(500)                      @title           : 'DOCUMENT_SUBTYPE_LVL2';
        CREATEDAT             : Timestamp                        @title           : 'CREATEDAT';
        CREATEDBY             : String(100)                      @title           : 'CREATEDBY';
        DELETED               : Boolean                          @title           : 'DELETED';
        DELETED_AT            : Timestamp                        @title           : 'DELETED_AT';
        DELETED_BY            : String(100)                      @title           : 'DELETED_BY';
        MODIFIEDAT            : Timestamp                        @title           : 'MODIFIEDAT';
        MODIFIEDBY            : String(100)                      @title           : 'MODIFIEDBY';
        DOCUMENT_ID           : String(50)                       @title           : 'DOCUMENT_ID';
        OT_DOCUMENT_ID        : Integer                          @title           : 'OT_DOCUMENT_ID';
        BLOCK_NAME            : String(30)                       @title           : 'BLOCK_NAME';
        PHASE_NAME            : String(30)                       @title           : 'PHASE_NAME';
        FINAL_DOCUMENT        : Boolean                          @title           : 'FINAL_DOCUMENT';
        MEDIA_TYPE            : String(100) default 'text/plain' @Core.IsMediaType: true;
        WORK_ID               : String                           @title           : 'Work ID';
}

entity BLOCK_SUPPORT_DOCUMENTS(p_blockId: UUID) as select 
    key dd.REGISTER_ID as ID,
        dd.BLOCK_ID as blockId,
        dd.INSTANCE_ID as instanceId,
        dd.REQUEST_ID as requestId,
        dd.REQUEST_CODE as requestCode,
        dd.TYPE_ID as docType,
        dd.STEP_ID as stepId,
        dd.FIELD as field,
        dd.DOCUMENT_NAME as documentName,
        dd.DOCUMENT_VERSION as version,
        dd.DOCUMENT_URL as fileUrl,
        dd.USER_DOC as user,
        dd.CREATION_DATE_DOC as documentCreationDate,
        dd.DOCUMENT_SUBTYPE as subType,
        dd.DOCUMENT_SUBTYPE_LVL2 as subTypeLvl2,
        dd.CREATEDAT as createdAt,
        dd.CREATEDBY as createdBy,
        dd.DELETED as deleted,
        dd.DELETED_BY as deletedBy,
        dd.MODIFIEDAT as modifiedAt,
        dd.MODIFIEDBY as modifiedBy,
        dd.DOCUMENT_ID as documentId,
        dd.OT_DOCUMENT_ID as OTDocumentId,
        dd.BLOCK_NAME as blockName,
        dd.PHASE_NAME as phaseName,
        dd.FINAL_DOCUMENT as finalDocument,
        dd.MEDIA_TYPE as mediaType,
        dd.WORK_ID as workId,
        dd.documentTypeName,
        case 
            when bh.BLOCK_STATUS = 7 then true
            else false
        end as canDelete: Boolean,
        null                     as content: LargeBinary
    from BLOCK_HEAD as bh
    inner join PHASE_HEAD as ph on ph.PHASE_ID = bh.PHASE_ID
                                and bh.BLOCK_ID = :p_blockId
    inner join REQUEST_HEAD as rh on rh.REQUEST_ID = ph.REQUEST_ID
    inner join WF_DETAIL_DOCUMENTS as dd on dd.BLOCK_ID = bh.BLOCK_ID
    inner join DOCUMENT_FLOWS      as df on df.documentId = dd.DOCUMENT_ID
                                        and df.countryId = rh.COUNTRY_ID
                                        and df.enableAttachments = true;

entity DOCUMENT_FLOWS_PER_REQUEST_DOCUMENT_ID_VH               as
    select distinct
        key rh.REQUEST_ID as ID,
        key dfb.documentId,
        key df.documentName
    from REQUEST_HEAD as rh
    inner join DOCUMENT_FLOWS_PER_PROCESS as dfp
        on dfp.processId = rh.PROCESS_ID
    inner join DOCUMENT_FLOWS_PER_CONFIG as dfc
        on dfc.ID = dfp.Configuration.ID
    inner join DOCUMENT_FLOWS_PER_BLOCK as dfb
        on  dfb.DocumentFlowsPerConfig.ID = dfc.ID
    inner join DOCUMENT_FLOWS as df
        on df.documentId = dfb.documentId;

entity DOCUMENTS_FLOWS_PER_BLOCK_DOCUMENT_ID_VH               as
    select distinct
        key dfb.documentId,
        key    dfc.ID,
        key    dfb.phase,
        key    dfb.block,
        key bh.BLOCK_ID,
            df.documentName
    from BLOCK_HEAD as bh
    inner join PHASE_HEAD as ph
        on  ph.PHASE_ID = bh.PHASE_ID
        and bh.BLOCK_ID = bh.BLOCK_ID
    inner join REQUEST_HEAD as rh
        on rh.REQUEST_ID = ph.REQUEST_ID
    inner join DOCUMENT_FLOWS_PER_PROCESS as dfp
        on dfp.processId = rh.PROCESS_ID
    inner join DOCUMENT_FLOWS_PER_CONFIG as dfc
        on dfc.ID = dfp.Configuration.ID
    inner join DOCUMENT_FLOWS_PER_BLOCK as dfb
        on  dfb.DocumentFlowsPerConfig.ID = dfc.ID
        and dfb.block         = bh.MASTER_BLOCK_ID
        and dfb.phase         = ph.MASTER_PHASE_ID
    inner join DOCUMENT_FLOWS as df
        on df.documentId = dfb.documentId;

entity DT_LINKED_GLOBAL_CONTEXT_PER_TASK              as
    select distinct
        key    dlr.CHILD_REQUEST_ID as childRequestCode,
         dlr.PARENT_INSTANCE_ID as jointProjectId
    from INSTANCES_PER_DOCUMENT as ipd  
    inner join DT_LINKED_REQUEST as dlr on ipd.DOC_PB_ID = dlr.PARENT_INSTANCE_ID 
									 and ( dlr.DELETED is null or dlr.DELETED = false )
									 and dlr.ASSOCIATION_TYPE = 'JOINT_PROJECTS';

entity DT_LINKED_GLOBAL_CONTEXT_PER_INSTANCE             as 
    select distinct
            dlr.CHILD_REQUEST_ID as childRequestCode,
        key ipd.INSTANCE_ID as dpbId
    from INSTANCES_PER_DOCUMENT as ipd  
    inner join DOCUMENTS_PER_BLOCK as dpb on dpb.REGISTER_ID = ipd.INSTANCE_ID  
    inner join DT_LINKED_REQUEST as dlr on dpb.PERMIT_ID = dlr.PARENT_INSTANCE_ID 
									 and ( dlr.DELETED is null or dlr.DELETED = false )
									 and dlr.ASSOCIATION_TYPE = 'JOINT_PROJECTS';

entity DOCUMENTS_FLOWS_PER_PROCESS_VH             as
    select
        key dfb.documentId,
        key dfc.ID,
            df.documentName
    from DOCUMENT_FLOWS_PER_PROCESS as dfp
    inner join DOCUMENT_FLOWS_PER_CONFIG as dfc
        on dfc.ID = dfp.Configuration.ID
    inner join DOCUMENT_FLOWS_PER_BLOCK as dfb
        on  dfb.DocumentFlowsPerConfig.ID = dfc.ID
    inner join DOCUMENT_FLOWS as df
        on df.documentId = dfb.documentId;

entity DOCUMENTS_FLOWS_PER_BLOCK_PER_PROCESS_VH           as
    select
        key dfb.documentId,
        key dfc.ID,
            dfb.phase,
            dfb.block,
            df.documentName
    from DOCUMENT_FLOWS_PER_PROCESS as dfp
    inner join DOCUMENT_FLOWS_PER_CONFIG as dfc
        on dfc.ID = dfp.Configuration.ID
    inner join DOCUMENT_FLOWS_PER_BLOCK as dfb
        on  dfb.DocumentFlowsPerConfig.ID = dfc.ID
    inner join DOCUMENT_FLOWS as df
        on df.documentId = dfb.documentId;


entity BLOCKS_PER_PROCESS_CONFIG         as
    select
    key dfb.ID as ID,
    key b.PHASE_ID_PK     as phaseProcessFlowId,
    key   b.BLOCK_ID_PK     as blockProcessFlowId,
        b.![ORDER]        as blockOrder,
    key    mb.BLOCK_NAME     as blockName
    from    DOCUMENT_FLOWS_PER_BLOCK as dfb
    inner join DOCUMENT_FLOWS_PER_PROCESS as dfp on dfp.Configuration.ID = dfb.DocumentFlowsPerConfig.ID
    inner join PROCESS as pr on pr.ID_PK = dfp.processId
    inner join BLOCK as b on b.ID_PK   = pr.ID_PK 
    inner join MASTER_BLOCK as mb on mb.PROCESS_ID_PK = pr.PROCESS_ID_PK
                                 and mb.PHASE_ID_PK   = b.PHASE_ID_PK
                                 and mb.BLOCK_ID_PK   = b.BLOCK_ID_PK
                                 and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    order by b.![ORDER];
entity PHASES_PER_PROCESS_CONFIG         as
    select
    key dfb.ID as ID,
    key pr.PROCESS_ID_PK,
    key p.PHASE_ID          as phaseProcessFlowId,
        p.![ORDER]          as phaseOrder,
    key    mp.PHASE_NAME       as phaseName
    from    DOCUMENT_FLOWS_PER_BLOCK as dfb
    inner join DOCUMENT_FLOWS_PER_PROCESS as dfp on dfp.Configuration.ID = dfb.DocumentFlowsPerConfig.ID
    inner join PROCESS as pr on pr.ID_PK = dfp.processId
    inner join PHASE as p on p.ID_PK        = pr.ID_PK
    inner join MASTER_PHASE as mp on mp.PROCESS_ID_PK   = pr.PROCESS_ID_PK
                                 and mp.PHASE_ID_PK     = p.PHASE_ID
                                 and mp.LANGUAGE_PK     = UPPER(SESSION_CONTEXT('LOCALE'))
    order by p.![ORDER];

entity DEFAULT_DOCUMENTS_PER_REQUEST_CUSTOMIZING as select
    key rh.REQUEST_ID,
    key dfb.phase,
    key dfb.block,
    key dfb.documentId,
        dfb.docOrder,
        def.APPROVER_TYPE,
        def.SUBCONTRACTOR,      
        def.DEFAULT_RESPONSIBLE,
        def.SUBCO_REQ_VAL,      
        def.CELLNEX_REQ_VAL,    
        def.CUSTOMER__REQ_VAL,  
        def.SITEOWNER_REQ_VAL,
        def.DELETED
    from REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID as def
    inner join REQUEST_HEAD as rh on rh.REQUEST_ID = def.REQUEST_ID
    inner join DOCUMENT_FLOWS_PER_PROCESS as dfp on dfp.processId = rh.PROCESS_ID
    inner join DOCUMENT_FLOWS_PER_BLOCK as dfb on dfb.DocumentFlowsPerConfig.ID = dfp.Configuration.ID
                                            and dfb.documentId               = def.DOCUMENT_ID;

entity DOCUMENTS_PER_PROCESS as select
    key pr.ID_PK          as processFlowId,
    key b.PHASE_ID_PK     as phaseProcessFlowId,
    key b.BLOCK_ID_PK     as blockProcessFlowId,
    key dfb.documentId,
        df.documentName    
    from PROCESS as pr
    inner join BLOCK as b on b.ID_PK   = pr.ID_PK
    inner join DOCUMENT_FLOWS_PER_PROCESS as dfp on dfp.processId = pr.ID_PK
    inner join DOCUMENT_FLOWS_PER_BLOCK   as dfb on dfb.DocumentFlowsPerConfig.ID = dfp.Configuration.ID
                                                and dfb.phase                     = b.PHASE_ID_PK
                                                and dfb.block                     = b.BLOCK_ID_PK
    inner join DOCUMENT_FLOWS             as df  on df.documentId                 = dfb.documentId
    order by dfb.docOrder;

entity REQUEST_ALL_TASKS_DOCUMENTS(p_requestId : UUID) as
    select 
        key dp.REGISTER_ID,
            dp.GENERIC_TYPE_ID,
            bh.MASTER_BLOCK_ID,
            ph.MASTER_PHASE_ID,
            rh.REQUEST_ID
    from REQUEST_HEAD as rh
    inner join PHASE_HEAD as ph on  ph.REQUEST_ID = :p_requestId
                                and rh.REQUEST_ID = :p_requestId
    inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
    inner join WORKS as gt on gt.parentId = bh.BLOCK_ID
                                  and gt.parentType.ID = 30
    inner join DOCUMENTS_PER_BLOCK as dp on  dp.WORK_ID =  gt.ID
                                        and (dp.DELETED  is null or dp.DELETED = false);

entity REQUEST_ALL_DOCUMENTS(p_requestId : UUID)  as
    select
        key dp.REGISTER_ID,
            dp.GENERIC_TYPE_ID,
            bh.MASTER_BLOCK_ID,
            ph.MASTER_PHASE_ID,
            rh.REQUEST_ID
    from REQUEST_HEAD as rh
    inner join PHASE_HEAD as ph on  ph.REQUEST_ID = :p_requestId
                                and rh.REQUEST_ID = :p_requestId
    inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
    inner join DOCUMENTS_PER_BLOCK as dp on  dp.BLOCK_ID =  bh.BLOCK_ID
                                        and (dp.DELETED  is null or dp.DELETED = false);


entity OT_DOCUMENTS_PER_REQUEST as select
            key docs.REGISTER_ID as ID @(title: '{i18n>Id}'),
                rh.REQUEST_ID as requestId @(title: '{i18n>requestId}'),
                docs.INSTANCE_ID as instanceId @(title: '{i18n>instanceId}'),
                docs.REQUEST_CODE as requestCode @(title: '{i18n>requestCode}'),
                docs.BLOCK_ID as blockId @(title: '{i18n>blockId}'),
                bh.MASTER_BLOCK_ID as blockFlowId @(title: '{i18n>blockFlowId}'),
                docs.TYPE_ID as documentType @(title: '{i18n>documentType}'),
                docs.STEP_ID as stepId @(title: '{i18n>stepId}'),
                docs.DOCUMENT_NAME as documentName @(title: '{i18n>documentName}'),
                docs.DOCUMENT_SUBTYPE as documentSubtype @(title: '{i18n>documentSubtype}'),
                docs.DOCUMENT_SUBTYPE_LVL2 as documentSubType2 @(title: '{i18n>documentSubType2}'),
                docs.DOCUMENT_ID as documentId @(title: '{i18n>OtdocumentId}'),
                docs.MEDIA_TYPE as mediaType @(title: '{i18n>mediaType}'),
                docs.CREATEDAT as createdAt @(title: '{i18n>createdAt}'),
                docs.CREATEDBY as createdBy @(title: '{i18n>createdBy}'),
                docs.DELETED as deleted @(title: '{i18n>deleted}'),
                docs.MODIFIEDAT  as modifiedAt @(title: '{i18n>modifiedAt}'),
                docs.MODIFIEDBY  as modifiedBy @(title: '{i18n>modifiedBy}'),
                docs.DOCUMENT_URL  as documentUrl @(title: '{i18n>documentUrl}'),
                ph.MASTER_PHASE_ID as phaseFlowId @(title: '{i18n>phaseFlowId}'),
                df.documentName as openTextDocName @(title: '{i18n>OtDocumentName}'),
                mb.BLOCK_NAME as blockName @(title: '{i18n>blockName}'),
                mp.PHASE_NAME as phaseName  @(title: '{i18n>phaseName}')
    from REQUEST_HEAD               as rh
    inner join WF_DETAIL_DOCUMENTS  as docs on docs.REQUEST_ID = rh.REQUEST_ID
    inner join BLOCK_HEAD           as bh  on bh.BLOCK_ID = docs.BLOCK_ID
    inner join PHASE_HEAD           as ph  on ph.PHASE_ID = bh.PHASE_ID    
    left outer join PROCESS as proc on proc.ID_PK = rh.PROCESS_ID
    left outer join MASTER_PHASE   as mp on mp.PROCESS_ID_PK = proc.PROCESS_ID_PK
                                        and mp.PHASE_ID_PK   = ph.MASTER_PHASE_ID
                                        and mp.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    left outer join MASTER_BLOCK   as mb on mb.PROCESS_ID_PK = proc.PROCESS_ID_PK
                                        and mb.PHASE_ID_PK   = ph.MASTER_PHASE_ID
                                        and mb.BLOCK_ID_PK   = bh.MASTER_BLOCK_ID
                                        and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    left join DOCUMENT_FLOWS             as df  on df.documentId = docs.DOCUMENT_ID   
    order by bh.MASTER_BLOCK_ID;

entity DOCUMENTS_PER_REQUEST as select
    key dpb.REGISTER_ID                 as ID                       : String(36)     @title: '{i18n>ID}',
        rh.REQUEST_ID                   as requestId, 
        ph.MASTER_PHASE_ID              as phaseFlowId              : String(36)     @title: '{i18n>phase}',
        ph.PHASE_ID                     as phaseId,
        bh.MASTER_BLOCK_ID              as blockFlowId              : String(36)     @title: '{i18n>processFlowId}',
        dpb.BLOCK_ID                    as blockId                  : String(36)     @title: '{i18n>blockId}',
        dpb.CREATEDAT                   as createdAt                : Timestamp      @title: '{i18n>createdAt}',
        dpb.CREATEDBY                   as createdBy                : String(100)    @title: '{i18n>createdBy}',
        dpb.DELETED                     as deleted                  : Boolean        @title: '{i18n>deleted}',
        dpb.DELETED_AT                  as deletedAt                : Timestamp      @title: '{i18n>deletedAt}',
        dpb.DELETED_BY                  as deletedBy                : String(100)    @title: '{i18n>deletedBy}',
        dpb.MODIFIEDAT                  as modifiedAt               : Timestamp      @title: '{i18n>modifiedAt}',
        dpb.MODIFIEDBY                  as modifiedBy               : String(100)    @title: '{i18n>modifiedBy}',
        dpb.ORDER                       as order,
        dpb.T_RESPONSIBLE               as responsibleDefault       : String(100)    @title: '{i18n>responsibleDefault}',
        dpb.RESPONSIBLE_ID              as responsibleId,
        dpb.SUBCONTRATOR_ID             as subcontractorId,
        dpb.VALIDATION_CELLNEX_CLIENT   as cellnexValidation        : String(10)     @title: '{i18n>cellnexValidation}',
        dpb.VALIDATION_REQ_CLIENT       as customerValidation       : String(10)     @title: '{i18n>customerValidation}',
        dpb.VALIDATION_SUBCO_CLIENT     as subcontractorValidation  : String(10)     @title: '{i18n>subcontratorValidation}',
        dpb.VALIDATION_SITEOWNER_NEEDED as siteOwnerValidation      : String(10)     @title: '{i18n>siteOwnerValidation}',
        dpb.GENERIC_TYPE_ID             as documentId               : String(50)     @title: '{i18n>documentId}',
        dpb.STATUS                      as status                   : Integer        @title: '{i18n>status}',
        '' as cellnexResponsible              : String(50) @Core.Computed: false,
        '' as subcontractorResponsible        : String(50) @Core.Computed: false,    
        '' as agencyResponsible               : String(50) @Core.Computed: false,
        '' as customerResponsible             : String(50) @Core.Computed: false,    
        '' as cellnexResponsibleName          : String(200) @Core.Computed: false,
        '' as subcontractorResponsibleName    : String(200) @Core.Computed: false,    
        '' as agencyResponsibleName           : String(200) @Core.Computed: false,    
        '' as customerResponsibleName         : String(200) @Core.Computed: false,    
        0  as cellnexResponsibleFC            : UInt8,
        0  as subcontractorResponsibleFC      : UInt8,    
        0  as agencyResponsibleFC             : UInt8,    
        0  as customerResponsibleFC           : UInt8,    
        '' as approverTypeName          : String(200),
        1 as approverTypeFC             : UInt8,
        '' as subcoTypeName             : String(200),
        1 as subcoTypeFC                : UInt8,
        '' as  responsibleDefaultName   : String(200),
        1 as responsibleDefaultFC       : UInt8,
        1 as cellnexValidationFC        : UInt8,
        1 as subcontractorValidationFC          : UInt8,
        1 as customerValidationFC       : UInt8,
        1 as siteOwnerValidationFC      : UInt8,
        1 as cellnexValidatorFC         : UInt8,
        1 as subcontractorValidatorFC           : UInt8,
        1 as customerValidatorFC        : UInt8,
        1 as siteOwnerValidatorFC       : UInt8,
        1 as documentIdFC               : UInt8,
        1 as Criticality                : UInt8,
        '' as stepIdVF                      : String(16)    @readonly,
        '' as statusIconVF                  : String(20)    @readonly,
        '' as statusStateVF                 : String(15)    @readonly,
        '' as statusTextVF                  : String(50)    @readonly,
        '' as cellnexStatusIconVF           : String(20)    @readonly,
        '' as cellnexStatusStateVF          : String(15)    @readonly,
        '' as cellnexStatusTextVF           : String(50)    @readonly,
        '' as responsibleStatusIconVF       : String(20)    @readonly,
        '' as responsibleStatusStateVF      : String(15)    @readonly,
        '' as responsibleStatusTextVF       : String(50)    @readonly,
        '' as subcontractorStatusIconVF     : String(20)    @readonly,
        '' as subcontractorStatusStateVF    : String(15)    @readonly,
        '' as subcontractorStatusTextVF     : String(50)    @readonly,
        '' as customerStatusIconVF          : String(20)    @readonly,
        '' as customerStatusStateVF         : String(15)    @readonly,
        '' as customerStatusTextVF          : String(50)    @readonly,
        '' as siteOwnerStatusIconVF         : String(20)    @readonly,
        '' as siteOwnerStatusStateVF        : String(15)    @readonly,
        '' as siteOwnerStatusTextVF         : String(50)    @readonly,
        false as canInit                    : Boolean,
        false as canSee                     : Boolean,
        false as canDelete                  : Boolean,
        false as canDownload                : Boolean,
        false as cellnexValidationVF    : Boolean       @Core.Computed: false,
        false as subcontractorValidationVF      : Boolean       @Core.Computed: false,
        false as customerValidationVF   : Boolean       @Core.Computed: false,
        false as siteOwnerValidationVF  : Boolean       @Core.Computed: false
    from REQUEST_HEAD               as rh
    inner join PHASE_HEAD           as ph  on ph.REQUEST_ID = rh.REQUEST_ID
    inner join BLOCK_HEAD           as bh  on bh.PHASE_ID = ph.PHASE_ID
    inner join DOCUMENTS_PER_BLOCK  as dpb on dpb.BLOCK_ID = bh.BLOCK_ID
    where rh.REQUEST_TYPE = '40';


entity DOCUMENT_VIEWER_NODES {
    key NODE_ID: String             @(title: '{i18n>nodeId}');
        HIERARCHY_LEVEL: Integer    @(title: '{i18n>level}');
        PARENT_NODE_ID: String      @(title: '{i18n>parentNodeId}');
        DRILL_STATE: String         @(title: '{i18n>drillState}');
        DESCRIPTION: String         @(title: '{i18n>description}');
        DOCUMENT_ID: String         @(title: '{i18n>documentId}');
        CREATED_BY: String(50)      @(title: '{i18n>createdBy}');
        CREATED_AT: Timestamp       @(title: '{i18n>createdAt}');
        REQUEST_ID: UUID            @(title: '{i18n>requestId}');
}
entity GET_BLOCK_ID_FROM_MASTERBLOCK_ID(p_requestId : String, p_masterBlockId : String)                               as
    select key bh.BLOCK_ID from REQUEST_HEAD as rh
    inner join PHASE_HEAD as ph
        on ph.REQUEST_ID = rh.REQUEST_ID
    inner join BLOCK_HEAD as bh
        on bh.PHASE_ID = ph.PHASE_ID
    where
            rh.REQUEST_ID    = :p_requestId
        and bh.MASTER_BLOCK_ID = :p_masterBlockId;