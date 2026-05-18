using { 
    BLOCK_HEAD,
    BLOCK_STATUS,
    BLOCK_STATUS_TEXTS,
    CACHE_R3_ENTITIES,
    DOCUMENT_FLOW_STATUS,
    DOCUMENT_FLOW_STATUS_TEXTS,
    PHASE_HEAD,
    PHASE_STATUS,
    PHASE_STATUS_TEXTS,
    REQUEST_HEAD,
    REQUEST_CHAR_PRO,
    REQUEST_STATUS,
    REQUEST_STATUS_TEXTS,
    SEARCH_TYPES,
    SEARCH_TYPES_TEXTS,
    TASK_TYPES, 
    TASK_TYPES_TEXTS,
    WF_ACTIONS_LOG,
    BLOCKS_PROVISIONING,
    DOCUMENTS_PER_BLOCK,
    INSTANCES_PER_DOCUMENT,
    REQUEST_IMPACTED_CUSTOMERS,
    ZPMSERVLOC,
    CVI_CUST_LINK,
    ZRECOAVALUEST
} from './cellnex';
using { 
    MASTER_BLOCK,
    MASTER_PHASE,
    PROCESS,
    STATUS_HEAD,
    STATUS_TEXTS,
} from './processflow';
using {
    VIBDAO,
    VIBDBE,
    VICNCN,
    VIBDOBJASS,
    VIBPOBJREL,
    VIBDOBJREL,
    VZOBJECT,
    ADRC,
    ZRETOAALIAS,
    IFLOT,
    ILOA,
    BUT000,
    T005U,
    ZPMSITESERV,
    ZPMSERVCHNGS
} from './eccmodel';
using { DOCUMENT_FLOWS } from './document';
using { US_USERS_IAS, US_COUNTRIES, US_BUKS, US_ROLES_AGR} from './userinfo';
using { APPROVER_TYPES, SUBCO_TYPES } from './selectoptions';
using { WORKS } from './works';
using { Checklist } from './checklist';

type RequestAllowedActions {
    requestId: UUID;
    linkedProjects: Boolean;
    forecast: Boolean;
    create: Boolean;
    responsibles: Boolean;
    workOrders:Boolean;
    log: Boolean;
    projectDocuments: Boolean;
    opentextDocuments: Boolean;
    consolidation: Boolean;
    cancel: Boolean;
    onHold: Boolean;
    takeOwnership: Boolean;
    reopen: Boolean;
    close: Boolean;
    confirms: Boolean;
    closePhase: Boolean;
    addDefaultDocuments: Boolean;
    registerCandidates: Boolean;
    launchRenegos: Boolean;
    launchPermits: Boolean;
}

type BlockAllowedActions {
    blockId: UUID;
    candidateId: String;
    phaseFlowId: String;
    blockFlowId: String;
    complete: Boolean;
    activate: Boolean;
    reopen: Boolean;
    addFlow: Boolean;
    cancelFlow: Boolean;
    detailFlow: Boolean;
}

type CreationFields: {
    name: String(100);
    visible: Boolean;
    editable: Boolean;
    mandatory: Boolean;
    defaultValueInteger: Integer;
    defaultValueString: String;
    defaultValueDate: Timestamp; 
}

type CreationConfigs {
    ID: String(20);
    description: String(250);
    Fields: many CreationFields;
}

type DefaultCreationOptions {
    defaultOptionId: String(20);
    CreationConfigs: many CreationConfigs;
}

type PhasesStatus {
    phaseName: String(40);
    status: Integer;
}

entity ECC_LANGUAGES {
    key SPRAS       : String(2);
        LASPEZ      : String(1);
        LAHQ        : String(1);
        LAISO       : String(2);
}

entity localized_BLOCK_STATUS as select
  coalesce(BLOCK_STATUS_TEXTS.NAME, BLOCK_STATUS.NAME) AS name: String(255),
  coalesce(BLOCK_STATUS_TEXTS.DESCR, BLOCK_STATUS.DESCR) AS descr: String(1000),
  key BLOCK_STATUS.CODE as code
FROM (BLOCK_STATUS LEFT JOIN BLOCK_STATUS_TEXTS ON BLOCK_STATUS_TEXTS.CODE = BLOCK_STATUS.CODE AND BLOCK_STATUS_TEXTS.LOCALE = SESSION_CONTEXT('LOCALE'));

entity localized_DOCUMENT_FLOW_STATUS as select
  coalesce(DOCUMENT_FLOW_STATUS_TEXTS.NAME, DOCUMENT_FLOW_STATUS.NAME) AS name: String(255),
  coalesce(DOCUMENT_FLOW_STATUS_TEXTS.DESCR, DOCUMENT_FLOW_STATUS.DESCR) AS descr: String(1000),
  key DOCUMENT_FLOW_STATUS.CODE as code
FROM (DOCUMENT_FLOW_STATUS LEFT JOIN DOCUMENT_FLOW_STATUS_TEXTS ON DOCUMENT_FLOW_STATUS_TEXTS.CODE = DOCUMENT_FLOW_STATUS.CODE AND DOCUMENT_FLOW_STATUS_TEXTS.LOCALE = SESSION_CONTEXT('LOCALE'));

