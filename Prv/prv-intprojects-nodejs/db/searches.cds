using {
    REQUEST_HEAD,
    REQUEST_CHAR_PRO,
    PHASE_HEAD,
    BLOCK_HEAD,
    BLOCKS_PROVISIONING,
    DOCUMENTS_PER_BLOCK,
    INSTANCES_PER_DOCUMENT,
    CACHE_R3_ENTITIES,
    STATUS_TEXTS
} from './cellnex';
using { localized_REQUEST_STATUS, localized_BLOCK_STATUS, localized_DOCUMENT_FLOW_STATUS, localized_TASK_TYPES, SITES, CELLNEX_ZONES, REGIONS, AUX_PROJECT_TYPES, COMPLEXITIES } from './common';
using { PROCESS, MASTER_PHASE, MASTER_BLOCK, LAST_ACTIVE_PHASE_BLOCK } from './processflow';
using { DOCUMENT_FLOWS } from './document';
using { US_USERS_IAS } from './userinfo';
using { WORKS, PROJECT_OBJECTIVES_BY_COUNTRY } from './works';

entity SEARCH_BY_REQUESTS                         as
    select
        key rh.REQUEST_ID            as ID : UUID,
            rh.WORKFLOW_ID           as projectType @(title : '{i18n>projectType}'),
            pt.name                  as projectTypeName @(title: '{i18n>description}'),
            rp.PROJECT_OBJECTIVE     as projectObjective,
            po.name                  as projectObjectiveName,
            rh.REQUEST_CODE          as code,
            rh.COUNTRY_ID            as country,
            rh.REQUEST_STATUS        as status,
            rs.name                  as statusName,
            sc.COMPLEXITY            as complexity,
            co.name                  as complexityName,
            rh.SITE_ID               as siteId,
            sit.siteName,
            sit.region               as siteRegion,
            rg.description           as siteRegionName,
            sit.city                 as siteCity,
            sit.cellnexZone          as cellnexZone,
            cz.description           as cellnexZoneName @(title: '{i18n>description}'),
            sit.legacyCode           as siteLegacyCode,
            la.lastPhase,
            la.lastPhaseName,
            la.lastBlock,
            la.lastBlockName,
            // rp.MIGRATION_REQUEST_ID     as legacyRequestId,
            // rh.CUSTOMER_REQUEST_ID   as customerRequestCode,
            rp.REQUESTED_DATE        as requestedDate,
            rh.CREATEDAT             as createdAt,
            rh.REQUEST_OWNER_ID      as manager,
            us.USER_NAME             as managerName,
            rp.PREFERRED_PROVIDER    as preferredProvider,
            pp.ENTITY_NAME           as preferredProviderName,
            rh.ASSIGNATION_DATE      as assignationDate,
            // rp.PROJECT               as commercialProgram,
            bh.ROLE_ID               as roleId,
            case 
	            when idp.STEP_ID = '0' then
                    case 
                        when db.RESPONSIBLE_ID = '1' then 'TIS_Cellnex'
                        when db.RESPONSIBLE_ID = '2' then
                            case 
                                when db.SUBCONTRATOR_ID = '2' then 'TIS_WF_PRO_Customer'
                                when db.SUBCONTRATOR_ID = '3' then 'TIS_WF_PRO_Subcontractor'
                                when db.SUBCONTRATOR_ID = '4' then 'TIS_WF_PRO_Agency'
                                else 'TIS_WF_PRO_Subcontractor'
                            end
                    end
                when idp.STEP_ID = '10' then
                    case 
                        when db.RESPONSIBLE_ID = '1' then 'TIS_Cellnex'
                        when db.RESPONSIBLE_ID = '2' then
                            case 
                                when db.SUBCONTRATOR_ID = '2' then 'TIS_WF_PRO_Customer'
                                when db.SUBCONTRATOR_ID = '3' then 'TIS_WF_PRO_Subcontractor'
                                when db.SUBCONTRATOR_ID = '4' then 'TIS_WF_PRO_Agency'
                                else 'TIS_WF_PRO_Subcontractor'
                            end
                    end
                when idp.STEP_ID = '20' then 'TIS_Cellnex'
                when idp.STEP_ID = '30' then 'TIS_WF_PRO_Subcontractor'
                when idp.STEP_ID = '40' then 'TIS_WF_PRO_Customer'
                else bh.ROLE_ID
            end as documentRoleId:String(50),
            bp.SUBCONTRACTOR_TYPE    as subcoType,
            bp.RESPONSIBLE_PERSON    as internalResponsible,
            bp.PROVIDER_NAME         as externalResponsible,
            db.SUBCONTRATOR_ID       as documentSubcontractor,
            0                        as searchType,
            db.T_RESPONSIBLE         as assignedResponsible,
            case 
                when idp.STEP_ID = '20' then idp.CELLNEX_VALIDATOR
                when idp.STEP_ID = '30' then idp.SUBCONTRACTOR_VALIDATOR
                when idp.STEP_ID = '40' then idp.CUSTOMER_VALIDATOR
                else db.T_RESPONSIBLE
            end as validator: String(100),
            case 
                when rh.REQUEST_STATUS = 7 then 2
                when rh.REQUEST_STATUS = 3 then 3
                when rh.REQUEST_STATUS = 4 then 1
                when rh.REQUEST_STATUS = 12 then 1
                when rh.REQUEST_STATUS = 32 then 2
                else 0
            end as objectStatus: Integer
    from REQUEST_HEAD as rh
    inner join SITES as sit on sit.siteId = rh.SITE_ID
    inner join REQUEST_CHAR_PRO as rp on rp.REQUEST_ID = rh.REQUEST_ID and (rh.REQUEST_TYPE = 40)
    left outer join LAST_ACTIVE_PHASE_BLOCK as la on la.REQUEST_ID = rh.REQUEST_ID
    left outer join SEARCH_BY_COMPLEXITIES as sc on sc.REQUEST_ID = rh.REQUEST_ID
    left outer join COMPLEXITIES as co on co.code = sc.COMPLEXITY and co.country = rh.COUNTRY_ID
    left outer join CELLNEX_ZONES as cz on cz.code = sit.cellnexZone
    left outer join REGIONS as rg on rg.country = sit.country and rg.code = sit.region
    left outer join AUX_PROJECT_TYPES as pt on pt.code = rh.WORKFLOW_ID and pt.country = rh.COUNTRY_ID
    left outer join PROJECT_OBJECTIVES_BY_COUNTRY as po on po.ID = rp.PROJECT_OBJECTIVE and po.country = rh.COUNTRY_ID
    left outer join localized_REQUEST_STATUS as rs on rs.code = rh.REQUEST_STATUS
    left outer join US_USERS_IAS as us on us.USER_ID = rh.REQUEST_OWNER_ID
    inner join PHASE_HEAD as ph on ph.REQUEST_ID = rh.REQUEST_ID
    inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
    inner join BLOCKS_PROVISIONING as bp on bp.BLOCK_ID = bh.BLOCK_ID
    left outer join DOCUMENTS_PER_BLOCK as db on db.BLOCK_ID = bh.BLOCK_ID
    left outer join INSTANCES_PER_DOCUMENT as idp on idp.INSTANCE_ID = db.REGISTER_ID
    left outer join CACHE_R3_ENTITIES as pp on pp.ENTITY_ID = rp.PREFERRED_PROVIDER
                                        and pp.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK'
                                        and pp.USER_ID = SESSION_CONTEXT('APPLICATIONUSER');

