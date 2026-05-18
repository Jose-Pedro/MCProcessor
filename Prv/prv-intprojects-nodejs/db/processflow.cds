using { sap.common.CodeList as CodeList } from '@sap/cds/common';
using { REQUEST_HEAD, PHASE_HEAD, BLOCK_HEAD  } from './cellnex';

@cds.persistence.exists
entity PROCESS {
    key ID_PK          : Integer64           @title: 'ID_PK: Code';
    key PROCESS_ID_PK  : String(15)          @title: 'PROCESS_ID_PK: Master Process Code';
        NOTE           : String(150)         @title: 'NOTE: Note Description';
        COUNTRY_CODE   : String(40) not null @title: 'COUNTRY_CODE: Country Code';
        COMPANY_CODE   : String(40) not null @title: 'COMPANY_CODE: Company Code';
        SITE_TYPE      : String(40) not null @title: 'SITE_TYPE: Site Type';
        SITE_REGION    : String(40) not null @title: 'SITE_REGION: Site Region';
        CLIENT         : String(40) not null @title: 'CLIENT: Client';
        CLASSIFICATION : String(40) not null @title: 'CLASSIFICATION: Classification';
        PROGRAM        : String(40) not null @title: 'PROGRAM: Program';
        CREATEDBY      : String(255)         @title: 'CREATEDBY';
        CREATEDAT      : Timestamp           @title: 'CREATEDAT';
        MODIFIEDAT     : Timestamp           @title: 'MODIFIEDAT';
        MODIFIEDBY     : String(255)         @title: 'MODIFIEDBY';
        // groups         : Association to many GROUPS
        //                             on groups.process = $self;
}

@cds.persistence.exists
entity PHASE {
        key ID_PK          : Integer64             @title: 'ID_PK: Table Process - Code';
        key PROCESS_ID_PK  : String(15)            @title: 'PROCESS_ID_PK: Table Process - Process Code';
        key PHASE_ID       : String(15)            @title: 'PHASE_ID: Master Phase Code';
            ORDER          : String(2) not null    @title: 'ORDER: Sort order';
            ALWAYS_ON      : String(1) not null    @title: 'ALWAYS_ON: Always Active';
            NOT_REQUIRED   : String(1) not null    @title: 'NOT_REQUIRED: No Required';
            PASS_OVER      : String(1) not null    @title: 'PASS_OVER: Complete Postponed';
            SKIP_RULE      : String(100) not null  @title: 'SKIP_RULE: Auto Skip Rule';
            CLOSE_BLOCK    : Boolean default false @title: 'CLOSE_BLOCK: Auto close block';
            HAS_CANDIDATES : Boolean default false @title: 'HAS_CANDIDATES: Phase with candidates';
            CREATEDBY      : String(255)           @title: 'CREATEDBY';
            CREATEDAT      : Timestamp             @title: 'CREATEDAT';
            MODIFIEDAT     : Timestamp             @title: 'MODIFIEDAT';
            MODIFIEDBY     : String(255)           @title: 'MODIFIEDBY';
}

@cds.persistence.exists
entity PHASE_DEPENDENCE {
    key ID_PK              : Integer64   @title: 'ID_PK: Table Process - Code';
    key PROCESS_ID_PK      : String(15)  @title: 'PROCESS_ID_PK: Table Process - Process Code';
    key PHASE_ID_PK        : String(15)  @title: 'PHASE_ID_PK: Phase Code';
    key DEPENDENT_TO_ID_PK : String(15)  @title: 'DEPENDENT_TO_ID_PK: Previous Phase Code';
        CREATEDBY          : String(255) @title: 'CREATEDBY';
        CREATEDAT          : Timestamp   @title: 'CREATEDAT';
        MODIFIEDAT         : Timestamp   @title: 'MODIFIEDAT';
        MODIFIEDBY         : String(255) @title: 'MODIFIEDBY';
}

