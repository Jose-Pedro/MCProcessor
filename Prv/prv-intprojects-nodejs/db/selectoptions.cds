using { sap.common.CodeList as CodeList } from '@sap/cds/common';
using { SC_SELECT_OPTIONS_V2, SC_SELECT_OPTIONS_V3_MASTER, SC_SELECT_OPTIONS_V3_CONFIGURATION, SC_SELECT_OPTIONS_V3_TRANSLATE } from './cellnex';
using { US_COUNTRIES } from './userinfo';

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity CANCELLATION_REASONS                     as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case when sot.SELECT_OPTION is null or sot.SELECT_OPTION =  '' then som.SELECT_OPTION
                else sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'int'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'cancellationReasons'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = UPPER(SESSION_CONTEXT('LOCALE'));

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity ON_HOLD_REASONS                          as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case when sot.SELECT_OPTION    is null or sot.SELECT_OPTION =  '' then som.SELECT_OPTION
                else sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'int'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'reasonOnHold'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = UPPER(SESSION_CONTEXT('LOCALE'));

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity CLASSIFICATIONS                          as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'classification'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity COMPLEXITIES                          as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'int'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'intcomplexity'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = UPPER(SESSION_CONTEXT('LOCALE'));

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity APPROVER_TYPES                             as
    select
        key som.SELECT_OPTION_ID as code : String @(Common.Text: name),
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'approverType'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity SUBCO_TYPES                                as
    select
        key som.SELECT_OPTION_ID as code @(Common.Text: name),
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'subcoType'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity YES_NO_FIELDS                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'yesno'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

entity VALIDATIONS_DOCS                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'documentValidation'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity FEASIBILITIES                                as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'feasibilities'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity FEASIBILITIES_WITH_RISKS                     as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'feasibilitiesWithRisk'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity RISKS                                        as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'feasibilityRisk'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity ADAPTIONS_NEEDED_FIELDS                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'adaptionsNeeded'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          =  UPPER(SESSION_CONTEXT('LOCALE'));

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity ACCEPTED_REJECTED                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'acceptedPrv'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity AUTOMATIC_FIELDS                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'automaticManual'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity REJECTION_REASONS                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'bts'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'rejectionReason'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = SESSION_CONTEXT('LOCALE');

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity MAD_RESULTS                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'newCo'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'MAD_Result'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = UPPER(SESSION_CONTEXT('LOCALE'));

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity ADAPTIONS_TYPES                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'newCo'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'adaptationsType'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = UPPER(SESSION_CONTEXT('LOCALE'));

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity REPAYMENT_STATUS                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'int'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'repaymentStatus'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = UPPER(SESSION_CONTEXT('LOCALE'));


@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity MOA_OPERATION_TYPES                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'newCo'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'moaOperation'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = UPPER(SESSION_CONTEXT('LOCALE'));

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity CONTRACT_RESTRICTIONS_OPTIONS as
    select distinct
        key so.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when so.SELECT_OPTION is null
                     or so.SELECT_OPTION = ''
                     then so.SELECT_OPTION
                else so.SELECT_OPTION
            end                 as name : String
    from SC_SELECT_OPTIONS_V2 as so
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = so.COUNTRY_ID
    where so.ACTIVE          =      true
      and LOWER(so.LANGUAGE) =      LOWER(SESSION_CONTEXT('LOCALE'))
      and so.FIELD_ID        =      'contractRestrictions'
      and so.SELECT_OPTION   is not null;

entity FEASIBILITY_EXPLANATION_OPTIONS                  as
    select
        key som.SELECT_OPTION_ID as code : Integer @Common.Text: name,
            case
                when
                    sot.SELECT_OPTION    is null
                    or sot.SELECT_OPTION =  ''
                then
                    som.SELECT_OPTION
                else
                    sot.SELECT_OPTION
            end                  as name : String,
            soc.COUNTRY_ID as country
    from SC_SELECT_OPTIONS_V3_CONFIGURATION as soc
    inner join US_COUNTRIES as co on co.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')
                                 and co.COUNTRY_ID = soc.COUNTRY_ID
    inner join SC_SELECT_OPTIONS_V3_MASTER as som
        on  som.SELECT_OPTION_ID = soc.SELECT_OPTION_ID
        and som.FIELD_ID         = soc.FIELD_ID
        and soc.PROCESS_ID_PK    = 'newCo'
        and soc.ACTIVE           = true
        and soc.FIELD_ID         = 'feasibilExplanation'
    left outer join SC_SELECT_OPTIONS_V3_TRANSLATE as sot
        on  sot.SELECT_OPTION_ID = som.SELECT_OPTION_ID
        and sot.FIELD_ID         = som.FIELD_ID
        and LANGUAGE_ID          = UPPER(SESSION_CONTEXT('LOCALE'));

@cds.odata.valuelist
@UI.Identification: [{Value: name}]
entity BOOLEAN_VALUES: CodeList {
    key code : Boolean @Common.Text: name
}