namespace Checklist;
using { cuid, managed, sap.common.CodeList, User } from '@sap/cds/common';
using { BLOCK_HEAD } from './cellnex';

@cds.persistence.exists
entity Item : cuid, managed {
    description             : String(255)                     @title : '{i18n>description}';
    deleted                 : Boolean; 
    deletedAt               : Timestamp;
    deletedBy               : User;
    type                    : Association to one ItemType     @title : '{i18n>type}';
    mandatory               : Boolean;
    booleanValue            : Boolean                         @title : '{i18n>booleanValue}';
    stringValue             : String(2000)                    @title : '{i18n>stringValue}';
    dateValue               : Timestamp                       @title : '{i18n>dateValue}';
    integerValue            : Integer                         @title : '{i18n>integerValue}';
    decimalValue            : Decimal(15,2)                   @title : '{i18n>decimalValue}';
    pickList                : Integer                         @title : '{i18n>pickList}';
    block_ID                : UUID;
    block                   : Association to one BLOCK_HEAD on block.BLOCK_ID = block_ID;
    virtual descriptionFC   : UInt8; 
    virtual booleanValueFC  : UInt8;
    virtual stringValueFC   : UInt8;
    virtual dateValueFC     : UInt8;
    virtual integerValueFC  : UInt8;
    virtual decimalValueFC  : UInt8;
    virtual pickListFC      : UInt8;
    virtual picklistValueName: String(255);
    virtual rowStatus       : String(10);
    virtual refreshEntity   : String(30);
    virtual editable        : Boolean;
    virtual order           : Integer;  
}

@cds.persistence.exists
@odata.draft.enabled 
entity FieldType: CodeList {
    key ID              : Integer           @title : '{i18n>fieldTypeID}';
    translations: Composition of many FieldType.texts on translations.ID = ID;
}

@cds.persistence.exists
entity FieldType.texts {
    key locale              : String(14);
        name                : String(255);
        descr               : String(1000);
    key ID                  : Integer           @title : '{i18n>fieldTypeID}';
        parent              : association to one FieldType on parent.ID = ID;
}

@cds.persistence.exists
@odata.draft.enabled
@cds.autoexpose
entity ItemType: managed {
    key ID              : Integer           @title : '{i18n>itemTypeID}';
        description     : localized String(255);
        active          : Boolean           @title : '{i18n>active}';
        valueType       : Association to one FieldType;
        defaultBoolean  : Boolean           @title : '{i18n>defaultBooleanValue}';
        defaultString   : String(1000)      @title : '{i18n>defaultStringValue}';
        defaultDate     : Date              @title : '{i18n>defaultDateValue}';
        defaultInteger  : Integer           @title : '{i18n>defaultIntegerValue}';
        defaultDecimal  : Decimal(15,2)     @title : '{i18n>defaultDecimalValue}';
        defaultPickList : Integer           @title : '{i18n>defaultPickListValue}';
        values          : Composition of many ItemTypeValue on values.itemType = $self;
        translations    : Composition of many ItemType.texts on translations.ID = ID;
}
extend ItemType with {
    localized: Association to one ItemType.texts on localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE')
}

@cds.persistence.exists
@cds.autoexpose
entity ItemType.texts {
    key locale              : String(14);
    key ID                  : Integer           @title : '{i18n>fieldTypeID}';
        description         : String(255);
        parent              : association to one ItemType on parent.ID = ID;
}

@cds.persistence.exists
@cds.autoexpose
entity ItemTypeValue : cuid, managed {
        description     : localized String(255) @title : '{i18n>description}';
        active          : Boolean               @title : '{i18n>active}';
        booleanValue    : Boolean               @title : '{i18n>booleanValue}';
        stringValue     : String(1000)          @title : '{i18n>stringValue}';
        dateValue       : Timestamp             @title : '{i18n>dateValue}';
        integerValue    : Integer               @title : '{i18n>integerValue}';
        decimalValue    : Decimal(15,2)         @title : '{i18n>decimalValue}';
        pickList        : Integer               @title : '{i18n>pickList}';
        itemType        : Association to ItemType;
        translations    : Composition of many ItemTypeValue.texts on translations.ID = ID;
}
extend ItemTypeValue with {
    localized: Association to one ItemTypeValue.texts on localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE')
}