entity localized_PHASE_STATUS as select
  coalesce(PHASE_STATUS_TEXTS.NAME, PHASE_STATUS.NAME) AS name: String(255),
  coalesce(PHASE_STATUS_TEXTS.DESCR, PHASE_STATUS.DESCR) AS descr: String(1000),
  key PHASE_STATUS.CODE as code
FROM (PHASE_STATUS LEFT JOIN PHASE_STATUS_TEXTS ON PHASE_STATUS_TEXTS.CODE = PHASE_STATUS.CODE AND PHASE_STATUS_TEXTS.LOCALE = SESSION_CONTEXT('LOCALE'));

entity localized_REQUEST_STATUS as select
  coalesce(REQUEST_STATUS_TEXTS.NAME, REQUEST_STATUS.NAME) AS name: String(255),
  coalesce(REQUEST_STATUS_TEXTS.DESCR, REQUEST_STATUS.DESCR) AS descr: String(1000),
  key REQUEST_STATUS.CODE as code
FROM (REQUEST_STATUS LEFT JOIN REQUEST_STATUS_TEXTS ON REQUEST_STATUS_TEXTS.CODE = REQUEST_STATUS.CODE AND REQUEST_STATUS_TEXTS.LOCALE = SESSION_CONTEXT('LOCALE'));

entity localized_SEARCH_TYPES as select
  coalesce(SEARCH_TYPES_TEXTS.NAME, SEARCH_TYPES.NAME) AS name: String(255),
  coalesce(SEARCH_TYPES_TEXTS.DESCR, SEARCH_TYPES.DESCR) AS descr: String(1000),
  key SEARCH_TYPES.CODE as code
FROM (SEARCH_TYPES LEFT JOIN SEARCH_TYPES_TEXTS ON SEARCH_TYPES_TEXTS.CODE = SEARCH_TYPES.CODE AND SEARCH_TYPES_TEXTS.LOCALE = SESSION_CONTEXT('LOCALE'));

entity localized_STATUS_HEAD as select
    key STATUS_HEAD.STATUS_CODE as code,
        coalesce( STATUS_TEXTS.STATUS_TEXT, STATUS_HEAD.STATUS_TEXT) as name : String(255)
from STATUS_HEAD left join STATUS_TEXTS on  STATUS_TEXTS.STATUS_CODE = STATUS_HEAD.STATUS_CODE and STATUS_TEXTS.LANGUAGE = UPPER( SESSION_CONTEXT('LANGUAGE') );

entity localized_TASK_TYPES as select
  coalesce(TASK_TYPES_TEXTS.NAME, TASK_TYPES.NAME) AS name: String(255),
  coalesce(TASK_TYPES_TEXTS.DESCR, TASK_TYPES.DESCR) AS descr: String(1000),
  key TASK_TYPES.CODE as code
FROM (TASK_TYPES LEFT JOIN TASK_TYPES_TEXTS ON TASK_TYPES_TEXTS.CODE = TASK_TYPES.CODE AND TASK_TYPES_TEXTS.LOCALE = SESSION_CONTEXT('LOCALE'));

entity CHANGE_LOG as select distinct
        @title: '{i18n>logId}'          key log.ACTIONS_LOG_ID  as logId,
        @title: '{i18n>requestId}'      key log.REQUEST_ID      as requestId,
        @title: '{i18n>requestType}'        log.REQUEST_TYPE    as requestType,
        @title: '{i18n>modifiedAt}'         log.DATE            as changeDate,
        @title: '{i18n>userId}'             log.USER            as userId,
        @title: '{i18n>userName}'           case
                                                when ias.USER_NAME is null or ias.USER_NAME = '' then ias.USER_ID
                                                else ias.USER_NAME
                                            end as                 userName: String,
        @title: '{i18n>action}'             log.ACTION          as userAction,
        @title: '{i18n>actionName}'         ''                  as userActionName:String(100),
        @title: '{i18n>phaseType}'          log.PHASE_ID_PK     as phaseProcessFlowId,
        @title: '{i18n>phaseTypeName}'      mp.PHASE_NAME       as phaseName,
        @title: '{i18n>blockType}'          log.BLOCK_ID_PK     as blockProcessFlowId,
        @title: '{i18n>blockTypeName}'      mb.BLOCK_NAME       as blockName,
        @title: '{i18n>fieldName}'          log.FIELD_MOD       as fieldName,
        @title: '{i18n>fieldDescription}'   ''                  as fieldDescription: String,
        @title: '{i18n>oldValue}'           log.OLD_VALUE       as oldValue,
        @title: '{i18n>oldValueDescription}' ''                 as oldValueDescription:String(100),
        @title: '{i18n>newValue}'           log.NEW_VALUE       as newValue,
        @title: '{i18n>newValueDescription}' ''                 as newValueDescription:String(100),
        @title: '{i18n>phaseId}'            log.PHASE_ID        as phaseId,
        @title: '{i18n>blockId}'            log.BLOCK_ID        as BlockId,
        @title: '{i18n>documentName}'       doc.documentName    as documentName,
        @title: '{i18n>workType}'           works.type.ID       as workType,
        @title: '{i18n>workTypeName}'           works.type.descr    as workTypeName
    from WF_ACTIONS_LOG as log
    left outer join REQUEST_HEAD as rh on rh.REQUEST_ID = log.REQUEST_ID
    left outer join BLOCK_HEAD as bh on bh.BLOCK_ID = log.BLOCK_ID
    left outer join US_USERS_IAS as ias on ias.USER_ID = log.USER
    left outer join PROCESS as proc on proc.ID_PK = rh.PROCESS_ID
    left outer join MASTER_PHASE   as mp on mp.PROCESS_ID_PK = proc.PROCESS_ID_PK
                                        and mp.PHASE_ID_PK   = log.PHASE_ID_PK
                                        and mp.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    left outer join MASTER_BLOCK   as mb on mb.PROCESS_ID_PK = proc.PROCESS_ID_PK
                                        and mb.PHASE_ID_PK   = log.PHASE_ID_PK
                                        and mb.BLOCK_ID_PK   = log.BLOCK_ID_PK
                                        and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    left outer join DOCUMENT_FLOWS as doc on doc.documentId = log.DOCUMENT_ID
    left outer join WORKS as works on works.ID = log.WORK_ID;