entity SEARCH_BY_TASKS                            as
    select         
        key SEARCH_BY_TASKS_WOTASK.ID,
            SEARCH_BY_TASKS_WOTASK.code,
            requestStatus,
            st.name as requestStatusName,
            SEARCH_BY_TASKS_WOTASK.country,
            projectType,
            pt.name as projectTypeName,
            projectObjective,
            po.name as projectObjectiveName,
            status,
            statusName,
            complexity,
            complexityName,
            siteId,
            siteName,
            siteRegion,
            rg.description as siteRegionName,
            siteCity,
            cellnexZone,
            cz.description as cellnexZoneName,
            siteLegacyCode,
            // legacyRequestId,
            // customerRequestCode,
            requestedDate,
            createdAt,
        key masterPhaseId,
            phase,
        key masterBlockID,
            block,
            la.lastPhase,
            la.lastPhaseName,
            la.lastBlock,
            la.lastBlockName,
            roleId,
        key workId,
            work,
            workType,
            workTypeName,
            assignedResponsible,
            assignedResponsibleName,
            validator,
            validatorName,
            internalResponsible,
            externalResponsible,
            manager,
            managerName,
            preferredProvider,
            preferredProviderName,
            assignationDate,
        key taskType,
            tt.name as taskTypeName,
            searchType,
        key documentId,
            documentType,
            documentName,
            documentValidation,
            case 
                when status = 7 then 2
                when status = 3 then 3
                when status = 4 then 1
                else 0
            end as objectStatus: Integer,
            case 
                when requestStatus = 7 then 2
                when requestStatus = 3 then 3
                when requestStatus = 4 then 1
                when requestStatus = 12 then 1
                when requestStatus = 32 then 2
                else 0
            end as objectRequestStatus: Integer,
            case 
                when la.lastPhase = masterPhaseId and la.lastBlock = masterBlockID then true
                else false
            end as isFirstBlock: Boolean
    from SEARCH_BY_TASKS_WOTASK
    left outer join LAST_ACTIVE_PHASE_BLOCK as la on la.REQUEST_ID = SEARCH_BY_TASKS_WOTASK.ID
    left outer join localized_TASK_TYPES as tt on tt.code = taskType
    left outer join localized_REQUEST_STATUS as st on st.code = requestStatus
    left outer join CELLNEX_ZONES as cz on cz.code = cellnexZone
    left outer join REGIONS as rg on rg.country = SEARCH_BY_TASKS_WOTASK.country and rg.code = siteRegion
    left outer join AUX_PROJECT_TYPES as pt on pt.code = projectType and pt.country = SEARCH_BY_TASKS_WOTASK.country
    left outer join PROJECT_OBJECTIVES_BY_COUNTRY as po on po.ID = projectObjective and po.country = SEARCH_BY_TASKS_WOTASK.country;

