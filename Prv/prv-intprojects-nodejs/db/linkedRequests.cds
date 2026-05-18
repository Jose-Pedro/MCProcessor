using {
    DT_LINKED_REQUEST
} from './cellnex';

using {
    REQUEST_HEAD,
    STATUS_HEAD,
    REQUEST_TYPE,
    US_USERS_IAS,
    US_COUNTRIES
} from './common';

entity SearchDtLinkedRequest as select from DT_LINKED_REQUEST as dtl
    inner join REQUEST_HEAD as rh on dtl.CHILD_REQUEST_ID = rh.REQUEST_CODE
    inner join STATUS_HEAD as rs on rs.STATUS_CODE = rh.REQUEST_STATUS
    inner join REQUEST_TYPE as rt on rt.REQUEST_TYPE = rh.REQUEST_TYPE
{
    key rh.REQUEST_ID          as requestID,
        rh.REQUEST_STATUS      as status          @(title: '{i18n>status}'),
        rs.STATUS_TEXT         as statusName      @(title: '{i18n>status}'),
        rh.SITE_ID             as siteID          @(title: '{i18n>siteId}'),
        rh.REQUEST_TYPE        as requestType     @(title: '{i18n>requestType}'),
        rt.REQUEST_TYPE_DESC   as requestTypeName @(title: '{i18n>requestType}'),
        dtl.CHILD_REQUEST_ID   as childRequestID  @(title: '{i18n>code}'),
        dtl.PARENT_INSTANCE_ID as parentInstanceID,
        dtl.ASSOCIATION_TYPE   as associationType,
        dtl.DELETED            as deleted,
        dtl.CHILD_INSTANCE_ID  as childInstanceID,
        dtl.LINK_ID            as linkID,
        
        case rh.REQUEST_STATUS
            when '2' then 2
            when '4' then 1
            when '7' then 2
            when '3' then 3
            else 2
        end as statusCritical : Integer
}
where dtl.DELETED = false or dtl.DELETED is NULL;

entity DtLinkedRequestPossibleChildrenRequest     as
    select from REQUEST_HEAD as rh
    inner join STATUS_HEAD as rs
        on rs.STATUS_CODE = rh.REQUEST_STATUS
    inner join REQUEST_TYPE as rt
        on rt.REQUEST_TYPE = rh.REQUEST_TYPE
    left join US_USERS_IAS as US
        on US.USER_ID = $user.id
    left join US_COUNTRIES as UC
        on UC.USER_ID = US.USER_ID

    {
        key REQUEST_ID           as requestID,
            rh.REQUEST_STATUS    as status          @(title: '{i18n>status}'),
            rs.STATUS_TEXT       as statusName      @(title: '{i18n>status}'),
            REQUEST_CODE         as requestCode     @(title: '{i18n>code}'),
            rh.REQUEST_TYPE      as requestType     @(title: '{i18n>requestType}'),
            rt.REQUEST_TYPE_DESC as requestTypeName @(title: '{i18n>requestType}'),
            SITE_ID              as siteID          @(title: '{i18n>siteId}'),
            PROCESS_ID           as processFlowID   @(title: '{i18n>processFlowId}'),
            virtual null         as parentInstanceID : UUID,
            cast(
                case
                    when
                        rh.REQUEST_STATUS = '2'
                    then
                        0
                    when
                        rh.REQUEST_STATUS = '4'
                    then
                        1
                    when
                        rh.REQUEST_STATUS = '7'
                    then
                        2
                    when
                        rh.REQUEST_STATUS = '3'
                    then
                        3
                    else
                        0
                end as                                 Integer
            )                    as statusCritical
    }
    where
        rh.COUNTRY_ID = UC.COUNTRY_ID;