entity BLOCK_PHASE_REQUEST(p_blockId : UUID)      as
  select
      key bh.BLOCK_ID,
          bh.MASTER_BLOCK_ID,
          bh.BLOCK_STATUS,
          ph.PHASE_ID,
          ph.MASTER_PHASE_ID,
          rh.REQUEST_ID,
          rh.REQUEST_TYPE,
          rh.REQUEST_CODE,
          rh.PROCESS_ID,
          rh.COUNTRY_ID,
          rh.SITE_ID,
          rh.REQUEST_STATUS,
          p.PROCESS_ID_PK,
          bh.ROLE_ID
  from BLOCK_HEAD as bh
  inner join PHASE_HEAD as ph on  ph.PHASE_ID = bh.PHASE_ID
                              and bh.BLOCK_ID = :p_blockId
  inner join REQUEST_HEAD as rh on rh.REQUEST_ID = ph.REQUEST_ID
  inner join PROCESS as p on p.ID_PK = rh.PROCESS_ID;      

entity WORKS_BLOCK_PHASE_REQUEST(p_workId : UUID)      as
  select
      key gt.ID       as WORK_ID,
          gt.type.ID  as TYPE,
          gt.status   as STATUS, 
          bh.BLOCK_ID,
          bh.MASTER_BLOCK_ID,
          bh.BLOCK_STATUS,
          ph.PHASE_ID,
          ph.MASTER_PHASE_ID,
          rh.REQUEST_ID,
          rh.REQUEST_TYPE,
          rp.PROJECT_OBJECTIVE,
          rh.PROCESS_ID,
          rh.COUNTRY_ID,
          rh.SITE_ID,
          p.PROCESS_ID_PK,
          bh.ROLE_ID
  from WORKS as gt
  inner join BLOCK_HEAD as bh on  bh.BLOCK_ID = gt.parentId
                              and gt.parentType.ID = 30
                              and gt.ID = :p_workId
  inner join PHASE_HEAD as ph on  ph.PHASE_ID = bh.PHASE_ID
  inner join REQUEST_HEAD as rh on rh.REQUEST_ID = ph.REQUEST_ID
  inner join REQUEST_CHAR_PRO as rp on rp.REQUEST_ID = rh.REQUEST_ID
  inner join PROCESS as p on p.ID_PK = rh.PROCESS_ID;      

entity CHECKLIST_BLOCK_PHASE_REQUEST(p_taskId : UUID)      as
  select
      key ci.ID       as ITEM_ID,
          ci.type.ID  as TYPE,
          bh.BLOCK_ID,
          bh.MASTER_BLOCK_ID,
          bh.BLOCK_STATUS,
          ph.PHASE_ID,
          ph.MASTER_PHASE_ID,
          rh.REQUEST_ID,
          rh.REQUEST_TYPE,
          rp.PROJECT_OBJECTIVE,
          rh.PROCESS_ID,
          rh.COUNTRY_ID,
          rh.SITE_ID,
          p.PROCESS_ID_PK
  from Checklist.Item as ci
  inner join BLOCK_HEAD as bh on  bh.BLOCK_ID = ci.block_ID
  inner join PHASE_HEAD as ph on  ph.PHASE_ID = bh.PHASE_ID
  inner join REQUEST_HEAD as rh on rh.REQUEST_ID = ph.REQUEST_ID
  inner join REQUEST_CHAR_PRO as rp on rp.REQUEST_ID = rh.REQUEST_ID
  inner join PROCESS as p on p.ID_PK = rh.PROCESS_ID;      