entity SEARCH_BY_TASKS_WOTASK                     as
    select * from SEARCH_BY_BLOCKS
    union all select * from SEARCH_BY_BLOCKS_WORKS
    union all select * from SEARCH_BY_DOCUMENTS;
    // union all select * from SEARCH_BY_WORK_DOCUMENTS;

entity SEARCH_BY_BLOCKS                           as
    select
        key rh.REQUEST_ID            as ID : UUID,
            rh.REQUEST_CODE          as code,
            rh.REQUEST_STATUS        as requestStatus,
            rh.COUNTRY_ID            as country,
            rh.WORKFLOW_ID           as projectType,
            rp.PROJECT_OBJECTIVE     as projectObjective,
            bh.BLOCK_STATUS          as status,
            bs.name                  as statusName,
            sc.COMPLEXITY            as complexity,
            co.name                  as complexityName,
            rh.SITE_ID               as siteId,
            sit.siteName,
            sit.region               as siteRegion,
            sit.city                 as siteCity,
            sit.cellnexZone          as cellnexZone,
            sit.legacyCode           as siteLegacyCode,
            // rh.CUSTOMER_REQUEST_ID   as customerRequestCode,
            // rp.MIGRATION_REQUEST_ID  as legacyRequestId,
            rp.REQUESTED_DATE        as requestedDate,
            rh.CREATEDAT             as createdAt,
        key ph.MASTER_PHASE_ID       as masterPhaseId,
            mp.PHASE_NAME            as phase,
        key bh.MASTER_BLOCK_ID       as masterBlockID,
            mb.BLOCK_NAME            as block,
        key ''                       as workId,
            ''                       as work,
            0                        as workType,
            ''                       as workTypeName,
            bh.ROLE_ID               as roleId,
            case bp.ASSIGNED_RESPONSIBLE
                when '1' then bp.RESPONSIBLE_PERSON
                when '2' then bp.PROVIDER_NAME
                else null
            end as assignedResponsible: String(100),
            case bp.ASSIGNED_RESPONSIBLE
                when '1' then usn.USER_NAME
                when '2' then 
                    case bp.SUBCONTRACTOR_TYPE
                        when '3' then sb.ENTITY_NAME
                        when '4' then ag.ENTITY_NAME
                        else null
                    end
                else null
            end as assignedResponsibleName: String(100),
            // usn.USER_NAME            as assignedResponsibleName,
            ''                       as validator,
            ''                       as validatorName,
            bp.RESPONSIBLE_PERSON    as internalResponsible,
            bp.PROVIDER_NAME         as externalResponsible,
            rh.REQUEST_OWNER_ID      as manager,
            us.USER_NAME             as managerName,
            rp.PREFERRED_PROVIDER    as preferredProvider,
            pp.ENTITY_NAME           as preferredProviderName,
            rh.ASSIGNATION_DATE      as assignationDate,
        key 0                        as taskType,
            0                        as searchType,
        key ''                       as documentId,
            ''                       as documentType,
            ''                       as documentName,
            ''                       as documentValidation
    from REQUEST_HEAD as rh left outer join PROCESS as p on p.ID_PK = rh.PROCESS_ID
    inner join SITES as sit on sit.siteId = rh.SITE_ID
    left outer join US_USERS_IAS as us on us.USER_ID = rh.REQUEST_OWNER_ID
    inner join REQUEST_CHAR_PRO as rp on rp.REQUEST_ID = rh.REQUEST_ID 
                                     and (rh.REQUEST_TYPE = 40)
    left outer join SEARCH_BY_COMPLEXITIES as sc on sc.REQUEST_ID = rh.REQUEST_ID
    left outer join COMPLEXITIES as co on co.code = sc.COMPLEXITY and co.country = rh.COUNTRY_ID
    inner join PHASE_HEAD as ph on ph.REQUEST_ID = rh.REQUEST_ID
                                and ph.PHASE_STATUS != 2
    left outer join MASTER_PHASE as mp on  mp.PROCESS_ID_PK = p.PROCESS_ID_PK
                                       and mp.PHASE_ID_PK   = ph.MASTER_PHASE_ID
                                       and mp.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
    left outer join localized_BLOCK_STATUS as bs on bs.code = bh.BLOCK_STATUS
    inner join BLOCKS_PROVISIONING as bp on bp.BLOCK_ID = bh.BLOCK_ID
    left outer join US_USERS_IAS as usn on usn.USER_ID = bp.RESPONSIBLE_PERSON
    left outer join CACHE_R3_ENTITIES as pp on pp.ENTITY_ID = rp.PREFERRED_PROVIDER
                                           and pp.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK'
                                           and pp.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as sb on sb.ENTITY_ID = bp.PROVIDER_NAME
                                           and sb.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK'
                                           and sb.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as ag on ag.ENTITY_ID = bp.PROVIDER_NAME
                                           and ag.ENTITY_TYPE = 'F4_GEWRK_AGEN'
                                           and ag.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join MASTER_BLOCK as mb on  mb.PROCESS_ID_PK = p.PROCESS_ID_PK
                                       and mb.PHASE_ID_PK   = mp.PHASE_ID_PK
                                       and mb.BLOCK_ID_PK   = bh.MASTER_BLOCK_ID
                                       and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'));