@cds.persistence.exists
entity PHASE_PARALLEL {
    key ID_PK             : Integer64   @title: 'ID_PK: Table Process - Code';
    key PROCESS_ID_PK     : String(15)  @title: 'PROCESS_ID_PK: Table Process - Process Code';
    key PHASE_ID_PK       : String(15)  @title: 'PHASE_ID_PK: Phase Code';
    key PARALLEL_TO_ID_PK : String(15)  @title: 'PARALLEL_TO_ID_PK: Parallel Phase Code';
        CREATEDBY         : String(255) @title: 'CREATEDBY';
        CREATEDAT         : Timestamp   @title: 'CREATEDAT';
        MODIFIEDAT        : Timestamp   @title: 'MODIFIEDAT';
        MODIFIEDBY        : String(255) @title: 'MODIFIEDBY';
}

@cds.persistence.exists
entity BLOCK {
    key ID_PK              : Integer64             @title: 'ID_PK: Table Phase - Code';
    key PROCESS_ID_PK      : String(15)            @title: 'PROCESS_ID_PK: Table Phase - Process Code';
    key PHASE_ID_PK        : String(15)            @title: 'PHASE_ID_PK: Table Phase - Phase Code';
    key BLOCK_ID_PK        : String(15)            @title: 'BLOCK_ID_PK: Master Block Code';
        ORDER              : String(2) not null    @title: 'ORDER: Sort order';
        VISIBLE_ON         : String(1) not null    @title: 'VISIBLE_ON: Visible';
        MANDATORY          : String(1) not null    @title: 'MANDATORY: Requested';
        ACTIVE             : String(1)             @title: 'ACTIVE: Default Active';
        CREATEDBY          : String(255)           @title: 'CREATEDBY';
        CREATEDAT          : Timestamp             @title: 'CREATEDAT';
        MODIFIEDAT         : Timestamp             @title: 'MODIFIEDAT';
        MODIFIEDBY         : String(255)           @title: 'MODIFIEDBY';
        ROLE_ID            : String(50)            @title: 'ROLE_ID';
        HASRESPONSIBLE     : String(1)             @title: 'HASRESPONSIBLE: Has Responsible';
        APPROVER_TYPE      : Integer               @title: 'APPROVER_TYPE';
        SUBCONTRACTOR_TYPE : Integer               @title: 'SUBCONTRACTOR_TYPE';
        PROVIDER_NAME      : String(100)           @title: 'PROVIDER_NAME';
        RESPONSIBLE_PERSON : String(100)           @title: 'RESPONSIBLE_PERSON';
        IS_CANDIDATE       : Boolean default false @title: 'IS_CANDIDATE: Block for Candidate';
}

@cds.persistence.exists
entity BLOCK_DEPENDENCE {
    key ID_PK              : Integer64   @title: 'ID_PK: Table Phase - Code';
    key PROCESS_ID_PK      : String(15)  @title: 'PROCESS_ID_PK: Table Phase - Process Code';
    key PHASE_ID_PK        : String(15)  @title: 'PHASE_ID_PK: Table Phase - Phase Code';
    key BLOCK_ID_PK        : String(15)  @title: 'BLOCK_ID_PK: Master Block Code';
    key DEPENDENT_TO_ID_PK : String(15)  @title: 'DEPENDENT_TO_ID_PK: Previous Block Code';
        CREATEDBY          : String(255) @title: 'CREATEDBY';
        CREATEDAT          : Timestamp   @title: 'CREATEDAT';
        MODIFIEDAT         : Timestamp   @title: 'MODIFIEDAT';
        MODIFIEDBY         : String(255) @title: 'MODIFIEDBY';
}

@cds.persistence.exists
@cds.odata.valuelist
@UI.Identification: [{Value: REQUEST_TYPE_DESC}]
entity REQUEST_TYPE {
    key REQUEST_TYPE      : Integer    @title: '{i18n>RequestType}'  @Common.Text: REQUEST_TYPE_DESC;
        REQUEST_TYPE_CODE : String(3)  @title: '{i18n>requestTypeIntId}';
        REQUEST_TYPE_DESC : String(50) @title: '{i18n>description}';
        MASTER_PROCESS_ID : String(15) @title: '{i18n>masterProcessFlowId}';
}