entity SITES_BY_AOTYPE(p_aotype : String(3)) as select 
    key site.AOID           as siteId,
        site.AOTYPE,
        site.ZZMUNA         as legacyCode,
        site.ZZINFO         as primaryLegacyCode,
        site.XAO            as siteName,
        // alias.ZALIAS        as siteAlias,
        emplaz.BUKRS        as company,
        site.ZZUNIDOPER     as cellnexZone,
        site.ZZOPERTYPE     as infraOrigin,
        site.ZZOWNERSHIP    as infraOwner,
        site.ZZCOMERCIAL    as marketableId,
        site.ZZABFZONE      as abfZone,  
        address.COUNTRY     as country,
        address.REGION      as region,
        site.ZZCOMUNIDAD    as comunity,
        address.CITY1       as city,
        address.POST_CODE1  as postalCode,
        address.STREET      as street,
        address.HOUSE_NUM1  as houseNumber,
        address.FLOOR       as floor
        // Cellnex project. Read only maintained in ECC.
        // Site direction data. Read only maintained in ECC.
        // Cellnex zone. Zzunidopertxt
        // Infrastructure origin. Zzoperorigintxt
        // Telecom infra ownership. Zzownershiptxt
        // Marketable. Zzcomercialtxt
        // marketableId Zzcomercial
        // Customer area. Read only maintained in ECC.
        // ABF zone. Zzabfzonetxt
        // Landlord name. Read only maintained in ECC.
        // Infra status. Read only maintained in ECC.
        // Exploited. Read only maintained in ECC.
        // Production manager. Read only maintained in ECC.
        // Production region manager. Read only maintained in ECC.
        // Production zone responsible. Read only maintained in ECC.
        // Site manager. Read only maintained in ECC.
        // Region site manager. Read only maintained in ECC.
        // Site manager zone responsible. Read only maintained in ECC.
  from VIBDAO as site
  inner join VIBDOBJASS as relation      on relation.OBJNRSRC   = site.OBJNR
                                        and relation.OBJASSTYPE = '61'          //Technical location relation typ2
                                        and site.AOTYPE = :p_aotype
  inner join IFLOT as details            on details.OBJNR   = relation.OBJNRTRG
  inner join ILOA  as emplaz             on emplaz.ILOAN    = details.ILOAN
  left outer join VZOBJECT as adrcrel   on adrcrel.ADROBJNR = site.INTRENO
                                      and adrcrel.ADROBJTYP = 'VI'
                                      and adrcrel.OBTYP = '56'
  left outer join ADRC as address       on address.ADDRNUMBER = adrcrel.ADRNR;
  // left outer join ZRETOAALIAS as alias   on alias.INTRENO = site.INTRENO;

//T005S Regiones site
// Production Manager              --> OPProduction
// Production region manager       --> OPRegion
// Production zone responsible     --> OPArea
// Site manager                    --> Maintainer
// Region Site manager             --> SMRegion
// Site manager zone responsible   --> SMArea