entity SEARCH_BY_BLOCKS_WORKS                    as
    select
        key rh.REQUEST_ID            as ID : UUID,
            rh.REQUEST_CODE          as code,
            rh.REQUEST_STATUS        as requestStatus,
            rh.COUNTRY_ID            as country,
            rh.WORKFLOW_ID           as projectType,
            rp.PROJECT_OBJECTIVE     as projectObjective,
            gt.status,
            st.STATUS_TEXT           as statusName,
            sc.COMPLEXITY            as complexity,
            co.name                  as complexityName,
            rh.SITE_ID               as siteId,
            sit.siteName,
            sit.region               as siteRegion,
            sit.city                 as siteCity,
            sit.cellnexZone          as cellnexZone,
            sit.legacyCode           as siteLegacyCode,
            // rh.CUSTOMER_REQUEST_ID   as customerRequestCode,
            // rp.MIGRATION_REQUEST_ID  as legacyRequestId,
            rp.REQUESTED_DATE        as requestedDate,
            rh.CREATEDAT             as createdAt,
        key ph.MASTER_PHASE_ID       as masterPhaseId,
            mp.PHASE_NAME            as phase,
        key bh.MASTER_BLOCK_ID       as masterBlockID,
            mb.BLOCK_NAME            as block,
        key gt.ID                    as workId,
            gt.description           as work,
            gt.type.ID               as workType,
            gt.type.descr            as workTypeName,
            bh.ROLE_ID               as roleId,
            case gt.responsibleType
                when '1' then gt.internalResponsible
                when '2' then gt.externalResponsible
                else 
                    case bp.ASSIGNED_RESPONSIBLE
                        when '1' then bp.RESPONSIBLE_PERSON
                        when '2' then bp.PROVIDER_NAME
                        else null
                    end 
            end as assignedResponsible: String(100),
            case gt.responsibleType
                when '1' then usw.USER_NAME
                when '2' then 
                    case gt.externalType
                        when '3' then sbw.ENTITY_NAME
                        when '4' then agw.ENTITY_NAME
                        else null
                    end
                else 
                    case bp.ASSIGNED_RESPONSIBLE
                        when '1' then usn.USER_NAME
                        when '2' then 
                            case bp.SUBCONTRACTOR_TYPE
                                when '3' then sb.ENTITY_NAME
                                when '4' then ag.ENTITY_NAME
                                else null
                            end
                        else null
                    end 
            end as assignedResponsibleName: String(100),
            // usn.USER_NAME            as assignedResponsibleName,
            ''                       as validator,
            ''                       as validatorName,
            bp.RESPONSIBLE_PERSON    as internalResponsible,
            bp.PROVIDER_NAME         as externalResponsible,
            rh.REQUEST_OWNER_ID      as manager,
            us.USER_NAME             as managerName,
            rp.PREFERRED_PROVIDER    as preferredProvider,
            pp.ENTITY_NAME           as preferredProviderName,
            rh.ASSIGNATION_DATE      as assignationDate,
        key 0                        as taskType,
            0                        as searchType,
        key ''                       as documentId,
            ''                       as documentType,
            ''                       as documentName,
            ''                       as documentValidation
    from REQUEST_HEAD as rh left outer join PROCESS as p on p.ID_PK = rh.PROCESS_ID
    inner join SITES as sit on sit.siteId = rh.SITE_ID
    left outer join US_USERS_IAS as us on us.USER_ID = rh.REQUEST_OWNER_ID
    inner join REQUEST_CHAR_PRO as rp on rp.REQUEST_ID = rh.REQUEST_ID 
                                     and (rh.REQUEST_TYPE = 40)
    left outer join SEARCH_BY_COMPLEXITIES as sc on sc.REQUEST_ID = rh.REQUEST_ID
    left outer join COMPLEXITIES as co on co.code = sc.COMPLEXITY and co.country = rh.COUNTRY_ID
    inner join PHASE_HEAD as ph on ph.REQUEST_ID = rh.REQUEST_ID
                                and ph.PHASE_STATUS != 2
    left outer join MASTER_PHASE as mp on  mp.PROCESS_ID_PK = p.PROCESS_ID_PK
                                       and mp.PHASE_ID_PK   = ph.MASTER_PHASE_ID
                                       and mp.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
    inner join WORKS as gt on gt.parentId = bh.BLOCK_ID and gt.parentType.ID = 30
    left outer join localized_BLOCK_STATUS as bs on bs.code = bh.BLOCK_STATUS
    left outer join STATUS_TEXTS as st on st.STATUS_CODE = gt.status and st.LANGUAGE = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join BLOCKS_PROVISIONING as bp on bp.BLOCK_ID = bh.BLOCK_ID
    left outer join US_USERS_IAS as usn on usn.USER_ID = bp.RESPONSIBLE_PERSON
    left outer join US_USERS_IAS as usw on usw.USER_ID = gt.internalResponsible
    left outer join CACHE_R3_ENTITIES as pp on pp.ENTITY_ID = rp.PREFERRED_PROVIDER
                                           and pp.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK'
                                           and pp.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as sb on sb.ENTITY_ID = bp.PROVIDER_NAME
                                           and sb.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK'
                                           and sb.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as ag on ag.ENTITY_ID = bp.PROVIDER_NAME
                                           and ag.ENTITY_TYPE = 'F4_GEWRK_AGEN'
                                           and ag.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as sbw on sbw.ENTITY_ID = gt.externalResponsible
                                            and sbw.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK'
                                            and sbw.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as agw on agw.ENTITY_ID = gt.externalResponsible
                                            and agw.ENTITY_TYPE = 'F4_GEWRK_AGEN'
                                            and agw.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join MASTER_BLOCK as mb on  mb.PROCESS_ID_PK = p.PROCESS_ID_PK
                                       and mb.PHASE_ID_PK   = mp.PHASE_ID_PK
                                       and mb.BLOCK_ID_PK   = bh.MASTER_BLOCK_ID
                                       and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'));