@cds.persistence.exists
entity ![STATUS_HEAD] {
    key ![STATUS_CODE] : Integer    @title: 'STATUS_CODE';
        ![STATUS_TEXT] : String(50) @title: '{i18n>status}';
}

@cds.persistence.exists
entity ![STATUS_TEXTS] {
    key ![STATUS_CODE] : Integer     @title: 'STATUS_CODE';
        ![LANGUAGE]    : String(3)   @title: 'LANGUAGE';
        ![STATUS_TEXT] : String(100) @title: 'STATUS_TEXT';
}

entity PROCESS_TYPES : CodeList {
    key code : String;
}

@cds.persistence.exists 
entity MASTER_PROCESS {
    key PROCESS_ID_PK: String(15)  @title: 'PROCESS_ID_PK: Code' ; 
    key LANGUAGE_PK: String(2)  @title: 'LANGUAGE_PK' ; 
        PROCESS_NAME: String(100) not null  @title: 'PROCESS_NAME' ; 
}

@cds.persistence.exists
entity MASTER_PHASE {
    key PROCESS_ID_PK : String(15)           @title: 'PROCESS_ID_PK: Process Code';
    key PHASE_ID_PK   : String(15)           @title: 'PHASE_ID_PK: Phase Code';
    key LANGUAGE_PK   : String(2)            @title: 'LANGUAGE_PK';
    key ORDER_PK      : String(2)            @title: 'ORDER_PK';
        PHASE_NAME    : String(100) not null @title: 'PHASE_NAME';
}

@cds.persistence.exists
entity MASTER_BLOCK {
    key PROCESS_ID_PK  : String(15)           @title: 'PROCESS_ID_PK: Process Code';
    key PHASE_ID_PK    : String(15)           @title: 'PHASE_ID_PK: Phase Code';
    key BLOCK_ID_PK    : String(15)           @title: 'BLOCK_ID_PK: Code';
    key ORDER_PHASE_PK : String(2)            @title: 'ORDER_PHASE_PK';
    key LANGUAGE_PK    : String(2)            @title: 'LANGUAGE_PK';
    key ORDER_PK       : String(2)            @title: 'ORDER_PK';
        BLOCK_NAME     : String(100) not null @title: 'BLOCK_NAME';
        ROLE_ID        : String(50)           @title: 'ROLE_ID';
}

entity PHASES_PER_PROCESS as select
    key pr.ID_PK   as processFlowId,
    key p.PHASE_ID          as phaseProcessFlowId,
        p.![ORDER]          as phaseOrder,
        mp.PHASE_NAME       as phaseName
    from PROCESS as pr
    inner join PHASE as p on p.ID_PK        = pr.ID_PK
    inner join MASTER_PHASE as mp on mp.PROCESS_ID_PK   = pr.PROCESS_ID_PK
                                 and mp.PHASE_ID_PK     = p.PHASE_ID
                                 and mp.LANGUAGE_PK     = UPPER(SESSION_CONTEXT('LOCALE'))
    order by p.![ORDER];

entity BLOCKS_PER_PROCESS as select
    key pr.ID_PK            as processFlowId,
    key b.PHASE_ID_PK       as phaseProcessFlowId,
    key b.BLOCK_ID_PK       as blockProcessFlowId,
        b.![ORDER]          as blockOrder,
        mb.BLOCK_NAME       as blockName,
        IS_CANDIDATE        as hasCandidate
    from PROCESS as pr
    inner join BLOCK as b on b.ID_PK   = pr.ID_PK
    inner join MASTER_BLOCK as mb on mb.PROCESS_ID_PK = pr.PROCESS_ID_PK
                                 and mb.PHASE_ID_PK   = b.PHASE_ID_PK
                                 and mb.BLOCK_ID_PK   = b.BLOCK_ID_PK
                                 and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    order by b.![ORDER];