entity SITES as select distinct
    key site.AOID               as siteId,
        site.AOTYPE,
        site.ZZINFO             as primaryLegacyCode,
        site.ZZMUNA             as legacyCode,
        site.XAO                as siteName,
        emplaz.BUKRS            as company,
        site.ZZUNIDOPER         as cellnexZone,         //ZOPE
        site.ZZONE              as zone,                //ZONE
        site.ZZOPERTYPE         as infraOrigin,         //ORIG
        site.ZZOWNERSHIP        as infraOwnership,      //OWSH
        site.ZZINFCONSTSTAT     as infraStatus,         //ICST
        site.ZZCOMERCIAL        as marketableId,        //COME
        site.ZZABFZONE          as abfZone,             //ABFZ
        site.ZZTITULARIDAD      as managingCompany,     //TITU
        site.ZZPROYECT          as cellnexProject,      //PROY
        site.ZZEXPLOITEDSITE    as exploited,           //EXSI
        site.ZZCOMUNIDAD        as comunity,
        address.COUNTRY         as country,
        address.REGION          as region,
        address.CITY1           as city,
        address.POST_CODE1      as postalCode,
        address.STREET          as street,
        address.HOUSE_NUM1      as houseNumber,
        address.FLOOR           as floor,
        pzr.PARTNER             as productionZoneResponsible : String(10)                       @(title: '{i18n>productionZoneResponsible}'),
        case 
            when pzrb.TYPE = 1 then pzrb.NAME_FIRST || ' ' || pzrb.NAME_LAST 
            else pzrb.NAME_ORG1 || ' ' || pzrb.NAME_ORG2 || ' ' || pzrb.NAME_ORG3 || ' ' || pzrb.NAME_ORG4
        end as productionZoneResponsibleName : String(400),
        szr.PARTNER             as siteManagerZoneResponsible : String(10)                      @(title: '{i18n>siteManagerZoneResponsible}'),
        case 
            when szrb.TYPE = 1 then szrb.NAME_FIRST || ' ' || szrb.NAME_LAST 
            else szrb.NAME_ORG1 || ' ' || szrb.NAME_ORG2 || ' ' || szrb.NAME_ORG3 || ' ' || szrb.NAME_ORG4
        end as siteManagerZoneResponsibleName : String(400),
        prm.PARTNER             as productionRegionManager : String(10)                         @(title: '{i18n>productionRegionManager}'),
        case 
            when prmb.TYPE = 1 then prmb.NAME_FIRST || ' ' || prmb.NAME_LAST 
            else prmb.NAME_ORG1 || ' ' || prmb.NAME_ORG2 || ' ' || prmb.NAME_ORG3 || ' ' || prmb.NAME_ORG4
        end as productionRegionManagerName : String(250),
        rsm.PARTNER             as regionSiteManager : String(10)                               @(title: '{i18n>regionSiteManager}'),
        case 
            when rsmb.TYPE = 1 then rsmb.NAME_FIRST || ' ' || rsmb.NAME_LAST 
            else rsmb.NAME_ORG1 || ' ' || rsmb.NAME_ORG2 || ' ' || rsmb.NAME_ORG3 || ' ' || rsmb.NAME_ORG4
        end as regionSiteManagerName : String(400),
        pmg.PARTNER             as productionManager : String(10)                               @(title: '{i18n>productionManager}'),
        case 
            when pmgb.TYPE = 1 then pmgb.NAME_FIRST || ' ' || pmgb.NAME_LAST 
            else pmgb.NAME_ORG1 || ' ' || pmgb.NAME_ORG2 || ' ' || pmgb.NAME_ORG3 || ' ' || pmgb.NAME_ORG4
        end as productionManagerName : String(400),
        smg.PARTNER             as siteManager : String(10)                                     @(title: '{i18n>siteManager}'),
        case 
            when smgb.TYPE = 1 then smgb.NAME_FIRST || ' ' || smgb.NAME_LAST 
            else smgb.NAME_ORG1 || ' ' || smgb.NAME_ORG2 || ' ' || smgb.NAME_ORG3 || ' ' || smgb.NAME_ORG4
        end as siteManagerName : String(400),
        '' as landlordName :String(400)                                                         @(title: '{i18n>landlordName}')
  from VIBDAO as site
  inner join VIBDOBJASS as relation      on relation.OBJNRSRC   = site.OBJNR
                                        and relation.OBJASSTYPE = '61'          //Technical location relation typ2
  inner join IFLOT as details            on details.OBJNR   = relation.OBJNRTRG
  inner join ILOA  as emplaz             on emplaz.ILOAN    = details.ILOAN
  left outer join VZOBJECT as adrcrel   on adrcrel.ADROBJNR = site.INTRENO
                                      and adrcrel.ADROBJTYP = 'VI'
                                      and adrcrel.OBTYP = '56'
  left outer join VIBPOBJREL as pzr      on pzr.INTRENO = site.INTRENO //production zone responsible
                                        and pzr.ROLE = 'ZSM001'
                                        and pzr.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD')
                                        and pzr.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')
  left outer join BUT000 as pzrb         on pzrb.PARTNER = pzr.PARTNER
  left outer join VIBPOBJREL as szr      on szr.INTRENO = site.INTRENO //site manager zone responsible
                                        and szr.ROLE = 'ZSM002'
                                        and szr.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD')
                                        and szr.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')
  left outer join BUT000 as szrb         on szrb.PARTNER = szr.PARTNER
  left outer join VIBPOBJREL as prm      on prm.INTRENO = site.INTRENO //production region manager
                                        and prm.ROLE = 'ZSM003'
                                        and prm.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD')
                                        and prm.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')
  left outer join BUT000 as prmb         on prmb.PARTNER = prm.PARTNER
  left outer join VIBPOBJREL as rsm      on rsm.INTRENO = site.INTRENO //region site manager
                                        and rsm.ROLE = 'ZSM004'
                                        and rsm.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD')
                                        and rsm.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')
  left outer join BUT000 as rsmb         on rsmb.PARTNER = rsm.PARTNER
  left outer join VIBPOBJREL as pmg      on pmg.INTRENO = site.INTRENO //production manager
                                        and pmg.ROLE = 'ZSM005'
                                        and pmg.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD')
                                        and pmg.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')
  left outer join BUT000 as pmgb         on pmgb.PARTNER = pmg.PARTNER
  left outer join VIBPOBJREL as smg      on smg.INTRENO = site.INTRENO //site Manager
                                        and smg.ROLE = 'ZSM006'
                                        and smg.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD')
                                        and smg.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')
  left outer join BUT000 as smgb         on smgb.PARTNER = smg.PARTNER
  left outer join ADRC as address       on address.ADDRNUMBER = adrcrel.ADRNR;

entity LANDLORD_BY_SITE (p_siteId: String) as select from (
    select
        site.AOID,
        site.AOTYPE,
        contract.RECNNR,
        contract.BUKRS,
        partner.PARTNER,
        contrels.ROLE,
        partner.![TYPE],
        partner.VALID_FROM,
        partner.VALID_TO,
        case 
            when partner.![TYPE] = 1 then partner.NAME_FIRST || ' ' || partner.NAME_LAST
            else partner.NAME_ORG1 || ' ' || partner.NAME_ORG2 || ' ' || partner.NAME_ORG3 || ' ' || partner.NAME_ORG4
        end as fullName,
        row_number() over (
            partition by contract.RECNNR, contract.BUKRS, partner.PARTNER
            order by case contrels.ROLE
                when 'ZRE011' then 1
                when 'ZRE001' then 2
                when 'ZRE006' then 3
            end
        ) as rn
    from VIBDAO as site
    inner join VIBDOBJREL as siterels on siterels.INTRENOSRC = site.INTRENO
                                     and site.AOID = :p_siteId
    inner join VIBDBE as ue on ue.INTRENO = siterels.INTRENOTRG
    inner join VIBDOBJASS as ueass on ueass.OBJNRTRG = ue.OBJNR
    inner join VICNCN as contract on contract.OBJNR = ueass.OBJNRSRC
                                 and contract.RECNTYPE = '0011'
    inner join VIBPOBJREL as contrels on contrels.INTRENO = contract.INTRENO
                                     and contrels.ROLE in ('ZRE001', 'ZRE011', 'ZRE006')
    inner join BUT000 as partner on partner.PARTNER = contrels.PARTNER
                                and ( partner.VALID_FROM is null or partner.VALID_FROM <= to_number(to_varchar(current_timestamp, 'YYYYMMDDHHMMSS')) )
                                and ( partner.VALID_TO is null or partner.VALID_TO >= to_number(to_varchar(current_timestamp, 'YYYYMMDDHHMMSS')) )
) where rn = 1;