entity SEARCH_BY_DOCUMENTS                        as
    select
        key rh.REQUEST_ID               as ID : UUID,
            rh.REQUEST_CODE             as code,
            rh.REQUEST_STATUS           as requestStatus,
            rh.COUNTRY_ID               as country,
            rh.WORKFLOW_ID              as projectType,
            rp.PROJECT_OBJECTIVE        as projectObjective,
            dp.STATUS                   as status,
            dfs.name                    as statusName,
            sc.COMPLEXITY            as complexity,
            co.name                  as complexityName,
            rh.SITE_ID                  as siteId,
            sit.siteName,
            sit.region               as siteRegion,
            sit.city                 as siteCity,
            sit.cellnexZone          as cellnexZone,
            sit.legacyCode           as siteLegacyCode,
            // rh.CUSTOMER_REQUEST_ID      as customerRequestCode,
            // rp.MIGRATION_REQUEST_ID     as legacyRequestId,
            rp.REQUESTED_DATE        as requestedDate,
            rh.CREATEDAT             as createdAt,
        key ph.MASTER_PHASE_ID          as masterPhaseId @(title: '{i18n>phase}'),
            mp.PHASE_NAME               as phase         @(title: '{i18n>phaseName}'),
        key bh.MASTER_BLOCK_ID          as masterBlockID @(title: '{i18n>block}'),
            mb.BLOCK_NAME               as block         @(title: '{i18n>blockName}'),
        key ''                          as workId,
            ''                          as work,
            0                           as workType,
            ''                          as workTypeName,
            case 
	            when idp.STEP_ID = '0' then
                    case 
                        when dp.RESPONSIBLE_ID = '1' then 'TIS_Cellnex'
                        when dp.RESPONSIBLE_ID = '2' then
                            case 
                                when dp.SUBCONTRATOR_ID = '2' then 'TIS_WF_PRO_Customer'
                                when dp.SUBCONTRATOR_ID = '3' then 'TIS_WF_PRO_Subcontractor'
                                when dp.SUBCONTRATOR_ID = '4' then 'TIS_WF_PRO_Agency'
                                else 'TIS_WF_PRO_Subcontractor'
                            end
                    end
                when idp.STEP_ID = '10' then 
                    case
                        when dp.RESPONSIBLE_ID = '1' then 'TIS_Cellnex'
                        when dp.RESPONSIBLE_ID = '2' then
                            case 
                                when dp.SUBCONTRATOR_ID = '2' then 'TIS_WF_PRO_Customer'
                                when dp.SUBCONTRATOR_ID = '3' then 'TIS_WF_PRO_Subcontractor'
                                when dp.SUBCONTRATOR_ID = '4' then 'TIS_WF_PRO_Agency'
                                else 'TIS_WF_PRO_Subcontractor'
                            end
                    end
                when idp.STEP_ID = '20' then 'TIS_Cellnex'
                when idp.STEP_ID = '30' then 'TIS_WF_PRO_Subcontractor'
                when idp.STEP_ID = '40' then 'TIS_WF_PRO_Customer'
                else bh.ROLE_ID
            end as roleId:String(50),
            dp.T_RESPONSIBLE as assignedResponsible,
            case 
                when dp.RESPONSIBLE_ID = '1' then usdr.USER_NAME
                when dp.RESPONSIBLE_ID = '2' then
                    case 
                        when dp.SUBCONTRATOR_ID = '3' then drsc.ENTITY_NAME
                        when dp.SUBCONTRATOR_ID = '4' then drag.ENTITY_NAME
                        else null
                        // when dp.SUBCONTRATOR_ID = '2' then rh.CUSTOMER_NAME
                    end
            end as assignedResponsibleName: String(100),
            case 
                when idp.STEP_ID = '20' then idp.CELLNEX_VALIDATOR
                when idp.STEP_ID = '30' then idp.SUBCONTRACTOR_VALIDATOR
                when idp.STEP_ID = '40' then idp.CUSTOMER_VALIDATOR
                else dp.T_RESPONSIBLE
            end as validator: String(100),
            case 
                when idp.STEP_ID = '20' then uscv.USER_NAME
                when idp.STEP_ID = '30' then sv.ENTITY_NAME
                // when idp.STEP_ID = '40' then rh.CUSTOMER_NAME
                else usdr.USER_NAME
            end as validatorName: String(100),
            bp.RESPONSIBLE_PERSON       as internalResponsible,
            bp.PROVIDER_NAME            as externalResponsible,
            rh.REQUEST_OWNER_ID         as manager,
            uscm.USER_NAME              as managerName,
            rp.PREFERRED_PROVIDER       as preferredProvider,
            pp.ENTITY_NAME              as preferredProviderName,
            rh.ASSIGNATION_DATE         as assignationDate,
        key 1                           as taskType,
            0                           as searchType,
        key dp.REGISTER_ID              as documentId,
            dp.GENERIC_TYPE_ID          as documentType,
            df.documentName,
            case
                when idp.STEP_ID = '0' then 'Responsible document upload'
                when idp.STEP_ID = '20' then 'Cellnex validation'
                when idp.STEP_ID = '30' then 'Subcontractor validation'
                when idp.STEP_ID = '40' then 'On behalf of Customer validation'
            end                         as documentValidation: String(100)
    from REQUEST_HEAD as rh
    inner join SITES as sit on sit.siteId = rh.SITE_ID
    left outer join PROCESS as p on p.ID_PK = rh.PROCESS_ID
    inner join REQUEST_CHAR_PRO as rp on rp.REQUEST_ID = rh.REQUEST_ID
                                     and (rh.REQUEST_TYPE = 40)
    left outer join SEARCH_BY_COMPLEXITIES as sc on sc.REQUEST_ID = rh.REQUEST_ID
    left outer join COMPLEXITIES as co on co.code = sc.COMPLEXITY and co.country = rh.COUNTRY_ID
    inner join PHASE_HEAD as ph on ph.REQUEST_ID = rh.REQUEST_ID
    left outer join MASTER_PHASE as mp on  mp.PROCESS_ID_PK = p.PROCESS_ID_PK
                                       and mp.PHASE_ID_PK   = ph.MASTER_PHASE_ID
                                       and mp.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
    inner join BLOCKS_PROVISIONING as bp on bp.BLOCK_ID = bh.BLOCK_ID
    left outer join MASTER_BLOCK as mb on  mb.PROCESS_ID_PK = p.PROCESS_ID_PK
                                        and mb.PHASE_ID_PK   = mp.PHASE_ID_PK
                                        and mb.BLOCK_ID_PK   = bh.MASTER_BLOCK_ID
                                        and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join DOCUMENTS_PER_BLOCK as dp on dp.BLOCK_ID = bh.BLOCK_ID and (dp.WORK_ID is null or dp.WORK_ID = '')
    left outer join localized_DOCUMENT_FLOW_STATUS as dfs on dfs.code = dp.STATUS
    left outer join DOCUMENT_FLOWS as df on df.documentId = dp.GENERIC_TYPE_ID
    left outer join INSTANCES_PER_DOCUMENT as idp on idp.INSTANCE_ID = dp.REGISTER_ID
    left outer join US_USERS_IAS as uscm on uscm.USER_ID = rh.REQUEST_OWNER_ID
    left outer join CACHE_R3_ENTITIES as pp on pp.ENTITY_ID = rp.PREFERRED_PROVIDER
                                           and pp.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK'
                                           and pp.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as drsc on drsc.ENTITY_ID =  dp.T_RESPONSIBLE
                                           and ( drsc.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' )
                                           and drsc.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as drag on drag.ENTITY_ID =  dp.T_RESPONSIBLE
                                           and ( drag.ENTITY_TYPE = 'F4_GEWRK_AGEN' )
                                           and drag.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as sv on sv.ENTITY_ID =  idp.SUBCONTRACTOR_VALIDATOR
                                           and ( sv.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' or sv.ENTITY_TYPE = 'F4_GEWRK_AGEN' )
                                           and sv.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join US_USERS_IAS as usir on usir.USER_ID = bp.RESPONSIBLE_PERSON
    left outer join US_USERS_IAS as uscv on uscv.USER_ID = idp.CELLNEX_VALIDATOR
    left outer join US_USERS_IAS as usdr on usdr.USER_ID = dp.T_RESPONSIBLE;

entity SEARCH_BY_WORK_DOCUMENTS                      as
    select
        key rh.REQUEST_ID               as ID : UUID,
            rh.REQUEST_CODE             as code,
            rh.REQUEST_STATUS           as requestStatus,
            rh.COUNTRY_ID               as country,
            rh.WORKFLOW_ID              as projectType,
            rp.PROJECT_OBJECTIVE        as projectObjective,
            dp.STATUS                   as status,
            dfs.name                    as statusName,
            sc.COMPLEXITY               as complexity,
            co.name                     as complexityName,
            rh.SITE_ID                  as siteId,
            sit.siteName,
            sit.region                  as siteRegion,
            sit.city                    as siteCity,
            sit.cellnexZone             as cellnexZone,
            sit.legacyCode              as siteLegacyCode,
            // rh.CUSTOMER_REQUEST_ID      as customerRequestCode,
            // rp.MIGRATION_REQUEST_ID     as legacyRequestId,
            rp.REQUESTED_DATE           as requestedDate,
            rh.CREATEDAT                as createdAt,
        key ph.MASTER_PHASE_ID          as masterPhaseId @(title: '{i18n>phase}'),
            mp.PHASE_NAME               as phase         @(title: '{i18n>phaseName}'),
        key bh.MASTER_BLOCK_ID          as masterBlockID @(title: '{i18n>block}'),
            mb.BLOCK_NAME               as block         @(title: '{i18n>blockName}'),
        key gt.ID                       as workId,
            gt.description              as work,
            gt.type.ID                  as workType,
            gt.type.descr               as workTypeName,
            case 
	            when idp.STEP_ID = '0' then
                    case 
                        when dp.RESPONSIBLE_ID = '1' then 'TIS_Cellnex'
                        when dp.RESPONSIBLE_ID = '2' then
                            case 
                                when dp.SUBCONTRATOR_ID = '2' then 'TIS_WF_PRO_Customer'
                                when dp.SUBCONTRATOR_ID = '3' then 'TIS_WF_PRO_Subcontractor'
                                when dp.SUBCONTRATOR_ID = '4' then 'TIS_WF_PRO_Agency'
                                else 'TIS_WF_PRO_Subcontractor'
                            end
                    end
                when idp.STEP_ID = '10' then 
                    case
                        when dp.RESPONSIBLE_ID = '1' then 'TIS_Cellnex'
                        when dp.RESPONSIBLE_ID = '2' then
                            case 
                                when dp.SUBCONTRATOR_ID = '2' then 'TIS_WF_PRO_Customer'
                                when dp.SUBCONTRATOR_ID = '3' then 'TIS_WF_PRO_Subcontractor'
                                when dp.SUBCONTRATOR_ID = '4' then 'TIS_WF_PRO_Agency'
                                else 'TIS_WF_PRO_Subcontractor'
                            end
                    end
                when idp.STEP_ID = '20' then 'TIS_Cellnex'
                when idp.STEP_ID = '30' then 'TIS_WF_PRO_Subcontractor'
                when idp.STEP_ID = '40' then 'TIS_WF_PRO_Customer'
                else bh.ROLE_ID
            end as roleId:String(50),
            dp.T_RESPONSIBLE as assignedResponsible,
            case 
                when dp.RESPONSIBLE_ID = '1' then usdr.USER_NAME
                when dp.RESPONSIBLE_ID = '2' then
                    case 
                        when dp.SUBCONTRATOR_ID = '3' or dp.SUBCONTRATOR_ID = '4' then dr.ENTITY_NAME
                        // when dp.SUBCONTRATOR_ID = '2' then rh.CUSTOMER_NAME
                    end
            end as assignedResponsibleName: String(100),
            case 
                when idp.STEP_ID = '20' then idp.CELLNEX_VALIDATOR
                when idp.STEP_ID = '30' then idp.SUBCONTRACTOR_VALIDATOR
                when idp.STEP_ID = '40' then idp.CUSTOMER_VALIDATOR
                else dp.T_RESPONSIBLE
            end as validator: String(100),
            case 
                when idp.STEP_ID = '20' then uscv.USER_NAME
                when idp.STEP_ID = '30' then sv.ENTITY_NAME
                // when idp.STEP_ID = '40' then rh.CUSTOMER_NAME
                else usdr.USER_NAME
            end as validatorName: String(100),
            bp.RESPONSIBLE_PERSON       as internalResponsible,
            bp.PROVIDER_NAME            as externalResponsible,
            rh.REQUEST_OWNER_ID         as manager,
            uscm.USER_NAME              as managerName,
            rp.PREFERRED_PROVIDER       as preferredProvider,
            pp.ENTITY_NAME              as preferredProviderName,
            rh.ASSIGNATION_DATE         as assignationDate,
        key 1                           as taskType,
            0                           as searchType,
        key dp.REGISTER_ID              as documentId,
            dp.GENERIC_TYPE_ID          as documentType,
            df.documentName,
            case
                when idp.STEP_ID = '0' then 'Responsible document upload'
                when idp.STEP_ID = '20' then 'Cellnex validation'
                when idp.STEP_ID = '30' then 'Subcontractor validation'
                when idp.STEP_ID = '40' then 'On behalf of Customer validation'
            end                         as documentValidation: String(100)
    from REQUEST_HEAD as rh
    inner join SITES as sit on sit.siteId = rh.SITE_ID
    left outer join PROCESS as p on p.ID_PK = rh.PROCESS_ID
    inner join REQUEST_CHAR_PRO as rp on rp.REQUEST_ID = rh.REQUEST_ID
                                     and (rh.REQUEST_TYPE = 40)
    left outer join SEARCH_BY_COMPLEXITIES as sc on sc.REQUEST_ID = rh.REQUEST_ID
    left outer join COMPLEXITIES as co on co.code = sc.COMPLEXITY and co.country = rh.COUNTRY_ID
    inner join PHASE_HEAD as ph on ph.REQUEST_ID = rh.REQUEST_ID
    left outer join MASTER_PHASE as mp on  mp.PROCESS_ID_PK = p.PROCESS_ID_PK
                                       and mp.PHASE_ID_PK   = ph.MASTER_PHASE_ID
                                       and mp.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join BLOCK_HEAD as bh on bh.PHASE_ID = ph.PHASE_ID
    inner join WORKS as gt on gt.parentId = bh.BLOCK_ID and gt.parentType.ID = 30
    inner join BLOCKS_PROVISIONING as bp on bp.BLOCK_ID = bh.BLOCK_ID
    left outer join MASTER_BLOCK as mb on  mb.PROCESS_ID_PK = p.PROCESS_ID_PK
                                        and mb.PHASE_ID_PK   = mp.PHASE_ID_PK
                                        and mb.BLOCK_ID_PK   = bh.MASTER_BLOCK_ID
                                        and mb.LANGUAGE_PK   = UPPER(SESSION_CONTEXT('LOCALE'))
    inner join DOCUMENTS_PER_BLOCK as dp on dp.BLOCK_ID = gt.parentId and dp.WORK_ID = gt.ID
    left outer join localized_DOCUMENT_FLOW_STATUS as dfs on dfs.code = dp.STATUS
    left outer join DOCUMENT_FLOWS as df on df.documentId = dp.GENERIC_TYPE_ID
    left outer join INSTANCES_PER_DOCUMENT as idp on idp.INSTANCE_ID = dp.REGISTER_ID
    left outer join US_USERS_IAS as uscm on uscm.USER_ID = rh.REQUEST_OWNER_ID
    left outer join CACHE_R3_ENTITIES as pp on pp.ENTITY_ID = rp.PREFERRED_PROVIDER
                                           and pp.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK'
                                           and pp.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as dr on dr.ENTITY_ID =  dp.T_RESPONSIBLE
                                           and ( dr.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' or dr.ENTITY_TYPE = 'F4_GEWRK_AGEN' )
                                           and dr.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join CACHE_R3_ENTITIES as sv on dr.ENTITY_ID =  idp.SUBCONTRACTOR_VALIDATOR
                                           and ( dr.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' or dr.ENTITY_TYPE = 'F4_GEWRK_AGEN' )
                                           and dr.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
    left outer join US_USERS_IAS as usir on usir.USER_ID = bp.RESPONSIBLE_PERSON
    left outer join US_USERS_IAS as uscv on uscv.USER_ID = idp.CELLNEX_VALIDATOR
    left outer join US_USERS_IAS as usdr on usdr.USER_ID = dp.T_RESPONSIBLE;

entity SEARCH_BY_COMPLEXITIES as select
        rh.REQUEST_ID,
        bh.BLOCK_ID,
        bp.COMPLEXITY
    from REQUEST_HEAD as rh
    inner join PHASE_HEAD as ph on ph.REQUEST_ID = rh.REQUEST_ID
                                and rh.REQUEST_TYPE = 40
    inner join BLOCK_HEAD as bh on  bh.PHASE_ID = ph.PHASE_ID 
                                and bh.MASTER_BLOCK_ID = 'globalResult'
                                and ph.MASTER_PHASE_ID = 'siteSurvey' 
    inner join BLOCKS_PROVISIONING as bp on bp.BLOCK_ID = bh.BLOCK_ID;