entity INTERNAL_PHASES as select distinct
    key PHASE.PHASE_ID      as code @(title: '{i18n>phaseType}'),
        PHASE_NAME          as name @(title: '{i18n>name}')  @sap.text,
        ORDER
    from PROCESS 
    inner join PHASE on  PHASE.PROCESS_ID_PK = PROCESS.PROCESS_ID_PK
                     and PROCESS.PROCESS_ID_PK = 'int'
                     and PROCESS.PROGRAM = 'DEF'
                     and PHASE.ID_PK = PROCESS.ID_PK
    inner join MASTER_PHASE on  MASTER_PHASE.PROCESS_ID_PK = PHASE.PROCESS_ID_PK
                            and MASTER_PHASE.PHASE_ID_PK = PHASE.PHASE_ID
                            and MASTER_PHASE.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))
    order by PHASE.ORDER;

entity INTERNAL_BLOCKS as select distinct
    key MASTER_BLOCK.PHASE_ID_PK       as phaseId,
    key MASTER_BLOCK.BLOCK_ID_PK       as code @(title: '{i18n>blockType}'),
        BLOCK_NAME        as name @(title: '{i18n>name}') @sap.text,
        PHASE.ORDER       as phaseOrder,
        BLOCK.ORDER       as blockOrder
    from PROCESS 
    inner join PHASE on  PHASE.PROCESS_ID_PK = PROCESS.PROCESS_ID_PK
                     and PROCESS.PROCESS_ID_PK = 'int'
                     and PROCESS.PROGRAM = 'DEF'
                     and PHASE.ID_PK = PROCESS.ID_PK
    inner join BLOCK on  BLOCK.PROCESS_ID_PK = PHASE.PROCESS_ID_PK
                     and BLOCK.ID_PK = PHASE.ID_PK
                     and BLOCK.PHASE_ID_PK = PHASE.PHASE_ID
    inner join MASTER_BLOCK on  MASTER_BLOCK.PROCESS_ID_PK = BLOCK.PROCESS_ID_PK
                            and MASTER_BLOCK.PHASE_ID_PK = BLOCK.PHASE_ID_PK
                            and MASTER_BLOCK.BLOCK_ID_PK = BLOCK.BLOCK_ID_PK
                            and MASTER_BLOCK.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    order by PHASE.ORDER, BLOCK.ORDER;

entity requestProcess                             as
    select
        key pr.ID_PK,
            pr.PROCESS_ID_PK,
        key ph.PHASE_ID,
            ph.ORDER as PHASE_ORDER,
            ph.NOT_REQUIRED,
            ph.ALWAYS_ON,
            ph.PASS_OVER,
            ph.SKIP_RULE,
            ph.CLOSE_BLOCK,
            ph.HAS_CANDIDATES,
        key bl.BLOCK_ID_PK,
            bl.VISIBLE_ON,
            bl.MANDATORY,
            bl.ACTIVE,
            bl.ROLE_ID,
            bl.HASRESPONSIBLE,
            bl.APPROVER_TYPE,
            bl.SUBCONTRACTOR_TYPE,
            bl.IS_CANDIDATE
    from PROCESS as pr
    inner join PHASE as ph on ph.ID_PK = pr.ID_PK
    inner join BLOCK as bl on  bl.ID_PK       = ph.ID_PK
                          and bl.PHASE_ID_PK = ph.PHASE_ID
    order by ph.ORDER,
             bl.ORDER;

entity LAST_ACTIVE_PHASES(p_requestId : UUID)     as
    select key max(
        p.![ORDER]
    ) as LAST_PHASE : String(2) from REQUEST_HEAD as rh
    inner join PHASE_HEAD as ph on  ph.REQUEST_ID = rh.REQUEST_ID
                                and ph.REQUEST_ID = :p_requestId
                                and (ph.PHASE_STATUS = 7 or ph.PHASE_STATUS = 3)
    inner join PHASE as p on  p.PHASE_ID = ph.MASTER_PHASE_ID
                          and p.ID_PK    = rh.PROCESS_ID;

