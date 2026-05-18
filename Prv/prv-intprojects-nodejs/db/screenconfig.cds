using {cuid, managed } from '@sap/cds/common';
using { PROCESS, MASTER_PROCESS } from './processflow';

@cds.persistence.exists
entity SCREEN_CONTROLS: cuid, managed {
    description:            String(200)              @title: '{i18n>description}';
    priority:               Integer                  @title: '{i18n>priority}';
    IASGroup:               String(100)              @title: '{i18n>IASGroup}';
    defaultDisplay:         UInt8                    @title: '{i18n>defaultDisplayType}';  
    ScreenControlFields:    Composition of many SCREEN_CONTROL_FIELDS on ScreenControlFields.ScreenControl = $self;
    ScreenControlProcesses: Composition of many SCREEN_CONTROL_PROCESS on ScreenControlProcesses.ScreenControl = $self;
}

@cds.persistence.exists
entity SCREEN_CONTROL_PROCESS: cuid, managed {
    processId:              Integer64                     @title: '{i18n>processFlowId}';
    ScreenControl:          Association to SCREEN_CONTROLS;

}

@cds.persistence.exists
entity SCREEN_CONTROL_FIELDS: cuid, managed {
    tabName:                String(100)              @title: '{i18n>table}';
    phase:                  String(20)               @title: '{i18n>phase}';
    block:                  String(20)               @title: '{i18n>block}';
    fieldName:              String(100)              @title: '{i18n>fieldName}';
    displayType:            UInt8                    @title: '{i18n>displayType}';
    ScreenControl:          Association to SCREEN_CONTROLS;
}

@cds.persistence.exists 
entity SCREEN_CONTROL_IASGROUPS {
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
    key CODE: String(100)  @title: 'CODE' ; 
}

@cds.persistence.exists 
entity SCREEN_CONTROL_IASGROUPS_TEXTS {
    key LOCALE: String(14)  @title: 'LOCALE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
    key CODE: String(100)  @title: 'CODE' ; 
}

@cds.odata.valuelist
@UI.Identification: [{Value: name}] 
entity localized_SCREEN_CONTROL_IASGROUPS as select
    key main.CODE                        as code @(Common.Text: name),
        COALESCE(text.NAME, main.NAME)  as name: String
    from SCREEN_CONTROL_IASGROUPS as main 
    left outer join SCREEN_CONTROL_IASGROUPS_TEXTS as text on text.CODE = main.CODE
                                                          and text.LOCALE = SESSION_CONTEXT('LOCALE');

@cds.persistence.exists
entity SCREEN_CONTROL_DISPLAY_TYPES {
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
    key CODE: UInt8  @title: 'CODE' ; 
}

@cds.persistence.exists 
entity SCREEN_CONTROL_DISPLAY_TYPES_TEXTS {
    key LOCALE: String(14)  @title: 'LOCALE' ; 
        NAME: String(255)  @title: 'NAME' ; 
        DESCR: String(1000)  @title: 'DESCR' ; 
    key CODE: UInt8  @title: 'CODE' ; 
}

@cds.odata.valuelist
@UI.Identification: [{Value: name}] 
entity localized_SCREEN_CONTROL_DISPLAY_TYPES as select
    key main.CODE                       as code @(Common.Text: name),
        COALESCE(text.NAME, main.NAME)  as name: String
    from SCREEN_CONTROL_DISPLAY_TYPES as main 
    left outer join SCREEN_CONTROL_DISPLAY_TYPES_TEXTS as text on text.CODE = main.CODE
                                                              and text.LOCALE = SESSION_CONTEXT('LOCALE');


@cds.odata.valuelist
@UI.Identification: [{Value: processName}] 
entity localized_PROCESSES as select
    key p.ID_PK         as processId @(Common.Text: processName),
        mp.PROCESS_NAME as processName
    from PROCESS as p
    left outer join MASTER_PROCESS as mp on mp.PROCESS_ID_PK = p.PROCESS_ID_PK
                                        and ( mp.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))
                                         or mp.LANGUAGE_PK   = SESSION_CONTEXT('LOCALE'));

entity SCREEN_CONTROL_BY_PROCESS as select
    key sc.ID,
    key scp.processId,
        sc.priority,
        sc.IASGroup,
        sc.defaultDisplay
    from SCREEN_CONTROLS as sc 
    inner join SCREEN_CONTROL_PROCESS as scp on scp.ScreenControl.ID = sc.ID;

entity SCREEN_CONTROL_LIST as select
    key sc.ID,
        sc.defaultDisplay,
        scf.tabName,
        scf.phase,
        scf.block,
        scf.fieldName,
        scf.displayType as code
    from SCREEN_CONTROLS as sc 
    inner join SCREEN_CONTROL_FIELDS  as scf on scf.ScreenControl.ID = sc.ID;

entity SCREEN_CONFIG_DATA as select 
  scp.processId, sc.IASGroup, scf.tabName, scf.phase, scf.block, scf.fieldName, sc.priority, scf.displayType
  from SCREEN_CONTROLS as sc
  inner join SCREEN_CONTROL_PROCESS as scp on scp.ScreenControl.ID = sc.ID 
  inner join SCREEN_CONTROL_FIELDS as scf on scf.ScreenControl.ID = sc.ID;