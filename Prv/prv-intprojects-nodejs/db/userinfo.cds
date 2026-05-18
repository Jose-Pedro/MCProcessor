@cds.persistence.exists
entity ![US_USERS_IAS] {
    key ![USER_ID]     : String(15)           @title: 'USER_ID';
        ![USER_NAME]   : String(100) not null @title: 'USER_NAME';
        ![EMAIL]       : String(200)          @title: 'EMAIL';
        ![TELEPHONE]   : String(100)          @title: 'TELEPHONE';
        ![NEDAP]       : String(10)           @title: 'NEDAP';
        ![ILOQ]        : String(50)           @title: 'ILOQ';
        ![CARD_NUMBER] : String(8)            @title: 'CARD_NUMBER';
}

@cds.persistence.exists
entity ![US_ROLES_AGR] {
    key ![USER_ID]   : String(15) @title: 'USER_ID';
    key ![IAS_GROUP] : String(50) @title: 'IAS_GROUP';
}

@cds.persistence.exists
entity ![US_BUKS] {
    key ![USER_ID] : String(15) @title: 'USER_ID';
    key ![BUK]     : String(5)  @title: 'BUK: Company Code';
}

@cds.persistence.exists
entity ![US_COUNTRIES] {
    key ![USER_ID]    : String(15) @title: 'USER_ID';
    key ![COUNTRY_ID] : String(2)  @title: 'COUNTRY_ID';
}

@cds.persistence.exists
entity ![US_ZAGENCY] {
    key ![USER_ID]             : String(15)  @title: 'USER_ID';
    key ![ZAGENCY_ID]          : String(25)  @title: 'ZAGENCY_ID';
        ![ZAGENCY_DESCRIPTION] : String(200) @title: 'ZAGENCY_DESCRIPTION';
}

@cds.persistence.exists
entity ![US_ZCUSTOMER] {
    key ![USER_ID]               : String(15)  @title: 'USER_ID';
    key ![ZCUSTOMER_ID]          : String(25)  @title: 'ZCUSTOMER_ID';
        ![ZCUSTOMER_DESCRIPTION] : String(200) @title: 'ZCUSTOMER_DESCRIPTION';
}

@cds.persistence.exists
entity ![US_ZVENDOR] {
    key ![USER_ID]             : String(15)  @title: 'USER_ID';
    key ![ZVENDOR_ID]          : String(25)  @title: 'ZVENDOR_ID';
        ![ZVENDOR_DESCRIPTION] : String(200) @title: 'ZVENDOR_DESCRIPTION';
}

entity MANAGERS                                   as
    select distinct 
        key ias.USER_ID    as userId   @(title: '{i18n>userId}'),
        key lnd.COUNTRY_ID as country  @(title: '{i18n>country}'),
            ias.USER_NAME  as userName @(title: '{i18n>userName}')
    from US_USERS_IAS as ias
    inner join US_ROLES_AGR as agr on agr.USER_ID = ias.USER_ID
                                  and (agr.IAS_GROUP = 'TIS_WF_PRO_ColocationMgr' or agr.IAS_GROUP = 'TIS_WF_PRO_SuppColoMng')
    inner join US_COUNTRIES as lnd on lnd.USER_ID = ias.USER_ID ;

entity PMO_MANAGERS                               as
    select distinct
        key ias.USER_ID    as userId   @(title: '{i18n>userId}'),
        key lnd.COUNTRY_ID as country  @(title: '{i18n>country}'),
            ias.USER_NAME  as userName @(title: '{i18n>userName}')
    from US_USERS_IAS as ias
    inner join US_ROLES_AGR as agr on agr.USER_ID = ias.USER_ID
        and (agr.IAS_GROUP = 'TIS_WF_PRO_PMOMgr')
    inner join US_COUNTRIES as lnd on lnd.USER_ID = ias.USER_ID ;

entity REQUESTERS                                 as
    select distinct
        key ias.USER_ID    as userId   @(title: '{i18n>userId}'),
        key lnd.COUNTRY_ID as country  @(title: '{i18n>country}'),
            ias.USER_NAME  as userName @(title: '{i18n>userName}')
    from US_USERS_IAS as ias
    inner join US_ROLES_AGR as agr on agr.USER_ID = ias.USER_ID
        and (agr.IAS_GROUP = 'TIS_WF_PRO_ColocationMgr' or agr.IAS_GROUP = 'TIS_WF_PRO_Requester')
    inner join US_COUNTRIES as lnd on lnd.USER_ID = ias.USER_ID  ;