entity FIRST_INPROGRESS_PHASE(p_requestId : UUID) as
    select
        key ph.MASTER_PHASE_ID,
            p.ORDER
    from REQUEST_HEAD as rh
    inner join PHASE_HEAD as ph on ph.REQUEST_ID = rh.REQUEST_ID
                                and ph.REQUEST_ID = :p_requestId
                                and (ph.PHASE_STATUS = 7 )
    inner join PHASE as p on  p.PHASE_ID = ph.MASTER_PHASE_ID
                          and p.ID_PK    = rh.PROCESS_ID
    order by p.ORDER
    limit 1;             

entity LAST_ACTIVE_PHASE_BLOCK     as
    select REQUEST_ID, lastPhase, lastPhaseName ,lastBlock, lastBlockName from (
        select key rh.REQUEST_ID,
                ph.MASTER_PHASE_ID as lastPhase,
                bh.MASTER_BLOCK_ID as lastBlock,
                mp.PHASE_NAME as lastPhaseName,
                mb.BLOCK_NAME as lastBlockName,
                p.![ORDER] as phaseOrder,
                b.![ORDER] as blockOrder,
                row_number() over (
                    partition by rh.REQUEST_ID
                    order by p.![ORDER] asc, b.![ORDER] asc
                ) as rn
        from REQUEST_HEAD as rh
        inner join PHASE_HEAD as ph on  ph.REQUEST_ID = rh.REQUEST_ID
                                    and ph.PHASE_STATUS = 7
                                    and rh.REQUEST_TYPE = 40
        inner join PHASE as p on  p.PHASE_ID = ph.MASTER_PHASE_ID
                            and p.ID_PK    = rh.PROCESS_ID
        left outer join MASTER_PHASE as mp on mp.PROCESS_ID_PK = p.PROCESS_ID_PK
                                            and mp.PHASE_ID_PK = p.PHASE_ID
                                            and mp.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))
        inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
                                    and bh.BLOCK_STATUS = 7
        inner join BLOCK as b on  p.PHASE_ID = ph.MASTER_PHASE_ID
                            and b.BLOCK_ID_PK = bh.MASTER_BLOCK_ID
                            and b.ID_PK    = rh.PROCESS_ID
        left outer join MASTER_BLOCK as mb on mb.PROCESS_ID_PK = b.PROCESS_ID_PK
                                            and mb.PHASE_ID_PK = b.PHASE_ID_PK
                                            and mb.BLOCK_ID_PK = b.BLOCK_ID_PK
                                            and mb.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))
    ) where rn = 1;

entity SINGLE_REQUEST_PROCESS(p_requestId : UUID)    as        
    select
        key rh.REQUEST_ID,
            rh.PROCESS_ID,
            rh.REQUEST_CODE,
            pr.ID_PK,
            pr.PROCESS_ID_PK,
        key ph.PHASE_ID,
            ph.ORDER as PHASE_ORDER,
            ph.NOT_REQUIRED,
            ph.ALWAYS_ON,
            ph.PASS_OVER,
            ph.SKIP_RULE,
            ph.CLOSE_BLOCK,
            ph.HAS_CANDIDATES,
        key bl.BLOCK_ID_PK,
            bl.VISIBLE_ON,
            bl.MANDATORY,
            bl.ACTIVE,
            bl.ROLE_ID,
            bl.HASRESPONSIBLE,
            bl.APPROVER_TYPE,
            bl.SUBCONTRACTOR_TYPE,
            bl.IS_CANDIDATE
    from REQUEST_HEAD as rh 
    inner join  PROCESS as pr on pr.ID_PK=  rh.PROCESS_ID  
    inner join PHASE as ph on ph.ID_PK = rh.PROCESS_ID
    inner join BLOCK as bl on  bl.ID_PK       = rh.PROCESS_ID
                          and bl.PHASE_ID_PK = ph.PHASE_ID
    where rh.REQUEST_ID = :p_requestId 
    order by
        ph.ORDER,
        bl.ORDER;