entity REGIONS as select distinct
    key LAND1   as country,
    key BLAND   as code,
        BEZEI   as description
from T005U
where SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity CELLNEX_ZONES as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'UOPE'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity ZONES as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'ZONE'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity INFRA_ORIGINS as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'ORIG'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity INFRA_OWNERSHIPS as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'OWSH'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity INFRA_STATUS as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'ICST'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity MARKETABLES as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'COME'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity ABF_ZONES as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'ABFZ'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity MANAGING_COMPANIES as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'TITU'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity CELLNEX_PROJECTS as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'PROY'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity EXPLOITEDS as select
    key VALUE as code,
        XVALUE as description
    from ZRECOAVALUEST
    where VALUETYPE = 'EXSI'
      and SPRAS in (SELECT SPRAS from ECC_LANGUAGES where LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

entity CUSTOMERS (p_siteId: String(30)) as select distinct 
    key site.AOID           as siteId                                           @(title: '{i18n>siteId}'),
    key case 
    	when customer.PARTNER is not null and customer.PARTNER != '' then customer.PARTNER
    	else oldcustomer.PARTNER
    end as customerId:String(10)                                                @(title: '{i18n>customer}'),
    // key customer.PARTNER    as customerId                                       @(title: '{i18n>customer}'),
        site.XAO            as siteName                                         @(title: '{i18n>siteName}'),
        case 
    	    when customer.PARTNER is not null and customer.PARTNER != '' then customer.NAME_ORG1 || ' ' || customer.NAME_ORG2
    	    else oldcustomer.NAME_ORG1 || ' ' || oldcustomer.NAME_ORG2
        end as customerName:String                                              @(title: '{i18n>customerName}'),
        // customer.NAME_ORG1 || ' ' ||customer.NAME_ORG2 as customerName:String   @(title: '{i18n>customerName}'),
        alias.ZALIAS        as alias                                            @(title: '{i18n>alias}'),
        alias.ZALIASNAME    as aliasName                                        @(title: '{i18n>aliasName}'),
        alias.ZALIASSERV    as aliasServ                                        @(title: '{i18n>aliasService}'),
        alias.ZALIASOTHER   as aliasOther                                       @(title: '{i18n>aliasOther}'),  
        alias.PARTNZONE     as aliasClientArea                                  @(title: '{i18n>aliasClientArea}'),
        alias.ZALIASKEY     as aliasKey                                         @(title: '{i18n>aliasKey}')
  from VIBDAO as site
  inner join VIBDOBJASS as relation      on relation.OBJNRSRC   = site.OBJNR
                                        and relation.OBJASSTYPE = '61'          //Technical location relation typ2
                                        and site.AOID = :p_siteId
  inner join IFLOT as details            on details.OBJNR   = relation.OBJNRTRG
  inner join ZPMSERVLOC  as locserv      on locserv.ZZSITE = details.TPLNR and locserv.ZZMARKDEL != true
  inner join ZPMSITESERV as service      on service.ZZIDINTERN = locserv.ZZIDINTERN
  inner join ZPMSERVCHNGS as srvstatus   on srvstatus.ZZIDINTERN = locserv.ZZIDINTERN and srvstatus.ZZSTATUS_OP = 'OP30' and srvstatus.ACTIVE = 'X'
  left outer join BUT000 as customer     on customer.PARTNER = service.ZZBUSINESSPRTNR
  left outer join CVI_CUST_LINK as cv    on cv.CUSTOMER = service.ZZCUSTOMER
  left outer join BUT000 as oldcustomer  on oldcustomer.PARTNER_GUID = cv.PARTNER_GUID
  left outer join ZRETOAALIAS as alias   on alias.INTRENO = site.INTRENO and ( alias.PARTNER = customer.PARTNER or alias.PARTNER = oldcustomer.PARTNER );

entity REQUEST_CUSTOMERS(p_requestId: UUID) as select distinct
    key request.REQUEST_ID  as requestId,
    key site.AOID           as siteId                                           @(title: '{i18n>siteId}'),
    key case 
    	when customer.PARTNER is not null and customer.PARTNER != '' then customer.PARTNER
    	else oldcustomer.PARTNER
    end as customerId:String(10)                                                @(title: '{i18n>customer}'),
    // key customer.PARTNER    as customerId                                       @(title: '{i18n>customer}'),
        site.XAO            as siteName                                         @(title: '{i18n>siteName}'),
        case 
    	    when customer.PARTNER is not null and customer.PARTNER != '' then customer.NAME_ORG1 || ' ' || customer.NAME_ORG2
    	    else oldcustomer.NAME_ORG1 || ' ' || oldcustomer.NAME_ORG2
        end as customerName:String                                              @(title: '{i18n>customerName}'),
        // customer.NAME_ORG1 || ' ' ||customer.NAME_ORG2 as customerName:String   @(title: '{i18n>customerName}'),
        alias.ZALIAS        as alias                                            @(title: '{i18n>alias}'),
        alias.ZALIASNAME    as aliasName                                        @(title: '{i18n>aliasName}'),
        alias.ZALIASSERV    as aliasServ                                        @(title: '{i18n>aliasService}'),
        alias.ZALIASOTHER   as aliasOther                                       @(title: '{i18n>aliasOther}'),  
        alias.PARTNZONE     as aliasClientArea                                  @(title: '{i18n>aliasClientArea}'),
        alias.ZALIASKEY     as aliasKey                                         @(title: '{i18n>aliasKey}'),
        case 
            when impacted.customer is not null then true
            else false
        end as impacted: Boolean                                                @(title: '{i18n>impacted}')
  from REQUEST_HEAD as request      
  inner join VIBDAO as site              on site.AOID = request.SITE_ID
                                        and request.REQUEST_ID = :p_requestId
  inner join VIBDOBJASS as relation      on relation.OBJNRSRC   = site.OBJNR and relation.OBJASSTYPE = '61'          //Technical location relation typ2
  inner join IFLOT as details            on details.OBJNR   = relation.OBJNRTRG
  inner join ZPMSERVLOC  as locserv      on locserv.ZZSITE = details.TPLNR and locserv.ZZMARKDEL != true
  inner join ZPMSITESERV as service      on service.ZZIDINTERN = locserv.ZZIDINTERN
  inner join ZPMSERVCHNGS as srvstatus   on srvstatus.ZZIDINTERN = locserv.ZZIDINTERN and srvstatus.ZZSTATUS_OP = 'OP30' and srvstatus.ACTIVE = 'X'
  left outer join BUT000 as customer     on customer.PARTNER = service.ZZBUSINESSPRTNR
  left outer join CVI_CUST_LINK as cv    on cv.CUSTOMER = service.ZZCUSTOMER
  left outer join BUT000 as oldcustomer  on oldcustomer.PARTNER_GUID = cv.PARTNER_GUID
  left outer join REQUEST_IMPACTED_CUSTOMERS as impacted on impacted.requestId = request.REQUEST_ID and ( impacted.customer = customer.PARTNER or impacted.customer = oldcustomer.PARTNER ) and (deleted = false or deleted is null)
  left outer join ZRETOAALIAS as alias   on alias.INTRENO = site.INTRENO and ( alias.PARTNER = customer.PARTNER or alias.PARTNER = oldcustomer.PARTNER );

entity PREFERRED_PROVIDERS as 
  select distinct
    key ENTITY_ID   as code,
        ENTITY_NAME as name
  from CACHE_R3_ENTITIES
  where ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' and USER_ID = SESSION_CONTEXT('APPLICATIONUSER');

entity USERS(p_country : String)                  as
    select
        key USERS.USER_ID        as userId,
            USERS.USER_NAME      as userName,
            USERS.EMAIL          as email,
            USERS.TELEPHONE      as telephone,
            COUNTRIES.COUNTRY_ID as country,
        key ROLES.IAS_GROUP      as iasGroup,
            ''                   as requestId,
            ''                   as blockId
    from US_USERS_IAS as USERS 
    inner join US_COUNTRIES as COUNTRIES on COUNTRIES.USER_ID    = USERS.USER_ID
                                        and COUNTRIES.COUNTRY_ID = :p_country
    inner join US_BUKS as BUKS on BUKS.USER_ID = USERS.USER_ID
    inner join US_ROLES_AGR as ROLES on ROLES.USER_ID   = USERS.USER_ID;

entity BLOCKS_RESPONSIBLES(p_requestId : UUID)    as
    select
        key bh.BLOCK_ID             as ID,
            bh.BLOCK_STATUS         as status,
            :p_requestId            as requestId,
            rh.PROCESS_ID           as requestProcessFlowId          @(title: '{i18n>processType}'),
            p.PROCESS_ID_PK         as ProcessFlowType               @(title: '{i18n>processType}'),
            ph.MASTER_PHASE_ID      as phaseProcessFlowId            @(title: '{i18n>phase}'),
            mp.PHASE_NAME           as phaseName                     @(title: '{i18n>phaseName}'),
            bh.MASTER_BLOCK_ID      as blockProcessFlowId            @(title: '{i18n>block}'),
            mb.BLOCK_NAME           as blockName                     @(title: '{i18n>blockName}'),
            bp.ASSIGNED_RESPONSIBLE as approverType,
            0                       as approverTypeFC        : UInt8 @odata.Nullable,
            at.name                 as approverName,
            bp.SUBCONTRACTOR_TYPE   as subcoType,
            0                       as subcoTypeFC           : UInt8 @odata.Nullable,
            st.name                 as subcoName,
            bp.PROVIDER_NAME        as externalResponsible,
            exu.USER_NAME           as externalResponsibleName,
            0                       as externalResponsibleFC : UInt8 @odata.Nullable,
            bp.RESPONSIBLE_PERSON   as internalResponsible,
            inu.USER_NAME           as internalResponsibleName,
            0                       as internalResponsibleFC : UInt8 @odata.Nullable
    from REQUEST_HEAD as rh
    left join PROCESS as p on p.ID_PK = rh.PROCESS_ID
    inner join PHASE_HEAD as ph on  ph.REQUEST_ID = rh.REQUEST_ID
                                and ph.REQUEST_ID = :p_requestId
    left join MASTER_PHASE as mp on  mp.PROCESS_ID_PK = p.PROCESS_ID_PK
                                 and mp.PHASE_ID_PK   = ph.MASTER_PHASE_ID
                                 and mp.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
    left join MASTER_BLOCK as mb on  mb.PROCESS_ID_PK = p.PROCESS_ID_PK
                                 and mb.PHASE_ID_PK   = ph.MASTER_PHASE_ID
                                 and mb.BLOCK_ID_PK   = bh.MASTER_BLOCK_ID
                                 and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join BLOCKS_PROVISIONING as bp on bp.BLOCK_ID        =      bh.BLOCK_ID
                                        and bp.ASSIGNED_RESPONSIBLE is not null
                                        and bp.ASSIGNED_RESPONSIBLE !=     ''
    left join APPROVER_TYPES as at on at.code = bp.ASSIGNED_RESPONSIBLE
    left join SUBCO_TYPES as st on st.code = bp.SUBCONTRACTOR_TYPE
    left join US_USERS_IAS as inu on inu.USER_ID = bp.RESPONSIBLE_PERSON
    left join US_USERS_IAS as exu on exu.USER_ID = bp.PROVIDER_NAME;

 entity BLOCK_PHASE_REQUEST_DOCUMENT_INSTANCE(p_registerId  : UUID) as
  select
      key BH.BLOCK_ID,
      BH.MASTER_BLOCK_ID,
      PH.PHASE_ID,
      PH.MASTER_PHASE_ID,
      RH.REQUEST_ID,
      RH.REQUEST_TYPE,
      RH.PROCESS_ID,
      RH.COUNTRY_ID,
      RH.SITE_ID,
      P.PROCESS_ID_PK,
      DPB.GENERIC_TYPE_ID 
    from REQUEST_HEAD as RH
    inner join PROCESS as P on P.ID_PK = RH.PROCESS_ID
    inner join PHASE_HEAD as PH
        on PH.REQUEST_ID = RH.REQUEST_ID
    inner join BLOCK_HEAD as BH
        on BH.PHASE_ID = PH.PHASE_ID
    inner join DOCUMENTS_PER_BLOCK as DPB
        on DPB.BLOCK_ID = BH.BLOCK_ID
    inner join INSTANCES_PER_DOCUMENT as IPD
        on IPD.INSTANCE_ID = DPB.REGISTER_ID
    where IPD.REGISTER_ID = :p_registerId ;


 entity BLOCK_PHASE_REQUEST_DOCUMENT(p_registerId  : UUID) as
  select
      key BH.BLOCK_ID,
      BH.MASTER_BLOCK_ID,
      PH.PHASE_ID,
      PH.MASTER_PHASE_ID,
      RH.REQUEST_ID,
      RH.REQUEST_TYPE,
      RH.PROCESS_ID,
      RH.COUNTRY_ID,
      RH.SITE_ID,
      P.PROCESS_ID_PK,
      DPB.GENERIC_TYPE_ID 
    from REQUEST_HEAD as RH
    inner join PROCESS as P on P.ID_PK = RH.PROCESS_ID
    inner join PHASE_HEAD as PH
        on PH.REQUEST_ID = RH.REQUEST_ID
    inner join BLOCK_HEAD as BH
        on BH.PHASE_ID = PH.PHASE_ID
    inner join DOCUMENTS_PER_BLOCK as DPB
        on DPB.BLOCK_ID = BH.BLOCK_ID
    where  DPB.REGISTER_ID = :p_registerId ;

entity PROJECT_TYPES {
    key code:       String(10)    @title: '{i18n>projectType}';
    key country:    String(2)     @title: '{i18n>country}';
        name:       localized String(100) @title: '{i18n>description}';
}

entity AUX_PROJECT_TYPES as select
    key PROJECT_TYPES.code as code,
        coalesce(l.name, PROJECT_TYPES.name) as name: String(255),
        PROJECT_TYPES.country
    from (PROJECT_TYPES left join PROJECT_TYPES.texts as l on l.code = PROJECT_TYPES.code and l.locale = SESSION_CONTEXT('LOCALE'));

entity CONFIRM_BUTTONS(p_requestId : UUID, p_master_phase_id : String, p_master_block_id : String)                      as
    select
        bp.BTTN_INV_UPDATED,
        bp.BTTN_SERV_UPDATED,
        bp.BTTN_DOC_UPDATED
    from REQUEST_HEAD as rh
    inner join PHASE_HEAD as ph
        on  ph.REQUEST_ID      = :p_requestId
        and ph.MASTER_PHASE_ID = :p_master_phase_id
    inner join BLOCK_HEAD as bh
        on  bh.PHASE_ID        = ph.PHASE_ID
        and bh.MASTER_BLOCK_ID = :p_master_block_id
    inner join BLOCKS_PROVISIONING as bp
        on bp.BLOCK_ID = bh.BLOCK_ID
    inner join PROCESS as p
        on p.ID_PK = rh.PROCESS_ID;