@cds.persistence.exists
@cds.autoexpose
entity ItemTypeValue.texts {
    key locale              : String(14);
    key ID                  : UUID              @title : '{i18n>fieldTypeID}';
        description         : String(255);
        parent              : association to one ItemTypeValue on parent.ID = ID;
}

@cds.persistence.exists
@odata.draft.enabled 
entity ItemConfiguration : cuid, managed {
    description     : String(255)               @title : '{i18n>description}';
    active          : Boolean default true      @title : '{i18n>active}';
    deletedAt       : Timestamp                 @title : '{i18n>deletedAt}';
    deletedBy       : String(100)               @title : '{i18n>deletedBy}';
    types           : Composition of many ItemConfigurationType on types.configuration = $self;
    processes       : Composition of many ItemConfigurationProcess on processes.configuration = $self;
    blocks          : Composition of many ItemConfigurationBlock on blocks.configuration = $self;
}   

@cds.persistence.exists
entity ItemConfigurationType: cuid, managed {
    defaulted       : Boolean                   @title : '{i18n>defaulted}';
    mandatory       : Boolean                   @title : '{i18n>mandatory}';
    defaultBoolean  : Boolean                   @title : '{i18n>defaultBooleanValue}';
    defaultString   : String(1000)              @title : '{i18n>defaultStringValue}';
    defaultDate     : Date                      @title : '{i18n>defaultDateValue}';
    defaultInteger  : Integer                   @title : '{i18n>defaultIntegerValue}';
    defaultDecimal  : Decimal(15,2)             @title : '{i18n>defaultDecimalValue}';
    defaultPickList : Integer                   @title : '{i18n>defaultPickListValue}';
    beforeCreate    : String(100)               @title : '{i18n>beforeCreate}';
    afterUpdate     : String(100)               @title : '{i18n>afterUpdate}';
    afterRead       : String(100)               @title : '{i18n>afterRead}';
    refreshEntity   : String(30)                @title : '{i18n>refreshEntity}';
    order           : Integer;
    type            : Association to ItemType;
    configuration   : Association to ItemConfiguration;
}

@cds.persistence.exists
entity ItemConfigurationProcess: cuid, managed {
    processId      : Integer                    @title : '{i18n>processId}';
    configuration  : Association to ItemConfiguration;
}

@cds.persistence.exists
entity ItemConfigurationBlock:cuid, managed {
    phaseType      : String(50)                 @title : '{i18n>phaseType}';
    blockType      : String(50)                 @title : '{i18n>blockType}';
    configuration  : Association to ItemConfiguration;
}

entity ItemTypesPerBlock as select 
    key cp.configuration.ID,
    key cp.processId,
    key cb.phaseType,
    key cb.blockType,
    key ct.type.ID as type,
        ic.active,
        it.active as activeType,
        ct.defaulted,
        ct.mandatory,
        ct.beforeCreate,
        ct.afterUpdate,
        ct.afterRead,
        ct.refreshEntity,
        ct.order,
        ct.defaultBoolean,
        ct.defaultString,
        ct.defaultDate,
        ct.defaultInteger,
        ct.defaultDecimal,
        ct.defaultPickList
        from ItemConfigurationBlock as cb
        inner join ItemConfigurationProcess as cp on cp.configuration.ID = cb.configuration.ID
        inner join ItemConfigurationType as ct on ct.configuration.ID = cb.configuration.ID
        inner join ItemType as it on it.ID = ct.type.ID
        inner join ItemConfiguration as ic on ic.ID = cp.configuration.ID
    order by ct.order;

entity localized_ItemTypeValue as select
    key L_0.pickList, 
    key L_0.itemType.ID as itemType_ID,
    coalesce(localized_1.description, L_0.description) as description:String(255),
    active
from (Checklist.ItemTypeValue as L_0 left join Checklist.ItemTypeValue.texts as localized_1 on localized_1.ID = L_0.ID and localized_1.locale = SESSION_CONTEXT('LOCALE'));

entity localized_ItemType as select
  key L_0.ID,
  coalesce(localized_1.description, L_0.description) as description:String(255),
  active
from (Checklist.ItemType as L_0 left join Checklist.ItemType.texts as localized_1 on localized_1.ID = L_0.ID and localized_1.locale = SESSION_CONTEXT('LOCALE'));

