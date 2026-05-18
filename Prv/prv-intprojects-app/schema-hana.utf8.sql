
CREATE TABLE project_BlocksResponsibles (
  ID NVARCHAR(36) NOT NULL,
  requestId NVARCHAR(36),
  requestProcessFlowId NVARCHAR(20),
  ProcessFlowType NVARCHAR(15),
  phaseProcessFlowId NVARCHAR(36),
  phaseName NVARCHAR(100),
  blockProcessFlowId NVARCHAR(36),
  blockName NVARCHAR(100),
  approverType NVARCHAR(5000),
  approverTypeFC TINYINT,
  approverName NVARCHAR(200),
  subcoType INTEGER,
  subcoTypeFC TINYINT,
  subcoName NVARCHAR(200),
  externalResponsible NVARCHAR(100),
  externalResponsibleName NVARCHAR(200),
  externalResponsibleFC TINYINT,
  internalResponsible NVARCHAR(100),
  internalResponsibleName NVARCHAR(200),
  internalResponsibleFC TINYINT,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = approverType),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcoType)
);

CREATE TABLE project_ImpactedCustomers (
  requestId NVARCHAR(36) NOT NULL,
  siteId NVARCHAR(30) NOT NULL,
  customerId NVARCHAR(10) NOT NULL,
  siteName NVARCHAR(60),
  customerName NVARCHAR(100),
  alias NVARCHAR(80),
  aliasName NVARCHAR(80),
  aliasServ NVARCHAR(120),
  aliasOther NVARCHAR(120),
  aliasClientArea NVARCHAR(30),
  aliasKey NVARCHAR(1),
  impacted BOOLEAN,
  impactedFC TINYINT,
  PRIMARY KEY(requestId, siteId, customerId)
);

CREATE TABLE project_DocumentFlowDocumentId (
  documentId NVARCHAR(10) NOT NULL,
  documentName NVARCHAR(100),
  ID NVARCHAR(36),
  PRIMARY KEY(documentId)
);

CREATE TABLE project_InternalUsers (
  userId NVARCHAR(5000) NOT NULL,
  userName NVARCHAR(5000),
  email NVARCHAR(5000),
  telephone NVARCHAR(5000),
  country NVARCHAR(5000),
  iasGroup NVARCHAR(5000),
  requestId NVARCHAR(5000),
  blockId NVARCHAR(5000),
  PRIMARY KEY(userId)
);

CREATE TABLE project_ExternalUsers (
  code NVARCHAR(10) NOT NULL,
  name NVARCHAR(100),
  blockId NVARCHAR(36),
  objectType NVARCHAR(5),
  PRIMARY KEY(code)
);

CREATE TABLE project_ServicesECC (
  Zzidintern NVARCHAR(5000) NOT NULL,
  Idrequest NVARCHAR(5000),
  Zzclass NVARCHAR(5000),
  Zzclasstxt NVARCHAR(5000),
  Zzservid NVARCHAR(5000),
  ZzserviceCatalog NVARCHAR(5000),
  ZzservcatDesc NVARCHAR(5000),
  ZzopStatus NVARCHAR(5000),
  ZzopStatusDesc NVARCHAR(5000),
  ZzinvStatus NVARCHAR(5000),
  InvstDesc NVARCHAR(5000),
  Zzbusinessprtnr NVARCHAR(5000),
  ZzbpDesc NVARCHAR(5000),
  Zzstartdate DATE,
  Zzenddate DATE,
  Zzcontractnumber NVARCHAR(5000),
  Zzlegacy NVARCHAR(5000),
  Zzsellerdesc NVARCHAR(5000),
  Zzseller NVARCHAR(5000),
  Agreement NVARCHAR(5000),
  zcompliance BOOLEAN,
  PRIMARY KEY(Zzidintern)
);

CREATE TABLE project_AfterCreateExits (
  ID NVARCHAR(100) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE project_AfterReadExits (
  ID NVARCHAR(100) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE project_AfterUpdateExits (
  ID NVARCHAR(100) NOT NULL,
  PRIMARY KEY(ID)
);

CREATE TABLE project_DocumentFlowResponsibles (
  code NVARCHAR(10) NOT NULL,
  name NVARCHAR(100),
  ID NVARCHAR(36),
  PRIMARY KEY(code)
);

CREATE TABLE project_DocumentFlowResponsiblesDefaultValid (
  code NVARCHAR(10) NOT NULL,
  name NVARCHAR(100),
  ID NVARCHAR(36),
  PRIMARY KEY(code)
);

CREATE TABLE project_DocumentFlowDefaultValidDocumentId (
  documentId NVARCHAR(10) NOT NULL,
  documentName NVARCHAR(100),
  ID NVARCHAR(36),
  PRIMARY KEY(documentId)
);

CREATE TABLE sap_common_Currencies (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(3) NOT NULL,
  symbol NVARCHAR(5),
  minorUnit SMALLINT,
  PRIMARY KEY(code)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN sap_common_Currencies_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN sap_common_Currencies_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE TABLE TASK_TYPES (
  CODE INTEGER NOT NULL,
  NAME NVARCHAR(255),
  DESCR NVARCHAR(1000),
  PRIMARY KEY(CODE)
);

CREATE TABLE TASK_TYPES_TEXTS (
  CODE INTEGER NOT NULL,
  LOCALE NVARCHAR(14) NOT NULL,
  NAME NVARCHAR(255),
  DESCR NVARCHAR(1000),
  PRIMARY KEY(CODE, LOCALE)
);

CREATE TABLE CACHE_R3_ENTITIES (
  USER_ID NVARCHAR(100) NOT NULL,
  ENTITY_TYPE NVARCHAR(50) NOT NULL,
  ENTITY_ID NVARCHAR(50) NOT NULL,
  ENTITY_NAME NVARCHAR(120),
  CREATED_AT TIMESTAMP,
  PRIMARY KEY(USER_ID, ENTITY_TYPE, ENTITY_ID)
);

CREATE TABLE REQUEST_IMPACTED_CUSTOMERS (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP,
  createdBy NVARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy NVARCHAR(255),
  requestId NVARCHAR(36),
  customer NVARCHAR(10),
  deleted BOOLEAN,
  deletedAt TIMESTAMP,
  deletedBy NVARCHAR(255),
  PRIMARY KEY(ID)
);

CREATE TABLE BOOLEAN_VALUES (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code BOOLEAN NOT NULL,
  PRIMARY KEY(code)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN BOOLEAN_VALUES_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN BOOLEAN_VALUES_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE TABLE ECC_LANGUAGES (
  SPRAS NVARCHAR(2) NOT NULL,
  LASPEZ NVARCHAR(1),
  LAHQ NVARCHAR(1),
  LAISO NVARCHAR(2),
  PRIMARY KEY(SPRAS)
);

CREATE TABLE PROJECT_TYPES (
  code NVARCHAR(10) NOT NULL,
  country NVARCHAR(2) NOT NULL,
  name NVARCHAR(100),
  PRIMARY KEY(code, country)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN PROJECT_TYPES_texts AS texts ON (texts.code = code AND texts.country = country),
  MANY TO ONE JOIN PROJECT_TYPES_texts AS localized ON (localized.code = code AND localized.country = country AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE TABLE PROCESS_TYPES (
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL,
  PRIMARY KEY(code)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN PROCESS_TYPES_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN PROCESS_TYPES_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE TABLE WF_DETAIL_DOCUMENTS_LOCAL (
  REGISTER_ID NVARCHAR(36) NOT NULL,
  BLOCK_ID NVARCHAR(36),
  INSTANCE_ID NVARCHAR(36),
  REQUEST_ID NVARCHAR(36),
  REQUEST_CODE NVARCHAR(100) NOT NULL,
  TYPE_ID NVARCHAR(50) NOT NULL,
  STEP_ID NVARCHAR(50) NOT NULL,
  FIELD NVARCHAR(50),
  DOCUMENT_NAME NVARCHAR(1000),
  DOCUMENT_VERSION NVARCHAR(10),
  DOCUMENT_URL NVARCHAR(250),
  USER_DOC NVARCHAR(250),
  CREATION_DATE_DOC NVARCHAR(50),
  DOCUMENT_SUBTYPE NVARCHAR(100),
  DOCUMENT_SUBTYPE_LVL2 NVARCHAR(500),
  CREATEDAT TIMESTAMP,
  CREATEDBY NVARCHAR(100),
  DELETED BOOLEAN,
  DELETED_AT TIMESTAMP,
  DELETED_BY NVARCHAR(100),
  MODIFIEDAT TIMESTAMP,
  MODIFIEDBY NVARCHAR(100),
  DOCUMENT_ID NVARCHAR(50),
  OT_DOCUMENT_ID INTEGER,
  BLOCK_NAME NVARCHAR(30),
  PHASE_NAME NVARCHAR(30),
  FINAL_DOCUMENT BOOLEAN,
  MEDIA_TYPE NVARCHAR(100) DEFAULT 'text/plain',
  WORK_ID NVARCHAR(5000),
  PRIMARY KEY(REGISTER_ID)
);

CREATE TABLE DOCUMENT_VIEWER_NODES (
  NODE_ID NVARCHAR(5000) NOT NULL,
  HIERARCHY_LEVEL INTEGER,
  PARENT_NODE_ID NVARCHAR(5000),
  DRILL_STATE NVARCHAR(5000),
  DESCRIPTION NVARCHAR(5000),
  DOCUMENT_ID NVARCHAR(5000),
  CREATED_BY NVARCHAR(50),
  CREATED_AT TIMESTAMP,
  REQUEST_ID NVARCHAR(36),
  PRIMARY KEY(NODE_ID)
);

CREATE TABLE sap_common_Currencies_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(3) NOT NULL,
  PRIMARY KEY(locale, code)
);

CREATE TABLE BOOLEAN_VALUES_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code BOOLEAN NOT NULL,
  PRIMARY KEY(locale, code)
);

CREATE TABLE PROJECT_TYPES_texts (
  locale NVARCHAR(14) NOT NULL,
  code NVARCHAR(10) NOT NULL,
  country NVARCHAR(2) NOT NULL,
  name NVARCHAR(100),
  PRIMARY KEY(locale, code, country)
);

CREATE TABLE PROCESS_TYPES_texts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255),
  descr NVARCHAR(1000),
  code NVARCHAR(5000) NOT NULL,
  PRIMARY KEY(locale, code)
);

CREATE TABLE DRAFT_DraftAdministrativeData (
  DraftUUID NVARCHAR(36) NOT NULL,
  CreationDateTime TIMESTAMP,
  CreatedByUser NVARCHAR(256),
  DraftIsCreatedByMe BOOLEAN,
  LastChangeDateTime TIMESTAMP,
  LastChangedByUser NVARCHAR(256),
  InProcessByUser NVARCHAR(256),
  DraftIsProcessedByMe BOOLEAN,
  PRIMARY KEY(DraftUUID)
);

CREATE TABLE checklistconfiguration_FieldTypes_drafts (
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN checklistconfiguration_FieldTypeTexts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_FieldTypeTexts_drafts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(locale, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_FieldTypes_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_ItemTypes_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  ID INTEGER NOT NULL,
  description NVARCHAR(255) NULL,
  active BOOLEAN NULL,
  valueType_ID INTEGER NULL,
  defaultBoolean BOOLEAN NULL,
  defaultString NVARCHAR(1000) NULL,
  defaultDate DATE NULL,
  defaultInteger INTEGER NULL,
  defaultDecimal DECIMAL(15, 2) NULL,
  defaultPickList INTEGER NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_FieldTypes AS valueType ON (valueType.ID = valueType_ID),
  MANY TO MANY JOIN checklistconfiguration_ItemTypeValues_drafts AS "VALUES" ON ("VALUES".itemType_ID = ID),
  MANY TO MANY JOIN checklistconfiguration_ItemTypeTexts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN checklistconfiguration_ItemTypeTexts_drafts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE')),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_ItemTypeValues_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  description NVARCHAR(255) NULL,
  active BOOLEAN NULL,
  booleanValue BOOLEAN NULL,
  stringValue NVARCHAR(1000) NULL,
  dateValue TIMESTAMP NULL,
  integerValue INTEGER NULL,
  decimalValue DECIMAL(15, 2) NULL,
  pickList INTEGER NULL,
  itemType_ID INTEGER NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemTypes_drafts AS itemType ON (itemType.ID = itemType_ID),
  MANY TO MANY JOIN checklistconfiguration_ItemTypeValueTexts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN checklistconfiguration_ItemTypeValueTexts_drafts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE')),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_ItemTypeValueTexts_drafts (
  locale NVARCHAR(14) NOT NULL,
  ID NVARCHAR(36) NOT NULL,
  description NVARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(locale, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemTypeValues_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_ItemTypeTexts_drafts (
  locale NVARCHAR(14) NOT NULL,
  ID INTEGER NOT NULL,
  description NVARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(locale, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemTypes_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_ItemConfigurations_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  description NVARCHAR(255) NULL,
  active BOOLEAN NULL DEFAULT TRUE,
  deletedAt TIMESTAMP NULL,
  deletedBy NVARCHAR(100) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN checklistconfiguration_ItemConfigurationTypes_drafts AS types ON (types.configuration_ID = ID),
  MANY TO MANY JOIN checklistconfiguration_ItemConfigurationProcesses_drafts AS processes ON (processes.configuration_ID = ID),
  MANY TO MANY JOIN checklistconfiguration_ItemConfigurationBlocks_drafts AS blocks ON (blocks.configuration_ID = ID),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_ItemConfigurationTypes_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  defaulted BOOLEAN NULL,
  mandatory BOOLEAN NULL,
  defaultBoolean BOOLEAN NULL,
  defaultString NVARCHAR(1000) NULL,
  defaultDate DATE NULL,
  defaultInteger INTEGER NULL,
  defaultDecimal DECIMAL(15, 2) NULL,
  defaultPickList INTEGER NULL,
  beforeCreate NVARCHAR(100) NULL,
  afterUpdate NVARCHAR(100) NULL,
  afterRead NVARCHAR(100) NULL,
  refreshEntity NVARCHAR(30) NULL,
  "ORDER" INTEGER NULL,
  type_ID INTEGER NULL,
  configuration_ID NVARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemTypes AS type ON (type.ID = type_ID),
  MANY TO ONE JOIN checklistconfiguration_ItemConfigurations_drafts AS configuration ON (configuration.ID = configuration_ID),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_ItemConfigurationProcesses_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  processId INTEGER NULL,
  configuration_ID NVARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemConfigurations_drafts AS configuration ON (configuration.ID = configuration_ID),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE checklistconfiguration_ItemConfigurationBlocks_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  phaseType NVARCHAR(50) NULL,
  blockType NVARCHAR(50) NULL,
  configuration_ID NVARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemConfigurations_drafts AS configuration ON (configuration.ID = configuration_ID),
  MANY TO ONE JOIN checklistconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_WorkTypes_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_WorkTypes_texts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_WorkTypes_texts_drafts (
  LOCALE NVARCHAR(14) NOT NULL,
  NAME NVARCHAR(255) NULL,
  DESCR NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(LOCALE, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_WorkTypes_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_ProjectObjectivesCountry_drafts (
  ID INTEGER NOT NULL,
  name NVARCHAR(255) NULL,
  country NVARCHAR(40) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_LocalizedWorkTypes_drafts (
  code INTEGER NOT NULL,
  name NVARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(code)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_WorkTypes_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN workconfiguration_WorkTypesTexts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_WorkTypesTexts_drafts (
  LOCALE NVARCHAR(14) NOT NULL,
  NAME NVARCHAR(255) NULL,
  DESCR NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(LOCALE, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkTypes_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_WorkParentTypes_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN workconfiguration_WorkParentTypes_texts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_WorkParentTypes_texts_drafts (
  LOCALE NVARCHAR(14) NOT NULL,
  NAME NVARCHAR(255) NULL,
  DESCR NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(LOCALE, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkParentTypes_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_MasterObjectives_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN workconfiguration_MasterObjectivesTexts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_MasterObjectivesTexts_drafts (
  LOCALE NVARCHAR(14) NOT NULL,
  NAME NVARCHAR(255) NULL,
  DESCR NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(LOCALE, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_MasterObjectives_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_WorkConfigs_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  ID NVARCHAR(36) NOT NULL,
  description NVARCHAR(200) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN workconfiguration_FlowsPerProcess_drafts AS FlowsPerProcess ON (FlowsPerProcess.Configuration_ID = ID),
  MANY TO MANY JOIN workconfiguration_Objectives_drafts AS Objectives ON (Objectives.Configuration_ID = ID),
  MANY TO MANY JOIN workconfiguration_Documents_drafts AS Documents ON (Documents.Configuration_ID = ID),
  MANY TO MANY JOIN workconfiguration_DocumentDefaults_drafts AS DocumentDefaults ON (DocumentDefaults.Configuration_ID = ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_FlowsPerProcess_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  ID NVARCHAR(36) NOT NULL,
  processFlowId INTEGER NULL,
  phaseTypeId NVARCHAR(50) NULL,
  blockTypeId NVARCHAR(50) NULL,
  default BOOLEAN NULL,
  Type_ID INTEGER NULL,
  Configuration_ID NVARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkTypes AS Type ON (Type.ID = Type_ID),
  MANY TO ONE JOIN workconfiguration_WorkConfigs_drafts AS Configuration ON (Configuration.ID = Configuration_ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_Objectives_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  ID NVARCHAR(36) NOT NULL,
  objective_ID INTEGER NULL,
  Configuration_ID NVARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_MasterObjectives AS objective ON (objective.ID = objective_ID),
  MANY TO ONE JOIN workconfiguration_WorkConfigs_drafts AS Configuration ON (Configuration.ID = Configuration_ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_Documents_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  documentId NVARCHAR(50) NULL,
  WorkType_ID INTEGER NULL,
  Configuration_ID NVARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkTypes AS WorkType ON (WorkType.ID = WorkType_ID),
  MANY TO ONE JOIN workconfiguration_WorkConfigs_drafts AS Configuration ON (Configuration.ID = Configuration_ID),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE workconfiguration_DocumentDefaults_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  documentId NVARCHAR(50) NULL,
  approverType INTEGER NULL,
  externalType INTEGER NULL,
  subcontractorValidationReq BOOLEAN NULL,
  cellnexValidationReq BOOLEAN NULL,
  customerValidationReq BOOLEAN NULL,
  landlordValidationReq BOOLEAN NULL,
  default BOOLEAN NULL,
  deleted BOOLEAN NULL,
  Configuration_ID NVARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkConfigs_drafts AS Configuration ON (Configuration.ID = Configuration_ID),
  MANY TO MANY JOIN workconfiguration_DocumentDefaults_texts AS texts ON (texts.ID = ID),
  MANY TO ONE JOIN workconfiguration_DocumentDefaults_texts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE')),
  MANY TO ONE JOIN workconfiguration_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_WORK_PARENT_TYPES_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_WORK_PARENT_TYPES_texts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_WORK_PARENT_TYPES_texts_drafts (
  LOCALE NVARCHAR(14) NOT NULL,
  NAME NVARCHAR(255) NULL,
  DESCR NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(LOCALE, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_WORK_PARENT_TYPES_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_ItemType_drafts (
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  ID INTEGER NOT NULL,
  description NVARCHAR(255) NULL,
  active BOOLEAN NULL,
  valueType_ID INTEGER NULL,
  defaultBoolean BOOLEAN NULL,
  defaultString NVARCHAR(1000) NULL,
  defaultDate DATE NULL,
  defaultInteger INTEGER NULL,
  defaultDecimal DECIMAL(15, 2) NULL,
  defaultPickList INTEGER NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_FieldType AS valueType ON (valueType.ID = valueType_ID),
  MANY TO MANY JOIN project_ItemTypeValue_drafts AS "VALUES" ON ("VALUES".itemType_ID = ID),
  MANY TO MANY JOIN project_ItemType_texts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN project_ItemType_texts_drafts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE')),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_ItemTypeValue_drafts (
  ID NVARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy NVARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy NVARCHAR(255) NULL,
  description NVARCHAR(255) NULL,
  active BOOLEAN NULL,
  booleanValue BOOLEAN NULL,
  stringValue NVARCHAR(1000) NULL,
  dateValue TIMESTAMP NULL,
  integerValue INTEGER NULL,
  decimalValue DECIMAL(15, 2) NULL,
  pickList INTEGER NULL,
  itemType_ID INTEGER NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ItemType_drafts AS itemType ON (itemType.ID = itemType_ID),
  MANY TO MANY JOIN project_ItemTypeValue_texts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN project_ItemTypeValue_texts_drafts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE')),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_ItemTypeValue_texts_drafts (
  locale NVARCHAR(14) NOT NULL,
  ID NVARCHAR(36) NOT NULL,
  description NVARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(locale, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ItemTypeValue_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_ItemType_texts_drafts (
  locale NVARCHAR(14) NOT NULL,
  ID INTEGER NOT NULL,
  description NVARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(locale, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ItemType_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_FieldType_drafts (
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
) WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_FieldType_texts_drafts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE TABLE project_FieldType_texts_drafts (
  locale NVARCHAR(14) NOT NULL,
  name NVARCHAR(255) NULL,
  descr NVARCHAR(1000) NULL,
  ID INTEGER NOT NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID NVARCHAR(36) NOT NULL,
  PRIMARY KEY(locale, ID)
) WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_FieldType_drafts AS parent ON (parent.ID = ID),
  MANY TO ONE JOIN project_DraftAdministrativeData AS DraftAdministrativeData ON (DraftAdministrativeData.DraftUUID = DraftAdministrativeData_DraftUUID)
);

CREATE VIEW checklistconfiguration_FieldTypes AS SELECT
  FieldType_0.name,
  FieldType_0.descr,
  FieldType_0.ID
FROM Checklist_FieldType AS FieldType_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN checklistconfiguration_FieldTypeTexts AS translations ON (translations.ID = ID)
);

CREATE VIEW checklistconfiguration_FieldTypeTexts AS SELECT
  texts_0.locale,
  texts_0.name,
  texts_0.descr,
  texts_0.ID
FROM Checklist_FieldType_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_FieldTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW checklistconfiguration_ItemTypes AS SELECT
  ItemType_0.createdAt,
  ItemType_0.createdBy,
  ItemType_0.modifiedAt,
  ItemType_0.modifiedBy,
  ItemType_0.ID,
  ItemType_0.description,
  ItemType_0.active,
  ItemType_0.valueType_ID,
  ItemType_0.defaultBoolean,
  ItemType_0.defaultString,
  ItemType_0.defaultDate,
  ItemType_0.defaultInteger,
  ItemType_0.defaultDecimal,
  ItemType_0.defaultPickList
FROM Checklist_ItemType AS ItemType_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_FieldTypes AS valueType ON (valueType.ID = valueType_ID),
  MANY TO MANY JOIN checklistconfiguration_ItemTypeValues AS "VALUES" ON ("VALUES".itemType_ID = ID),
  MANY TO MANY JOIN checklistconfiguration_ItemTypeTexts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN checklistconfiguration_ItemTypeTexts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW checklistconfiguration_ItemTypeTexts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.description
FROM Checklist_ItemType_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW checklistconfiguration_ItemTypeValues AS SELECT
  ItemTypeValue_0.ID,
  ItemTypeValue_0.createdAt,
  ItemTypeValue_0.createdBy,
  ItemTypeValue_0.modifiedAt,
  ItemTypeValue_0.modifiedBy,
  ItemTypeValue_0.description,
  ItemTypeValue_0.active,
  ItemTypeValue_0.booleanValue,
  ItemTypeValue_0.stringValue,
  ItemTypeValue_0.dateValue,
  ItemTypeValue_0.integerValue,
  ItemTypeValue_0.decimalValue,
  ItemTypeValue_0.pickList,
  ItemTypeValue_0.itemType_ID
FROM Checklist_ItemTypeValue AS ItemTypeValue_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemTypes AS itemType ON (itemType.ID = itemType_ID),
  MANY TO MANY JOIN checklistconfiguration_ItemTypeValueTexts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN checklistconfiguration_ItemTypeValueTexts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW checklistconfiguration_ItemTypeValueTexts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.description
FROM Checklist_ItemTypeValue_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemTypeValues AS parent ON (parent.ID = ID)
);

CREATE VIEW checklistconfiguration_ItemConfigurations AS SELECT
  ItemConfiguration_0.ID,
  ItemConfiguration_0.createdAt,
  ItemConfiguration_0.createdBy,
  ItemConfiguration_0.modifiedAt,
  ItemConfiguration_0.modifiedBy,
  ItemConfiguration_0.description,
  ItemConfiguration_0.active,
  ItemConfiguration_0.deletedAt,
  ItemConfiguration_0.deletedBy
FROM Checklist_ItemConfiguration AS ItemConfiguration_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN checklistconfiguration_ItemConfigurationTypes AS types ON (types.configuration_ID = ID),
  MANY TO MANY JOIN checklistconfiguration_ItemConfigurationProcesses AS processes ON (processes.configuration_ID = ID),
  MANY TO MANY JOIN checklistconfiguration_ItemConfigurationBlocks AS blocks ON (blocks.configuration_ID = ID)
);

CREATE VIEW checklistconfiguration_ItemConfigurationTypes AS SELECT
  ItemConfigurationType_0.ID,
  ItemConfigurationType_0.createdAt,
  ItemConfigurationType_0.createdBy,
  ItemConfigurationType_0.modifiedAt,
  ItemConfigurationType_0.modifiedBy,
  ItemConfigurationType_0.defaulted,
  ItemConfigurationType_0.mandatory,
  ItemConfigurationType_0.defaultBoolean,
  ItemConfigurationType_0.defaultString,
  ItemConfigurationType_0.defaultDate,
  ItemConfigurationType_0.defaultInteger,
  ItemConfigurationType_0.defaultDecimal,
  ItemConfigurationType_0.defaultPickList,
  ItemConfigurationType_0.beforeCreate,
  ItemConfigurationType_0.afterUpdate,
  ItemConfigurationType_0.afterRead,
  ItemConfigurationType_0.refreshEntity,
  ItemConfigurationType_0."ORDER",
  ItemConfigurationType_0.type_ID,
  ItemConfigurationType_0.configuration_ID
FROM Checklist_ItemConfigurationType AS ItemConfigurationType_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemTypes AS type ON (type.ID = type_ID),
  MANY TO ONE JOIN checklistconfiguration_ItemConfigurations AS configuration ON (configuration.ID = configuration_ID)
);

CREATE VIEW checklistconfiguration_ItemConfigurationProcesses AS SELECT
  ItemConfigurationProcess_0.ID,
  ItemConfigurationProcess_0.createdAt,
  ItemConfigurationProcess_0.createdBy,
  ItemConfigurationProcess_0.modifiedAt,
  ItemConfigurationProcess_0.modifiedBy,
  ItemConfigurationProcess_0.processId,
  ItemConfigurationProcess_0.configuration_ID
FROM Checklist_ItemConfigurationProcess AS ItemConfigurationProcess_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemConfigurations AS configuration ON (configuration.ID = configuration_ID)
);

CREATE VIEW checklistconfiguration_ItemConfigurationBlocks AS SELECT
  ItemConfigurationBlock_0.ID,
  ItemConfigurationBlock_0.createdAt,
  ItemConfigurationBlock_0.createdBy,
  ItemConfigurationBlock_0.modifiedAt,
  ItemConfigurationBlock_0.modifiedBy,
  ItemConfigurationBlock_0.phaseType,
  ItemConfigurationBlock_0.blockType,
  ItemConfigurationBlock_0.configuration_ID
FROM Checklist_ItemConfigurationBlock AS ItemConfigurationBlock_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN checklistconfiguration_ItemConfigurations AS configuration ON (configuration.ID = configuration_ID)
);

CREATE VIEW project_Requests AS SELECT
  REQUEST_HEAD_0.REQUEST_ID AS ID,
  REQUEST_HEAD_0.ASSIGNATION_DATE AS assignationDate,
  REQUEST_HEAD_0.CANCELLATION_COMMENTS AS cancellationComments,
  REQUEST_HEAD_0.CANCELLATION_PHASE_ID AS cancellationPhaseID,
  REQUEST_HEAD_0.CANCELLATION_REASON AS cancellationReason,
  REQUEST_HEAD_0.COMUNIDAD_ID AS company,
  REQUEST_HEAD_0.COUNTRY_ID AS country,
  REQUEST_HEAD_0.CREATEDAT AS createdAt,
  REQUEST_HEAD_0.CREATEDBY AS createdBy,
  REQUEST_HEAD_0.DELETED_AT AS deletedAt,
  REQUEST_HEAD_0.DELETED_BY AS deletedBy,
  REQUEST_HEAD_0.ENDED_AT AS closedAt,
  REQUEST_HEAD_0.MODIFIEDAT AS changedAt,
  REQUEST_HEAD_0.MODIFIEDBY AS changedBy,
  REQUEST_HEAD_0.PROCESS_ID AS processFlowId,
  REQUEST_HEAD_0.REQUEST_CODE AS code,
  REQUEST_HEAD_0.REQUEST_DESCRIPTION AS description,
  REQUEST_HEAD_0.REQUEST_OWNER_ID AS manager,
  REQUEST_HEAD_0.REQUEST_STATUS AS status,
  REQUEST_HEAD_0.REQUEST_TYPE AS requestType,
  REQUEST_HEAD_0.ROLE_ID AS role,
  REQUEST_HEAD_0.SITE_ID AS siteId,
  REQUEST_HEAD_0.STARTED_AT AS opentAt,
  REQUEST_HEAD_0.ON_HOLD_COMMENTS AS onHoldComments,
  REQUEST_HEAD_0.ON_HOLD_PHASE_ID AS onHoldPhaseId,
  REQUEST_HEAD_0.ON_HOLD_REASON AS onHoldReason,
  REQUEST_HEAD_0.WORKFLOW_NAME AS workflowName,
  REQUEST_HEAD_0.WORKFLOW_ID AS creationConfig
FROM REQUEST_HEAD AS REQUEST_HEAD_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_RequestProvision AS RequestProvision ON (RequestProvision.ID = ID),
  MANY TO MANY JOIN project_Phases AS Phases ON (Phases.requestId = ID),
  MANY TO MANY JOIN project_Chats AS Chats ON (Chats.ID = ID),
  MANY TO MANY JOIN project_ChangesLog AS ChangesLog ON (ChangesLog.requestId = ID),
  MANY TO ONE JOIN project_ProcessTypes AS ProcessTypes ON (ProcessTypes.code = processFlowId),
  MANY TO ONE JOIN project_RequestTypes AS RequestTypes ON (RequestTypes.REQUEST_TYPE = requestType),
  MANY TO ONE JOIN project_RequestStatus AS RequestStatus ON (RequestStatus.code = status),
  MANY TO ONE JOIN project_OnHoldReasons AS OnHoldReasons ON (OnHoldReasons.code = onHoldReason),
  MANY TO ONE JOIN project_CancellationReasons AS CancellationReasons ON (CancellationReasons.code = cancellationReason),
  MANY TO ONE JOIN project_Managers AS Managers ON (Managers.userId = manager),
  MANY TO ONE JOIN project_Sites AS Site ON (Site.siteId = siteId),
  MANY TO MANY JOIN project_RequestDocumentsPerBlockDefaultValid AS RequestDocumentsPerBlockDefaultValid ON (RequestDocumentsPerBlockDefaultValid.requestId = ID AND RequestDocumentsPerBlockDefaultValid.deleted = FALSE),
  MANY TO MANY JOIN project_DocumentsPerRequest AS DocumentsPerRequest ON (DocumentsPerRequest.requestId = ID),
  MANY TO MANY JOIN project_DocumentViewerNodes AS DocumentViewerNodes ON (DocumentViewerNodes.requestId = ID),
  MANY TO MANY JOIN project_ImpactedCustomers AS ImpactedCustomers ON (ImpactedCustomers.requestId = ID)
);

CREATE VIEW project_RequestProvision AS SELECT
  REQUEST_CHAR_PRO_0.REQUEST_ID AS ID,
  REQUEST_CHAR_PRO_0.REQUESTED_DATE AS requestedDate,
  REQUEST_CHAR_PRO_0.REQUESTER AS requester,
  REQUEST_CHAR_PRO_0.FORESCAST_DONE AS forecastDone,
  REQUEST_CHAR_PRO_0.PMO_MANAGER AS PMOManager,
  REQUEST_CHAR_PRO_0.PREFERRED_PROVIDER AS preferredProvider,
  REQUEST_CHAR_PRO_0.PREFERRED_PROVIDER_NAME AS preferredProviderName,
  REQUEST_CHAR_PRO_0.CLASIFICATION AS classification,
  REQUEST_CHAR_PRO_0.SF_OPPORTUNITY_ID AS salesforceRequestId,
  REQUEST_CHAR_PRO_0.PROJECT_OBJECTIVE AS projectObjective,
  REQUEST_CHAR_PRO_0.MOA_OPERATION AS moaOperation
FROM REQUEST_CHAR_PRO AS REQUEST_CHAR_PRO_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_Requests AS Requests ON (Requests.ID = ID),
  MANY TO ONE JOIN project_Classifications AS Classifications ON (Classifications.code = classification),
  MANY TO ONE JOIN project_PreferredProviders AS PreferredProviders ON (PreferredProviders.code = preferredProvider),
  MANY TO ONE JOIN project_MoaOperationTypes AS MoaOperationTypes ON (MoaOperationTypes.code = moaOperation),
  MANY TO ONE JOIN project_CacheR3Entities AS CacheR3Entities ON (CacheR3Entities.code = preferredProvider),
  MANY TO ONE JOIN project_PMOManagers AS PMOManagers ON (PMOManagers.userId = PMOManager),
  MANY TO ONE JOIN project_Requesters AS Requesters ON (Requesters.userId = requester),
  MANY TO ONE JOIN project_ProjectObjectives AS ProjectObjectives ON (ProjectObjectives.ID = projectObjective)
);

CREATE VIEW project_RequestDocumentsPerBlockDefaultValid AS SELECT
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.REGISTER_ID AS ID,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DOCUMENT_ID AS documentId,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.REQUEST_ID AS requestId,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.APPROVER_TYPE AS responsibleId,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.SUBCONTRACTOR AS subcontractorId,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DEFAULT_RESPONSIBLE AS responsibleDefault,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.SUBCO_REQ_VAL AS subcontractorValidation,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.CELLNEX_REQ_VAL AS cellnexValidation,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.CUSTOMER__REQ_VAL AS customerValidation,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.SITEOWNER_REQ_VAL AS siteOwnerValidation,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.CREATEDAT AS createdAt,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.CREATEDBY AS createdBy,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DELETED AS deleted,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DELETED_AT AS deletedAt,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DELETED_BY AS deletebBy,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.MODIFIEDAT AS modifiedAt,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.MODIFIEDBY AS modifiedBy
FROM REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID AS REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_Requests AS Requests ON (Requests.ID = requestId),
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = responsibleId),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcontractorId),
  MANY TO ONE JOIN project_DocumentFlowDefaultValidDocumentId AS DocumentFlowDefaultValidDocumentId ON (DocumentFlowDefaultValidDocumentId.documentId = documentId),
  MANY TO ONE JOIN project_DocumentFlowResponsiblesDefaultValid AS DocumentFlowResponsiblesDefaultValid ON (DocumentFlowResponsiblesDefaultValid.code = responsibleDefault)
);

CREATE VIEW project_Phases AS SELECT
  PHASE_HEAD_0.PHASE_ID AS ID,
  PHASE_HEAD_0.CREATEDAT AS createdAt,
  PHASE_HEAD_0.CREATEDBY AS createdBy,
  PHASE_HEAD_0.DELETED AS deleted,
  PHASE_HEAD_0.DELETED_AT AS deletedAt,
  PHASE_HEAD_0.DELETED_BY AS deletedBy,
  PHASE_HEAD_0.ENDED_AT AS closedAt,
  PHASE_HEAD_0.MASTER_PHASE_ID AS processFlowId,
  PHASE_HEAD_0.MODIFIEDAT AS changedAt,
  PHASE_HEAD_0.MODIFIEDBY AS changedBy,
  PHASE_HEAD_0.PHASE_OWNER AS owner,
  PHASE_HEAD_0.PHASE_STATUS AS status,
  PHASE_HEAD_0.REQUEST_ID AS requestId,
  PHASE_HEAD_0.STARTED_AT AS openAt
FROM PHASE_HEAD AS PHASE_HEAD_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_Blocks AS Blocks ON (Blocks.phaseId = ID),
  MANY TO ONE JOIN project_Requests AS Requests ON (Requests.ID = requestId),
  MANY TO ONE JOIN project_PhaseStatus AS PhaseStatus ON (PhaseStatus.code = status),
  MANY TO MANY JOIN project_SupportDocuments AS SupportDocuments ON (SupportDocuments.phaseName = processFlowId AND SupportDocuments.requestId = requestId)
);

CREATE VIEW project_Blocks AS SELECT
  BLOCK_HEAD_0.BLOCK_ID AS ID,
  BLOCK_HEAD_0.ACTIVATED AS activated,
  BLOCK_HEAD_0.BLOCK_STATUS AS status,
  BLOCK_HEAD_0.COMMENTS AS comments,
  BLOCK_HEAD_0.COMMENTS AS commentsPLU,
  BLOCK_HEAD_0.CREATEDAT AS createdAt,
  BLOCK_HEAD_0.CREATEDBY AS createdBy,
  BLOCK_HEAD_0.DELETED_AT AS deletedAt,
  BLOCK_HEAD_0.DELETED_BY AS deletedBy,
  BLOCK_HEAD_0.ENDED_AT AS closedAt,
  BLOCK_HEAD_0.MASTER_BLOCK_ID AS processFlowId,
  BLOCK_HEAD_0.MODIFIEDAT AS modifiedAt,
  BLOCK_HEAD_0.MODIFIEDBY AS modifiedBy,
  BLOCK_HEAD_0.PHASE_ID AS phaseId,
  BLOCK_HEAD_0.ROLE_ID AS role,
  BLOCK_HEAD_0.STARTED_AT AS openAt,
  BLOCK_HEAD_0.MANDATORY AS mandatory,
  BLOCK_HEAD_0.OWNER_ID AS owner
FROM BLOCK_HEAD AS BLOCK_HEAD_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_Phases AS Phases ON (Phases.ID = phaseId),
  MANY TO ONE JOIN project_BlockProvision AS BlockProvision ON (BlockProvision.ID = ID),
  MANY TO MANY JOIN project_Works AS Works ON (Works.parentId = ID AND Works.parentType_ID = 30),
  MANY TO MANY JOIN project_ChecklistItems AS Checklist ON (Checklist.block_ID = ID),
  MANY TO ONE JOIN project_BlockStatus AS BlockStatus ON (BlockStatus.code = status),
  MANY TO MANY JOIN project_Documents AS Documents ON (Documents.blockId = ID AND Documents.workId IS NULL),
  MANY TO MANY JOIN project_SupportDocuments AS SupportDocuments ON (SupportDocuments.blockId = ID),
  MANY TO MANY JOIN project_ContractRestrictions AS ContractRestrictions ON (ContractRestrictions.BLOCK_ID = ID),
  MANY TO MANY JOIN project_DocumentsPerBlocks AS DocumentsPerBlocks ON (DocumentsPerBlocks.blockId = ID),
  MANY TO MANY JOIN project_AttachmentDocumentTypes AS AttachmentDocumentTypes ON (AttachmentDocumentTypes.BLOCK_ID = ID)
);

CREATE VIEW project_BlockProvision AS SELECT
  BLOCKS_PROVISIONING_0.BLOCK_ID AS ID,
  BLOCKS_PROVISIONING_0.ACCEPTED_REJECTED AS accepted,
  BLOCKS_PROVISIONING_0.ACCEPTED_REJECTED_DATE AS acceptedDate,
  BLOCKS_PROVISIONING_0.ACTIVATION_REASON AS activationReason,
  BLOCKS_PROVISIONING_0.ADAPTIONS_TYPE AS adaptionsType,
  BLOCKS_PROVISIONING_0.APD_PACK_DELIVERY_EXPECTED_DATE AS apdPackDeliveryExpectedDate,
  BLOCKS_PROVISIONING_0.APD_PACK_DELIVERY_PLANNED_DATE AS apdPackDeliveryPlannedDate,
  BLOCKS_PROVISIONING_0.APS_DELIVERY_EXPECTED_DATE AS apsDeliveryExpectedDate,
  BLOCKS_PROVISIONING_0.APS_DELIVERY_PLANNED_DATE AS apsDeliveryPlannedDate,
  BLOCKS_PROVISIONING_0.ASSIGNED_RESPONSIBLE AS assignedResponsible,
  BLOCKS_PROVISIONING_0.AUTOMATIC_MANUAL_RESPONSE AS automaticManualResponse,
  BLOCKS_PROVISIONING_0.STATUS AS repaymentStatus,
  BLOCKS_PROVISIONING_0.BTTN_DOC_UPDATED AS documentsUpdated,
  BLOCKS_PROVISIONING_0.BTTN_INV_UPDATED AS inventoryUpdated,
  BLOCKS_PROVISIONING_0.BTTN_SERV_UPDATED AS servicesUpdated,
  BLOCKS_PROVISIONING_0.COMPLETED_BY AS completedBy,
  BLOCKS_PROVISIONING_0.COMPLETED_DATE AS completedDate,
  BLOCKS_PROVISIONING_0.COMPLEXITY AS complexity,
  BLOCKS_PROVISIONING_0.CONTRACT_RESTRICTIONS AS contractRestrictions,
  BLOCKS_PROVISIONING_0.CREATEDAT AS createdAt,
  BLOCKS_PROVISIONING_0.CREATEDBY AS createdBy,
  BLOCKS_PROVISIONING_0.CURRENCY AS currency,
  BLOCKS_PROVISIONING_0.DEBTOR AS debtor,
  BLOCKS_PROVISIONING_0.DESCRIPTION AS description,
  BLOCKS_PROVISIONING_0.DELETED AS deleted,
  BLOCKS_PROVISIONING_0.DELETED_AT AS deletedAt,
  BLOCKS_PROVISIONING_0.DELETED_BY AS deletedBy,
  BLOCKS_PROVISIONING_0.ENDED_AT AS closedAt,
  BLOCKS_PROVISIONING_0.ENERGY_PROVIDER_DOC_DELIVERY_EXPECTED_DATE AS energyProvDocExpectedDate,
  BLOCKS_PROVISIONING_0.ENERGY_PROVIDER_VISIT_EXPECTED_DATE AS energyProvVisitExpectedDate,
  BLOCKS_PROVISIONING_0.ENERGY_PROVIDER_VISIT_DATE AS energyProviderVisitDate,
  BLOCKS_PROVISIONING_0.EXPECTED_DATE AS expectedDate,
  BLOCKS_PROVISIONING_0.EXPECTED_START_DATE AS expectedStartDate,
  BLOCKS_PROVISIONING_0.EXPECTED_END_DATE AS expectedEndDate,
  BLOCKS_PROVISIONING_0.EXPECTED_MAD_DATE AS expectedMadDate,
  BLOCKS_PROVISIONING_0.ESTIMATED_PAYMENT_DATE AS estimatedPaymentDate,
  BLOCKS_PROVISIONING_0.READY_TO_START_WORKS_DATE AS readyToStartWorksDate,
  BLOCKS_PROVISIONING_0.GLOBAL_END_WORKS_DATE AS globalEndWorksDate,
  BLOCKS_PROVISIONING_0.GLOBAL_START_WORKS_DATE AS globalStartWorksDate,
  BLOCKS_PROVISIONING_0.HS_VISIT_DATE AS hsVisitDate,
  BLOCKS_PROVISIONING_0.HS_VISIT_PLANNED_DATE AS hsVisitPlannedDate,
  BLOCKS_PROVISIONING_0.INFRASTRUCTURES_MAD_DATE AS infraMadDate,
  BLOCKS_PROVISIONING_0.KICK_OFF_ESTIMATED_VISIT_DATE AS kickOffEstimatedVisitDate,
  BLOCKS_PROVISIONING_0.KICK_OFF_VISIT_NEEDED AS visitNeeded,
  BLOCKS_PROVISIONING_0.MODIFIEDAT AS changedAt,
  BLOCKS_PROVISIONING_0.MODIFIEDBY AS changedBy,
  BLOCKS_PROVISIONING_0.PLANNED_DATE AS plannedDate,
  BLOCKS_PROVISIONING_0.PLANNED_KICK_OFF_DATE AS plannedKickoffDate,
  BLOCKS_PROVISIONING_0.PLANNING_RATING AS planningRating,
  BLOCKS_PROVISIONING_0.PROVIDER_NAME AS externalResponsible,
  BLOCKS_PROVISIONING_0.REJECTION_CAUSE AS rejectionReason,
  BLOCKS_PROVISIONING_0.RENEGO_NEEDED AS renegoNeeded,
  BLOCKS_PROVISIONING_0.REAL_DATE_SURVEY AS siteSurveyDate,
  BLOCKS_PROVISIONING_0.REAL_END_DATE AS realEndDate,
  BLOCKS_PROVISIONING_0.REAL_END_DATE AS kickOffRealDate,
  BLOCKS_PROVISIONING_0.REAL_END_DATE AS heritageEndDate,
  BLOCKS_PROVISIONING_0.REAL_START_DATE AS realStartDate,
  BLOCKS_PROVISIONING_0.RESPONSIBLE_PERSON AS internalResponsible,
  BLOCKS_PROVISIONING_0.RESULT_MAD AS madResult,
  BLOCKS_PROVISIONING_0.SEND_OFFER_DATE AS sendOfferDate,
  BLOCKS_PROVISIONING_0.START_DATE AS startDate,
  BLOCKS_PROVISIONING_0.END_DATE AS endDate,
  BLOCKS_PROVISIONING_0.SITE_SURVEY_WILL_BE_NEEDED AS siteSurveyWillBeNeeded,
  BLOCKS_PROVISIONING_0.SUBCONTRACTOR_TYPE AS subcontractorType,
  BLOCKS_PROVISIONING_0.AMOUNT_BUDGET AS amount,
  BLOCKS_PROVISIONING_0.TOTAL_COST AS totalCost,
  BLOCKS_PROVISIONING_0.TOTAL_COST AS totalCostClient,
  BLOCKS_PROVISIONING_0.NEED_KICK_OFF_VISIT AS kickOffVisitNeeded,
  BLOCKS_PROVISIONING_0.OVERALL_FEASIBILITY AS overallFeasibility,
  BLOCKS_PROVISIONING_0.OVERALL_FEASIBILITY_RISK AS overallFeasibilityRisk,
  BLOCKS_PROVISIONING_0.PERMITS_NEEDED AS permitsNeeded,
  BLOCKS_PROVISIONING_0.PERMITS_FEASIBILITY AS permitsFeasibility,
  BLOCKS_PROVISIONING_0.PERMITS_FEASIBILITY_EXPLANATION AS permitsFeasibilityExp,
  BLOCKS_PROVISIONING_0.REAL_ESTATE_FEASIBILITY AS realStateFeasibility,
  BLOCKS_PROVISIONING_0.REAL_ESTATE_FEASIBILITY_RISK AS realStateFeasibilityRisk,
  BLOCKS_PROVISIONING_0.REAL_ESTATE_FEASIBILITY_EXPLANATION AS realEstateFeasibilityExp
FROM BLOCKS_PROVISIONING AS BLOCKS_PROVISIONING_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_Blocks AS Blocks ON (Blocks.ID = ID),
  MANY TO ONE JOIN project_RepaymentStatus AS RepaymentStatus ON (RepaymentStatus.code = repaymentStatus),
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = assignedResponsible),
  MANY TO ONE JOIN project_YesNoFields AS SiteSurveyNeeded ON (SiteSurveyNeeded.code = siteSurveyWillBeNeeded),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcontractorType),
  MANY TO ONE JOIN project_YesNoFields AS KickOffVisitNeeded ON (KickOffVisitNeeded.code = kickOffVisitNeeded),
  MANY TO ONE JOIN project_AdaptionsNeededFields AS RenegoNeeded ON (RenegoNeeded.code = renegoNeeded),
  MANY TO ONE JOIN project_AutomaticFields AS AutomaticManualResponses ON (AutomaticManualResponses.code = automaticManualResponse),
  MANY TO ONE JOIN project_FeasibilitiesWithRisks AS RealStateFeasibilities ON (RealStateFeasibilities.code = realStateFeasibility),
  MANY TO ONE JOIN project_FeasibilitiesWithRisks AS PermitsFeasibilities ON (PermitsFeasibilities.code = permitsFeasibility),
  MANY TO ONE JOIN project_Risks AS RealStateRisks ON (RealStateRisks.code = realStateFeasibilityRisk),
  MANY TO ONE JOIN project_AdaptionsNeededFields AS PermitsNeeded ON (PermitsNeeded.code = permitsNeeded),
  MANY TO ONE JOIN project_AcceptedRejected AS AcceptedRejected ON (AcceptedRejected.code = accepted),
  MANY TO ONE JOIN project_RejectionReasons AS RejectionReasons ON (RejectionReasons.code = rejectionReason),
  MANY TO ONE JOIN project_Currencies AS Currencies ON (Currencies.code = currency),
  MANY TO ONE JOIN project_Complexities AS Complexities ON (Complexities.code = complexity),
  MANY TO ONE JOIN project_MadResults AS MadResults ON (MadResults.code = madResult),
  MANY TO ONE JOIN project_AdaptionsTypes AS AdaptionsTypes ON (AdaptionsTypes.code = adaptionsType),
  MANY TO ONE JOIN project_FeasibilityExplanations AS RealStateFeasibilityExplanations ON (RealStateFeasibilityExplanations.code = realEstateFeasibilityExp),
  MANY TO ONE JOIN project_FeasibilityExplanations AS PermitsFeasibilityExplanations ON (PermitsFeasibilityExplanations.code = permitsFeasibilityExp)
);

CREATE VIEW project_LocalDocuments AS SELECT
  WF_DETAIL_DOCUMENTS_LOCAL_0.REGISTER_ID AS ID,
  WF_DETAIL_DOCUMENTS_LOCAL_0.BLOCK_ID AS blockId,
  WF_DETAIL_DOCUMENTS_LOCAL_0.INSTANCE_ID AS instanceId,
  WF_DETAIL_DOCUMENTS_LOCAL_0.REQUEST_ID AS requestId,
  WF_DETAIL_DOCUMENTS_LOCAL_0.REQUEST_CODE AS requestCode,
  WF_DETAIL_DOCUMENTS_LOCAL_0.TYPE_ID AS docType,
  WF_DETAIL_DOCUMENTS_LOCAL_0.STEP_ID AS stepId,
  WF_DETAIL_DOCUMENTS_LOCAL_0.FIELD AS field,
  WF_DETAIL_DOCUMENTS_LOCAL_0.DOCUMENT_NAME AS documentName,
  WF_DETAIL_DOCUMENTS_LOCAL_0.DOCUMENT_VERSION AS version,
  WF_DETAIL_DOCUMENTS_LOCAL_0.DOCUMENT_URL AS fileUrl,
  WF_DETAIL_DOCUMENTS_LOCAL_0.USER_DOC AS "USER",
  WF_DETAIL_DOCUMENTS_LOCAL_0.CREATION_DATE_DOC AS documentCreationDate,
  WF_DETAIL_DOCUMENTS_LOCAL_0.DOCUMENT_SUBTYPE AS subType,
  WF_DETAIL_DOCUMENTS_LOCAL_0.DOCUMENT_SUBTYPE_LVL2 AS subTypeLvl2,
  WF_DETAIL_DOCUMENTS_LOCAL_0.CREATEDAT AS createdAt,
  WF_DETAIL_DOCUMENTS_LOCAL_0.CREATEDBY AS createdBy,
  WF_DETAIL_DOCUMENTS_LOCAL_0.DELETED AS deleted,
  WF_DETAIL_DOCUMENTS_LOCAL_0.DELETED_BY AS deletedBy,
  WF_DETAIL_DOCUMENTS_LOCAL_0.MODIFIEDAT AS modifiedAt,
  WF_DETAIL_DOCUMENTS_LOCAL_0.MODIFIEDBY AS modifiedBy,
  WF_DETAIL_DOCUMENTS_LOCAL_0.DOCUMENT_ID AS documentId,
  WF_DETAIL_DOCUMENTS_LOCAL_0.OT_DOCUMENT_ID AS OTDocumentId,
  WF_DETAIL_DOCUMENTS_LOCAL_0.BLOCK_NAME AS blockName,
  WF_DETAIL_DOCUMENTS_LOCAL_0.PHASE_NAME AS phaseName,
  WF_DETAIL_DOCUMENTS_LOCAL_0.FINAL_DOCUMENT AS finalDocument,
  WF_DETAIL_DOCUMENTS_LOCAL_0.MEDIA_TYPE AS mediaType,
  WF_DETAIL_DOCUMENTS_LOCAL_0.WORK_ID AS workId,
  CASE WHEN WF_DETAIL_DOCUMENTS_LOCAL_0.MEDIA_TYPE IS NULL THEN 'text/plain' ELSE WF_DETAIL_DOCUMENTS_LOCAL_0.MEDIA_TYPE END AS virtMediaType
FROM WF_DETAIL_DOCUMENTS_LOCAL AS WF_DETAIL_DOCUMENTS_LOCAL_0;

CREATE VIEW project_Works AS SELECT
  WORKS_0.ID,
  WORKS_0.status,
  WORKS_0.description,
  WORKS_0.responsibleType,
  WORKS_0.externalType,
  WORKS_0.comments,
  WORKS_0.startDate,
  WORKS_0.endDate,
  WORKS_0.expectedStartDate,
  WORKS_0.expectedEndDate,
  WORKS_0.realStartDate,
  WORKS_0.realEndDate,
  WORKS_0.parentId,
  WORKS_0.internalResponsible,
  WORKS_0.externalResponsible,
  WORKS_0.parentType_ID,
  WORKS_0.type_ID
FROM WORKS AS WORKS_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_WORK_PARENT_TYPES AS parentType ON (parentType.ID = parentType_ID),
  MANY TO ONE JOIN project_Blocks AS block ON (block.ID = parentId),
  MANY TO MANY JOIN project_Documents AS documents ON (documents.workId = ID),
  MANY TO MANY JOIN project_DocumentsPerBlocks AS approvalFlows ON (approvalFlows.workId = ID),
  MANY TO ONE JOIN project_WorkTypes AS type ON (type.ID = type_ID),
  MANY TO ONE JOIN project_LocalizedWorkTypes AS LocalizedWorkTypesName ON (LocalizedWorkTypesName.code = type_ID)
);

CREATE VIEW project_ChecklistItems AS SELECT
  Item_0.ID,
  Item_0.description,
  Item_0.type_ID,
  Item_0.mandatory,
  Item_0.booleanValue,
  Item_0.stringValue,
  Item_0.dateValue,
  Item_0.integerValue,
  Item_0.decimalValue,
  Item_0.pickList,
  Item_0.block_ID,
  Item_0.deleted
FROM Checklist_Item AS Item_0
WHERE Item_0.deleted != TRUE
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ItemType AS type ON (type.ID = type_ID),
  MANY TO ONE JOIN project_Blocks AS block ON (block.ID = block_ID)
);

CREATE VIEW project_Documents AS SELECT
  WF_DETAIL_DOCUMENTS_0.REGISTER_ID AS ID,
  WF_DETAIL_DOCUMENTS_0.BLOCK_ID AS blockId,
  WF_DETAIL_DOCUMENTS_0.INSTANCE_ID AS instanceId,
  WF_DETAIL_DOCUMENTS_0.REQUEST_ID AS requestId,
  WF_DETAIL_DOCUMENTS_0.REQUEST_CODE AS requestCode,
  WF_DETAIL_DOCUMENTS_0.TYPE_ID AS docType,
  WF_DETAIL_DOCUMENTS_0.STEP_ID AS stepId,
  WF_DETAIL_DOCUMENTS_0.FIELD AS field,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_NAME AS documentName,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_VERSION AS version,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_URL AS fileUrl,
  WF_DETAIL_DOCUMENTS_0.USER_DOC AS "USER",
  WF_DETAIL_DOCUMENTS_0.CREATION_DATE_DOC AS documentCreationDate,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_SUBTYPE AS subType,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_SUBTYPE_LVL2 AS subTypeLvl2,
  WF_DETAIL_DOCUMENTS_0.CREATEDAT AS createdAt,
  WF_DETAIL_DOCUMENTS_0.CREATEDBY AS createdBy,
  WF_DETAIL_DOCUMENTS_0.DELETED AS deleted,
  WF_DETAIL_DOCUMENTS_0.DELETED_BY AS deletedBy,
  WF_DETAIL_DOCUMENTS_0.MODIFIEDAT AS modifiedAt,
  WF_DETAIL_DOCUMENTS_0.MODIFIEDBY AS modifiedBy,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_ID AS documentId,
  WF_DETAIL_DOCUMENTS_0.OT_DOCUMENT_ID AS OTDocumentId,
  WF_DETAIL_DOCUMENTS_0.BLOCK_NAME AS blockName,
  WF_DETAIL_DOCUMENTS_0.PHASE_NAME AS phaseName,
  WF_DETAIL_DOCUMENTS_0.FINAL_DOCUMENT AS finalDocument,
  WF_DETAIL_DOCUMENTS_0.MEDIA_TYPE AS mediaType,
  WF_DETAIL_DOCUMENTS_0.WORK_ID AS workId,
  CASE WHEN WF_DETAIL_DOCUMENTS_0.MEDIA_TYPE IS NULL THEN 'text/plain' ELSE WF_DETAIL_DOCUMENTS_0.MEDIA_TYPE END AS virtMediaType
FROM WF_DETAIL_DOCUMENTS AS WF_DETAIL_DOCUMENTS_0
WHERE WF_DETAIL_DOCUMENTS_0.DELETED != TRUE AND WF_DETAIL_DOCUMENTS_0.DOCUMENT_URL IS NOT NULL AND WF_DETAIL_DOCUMENTS_0.DOCUMENT_URL != '';

CREATE VIEW project_SupportDocuments AS SELECT
  WF_DETAIL_DOCUMENTS_0.REGISTER_ID AS ID,
  WF_DETAIL_DOCUMENTS_0.BLOCK_ID AS blockId,
  WF_DETAIL_DOCUMENTS_0.INSTANCE_ID AS instanceId,
  WF_DETAIL_DOCUMENTS_0.REQUEST_ID AS requestId,
  WF_DETAIL_DOCUMENTS_0.REQUEST_CODE AS requestCode,
  WF_DETAIL_DOCUMENTS_0.TYPE_ID AS docType,
  WF_DETAIL_DOCUMENTS_0.STEP_ID AS stepId,
  WF_DETAIL_DOCUMENTS_0.FIELD AS field,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_NAME AS documentName,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_VERSION AS version,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_URL AS fileUrl,
  WF_DETAIL_DOCUMENTS_0.USER_DOC AS "USER",
  WF_DETAIL_DOCUMENTS_0.CREATION_DATE_DOC AS documentCreationDate,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_SUBTYPE AS subType,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_SUBTYPE_LVL2 AS subTypeLvl2,
  WF_DETAIL_DOCUMENTS_0.CREATEDAT AS createdAt,
  WF_DETAIL_DOCUMENTS_0.CREATEDBY AS createdBy,
  WF_DETAIL_DOCUMENTS_0.DELETED AS deleted,
  WF_DETAIL_DOCUMENTS_0.DELETED_BY AS deletedBy,
  WF_DETAIL_DOCUMENTS_0.MODIFIEDAT AS modifiedAt,
  WF_DETAIL_DOCUMENTS_0.MODIFIEDBY AS modifiedBy,
  WF_DETAIL_DOCUMENTS_0.DOCUMENT_ID AS documentId,
  WF_DETAIL_DOCUMENTS_0.OT_DOCUMENT_ID AS OTDocumentId,
  WF_DETAIL_DOCUMENTS_0.BLOCK_NAME AS blockName,
  WF_DETAIL_DOCUMENTS_0.PHASE_NAME AS phaseName,
  WF_DETAIL_DOCUMENTS_0.FINAL_DOCUMENT AS finalDocument,
  WF_DETAIL_DOCUMENTS_0.MEDIA_TYPE AS mediaType,
  WF_DETAIL_DOCUMENTS_0.WORK_ID AS workId,
  CASE WHEN WF_DETAIL_DOCUMENTS_0.MEDIA_TYPE IS NULL THEN 'text/plain' ELSE WF_DETAIL_DOCUMENTS_0.MEDIA_TYPE END AS virtMediaType
FROM WF_DETAIL_DOCUMENTS AS WF_DETAIL_DOCUMENTS_0;

CREATE VIEW project_DocumentsPerBlocks AS SELECT
  DOCUMENTS_PER_BLOCK_0.REGISTER_ID AS ID,
  DOCUMENTS_PER_BLOCK_0.BLOCK_ID AS blockId,
  DOCUMENTS_PER_BLOCK_0.CREATEDAT AS createdAt,
  DOCUMENTS_PER_BLOCK_0.CREATEDBY AS createdBy,
  DOCUMENTS_PER_BLOCK_0.DELETED AS deleted,
  DOCUMENTS_PER_BLOCK_0.DELETED_AT AS deletedAt,
  DOCUMENTS_PER_BLOCK_0.DELETED_BY AS deletedBy,
  DOCUMENTS_PER_BLOCK_0.MODIFIEDAT AS modifiedAt,
  DOCUMENTS_PER_BLOCK_0.MODIFIEDBY AS modifiedBy,
  DOCUMENTS_PER_BLOCK_0."ORDER" AS "ORDER",
  DOCUMENTS_PER_BLOCK_0.RESPONSIBLE_ID AS responsibleId,
  DOCUMENTS_PER_BLOCK_0.SUBCONTRATOR_ID AS subcontractorId,
  DOCUMENTS_PER_BLOCK_0.T_RESPONSIBLE AS responsibleDefault,
  DOCUMENTS_PER_BLOCK_0.VALIDATION_CELLNEX_CLIENT AS cellnexValidation,
  DOCUMENTS_PER_BLOCK_0.VALIDATION_REQ_CLIENT AS customerValidation,
  DOCUMENTS_PER_BLOCK_0.VALIDATION_SUBCO_CLIENT AS subcontractorValidation,
  DOCUMENTS_PER_BLOCK_0.VALIDATION_SITEOWNER_NEEDED AS siteOwnerValidation,
  DOCUMENTS_PER_BLOCK_0.GENERIC_TYPE_ID AS documentId,
  DOCUMENTS_PER_BLOCK_0.TYPE_ID AS typeId,
  DOCUMENTS_PER_BLOCK_0.STATUS AS status,
  DOCUMENTS_PER_BLOCK_0.PERMIT_ID AS jointProjectId,
  DOCUMENTS_PER_BLOCK_0.STEP_ID AS masterBlock_id,
  DOCUMENTS_PER_BLOCK_0.WORK_ID AS workId
FROM DOCUMENTS_PER_BLOCK AS DOCUMENTS_PER_BLOCK_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_Blocks AS Blocks ON (Blocks.ID = ID),
  MANY TO ONE JOIN project_InstancesPerDocuments AS InstancesPerDocuments ON (InstancesPerDocuments.instanceId = ID),
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = responsibleId),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcontractorId)
);

CREATE VIEW project_InstancesPerDocuments AS SELECT
  INSTANCES_PER_DOCUMENT_0.REGISTER_ID AS ID,
  INSTANCES_PER_DOCUMENT_0.CELLNEX_COMMENT AS cellnexComment,
  INSTANCES_PER_DOCUMENT_0.CELLNEX_VALIDATION AS cellnexValidation,
  INSTANCES_PER_DOCUMENT_0.CELLNEX_VALIDATION_DATE AS cellnexValidationDate,
  INSTANCES_PER_DOCUMENT_0.CELLNEX_VALIDATOR AS cellnexValidator,
  INSTANCES_PER_DOCUMENT_0.CONTACT_EMAIL AS contactEmail,
  INSTANCES_PER_DOCUMENT_0.CONTACT_PHONE AS contactPhone,
  INSTANCES_PER_DOCUMENT_0.CREATEDAT AS createdAt,
  INSTANCES_PER_DOCUMENT_0.CREATEDBY AS createdBy,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_COMMENT AS customerComment,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_VALIDATION AS customerValidation,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_VALIDATION_DATE AS customerValidationDate,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_VALIDATOR AS customerValidator,
  INSTANCES_PER_DOCUMENT_0.DELETED AS deleted,
  INSTANCES_PER_DOCUMENT_0.DELETED_AT AS deletedAt,
  INSTANCES_PER_DOCUMENT_0.DELETED_BY AS deletedBy,
  INSTANCES_PER_DOCUMENT_0.DOC_PB_ID AS jointProjectId,
  INSTANCES_PER_DOCUMENT_0.DOCUMENT_ID_DOSSIER_ATTACHED AS requestCodeOrigin,
  INSTANCES_PER_DOCUMENT_0.END_DATE AS endDate,
  INSTANCES_PER_DOCUMENT_0.INSTANCE_ID AS instanceId,
  INSTANCES_PER_DOCUMENT_0.MODIFIEDAT AS modifiedAt,
  INSTANCES_PER_DOCUMENT_0.MODIFIEDBY AS modifiedBy,
  INSTANCES_PER_DOCUMENT_0.SITEOWNER_COMMENT AS siteOwnerComment,
  INSTANCES_PER_DOCUMENT_0.SITEOWNER_VALIDATION AS siteOwnerValidation,
  INSTANCES_PER_DOCUMENT_0.SITEOWNER_VALIDATION_DATE AS siteOwnerValidationDate,
  INSTANCES_PER_DOCUMENT_0.SITEOWNER_VALIDATOR AS siteOwnerValidator,
  INSTANCES_PER_DOCUMENT_0.START_DATE AS startDate,
  INSTANCES_PER_DOCUMENT_0.SUBCONTRACTOR_COMMENT AS subcontractorComment,
  INSTANCES_PER_DOCUMENT_0.SUBCONTRACTOR_VALIDATION AS subcontractorValidation,
  INSTANCES_PER_DOCUMENT_0.SUBCONTRACTOR_VALIDATION_DATE AS subcontractorValidationDate,
  INSTANCES_PER_DOCUMENT_0.SUBCONTRACTOR_VALIDATOR AS subcontractorValidator,
  INSTANCES_PER_DOCUMENT_0.SUBMISSION_DATE AS submissionDate,
  INSTANCES_PER_DOCUMENT_0.T_GO AS tasksActivated,
  INSTANCES_PER_DOCUMENT_0.VERSION AS version,
  INSTANCES_PER_DOCUMENT_0.BLOCK_ID AS blockId,
  INSTANCES_PER_DOCUMENT_0.STEP_ID AS stepId,
  INSTANCES_PER_DOCUMENT_0.STEP_TXT AS stepName,
  INSTANCES_PER_DOCUMENT_0.ASSIGNED_ROLE AS assignedRole,
  INSTANCES_PER_DOCUMENT_0.EXPECTED_SUBMISSION_DATE AS expectedSubmissionDate,
  INSTANCES_PER_DOCUMENT_0.EXPECTED_CUSTOMER_VAL AS expectedCustValidationDate,
  INSTANCES_PER_DOCUMENT_0.EXPECTED_CELLNEX_VAL AS expectedCellValidationDate,
  INSTANCES_PER_DOCUMENT_0.EXPIRATION_DATE AS expirationDate,
  INSTANCES_PER_DOCUMENT_0.PLANNED_SUBMISSION_DATE AS plannedSubmissionDate,
  INSTANCES_PER_DOCUMENT_0.CANCELLATION_REASON AS cancellationReason,
  INSTANCES_PER_DOCUMENT_0.MODIFIEDBULK_AT AS modifiedBulkAt,
  INSTANCES_PER_DOCUMENT_0.MODIFIEDBULK_BY AS modifiedBulkBy,
  INSTANCES_PER_DOCUMENT_0.CREATEDBULK_AT AS createdBulkAt,
  INSTANCES_PER_DOCUMENT_0.CREATEDBULK_BY AS createdBulkBy,
  INSTANCES_PER_DOCUMENT_0.DELETEDBULK_AT AS deletedBulkAt,
  INSTANCES_PER_DOCUMENT_0.DELETEDBULK_BY AS deletedBulkBy,
  INSTANCES_PER_DOCUMENT_0.ASSIGNED_RESPONSIBLE AS assignedResponsible,
  INSTANCES_PER_DOCUMENT_0.SUBCO_ASSIGNED AS assignedSubcontractor,
  INSTANCES_PER_DOCUMENT_0.FORECAST_NA AS forecastNA,
  INSTANCES_PER_DOCUMENT_0.DOCUMENT_ID_SENT_CUSTOMER AS taskCode,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_INFORM_DATE AS customerInformDate,
  INSTANCES_PER_DOCUMENT_0.DOCUMENTS_RESPONSIBLE_COMMENTS AS documentsResponsibleComments,
  INSTANCES_PER_DOCUMENT_0.LIMIT_SUBMISSION_DATE AS limitSubmissionDate
FROM INSTANCES_PER_DOCUMENT AS INSTANCES_PER_DOCUMENT_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_DocumentsPerBlocks AS DocumentsPerBlocks ON (DocumentsPerBlocks.ID = instanceId),
  MANY TO MANY JOIN project_Documents AS Documents ON (Documents.instanceId = ID),
  MANY TO MANY JOIN project_LocalDocuments AS LocalDocuments ON (LocalDocuments.instanceId = ID),
  MANY TO ONE JOIN project_PreferredProviders AS PreferredProviders ON (PreferredProviders.code = subcontractorValidator)
);

CREATE VIEW project_Chats AS SELECT
  WF_CHAT_0.REQUEST_ID AS ID,
  WF_CHAT_0.USER_ID AS userId,
  WF_CHAT_0."TIME" AS "DATE",
  WF_CHAT_0."TEXT" AS "TEXT",
  WF_CHAT_0.READ AS readed
FROM WF_CHAT AS WF_CHAT_0;

CREATE VIEW project_ContractRestrictions AS SELECT
  MASTER_MS_CONTRACT_RESTRICTIONS_0.CONTRACT_RESTRICTIONS_ID AS contractRestrictionId,
  MASTER_MS_CONTRACT_RESTRICTIONS_0.BLOCK_ID,
  MASTER_MS_CONTRACT_RESTRICTIONS_0.CONTRACT_RESTRICTIONS_TXT,
  MASTER_MS_CONTRACT_RESTRICTIONS_0.DELETED,
  MASTER_MS_CONTRACT_RESTRICTIONS_0.DELETEDAT,
  MASTER_MS_CONTRACT_RESTRICTIONS_0.DELETEDBY
FROM MASTER_MS_CONTRACT_RESTRICTIONS AS MASTER_MS_CONTRACT_RESTRICTIONS_0
WHERE MASTER_MS_CONTRACT_RESTRICTIONS_0.DELETED = FALSE
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ContractRestrictionVH AS ContractRestrictionsVH ON (ContractRestrictionsVH.code = contractRestrictionId)
);

CREATE VIEW project_DocumentFlows AS SELECT
  DOCUMENT_FLOWS_0.ID,
  DOCUMENT_FLOWS_0.createdAt,
  DOCUMENT_FLOWS_0.createdBy,
  DOCUMENT_FLOWS_0.modifiedAt,
  DOCUMENT_FLOWS_0.modifiedBy,
  DOCUMENT_FLOWS_0.documentId,
  DOCUMENT_FLOWS_0.documentName,
  DOCUMENT_FLOWS_0.documentType,
  DOCUMENT_FLOWS_0.documentSubtype,
  DOCUMENT_FLOWS_0.documentSubType2,
  DOCUMENT_FLOWS_0.countryId,
  DOCUMENT_FLOWS_0.enableAttachments
FROM DOCUMENT_FLOWS AS DOCUMENT_FLOWS_0;

CREATE VIEW project_ProcessTypes AS SELECT
  PROCESS_TYPES_0.name,
  PROCESS_TYPES_0.descr,
  PROCESS_TYPES_0.code
FROM PROCESS_TYPES AS PROCESS_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_ProcessTypes_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN project_ProcessTypes_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW project_RequestTypes AS SELECT
  REQUEST_TYPE_0.REQUEST_TYPE,
  REQUEST_TYPE_0.REQUEST_TYPE_CODE,
  REQUEST_TYPE_0.REQUEST_TYPE_DESC,
  REQUEST_TYPE_0.MASTER_PROCESS_ID
FROM REQUEST_TYPE AS REQUEST_TYPE_0
WHERE REQUEST_TYPE_0.REQUEST_TYPE = 40;

CREATE VIEW project_RequestTypesLinked AS SELECT
  REQUEST_TYPE_0.REQUEST_TYPE,
  REQUEST_TYPE_0.REQUEST_TYPE_CODE,
  REQUEST_TYPE_0.REQUEST_TYPE_DESC,
  REQUEST_TYPE_0.MASTER_PROCESS_ID
FROM REQUEST_TYPE AS REQUEST_TYPE_0
WHERE REQUEST_TYPE_0.REQUEST_TYPE IN (4, 10, 11, 1, 3, 2, 20, 30, 40);

CREATE VIEW project_WorkTypes AS SELECT
  WORK_TYPES_0.createdAt,
  WORK_TYPES_0.createdBy,
  WORK_TYPES_0.modifiedAt,
  WORK_TYPES_0.modifiedBy,
  WORK_TYPES_0.name,
  WORK_TYPES_0.descr,
  WORK_TYPES_0.ID
FROM WORK_TYPES AS WORK_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_WorkTypes_texts AS translations ON (translations.ID = ID)
);

CREATE VIEW project_Companies AS SELECT
  T001_0.MANDT,
  T001_0.BUKRS,
  T001_0.BUTXT,
  T001_0.ORT01,
  T001_0.LAND1,
  T001_0.WAERS,
  T001_0.SPRAS,
  T001_0.KTOPL,
  T001_0.WAABW,
  T001_0.PERIV,
  T001_0.KOKFI,
  T001_0.RCOMP,
  T001_0.ADRNR,
  T001_0.STCEG,
  T001_0.FIKRS,
  T001_0.XFMCO,
  T001_0.XFMCB,
  T001_0.XFMCA,
  T001_0.TXJCD,
  T001_0.FMHRDATE,
  T001_0.BUVAR,
  T001_0.FDBUK,
  T001_0.XFDIS,
  T001_0.XVALV,
  T001_0.XSKFN,
  T001_0.KKBER,
  T001_0.XMWSN,
  T001_0.MREGL,
  T001_0.XGSBE,
  T001_0.XGJRV,
  T001_0.XKDFT,
  T001_0.XPROD,
  T001_0.XEINK,
  T001_0.XJVAA,
  T001_0.XVVWA,
  T001_0.XSLTA,
  T001_0.XFDMM,
  T001_0.XFDSD,
  T001_0.XEXTB,
  T001_0.EBUKR,
  T001_0.KTOP2,
  T001_0.UMKRS,
  T001_0.BUKRS_GLOB,
  T001_0.FSTVA,
  T001_0.OPVAR,
  T001_0.XCOVR,
  T001_0.TXKRS,
  T001_0.WFVAR,
  T001_0.XBBBF,
  T001_0.XBBBE,
  T001_0.XBBBA,
  T001_0.XBBKO,
  T001_0.XSTDT,
  T001_0.MWSKV,
  T001_0.MWSKA,
  T001_0.IMPDA,
  T001_0.XNEGP,
  T001_0.XKKBI,
  T001_0.WT_NEWWT,
  T001_0.PP_PDATE,
  T001_0.INFMT,
  T001_0.FSTVARE,
  T001_0.KOPIM,
  T001_0.DKWEG,
  T001_0.OFFSACCT,
  T001_0.BAPOVAR,
  T001_0.XCOS,
  T001_0.XCESSION,
  T001_0.XSPLT,
  T001_0.SURCCM,
  T001_0.DTPROV,
  T001_0.DTAMTC,
  T001_0.DTTAXC,
  T001_0.DTTDSP,
  T001_0.DTAXR,
  T001_0.XVATDATE,
  T001_0.PST_PER_VAR,
  T001_0.XBBSC,
  T001_0.FM_DERIVE_ACC,
  T001_0.F_OBSOLETE
FROM T001 AS T001_0;

CREATE VIEW project_ProjectTypes AS SELECT
  PROJECT_TYPES_0.code,
  PROJECT_TYPES_0.country,
  PROJECT_TYPES_0.name
FROM PROJECT_TYPES AS PROJECT_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_ProjectTypes_texts AS texts ON (texts.code = code AND texts.country = country),
  MANY TO ONE JOIN project_ProjectTypes_texts AS localized ON (localized.code = code AND localized.country = country AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW project_BooleanValues AS SELECT
  BOOLEAN_VALUES_0.name,
  BOOLEAN_VALUES_0.descr,
  BOOLEAN_VALUES_0.code
FROM BOOLEAN_VALUES AS BOOLEAN_VALUES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_BooleanValues_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN project_BooleanValues_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW project_CacheR3Entities AS SELECT
  CACHE_R3_ENTITIES_0.USER_ID AS userId,
  CACHE_R3_ENTITIES_0.ENTITY_TYPE AS entityType,
  CACHE_R3_ENTITIES_0.ENTITY_ID AS code,
  CACHE_R3_ENTITIES_0.ENTITY_NAME AS name,
  CACHE_R3_ENTITIES_0.CREATED_AT AS createdAt
FROM CACHE_R3_ENTITIES AS CACHE_R3_ENTITIES_0;

CREATE VIEW project_DtLinkedRequest AS SELECT
  DT_LINKED_REQUEST_0.LINK_ID AS linkID,
  DT_LINKED_REQUEST_0.ASSOCIATION_TYPE AS associationType,
  DT_LINKED_REQUEST_0.PARENT_REQUEST_ID AS parentRequestID,
  DT_LINKED_REQUEST_0.PARENT_INSTANCE_ID AS parentInstanceID,
  DT_LINKED_REQUEST_0.PARENT_WORKFLOW_ID AS parentWorkflowID,
  DT_LINKED_REQUEST_0.CHILD_REQUEST_ID AS childRequestID,
  DT_LINKED_REQUEST_0.CHILD_INSTANCE_ID AS childInstanceID,
  DT_LINKED_REQUEST_0.CHILD_WORKFLOW_ID AS childWorkflowID,
  DT_LINKED_REQUEST_0.DELETED AS deleted,
  DT_LINKED_REQUEST_0.DELETED_AT AS deletedAt,
  DT_LINKED_REQUEST_0.DELETED_BY AS deletedBy
FROM DT_LINKED_REQUEST AS DT_LINKED_REQUEST_0;

CREATE VIEW project_DocumentViewerNodes AS SELECT
  DOCUMENT_VIEWER_NODES_0.NODE_ID AS nodeId,
  DOCUMENT_VIEWER_NODES_0.HIERARCHY_LEVEL AS hierarchyLevel,
  DOCUMENT_VIEWER_NODES_0.PARENT_NODE_ID AS parentNodeId,
  DOCUMENT_VIEWER_NODES_0.DRILL_STATE AS drillState,
  DOCUMENT_VIEWER_NODES_0.DESCRIPTION AS description,
  DOCUMENT_VIEWER_NODES_0.DOCUMENT_ID AS documentId,
  DOCUMENT_VIEWER_NODES_0.CREATED_BY AS createdBy,
  DOCUMENT_VIEWER_NODES_0.CREATED_AT AS createdAt,
  DOCUMENT_VIEWER_NODES_0.REQUEST_ID AS requestId
FROM DOCUMENT_VIEWER_NODES AS DOCUMENT_VIEWER_NODES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_DocumentViewerNodes AS Childrens ON (Childrens.parentNodeId = nodeId)
);

CREATE VIEW project_AttachmentDocumentTypes AS SELECT
  DF_0.documentId,
  BH_3.BLOCK_ID,
  DF_0.documentName,
  DF_0.documentType,
  DF_0.documentSubtype,
  DF_0.documentSubType2
FROM (((DOCUMENT_FLOWS AS DF_0 INNER JOIN REQUEST_HEAD AS RH_1 ON RH_1.COUNTRY_ID = DF_0.countryId) INNER JOIN PHASE_HEAD AS PH_2 ON PH_2.REQUEST_ID = RH_1.REQUEST_ID) INNER JOIN BLOCK_HEAD AS BH_3 ON BH_3.PHASE_ID = PH_2.PHASE_ID)
WHERE DF_0.enableAttachments = TRUE;

CREATE VIEW workconfiguration_WorkTypes AS SELECT
  WORK_TYPES_0.createdAt,
  WORK_TYPES_0.createdBy,
  WORK_TYPES_0.modifiedAt,
  WORK_TYPES_0.modifiedBy,
  WORK_TYPES_0.name,
  WORK_TYPES_0.descr,
  WORK_TYPES_0.ID
FROM WORK_TYPES AS WORK_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN workconfiguration_WorkTypesTexts AS translations ON (translations.ID = ID)
);

CREATE VIEW workconfiguration_WorkTypesTexts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM WORK_TYPES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW workconfiguration_WorkParentTypes AS SELECT
  WORK_PARENT_TYPES_0.createdAt,
  WORK_PARENT_TYPES_0.createdBy,
  WORK_PARENT_TYPES_0.modifiedAt,
  WORK_PARENT_TYPES_0.modifiedBy,
  WORK_PARENT_TYPES_0.name,
  WORK_PARENT_TYPES_0.descr,
  WORK_PARENT_TYPES_0.ID
FROM WORK_PARENT_TYPES AS WORK_PARENT_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN workconfiguration_WorkParentTypes_texts AS translations ON (translations.ID = ID)
);

CREATE VIEW workconfiguration_MasterObjectives AS SELECT
  PROJECT_OBJECTIVES_0.createdAt,
  PROJECT_OBJECTIVES_0.createdBy,
  PROJECT_OBJECTIVES_0.modifiedAt,
  PROJECT_OBJECTIVES_0.modifiedBy,
  PROJECT_OBJECTIVES_0.name,
  PROJECT_OBJECTIVES_0.descr,
  PROJECT_OBJECTIVES_0.ID
FROM PROJECT_OBJECTIVES AS PROJECT_OBJECTIVES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN workconfiguration_MasterObjectivesTexts AS translations ON (translations.ID = ID)
);

CREATE VIEW workconfiguration_MasterObjectivesTexts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM PROJECT_OBJECTIVES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_MasterObjectives AS parent ON (parent.ID = ID)
);

CREATE VIEW workconfiguration_WorkConfigs AS SELECT
  WORK_CONFIGS_0.createdAt,
  WORK_CONFIGS_0.createdBy,
  WORK_CONFIGS_0.modifiedAt,
  WORK_CONFIGS_0.modifiedBy,
  WORK_CONFIGS_0.ID,
  WORK_CONFIGS_0.description
FROM WORK_CONFIGS AS WORK_CONFIGS_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN workconfiguration_FlowsPerProcess AS FlowsPerProcess ON (FlowsPerProcess.Configuration_ID = ID),
  MANY TO MANY JOIN workconfiguration_Objectives AS Objectives ON (Objectives.Configuration_ID = ID),
  MANY TO MANY JOIN workconfiguration_Documents AS Documents ON (Documents.Configuration_ID = ID),
  MANY TO MANY JOIN workconfiguration_DocumentDefaults AS DocumentDefaults ON (DocumentDefaults.Configuration_ID = ID)
);

CREATE VIEW workconfiguration_FlowsPerProcess AS SELECT
  WORK_CONFIG_PROCESSES_0.createdAt,
  WORK_CONFIG_PROCESSES_0.createdBy,
  WORK_CONFIG_PROCESSES_0.modifiedAt,
  WORK_CONFIG_PROCESSES_0.modifiedBy,
  WORK_CONFIG_PROCESSES_0.ID,
  WORK_CONFIG_PROCESSES_0.processFlowId,
  WORK_CONFIG_PROCESSES_0.phaseTypeId,
  WORK_CONFIG_PROCESSES_0.blockTypeId,
  WORK_CONFIG_PROCESSES_0.default,
  WORK_CONFIG_PROCESSES_0.Type_ID,
  WORK_CONFIG_PROCESSES_0.Configuration_ID
FROM WORK_CONFIG_PROCESSES AS WORK_CONFIG_PROCESSES_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkTypes AS Type ON (Type.ID = Type_ID),
  MANY TO ONE JOIN workconfiguration_WorkConfigs AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW workconfiguration_Objectives AS SELECT
  WORK_CONFIG_OBJECTIVES_0.createdAt,
  WORK_CONFIG_OBJECTIVES_0.createdBy,
  WORK_CONFIG_OBJECTIVES_0.modifiedAt,
  WORK_CONFIG_OBJECTIVES_0.modifiedBy,
  WORK_CONFIG_OBJECTIVES_0.ID,
  WORK_CONFIG_OBJECTIVES_0.objective_ID,
  WORK_CONFIG_OBJECTIVES_0.Configuration_ID
FROM WORK_CONFIG_OBJECTIVES AS WORK_CONFIG_OBJECTIVES_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_MasterObjectives AS objective ON (objective.ID = objective_ID),
  MANY TO ONE JOIN workconfiguration_WorkConfigs AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW workconfiguration_Documents AS SELECT
  WORK_CONFIG_DOCUMENT_FLOWS_0.ID,
  WORK_CONFIG_DOCUMENT_FLOWS_0.createdAt,
  WORK_CONFIG_DOCUMENT_FLOWS_0.createdBy,
  WORK_CONFIG_DOCUMENT_FLOWS_0.modifiedAt,
  WORK_CONFIG_DOCUMENT_FLOWS_0.modifiedBy,
  WORK_CONFIG_DOCUMENT_FLOWS_0.documentId,
  WORK_CONFIG_DOCUMENT_FLOWS_0.WorkType_ID,
  WORK_CONFIG_DOCUMENT_FLOWS_0.Configuration_ID
FROM WORK_CONFIG_DOCUMENT_FLOWS AS WORK_CONFIG_DOCUMENT_FLOWS_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkTypes AS WorkType ON (WorkType.ID = WorkType_ID),
  MANY TO ONE JOIN workconfiguration_WorkConfigs AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW workconfiguration_DocumentDefaults AS SELECT
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.ID,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.createdAt,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.createdBy,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.modifiedAt,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.modifiedBy,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.name,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.descr,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.documentId,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.approverType,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.externalType,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.subcontractorValidationReq,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.cellnexValidationReq,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.customerValidationReq,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.landlordValidationReq,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.default,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.deleted,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.Configuration_ID
FROM WORK_CONFIG_DOCUMENT_DEFAULTS AS WORK_CONFIG_DOCUMENT_DEFAULTS_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkConfigs AS Configuration ON (Configuration.ID = Configuration_ID),
  MANY TO MANY JOIN workconfiguration_DocumentDefaults_texts AS texts ON (texts.ID = ID),
  MANY TO ONE JOIN workconfiguration_DocumentDefaults_texts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW Checklist_ItemTypesPerBlock AS SELECT
  cp_1.configuration_ID AS ID,
  cp_1.processId,
  cb_0.phaseType,
  cb_0.blockType,
  ct_2.type_ID AS type,
  ic_4.active,
  it_3.active AS activeType,
  ct_2.defaulted,
  ct_2.mandatory,
  ct_2.beforeCreate,
  ct_2.afterUpdate,
  ct_2.afterRead,
  ct_2.refreshEntity,
  ct_2."ORDER",
  ct_2.defaultBoolean,
  ct_2.defaultString,
  ct_2.defaultDate,
  ct_2.defaultInteger,
  ct_2.defaultDecimal,
  ct_2.defaultPickList
FROM ((((Checklist_ItemConfigurationBlock AS cb_0 INNER JOIN Checklist_ItemConfigurationProcess AS cp_1 ON cp_1.configuration_ID = cb_0.configuration_ID) INNER JOIN Checklist_ItemConfigurationType AS ct_2 ON ct_2.configuration_ID = cb_0.configuration_ID) INNER JOIN Checklist_ItemType AS it_3 ON it_3.ID = ct_2.type_ID) INNER JOIN Checklist_ItemConfiguration AS ic_4 ON ic_4.ID = cp_1.configuration_ID)
ORDER BY ct_2."ORDER";

CREATE VIEW Checklist_localized_ItemTypeValue AS SELECT
  L_0_0.pickList,
  L_0_0.itemType_ID AS itemType_ID,
  coalesce(localized_1_1.description, L_0_0.description) AS description,
  L_0_0.active
FROM (Checklist_ItemTypeValue AS L_0_0 LEFT JOIN Checklist_ItemTypeValue_texts AS localized_1_1 ON localized_1_1.ID = L_0_0.ID AND localized_1_1.locale = SESSION_CONTEXT('LOCALE'));

CREATE VIEW Checklist_localized_ItemType AS SELECT
  L_0_0.ID,
  coalesce(localized_1_1.description, L_0_0.description) AS description,
  L_0_0.active
FROM (Checklist_ItemType AS L_0_0 LEFT JOIN Checklist_ItemType_texts AS localized_1_1 ON localized_1_1.ID = L_0_0.ID AND localized_1_1.locale = SESSION_CONTEXT('LOCALE'));

CREATE VIEW CANCELLATION_REASONS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'int' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'cancellationReasons') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW ON_HOLD_REASONS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'int' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'reasonOnHold') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW CLASSIFICATIONS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'classification') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW COMPLEXITIES AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'int' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'intcomplexity') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW APPROVER_TYPES AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'approverType') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW SUBCO_TYPES AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'subcoType') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW YES_NO_FIELDS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'yesno') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW VALIDATIONS_DOCS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'documentValidation') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW FEASIBILITIES AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'feasibilities') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW FEASIBILITIES_WITH_RISKS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'feasibilitiesWithRisk') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW RISKS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'feasibilityRisk') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW ADAPTIONS_NEEDED_FIELDS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'adaptionsNeeded') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW ACCEPTED_REJECTED AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'acceptedPrv') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW AUTOMATIC_FIELDS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'automaticManual') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW REJECTION_REASONS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'bts' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'rejectionReason') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = SESSION_CONTEXT('LOCALE'));

CREATE VIEW MAD_RESULTS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'newCo' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'MAD_Result') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW ADAPTIONS_TYPES AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'newCo' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'adaptationsType') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW REPAYMENT_STATUS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'int' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'repaymentStatus') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW MOA_OPERATION_TYPES AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'newCo' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'moaOperation') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW CONTRACT_RESTRICTIONS_OPTIONS AS SELECT DISTINCT
  so_0.SELECT_OPTION_ID AS code,
  CASE WHEN so_0.SELECT_OPTION IS NULL OR so_0.SELECT_OPTION = '' THEN so_0.SELECT_OPTION ELSE so_0.SELECT_OPTION END AS name
FROM (SC_SELECT_OPTIONS_V2 AS so_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = so_0.COUNTRY_ID)
WHERE so_0.ACTIVE = TRUE AND LOWER(so_0."LANGUAGE") = LOWER(SESSION_CONTEXT('LOCALE')) AND so_0.FIELD_ID = 'contractRestrictions' AND so_0.SELECT_OPTION IS NOT NULL;

CREATE VIEW FEASIBILITY_EXPLANATION_OPTIONS AS SELECT
  som_2.SELECT_OPTION_ID AS code,
  CASE WHEN sot_3.SELECT_OPTION IS NULL OR sot_3.SELECT_OPTION = '' THEN som_2.SELECT_OPTION ELSE sot_3.SELECT_OPTION END AS name,
  soc_0.COUNTRY_ID AS country
FROM (((SC_SELECT_OPTIONS_V3_CONFIGURATION AS soc_0 INNER JOIN US_COUNTRIES AS co_1 ON co_1.USER_ID = SESSION_CONTEXT('APPLICATIONUSER') AND co_1.COUNTRY_ID = soc_0.COUNTRY_ID) INNER JOIN SC_SELECT_OPTIONS_V3_MASTER AS som_2 ON som_2.SELECT_OPTION_ID = soc_0.SELECT_OPTION_ID AND som_2.FIELD_ID = soc_0.FIELD_ID AND soc_0.PROCESS_ID_PK = 'newCo' AND soc_0.ACTIVE = TRUE AND soc_0.FIELD_ID = 'feasibilExplanation') LEFT JOIN SC_SELECT_OPTIONS_V3_TRANSLATE AS sot_3 ON sot_3.SELECT_OPTION_ID = som_2.SELECT_OPTION_ID AND sot_3.FIELD_ID = som_2.FIELD_ID AND sot_3.LANGUAGE_ID = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW localized_BLOCK_STATUS AS SELECT
  coalesce(BLOCK_STATUS_TEXTS_1.NAME, BLOCK_STATUS_0.NAME) AS name,
  coalesce(BLOCK_STATUS_TEXTS_1.DESCR, BLOCK_STATUS_0.DESCR) AS descr,
  BLOCK_STATUS_0.CODE AS code
FROM (BLOCK_STATUS AS BLOCK_STATUS_0 LEFT JOIN BLOCK_STATUS_TEXTS AS BLOCK_STATUS_TEXTS_1 ON BLOCK_STATUS_TEXTS_1.CODE = BLOCK_STATUS_0.CODE AND BLOCK_STATUS_TEXTS_1.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW localized_DOCUMENT_FLOW_STATUS AS SELECT
  coalesce(DOCUMENT_FLOW_STATUS_TEXTS_1.NAME, DOCUMENT_FLOW_STATUS_0.NAME) AS name,
  coalesce(DOCUMENT_FLOW_STATUS_TEXTS_1.DESCR, DOCUMENT_FLOW_STATUS_0.DESCR) AS descr,
  DOCUMENT_FLOW_STATUS_0.CODE AS code
FROM (DOCUMENT_FLOW_STATUS AS DOCUMENT_FLOW_STATUS_0 LEFT JOIN DOCUMENT_FLOW_STATUS_TEXTS AS DOCUMENT_FLOW_STATUS_TEXTS_1 ON DOCUMENT_FLOW_STATUS_TEXTS_1.CODE = DOCUMENT_FLOW_STATUS_0.CODE AND DOCUMENT_FLOW_STATUS_TEXTS_1.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW localized_PHASE_STATUS AS SELECT
  coalesce(PHASE_STATUS_TEXTS_1.NAME, PHASE_STATUS_0.NAME) AS name,
  coalesce(PHASE_STATUS_TEXTS_1.DESCR, PHASE_STATUS_0.DESCR) AS descr,
  PHASE_STATUS_0.CODE AS code
FROM (PHASE_STATUS AS PHASE_STATUS_0 LEFT JOIN PHASE_STATUS_TEXTS AS PHASE_STATUS_TEXTS_1 ON PHASE_STATUS_TEXTS_1.CODE = PHASE_STATUS_0.CODE AND PHASE_STATUS_TEXTS_1.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW localized_REQUEST_STATUS AS SELECT
  coalesce(REQUEST_STATUS_TEXTS_1.NAME, REQUEST_STATUS_0.NAME) AS name,
  coalesce(REQUEST_STATUS_TEXTS_1.DESCR, REQUEST_STATUS_0.DESCR) AS descr,
  REQUEST_STATUS_0.CODE AS code
FROM (REQUEST_STATUS AS REQUEST_STATUS_0 LEFT JOIN REQUEST_STATUS_TEXTS AS REQUEST_STATUS_TEXTS_1 ON REQUEST_STATUS_TEXTS_1.CODE = REQUEST_STATUS_0.CODE AND REQUEST_STATUS_TEXTS_1.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW localized_SEARCH_TYPES AS SELECT
  coalesce(SEARCH_TYPES_TEXTS_1.NAME, SEARCH_TYPES_0.NAME) AS name,
  coalesce(SEARCH_TYPES_TEXTS_1.DESCR, SEARCH_TYPES_0.DESCR) AS descr,
  SEARCH_TYPES_0.CODE AS code
FROM (SEARCH_TYPES AS SEARCH_TYPES_0 LEFT JOIN SEARCH_TYPES_TEXTS AS SEARCH_TYPES_TEXTS_1 ON SEARCH_TYPES_TEXTS_1.CODE = SEARCH_TYPES_0.CODE AND SEARCH_TYPES_TEXTS_1.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW localized_STATUS_HEAD AS SELECT
  STATUS_HEAD_0.STATUS_CODE AS code,
  coalesce(STATUS_TEXTS_1.STATUS_TEXT, STATUS_HEAD_0.STATUS_TEXT) AS name
FROM (STATUS_HEAD AS STATUS_HEAD_0 LEFT JOIN STATUS_TEXTS AS STATUS_TEXTS_1 ON STATUS_TEXTS_1.STATUS_CODE = STATUS_HEAD_0.STATUS_CODE AND STATUS_TEXTS_1."LANGUAGE" = UPPER(SESSION_CONTEXT('LANGUAGE')));

CREATE VIEW localized_TASK_TYPES AS SELECT
  coalesce(TASK_TYPES_TEXTS_1.NAME, TASK_TYPES_0.NAME) AS name,
  coalesce(TASK_TYPES_TEXTS_1.DESCR, TASK_TYPES_0.DESCR) AS descr,
  TASK_TYPES_0.CODE AS code
FROM (TASK_TYPES AS TASK_TYPES_0 LEFT JOIN TASK_TYPES_TEXTS AS TASK_TYPES_TEXTS_1 ON TASK_TYPES_TEXTS_1.CODE = TASK_TYPES_0.CODE AND TASK_TYPES_TEXTS_1.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW CHANGE_LOG AS SELECT DISTINCT
  log_0.ACTIONS_LOG_ID AS logId,
  log_0.REQUEST_ID AS requestId,
  log_0.REQUEST_TYPE AS requestType,
  log_0."DATE" AS changeDate,
  log_0."USER" AS userId,
  CASE WHEN ias_3.USER_NAME IS NULL OR ias_3.USER_NAME = '' THEN ias_3.USER_ID ELSE ias_3.USER_NAME END AS userName,
  log_0.ACTION AS userAction,
  '' AS userActionName,
  log_0.PHASE_ID_PK AS phaseProcessFlowId,
  mp_5.PHASE_NAME AS phaseName,
  log_0.BLOCK_ID_PK AS blockProcessFlowId,
  mb_6.BLOCK_NAME AS blockName,
  log_0.FIELD_MOD AS fieldName,
  '' AS fieldDescription,
  log_0.OLD_VALUE AS oldValue,
  '' AS oldValueDescription,
  log_0.NEW_VALUE AS newValue,
  '' AS newValueDescription,
  log_0.PHASE_ID AS phaseId,
  log_0.BLOCK_ID AS BlockId,
  doc_7.documentName AS documentName,
  type_9.ID AS workType,
  type_9.descr AS workTypeName
FROM (((((((((WF_ACTIONS_LOG AS log_0 LEFT JOIN REQUEST_HEAD AS rh_1 ON rh_1.REQUEST_ID = log_0.REQUEST_ID) LEFT JOIN BLOCK_HEAD AS bh_2 ON bh_2.BLOCK_ID = log_0.BLOCK_ID) LEFT JOIN US_USERS_IAS AS ias_3 ON ias_3.USER_ID = log_0."USER") LEFT JOIN PROCESS AS proc_4 ON proc_4.ID_PK = rh_1.PROCESS_ID) LEFT JOIN MASTER_PHASE AS mp_5 ON mp_5.PROCESS_ID_PK = proc_4.PROCESS_ID_PK AND mp_5.PHASE_ID_PK = log_0.PHASE_ID_PK AND mp_5.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) LEFT JOIN MASTER_BLOCK AS mb_6 ON mb_6.PROCESS_ID_PK = proc_4.PROCESS_ID_PK AND mb_6.PHASE_ID_PK = log_0.PHASE_ID_PK AND mb_6.BLOCK_ID_PK = log_0.BLOCK_ID_PK AND mb_6.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) LEFT JOIN DOCUMENT_FLOWS AS doc_7 ON doc_7.documentId = log_0.DOCUMENT_ID) LEFT JOIN WORKS AS works_8 ON works_8.ID = log_0.WORK_ID) LEFT JOIN WORK_TYPES AS type_9 ON works_8.type_ID = type_9.ID);

CREATE VIEW BLOCK_PHASE_REQUEST(IN p_blockId NVARCHAR(36)) AS SELECT
  bh_0.BLOCK_ID,
  bh_0.MASTER_BLOCK_ID,
  bh_0.BLOCK_STATUS,
  ph_1.PHASE_ID,
  ph_1.MASTER_PHASE_ID,
  rh_2.REQUEST_ID,
  rh_2.REQUEST_TYPE,
  rh_2.REQUEST_CODE,
  rh_2.PROCESS_ID,
  rh_2.COUNTRY_ID,
  rh_2.SITE_ID,
  rh_2.REQUEST_STATUS,
  p_3.PROCESS_ID_PK,
  bh_0.ROLE_ID
FROM (((BLOCK_HEAD AS bh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.PHASE_ID = bh_0.PHASE_ID AND bh_0.BLOCK_ID = :P_BLOCKID) INNER JOIN REQUEST_HEAD AS rh_2 ON rh_2.REQUEST_ID = ph_1.REQUEST_ID) INNER JOIN PROCESS AS p_3 ON p_3.ID_PK = rh_2.PROCESS_ID);

CREATE VIEW WORKS_BLOCK_PHASE_REQUEST(IN p_workId NVARCHAR(36)) AS SELECT
  gt_0.ID AS WORK_ID,
  gt_0.type_ID AS TYPE,
  gt_0.status AS STATUS,
  bh_1.BLOCK_ID,
  bh_1.MASTER_BLOCK_ID,
  bh_1.BLOCK_STATUS,
  ph_2.PHASE_ID,
  ph_2.MASTER_PHASE_ID,
  rh_3.REQUEST_ID,
  rh_3.REQUEST_TYPE,
  rp_4.PROJECT_OBJECTIVE,
  rh_3.PROCESS_ID,
  rh_3.COUNTRY_ID,
  rh_3.SITE_ID,
  p_5.PROCESS_ID_PK,
  bh_1.ROLE_ID
FROM (((((WORKS AS gt_0 INNER JOIN BLOCK_HEAD AS bh_1 ON bh_1.BLOCK_ID = gt_0.parentId AND gt_0.parentType_ID = 30 AND gt_0.ID = :P_WORKID) INNER JOIN PHASE_HEAD AS ph_2 ON ph_2.PHASE_ID = bh_1.PHASE_ID) INNER JOIN REQUEST_HEAD AS rh_3 ON rh_3.REQUEST_ID = ph_2.REQUEST_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_4 ON rp_4.REQUEST_ID = rh_3.REQUEST_ID) INNER JOIN PROCESS AS p_5 ON p_5.ID_PK = rh_3.PROCESS_ID);

CREATE VIEW CHECKLIST_BLOCK_PHASE_REQUEST(IN p_taskId NVARCHAR(36)) AS SELECT
  ci_0.ID AS ITEM_ID,
  ci_0.type_ID AS TYPE,
  bh_1.BLOCK_ID,
  bh_1.MASTER_BLOCK_ID,
  bh_1.BLOCK_STATUS,
  ph_2.PHASE_ID,
  ph_2.MASTER_PHASE_ID,
  rh_3.REQUEST_ID,
  rh_3.REQUEST_TYPE,
  rp_4.PROJECT_OBJECTIVE,
  rh_3.PROCESS_ID,
  rh_3.COUNTRY_ID,
  rh_3.SITE_ID,
  p_5.PROCESS_ID_PK
FROM (((((Checklist_Item AS ci_0 INNER JOIN BLOCK_HEAD AS bh_1 ON bh_1.BLOCK_ID = ci_0.block_ID) INNER JOIN PHASE_HEAD AS ph_2 ON ph_2.PHASE_ID = bh_1.PHASE_ID) INNER JOIN REQUEST_HEAD AS rh_3 ON rh_3.REQUEST_ID = ph_2.REQUEST_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_4 ON rp_4.REQUEST_ID = rh_3.REQUEST_ID) INNER JOIN PROCESS AS p_5 ON p_5.ID_PK = rh_3.PROCESS_ID);

CREATE VIEW SITES_BY_AOTYPE(IN p_aotype NVARCHAR(3)) AS SELECT
  site_0.AOID AS siteId,
  site_0.AOTYPE,
  site_0.ZZMUNA AS legacyCode,
  site_0.ZZINFO AS primaryLegacyCode,
  site_0.XAO AS siteName,
  emplaz_3.BUKRS AS company,
  site_0.ZZUNIDOPER AS cellnexZone,
  site_0.ZZOPERTYPE AS infraOrigin,
  site_0.ZZOWNERSHIP AS infraOwner,
  site_0.ZZCOMERCIAL AS marketableId,
  site_0.ZZABFZONE AS abfZone,
  address_5.COUNTRY AS country,
  address_5.REGION AS region,
  site_0.ZZCOMUNIDAD AS comunity,
  address_5.CITY1 AS city,
  address_5.POST_CODE1 AS postalCode,
  address_5.STREET AS street,
  address_5.HOUSE_NUM1 AS houseNumber,
  address_5."FLOOR" AS "FLOOR"
FROM (((((VIBDAO AS site_0 INNER JOIN VIBDOBJASS AS relation_1 ON relation_1.OBJNRSRC = site_0.OBJNR AND relation_1.OBJASSTYPE = '61' AND site_0.AOTYPE = :P_AOTYPE) INNER JOIN IFLOT AS details_2 ON details_2.OBJNR = relation_1.OBJNRTRG) INNER JOIN ILOA AS emplaz_3 ON emplaz_3.ILOAN = details_2.ILOAN) LEFT JOIN VZOBJECT AS adrcrel_4 ON adrcrel_4.ADROBJNR = site_0.INTRENO AND adrcrel_4.ADROBJTYP = 'VI' AND adrcrel_4.OBTYP = '56') LEFT JOIN ADRC AS address_5 ON address_5.ADDRNUMBER = adrcrel_4.ADRNR);

CREATE VIEW SITES AS SELECT DISTINCT
  site_0.AOID AS siteId,
  site_0.AOTYPE,
  site_0.ZZINFO AS primaryLegacyCode,
  site_0.ZZMUNA AS legacyCode,
  site_0.XAO AS siteName,
  emplaz_3.BUKRS AS company,
  site_0.ZZUNIDOPER AS cellnexZone,
  site_0.ZZONE AS zone,
  site_0.ZZOPERTYPE AS infraOrigin,
  site_0.ZZOWNERSHIP AS infraOwnership,
  site_0.ZZINFCONSTSTAT AS infraStatus,
  site_0.ZZCOMERCIAL AS marketableId,
  site_0.ZZABFZONE AS abfZone,
  site_0.ZZTITULARIDAD AS managingCompany,
  site_0.ZZPROYECT AS cellnexProject,
  site_0.ZZEXPLOITEDSITE AS exploited,
  site_0.ZZCOMUNIDAD AS comunity,
  address_17.COUNTRY AS country,
  address_17.REGION AS region,
  address_17.CITY1 AS city,
  address_17.POST_CODE1 AS postalCode,
  address_17.STREET AS street,
  address_17.HOUSE_NUM1 AS houseNumber,
  address_17."FLOOR" AS "FLOOR",
  pzr_5.PARTNER AS productionZoneResponsible,
  CASE WHEN pzrb_6.TYPE = 1 THEN pzrb_6.NAME_FIRST || ' ' || pzrb_6.NAME_LAST ELSE pzrb_6.NAME_ORG1 || ' ' || pzrb_6.NAME_ORG2 || ' ' || pzrb_6.NAME_ORG3 || ' ' || pzrb_6.NAME_ORG4 END AS productionZoneResponsibleName,
  szr_7.PARTNER AS siteManagerZoneResponsible,
  CASE WHEN szrb_8.TYPE = 1 THEN szrb_8.NAME_FIRST || ' ' || szrb_8.NAME_LAST ELSE szrb_8.NAME_ORG1 || ' ' || szrb_8.NAME_ORG2 || ' ' || szrb_8.NAME_ORG3 || ' ' || szrb_8.NAME_ORG4 END AS siteManagerZoneResponsibleName,
  prm_9.PARTNER AS productionRegionManager,
  CASE WHEN prmb_10.TYPE = 1 THEN prmb_10.NAME_FIRST || ' ' || prmb_10.NAME_LAST ELSE prmb_10.NAME_ORG1 || ' ' || prmb_10.NAME_ORG2 || ' ' || prmb_10.NAME_ORG3 || ' ' || prmb_10.NAME_ORG4 END AS productionRegionManagerName,
  rsm_11.PARTNER AS regionSiteManager,
  CASE WHEN rsmb_12.TYPE = 1 THEN rsmb_12.NAME_FIRST || ' ' || rsmb_12.NAME_LAST ELSE rsmb_12.NAME_ORG1 || ' ' || rsmb_12.NAME_ORG2 || ' ' || rsmb_12.NAME_ORG3 || ' ' || rsmb_12.NAME_ORG4 END AS regionSiteManagerName,
  pmg_13.PARTNER AS productionManager,
  CASE WHEN pmgb_14.TYPE = 1 THEN pmgb_14.NAME_FIRST || ' ' || pmgb_14.NAME_LAST ELSE pmgb_14.NAME_ORG1 || ' ' || pmgb_14.NAME_ORG2 || ' ' || pmgb_14.NAME_ORG3 || ' ' || pmgb_14.NAME_ORG4 END AS productionManagerName,
  smg_15.PARTNER AS siteManager,
  CASE WHEN smgb_16.TYPE = 1 THEN smgb_16.NAME_FIRST || ' ' || smgb_16.NAME_LAST ELSE smgb_16.NAME_ORG1 || ' ' || smgb_16.NAME_ORG2 || ' ' || smgb_16.NAME_ORG3 || ' ' || smgb_16.NAME_ORG4 END AS siteManagerName,
  '' AS landlordName
FROM (((((((((((((((((VIBDAO AS site_0 INNER JOIN VIBDOBJASS AS relation_1 ON relation_1.OBJNRSRC = site_0.OBJNR AND relation_1.OBJASSTYPE = '61') INNER JOIN IFLOT AS details_2 ON details_2.OBJNR = relation_1.OBJNRTRG) INNER JOIN ILOA AS emplaz_3 ON emplaz_3.ILOAN = details_2.ILOAN) LEFT JOIN VZOBJECT AS adrcrel_4 ON adrcrel_4.ADROBJNR = site_0.INTRENO AND adrcrel_4.ADROBJTYP = 'VI' AND adrcrel_4.OBTYP = '56') LEFT JOIN VIBPOBJREL AS pzr_5 ON pzr_5.INTRENO = site_0.INTRENO AND pzr_5.ROLE = 'ZSM001' AND pzr_5.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD') AND pzr_5.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')) LEFT JOIN BUT000 AS pzrb_6 ON pzrb_6.PARTNER = pzr_5.PARTNER) LEFT JOIN VIBPOBJREL AS szr_7 ON szr_7.INTRENO = site_0.INTRENO AND szr_7.ROLE = 'ZSM002' AND szr_7.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD') AND szr_7.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')) LEFT JOIN BUT000 AS szrb_8 ON szrb_8.PARTNER = szr_7.PARTNER) LEFT JOIN VIBPOBJREL AS prm_9 ON prm_9.INTRENO = site_0.INTRENO AND prm_9.ROLE = 'ZSM003' AND prm_9.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD') AND prm_9.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')) LEFT JOIN BUT000 AS prmb_10 ON prmb_10.PARTNER = prm_9.PARTNER) LEFT JOIN VIBPOBJREL AS rsm_11 ON rsm_11.INTRENO = site_0.INTRENO AND rsm_11.ROLE = 'ZSM004' AND rsm_11.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD') AND rsm_11.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')) LEFT JOIN BUT000 AS rsmb_12 ON rsmb_12.PARTNER = rsm_11.PARTNER) LEFT JOIN VIBPOBJREL AS pmg_13 ON pmg_13.INTRENO = site_0.INTRENO AND pmg_13.ROLE = 'ZSM005' AND pmg_13.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD') AND pmg_13.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')) LEFT JOIN BUT000 AS pmgb_14 ON pmgb_14.PARTNER = pmg_13.PARTNER) LEFT JOIN VIBPOBJREL AS smg_15 ON smg_15.INTRENO = site_0.INTRENO AND smg_15.ROLE = 'ZSM006' AND smg_15.VALIDFROM <= to_varchar(CURRENT_DATE, 'YYYYMMDD') AND smg_15.VALIDTO >= to_varchar(CURRENT_DATE, 'YYYYMMDD')) LEFT JOIN BUT000 AS smgb_16 ON smgb_16.PARTNER = smg_15.PARTNER) LEFT JOIN ADRC AS address_17 ON address_17.ADDRNUMBER = adrcrel_4.ADRNR);

CREATE VIEW LANDLORD_BY_SITE(IN p_siteId NVARCHAR(5000)) AS SELECT
  __select_2___0.AOID,
  __select_2___0.AOTYPE,
  __select_2___0.RECNNR,
  __select_2___0.BUKRS,
  __select_2___0.PARTNER,
  __select_2___0.ROLE,
  __select_2___0.TYPE,
  __select_2___0.VALID_FROM,
  __select_2___0.VALID_TO,
  __select_2___0.fullName,
  __select_2___0.rn
FROM (SELECT
    site_1.AOID,
    site_1.AOTYPE,
    contract_5.RECNNR,
    contract_5.BUKRS,
    partner_7.PARTNER,
    contrels_6.ROLE,
    partner_7.TYPE,
    partner_7.VALID_FROM,
    partner_7.VALID_TO,
    CASE WHEN partner_7.TYPE = 1 THEN partner_7.NAME_FIRST || ' ' || partner_7.NAME_LAST ELSE partner_7.NAME_ORG1 || ' ' || partner_7.NAME_ORG2 || ' ' || partner_7.NAME_ORG3 || ' ' || partner_7.NAME_ORG4 END AS fullName,
    row_number() OVER (PARTITION BY contract_5.RECNNR, contract_5.BUKRS, partner_7.PARTNER ORDER BY CASE contrels_6.ROLE WHEN 'ZRE011' THEN 1 WHEN 'ZRE001' THEN 2 WHEN 'ZRE006' THEN 3 END) AS rn
  FROM ((((((VIBDAO AS site_1 INNER JOIN VIBDOBJREL AS siterels_2 ON siterels_2.INTRENOSRC = site_1.INTRENO AND site_1.AOID = :P_SITEID) INNER JOIN VIBDBE AS ue_3 ON ue_3.INTRENO = siterels_2.INTRENOTRG) INNER JOIN VIBDOBJASS AS ueass_4 ON ueass_4.OBJNRTRG = ue_3.OBJNR) INNER JOIN VICNCN AS contract_5 ON contract_5.OBJNR = ueass_4.OBJNRSRC AND contract_5.RECNTYPE = '0011') INNER JOIN VIBPOBJREL AS contrels_6 ON contrels_6.INTRENO = contract_5.INTRENO AND contrels_6.ROLE IN ('ZRE001', 'ZRE011', 'ZRE006')) INNER JOIN BUT000 AS partner_7 ON partner_7.PARTNER = contrels_6.PARTNER AND (partner_7.VALID_FROM IS NULL OR partner_7.VALID_FROM <= to_number(to_varchar(current_timestamp, 'YYYYMMDDHHMMSS'))) AND (partner_7.VALID_TO IS NULL OR partner_7.VALID_TO >= to_number(to_varchar(current_timestamp, 'YYYYMMDDHHMMSS'))))) AS __select_2___0
WHERE __select_2___0.rn = 1;

CREATE VIEW REGIONS AS SELECT DISTINCT
  T005U_0.LAND1 AS country,
  T005U_0.BLAND AS code,
  T005U_0.BEZEI AS description
FROM T005U AS T005U_0
WHERE T005U_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW CELLNEX_ZONES AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'UOPE' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW ZONES AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'ZONE' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW INFRA_ORIGINS AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'ORIG' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW INFRA_OWNERSHIPS AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'OWSH' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW INFRA_STATUS AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'ICST' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW MARKETABLES AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'COME' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW ABF_ZONES AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'ABFZ' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW MANAGING_COMPANIES AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'TITU' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW CELLNEX_PROJECTS AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'PROY' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW EXPLOITEDS AS SELECT
  ZRECOAVALUEST_0.VALUE AS code,
  ZRECOAVALUEST_0.XVALUE AS description
FROM ZRECOAVALUEST AS ZRECOAVALUEST_0
WHERE ZRECOAVALUEST_0.VALUETYPE = 'EXSI' AND ZRECOAVALUEST_0.SPRAS IN (SELECT
    ECC_LANGUAGES_1.SPRAS
  FROM ECC_LANGUAGES AS ECC_LANGUAGES_1
  WHERE ECC_LANGUAGES_1.LAISO = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW CUSTOMERS(IN p_siteId NVARCHAR(30)) AS SELECT DISTINCT
  site_0.AOID AS siteId,
  CASE WHEN customer_6.PARTNER IS NOT NULL AND customer_6.PARTNER != '' THEN customer_6.PARTNER ELSE oldcustomer_8.PARTNER END AS customerId,
  site_0.XAO AS siteName,
  CASE WHEN customer_6.PARTNER IS NOT NULL AND customer_6.PARTNER != '' THEN customer_6.NAME_ORG1 || ' ' || customer_6.NAME_ORG2 ELSE oldcustomer_8.NAME_ORG1 || ' ' || oldcustomer_8.NAME_ORG2 END AS customerName,
  alias_9.ZALIAS AS alias,
  alias_9.ZALIASNAME AS aliasName,
  alias_9.ZALIASSERV AS aliasServ,
  alias_9.ZALIASOTHER AS aliasOther,
  alias_9.PARTNZONE AS aliasClientArea,
  alias_9.ZALIASKEY AS aliasKey
FROM (((((((((VIBDAO AS site_0 INNER JOIN VIBDOBJASS AS relation_1 ON relation_1.OBJNRSRC = site_0.OBJNR AND relation_1.OBJASSTYPE = '61' AND site_0.AOID = :P_SITEID) INNER JOIN IFLOT AS details_2 ON details_2.OBJNR = relation_1.OBJNRTRG) INNER JOIN ZPMSERVLOC AS locserv_3 ON locserv_3.ZZSITE = details_2.TPLNR AND locserv_3.ZZMARKDEL != TRUE) INNER JOIN ZPMSITESERV AS service_4 ON service_4.ZZIDINTERN = locserv_3.ZZIDINTERN) INNER JOIN ZPMSERVCHNGS AS srvstatus_5 ON srvstatus_5.ZZIDINTERN = locserv_3.ZZIDINTERN AND srvstatus_5.ZZSTATUS_OP = 'OP30' AND srvstatus_5.ACTIVE = 'X') LEFT JOIN BUT000 AS customer_6 ON customer_6.PARTNER = service_4.ZZBUSINESSPRTNR) LEFT JOIN CVI_CUST_LINK AS cv_7 ON cv_7.CUSTOMER = service_4.ZZCUSTOMER) LEFT JOIN BUT000 AS oldcustomer_8 ON oldcustomer_8.PARTNER_GUID = cv_7.PARTNER_GUID) LEFT JOIN ZRETOAALIAS AS alias_9 ON alias_9.INTRENO = site_0.INTRENO AND (alias_9.PARTNER = customer_6.PARTNER OR alias_9.PARTNER = oldcustomer_8.PARTNER));

CREATE VIEW REQUEST_CUSTOMERS(IN p_requestId NVARCHAR(36)) AS SELECT DISTINCT
  request_0.REQUEST_ID AS requestId,
  site_1.AOID AS siteId,
  CASE WHEN customer_7.PARTNER IS NOT NULL AND customer_7.PARTNER != '' THEN customer_7.PARTNER ELSE oldcustomer_9.PARTNER END AS customerId,
  site_1.XAO AS siteName,
  CASE WHEN customer_7.PARTNER IS NOT NULL AND customer_7.PARTNER != '' THEN customer_7.NAME_ORG1 || ' ' || customer_7.NAME_ORG2 ELSE oldcustomer_9.NAME_ORG1 || ' ' || oldcustomer_9.NAME_ORG2 END AS customerName,
  alias_11.ZALIAS AS alias,
  alias_11.ZALIASNAME AS aliasName,
  alias_11.ZALIASSERV AS aliasServ,
  alias_11.ZALIASOTHER AS aliasOther,
  alias_11.PARTNZONE AS aliasClientArea,
  alias_11.ZALIASKEY AS aliasKey,
  CASE WHEN impacted_10.customer IS NOT NULL THEN TRUE ELSE FALSE END AS impacted
FROM (((((((((((REQUEST_HEAD AS request_0 INNER JOIN VIBDAO AS site_1 ON site_1.AOID = request_0.SITE_ID AND request_0.REQUEST_ID = :P_REQUESTID) INNER JOIN VIBDOBJASS AS relation_2 ON relation_2.OBJNRSRC = site_1.OBJNR AND relation_2.OBJASSTYPE = '61') INNER JOIN IFLOT AS details_3 ON details_3.OBJNR = relation_2.OBJNRTRG) INNER JOIN ZPMSERVLOC AS locserv_4 ON locserv_4.ZZSITE = details_3.TPLNR AND locserv_4.ZZMARKDEL != TRUE) INNER JOIN ZPMSITESERV AS service_5 ON service_5.ZZIDINTERN = locserv_4.ZZIDINTERN) INNER JOIN ZPMSERVCHNGS AS srvstatus_6 ON srvstatus_6.ZZIDINTERN = locserv_4.ZZIDINTERN AND srvstatus_6.ZZSTATUS_OP = 'OP30' AND srvstatus_6.ACTIVE = 'X') LEFT JOIN BUT000 AS customer_7 ON customer_7.PARTNER = service_5.ZZBUSINESSPRTNR) LEFT JOIN CVI_CUST_LINK AS cv_8 ON cv_8.CUSTOMER = service_5.ZZCUSTOMER) LEFT JOIN BUT000 AS oldcustomer_9 ON oldcustomer_9.PARTNER_GUID = cv_8.PARTNER_GUID) LEFT JOIN REQUEST_IMPACTED_CUSTOMERS AS impacted_10 ON impacted_10.requestId = request_0.REQUEST_ID AND (impacted_10.customer = customer_7.PARTNER OR impacted_10.customer = oldcustomer_9.PARTNER) AND (impacted_10.deleted = FALSE OR impacted_10.deleted IS NULL)) LEFT JOIN ZRETOAALIAS AS alias_11 ON alias_11.INTRENO = site_1.INTRENO AND (alias_11.PARTNER = customer_7.PARTNER OR alias_11.PARTNER = oldcustomer_9.PARTNER));

CREATE VIEW PREFERRED_PROVIDERS AS SELECT DISTINCT
  CACHE_R3_ENTITIES_0.ENTITY_ID AS code,
  CACHE_R3_ENTITIES_0.ENTITY_NAME AS name
FROM CACHE_R3_ENTITIES AS CACHE_R3_ENTITIES_0
WHERE CACHE_R3_ENTITIES_0.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND CACHE_R3_ENTITIES_0.USER_ID = SESSION_CONTEXT('APPLICATIONUSER');

CREATE VIEW USERS(IN p_country NVARCHAR(5000)) AS SELECT
  USERS_0.USER_ID AS userId,
  USERS_0.USER_NAME AS userName,
  USERS_0.EMAIL AS email,
  USERS_0.TELEPHONE AS telephone,
  COUNTRIES_1.COUNTRY_ID AS country,
  ROLES_3.IAS_GROUP AS iasGroup,
  '' AS requestId,
  '' AS blockId
FROM (((US_USERS_IAS AS USERS_0 INNER JOIN US_COUNTRIES AS COUNTRIES_1 ON COUNTRIES_1.USER_ID = USERS_0.USER_ID AND COUNTRIES_1.COUNTRY_ID = :P_COUNTRY) INNER JOIN US_BUKS AS BUKS_2 ON BUKS_2.USER_ID = USERS_0.USER_ID) INNER JOIN US_ROLES_AGR AS ROLES_3 ON ROLES_3.USER_ID = USERS_0.USER_ID);

CREATE VIEW BLOCK_PHASE_REQUEST_DOCUMENT_INSTANCE(IN p_registerId NVARCHAR(36)) AS SELECT
  BH_3.BLOCK_ID,
  BH_3.MASTER_BLOCK_ID,
  PH_2.PHASE_ID,
  PH_2.MASTER_PHASE_ID,
  RH_0.REQUEST_ID,
  RH_0.REQUEST_TYPE,
  RH_0.PROCESS_ID,
  RH_0.COUNTRY_ID,
  RH_0.SITE_ID,
  P_1.PROCESS_ID_PK,
  DPB_4.GENERIC_TYPE_ID
FROM (((((REQUEST_HEAD AS RH_0 INNER JOIN PROCESS AS P_1 ON P_1.ID_PK = RH_0.PROCESS_ID) INNER JOIN PHASE_HEAD AS PH_2 ON PH_2.REQUEST_ID = RH_0.REQUEST_ID) INNER JOIN BLOCK_HEAD AS BH_3 ON BH_3.PHASE_ID = PH_2.PHASE_ID) INNER JOIN DOCUMENTS_PER_BLOCK AS DPB_4 ON DPB_4.BLOCK_ID = BH_3.BLOCK_ID) INNER JOIN INSTANCES_PER_DOCUMENT AS IPD_5 ON IPD_5.INSTANCE_ID = DPB_4.REGISTER_ID)
WHERE IPD_5.REGISTER_ID = :P_REGISTERID;

CREATE VIEW BLOCK_PHASE_REQUEST_DOCUMENT(IN p_registerId NVARCHAR(36)) AS SELECT
  BH_3.BLOCK_ID,
  BH_3.MASTER_BLOCK_ID,
  PH_2.PHASE_ID,
  PH_2.MASTER_PHASE_ID,
  RH_0.REQUEST_ID,
  RH_0.REQUEST_TYPE,
  RH_0.PROCESS_ID,
  RH_0.COUNTRY_ID,
  RH_0.SITE_ID,
  P_1.PROCESS_ID_PK,
  DPB_4.GENERIC_TYPE_ID
FROM ((((REQUEST_HEAD AS RH_0 INNER JOIN PROCESS AS P_1 ON P_1.ID_PK = RH_0.PROCESS_ID) INNER JOIN PHASE_HEAD AS PH_2 ON PH_2.REQUEST_ID = RH_0.REQUEST_ID) INNER JOIN BLOCK_HEAD AS BH_3 ON BH_3.PHASE_ID = PH_2.PHASE_ID) INNER JOIN DOCUMENTS_PER_BLOCK AS DPB_4 ON DPB_4.BLOCK_ID = BH_3.BLOCK_ID)
WHERE DPB_4.REGISTER_ID = :P_REGISTERID;

CREATE VIEW AUX_PROJECT_TYPES AS SELECT
  PROJECT_TYPES_0.code AS code,
  coalesce(l_1.name, PROJECT_TYPES_0.name) AS name,
  PROJECT_TYPES_0.country
FROM (PROJECT_TYPES AS PROJECT_TYPES_0 LEFT JOIN PROJECT_TYPES_texts AS l_1 ON l_1.code = PROJECT_TYPES_0.code AND l_1.locale = SESSION_CONTEXT('LOCALE'));

CREATE VIEW CONFIRM_BUTTONS(IN p_requestId NVARCHAR(36), IN p_master_phase_id NVARCHAR(5000), IN p_master_block_id NVARCHAR(5000)) AS SELECT
  bp_3.BTTN_INV_UPDATED,
  bp_3.BTTN_SERV_UPDATED,
  bp_3.BTTN_DOC_UPDATED
FROM ((((REQUEST_HEAD AS rh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.REQUEST_ID = :P_REQUESTID AND ph_1.MASTER_PHASE_ID = :P_MASTER_PHASE_ID) INNER JOIN BLOCK_HEAD AS bh_2 ON bh_2.PHASE_ID = ph_1.PHASE_ID AND bh_2.MASTER_BLOCK_ID = :P_MASTER_BLOCK_ID) INNER JOIN BLOCKS_PROVISIONING AS bp_3 ON bp_3.BLOCK_ID = bh_2.BLOCK_ID) INNER JOIN PROCESS AS p_4 ON p_4.ID_PK = rh_0.PROCESS_ID);

CREATE VIEW PHASES_PER_PROCESS AS SELECT
  pr_0.ID_PK AS processFlowId,
  p_1.PHASE_ID AS phaseProcessFlowId,
  p_1."ORDER" AS phaseOrder,
  mp_2.PHASE_NAME AS phaseName
FROM ((PROCESS AS pr_0 INNER JOIN PHASE AS p_1 ON p_1.ID_PK = pr_0.ID_PK) INNER JOIN MASTER_PHASE AS mp_2 ON mp_2.PROCESS_ID_PK = pr_0.PROCESS_ID_PK AND mp_2.PHASE_ID_PK = p_1.PHASE_ID AND mp_2.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE')))
ORDER BY p_1."ORDER";

CREATE VIEW BLOCKS_PER_PROCESS AS SELECT
  pr_0.ID_PK AS processFlowId,
  b_1.PHASE_ID_PK AS phaseProcessFlowId,
  b_1.BLOCK_ID_PK AS blockProcessFlowId,
  b_1."ORDER" AS blockOrder,
  mb_2.BLOCK_NAME AS blockName,
  b_1.IS_CANDIDATE AS hasCandidate
FROM ((PROCESS AS pr_0 INNER JOIN BLOCK AS b_1 ON b_1.ID_PK = pr_0.ID_PK) INNER JOIN MASTER_BLOCK AS mb_2 ON mb_2.PROCESS_ID_PK = pr_0.PROCESS_ID_PK AND mb_2.PHASE_ID_PK = b_1.PHASE_ID_PK AND mb_2.BLOCK_ID_PK = b_1.BLOCK_ID_PK AND mb_2.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE')))
ORDER BY b_1."ORDER";

CREATE VIEW INTERNAL_PHASES AS SELECT DISTINCT
  PHASE_1.PHASE_ID AS code,
  MASTER_PHASE_2.PHASE_NAME AS name,
  PHASE_1."ORDER"
FROM ((PROCESS AS PROCESS_0 INNER JOIN PHASE AS PHASE_1 ON PHASE_1.PROCESS_ID_PK = PROCESS_0.PROCESS_ID_PK AND PROCESS_0.PROCESS_ID_PK = 'int' AND PROCESS_0.PROGRAM = 'DEF' AND PHASE_1.ID_PK = PROCESS_0.ID_PK) INNER JOIN MASTER_PHASE AS MASTER_PHASE_2 ON MASTER_PHASE_2.PROCESS_ID_PK = PHASE_1.PROCESS_ID_PK AND MASTER_PHASE_2.PHASE_ID_PK = PHASE_1.PHASE_ID AND MASTER_PHASE_2.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE')))
ORDER BY PHASE_1."ORDER";

CREATE VIEW INTERNAL_BLOCKS AS SELECT DISTINCT
  MASTER_BLOCK_3.PHASE_ID_PK AS phaseId,
  MASTER_BLOCK_3.BLOCK_ID_PK AS code,
  MASTER_BLOCK_3.BLOCK_NAME AS name,
  PHASE_1."ORDER" AS phaseOrder,
  BLOCK_2."ORDER" AS blockOrder
FROM (((PROCESS AS PROCESS_0 INNER JOIN PHASE AS PHASE_1 ON PHASE_1.PROCESS_ID_PK = PROCESS_0.PROCESS_ID_PK AND PROCESS_0.PROCESS_ID_PK = 'int' AND PROCESS_0.PROGRAM = 'DEF' AND PHASE_1.ID_PK = PROCESS_0.ID_PK) INNER JOIN BLOCK AS BLOCK_2 ON BLOCK_2.PROCESS_ID_PK = PHASE_1.PROCESS_ID_PK AND BLOCK_2.ID_PK = PHASE_1.ID_PK AND BLOCK_2.PHASE_ID_PK = PHASE_1.PHASE_ID) INNER JOIN MASTER_BLOCK AS MASTER_BLOCK_3 ON MASTER_BLOCK_3.PROCESS_ID_PK = BLOCK_2.PROCESS_ID_PK AND MASTER_BLOCK_3.PHASE_ID_PK = BLOCK_2.PHASE_ID_PK AND MASTER_BLOCK_3.BLOCK_ID_PK = BLOCK_2.BLOCK_ID_PK AND MASTER_BLOCK_3.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE')))
ORDER BY PHASE_1."ORDER", BLOCK_2."ORDER";

CREATE VIEW requestProcess AS SELECT
  pr_0.ID_PK,
  pr_0.PROCESS_ID_PK,
  ph_1.PHASE_ID,
  ph_1."ORDER" AS PHASE_ORDER,
  ph_1.NOT_REQUIRED,
  ph_1.ALWAYS_ON,
  ph_1.PASS_OVER,
  ph_1.SKIP_RULE,
  ph_1.CLOSE_BLOCK,
  ph_1.HAS_CANDIDATES,
  bl_2.BLOCK_ID_PK,
  bl_2.VISIBLE_ON,
  bl_2.MANDATORY,
  bl_2.ACTIVE,
  bl_2.ROLE_ID,
  bl_2.HASRESPONSIBLE,
  bl_2.APPROVER_TYPE,
  bl_2.SUBCONTRACTOR_TYPE,
  bl_2.IS_CANDIDATE
FROM ((PROCESS AS pr_0 INNER JOIN PHASE AS ph_1 ON ph_1.ID_PK = pr_0.ID_PK) INNER JOIN BLOCK AS bl_2 ON bl_2.ID_PK = ph_1.ID_PK AND bl_2.PHASE_ID_PK = ph_1.PHASE_ID)
ORDER BY ph_1."ORDER", bl_2."ORDER";

CREATE VIEW LAST_ACTIVE_PHASES(IN p_requestId NVARCHAR(36)) AS SELECT
  max(p_2."ORDER") AS LAST_PHASE
FROM ((REQUEST_HEAD AS rh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.REQUEST_ID = rh_0.REQUEST_ID AND ph_1.REQUEST_ID = :P_REQUESTID AND (ph_1.PHASE_STATUS = 7 OR ph_1.PHASE_STATUS = 3)) INNER JOIN PHASE AS p_2 ON p_2.PHASE_ID = ph_1.MASTER_PHASE_ID AND p_2.ID_PK = rh_0.PROCESS_ID);

CREATE VIEW FIRST_INPROGRESS_PHASE(IN p_requestId NVARCHAR(36)) AS SELECT
  ph_1.MASTER_PHASE_ID,
  p_2."ORDER"
FROM ((REQUEST_HEAD AS rh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.REQUEST_ID = rh_0.REQUEST_ID AND ph_1.REQUEST_ID = :P_REQUESTID AND (ph_1.PHASE_STATUS = 7)) INNER JOIN PHASE AS p_2 ON p_2.PHASE_ID = ph_1.MASTER_PHASE_ID AND p_2.ID_PK = rh_0.PROCESS_ID)
ORDER BY p_2."ORDER"
LIMIT 1;

CREATE VIEW LAST_ACTIVE_PHASE_BLOCK AS SELECT
  __select_2___0.REQUEST_ID,
  __select_2___0.lastPhase,
  __select_2___0.lastPhaseName,
  __select_2___0.lastBlock,
  __select_2___0.lastBlockName
FROM (SELECT
    rh_1.REQUEST_ID,
    ph_2.MASTER_PHASE_ID AS lastPhase,
    bh_5.MASTER_BLOCK_ID AS lastBlock,
    mp_4.PHASE_NAME AS lastPhaseName,
    mb_7.BLOCK_NAME AS lastBlockName,
    p_3."ORDER" AS phaseOrder,
    b_6."ORDER" AS blockOrder,
    row_number() OVER (PARTITION BY rh_1.REQUEST_ID ORDER BY p_3."ORDER" ASC, b_6."ORDER" ASC) AS rn
  FROM ((((((REQUEST_HEAD AS rh_1 INNER JOIN PHASE_HEAD AS ph_2 ON ph_2.REQUEST_ID = rh_1.REQUEST_ID AND ph_2.PHASE_STATUS = 7 AND rh_1.REQUEST_TYPE = 40) INNER JOIN PHASE AS p_3 ON p_3.PHASE_ID = ph_2.MASTER_PHASE_ID AND p_3.ID_PK = rh_1.PROCESS_ID) LEFT JOIN MASTER_PHASE AS mp_4 ON mp_4.PROCESS_ID_PK = p_3.PROCESS_ID_PK AND mp_4.PHASE_ID_PK = p_3.PHASE_ID AND mp_4.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCK_HEAD AS bh_5 ON bh_5.PHASE_ID = ph_2.PHASE_ID AND bh_5.BLOCK_STATUS = 7) INNER JOIN BLOCK AS b_6 ON p_3.PHASE_ID = ph_2.MASTER_PHASE_ID AND b_6.BLOCK_ID_PK = bh_5.MASTER_BLOCK_ID AND b_6.ID_PK = rh_1.PROCESS_ID) LEFT JOIN MASTER_BLOCK AS mb_7 ON mb_7.PROCESS_ID_PK = b_6.PROCESS_ID_PK AND mb_7.PHASE_ID_PK = b_6.PHASE_ID_PK AND mb_7.BLOCK_ID_PK = b_6.BLOCK_ID_PK AND mb_7.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE')))) AS __select_2___0
WHERE __select_2___0.rn = 1;

CREATE VIEW SINGLE_REQUEST_PROCESS(IN p_requestId NVARCHAR(36)) AS SELECT
  rh_0.REQUEST_ID,
  rh_0.PROCESS_ID,
  rh_0.REQUEST_CODE,
  pr_1.ID_PK,
  pr_1.PROCESS_ID_PK,
  ph_2.PHASE_ID,
  ph_2."ORDER" AS PHASE_ORDER,
  ph_2.NOT_REQUIRED,
  ph_2.ALWAYS_ON,
  ph_2.PASS_OVER,
  ph_2.SKIP_RULE,
  ph_2.CLOSE_BLOCK,
  ph_2.HAS_CANDIDATES,
  bl_3.BLOCK_ID_PK,
  bl_3.VISIBLE_ON,
  bl_3.MANDATORY,
  bl_3.ACTIVE,
  bl_3.ROLE_ID,
  bl_3.HASRESPONSIBLE,
  bl_3.APPROVER_TYPE,
  bl_3.SUBCONTRACTOR_TYPE,
  bl_3.IS_CANDIDATE
FROM (((REQUEST_HEAD AS rh_0 INNER JOIN PROCESS AS pr_1 ON pr_1.ID_PK = rh_0.PROCESS_ID) INNER JOIN PHASE AS ph_2 ON ph_2.ID_PK = rh_0.PROCESS_ID) INNER JOIN BLOCK AS bl_3 ON bl_3.ID_PK = rh_0.PROCESS_ID AND bl_3.PHASE_ID_PK = ph_2.PHASE_ID)
WHERE rh_0.REQUEST_ID = :P_REQUESTID
ORDER BY ph_2."ORDER", bl_3."ORDER";

CREATE VIEW BLOCK_SUPPORT_DOCUMENTS(IN p_blockId NVARCHAR(36)) AS SELECT
  dd_3.REGISTER_ID AS ID,
  dd_3.BLOCK_ID AS blockId,
  dd_3.INSTANCE_ID AS instanceId,
  dd_3.REQUEST_ID AS requestId,
  dd_3.REQUEST_CODE AS requestCode,
  dd_3.TYPE_ID AS docType,
  dd_3.STEP_ID AS stepId,
  dd_3.FIELD AS field,
  dd_3.DOCUMENT_NAME AS documentName,
  dd_3.DOCUMENT_VERSION AS version,
  dd_3.DOCUMENT_URL AS fileUrl,
  dd_3.USER_DOC AS "USER",
  dd_3.CREATION_DATE_DOC AS documentCreationDate,
  dd_3.DOCUMENT_SUBTYPE AS subType,
  dd_3.DOCUMENT_SUBTYPE_LVL2 AS subTypeLvl2,
  dd_3.CREATEDAT AS createdAt,
  dd_3.CREATEDBY AS createdBy,
  dd_3.DELETED AS deleted,
  dd_3.DELETED_BY AS deletedBy,
  dd_3.MODIFIEDAT AS modifiedAt,
  dd_3.MODIFIEDBY AS modifiedBy,
  dd_3.DOCUMENT_ID AS documentId,
  dd_3.OT_DOCUMENT_ID AS OTDocumentId,
  dd_3.BLOCK_NAME AS blockName,
  dd_3.PHASE_NAME AS phaseName,
  dd_3.FINAL_DOCUMENT AS finalDocument,
  dd_3.MEDIA_TYPE AS mediaType,
  dd_3.WORK_ID AS workId,
  CASE WHEN bh_0.BLOCK_STATUS = 7 THEN TRUE ELSE FALSE END AS canDelete,
  NULL AS content
FROM ((((BLOCK_HEAD AS bh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.PHASE_ID = bh_0.PHASE_ID AND bh_0.BLOCK_ID = :P_BLOCKID) INNER JOIN REQUEST_HEAD AS rh_2 ON rh_2.REQUEST_ID = ph_1.REQUEST_ID) INNER JOIN WF_DETAIL_DOCUMENTS AS dd_3 ON dd_3.BLOCK_ID = bh_0.BLOCK_ID) INNER JOIN DOCUMENT_FLOWS AS df_4 ON df_4.documentId = dd_3.DOCUMENT_ID AND df_4.countryId = rh_2.COUNTRY_ID AND df_4.enableAttachments = TRUE);

CREATE VIEW DOCUMENT_FLOWS_PER_REQUEST_DOCUMENT_ID_VH AS SELECT DISTINCT
  rh_0.REQUEST_ID AS ID,
  dfb_3.documentId,
  df_4.documentName
FROM ((((REQUEST_HEAD AS rh_0 INNER JOIN DOCUMENT_FLOWS_PER_PROCESS AS dfp_1 ON dfp_1.processId = rh_0.PROCESS_ID) INNER JOIN DOCUMENT_FLOWS_PER_CONFIG AS dfc_2 ON dfc_2.ID = dfp_1.Configuration_ID) INNER JOIN DOCUMENT_FLOWS_PER_BLOCK AS dfb_3 ON dfb_3.DocumentFlowsPerConfig_ID = dfc_2.ID) INNER JOIN DOCUMENT_FLOWS AS df_4 ON df_4.documentId = dfb_3.documentId);

CREATE VIEW DOCUMENTS_FLOWS_PER_BLOCK_DOCUMENT_ID_VH AS SELECT DISTINCT
  dfb_5.documentId,
  dfc_4.ID,
  dfb_5.phase,
  dfb_5.block,
  bh_0.BLOCK_ID,
  df_6.documentName
FROM ((((((BLOCK_HEAD AS bh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.PHASE_ID = bh_0.PHASE_ID AND bh_0.BLOCK_ID = bh_0.BLOCK_ID) INNER JOIN REQUEST_HEAD AS rh_2 ON rh_2.REQUEST_ID = ph_1.REQUEST_ID) INNER JOIN DOCUMENT_FLOWS_PER_PROCESS AS dfp_3 ON dfp_3.processId = rh_2.PROCESS_ID) INNER JOIN DOCUMENT_FLOWS_PER_CONFIG AS dfc_4 ON dfc_4.ID = dfp_3.Configuration_ID) INNER JOIN DOCUMENT_FLOWS_PER_BLOCK AS dfb_5 ON dfb_5.DocumentFlowsPerConfig_ID = dfc_4.ID AND dfb_5.block = bh_0.MASTER_BLOCK_ID AND dfb_5.phase = ph_1.MASTER_PHASE_ID) INNER JOIN DOCUMENT_FLOWS AS df_6 ON df_6.documentId = dfb_5.documentId);

CREATE VIEW DT_LINKED_GLOBAL_CONTEXT_PER_TASK AS SELECT DISTINCT
  dlr_1.CHILD_REQUEST_ID AS childRequestCode,
  dlr_1.PARENT_INSTANCE_ID AS jointProjectId
FROM (INSTANCES_PER_DOCUMENT AS ipd_0 INNER JOIN DT_LINKED_REQUEST AS dlr_1 ON ipd_0.DOC_PB_ID = dlr_1.PARENT_INSTANCE_ID AND (dlr_1.DELETED IS NULL OR dlr_1.DELETED = FALSE) AND dlr_1.ASSOCIATION_TYPE = 'JOINT_PROJECTS');

CREATE VIEW DT_LINKED_GLOBAL_CONTEXT_PER_INSTANCE AS SELECT DISTINCT
  dlr_2.CHILD_REQUEST_ID AS childRequestCode,
  ipd_0.INSTANCE_ID AS dpbId
FROM ((INSTANCES_PER_DOCUMENT AS ipd_0 INNER JOIN DOCUMENTS_PER_BLOCK AS dpb_1 ON dpb_1.REGISTER_ID = ipd_0.INSTANCE_ID) INNER JOIN DT_LINKED_REQUEST AS dlr_2 ON dpb_1.PERMIT_ID = dlr_2.PARENT_INSTANCE_ID AND (dlr_2.DELETED IS NULL OR dlr_2.DELETED = FALSE) AND dlr_2.ASSOCIATION_TYPE = 'JOINT_PROJECTS');

CREATE VIEW DOCUMENTS_FLOWS_PER_PROCESS_VH AS SELECT
  dfb_2.documentId,
  dfc_1.ID,
  df_3.documentName
FROM (((DOCUMENT_FLOWS_PER_PROCESS AS dfp_0 INNER JOIN DOCUMENT_FLOWS_PER_CONFIG AS dfc_1 ON dfc_1.ID = dfp_0.Configuration_ID) INNER JOIN DOCUMENT_FLOWS_PER_BLOCK AS dfb_2 ON dfb_2.DocumentFlowsPerConfig_ID = dfc_1.ID) INNER JOIN DOCUMENT_FLOWS AS df_3 ON df_3.documentId = dfb_2.documentId);

CREATE VIEW DOCUMENTS_FLOWS_PER_BLOCK_PER_PROCESS_VH AS SELECT
  dfb_2.documentId,
  dfc_1.ID,
  dfb_2.phase,
  dfb_2.block,
  df_3.documentName
FROM (((DOCUMENT_FLOWS_PER_PROCESS AS dfp_0 INNER JOIN DOCUMENT_FLOWS_PER_CONFIG AS dfc_1 ON dfc_1.ID = dfp_0.Configuration_ID) INNER JOIN DOCUMENT_FLOWS_PER_BLOCK AS dfb_2 ON dfb_2.DocumentFlowsPerConfig_ID = dfc_1.ID) INNER JOIN DOCUMENT_FLOWS AS df_3 ON df_3.documentId = dfb_2.documentId);

CREATE VIEW BLOCKS_PER_PROCESS_CONFIG AS SELECT
  dfb_0.ID AS ID,
  b_3.PHASE_ID_PK AS phaseProcessFlowId,
  b_3.BLOCK_ID_PK AS blockProcessFlowId,
  b_3."ORDER" AS blockOrder,
  mb_4.BLOCK_NAME AS blockName
FROM ((((DOCUMENT_FLOWS_PER_BLOCK AS dfb_0 INNER JOIN DOCUMENT_FLOWS_PER_PROCESS AS dfp_1 ON dfp_1.Configuration_ID = dfb_0.DocumentFlowsPerConfig_ID) INNER JOIN PROCESS AS pr_2 ON pr_2.ID_PK = dfp_1.processId) INNER JOIN BLOCK AS b_3 ON b_3.ID_PK = pr_2.ID_PK) INNER JOIN MASTER_BLOCK AS mb_4 ON mb_4.PROCESS_ID_PK = pr_2.PROCESS_ID_PK AND mb_4.PHASE_ID_PK = b_3.PHASE_ID_PK AND mb_4.BLOCK_ID_PK = b_3.BLOCK_ID_PK AND mb_4.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE')))
ORDER BY b_3."ORDER";

CREATE VIEW PHASES_PER_PROCESS_CONFIG AS SELECT
  dfb_0.ID AS ID,
  pr_2.PROCESS_ID_PK,
  p_3.PHASE_ID AS phaseProcessFlowId,
  p_3."ORDER" AS phaseOrder,
  mp_4.PHASE_NAME AS phaseName
FROM ((((DOCUMENT_FLOWS_PER_BLOCK AS dfb_0 INNER JOIN DOCUMENT_FLOWS_PER_PROCESS AS dfp_1 ON dfp_1.Configuration_ID = dfb_0.DocumentFlowsPerConfig_ID) INNER JOIN PROCESS AS pr_2 ON pr_2.ID_PK = dfp_1.processId) INNER JOIN PHASE AS p_3 ON p_3.ID_PK = pr_2.ID_PK) INNER JOIN MASTER_PHASE AS mp_4 ON mp_4.PROCESS_ID_PK = pr_2.PROCESS_ID_PK AND mp_4.PHASE_ID_PK = p_3.PHASE_ID AND mp_4.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE')))
ORDER BY p_3."ORDER";

CREATE VIEW DEFAULT_DOCUMENTS_PER_REQUEST_CUSTOMIZING AS SELECT
  rh_1.REQUEST_ID,
  dfb_3.phase,
  dfb_3.block,
  dfb_3.documentId,
  dfb_3.docOrder,
  def_0.APPROVER_TYPE,
  def_0.SUBCONTRACTOR,
  def_0.DEFAULT_RESPONSIBLE,
  def_0.SUBCO_REQ_VAL,
  def_0.CELLNEX_REQ_VAL,
  def_0.CUSTOMER__REQ_VAL,
  def_0.SITEOWNER_REQ_VAL,
  def_0.DELETED
FROM (((REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID AS def_0 INNER JOIN REQUEST_HEAD AS rh_1 ON rh_1.REQUEST_ID = def_0.REQUEST_ID) INNER JOIN DOCUMENT_FLOWS_PER_PROCESS AS dfp_2 ON dfp_2.processId = rh_1.PROCESS_ID) INNER JOIN DOCUMENT_FLOWS_PER_BLOCK AS dfb_3 ON dfb_3.DocumentFlowsPerConfig_ID = dfp_2.Configuration_ID AND dfb_3.documentId = def_0.DOCUMENT_ID);

CREATE VIEW DOCUMENTS_PER_PROCESS AS SELECT
  pr_0.ID_PK AS processFlowId,
  b_1.PHASE_ID_PK AS phaseProcessFlowId,
  b_1.BLOCK_ID_PK AS blockProcessFlowId,
  dfb_3.documentId,
  df_4.documentName
FROM ((((PROCESS AS pr_0 INNER JOIN BLOCK AS b_1 ON b_1.ID_PK = pr_0.ID_PK) INNER JOIN DOCUMENT_FLOWS_PER_PROCESS AS dfp_2 ON dfp_2.processId = pr_0.ID_PK) INNER JOIN DOCUMENT_FLOWS_PER_BLOCK AS dfb_3 ON dfb_3.DocumentFlowsPerConfig_ID = dfp_2.Configuration_ID AND dfb_3.phase = b_1.PHASE_ID_PK AND dfb_3.block = b_1.BLOCK_ID_PK) INNER JOIN DOCUMENT_FLOWS AS df_4 ON df_4.documentId = dfb_3.documentId)
ORDER BY dfb_3.docOrder;

CREATE VIEW REQUEST_ALL_TASKS_DOCUMENTS(IN p_requestId NVARCHAR(36)) AS SELECT
  dp_4.REGISTER_ID,
  dp_4.GENERIC_TYPE_ID,
  bh_2.MASTER_BLOCK_ID,
  ph_1.MASTER_PHASE_ID,
  rh_0.REQUEST_ID
FROM ((((REQUEST_HEAD AS rh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.REQUEST_ID = :P_REQUESTID AND rh_0.REQUEST_ID = :P_REQUESTID) INNER JOIN BLOCK_HEAD AS bh_2 ON bh_2.PHASE_ID = ph_1.PHASE_ID) INNER JOIN WORKS AS gt_3 ON gt_3.parentId = bh_2.BLOCK_ID AND gt_3.parentType_ID = 30) INNER JOIN DOCUMENTS_PER_BLOCK AS dp_4 ON dp_4.WORK_ID = gt_3.ID AND (dp_4.DELETED IS NULL OR dp_4.DELETED = FALSE));

CREATE VIEW REQUEST_ALL_DOCUMENTS(IN p_requestId NVARCHAR(36)) AS SELECT
  dp_3.REGISTER_ID,
  dp_3.GENERIC_TYPE_ID,
  bh_2.MASTER_BLOCK_ID,
  ph_1.MASTER_PHASE_ID,
  rh_0.REQUEST_ID
FROM (((REQUEST_HEAD AS rh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.REQUEST_ID = :P_REQUESTID AND rh_0.REQUEST_ID = :P_REQUESTID) INNER JOIN BLOCK_HEAD AS bh_2 ON bh_2.PHASE_ID = ph_1.PHASE_ID) INNER JOIN DOCUMENTS_PER_BLOCK AS dp_3 ON dp_3.BLOCK_ID = bh_2.BLOCK_ID AND (dp_3.DELETED IS NULL OR dp_3.DELETED = FALSE));

CREATE VIEW OT_DOCUMENTS_PER_REQUEST AS SELECT
  docs_1.REGISTER_ID AS ID,
  rh_0.REQUEST_ID AS requestId,
  docs_1.INSTANCE_ID AS instanceId,
  docs_1.REQUEST_CODE AS requestCode,
  docs_1.BLOCK_ID AS blockId,
  bh_2.MASTER_BLOCK_ID AS blockFlowId,
  docs_1.TYPE_ID AS documentType,
  docs_1.STEP_ID AS stepId,
  docs_1.DOCUMENT_NAME AS documentName,
  docs_1.DOCUMENT_SUBTYPE AS documentSubtype,
  docs_1.DOCUMENT_SUBTYPE_LVL2 AS documentSubType2,
  docs_1.DOCUMENT_ID AS documentId,
  docs_1.MEDIA_TYPE AS mediaType,
  docs_1.CREATEDAT AS createdAt,
  docs_1.CREATEDBY AS createdBy,
  docs_1.DELETED AS deleted,
  docs_1.MODIFIEDAT AS modifiedAt,
  docs_1.MODIFIEDBY AS modifiedBy,
  docs_1.DOCUMENT_URL AS documentUrl,
  ph_3.MASTER_PHASE_ID AS phaseFlowId,
  df_7.documentName AS openTextDocName,
  mb_6.BLOCK_NAME AS blockName,
  mp_5.PHASE_NAME AS phaseName
FROM (((((((REQUEST_HEAD AS rh_0 INNER JOIN WF_DETAIL_DOCUMENTS AS docs_1 ON docs_1.REQUEST_ID = rh_0.REQUEST_ID) INNER JOIN BLOCK_HEAD AS bh_2 ON bh_2.BLOCK_ID = docs_1.BLOCK_ID) INNER JOIN PHASE_HEAD AS ph_3 ON ph_3.PHASE_ID = bh_2.PHASE_ID) LEFT JOIN PROCESS AS proc_4 ON proc_4.ID_PK = rh_0.PROCESS_ID) LEFT JOIN MASTER_PHASE AS mp_5 ON mp_5.PROCESS_ID_PK = proc_4.PROCESS_ID_PK AND mp_5.PHASE_ID_PK = ph_3.MASTER_PHASE_ID AND mp_5.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) LEFT JOIN MASTER_BLOCK AS mb_6 ON mb_6.PROCESS_ID_PK = proc_4.PROCESS_ID_PK AND mb_6.PHASE_ID_PK = ph_3.MASTER_PHASE_ID AND mb_6.BLOCK_ID_PK = bh_2.MASTER_BLOCK_ID AND mb_6.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) LEFT JOIN DOCUMENT_FLOWS AS df_7 ON df_7.documentId = docs_1.DOCUMENT_ID)
ORDER BY bh_2.MASTER_BLOCK_ID;

CREATE VIEW DOCUMENTS_PER_REQUEST AS SELECT
  dpb_3.REGISTER_ID AS ID,
  rh_0.REQUEST_ID AS requestId,
  ph_1.MASTER_PHASE_ID AS phaseFlowId,
  ph_1.PHASE_ID AS phaseId,
  bh_2.MASTER_BLOCK_ID AS blockFlowId,
  dpb_3.BLOCK_ID AS blockId,
  dpb_3.CREATEDAT AS createdAt,
  dpb_3.CREATEDBY AS createdBy,
  dpb_3.DELETED AS deleted,
  dpb_3.DELETED_AT AS deletedAt,
  dpb_3.DELETED_BY AS deletedBy,
  dpb_3.MODIFIEDAT AS modifiedAt,
  dpb_3.MODIFIEDBY AS modifiedBy,
  dpb_3."ORDER" AS "ORDER",
  dpb_3.T_RESPONSIBLE AS responsibleDefault,
  dpb_3.RESPONSIBLE_ID AS responsibleId,
  dpb_3.SUBCONTRATOR_ID AS subcontractorId,
  dpb_3.VALIDATION_CELLNEX_CLIENT AS cellnexValidation,
  dpb_3.VALIDATION_REQ_CLIENT AS customerValidation,
  dpb_3.VALIDATION_SUBCO_CLIENT AS subcontractorValidation,
  dpb_3.VALIDATION_SITEOWNER_NEEDED AS siteOwnerValidation,
  dpb_3.GENERIC_TYPE_ID AS documentId,
  dpb_3.STATUS AS status,
  '' AS cellnexResponsible,
  '' AS subcontractorResponsible,
  '' AS agencyResponsible,
  '' AS customerResponsible,
  '' AS cellnexResponsibleName,
  '' AS subcontractorResponsibleName,
  '' AS agencyResponsibleName,
  '' AS customerResponsibleName,
  0 AS cellnexResponsibleFC,
  0 AS subcontractorResponsibleFC,
  0 AS agencyResponsibleFC,
  0 AS customerResponsibleFC,
  '' AS approverTypeName,
  1 AS approverTypeFC,
  '' AS subcoTypeName,
  1 AS subcoTypeFC,
  '' AS responsibleDefaultName,
  1 AS responsibleDefaultFC,
  1 AS cellnexValidationFC,
  1 AS subcontractorValidationFC,
  1 AS customerValidationFC,
  1 AS siteOwnerValidationFC,
  1 AS cellnexValidatorFC,
  1 AS subcontractorValidatorFC,
  1 AS customerValidatorFC,
  1 AS siteOwnerValidatorFC,
  1 AS documentIdFC,
  1 AS Criticality,
  '' AS stepIdVF,
  '' AS statusIconVF,
  '' AS statusStateVF,
  '' AS statusTextVF,
  '' AS cellnexStatusIconVF,
  '' AS cellnexStatusStateVF,
  '' AS cellnexStatusTextVF,
  '' AS responsibleStatusIconVF,
  '' AS responsibleStatusStateVF,
  '' AS responsibleStatusTextVF,
  '' AS subcontractorStatusIconVF,
  '' AS subcontractorStatusStateVF,
  '' AS subcontractorStatusTextVF,
  '' AS customerStatusIconVF,
  '' AS customerStatusStateVF,
  '' AS customerStatusTextVF,
  '' AS siteOwnerStatusIconVF,
  '' AS siteOwnerStatusStateVF,
  '' AS siteOwnerStatusTextVF,
  FALSE AS canInit,
  FALSE AS canSee,
  FALSE AS canDelete,
  FALSE AS canDownload,
  FALSE AS cellnexValidationVF,
  FALSE AS subcontractorValidationVF,
  FALSE AS customerValidationVF,
  FALSE AS siteOwnerValidationVF
FROM (((REQUEST_HEAD AS rh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.REQUEST_ID = rh_0.REQUEST_ID) INNER JOIN BLOCK_HEAD AS bh_2 ON bh_2.PHASE_ID = ph_1.PHASE_ID) INNER JOIN DOCUMENTS_PER_BLOCK AS dpb_3 ON dpb_3.BLOCK_ID = bh_2.BLOCK_ID)
WHERE rh_0.REQUEST_TYPE = '40';

CREATE VIEW GET_BLOCK_ID_FROM_MASTERBLOCK_ID(IN p_requestId NVARCHAR(5000), IN p_masterBlockId NVARCHAR(5000)) AS SELECT
  bh_2.BLOCK_ID
FROM ((REQUEST_HEAD AS rh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.REQUEST_ID = rh_0.REQUEST_ID) INNER JOIN BLOCK_HEAD AS bh_2 ON bh_2.PHASE_ID = ph_1.PHASE_ID)
WHERE rh_0.REQUEST_ID = :P_REQUESTID AND bh_2.MASTER_BLOCK_ID = :P_MASTERBLOCKID;

CREATE VIEW MANAGERS AS SELECT DISTINCT
  ias_0.USER_ID AS userId,
  lnd_2.COUNTRY_ID AS country,
  ias_0.USER_NAME AS userName
FROM ((US_USERS_IAS AS ias_0 INNER JOIN US_ROLES_AGR AS agr_1 ON agr_1.USER_ID = ias_0.USER_ID AND (agr_1.IAS_GROUP = 'TIS_WF_PRO_ColocationMgr' OR agr_1.IAS_GROUP = 'TIS_WF_PRO_SuppColoMng')) INNER JOIN US_COUNTRIES AS lnd_2 ON lnd_2.USER_ID = ias_0.USER_ID);

CREATE VIEW PMO_MANAGERS AS SELECT DISTINCT
  ias_0.USER_ID AS userId,
  lnd_2.COUNTRY_ID AS country,
  ias_0.USER_NAME AS userName
FROM ((US_USERS_IAS AS ias_0 INNER JOIN US_ROLES_AGR AS agr_1 ON agr_1.USER_ID = ias_0.USER_ID AND (agr_1.IAS_GROUP = 'TIS_WF_PRO_PMOMgr')) INNER JOIN US_COUNTRIES AS lnd_2 ON lnd_2.USER_ID = ias_0.USER_ID);

CREATE VIEW REQUESTERS AS SELECT DISTINCT
  ias_0.USER_ID AS userId,
  lnd_2.COUNTRY_ID AS country,
  ias_0.USER_NAME AS userName
FROM ((US_USERS_IAS AS ias_0 INNER JOIN US_ROLES_AGR AS agr_1 ON agr_1.USER_ID = ias_0.USER_ID AND (agr_1.IAS_GROUP = 'TIS_WF_PRO_ColocationMgr' OR agr_1.IAS_GROUP = 'TIS_WF_PRO_Requester')) INNER JOIN US_COUNTRIES AS lnd_2 ON lnd_2.USER_ID = ias_0.USER_ID);

CREATE VIEW WORK_DOCUMENTS_VH AS SELECT
  document_0.documentId,
  otDocuments_1.documentName,
  otDocuments_1.countryId,
  objective_3.objective_ID AS objective,
  process_4.processFlowId,
  process_4.phaseTypeId,
  process_4.blockTypeId,
  process_4.Type_ID AS workType,
  '' AS workId
FROM ((((WORK_CONFIG_DOCUMENT_FLOWS AS document_0 LEFT JOIN DOCUMENT_FLOWS AS otDocuments_1 ON otDocuments_1.documentId = document_0.documentId) INNER JOIN WORK_CONFIGS AS configuration_2 ON configuration_2.ID = document_0.Configuration_ID) INNER JOIN WORK_CONFIG_OBJECTIVES AS objective_3 ON objective_3.Configuration_ID = configuration_2.ID) INNER JOIN WORK_CONFIG_PROCESSES AS process_4 ON process_4.Configuration_ID = configuration_2.ID);

CREATE VIEW WORK_CONFIG_BY_PROCESS AS SELECT
  tc_0.ID,
  tp_1.processFlowId,
  tp_1.phaseTypeId,
  tp_1.blockTypeId,
  tp_1.Type_ID AS type,
  tp_1.default,
  to_2.objective_ID
FROM ((WORK_CONFIGS AS tc_0 INNER JOIN WORK_CONFIG_PROCESSES AS tp_1 ON tp_1.Configuration_ID = tc_0.ID) INNER JOIN WORK_CONFIG_OBJECTIVES AS to_2 ON to_2.Configuration_ID = tc_0.ID)
WITH ASSOCIATIONS (
  MANY TO ONE JOIN PROJECT_OBJECTIVES AS objective ON (objective.ID = objective_ID)
);

CREATE VIEW WORK_CONFIG_DOCS_BY_PROCESS AS SELECT
  tc_0.ID,
  tp_1.processFlowId,
  tp_1.phaseTypeId,
  tp_1.blockTypeId,
  tp_1.Type_ID AS type,
  tp_1.default AS defaulted,
  to_2.objective_ID,
  tdf_3.documentId,
  tdd_4.approverType,
  tdd_4.externalType,
  tdd_4.subcontractorValidationReq,
  tdd_4.cellnexValidationReq,
  tdd_4.customerValidationReq,
  tdd_4.landlordValidationReq,
  tdd_4.default AS docdefaulted
FROM ((((WORK_CONFIGS AS tc_0 INNER JOIN WORK_CONFIG_PROCESSES AS tp_1 ON tp_1.Configuration_ID = tc_0.ID) INNER JOIN WORK_CONFIG_OBJECTIVES AS to_2 ON to_2.Configuration_ID = tc_0.ID) LEFT JOIN WORK_CONFIG_DOCUMENT_FLOWS AS tdf_3 ON tdf_3.Configuration_ID = tc_0.ID AND tdf_3.WorkType_ID = tp_1.Type_ID) LEFT JOIN WORK_CONFIG_DOCUMENT_DEFAULTS AS tdd_4 ON tdd_4.Configuration_ID = tdf_3.Configuration_ID AND tdd_4.documentId = tdf_3.documentId)
WITH ASSOCIATIONS (
  MANY TO ONE JOIN PROJECT_OBJECTIVES AS objective ON (objective.ID = objective_ID)
);

CREATE VIEW PROJECT_OBJECTIVES_CONFIG_BY_PROCESS AS SELECT DISTINCT
  to_3.objective_ID AS ID,
  COALESCE(pt_5.NAME, po_4.name) AS name,
  p_2.PROGRAM
FROM (((((WORK_CONFIGS AS tc_0 INNER JOIN WORK_CONFIG_PROCESSES AS tp_1 ON tp_1.Configuration_ID = tc_0.ID) INNER JOIN PROCESS AS p_2 ON p_2.ID_PK = tp_1.processFlowId) INNER JOIN WORK_CONFIG_OBJECTIVES AS to_3 ON to_3.Configuration_ID = tc_0.ID) INNER JOIN PROJECT_OBJECTIVES AS po_4 ON po_4.ID = to_3.objective_ID) LEFT JOIN PROJECT_OBJECTIVES_texts AS pt_5 ON pt_5.ID = po_4.ID AND pt_5.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW PROJECT_OBJECTIVES_BY_COUNTRY AS SELECT DISTINCT
  to_3.objective_ID AS ID,
  COALESCE(pt_5.NAME, po_4.name) AS name,
  p_2.COUNTRY_CODE AS country
FROM (((((WORK_CONFIGS AS tc_0 INNER JOIN WORK_CONFIG_PROCESSES AS tp_1 ON tp_1.Configuration_ID = tc_0.ID) INNER JOIN PROCESS AS p_2 ON p_2.ID_PK = tp_1.processFlowId) INNER JOIN WORK_CONFIG_OBJECTIVES AS to_3 ON to_3.Configuration_ID = tc_0.ID) INNER JOIN PROJECT_OBJECTIVES AS po_4 ON po_4.ID = to_3.objective_ID) LEFT JOIN PROJECT_OBJECTIVES_texts AS pt_5 ON pt_5.ID = po_4.ID AND pt_5.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW LOCALIZED_WORKTYPES AS SELECT
  w_0.ID AS code,
  COALESCE(wt_1.NAME, w_0.name) AS name
FROM (WORK_TYPES AS w_0 LEFT JOIN WORK_TYPES_texts AS wt_1 ON wt_1.ID = w_0.ID AND wt_1.LOCALE = SESSION_CONTEXT('LOCALE'));

CREATE VIEW SearchDtLinkedRequest AS SELECT
  rh_1.REQUEST_ID AS requestID,
  rh_1.REQUEST_STATUS AS status,
  rs_2.STATUS_TEXT AS statusName,
  rh_1.SITE_ID AS siteID,
  rh_1.REQUEST_TYPE AS requestType,
  rt_3.REQUEST_TYPE_DESC AS requestTypeName,
  dtl_0.CHILD_REQUEST_ID AS childRequestID,
  dtl_0.PARENT_INSTANCE_ID AS parentInstanceID,
  dtl_0.ASSOCIATION_TYPE AS associationType,
  dtl_0.DELETED AS deleted,
  dtl_0.CHILD_INSTANCE_ID AS childInstanceID,
  dtl_0.LINK_ID AS linkID,
  CASE rh_1.REQUEST_STATUS WHEN '2' THEN 2 WHEN '4' THEN 1 WHEN '7' THEN 2 WHEN '3' THEN 3 ELSE 2 END AS statusCritical
FROM (((DT_LINKED_REQUEST AS dtl_0 INNER JOIN REQUEST_HEAD AS rh_1 ON dtl_0.CHILD_REQUEST_ID = rh_1.REQUEST_CODE) INNER JOIN STATUS_HEAD AS rs_2 ON rs_2.STATUS_CODE = rh_1.REQUEST_STATUS) INNER JOIN REQUEST_TYPE AS rt_3 ON rt_3.REQUEST_TYPE = rh_1.REQUEST_TYPE)
WHERE dtl_0.DELETED = FALSE OR dtl_0.DELETED IS NULL;

CREATE VIEW DtLinkedRequestPossibleChildrenRequest AS SELECT
  rh_0.REQUEST_ID AS requestID,
  rh_0.REQUEST_STATUS AS status,
  rs_1.STATUS_TEXT AS statusName,
  rh_0.REQUEST_CODE AS requestCode,
  rh_0.REQUEST_TYPE AS requestType,
  rt_2.REQUEST_TYPE_DESC AS requestTypeName,
  rh_0.SITE_ID AS siteID,
  rh_0.PROCESS_ID AS processFlowID,
  CAST(CASE WHEN rh_0.REQUEST_STATUS = '2' THEN 0 WHEN rh_0.REQUEST_STATUS = '4' THEN 1 WHEN rh_0.REQUEST_STATUS = '7' THEN 2 WHEN rh_0.REQUEST_STATUS = '3' THEN 3 ELSE 0 END AS INTEGER) AS statusCritical
FROM ((((REQUEST_HEAD AS rh_0 INNER JOIN STATUS_HEAD AS rs_1 ON rs_1.STATUS_CODE = rh_0.REQUEST_STATUS) INNER JOIN REQUEST_TYPE AS rt_2 ON rt_2.REQUEST_TYPE = rh_0.REQUEST_TYPE) LEFT JOIN US_USERS_IAS AS US_3 ON US_3.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN US_COUNTRIES AS UC_4 ON UC_4.USER_ID = US_3.USER_ID)
WHERE rh_0.COUNTRY_ID = UC_4.COUNTRY_ID;

CREATE VIEW SEARCH_BY_COMPLEXITIES AS SELECT
  rh_0.REQUEST_ID,
  bh_2.BLOCK_ID,
  bp_3.COMPLEXITY
FROM (((REQUEST_HEAD AS rh_0 INNER JOIN PHASE_HEAD AS ph_1 ON ph_1.REQUEST_ID = rh_0.REQUEST_ID AND rh_0.REQUEST_TYPE = 40) INNER JOIN BLOCK_HEAD AS bh_2 ON bh_2.PHASE_ID = ph_1.PHASE_ID AND bh_2.MASTER_BLOCK_ID = 'globalResult' AND ph_1.MASTER_PHASE_ID = 'siteSurvey') INNER JOIN BLOCKS_PROVISIONING AS bp_3 ON bp_3.BLOCK_ID = bh_2.BLOCK_ID);

CREATE VIEW project_Currencies AS SELECT
  Currencies_0.name,
  Currencies_0.descr,
  Currencies_0.code,
  Currencies_0.symbol,
  Currencies_0.minorUnit
FROM sap_common_Currencies AS Currencies_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_Currencies_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN project_Currencies_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW project_WORK_PARENT_TYPES AS SELECT
  WORK_PARENT_TYPES_0.createdAt,
  WORK_PARENT_TYPES_0.createdBy,
  WORK_PARENT_TYPES_0.modifiedAt,
  WORK_PARENT_TYPES_0.modifiedBy,
  WORK_PARENT_TYPES_0.name,
  WORK_PARENT_TYPES_0.descr,
  WORK_PARENT_TYPES_0.ID
FROM WORK_PARENT_TYPES AS WORK_PARENT_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_WORK_PARENT_TYPES_texts AS translations ON (translations.ID = ID)
);

CREATE VIEW project_ItemType AS SELECT
  ItemType_0.createdAt,
  ItemType_0.createdBy,
  ItemType_0.modifiedAt,
  ItemType_0.modifiedBy,
  ItemType_0.ID,
  ItemType_0.description,
  ItemType_0.active,
  ItemType_0.valueType_ID,
  ItemType_0.defaultBoolean,
  ItemType_0.defaultString,
  ItemType_0.defaultDate,
  ItemType_0.defaultInteger,
  ItemType_0.defaultDecimal,
  ItemType_0.defaultPickList
FROM Checklist_ItemType AS ItemType_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_FieldType AS valueType ON (valueType.ID = valueType_ID),
  MANY TO MANY JOIN project_ItemTypeValue AS "VALUES" ON ("VALUES".itemType_ID = ID),
  MANY TO MANY JOIN project_ItemType_texts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN project_ItemType_texts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW project_ProcessTypes_texts AS SELECT
  texts_0.locale,
  texts_0.name,
  texts_0.descr,
  texts_0.code
FROM PROCESS_TYPES_texts AS texts_0;

CREATE VIEW project_WorkTypes_texts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM WORK_TYPES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_WorkTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW project_ProjectTypes_texts AS SELECT
  texts_0.locale,
  texts_0.code,
  texts_0.country,
  texts_0.name
FROM PROJECT_TYPES_texts AS texts_0;

CREATE VIEW project_BooleanValues_texts AS SELECT
  texts_0.locale,
  texts_0.name,
  texts_0.descr,
  texts_0.code
FROM BOOLEAN_VALUES_texts AS texts_0;

CREATE VIEW workconfiguration_WorkParentTypes_texts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM WORK_PARENT_TYPES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN workconfiguration_WorkParentTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW project_Currencies_texts AS SELECT
  texts_0.locale,
  texts_0.name,
  texts_0.descr,
  texts_0.code
FROM sap_common_Currencies_texts AS texts_0;

CREATE VIEW project_WORK_PARENT_TYPES_texts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM WORK_PARENT_TYPES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_WORK_PARENT_TYPES AS parent ON (parent.ID = ID)
);

CREATE VIEW project_FieldType AS SELECT
  FieldType_0.name,
  FieldType_0.descr,
  FieldType_0.ID
FROM Checklist_FieldType AS FieldType_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_FieldType_texts AS translations ON (translations.ID = ID)
);

CREATE VIEW project_ItemTypeValue AS SELECT
  ItemTypeValue_0.ID,
  ItemTypeValue_0.createdAt,
  ItemTypeValue_0.createdBy,
  ItemTypeValue_0.modifiedAt,
  ItemTypeValue_0.modifiedBy,
  ItemTypeValue_0.description,
  ItemTypeValue_0.active,
  ItemTypeValue_0.booleanValue,
  ItemTypeValue_0.stringValue,
  ItemTypeValue_0.dateValue,
  ItemTypeValue_0.integerValue,
  ItemTypeValue_0.decimalValue,
  ItemTypeValue_0.pickList,
  ItemTypeValue_0.itemType_ID
FROM Checklist_ItemTypeValue AS ItemTypeValue_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ItemType AS itemType ON (itemType.ID = itemType_ID),
  MANY TO MANY JOIN project_ItemTypeValue_texts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN project_ItemTypeValue_texts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW project_ItemType_texts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.description
FROM Checklist_ItemType_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ItemType AS parent ON (parent.ID = ID)
);

CREATE VIEW project_FieldType_texts AS SELECT
  texts_0.locale,
  texts_0.name,
  texts_0.descr,
  texts_0.ID
FROM Checklist_FieldType_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_FieldType AS parent ON (parent.ID = ID)
);

CREATE VIEW project_ItemTypeValue_texts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.description
FROM Checklist_ItemTypeValue_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_ItemTypeValue AS parent ON (parent.ID = ID)
);

CREATE VIEW workconfiguration_DocumentDefaults_texts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.name,
  texts_0.descr
FROM WORK_CONFIG_DOCUMENT_DEFAULTS_texts AS texts_0;

CREATE VIEW localized_sap_common_Currencies AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code,
  L_0.symbol,
  L_0.minorUnit
FROM (sap_common_Currencies AS L_0 LEFT JOIN sap_common_Currencies_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = SESSION_CONTEXT('LOCALE'))
WITH ASSOCIATIONS (
  MANY TO MANY JOIN sap_common_Currencies_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN sap_common_Currencies_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_BOOLEAN_VALUES AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (BOOLEAN_VALUES AS L_0 LEFT JOIN BOOLEAN_VALUES_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = SESSION_CONTEXT('LOCALE'))
WITH ASSOCIATIONS (
  MANY TO MANY JOIN BOOLEAN_VALUES_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN BOOLEAN_VALUES_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_PROJECT_TYPES AS SELECT
  L_0.code,
  L_0.country,
  coalesce(localized_1.name, L_0.name) AS name
FROM (PROJECT_TYPES AS L_0 LEFT JOIN PROJECT_TYPES_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.country = L_0.country AND localized_1.locale = SESSION_CONTEXT('LOCALE'))
WITH ASSOCIATIONS (
  MANY TO MANY JOIN PROJECT_TYPES_texts AS texts ON (texts.code = code AND texts.country = country),
  MANY TO ONE JOIN PROJECT_TYPES_texts AS localized ON (localized.code = code AND localized.country = country AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_PROCESS_TYPES AS SELECT
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.code
FROM (PROCESS_TYPES AS L_0 LEFT JOIN PROCESS_TYPES_texts AS localized_1 ON localized_1.code = L_0.code AND localized_1.locale = SESSION_CONTEXT('LOCALE'))
WITH ASSOCIATIONS (
  MANY TO MANY JOIN PROCESS_TYPES_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN PROCESS_TYPES_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_WORK_CONFIG_DOCUMENT_DEFAULTS AS SELECT
  L_0.ID,
  L_0.createdAt,
  L_0.createdBy,
  L_0.modifiedAt,
  L_0.modifiedBy,
  coalesce(localized_1.name, L_0.name) AS name,
  coalesce(localized_1.descr, L_0.descr) AS descr,
  L_0.documentId,
  L_0.approverType,
  L_0.externalType,
  L_0.subcontractorValidationReq,
  L_0.cellnexValidationReq,
  L_0.customerValidationReq,
  L_0.landlordValidationReq,
  L_0.default,
  L_0.deleted,
  L_0.Configuration_ID
FROM (WORK_CONFIG_DOCUMENT_DEFAULTS AS L_0 LEFT JOIN WORK_CONFIG_DOCUMENT_DEFAULTS_texts AS localized_1 ON localized_1.ID = L_0.ID AND localized_1.locale = SESSION_CONTEXT('LOCALE'))
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_WORK_CONFIGS AS Configuration ON (Configuration.ID = Configuration_ID),
  MANY TO MANY JOIN WORK_CONFIG_DOCUMENT_DEFAULTS_texts AS texts ON (texts.ID = ID),
  MANY TO ONE JOIN WORK_CONFIG_DOCUMENT_DEFAULTS_texts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_checklistconfiguration_FieldTypes AS SELECT
  FieldType_0.name,
  FieldType_0.descr,
  FieldType_0.ID
FROM Checklist_FieldType AS FieldType_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_checklistconfiguration_FieldTypeTexts AS translations ON (translations.ID = ID)
);

CREATE VIEW localized_checklistconfiguration_ItemTypes AS SELECT
  ItemType_0.createdAt,
  ItemType_0.createdBy,
  ItemType_0.modifiedAt,
  ItemType_0.modifiedBy,
  ItemType_0.ID,
  ItemType_0.description,
  ItemType_0.active,
  ItemType_0.valueType_ID,
  ItemType_0.defaultBoolean,
  ItemType_0.defaultString,
  ItemType_0.defaultDate,
  ItemType_0.defaultInteger,
  ItemType_0.defaultDecimal,
  ItemType_0.defaultPickList
FROM Checklist_ItemType AS ItemType_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_checklistconfiguration_FieldTypes AS valueType ON (valueType.ID = valueType_ID),
  MANY TO MANY JOIN localized_checklistconfiguration_ItemTypeValues AS "VALUES" ON ("VALUES".itemType_ID = ID),
  MANY TO MANY JOIN localized_checklistconfiguration_ItemTypeTexts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN localized_checklistconfiguration_ItemTypeTexts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_checklistconfiguration_ItemTypeValues AS SELECT
  ItemTypeValue_0.ID,
  ItemTypeValue_0.createdAt,
  ItemTypeValue_0.createdBy,
  ItemTypeValue_0.modifiedAt,
  ItemTypeValue_0.modifiedBy,
  ItemTypeValue_0.description,
  ItemTypeValue_0.active,
  ItemTypeValue_0.booleanValue,
  ItemTypeValue_0.stringValue,
  ItemTypeValue_0.dateValue,
  ItemTypeValue_0.integerValue,
  ItemTypeValue_0.decimalValue,
  ItemTypeValue_0.pickList,
  ItemTypeValue_0.itemType_ID
FROM Checklist_ItemTypeValue AS ItemTypeValue_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_checklistconfiguration_ItemTypes AS itemType ON (itemType.ID = itemType_ID),
  MANY TO MANY JOIN localized_checklistconfiguration_ItemTypeValueTexts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN localized_checklistconfiguration_ItemTypeValueTexts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_project_WorkTypes AS SELECT
  WORK_TYPES_0.createdAt,
  WORK_TYPES_0.createdBy,
  WORK_TYPES_0.modifiedAt,
  WORK_TYPES_0.modifiedBy,
  WORK_TYPES_0.name,
  WORK_TYPES_0.descr,
  WORK_TYPES_0.ID
FROM WORK_TYPES AS WORK_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_project_WorkTypes_texts AS translations ON (translations.ID = ID)
);

CREATE VIEW localized_workconfiguration_WorkTypes AS SELECT
  WORK_TYPES_0.createdAt,
  WORK_TYPES_0.createdBy,
  WORK_TYPES_0.modifiedAt,
  WORK_TYPES_0.modifiedBy,
  WORK_TYPES_0.name,
  WORK_TYPES_0.descr,
  WORK_TYPES_0.ID
FROM WORK_TYPES AS WORK_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_workconfiguration_WorkTypesTexts AS translations ON (translations.ID = ID)
);

CREATE VIEW localized_workconfiguration_WorkParentTypes AS SELECT
  WORK_PARENT_TYPES_0.createdAt,
  WORK_PARENT_TYPES_0.createdBy,
  WORK_PARENT_TYPES_0.modifiedAt,
  WORK_PARENT_TYPES_0.modifiedBy,
  WORK_PARENT_TYPES_0.name,
  WORK_PARENT_TYPES_0.descr,
  WORK_PARENT_TYPES_0.ID
FROM WORK_PARENT_TYPES AS WORK_PARENT_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_workconfiguration_WorkParentTypes_texts AS translations ON (translations.ID = ID)
);

CREATE VIEW localized_workconfiguration_MasterObjectives AS SELECT
  PROJECT_OBJECTIVES_0.createdAt,
  PROJECT_OBJECTIVES_0.createdBy,
  PROJECT_OBJECTIVES_0.modifiedAt,
  PROJECT_OBJECTIVES_0.modifiedBy,
  PROJECT_OBJECTIVES_0.name,
  PROJECT_OBJECTIVES_0.descr,
  PROJECT_OBJECTIVES_0.ID
FROM PROJECT_OBJECTIVES AS PROJECT_OBJECTIVES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_workconfiguration_MasterObjectivesTexts AS translations ON (translations.ID = ID)
);

CREATE VIEW localized_CHANGE_LOG AS SELECT DISTINCT
  log_0.ACTIONS_LOG_ID AS logId,
  log_0.REQUEST_ID AS requestId,
  log_0.REQUEST_TYPE AS requestType,
  log_0."DATE" AS changeDate,
  log_0."USER" AS userId,
  CASE WHEN ias_3.USER_NAME IS NULL OR ias_3.USER_NAME = '' THEN ias_3.USER_ID ELSE ias_3.USER_NAME END AS userName,
  log_0.ACTION AS userAction,
  '' AS userActionName,
  log_0.PHASE_ID_PK AS phaseProcessFlowId,
  mp_5.PHASE_NAME AS phaseName,
  log_0.BLOCK_ID_PK AS blockProcessFlowId,
  mb_6.BLOCK_NAME AS blockName,
  log_0.FIELD_MOD AS fieldName,
  '' AS fieldDescription,
  log_0.OLD_VALUE AS oldValue,
  '' AS oldValueDescription,
  log_0.NEW_VALUE AS newValue,
  '' AS newValueDescription,
  log_0.PHASE_ID AS phaseId,
  log_0.BLOCK_ID AS BlockId,
  doc_7.documentName AS documentName,
  type_9.ID AS workType,
  type_9.descr AS workTypeName
FROM (((((((((WF_ACTIONS_LOG AS log_0 LEFT JOIN REQUEST_HEAD AS rh_1 ON rh_1.REQUEST_ID = log_0.REQUEST_ID) LEFT JOIN BLOCK_HEAD AS bh_2 ON bh_2.BLOCK_ID = log_0.BLOCK_ID) LEFT JOIN US_USERS_IAS AS ias_3 ON ias_3.USER_ID = log_0."USER") LEFT JOIN PROCESS AS proc_4 ON proc_4.ID_PK = rh_1.PROCESS_ID) LEFT JOIN MASTER_PHASE AS mp_5 ON mp_5.PROCESS_ID_PK = proc_4.PROCESS_ID_PK AND mp_5.PHASE_ID_PK = log_0.PHASE_ID_PK AND mp_5.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) LEFT JOIN MASTER_BLOCK AS mb_6 ON mb_6.PROCESS_ID_PK = proc_4.PROCESS_ID_PK AND mb_6.PHASE_ID_PK = log_0.PHASE_ID_PK AND mb_6.BLOCK_ID_PK = log_0.BLOCK_ID_PK AND mb_6.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) LEFT JOIN DOCUMENT_FLOWS AS doc_7 ON doc_7.documentId = log_0.DOCUMENT_ID) LEFT JOIN WORKS AS works_8 ON works_8.ID = log_0.WORK_ID) LEFT JOIN WORK_TYPES AS type_9 ON works_8.type_ID = type_9.ID);

CREATE VIEW localized_WORK_CONFIGS AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.description
FROM WORK_CONFIGS AS L
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_WORK_CONFIG_PROCESSES AS FlowsPerProcess ON (FlowsPerProcess.Configuration_ID = ID),
  MANY TO MANY JOIN localized_WORK_CONFIG_OBJECTIVES AS Objectives ON (Objectives.Configuration_ID = ID),
  MANY TO MANY JOIN localized_WORK_CONFIG_DOCUMENT_FLOWS AS Documents ON (Documents.Configuration_ID = ID),
  MANY TO MANY JOIN localized_WORK_CONFIG_DOCUMENT_DEFAULTS AS DocumentDefaults ON (DocumentDefaults.Configuration_ID = ID)
);

CREATE VIEW localized_project_WORK_PARENT_TYPES AS SELECT
  WORK_PARENT_TYPES_0.createdAt,
  WORK_PARENT_TYPES_0.createdBy,
  WORK_PARENT_TYPES_0.modifiedAt,
  WORK_PARENT_TYPES_0.modifiedBy,
  WORK_PARENT_TYPES_0.name,
  WORK_PARENT_TYPES_0.descr,
  WORK_PARENT_TYPES_0.ID
FROM WORK_PARENT_TYPES AS WORK_PARENT_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_project_WORK_PARENT_TYPES_texts AS translations ON (translations.ID = ID)
);

CREATE VIEW localized_project_ItemType AS SELECT
  ItemType_0.createdAt,
  ItemType_0.createdBy,
  ItemType_0.modifiedAt,
  ItemType_0.modifiedBy,
  ItemType_0.ID,
  ItemType_0.description,
  ItemType_0.active,
  ItemType_0.valueType_ID,
  ItemType_0.defaultBoolean,
  ItemType_0.defaultString,
  ItemType_0.defaultDate,
  ItemType_0.defaultInteger,
  ItemType_0.defaultDecimal,
  ItemType_0.defaultPickList
FROM Checklist_ItemType AS ItemType_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_FieldType AS valueType ON (valueType.ID = valueType_ID),
  MANY TO MANY JOIN localized_project_ItemTypeValue AS "VALUES" ON ("VALUES".itemType_ID = ID),
  MANY TO MANY JOIN localized_project_ItemType_texts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN localized_project_ItemType_texts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_project_FieldType AS SELECT
  FieldType_0.name,
  FieldType_0.descr,
  FieldType_0.ID
FROM Checklist_FieldType AS FieldType_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_project_FieldType_texts AS translations ON (translations.ID = ID)
);

CREATE VIEW localized_project_ItemTypeValue AS SELECT
  ItemTypeValue_0.ID,
  ItemTypeValue_0.createdAt,
  ItemTypeValue_0.createdBy,
  ItemTypeValue_0.modifiedAt,
  ItemTypeValue_0.modifiedBy,
  ItemTypeValue_0.description,
  ItemTypeValue_0.active,
  ItemTypeValue_0.booleanValue,
  ItemTypeValue_0.stringValue,
  ItemTypeValue_0.dateValue,
  ItemTypeValue_0.integerValue,
  ItemTypeValue_0.decimalValue,
  ItemTypeValue_0.pickList,
  ItemTypeValue_0.itemType_ID
FROM Checklist_ItemTypeValue AS ItemTypeValue_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_ItemType AS itemType ON (itemType.ID = itemType_ID),
  MANY TO MANY JOIN localized_project_ItemTypeValue_texts AS translations ON (translations.ID = ID),
  MANY TO ONE JOIN localized_project_ItemTypeValue_texts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_checklistconfiguration_FieldTypeTexts AS SELECT
  texts_0.locale,
  texts_0.name,
  texts_0.descr,
  texts_0.ID
FROM Checklist_FieldType_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_checklistconfiguration_FieldTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_checklistconfiguration_ItemTypeTexts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.description
FROM Checklist_ItemType_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_checklistconfiguration_ItemTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_checklistconfiguration_ItemConfigurationTypes AS SELECT
  ItemConfigurationType_0.ID,
  ItemConfigurationType_0.createdAt,
  ItemConfigurationType_0.createdBy,
  ItemConfigurationType_0.modifiedAt,
  ItemConfigurationType_0.modifiedBy,
  ItemConfigurationType_0.defaulted,
  ItemConfigurationType_0.mandatory,
  ItemConfigurationType_0.defaultBoolean,
  ItemConfigurationType_0.defaultString,
  ItemConfigurationType_0.defaultDate,
  ItemConfigurationType_0.defaultInteger,
  ItemConfigurationType_0.defaultDecimal,
  ItemConfigurationType_0.defaultPickList,
  ItemConfigurationType_0.beforeCreate,
  ItemConfigurationType_0.afterUpdate,
  ItemConfigurationType_0.afterRead,
  ItemConfigurationType_0.refreshEntity,
  ItemConfigurationType_0."ORDER",
  ItemConfigurationType_0.type_ID,
  ItemConfigurationType_0.configuration_ID
FROM Checklist_ItemConfigurationType AS ItemConfigurationType_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_checklistconfiguration_ItemTypes AS type ON (type.ID = type_ID),
  MANY TO ONE JOIN localized_checklistconfiguration_ItemConfigurations AS configuration ON (configuration.ID = configuration_ID)
);

CREATE VIEW localized_checklistconfiguration_ItemTypeValueTexts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.description
FROM Checklist_ItemTypeValue_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_checklistconfiguration_ItemTypeValues AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_project_Requests AS SELECT
  REQUEST_HEAD_0.REQUEST_ID AS ID,
  REQUEST_HEAD_0.ASSIGNATION_DATE AS assignationDate,
  REQUEST_HEAD_0.CANCELLATION_COMMENTS AS cancellationComments,
  REQUEST_HEAD_0.CANCELLATION_PHASE_ID AS cancellationPhaseID,
  REQUEST_HEAD_0.CANCELLATION_REASON AS cancellationReason,
  REQUEST_HEAD_0.COMUNIDAD_ID AS company,
  REQUEST_HEAD_0.COUNTRY_ID AS country,
  REQUEST_HEAD_0.CREATEDAT AS createdAt,
  REQUEST_HEAD_0.CREATEDBY AS createdBy,
  REQUEST_HEAD_0.DELETED_AT AS deletedAt,
  REQUEST_HEAD_0.DELETED_BY AS deletedBy,
  REQUEST_HEAD_0.ENDED_AT AS closedAt,
  REQUEST_HEAD_0.MODIFIEDAT AS changedAt,
  REQUEST_HEAD_0.MODIFIEDBY AS changedBy,
  REQUEST_HEAD_0.PROCESS_ID AS processFlowId,
  REQUEST_HEAD_0.REQUEST_CODE AS code,
  REQUEST_HEAD_0.REQUEST_DESCRIPTION AS description,
  REQUEST_HEAD_0.REQUEST_OWNER_ID AS manager,
  REQUEST_HEAD_0.REQUEST_STATUS AS status,
  REQUEST_HEAD_0.REQUEST_TYPE AS requestType,
  REQUEST_HEAD_0.ROLE_ID AS role,
  REQUEST_HEAD_0.SITE_ID AS siteId,
  REQUEST_HEAD_0.STARTED_AT AS opentAt,
  REQUEST_HEAD_0.ON_HOLD_COMMENTS AS onHoldComments,
  REQUEST_HEAD_0.ON_HOLD_PHASE_ID AS onHoldPhaseId,
  REQUEST_HEAD_0.ON_HOLD_REASON AS onHoldReason,
  REQUEST_HEAD_0.WORKFLOW_NAME AS workflowName,
  REQUEST_HEAD_0.WORKFLOW_ID AS creationConfig
FROM REQUEST_HEAD AS REQUEST_HEAD_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_RequestProvision AS RequestProvision ON (RequestProvision.ID = ID),
  MANY TO MANY JOIN localized_project_Phases AS Phases ON (Phases.requestId = ID),
  MANY TO MANY JOIN project_Chats AS Chats ON (Chats.ID = ID),
  MANY TO MANY JOIN localized_project_ChangesLog AS ChangesLog ON (ChangesLog.requestId = ID),
  MANY TO ONE JOIN localized_project_ProcessTypes AS ProcessTypes ON (ProcessTypes.code = processFlowId),
  MANY TO ONE JOIN project_RequestTypes AS RequestTypes ON (RequestTypes.REQUEST_TYPE = requestType),
  MANY TO ONE JOIN project_RequestStatus AS RequestStatus ON (RequestStatus.code = status),
  MANY TO ONE JOIN project_OnHoldReasons AS OnHoldReasons ON (OnHoldReasons.code = onHoldReason),
  MANY TO ONE JOIN project_CancellationReasons AS CancellationReasons ON (CancellationReasons.code = cancellationReason),
  MANY TO ONE JOIN project_Managers AS Managers ON (Managers.userId = manager),
  MANY TO ONE JOIN project_Sites AS Site ON (Site.siteId = siteId),
  MANY TO MANY JOIN localized_project_RequestDocumentsPerBlockDefaultValid AS RequestDocumentsPerBlockDefaultValid ON (RequestDocumentsPerBlockDefaultValid.requestId = ID AND RequestDocumentsPerBlockDefaultValid.deleted = FALSE),
  MANY TO MANY JOIN localized_project_DocumentsPerRequest AS DocumentsPerRequest ON (DocumentsPerRequest.requestId = ID),
  MANY TO MANY JOIN project_DocumentViewerNodes AS DocumentViewerNodes ON (DocumentViewerNodes.requestId = ID),
  MANY TO MANY JOIN project_ImpactedCustomers AS ImpactedCustomers ON (ImpactedCustomers.requestId = ID)
);

CREATE VIEW localized_project_Works AS SELECT
  WORKS_0.ID,
  WORKS_0.status,
  WORKS_0.description,
  WORKS_0.responsibleType,
  WORKS_0.externalType,
  WORKS_0.comments,
  WORKS_0.startDate,
  WORKS_0.endDate,
  WORKS_0.expectedStartDate,
  WORKS_0.expectedEndDate,
  WORKS_0.realStartDate,
  WORKS_0.realEndDate,
  WORKS_0.parentId,
  WORKS_0.internalResponsible,
  WORKS_0.externalResponsible,
  WORKS_0.parentType_ID,
  WORKS_0.type_ID
FROM WORKS AS WORKS_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_WORK_PARENT_TYPES AS parentType ON (parentType.ID = parentType_ID),
  MANY TO ONE JOIN localized_project_Blocks AS block ON (block.ID = parentId),
  MANY TO MANY JOIN project_Documents AS documents ON (documents.workId = ID),
  MANY TO MANY JOIN localized_project_DocumentsPerBlocks AS approvalFlows ON (approvalFlows.workId = ID),
  MANY TO ONE JOIN localized_project_WorkTypes AS type ON (type.ID = type_ID),
  MANY TO ONE JOIN project_LocalizedWorkTypes AS LocalizedWorkTypesName ON (LocalizedWorkTypesName.code = type_ID)
);

CREATE VIEW localized_project_WorkTypes_texts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM WORK_TYPES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_WorkTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_workconfiguration_WorkTypesTexts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM WORK_TYPES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_workconfiguration_WorkTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_workconfiguration_WorkParentTypes_texts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM WORK_PARENT_TYPES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_workconfiguration_WorkParentTypes AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_workconfiguration_MasterObjectivesTexts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM PROJECT_OBJECTIVES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_workconfiguration_MasterObjectives AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_WORK_CONFIG_OBJECTIVES AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.objective_ID,
  L.Configuration_ID
FROM WORK_CONFIG_OBJECTIVES AS L
WITH ASSOCIATIONS (
  MANY TO ONE JOIN PROJECT_OBJECTIVES AS objective ON (objective.ID = objective_ID),
  MANY TO ONE JOIN localized_WORK_CONFIGS AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW localized_WORK_CONFIG_PROCESSES AS SELECT
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.ID,
  L.processFlowId,
  L.phaseTypeId,
  L.blockTypeId,
  L.default,
  L.Type_ID,
  L.Configuration_ID
FROM WORK_CONFIG_PROCESSES AS L
WITH ASSOCIATIONS (
  MANY TO ONE JOIN WORK_TYPES AS Type ON (Type.ID = Type_ID),
  MANY TO ONE JOIN localized_WORK_CONFIGS AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW localized_WORK_CONFIG_DOCUMENT_FLOWS AS SELECT
  L.ID,
  L.createdAt,
  L.createdBy,
  L.modifiedAt,
  L.modifiedBy,
  L.documentId,
  L.WorkType_ID,
  L.Configuration_ID
FROM WORK_CONFIG_DOCUMENT_FLOWS AS L
WITH ASSOCIATIONS (
  MANY TO ONE JOIN WORK_TYPES AS WorkType ON (WorkType.ID = WorkType_ID),
  MANY TO ONE JOIN localized_WORK_CONFIGS AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW localized_project_BlockProvision AS SELECT
  BLOCKS_PROVISIONING_0.BLOCK_ID AS ID,
  BLOCKS_PROVISIONING_0.ACCEPTED_REJECTED AS accepted,
  BLOCKS_PROVISIONING_0.ACCEPTED_REJECTED_DATE AS acceptedDate,
  BLOCKS_PROVISIONING_0.ACTIVATION_REASON AS activationReason,
  BLOCKS_PROVISIONING_0.ADAPTIONS_TYPE AS adaptionsType,
  BLOCKS_PROVISIONING_0.APD_PACK_DELIVERY_EXPECTED_DATE AS apdPackDeliveryExpectedDate,
  BLOCKS_PROVISIONING_0.APD_PACK_DELIVERY_PLANNED_DATE AS apdPackDeliveryPlannedDate,
  BLOCKS_PROVISIONING_0.APS_DELIVERY_EXPECTED_DATE AS apsDeliveryExpectedDate,
  BLOCKS_PROVISIONING_0.APS_DELIVERY_PLANNED_DATE AS apsDeliveryPlannedDate,
  BLOCKS_PROVISIONING_0.ASSIGNED_RESPONSIBLE AS assignedResponsible,
  BLOCKS_PROVISIONING_0.AUTOMATIC_MANUAL_RESPONSE AS automaticManualResponse,
  BLOCKS_PROVISIONING_0.STATUS AS repaymentStatus,
  BLOCKS_PROVISIONING_0.BTTN_DOC_UPDATED AS documentsUpdated,
  BLOCKS_PROVISIONING_0.BTTN_INV_UPDATED AS inventoryUpdated,
  BLOCKS_PROVISIONING_0.BTTN_SERV_UPDATED AS servicesUpdated,
  BLOCKS_PROVISIONING_0.COMPLETED_BY AS completedBy,
  BLOCKS_PROVISIONING_0.COMPLETED_DATE AS completedDate,
  BLOCKS_PROVISIONING_0.COMPLEXITY AS complexity,
  BLOCKS_PROVISIONING_0.CONTRACT_RESTRICTIONS AS contractRestrictions,
  BLOCKS_PROVISIONING_0.CREATEDAT AS createdAt,
  BLOCKS_PROVISIONING_0.CREATEDBY AS createdBy,
  BLOCKS_PROVISIONING_0.CURRENCY AS currency,
  BLOCKS_PROVISIONING_0.DEBTOR AS debtor,
  BLOCKS_PROVISIONING_0.DESCRIPTION AS description,
  BLOCKS_PROVISIONING_0.DELETED AS deleted,
  BLOCKS_PROVISIONING_0.DELETED_AT AS deletedAt,
  BLOCKS_PROVISIONING_0.DELETED_BY AS deletedBy,
  BLOCKS_PROVISIONING_0.ENDED_AT AS closedAt,
  BLOCKS_PROVISIONING_0.ENERGY_PROVIDER_DOC_DELIVERY_EXPECTED_DATE AS energyProvDocExpectedDate,
  BLOCKS_PROVISIONING_0.ENERGY_PROVIDER_VISIT_EXPECTED_DATE AS energyProvVisitExpectedDate,
  BLOCKS_PROVISIONING_0.ENERGY_PROVIDER_VISIT_DATE AS energyProviderVisitDate,
  BLOCKS_PROVISIONING_0.EXPECTED_DATE AS expectedDate,
  BLOCKS_PROVISIONING_0.EXPECTED_START_DATE AS expectedStartDate,
  BLOCKS_PROVISIONING_0.EXPECTED_END_DATE AS expectedEndDate,
  BLOCKS_PROVISIONING_0.EXPECTED_MAD_DATE AS expectedMadDate,
  BLOCKS_PROVISIONING_0.ESTIMATED_PAYMENT_DATE AS estimatedPaymentDate,
  BLOCKS_PROVISIONING_0.READY_TO_START_WORKS_DATE AS readyToStartWorksDate,
  BLOCKS_PROVISIONING_0.GLOBAL_END_WORKS_DATE AS globalEndWorksDate,
  BLOCKS_PROVISIONING_0.GLOBAL_START_WORKS_DATE AS globalStartWorksDate,
  BLOCKS_PROVISIONING_0.HS_VISIT_DATE AS hsVisitDate,
  BLOCKS_PROVISIONING_0.HS_VISIT_PLANNED_DATE AS hsVisitPlannedDate,
  BLOCKS_PROVISIONING_0.INFRASTRUCTURES_MAD_DATE AS infraMadDate,
  BLOCKS_PROVISIONING_0.KICK_OFF_ESTIMATED_VISIT_DATE AS kickOffEstimatedVisitDate,
  BLOCKS_PROVISIONING_0.KICK_OFF_VISIT_NEEDED AS visitNeeded,
  BLOCKS_PROVISIONING_0.MODIFIEDAT AS changedAt,
  BLOCKS_PROVISIONING_0.MODIFIEDBY AS changedBy,
  BLOCKS_PROVISIONING_0.PLANNED_DATE AS plannedDate,
  BLOCKS_PROVISIONING_0.PLANNED_KICK_OFF_DATE AS plannedKickoffDate,
  BLOCKS_PROVISIONING_0.PLANNING_RATING AS planningRating,
  BLOCKS_PROVISIONING_0.PROVIDER_NAME AS externalResponsible,
  BLOCKS_PROVISIONING_0.REJECTION_CAUSE AS rejectionReason,
  BLOCKS_PROVISIONING_0.RENEGO_NEEDED AS renegoNeeded,
  BLOCKS_PROVISIONING_0.REAL_DATE_SURVEY AS siteSurveyDate,
  BLOCKS_PROVISIONING_0.REAL_END_DATE AS realEndDate,
  BLOCKS_PROVISIONING_0.REAL_END_DATE AS kickOffRealDate,
  BLOCKS_PROVISIONING_0.REAL_END_DATE AS heritageEndDate,
  BLOCKS_PROVISIONING_0.REAL_START_DATE AS realStartDate,
  BLOCKS_PROVISIONING_0.RESPONSIBLE_PERSON AS internalResponsible,
  BLOCKS_PROVISIONING_0.RESULT_MAD AS madResult,
  BLOCKS_PROVISIONING_0.SEND_OFFER_DATE AS sendOfferDate,
  BLOCKS_PROVISIONING_0.START_DATE AS startDate,
  BLOCKS_PROVISIONING_0.END_DATE AS endDate,
  BLOCKS_PROVISIONING_0.SITE_SURVEY_WILL_BE_NEEDED AS siteSurveyWillBeNeeded,
  BLOCKS_PROVISIONING_0.SUBCONTRACTOR_TYPE AS subcontractorType,
  BLOCKS_PROVISIONING_0.AMOUNT_BUDGET AS amount,
  BLOCKS_PROVISIONING_0.TOTAL_COST AS totalCost,
  BLOCKS_PROVISIONING_0.TOTAL_COST AS totalCostClient,
  BLOCKS_PROVISIONING_0.NEED_KICK_OFF_VISIT AS kickOffVisitNeeded,
  BLOCKS_PROVISIONING_0.OVERALL_FEASIBILITY AS overallFeasibility,
  BLOCKS_PROVISIONING_0.OVERALL_FEASIBILITY_RISK AS overallFeasibilityRisk,
  BLOCKS_PROVISIONING_0.PERMITS_NEEDED AS permitsNeeded,
  BLOCKS_PROVISIONING_0.PERMITS_FEASIBILITY AS permitsFeasibility,
  BLOCKS_PROVISIONING_0.PERMITS_FEASIBILITY_EXPLANATION AS permitsFeasibilityExp,
  BLOCKS_PROVISIONING_0.REAL_ESTATE_FEASIBILITY AS realStateFeasibility,
  BLOCKS_PROVISIONING_0.REAL_ESTATE_FEASIBILITY_RISK AS realStateFeasibilityRisk,
  BLOCKS_PROVISIONING_0.REAL_ESTATE_FEASIBILITY_EXPLANATION AS realEstateFeasibilityExp
FROM BLOCKS_PROVISIONING AS BLOCKS_PROVISIONING_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_Blocks AS Blocks ON (Blocks.ID = ID),
  MANY TO ONE JOIN project_RepaymentStatus AS RepaymentStatus ON (RepaymentStatus.code = repaymentStatus),
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = assignedResponsible),
  MANY TO ONE JOIN project_YesNoFields AS SiteSurveyNeeded ON (SiteSurveyNeeded.code = siteSurveyWillBeNeeded),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcontractorType),
  MANY TO ONE JOIN project_YesNoFields AS KickOffVisitNeeded ON (KickOffVisitNeeded.code = kickOffVisitNeeded),
  MANY TO ONE JOIN project_AdaptionsNeededFields AS RenegoNeeded ON (RenegoNeeded.code = renegoNeeded),
  MANY TO ONE JOIN project_AutomaticFields AS AutomaticManualResponses ON (AutomaticManualResponses.code = automaticManualResponse),
  MANY TO ONE JOIN project_FeasibilitiesWithRisks AS RealStateFeasibilities ON (RealStateFeasibilities.code = realStateFeasibility),
  MANY TO ONE JOIN project_FeasibilitiesWithRisks AS PermitsFeasibilities ON (PermitsFeasibilities.code = permitsFeasibility),
  MANY TO ONE JOIN project_Risks AS RealStateRisks ON (RealStateRisks.code = realStateFeasibilityRisk),
  MANY TO ONE JOIN project_AdaptionsNeededFields AS PermitsNeeded ON (PermitsNeeded.code = permitsNeeded),
  MANY TO ONE JOIN project_AcceptedRejected AS AcceptedRejected ON (AcceptedRejected.code = accepted),
  MANY TO ONE JOIN project_RejectionReasons AS RejectionReasons ON (RejectionReasons.code = rejectionReason),
  MANY TO ONE JOIN localized_project_Currencies AS Currencies ON (Currencies.code = currency),
  MANY TO ONE JOIN project_Complexities AS Complexities ON (Complexities.code = complexity),
  MANY TO ONE JOIN project_MadResults AS MadResults ON (MadResults.code = madResult),
  MANY TO ONE JOIN project_AdaptionsTypes AS AdaptionsTypes ON (AdaptionsTypes.code = adaptionsType),
  MANY TO ONE JOIN project_FeasibilityExplanations AS RealStateFeasibilityExplanations ON (RealStateFeasibilityExplanations.code = realEstateFeasibilityExp),
  MANY TO ONE JOIN project_FeasibilityExplanations AS PermitsFeasibilityExplanations ON (PermitsFeasibilityExplanations.code = permitsFeasibilityExp)
);

CREATE VIEW localized_project_WORK_PARENT_TYPES_texts AS SELECT
  texts_0.LOCALE,
  texts_0.NAME,
  texts_0.DESCR,
  texts_0.ID
FROM WORK_PARENT_TYPES_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_WORK_PARENT_TYPES AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_project_ChecklistItems AS SELECT
  Item_0.ID,
  Item_0.description,
  Item_0.type_ID,
  Item_0.mandatory,
  Item_0.booleanValue,
  Item_0.stringValue,
  Item_0.dateValue,
  Item_0.integerValue,
  Item_0.decimalValue,
  Item_0.pickList,
  Item_0.block_ID,
  Item_0.deleted
FROM Checklist_Item AS Item_0
WHERE Item_0.deleted != TRUE
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_ItemType AS type ON (type.ID = type_ID),
  MANY TO ONE JOIN localized_project_Blocks AS block ON (block.ID = block_ID)
);

CREATE VIEW localized_project_ItemType_texts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.description
FROM Checklist_ItemType_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_ItemType AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_project_FieldType_texts AS SELECT
  texts_0.locale,
  texts_0.name,
  texts_0.descr,
  texts_0.ID
FROM Checklist_FieldType_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_FieldType AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_project_ItemTypeValue_texts AS SELECT
  texts_0.locale,
  texts_0.ID,
  texts_0.description
FROM Checklist_ItemTypeValue_texts AS texts_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_ItemTypeValue AS parent ON (parent.ID = ID)
);

CREATE VIEW localized_checklistconfiguration_ItemConfigurations AS SELECT
  ItemConfiguration_0.ID,
  ItemConfiguration_0.createdAt,
  ItemConfiguration_0.createdBy,
  ItemConfiguration_0.modifiedAt,
  ItemConfiguration_0.modifiedBy,
  ItemConfiguration_0.description,
  ItemConfiguration_0.active,
  ItemConfiguration_0.deletedAt,
  ItemConfiguration_0.deletedBy
FROM Checklist_ItemConfiguration AS ItemConfiguration_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_checklistconfiguration_ItemConfigurationTypes AS types ON (types.configuration_ID = ID),
  MANY TO MANY JOIN localized_checklistconfiguration_ItemConfigurationProcesses AS processes ON (processes.configuration_ID = ID),
  MANY TO MANY JOIN localized_checklistconfiguration_ItemConfigurationBlocks AS blocks ON (blocks.configuration_ID = ID)
);

CREATE VIEW localized_project_RequestProvision AS SELECT
  REQUEST_CHAR_PRO_0.REQUEST_ID AS ID,
  REQUEST_CHAR_PRO_0.REQUESTED_DATE AS requestedDate,
  REQUEST_CHAR_PRO_0.REQUESTER AS requester,
  REQUEST_CHAR_PRO_0.FORESCAST_DONE AS forecastDone,
  REQUEST_CHAR_PRO_0.PMO_MANAGER AS PMOManager,
  REQUEST_CHAR_PRO_0.PREFERRED_PROVIDER AS preferredProvider,
  REQUEST_CHAR_PRO_0.PREFERRED_PROVIDER_NAME AS preferredProviderName,
  REQUEST_CHAR_PRO_0.CLASIFICATION AS classification,
  REQUEST_CHAR_PRO_0.SF_OPPORTUNITY_ID AS salesforceRequestId,
  REQUEST_CHAR_PRO_0.PROJECT_OBJECTIVE AS projectObjective,
  REQUEST_CHAR_PRO_0.MOA_OPERATION AS moaOperation
FROM REQUEST_CHAR_PRO AS REQUEST_CHAR_PRO_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_Requests AS Requests ON (Requests.ID = ID),
  MANY TO ONE JOIN project_Classifications AS Classifications ON (Classifications.code = classification),
  MANY TO ONE JOIN project_PreferredProviders AS PreferredProviders ON (PreferredProviders.code = preferredProvider),
  MANY TO ONE JOIN project_MoaOperationTypes AS MoaOperationTypes ON (MoaOperationTypes.code = moaOperation),
  MANY TO ONE JOIN project_CacheR3Entities AS CacheR3Entities ON (CacheR3Entities.code = preferredProvider),
  MANY TO ONE JOIN project_PMOManagers AS PMOManagers ON (PMOManagers.userId = PMOManager),
  MANY TO ONE JOIN project_Requesters AS Requesters ON (Requesters.userId = requester),
  MANY TO ONE JOIN project_ProjectObjectives AS ProjectObjectives ON (ProjectObjectives.ID = projectObjective)
);

CREATE VIEW localized_project_RequestDocumentsPerBlockDefaultValid AS SELECT
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.REGISTER_ID AS ID,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DOCUMENT_ID AS documentId,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.REQUEST_ID AS requestId,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.APPROVER_TYPE AS responsibleId,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.SUBCONTRACTOR AS subcontractorId,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DEFAULT_RESPONSIBLE AS responsibleDefault,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.SUBCO_REQ_VAL AS subcontractorValidation,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.CELLNEX_REQ_VAL AS cellnexValidation,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.CUSTOMER__REQ_VAL AS customerValidation,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.SITEOWNER_REQ_VAL AS siteOwnerValidation,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.CREATEDAT AS createdAt,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.CREATEDBY AS createdBy,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DELETED AS deleted,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DELETED_AT AS deletedAt,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.DELETED_BY AS deletebBy,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.MODIFIEDAT AS modifiedAt,
  REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0.MODIFIEDBY AS modifiedBy
FROM REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID AS REQUEST_DOCUMENTS_PER_BLOCK_DEFAUL_VALID_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_project_Requests AS Requests ON (Requests.ID = requestId),
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = responsibleId),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcontractorId),
  MANY TO ONE JOIN project_DocumentFlowDefaultValidDocumentId AS DocumentFlowDefaultValidDocumentId ON (DocumentFlowDefaultValidDocumentId.documentId = documentId),
  MANY TO ONE JOIN project_DocumentFlowResponsiblesDefaultValid AS DocumentFlowResponsiblesDefaultValid ON (DocumentFlowResponsiblesDefaultValid.code = responsibleDefault)
);

CREATE VIEW localized_project_Phases AS SELECT
  PHASE_HEAD_0.PHASE_ID AS ID,
  PHASE_HEAD_0.CREATEDAT AS createdAt,
  PHASE_HEAD_0.CREATEDBY AS createdBy,
  PHASE_HEAD_0.DELETED AS deleted,
  PHASE_HEAD_0.DELETED_AT AS deletedAt,
  PHASE_HEAD_0.DELETED_BY AS deletedBy,
  PHASE_HEAD_0.ENDED_AT AS closedAt,
  PHASE_HEAD_0.MASTER_PHASE_ID AS processFlowId,
  PHASE_HEAD_0.MODIFIEDAT AS changedAt,
  PHASE_HEAD_0.MODIFIEDBY AS changedBy,
  PHASE_HEAD_0.PHASE_OWNER AS owner,
  PHASE_HEAD_0.PHASE_STATUS AS status,
  PHASE_HEAD_0.REQUEST_ID AS requestId,
  PHASE_HEAD_0.STARTED_AT AS openAt
FROM PHASE_HEAD AS PHASE_HEAD_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_project_Blocks AS Blocks ON (Blocks.phaseId = ID),
  MANY TO ONE JOIN localized_project_Requests AS Requests ON (Requests.ID = requestId),
  MANY TO ONE JOIN project_PhaseStatus AS PhaseStatus ON (PhaseStatus.code = status),
  MANY TO MANY JOIN project_SupportDocuments AS SupportDocuments ON (SupportDocuments.phaseName = processFlowId AND SupportDocuments.requestId = requestId)
);

CREATE VIEW localized_project_Blocks AS SELECT
  BLOCK_HEAD_0.BLOCK_ID AS ID,
  BLOCK_HEAD_0.ACTIVATED AS activated,
  BLOCK_HEAD_0.BLOCK_STATUS AS status,
  BLOCK_HEAD_0.COMMENTS AS comments,
  BLOCK_HEAD_0.COMMENTS AS commentsPLU,
  BLOCK_HEAD_0.CREATEDAT AS createdAt,
  BLOCK_HEAD_0.CREATEDBY AS createdBy,
  BLOCK_HEAD_0.DELETED_AT AS deletedAt,
  BLOCK_HEAD_0.DELETED_BY AS deletedBy,
  BLOCK_HEAD_0.ENDED_AT AS closedAt,
  BLOCK_HEAD_0.MASTER_BLOCK_ID AS processFlowId,
  BLOCK_HEAD_0.MODIFIEDAT AS modifiedAt,
  BLOCK_HEAD_0.MODIFIEDBY AS modifiedBy,
  BLOCK_HEAD_0.PHASE_ID AS phaseId,
  BLOCK_HEAD_0.ROLE_ID AS role,
  BLOCK_HEAD_0.STARTED_AT AS openAt,
  BLOCK_HEAD_0.MANDATORY AS mandatory,
  BLOCK_HEAD_0.OWNER_ID AS owner
FROM BLOCK_HEAD AS BLOCK_HEAD_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_Phases AS Phases ON (Phases.ID = phaseId),
  MANY TO ONE JOIN localized_project_BlockProvision AS BlockProvision ON (BlockProvision.ID = ID),
  MANY TO MANY JOIN localized_project_Works AS Works ON (Works.parentId = ID AND Works.parentType_ID = 30),
  MANY TO MANY JOIN localized_project_ChecklistItems AS Checklist ON (Checklist.block_ID = ID),
  MANY TO ONE JOIN project_BlockStatus AS BlockStatus ON (BlockStatus.code = status),
  MANY TO MANY JOIN project_Documents AS Documents ON (Documents.blockId = ID AND Documents.workId IS NULL),
  MANY TO MANY JOIN project_SupportDocuments AS SupportDocuments ON (SupportDocuments.blockId = ID),
  MANY TO MANY JOIN project_ContractRestrictions AS ContractRestrictions ON (ContractRestrictions.BLOCK_ID = ID),
  MANY TO MANY JOIN localized_project_DocumentsPerBlocks AS DocumentsPerBlocks ON (DocumentsPerBlocks.blockId = ID),
  MANY TO MANY JOIN project_AttachmentDocumentTypes AS AttachmentDocumentTypes ON (AttachmentDocumentTypes.BLOCK_ID = ID)
);

CREATE VIEW localized_checklistconfiguration_ItemConfigurationProcesses AS SELECT
  ItemConfigurationProcess_0.ID,
  ItemConfigurationProcess_0.createdAt,
  ItemConfigurationProcess_0.createdBy,
  ItemConfigurationProcess_0.modifiedAt,
  ItemConfigurationProcess_0.modifiedBy,
  ItemConfigurationProcess_0.processId,
  ItemConfigurationProcess_0.configuration_ID
FROM Checklist_ItemConfigurationProcess AS ItemConfigurationProcess_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_checklistconfiguration_ItemConfigurations AS configuration ON (configuration.ID = configuration_ID)
);

CREATE VIEW localized_checklistconfiguration_ItemConfigurationBlocks AS SELECT
  ItemConfigurationBlock_0.ID,
  ItemConfigurationBlock_0.createdAt,
  ItemConfigurationBlock_0.createdBy,
  ItemConfigurationBlock_0.modifiedAt,
  ItemConfigurationBlock_0.modifiedBy,
  ItemConfigurationBlock_0.phaseType,
  ItemConfigurationBlock_0.blockType,
  ItemConfigurationBlock_0.configuration_ID
FROM Checklist_ItemConfigurationBlock AS ItemConfigurationBlock_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_checklistconfiguration_ItemConfigurations AS configuration ON (configuration.ID = configuration_ID)
);

CREATE VIEW localized_project_DocumentsPerBlocks AS SELECT
  DOCUMENTS_PER_BLOCK_0.REGISTER_ID AS ID,
  DOCUMENTS_PER_BLOCK_0.BLOCK_ID AS blockId,
  DOCUMENTS_PER_BLOCK_0.CREATEDAT AS createdAt,
  DOCUMENTS_PER_BLOCK_0.CREATEDBY AS createdBy,
  DOCUMENTS_PER_BLOCK_0.DELETED AS deleted,
  DOCUMENTS_PER_BLOCK_0.DELETED_AT AS deletedAt,
  DOCUMENTS_PER_BLOCK_0.DELETED_BY AS deletedBy,
  DOCUMENTS_PER_BLOCK_0.MODIFIEDAT AS modifiedAt,
  DOCUMENTS_PER_BLOCK_0.MODIFIEDBY AS modifiedBy,
  DOCUMENTS_PER_BLOCK_0."ORDER" AS "ORDER",
  DOCUMENTS_PER_BLOCK_0.RESPONSIBLE_ID AS responsibleId,
  DOCUMENTS_PER_BLOCK_0.SUBCONTRATOR_ID AS subcontractorId,
  DOCUMENTS_PER_BLOCK_0.T_RESPONSIBLE AS responsibleDefault,
  DOCUMENTS_PER_BLOCK_0.VALIDATION_CELLNEX_CLIENT AS cellnexValidation,
  DOCUMENTS_PER_BLOCK_0.VALIDATION_REQ_CLIENT AS customerValidation,
  DOCUMENTS_PER_BLOCK_0.VALIDATION_SUBCO_CLIENT AS subcontractorValidation,
  DOCUMENTS_PER_BLOCK_0.VALIDATION_SITEOWNER_NEEDED AS siteOwnerValidation,
  DOCUMENTS_PER_BLOCK_0.GENERIC_TYPE_ID AS documentId,
  DOCUMENTS_PER_BLOCK_0.TYPE_ID AS typeId,
  DOCUMENTS_PER_BLOCK_0.STATUS AS status,
  DOCUMENTS_PER_BLOCK_0.PERMIT_ID AS jointProjectId,
  DOCUMENTS_PER_BLOCK_0.STEP_ID AS masterBlock_id,
  DOCUMENTS_PER_BLOCK_0.WORK_ID AS workId
FROM DOCUMENTS_PER_BLOCK AS DOCUMENTS_PER_BLOCK_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_Blocks AS Blocks ON (Blocks.ID = ID),
  MANY TO ONE JOIN localized_project_InstancesPerDocuments AS InstancesPerDocuments ON (InstancesPerDocuments.instanceId = ID),
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = responsibleId),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcontractorId)
);

CREATE VIEW localized_project_InstancesPerDocuments AS SELECT
  INSTANCES_PER_DOCUMENT_0.REGISTER_ID AS ID,
  INSTANCES_PER_DOCUMENT_0.CELLNEX_COMMENT AS cellnexComment,
  INSTANCES_PER_DOCUMENT_0.CELLNEX_VALIDATION AS cellnexValidation,
  INSTANCES_PER_DOCUMENT_0.CELLNEX_VALIDATION_DATE AS cellnexValidationDate,
  INSTANCES_PER_DOCUMENT_0.CELLNEX_VALIDATOR AS cellnexValidator,
  INSTANCES_PER_DOCUMENT_0.CONTACT_EMAIL AS contactEmail,
  INSTANCES_PER_DOCUMENT_0.CONTACT_PHONE AS contactPhone,
  INSTANCES_PER_DOCUMENT_0.CREATEDAT AS createdAt,
  INSTANCES_PER_DOCUMENT_0.CREATEDBY AS createdBy,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_COMMENT AS customerComment,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_VALIDATION AS customerValidation,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_VALIDATION_DATE AS customerValidationDate,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_VALIDATOR AS customerValidator,
  INSTANCES_PER_DOCUMENT_0.DELETED AS deleted,
  INSTANCES_PER_DOCUMENT_0.DELETED_AT AS deletedAt,
  INSTANCES_PER_DOCUMENT_0.DELETED_BY AS deletedBy,
  INSTANCES_PER_DOCUMENT_0.DOC_PB_ID AS jointProjectId,
  INSTANCES_PER_DOCUMENT_0.DOCUMENT_ID_DOSSIER_ATTACHED AS requestCodeOrigin,
  INSTANCES_PER_DOCUMENT_0.END_DATE AS endDate,
  INSTANCES_PER_DOCUMENT_0.INSTANCE_ID AS instanceId,
  INSTANCES_PER_DOCUMENT_0.MODIFIEDAT AS modifiedAt,
  INSTANCES_PER_DOCUMENT_0.MODIFIEDBY AS modifiedBy,
  INSTANCES_PER_DOCUMENT_0.SITEOWNER_COMMENT AS siteOwnerComment,
  INSTANCES_PER_DOCUMENT_0.SITEOWNER_VALIDATION AS siteOwnerValidation,
  INSTANCES_PER_DOCUMENT_0.SITEOWNER_VALIDATION_DATE AS siteOwnerValidationDate,
  INSTANCES_PER_DOCUMENT_0.SITEOWNER_VALIDATOR AS siteOwnerValidator,
  INSTANCES_PER_DOCUMENT_0.START_DATE AS startDate,
  INSTANCES_PER_DOCUMENT_0.SUBCONTRACTOR_COMMENT AS subcontractorComment,
  INSTANCES_PER_DOCUMENT_0.SUBCONTRACTOR_VALIDATION AS subcontractorValidation,
  INSTANCES_PER_DOCUMENT_0.SUBCONTRACTOR_VALIDATION_DATE AS subcontractorValidationDate,
  INSTANCES_PER_DOCUMENT_0.SUBCONTRACTOR_VALIDATOR AS subcontractorValidator,
  INSTANCES_PER_DOCUMENT_0.SUBMISSION_DATE AS submissionDate,
  INSTANCES_PER_DOCUMENT_0.T_GO AS tasksActivated,
  INSTANCES_PER_DOCUMENT_0.VERSION AS version,
  INSTANCES_PER_DOCUMENT_0.BLOCK_ID AS blockId,
  INSTANCES_PER_DOCUMENT_0.STEP_ID AS stepId,
  INSTANCES_PER_DOCUMENT_0.STEP_TXT AS stepName,
  INSTANCES_PER_DOCUMENT_0.ASSIGNED_ROLE AS assignedRole,
  INSTANCES_PER_DOCUMENT_0.EXPECTED_SUBMISSION_DATE AS expectedSubmissionDate,
  INSTANCES_PER_DOCUMENT_0.EXPECTED_CUSTOMER_VAL AS expectedCustValidationDate,
  INSTANCES_PER_DOCUMENT_0.EXPECTED_CELLNEX_VAL AS expectedCellValidationDate,
  INSTANCES_PER_DOCUMENT_0.EXPIRATION_DATE AS expirationDate,
  INSTANCES_PER_DOCUMENT_0.PLANNED_SUBMISSION_DATE AS plannedSubmissionDate,
  INSTANCES_PER_DOCUMENT_0.CANCELLATION_REASON AS cancellationReason,
  INSTANCES_PER_DOCUMENT_0.MODIFIEDBULK_AT AS modifiedBulkAt,
  INSTANCES_PER_DOCUMENT_0.MODIFIEDBULK_BY AS modifiedBulkBy,
  INSTANCES_PER_DOCUMENT_0.CREATEDBULK_AT AS createdBulkAt,
  INSTANCES_PER_DOCUMENT_0.CREATEDBULK_BY AS createdBulkBy,
  INSTANCES_PER_DOCUMENT_0.DELETEDBULK_AT AS deletedBulkAt,
  INSTANCES_PER_DOCUMENT_0.DELETEDBULK_BY AS deletedBulkBy,
  INSTANCES_PER_DOCUMENT_0.ASSIGNED_RESPONSIBLE AS assignedResponsible,
  INSTANCES_PER_DOCUMENT_0.SUBCO_ASSIGNED AS assignedSubcontractor,
  INSTANCES_PER_DOCUMENT_0.FORECAST_NA AS forecastNA,
  INSTANCES_PER_DOCUMENT_0.DOCUMENT_ID_SENT_CUSTOMER AS taskCode,
  INSTANCES_PER_DOCUMENT_0.CUSTOMER_INFORM_DATE AS customerInformDate,
  INSTANCES_PER_DOCUMENT_0.DOCUMENTS_RESPONSIBLE_COMMENTS AS documentsResponsibleComments,
  INSTANCES_PER_DOCUMENT_0.LIMIT_SUBMISSION_DATE AS limitSubmissionDate
FROM INSTANCES_PER_DOCUMENT AS INSTANCES_PER_DOCUMENT_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_DocumentsPerBlocks AS DocumentsPerBlocks ON (DocumentsPerBlocks.ID = instanceId),
  MANY TO MANY JOIN project_Documents AS Documents ON (Documents.instanceId = ID),
  MANY TO MANY JOIN project_LocalDocuments AS LocalDocuments ON (LocalDocuments.instanceId = ID),
  MANY TO ONE JOIN project_PreferredProviders AS PreferredProviders ON (PreferredProviders.code = subcontractorValidator)
);

CREATE VIEW checklistconfiguration_DraftAdministrativeData AS SELECT
  DraftAdministrativeData.DraftUUID,
  DraftAdministrativeData.CreationDateTime,
  DraftAdministrativeData.CreatedByUser,
  DraftAdministrativeData.DraftIsCreatedByMe,
  DraftAdministrativeData.LastChangeDateTime,
  DraftAdministrativeData.LastChangedByUser,
  DraftAdministrativeData.InProcessByUser,
  DraftAdministrativeData.DraftIsProcessedByMe
FROM DRAFT_DraftAdministrativeData AS DraftAdministrativeData;

CREATE VIEW project_DraftAdministrativeData AS SELECT
  DraftAdministrativeData.DraftUUID,
  DraftAdministrativeData.CreationDateTime,
  DraftAdministrativeData.CreatedByUser,
  DraftAdministrativeData.DraftIsCreatedByMe,
  DraftAdministrativeData.LastChangeDateTime,
  DraftAdministrativeData.LastChangedByUser,
  DraftAdministrativeData.InProcessByUser,
  DraftAdministrativeData.DraftIsProcessedByMe
FROM DRAFT_DraftAdministrativeData AS DraftAdministrativeData;

CREATE VIEW workconfiguration_DraftAdministrativeData AS SELECT
  DraftAdministrativeData.DraftUUID,
  DraftAdministrativeData.CreationDateTime,
  DraftAdministrativeData.CreatedByUser,
  DraftAdministrativeData.DraftIsCreatedByMe,
  DraftAdministrativeData.LastChangeDateTime,
  DraftAdministrativeData.LastChangedByUser,
  DraftAdministrativeData.InProcessByUser,
  DraftAdministrativeData.DraftIsProcessedByMe
FROM DRAFT_DraftAdministrativeData AS DraftAdministrativeData;

CREATE VIEW project_DocumentsPerRequest AS SELECT
  DOCUMENTS_PER_REQUEST_0.ID,
  DOCUMENTS_PER_REQUEST_0.requestId,
  DOCUMENTS_PER_REQUEST_0.phaseFlowId,
  DOCUMENTS_PER_REQUEST_0.phaseId,
  DOCUMENTS_PER_REQUEST_0.blockFlowId,
  DOCUMENTS_PER_REQUEST_0.blockId,
  DOCUMENTS_PER_REQUEST_0.createdAt,
  DOCUMENTS_PER_REQUEST_0.createdBy,
  DOCUMENTS_PER_REQUEST_0.deleted,
  DOCUMENTS_PER_REQUEST_0.deletedAt,
  DOCUMENTS_PER_REQUEST_0.deletedBy,
  DOCUMENTS_PER_REQUEST_0.modifiedAt,
  DOCUMENTS_PER_REQUEST_0.modifiedBy,
  DOCUMENTS_PER_REQUEST_0."ORDER",
  DOCUMENTS_PER_REQUEST_0.responsibleDefault,
  DOCUMENTS_PER_REQUEST_0.responsibleId,
  DOCUMENTS_PER_REQUEST_0.subcontractorId,
  DOCUMENTS_PER_REQUEST_0.cellnexValidation,
  DOCUMENTS_PER_REQUEST_0.customerValidation,
  DOCUMENTS_PER_REQUEST_0.subcontractorValidation,
  DOCUMENTS_PER_REQUEST_0.siteOwnerValidation,
  DOCUMENTS_PER_REQUEST_0.documentId,
  DOCUMENTS_PER_REQUEST_0.status,
  DOCUMENTS_PER_REQUEST_0.cellnexResponsible,
  DOCUMENTS_PER_REQUEST_0.subcontractorResponsible,
  DOCUMENTS_PER_REQUEST_0.agencyResponsible,
  DOCUMENTS_PER_REQUEST_0.customerResponsible,
  DOCUMENTS_PER_REQUEST_0.cellnexResponsibleName,
  DOCUMENTS_PER_REQUEST_0.subcontractorResponsibleName,
  DOCUMENTS_PER_REQUEST_0.agencyResponsibleName,
  DOCUMENTS_PER_REQUEST_0.customerResponsibleName,
  DOCUMENTS_PER_REQUEST_0.cellnexResponsibleFC,
  DOCUMENTS_PER_REQUEST_0.subcontractorResponsibleFC,
  DOCUMENTS_PER_REQUEST_0.agencyResponsibleFC,
  DOCUMENTS_PER_REQUEST_0.customerResponsibleFC,
  DOCUMENTS_PER_REQUEST_0.approverTypeName,
  DOCUMENTS_PER_REQUEST_0.approverTypeFC,
  DOCUMENTS_PER_REQUEST_0.subcoTypeName,
  DOCUMENTS_PER_REQUEST_0.subcoTypeFC,
  DOCUMENTS_PER_REQUEST_0.responsibleDefaultName,
  DOCUMENTS_PER_REQUEST_0.responsibleDefaultFC,
  DOCUMENTS_PER_REQUEST_0.cellnexValidationFC,
  DOCUMENTS_PER_REQUEST_0.subcontractorValidationFC,
  DOCUMENTS_PER_REQUEST_0.customerValidationFC,
  DOCUMENTS_PER_REQUEST_0.siteOwnerValidationFC,
  DOCUMENTS_PER_REQUEST_0.cellnexValidatorFC,
  DOCUMENTS_PER_REQUEST_0.subcontractorValidatorFC,
  DOCUMENTS_PER_REQUEST_0.customerValidatorFC,
  DOCUMENTS_PER_REQUEST_0.siteOwnerValidatorFC,
  DOCUMENTS_PER_REQUEST_0.documentIdFC,
  DOCUMENTS_PER_REQUEST_0.Criticality,
  DOCUMENTS_PER_REQUEST_0.stepIdVF,
  DOCUMENTS_PER_REQUEST_0.statusIconVF,
  DOCUMENTS_PER_REQUEST_0.statusStateVF,
  DOCUMENTS_PER_REQUEST_0.statusTextVF,
  DOCUMENTS_PER_REQUEST_0.cellnexStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.cellnexStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.cellnexStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.responsibleStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.responsibleStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.responsibleStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.subcontractorStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.subcontractorStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.subcontractorStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.customerStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.customerStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.customerStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.siteOwnerStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.siteOwnerStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.siteOwnerStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.canInit,
  DOCUMENTS_PER_REQUEST_0.canSee,
  DOCUMENTS_PER_REQUEST_0.canDelete,
  DOCUMENTS_PER_REQUEST_0.canDownload,
  DOCUMENTS_PER_REQUEST_0.cellnexValidationVF,
  DOCUMENTS_PER_REQUEST_0.subcontractorValidationVF,
  DOCUMENTS_PER_REQUEST_0.customerValidationVF,
  DOCUMENTS_PER_REQUEST_0.siteOwnerValidationVF
FROM DOCUMENTS_PER_REQUEST AS DOCUMENTS_PER_REQUEST_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_Blocks AS Blocks ON (Blocks.ID = ID),
  MANY TO ONE JOIN project_InstancesPerDocuments AS InstancesPerDocuments ON (InstancesPerDocuments.instanceId = ID),
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = responsibleId),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcontractorId),
  MANY TO ONE JOIN project_DocumentFlowResponsibles AS DocumentFlowResponsibles ON (DocumentFlowResponsibles.code = responsibleDefault)
);

CREATE VIEW project_Customers(IN p_siteId NVARCHAR(30)) AS SELECT
  CUSTOMERS_0.siteId,
  CUSTOMERS_0.customerId,
  CUSTOMERS_0.siteName,
  CUSTOMERS_0.customerName,
  CUSTOMERS_0.alias,
  CUSTOMERS_0.aliasName,
  CUSTOMERS_0.aliasServ,
  CUSTOMERS_0.aliasOther,
  CUSTOMERS_0.aliasClientArea,
  CUSTOMERS_0.aliasKey
FROM CUSTOMERS(p_siteId => :P_SITEID) AS CUSTOMERS_0;

CREATE VIEW project_AcceptedRejected AS SELECT
  ACCEPTED_REJECTED_0.code,
  ACCEPTED_REJECTED_0.name,
  ACCEPTED_REJECTED_0.country
FROM ACCEPTED_REJECTED AS ACCEPTED_REJECTED_0;

CREATE VIEW project_BlockStatus AS SELECT
  localized_BLOCK_STATUS_0.name,
  localized_BLOCK_STATUS_0.descr,
  localized_BLOCK_STATUS_0.code
FROM localized_BLOCK_STATUS AS localized_BLOCK_STATUS_0;

CREATE VIEW project_DocumentFlowStatus AS SELECT
  localized_DOCUMENT_FLOW_STATUS_0.name,
  localized_DOCUMENT_FLOW_STATUS_0.descr,
  localized_DOCUMENT_FLOW_STATUS_0.code
FROM localized_DOCUMENT_FLOW_STATUS AS localized_DOCUMENT_FLOW_STATUS_0;

CREATE VIEW project_OnHoldReasons AS SELECT
  ON_HOLD_REASONS_0.code,
  ON_HOLD_REASONS_0.name,
  ON_HOLD_REASONS_0.country
FROM ON_HOLD_REASONS AS ON_HOLD_REASONS_0;

CREATE VIEW project_PhaseStatus AS SELECT
  localized_PHASE_STATUS_0.name,
  localized_PHASE_STATUS_0.descr,
  localized_PHASE_STATUS_0.code
FROM localized_PHASE_STATUS AS localized_PHASE_STATUS_0;

CREATE VIEW project_RequestStatus AS SELECT
  localized_REQUEST_STATUS_0.name,
  localized_REQUEST_STATUS_0.descr,
  localized_REQUEST_STATUS_0.code
FROM localized_REQUEST_STATUS AS localized_REQUEST_STATUS_0;

CREATE VIEW project_SearchTypes AS SELECT
  localized_SEARCH_TYPES_0.name,
  localized_SEARCH_TYPES_0.descr,
  localized_SEARCH_TYPES_0.code
FROM localized_SEARCH_TYPES AS localized_SEARCH_TYPES_0;

CREATE VIEW project_StatusHead AS SELECT
  localized_STATUS_HEAD_0.code,
  localized_STATUS_HEAD_0.name
FROM localized_STATUS_HEAD AS localized_STATUS_HEAD_0
WHERE localized_STATUS_HEAD_0.code IN (2, 3, 4, 7, 12, 13);

CREATE VIEW project_TaskTypes AS SELECT
  localized_TASK_TYPES_0.name,
  localized_TASK_TYPES_0.descr,
  localized_TASK_TYPES_0.code
FROM localized_TASK_TYPES AS localized_TASK_TYPES_0;

CREATE VIEW project_CancellationReasons AS SELECT
  CANCELLATION_REASONS_0.code,
  CANCELLATION_REASONS_0.name,
  CANCELLATION_REASONS_0.country
FROM CANCELLATION_REASONS AS CANCELLATION_REASONS_0;

CREATE VIEW project_ChangesLog AS SELECT
  CHANGE_LOG_0.logId,
  CHANGE_LOG_0.requestId,
  CHANGE_LOG_0.requestType,
  CHANGE_LOG_0.changeDate,
  CHANGE_LOG_0.userId,
  CHANGE_LOG_0.userName,
  CHANGE_LOG_0.userAction,
  CHANGE_LOG_0.userActionName,
  CHANGE_LOG_0.phaseProcessFlowId,
  CHANGE_LOG_0.phaseName,
  CHANGE_LOG_0.blockProcessFlowId,
  CHANGE_LOG_0.blockName,
  CHANGE_LOG_0.fieldName,
  CHANGE_LOG_0.fieldDescription,
  CHANGE_LOG_0.oldValue,
  CHANGE_LOG_0.oldValueDescription,
  CHANGE_LOG_0.newValue,
  CHANGE_LOG_0.newValueDescription,
  CHANGE_LOG_0.phaseId,
  CHANGE_LOG_0.BlockId,
  CHANGE_LOG_0.documentName,
  CHANGE_LOG_0.workType,
  CHANGE_LOG_0.workTypeName
FROM CHANGE_LOG AS CHANGE_LOG_0;

CREATE VIEW project_Classifications AS SELECT
  CLASSIFICATIONS_0.code,
  CLASSIFICATIONS_0.name,
  CLASSIFICATIONS_0.country
FROM CLASSIFICATIONS AS CLASSIFICATIONS_0;

CREATE VIEW project_PreferredProviders AS SELECT
  PREFERRED_PROVIDERS_0.code,
  PREFERRED_PROVIDERS_0.name
FROM PREFERRED_PROVIDERS AS PREFERRED_PROVIDERS_0;

CREATE VIEW project_ApproverTypes AS SELECT
  APPROVER_TYPES_0.code,
  APPROVER_TYPES_0.name,
  APPROVER_TYPES_0.country
FROM APPROVER_TYPES AS APPROVER_TYPES_0;

CREATE VIEW project_SubcoTypes AS SELECT
  SUBCO_TYPES_0.code,
  SUBCO_TYPES_0.name,
  SUBCO_TYPES_0.country
FROM SUBCO_TYPES AS SUBCO_TYPES_0
WHERE SUBCO_TYPES_0.code IN (3, 4);

CREATE VIEW project_YesNoFields AS SELECT
  YES_NO_FIELDS_0.code,
  YES_NO_FIELDS_0.name,
  YES_NO_FIELDS_0.country
FROM YES_NO_FIELDS AS YES_NO_FIELDS_0;

CREATE VIEW project_ValidationDocs AS SELECT
  VALIDATIONS_DOCS_0.code,
  VALIDATIONS_DOCS_0.name,
  VALIDATIONS_DOCS_0.country
FROM VALIDATIONS_DOCS AS VALIDATIONS_DOCS_0;

CREATE VIEW project_WorkDocuments AS SELECT
  WORK_DOCUMENTS_VH_0.documentId,
  WORK_DOCUMENTS_VH_0.documentName,
  WORK_DOCUMENTS_VH_0.countryId,
  WORK_DOCUMENTS_VH_0.objective,
  WORK_DOCUMENTS_VH_0.processFlowId,
  WORK_DOCUMENTS_VH_0.phaseTypeId,
  WORK_DOCUMENTS_VH_0.blockTypeId,
  WORK_DOCUMENTS_VH_0.workType,
  WORK_DOCUMENTS_VH_0.workId
FROM WORK_DOCUMENTS_VH AS WORK_DOCUMENTS_VH_0;

CREATE VIEW project_ProjectObjectives AS SELECT
  PROJECT_OBJECTIVES_CONFIG_BY_PROCESS_0.ID,
  PROJECT_OBJECTIVES_CONFIG_BY_PROCESS_0.name,
  PROJECT_OBJECTIVES_CONFIG_BY_PROCESS_0.PROGRAM
FROM PROJECT_OBJECTIVES_CONFIG_BY_PROCESS AS PROJECT_OBJECTIVES_CONFIG_BY_PROCESS_0;

CREATE VIEW project_DocumentsPerProcess AS SELECT
  DOCUMENTS_PER_PROCESS_0.processFlowId,
  DOCUMENTS_PER_PROCESS_0.phaseProcessFlowId,
  DOCUMENTS_PER_PROCESS_0.blockProcessFlowId,
  DOCUMENTS_PER_PROCESS_0.documentId,
  DOCUMENTS_PER_PROCESS_0.documentName
FROM DOCUMENTS_PER_PROCESS AS DOCUMENTS_PER_PROCESS_0;

CREATE VIEW project_FeasibilitiesWithRisks AS SELECT
  FEASIBILITIES_WITH_RISKS_0.code,
  FEASIBILITIES_WITH_RISKS_0.name,
  FEASIBILITIES_WITH_RISKS_0.country
FROM FEASIBILITIES_WITH_RISKS AS FEASIBILITIES_WITH_RISKS_0;

CREATE VIEW project_Risks AS SELECT
  RISKS_0.code,
  RISKS_0.name,
  RISKS_0.country
FROM RISKS AS RISKS_0;

CREATE VIEW project_AdaptionsNeededFields AS SELECT
  ADAPTIONS_NEEDED_FIELDS_0.code,
  ADAPTIONS_NEEDED_FIELDS_0.name,
  ADAPTIONS_NEEDED_FIELDS_0.country
FROM ADAPTIONS_NEEDED_FIELDS AS ADAPTIONS_NEEDED_FIELDS_0;

CREATE VIEW project_AutomaticFields AS SELECT
  AUTOMATIC_FIELDS_0.code,
  AUTOMATIC_FIELDS_0.name,
  AUTOMATIC_FIELDS_0.country
FROM AUTOMATIC_FIELDS AS AUTOMATIC_FIELDS_0;

CREATE VIEW project_RejectionReasons AS SELECT
  REJECTION_REASONS_0.code,
  REJECTION_REASONS_0.name,
  REJECTION_REASONS_0.country
FROM REJECTION_REASONS AS REJECTION_REASONS_0;

CREATE VIEW project_ItemTypeValues AS SELECT
  localized_ItemTypeValue_0.pickList,
  localized_ItemTypeValue_0.itemType_ID,
  localized_ItemTypeValue_0.description,
  localized_ItemTypeValue_0.active
FROM Checklist_localized_ItemTypeValue AS localized_ItemTypeValue_0
WHERE localized_ItemTypeValue_0.active = TRUE;

CREATE VIEW project_ItemTypes AS SELECT
  localized_ItemType_0.ID,
  localized_ItemType_0.description,
  localized_ItemType_0.active
FROM Checklist_localized_ItemType AS localized_ItemType_0
WHERE localized_ItemType_0.active = TRUE;

CREATE VIEW project_Complexities AS SELECT
  COMPLEXITIES_0.code,
  COMPLEXITIES_0.name,
  COMPLEXITIES_0.country
FROM COMPLEXITIES AS COMPLEXITIES_0;

CREATE VIEW project_MadResults AS SELECT
  MAD_RESULTS_0.code,
  MAD_RESULTS_0.name,
  MAD_RESULTS_0.country
FROM MAD_RESULTS AS MAD_RESULTS_0;

CREATE VIEW project_AdaptionsTypes AS SELECT
  ADAPTIONS_TYPES_0.code,
  ADAPTIONS_TYPES_0.name,
  ADAPTIONS_TYPES_0.country
FROM ADAPTIONS_TYPES AS ADAPTIONS_TYPES_0;

CREATE VIEW project_CellnexZones AS SELECT
  CELLNEX_ZONES_0.code,
  CELLNEX_ZONES_0.description
FROM CELLNEX_ZONES AS CELLNEX_ZONES_0;

CREATE VIEW project_Zones AS SELECT
  ZONES_0.code,
  ZONES_0.description
FROM ZONES AS ZONES_0;

CREATE VIEW project_InfraOrigins AS SELECT
  INFRA_ORIGINS_0.code,
  INFRA_ORIGINS_0.description
FROM INFRA_ORIGINS AS INFRA_ORIGINS_0;

CREATE VIEW project_InfraOwnerships AS SELECT
  INFRA_OWNERSHIPS_0.code,
  INFRA_OWNERSHIPS_0.description
FROM INFRA_OWNERSHIPS AS INFRA_OWNERSHIPS_0;

CREATE VIEW project_InfraStatus AS SELECT
  INFRA_STATUS_0.code,
  INFRA_STATUS_0.description
FROM INFRA_STATUS AS INFRA_STATUS_0;

CREATE VIEW project_Marketables AS SELECT
  MARKETABLES_0.code,
  MARKETABLES_0.description
FROM MARKETABLES AS MARKETABLES_0;

CREATE VIEW project_ABFZones AS SELECT
  ABF_ZONES_0.code,
  ABF_ZONES_0.description
FROM ABF_ZONES AS ABF_ZONES_0;

CREATE VIEW project_ManagingCompanies AS SELECT
  MANAGING_COMPANIES_0.code,
  MANAGING_COMPANIES_0.description
FROM MANAGING_COMPANIES AS MANAGING_COMPANIES_0;

CREATE VIEW project_CellnexProjects AS SELECT
  CELLNEX_PROJECTS_0.code,
  CELLNEX_PROJECTS_0.description
FROM CELLNEX_PROJECTS AS CELLNEX_PROJECTS_0;

CREATE VIEW project_Exploiteds AS SELECT
  EXPLOITEDS_0.code,
  EXPLOITEDS_0.description
FROM EXPLOITEDS AS EXPLOITEDS_0;

CREATE VIEW project_Regions AS SELECT
  REGIONS_0.country,
  REGIONS_0.code,
  REGIONS_0.description
FROM REGIONS AS REGIONS_0;

CREATE VIEW project_RepaymentStatus AS SELECT
  REPAYMENT_STATUS_0.code,
  REPAYMENT_STATUS_0.name,
  REPAYMENT_STATUS_0.country
FROM REPAYMENT_STATUS AS REPAYMENT_STATUS_0;

CREATE VIEW project_AuxProjectTypes AS SELECT
  AUX_PROJECT_TYPES_0.code,
  AUX_PROJECT_TYPES_0.name,
  AUX_PROJECT_TYPES_0.country
FROM AUX_PROJECT_TYPES AS AUX_PROJECT_TYPES_0;

CREATE VIEW project_MoaOperationTypes AS SELECT
  MOA_OPERATION_TYPES_0.code,
  MOA_OPERATION_TYPES_0.name,
  MOA_OPERATION_TYPES_0.country
FROM MOA_OPERATION_TYPES AS MOA_OPERATION_TYPES_0;

CREATE VIEW project_ProjectObjectivesCountry AS SELECT
  PROJECT_OBJECTIVES_BY_COUNTRY_0.ID,
  PROJECT_OBJECTIVES_BY_COUNTRY_0.name,
  PROJECT_OBJECTIVES_BY_COUNTRY_0.country
FROM PROJECT_OBJECTIVES_BY_COUNTRY AS PROJECT_OBJECTIVES_BY_COUNTRY_0;

CREATE VIEW project_ContractRestrictionVH AS SELECT
  CONTRACT_RESTRICTIONS_OPTIONS_0.code,
  CONTRACT_RESTRICTIONS_OPTIONS_0.name
FROM CONTRACT_RESTRICTIONS_OPTIONS AS CONTRACT_RESTRICTIONS_OPTIONS_0;

CREATE VIEW project_FeasibilityExplanations AS SELECT
  FEASIBILITY_EXPLANATION_OPTIONS_0.code,
  FEASIBILITY_EXPLANATION_OPTIONS_0.name,
  FEASIBILITY_EXPLANATION_OPTIONS_0.country
FROM FEASIBILITY_EXPLANATION_OPTIONS AS FEASIBILITY_EXPLANATION_OPTIONS_0;

CREATE VIEW project_InternalPhases AS SELECT
  INTERNAL_PHASES_0.code,
  INTERNAL_PHASES_0.name,
  INTERNAL_PHASES_0."ORDER"
FROM INTERNAL_PHASES AS INTERNAL_PHASES_0;

CREATE VIEW project_InternalBlocks AS SELECT
  INTERNAL_BLOCKS_0.phaseId,
  INTERNAL_BLOCKS_0.code,
  INTERNAL_BLOCKS_0.name,
  INTERNAL_BLOCKS_0.phaseOrder,
  INTERNAL_BLOCKS_0.blockOrder
FROM INTERNAL_BLOCKS AS INTERNAL_BLOCKS_0
ORDER BY phaseOrder, blockOrder;

CREATE VIEW project_LocalizedWorkTypes AS SELECT
  LOCALIZED_WORKTYPES_0.code,
  LOCALIZED_WORKTYPES_0.name
FROM LOCALIZED_WORKTYPES AS LOCALIZED_WORKTYPES_0;

CREATE VIEW project_Sites AS SELECT
  SITES_0.siteId,
  SITES_0.AOTYPE,
  SITES_0.primaryLegacyCode,
  SITES_0.legacyCode,
  SITES_0.siteName,
  SITES_0.company,
  SITES_0.cellnexZone,
  SITES_0.zone,
  SITES_0.infraOrigin,
  SITES_0.infraOwnership,
  SITES_0.infraStatus,
  SITES_0.marketableId,
  SITES_0.abfZone,
  SITES_0.managingCompany,
  SITES_0.cellnexProject,
  SITES_0.exploited,
  SITES_0.comunity,
  SITES_0.country,
  SITES_0.region,
  SITES_0.city,
  SITES_0.postalCode,
  SITES_0.street,
  SITES_0.houseNumber,
  SITES_0."FLOOR",
  SITES_0.productionZoneResponsible,
  SITES_0.productionZoneResponsibleName,
  SITES_0.siteManagerZoneResponsible,
  SITES_0.siteManagerZoneResponsibleName,
  SITES_0.productionRegionManager,
  SITES_0.productionRegionManagerName,
  SITES_0.regionSiteManager,
  SITES_0.regionSiteManagerName,
  SITES_0.productionManager,
  SITES_0.productionManagerName,
  SITES_0.siteManager,
  SITES_0.siteManagerName,
  SITES_0.landlordName
FROM SITES AS SITES_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN project_Companies AS Companies ON (Companies.BUKRS = company),
  MANY TO ONE JOIN project_CellnexZones AS CellnexZones ON (CellnexZones.code = cellnexZone),
  MANY TO ONE JOIN project_Zones AS Zones ON (Zones.code = zone),
  MANY TO ONE JOIN project_InfraOrigins AS InfraOrigins ON (InfraOrigins.code = infraOrigin),
  MANY TO ONE JOIN project_InfraOwnerships AS InfraOwnerships ON (InfraOwnerships.code = infraOwnership),
  MANY TO ONE JOIN project_InfraStatus AS InfraStatus ON (InfraStatus.code = infraStatus),
  MANY TO ONE JOIN project_Marketables AS Marketables ON (Marketables.code = marketableId),
  MANY TO ONE JOIN project_ABFZones AS ABFZones ON (ABFZones.code = abfZone),
  MANY TO ONE JOIN project_ManagingCompanies AS ManagingCompanies ON (ManagingCompanies.code = managingCompany),
  MANY TO ONE JOIN project_CellnexProjects AS CellnexProjects ON (CellnexProjects.code = cellnexProject),
  MANY TO ONE JOIN project_Exploiteds AS Exploiteds ON (Exploiteds.code = exploited),
  MANY TO ONE JOIN project_Regions AS Regions ON (Regions.country = country AND Regions.code = region)
);

CREATE VIEW project_PhasesPerProcess AS SELECT
  PHASES_PER_PROCESS_0.processFlowId,
  PHASES_PER_PROCESS_0.phaseProcessFlowId,
  PHASES_PER_PROCESS_0.phaseOrder,
  PHASES_PER_PROCESS_0.phaseName
FROM PHASES_PER_PROCESS AS PHASES_PER_PROCESS_0;

CREATE VIEW project_BlocksPerProcess AS SELECT
  BLOCKS_PER_PROCESS_0.processFlowId,
  BLOCKS_PER_PROCESS_0.phaseProcessFlowId,
  BLOCKS_PER_PROCESS_0.blockProcessFlowId,
  BLOCKS_PER_PROCESS_0.blockOrder,
  BLOCKS_PER_PROCESS_0.blockName,
  BLOCKS_PER_PROCESS_0.hasCandidate
FROM BLOCKS_PER_PROCESS AS BLOCKS_PER_PROCESS_0;

CREATE VIEW project_PMOManagers AS SELECT
  PMO_MANAGERS_0.userId,
  PMO_MANAGERS_0.userName,
  PMO_MANAGERS_0.country
FROM PMO_MANAGERS AS PMO_MANAGERS_0;

CREATE VIEW project_Managers AS SELECT
  MANAGERS_0.userId,
  MANAGERS_0.userName,
  MANAGERS_0.country
FROM MANAGERS AS MANAGERS_0;

CREATE VIEW project_Requesters AS SELECT
  REQUESTERS_0.userId,
  REQUESTERS_0.userName,
  REQUESTERS_0.country
FROM REQUESTERS AS REQUESTERS_0;

CREATE VIEW project_singleRequestProcess(IN p_requestId NVARCHAR(36)) AS SELECT
  SINGLE_REQUEST_PROCESS_0.REQUEST_ID,
  SINGLE_REQUEST_PROCESS_0.PROCESS_ID,
  SINGLE_REQUEST_PROCESS_0.REQUEST_CODE,
  SINGLE_REQUEST_PROCESS_0.ID_PK,
  SINGLE_REQUEST_PROCESS_0.PROCESS_ID_PK,
  SINGLE_REQUEST_PROCESS_0.PHASE_ID,
  SINGLE_REQUEST_PROCESS_0.PHASE_ORDER,
  SINGLE_REQUEST_PROCESS_0.NOT_REQUIRED,
  SINGLE_REQUEST_PROCESS_0.ALWAYS_ON,
  SINGLE_REQUEST_PROCESS_0.PASS_OVER,
  SINGLE_REQUEST_PROCESS_0.SKIP_RULE,
  SINGLE_REQUEST_PROCESS_0.CLOSE_BLOCK,
  SINGLE_REQUEST_PROCESS_0.HAS_CANDIDATES,
  SINGLE_REQUEST_PROCESS_0.BLOCK_ID_PK,
  SINGLE_REQUEST_PROCESS_0.VISIBLE_ON,
  SINGLE_REQUEST_PROCESS_0.MANDATORY,
  SINGLE_REQUEST_PROCESS_0.ACTIVE,
  SINGLE_REQUEST_PROCESS_0.ROLE_ID,
  SINGLE_REQUEST_PROCESS_0.HASRESPONSIBLE,
  SINGLE_REQUEST_PROCESS_0.APPROVER_TYPE,
  SINGLE_REQUEST_PROCESS_0.SUBCONTRACTOR_TYPE,
  SINGLE_REQUEST_PROCESS_0.IS_CANDIDATE
FROM SINGLE_REQUEST_PROCESS(p_requestId => :P_REQUESTID) AS SINGLE_REQUEST_PROCESS_0;

CREATE VIEW project_lastActivePhases(IN p_requestId NVARCHAR(36)) AS SELECT
  LAST_ACTIVE_PHASES_0.LAST_PHASE AS lastPhase
FROM LAST_ACTIVE_PHASES(p_requestId => :P_REQUESTID) AS LAST_ACTIVE_PHASES_0;

CREATE VIEW project_DtLinkedRequestPossibleChildrenRequestList AS SELECT
  DtLinkedRequestPossibleChildrenRequest_0.requestID,
  DtLinkedRequestPossibleChildrenRequest_0.status,
  DtLinkedRequestPossibleChildrenRequest_0.statusName,
  DtLinkedRequestPossibleChildrenRequest_0.requestCode,
  DtLinkedRequestPossibleChildrenRequest_0.requestType,
  DtLinkedRequestPossibleChildrenRequest_0.requestTypeName,
  DtLinkedRequestPossibleChildrenRequest_0.siteID,
  DtLinkedRequestPossibleChildrenRequest_0.processFlowID,
  DtLinkedRequestPossibleChildrenRequest_0.statusCritical
FROM DtLinkedRequestPossibleChildrenRequest AS DtLinkedRequestPossibleChildrenRequest_0;

CREATE VIEW project_SearchDtLinkedRequestSet AS SELECT
  SearchDtLinkedRequest_0.requestID,
  SearchDtLinkedRequest_0.status,
  SearchDtLinkedRequest_0.statusName,
  SearchDtLinkedRequest_0.siteID,
  SearchDtLinkedRequest_0.requestType,
  SearchDtLinkedRequest_0.requestTypeName,
  SearchDtLinkedRequest_0.childRequestID,
  SearchDtLinkedRequest_0.parentInstanceID,
  SearchDtLinkedRequest_0.associationType,
  SearchDtLinkedRequest_0.deleted,
  SearchDtLinkedRequest_0.childInstanceID,
  SearchDtLinkedRequest_0.linkID,
  SearchDtLinkedRequest_0.statusCritical
FROM SearchDtLinkedRequest AS SearchDtLinkedRequest_0;

CREATE VIEW project_firstInprogressPhase(IN p_requestId NVARCHAR(36)) AS SELECT
  FIRST_INPROGRESS_PHASE_0.MASTER_PHASE_ID AS processFlowId
FROM FIRST_INPROGRESS_PHASE(p_requestId => :P_REQUESTID) AS FIRST_INPROGRESS_PHASE_0;

CREATE VIEW workconfiguration_ApproverTypes AS SELECT
  APPROVER_TYPES_0.code,
  APPROVER_TYPES_0.name,
  APPROVER_TYPES_0.country
FROM APPROVER_TYPES AS APPROVER_TYPES_0;

CREATE VIEW workconfiguration_SubcoTypes AS SELECT
  SUBCO_TYPES_0.code,
  SUBCO_TYPES_0.name,
  SUBCO_TYPES_0.country
FROM SUBCO_TYPES AS SUBCO_TYPES_0
WHERE SUBCO_TYPES_0.code IN (3, 4);

CREATE VIEW BLOCKS_RESPONSIBLES(IN p_requestId NVARCHAR(36)) AS SELECT
  bh_4.BLOCK_ID AS ID,
  bh_4.BLOCK_STATUS AS status,
  :P_REQUESTID AS requestId,
  rh_0.PROCESS_ID AS requestProcessFlowId,
  p_1.PROCESS_ID_PK AS ProcessFlowType,
  ph_2.MASTER_PHASE_ID AS phaseProcessFlowId,
  mp_3.PHASE_NAME AS phaseName,
  bh_4.MASTER_BLOCK_ID AS blockProcessFlowId,
  mb_5.BLOCK_NAME AS blockName,
  bp_6.ASSIGNED_RESPONSIBLE AS approverType,
  0 AS approverTypeFC,
  at_7.name AS approverName,
  bp_6.SUBCONTRACTOR_TYPE AS subcoType,
  0 AS subcoTypeFC,
  st_8.name AS subcoName,
  bp_6.PROVIDER_NAME AS externalResponsible,
  exu_10.USER_NAME AS externalResponsibleName,
  0 AS externalResponsibleFC,
  bp_6.RESPONSIBLE_PERSON AS internalResponsible,
  inu_9.USER_NAME AS internalResponsibleName,
  0 AS internalResponsibleFC
FROM ((((((((((REQUEST_HEAD AS rh_0 LEFT JOIN PROCESS AS p_1 ON p_1.ID_PK = rh_0.PROCESS_ID) INNER JOIN PHASE_HEAD AS ph_2 ON ph_2.REQUEST_ID = rh_0.REQUEST_ID AND ph_2.REQUEST_ID = :P_REQUESTID) LEFT JOIN MASTER_PHASE AS mp_3 ON mp_3.PROCESS_ID_PK = p_1.PROCESS_ID_PK AND mp_3.PHASE_ID_PK = ph_2.MASTER_PHASE_ID AND mp_3.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCK_HEAD AS bh_4 ON bh_4.PHASE_ID = ph_2.PHASE_ID) LEFT JOIN MASTER_BLOCK AS mb_5 ON mb_5.PROCESS_ID_PK = p_1.PROCESS_ID_PK AND mb_5.PHASE_ID_PK = ph_2.MASTER_PHASE_ID AND mb_5.BLOCK_ID_PK = bh_4.MASTER_BLOCK_ID AND mb_5.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCKS_PROVISIONING AS bp_6 ON bp_6.BLOCK_ID = bh_4.BLOCK_ID AND bp_6.ASSIGNED_RESPONSIBLE IS NOT NULL AND bp_6.ASSIGNED_RESPONSIBLE != '') LEFT JOIN APPROVER_TYPES AS at_7 ON at_7.code = bp_6.ASSIGNED_RESPONSIBLE) LEFT JOIN SUBCO_TYPES AS st_8 ON st_8.code = bp_6.SUBCONTRACTOR_TYPE) LEFT JOIN US_USERS_IAS AS inu_9 ON inu_9.USER_ID = bp_6.RESPONSIBLE_PERSON) LEFT JOIN US_USERS_IAS AS exu_10 ON exu_10.USER_ID = bp_6.PROVIDER_NAME);

CREATE VIEW SEARCH_BY_REQUESTS AS SELECT
  rh_0.REQUEST_ID AS ID,
  rh_0.WORKFLOW_ID AS projectType,
  pt_8.name AS projectTypeName,
  rp_2.PROJECT_OBJECTIVE AS projectObjective,
  po_9.name AS projectObjectiveName,
  rh_0.REQUEST_CODE AS code,
  rh_0.COUNTRY_ID AS country,
  rh_0.REQUEST_STATUS AS status,
  rs_10.name AS statusName,
  sc_4.COMPLEXITY AS complexity,
  co_5.name AS complexityName,
  rh_0.SITE_ID AS siteId,
  sit_1.siteName,
  sit_1.region AS siteRegion,
  rg_7.description AS siteRegionName,
  sit_1.city AS siteCity,
  sit_1.cellnexZone AS cellnexZone,
  cz_6.description AS cellnexZoneName,
  sit_1.legacyCode AS siteLegacyCode,
  la_3.lastPhase,
  la_3.lastPhaseName,
  la_3.lastBlock,
  la_3.lastBlockName,
  rp_2.REQUESTED_DATE AS requestedDate,
  rh_0.CREATEDAT AS createdAt,
  rh_0.REQUEST_OWNER_ID AS manager,
  us_11.USER_NAME AS managerName,
  rp_2.PREFERRED_PROVIDER AS preferredProvider,
  pp_17.ENTITY_NAME AS preferredProviderName,
  rh_0.ASSIGNATION_DATE AS assignationDate,
  bh_13.ROLE_ID AS roleId,
  CASE WHEN idp_16.STEP_ID = '0' THEN CASE WHEN db_15.RESPONSIBLE_ID = '1' THEN 'TIS_Cellnex' WHEN db_15.RESPONSIBLE_ID = '2' THEN CASE WHEN db_15.SUBCONTRATOR_ID = '2' THEN 'TIS_WF_PRO_Customer' WHEN db_15.SUBCONTRATOR_ID = '3' THEN 'TIS_WF_PRO_Subcontractor' WHEN db_15.SUBCONTRATOR_ID = '4' THEN 'TIS_WF_PRO_Agency' ELSE 'TIS_WF_PRO_Subcontractor' END END WHEN idp_16.STEP_ID = '10' THEN CASE WHEN db_15.RESPONSIBLE_ID = '1' THEN 'TIS_Cellnex' WHEN db_15.RESPONSIBLE_ID = '2' THEN CASE WHEN db_15.SUBCONTRATOR_ID = '2' THEN 'TIS_WF_PRO_Customer' WHEN db_15.SUBCONTRATOR_ID = '3' THEN 'TIS_WF_PRO_Subcontractor' WHEN db_15.SUBCONTRATOR_ID = '4' THEN 'TIS_WF_PRO_Agency' ELSE 'TIS_WF_PRO_Subcontractor' END END WHEN idp_16.STEP_ID = '20' THEN 'TIS_Cellnex' WHEN idp_16.STEP_ID = '30' THEN 'TIS_WF_PRO_Subcontractor' WHEN idp_16.STEP_ID = '40' THEN 'TIS_WF_PRO_Customer' ELSE bh_13.ROLE_ID END AS documentRoleId,
  bp_14.SUBCONTRACTOR_TYPE AS subcoType,
  bp_14.RESPONSIBLE_PERSON AS internalResponsible,
  bp_14.PROVIDER_NAME AS externalResponsible,
  db_15.SUBCONTRATOR_ID AS documentSubcontractor,
  0 AS searchType,
  db_15.T_RESPONSIBLE AS assignedResponsible,
  CASE WHEN idp_16.STEP_ID = '20' THEN idp_16.CELLNEX_VALIDATOR WHEN idp_16.STEP_ID = '30' THEN idp_16.SUBCONTRACTOR_VALIDATOR WHEN idp_16.STEP_ID = '40' THEN idp_16.CUSTOMER_VALIDATOR ELSE db_15.T_RESPONSIBLE END AS validator,
  CASE WHEN rh_0.REQUEST_STATUS = 7 THEN 2 WHEN rh_0.REQUEST_STATUS = 3 THEN 3 WHEN rh_0.REQUEST_STATUS = 4 THEN 1 WHEN rh_0.REQUEST_STATUS = 12 THEN 1 WHEN rh_0.REQUEST_STATUS = 32 THEN 2 ELSE 0 END AS objectStatus
FROM (((((((((((((((((REQUEST_HEAD AS rh_0 INNER JOIN SITES AS sit_1 ON sit_1.siteId = rh_0.SITE_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_2 ON rp_2.REQUEST_ID = rh_0.REQUEST_ID AND (rh_0.REQUEST_TYPE = 40)) LEFT JOIN LAST_ACTIVE_PHASE_BLOCK AS la_3 ON la_3.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN SEARCH_BY_COMPLEXITIES AS sc_4 ON sc_4.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN COMPLEXITIES AS co_5 ON co_5.code = sc_4.COMPLEXITY AND co_5.country = rh_0.COUNTRY_ID) LEFT JOIN CELLNEX_ZONES AS cz_6 ON cz_6.code = sit_1.cellnexZone) LEFT JOIN REGIONS AS rg_7 ON rg_7.country = sit_1.country AND rg_7.code = sit_1.region) LEFT JOIN AUX_PROJECT_TYPES AS pt_8 ON pt_8.code = rh_0.WORKFLOW_ID AND pt_8.country = rh_0.COUNTRY_ID) LEFT JOIN PROJECT_OBJECTIVES_BY_COUNTRY AS po_9 ON po_9.ID = rp_2.PROJECT_OBJECTIVE AND po_9.country = rh_0.COUNTRY_ID) LEFT JOIN localized_REQUEST_STATUS AS rs_10 ON rs_10.code = rh_0.REQUEST_STATUS) LEFT JOIN US_USERS_IAS AS us_11 ON us_11.USER_ID = rh_0.REQUEST_OWNER_ID) INNER JOIN PHASE_HEAD AS ph_12 ON ph_12.REQUEST_ID = rh_0.REQUEST_ID) INNER JOIN BLOCK_HEAD AS bh_13 ON bh_13.PHASE_ID = ph_12.PHASE_ID) INNER JOIN BLOCKS_PROVISIONING AS bp_14 ON bp_14.BLOCK_ID = bh_13.BLOCK_ID) LEFT JOIN DOCUMENTS_PER_BLOCK AS db_15 ON db_15.BLOCK_ID = bh_13.BLOCK_ID) LEFT JOIN INSTANCES_PER_DOCUMENT AS idp_16 ON idp_16.INSTANCE_ID = db_15.REGISTER_ID) LEFT JOIN CACHE_R3_ENTITIES AS pp_17 ON pp_17.ENTITY_ID = rp_2.PREFERRED_PROVIDER AND pp_17.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND pp_17.USER_ID = SESSION_CONTEXT('APPLICATIONUSER'));

CREATE VIEW SEARCH_BY_BLOCKS AS SELECT
  rh_0.REQUEST_ID AS ID,
  rh_0.REQUEST_CODE AS code,
  rh_0.REQUEST_STATUS AS requestStatus,
  rh_0.COUNTRY_ID AS country,
  rh_0.WORKFLOW_ID AS projectType,
  rp_4.PROJECT_OBJECTIVE AS projectObjective,
  bh_9.BLOCK_STATUS AS status,
  bs_10.name AS statusName,
  sc_5.COMPLEXITY AS complexity,
  co_6.name AS complexityName,
  rh_0.SITE_ID AS siteId,
  sit_2.siteName,
  sit_2.region AS siteRegion,
  sit_2.city AS siteCity,
  sit_2.cellnexZone AS cellnexZone,
  sit_2.legacyCode AS siteLegacyCode,
  rp_4.REQUESTED_DATE AS requestedDate,
  rh_0.CREATEDAT AS createdAt,
  ph_7.MASTER_PHASE_ID AS masterPhaseId,
  mp_8.PHASE_NAME AS phase,
  bh_9.MASTER_BLOCK_ID AS masterBlockID,
  mb_16.BLOCK_NAME AS block,
  '' AS workId,
  '' AS work,
  0 AS workType,
  '' AS workTypeName,
  bh_9.ROLE_ID AS roleId,
  CASE bp_11.ASSIGNED_RESPONSIBLE WHEN '1' THEN bp_11.RESPONSIBLE_PERSON WHEN '2' THEN bp_11.PROVIDER_NAME ELSE NULL END AS assignedResponsible,
  CASE bp_11.ASSIGNED_RESPONSIBLE WHEN '1' THEN usn_12.USER_NAME WHEN '2' THEN CASE bp_11.SUBCONTRACTOR_TYPE WHEN '3' THEN sb_14.ENTITY_NAME WHEN '4' THEN ag_15.ENTITY_NAME ELSE NULL END ELSE NULL END AS assignedResponsibleName,
  '' AS validator,
  '' AS validatorName,
  bp_11.RESPONSIBLE_PERSON AS internalResponsible,
  bp_11.PROVIDER_NAME AS externalResponsible,
  rh_0.REQUEST_OWNER_ID AS manager,
  us_3.USER_NAME AS managerName,
  rp_4.PREFERRED_PROVIDER AS preferredProvider,
  pp_13.ENTITY_NAME AS preferredProviderName,
  rh_0.ASSIGNATION_DATE AS assignationDate,
  0 AS taskType,
  0 AS searchType,
  '' AS documentId,
  '' AS documentType,
  '' AS documentName,
  '' AS documentValidation
FROM ((((((((((((((((REQUEST_HEAD AS rh_0 LEFT JOIN PROCESS AS p_1 ON p_1.ID_PK = rh_0.PROCESS_ID) INNER JOIN SITES AS sit_2 ON sit_2.siteId = rh_0.SITE_ID) LEFT JOIN US_USERS_IAS AS us_3 ON us_3.USER_ID = rh_0.REQUEST_OWNER_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_4 ON rp_4.REQUEST_ID = rh_0.REQUEST_ID AND (rh_0.REQUEST_TYPE = 40)) LEFT JOIN SEARCH_BY_COMPLEXITIES AS sc_5 ON sc_5.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN COMPLEXITIES AS co_6 ON co_6.code = sc_5.COMPLEXITY AND co_6.country = rh_0.COUNTRY_ID) INNER JOIN PHASE_HEAD AS ph_7 ON ph_7.REQUEST_ID = rh_0.REQUEST_ID AND ph_7.PHASE_STATUS != 2) LEFT JOIN MASTER_PHASE AS mp_8 ON mp_8.PROCESS_ID_PK = p_1.PROCESS_ID_PK AND mp_8.PHASE_ID_PK = ph_7.MASTER_PHASE_ID AND mp_8.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCK_HEAD AS bh_9 ON bh_9.PHASE_ID = ph_7.PHASE_ID) LEFT JOIN localized_BLOCK_STATUS AS bs_10 ON bs_10.code = bh_9.BLOCK_STATUS) INNER JOIN BLOCKS_PROVISIONING AS bp_11 ON bp_11.BLOCK_ID = bh_9.BLOCK_ID) LEFT JOIN US_USERS_IAS AS usn_12 ON usn_12.USER_ID = bp_11.RESPONSIBLE_PERSON) LEFT JOIN CACHE_R3_ENTITIES AS pp_13 ON pp_13.ENTITY_ID = rp_4.PREFERRED_PROVIDER AND pp_13.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND pp_13.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS sb_14 ON sb_14.ENTITY_ID = bp_11.PROVIDER_NAME AND sb_14.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND sb_14.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS ag_15 ON ag_15.ENTITY_ID = bp_11.PROVIDER_NAME AND ag_15.ENTITY_TYPE = 'F4_GEWRK_AGEN' AND ag_15.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN MASTER_BLOCK AS mb_16 ON mb_16.PROCESS_ID_PK = p_1.PROCESS_ID_PK AND mb_16.PHASE_ID_PK = mp_8.PHASE_ID_PK AND mb_16.BLOCK_ID_PK = bh_9.MASTER_BLOCK_ID AND mb_16.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE')));

CREATE VIEW SEARCH_BY_BLOCKS_WORKS AS SELECT
  rh_0.REQUEST_ID AS ID,
  rh_0.REQUEST_CODE AS code,
  rh_0.REQUEST_STATUS AS requestStatus,
  rh_0.COUNTRY_ID AS country,
  rh_0.WORKFLOW_ID AS projectType,
  rp_4.PROJECT_OBJECTIVE AS projectObjective,
  gt_10.status,
  st_12.STATUS_TEXT AS statusName,
  sc_5.COMPLEXITY AS complexity,
  co_6.name AS complexityName,
  rh_0.SITE_ID AS siteId,
  sit_2.siteName,
  sit_2.region AS siteRegion,
  sit_2.city AS siteCity,
  sit_2.cellnexZone AS cellnexZone,
  sit_2.legacyCode AS siteLegacyCode,
  rp_4.REQUESTED_DATE AS requestedDate,
  rh_0.CREATEDAT AS createdAt,
  ph_7.MASTER_PHASE_ID AS masterPhaseId,
  mp_8.PHASE_NAME AS phase,
  bh_9.MASTER_BLOCK_ID AS masterBlockID,
  mb_21.BLOCK_NAME AS block,
  gt_10.ID AS workId,
  gt_10.description AS work,
  type_22.ID AS workType,
  type_22.descr AS workTypeName,
  bh_9.ROLE_ID AS roleId,
  CASE gt_10.responsibleType WHEN '1' THEN gt_10.internalResponsible WHEN '2' THEN gt_10.externalResponsible ELSE CASE bp_13.ASSIGNED_RESPONSIBLE WHEN '1' THEN bp_13.RESPONSIBLE_PERSON WHEN '2' THEN bp_13.PROVIDER_NAME ELSE NULL END END AS assignedResponsible,
  CASE gt_10.responsibleType WHEN '1' THEN usw_15.USER_NAME WHEN '2' THEN CASE gt_10.externalType WHEN '3' THEN sbw_19.ENTITY_NAME WHEN '4' THEN agw_20.ENTITY_NAME ELSE NULL END ELSE CASE bp_13.ASSIGNED_RESPONSIBLE WHEN '1' THEN usn_14.USER_NAME WHEN '2' THEN CASE bp_13.SUBCONTRACTOR_TYPE WHEN '3' THEN sb_17.ENTITY_NAME WHEN '4' THEN ag_18.ENTITY_NAME ELSE NULL END ELSE NULL END END AS assignedResponsibleName,
  '' AS validator,
  '' AS validatorName,
  bp_13.RESPONSIBLE_PERSON AS internalResponsible,
  bp_13.PROVIDER_NAME AS externalResponsible,
  rh_0.REQUEST_OWNER_ID AS manager,
  us_3.USER_NAME AS managerName,
  rp_4.PREFERRED_PROVIDER AS preferredProvider,
  pp_16.ENTITY_NAME AS preferredProviderName,
  rh_0.ASSIGNATION_DATE AS assignationDate,
  0 AS taskType,
  0 AS searchType,
  '' AS documentId,
  '' AS documentType,
  '' AS documentName,
  '' AS documentValidation
FROM ((((((((((((((((((((((REQUEST_HEAD AS rh_0 LEFT JOIN PROCESS AS p_1 ON p_1.ID_PK = rh_0.PROCESS_ID) INNER JOIN SITES AS sit_2 ON sit_2.siteId = rh_0.SITE_ID) LEFT JOIN US_USERS_IAS AS us_3 ON us_3.USER_ID = rh_0.REQUEST_OWNER_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_4 ON rp_4.REQUEST_ID = rh_0.REQUEST_ID AND (rh_0.REQUEST_TYPE = 40)) LEFT JOIN SEARCH_BY_COMPLEXITIES AS sc_5 ON sc_5.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN COMPLEXITIES AS co_6 ON co_6.code = sc_5.COMPLEXITY AND co_6.country = rh_0.COUNTRY_ID) INNER JOIN PHASE_HEAD AS ph_7 ON ph_7.REQUEST_ID = rh_0.REQUEST_ID AND ph_7.PHASE_STATUS != 2) LEFT JOIN MASTER_PHASE AS mp_8 ON mp_8.PROCESS_ID_PK = p_1.PROCESS_ID_PK AND mp_8.PHASE_ID_PK = ph_7.MASTER_PHASE_ID AND mp_8.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCK_HEAD AS bh_9 ON bh_9.PHASE_ID = ph_7.PHASE_ID) INNER JOIN WORKS AS gt_10 ON gt_10.parentId = bh_9.BLOCK_ID AND gt_10.parentType_ID = 30) LEFT JOIN localized_BLOCK_STATUS AS bs_11 ON bs_11.code = bh_9.BLOCK_STATUS) LEFT JOIN STATUS_TEXTS AS st_12 ON st_12.STATUS_CODE = gt_10.status AND st_12."LANGUAGE" = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCKS_PROVISIONING AS bp_13 ON bp_13.BLOCK_ID = bh_9.BLOCK_ID) LEFT JOIN US_USERS_IAS AS usn_14 ON usn_14.USER_ID = bp_13.RESPONSIBLE_PERSON) LEFT JOIN US_USERS_IAS AS usw_15 ON usw_15.USER_ID = gt_10.internalResponsible) LEFT JOIN CACHE_R3_ENTITIES AS pp_16 ON pp_16.ENTITY_ID = rp_4.PREFERRED_PROVIDER AND pp_16.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND pp_16.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS sb_17 ON sb_17.ENTITY_ID = bp_13.PROVIDER_NAME AND sb_17.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND sb_17.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS ag_18 ON ag_18.ENTITY_ID = bp_13.PROVIDER_NAME AND ag_18.ENTITY_TYPE = 'F4_GEWRK_AGEN' AND ag_18.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS sbw_19 ON sbw_19.ENTITY_ID = gt_10.externalResponsible AND sbw_19.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND sbw_19.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS agw_20 ON agw_20.ENTITY_ID = gt_10.externalResponsible AND agw_20.ENTITY_TYPE = 'F4_GEWRK_AGEN' AND agw_20.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN MASTER_BLOCK AS mb_21 ON mb_21.PROCESS_ID_PK = p_1.PROCESS_ID_PK AND mb_21.PHASE_ID_PK = mp_8.PHASE_ID_PK AND mb_21.BLOCK_ID_PK = bh_9.MASTER_BLOCK_ID AND mb_21.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) LEFT JOIN WORK_TYPES AS type_22 ON gt_10.type_ID = type_22.ID);

CREATE VIEW SEARCH_BY_DOCUMENTS AS SELECT
  rh_0.REQUEST_ID AS ID,
  rh_0.REQUEST_CODE AS code,
  rh_0.REQUEST_STATUS AS requestStatus,
  rh_0.COUNTRY_ID AS country,
  rh_0.WORKFLOW_ID AS projectType,
  rp_3.PROJECT_OBJECTIVE AS projectObjective,
  dp_11.STATUS AS status,
  dfs_12.name AS statusName,
  sc_4.COMPLEXITY AS complexity,
  co_5.name AS complexityName,
  rh_0.SITE_ID AS siteId,
  sit_1.siteName,
  sit_1.region AS siteRegion,
  sit_1.city AS siteCity,
  sit_1.cellnexZone AS cellnexZone,
  sit_1.legacyCode AS siteLegacyCode,
  rp_3.REQUESTED_DATE AS requestedDate,
  rh_0.CREATEDAT AS createdAt,
  ph_6.MASTER_PHASE_ID AS masterPhaseId,
  mp_7.PHASE_NAME AS phase,
  bh_8.MASTER_BLOCK_ID AS masterBlockID,
  mb_10.BLOCK_NAME AS block,
  '' AS workId,
  '' AS work,
  0 AS workType,
  '' AS workTypeName,
  CASE WHEN idp_14.STEP_ID = '0' THEN CASE WHEN dp_11.RESPONSIBLE_ID = '1' THEN 'TIS_Cellnex' WHEN dp_11.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_11.SUBCONTRATOR_ID = '2' THEN 'TIS_WF_PRO_Customer' WHEN dp_11.SUBCONTRATOR_ID = '3' THEN 'TIS_WF_PRO_Subcontractor' WHEN dp_11.SUBCONTRATOR_ID = '4' THEN 'TIS_WF_PRO_Agency' ELSE 'TIS_WF_PRO_Subcontractor' END END WHEN idp_14.STEP_ID = '10' THEN CASE WHEN dp_11.RESPONSIBLE_ID = '1' THEN 'TIS_Cellnex' WHEN dp_11.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_11.SUBCONTRATOR_ID = '2' THEN 'TIS_WF_PRO_Customer' WHEN dp_11.SUBCONTRATOR_ID = '3' THEN 'TIS_WF_PRO_Subcontractor' WHEN dp_11.SUBCONTRATOR_ID = '4' THEN 'TIS_WF_PRO_Agency' ELSE 'TIS_WF_PRO_Subcontractor' END END WHEN idp_14.STEP_ID = '20' THEN 'TIS_Cellnex' WHEN idp_14.STEP_ID = '30' THEN 'TIS_WF_PRO_Subcontractor' WHEN idp_14.STEP_ID = '40' THEN 'TIS_WF_PRO_Customer' ELSE bh_8.ROLE_ID END AS roleId,
  dp_11.T_RESPONSIBLE AS assignedResponsible,
  CASE WHEN dp_11.RESPONSIBLE_ID = '1' THEN usdr_22.USER_NAME WHEN dp_11.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_11.SUBCONTRATOR_ID = '3' THEN drsc_17.ENTITY_NAME WHEN dp_11.SUBCONTRATOR_ID = '4' THEN drag_18.ENTITY_NAME ELSE NULL END END AS assignedResponsibleName,
  CASE WHEN idp_14.STEP_ID = '20' THEN idp_14.CELLNEX_VALIDATOR WHEN idp_14.STEP_ID = '30' THEN idp_14.SUBCONTRACTOR_VALIDATOR WHEN idp_14.STEP_ID = '40' THEN idp_14.CUSTOMER_VALIDATOR ELSE dp_11.T_RESPONSIBLE END AS validator,
  CASE WHEN idp_14.STEP_ID = '20' THEN uscv_21.USER_NAME WHEN idp_14.STEP_ID = '30' THEN sv_19.ENTITY_NAME ELSE usdr_22.USER_NAME END AS validatorName,
  bp_9.RESPONSIBLE_PERSON AS internalResponsible,
  bp_9.PROVIDER_NAME AS externalResponsible,
  rh_0.REQUEST_OWNER_ID AS manager,
  uscm_15.USER_NAME AS managerName,
  rp_3.PREFERRED_PROVIDER AS preferredProvider,
  pp_16.ENTITY_NAME AS preferredProviderName,
  rh_0.ASSIGNATION_DATE AS assignationDate,
  1 AS taskType,
  0 AS searchType,
  dp_11.REGISTER_ID AS documentId,
  dp_11.GENERIC_TYPE_ID AS documentType,
  df_13.documentName,
  CASE WHEN idp_14.STEP_ID = '0' THEN 'Responsible document upload' WHEN idp_14.STEP_ID = '20' THEN 'Cellnex validation' WHEN idp_14.STEP_ID = '30' THEN 'Subcontractor validation' WHEN idp_14.STEP_ID = '40' THEN 'On behalf of Customer validation' END AS documentValidation
FROM ((((((((((((((((((((((REQUEST_HEAD AS rh_0 INNER JOIN SITES AS sit_1 ON sit_1.siteId = rh_0.SITE_ID) LEFT JOIN PROCESS AS p_2 ON p_2.ID_PK = rh_0.PROCESS_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_3 ON rp_3.REQUEST_ID = rh_0.REQUEST_ID AND (rh_0.REQUEST_TYPE = 40)) LEFT JOIN SEARCH_BY_COMPLEXITIES AS sc_4 ON sc_4.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN COMPLEXITIES AS co_5 ON co_5.code = sc_4.COMPLEXITY AND co_5.country = rh_0.COUNTRY_ID) INNER JOIN PHASE_HEAD AS ph_6 ON ph_6.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN MASTER_PHASE AS mp_7 ON mp_7.PROCESS_ID_PK = p_2.PROCESS_ID_PK AND mp_7.PHASE_ID_PK = ph_6.MASTER_PHASE_ID AND mp_7.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCK_HEAD AS bh_8 ON bh_8.PHASE_ID = ph_6.PHASE_ID) INNER JOIN BLOCKS_PROVISIONING AS bp_9 ON bp_9.BLOCK_ID = bh_8.BLOCK_ID) LEFT JOIN MASTER_BLOCK AS mb_10 ON mb_10.PROCESS_ID_PK = p_2.PROCESS_ID_PK AND mb_10.PHASE_ID_PK = mp_7.PHASE_ID_PK AND mb_10.BLOCK_ID_PK = bh_8.MASTER_BLOCK_ID AND mb_10.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN DOCUMENTS_PER_BLOCK AS dp_11 ON dp_11.BLOCK_ID = bh_8.BLOCK_ID AND (dp_11.WORK_ID IS NULL OR dp_11.WORK_ID = '')) LEFT JOIN localized_DOCUMENT_FLOW_STATUS AS dfs_12 ON dfs_12.code = dp_11.STATUS) LEFT JOIN DOCUMENT_FLOWS AS df_13 ON df_13.documentId = dp_11.GENERIC_TYPE_ID) LEFT JOIN INSTANCES_PER_DOCUMENT AS idp_14 ON idp_14.INSTANCE_ID = dp_11.REGISTER_ID) LEFT JOIN US_USERS_IAS AS uscm_15 ON uscm_15.USER_ID = rh_0.REQUEST_OWNER_ID) LEFT JOIN CACHE_R3_ENTITIES AS pp_16 ON pp_16.ENTITY_ID = rp_3.PREFERRED_PROVIDER AND pp_16.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND pp_16.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS drsc_17 ON drsc_17.ENTITY_ID = dp_11.T_RESPONSIBLE AND (drsc_17.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK') AND drsc_17.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS drag_18 ON drag_18.ENTITY_ID = dp_11.T_RESPONSIBLE AND (drag_18.ENTITY_TYPE = 'F4_GEWRK_AGEN') AND drag_18.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS sv_19 ON sv_19.ENTITY_ID = idp_14.SUBCONTRACTOR_VALIDATOR AND (sv_19.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' OR sv_19.ENTITY_TYPE = 'F4_GEWRK_AGEN') AND sv_19.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN US_USERS_IAS AS usir_20 ON usir_20.USER_ID = bp_9.RESPONSIBLE_PERSON) LEFT JOIN US_USERS_IAS AS uscv_21 ON uscv_21.USER_ID = idp_14.CELLNEX_VALIDATOR) LEFT JOIN US_USERS_IAS AS usdr_22 ON usdr_22.USER_ID = dp_11.T_RESPONSIBLE);

CREATE VIEW SEARCH_BY_WORK_DOCUMENTS AS SELECT
  rh_0.REQUEST_ID AS ID,
  rh_0.REQUEST_CODE AS code,
  rh_0.REQUEST_STATUS AS requestStatus,
  rh_0.COUNTRY_ID AS country,
  rh_0.WORKFLOW_ID AS projectType,
  rp_3.PROJECT_OBJECTIVE AS projectObjective,
  dp_12.STATUS AS status,
  dfs_13.name AS statusName,
  sc_4.COMPLEXITY AS complexity,
  co_5.name AS complexityName,
  rh_0.SITE_ID AS siteId,
  sit_1.siteName,
  sit_1.region AS siteRegion,
  sit_1.city AS siteCity,
  sit_1.cellnexZone AS cellnexZone,
  sit_1.legacyCode AS siteLegacyCode,
  rp_3.REQUESTED_DATE AS requestedDate,
  rh_0.CREATEDAT AS createdAt,
  ph_6.MASTER_PHASE_ID AS masterPhaseId,
  mp_7.PHASE_NAME AS phase,
  bh_8.MASTER_BLOCK_ID AS masterBlockID,
  mb_11.BLOCK_NAME AS block,
  gt_9.ID AS workId,
  gt_9.description AS work,
  type_23.ID AS workType,
  type_23.descr AS workTypeName,
  CASE WHEN idp_15.STEP_ID = '0' THEN CASE WHEN dp_12.RESPONSIBLE_ID = '1' THEN 'TIS_Cellnex' WHEN dp_12.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_12.SUBCONTRATOR_ID = '2' THEN 'TIS_WF_PRO_Customer' WHEN dp_12.SUBCONTRATOR_ID = '3' THEN 'TIS_WF_PRO_Subcontractor' WHEN dp_12.SUBCONTRATOR_ID = '4' THEN 'TIS_WF_PRO_Agency' ELSE 'TIS_WF_PRO_Subcontractor' END END WHEN idp_15.STEP_ID = '10' THEN CASE WHEN dp_12.RESPONSIBLE_ID = '1' THEN 'TIS_Cellnex' WHEN dp_12.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_12.SUBCONTRATOR_ID = '2' THEN 'TIS_WF_PRO_Customer' WHEN dp_12.SUBCONTRATOR_ID = '3' THEN 'TIS_WF_PRO_Subcontractor' WHEN dp_12.SUBCONTRATOR_ID = '4' THEN 'TIS_WF_PRO_Agency' ELSE 'TIS_WF_PRO_Subcontractor' END END WHEN idp_15.STEP_ID = '20' THEN 'TIS_Cellnex' WHEN idp_15.STEP_ID = '30' THEN 'TIS_WF_PRO_Subcontractor' WHEN idp_15.STEP_ID = '40' THEN 'TIS_WF_PRO_Customer' ELSE bh_8.ROLE_ID END AS roleId,
  dp_12.T_RESPONSIBLE AS assignedResponsible,
  CASE WHEN dp_12.RESPONSIBLE_ID = '1' THEN usdr_22.USER_NAME WHEN dp_12.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_12.SUBCONTRATOR_ID = '3' OR dp_12.SUBCONTRATOR_ID = '4' THEN dr_18.ENTITY_NAME END END AS assignedResponsibleName,
  CASE WHEN idp_15.STEP_ID = '20' THEN idp_15.CELLNEX_VALIDATOR WHEN idp_15.STEP_ID = '30' THEN idp_15.SUBCONTRACTOR_VALIDATOR WHEN idp_15.STEP_ID = '40' THEN idp_15.CUSTOMER_VALIDATOR ELSE dp_12.T_RESPONSIBLE END AS validator,
  CASE WHEN idp_15.STEP_ID = '20' THEN uscv_21.USER_NAME WHEN idp_15.STEP_ID = '30' THEN sv_19.ENTITY_NAME ELSE usdr_22.USER_NAME END AS validatorName,
  bp_10.RESPONSIBLE_PERSON AS internalResponsible,
  bp_10.PROVIDER_NAME AS externalResponsible,
  rh_0.REQUEST_OWNER_ID AS manager,
  uscm_16.USER_NAME AS managerName,
  rp_3.PREFERRED_PROVIDER AS preferredProvider,
  pp_17.ENTITY_NAME AS preferredProviderName,
  rh_0.ASSIGNATION_DATE AS assignationDate,
  1 AS taskType,
  0 AS searchType,
  dp_12.REGISTER_ID AS documentId,
  dp_12.GENERIC_TYPE_ID AS documentType,
  df_14.documentName,
  CASE WHEN idp_15.STEP_ID = '0' THEN 'Responsible document upload' WHEN idp_15.STEP_ID = '20' THEN 'Cellnex validation' WHEN idp_15.STEP_ID = '30' THEN 'Subcontractor validation' WHEN idp_15.STEP_ID = '40' THEN 'On behalf of Customer validation' END AS documentValidation
FROM (((((((((((((((((((((((REQUEST_HEAD AS rh_0 INNER JOIN SITES AS sit_1 ON sit_1.siteId = rh_0.SITE_ID) LEFT JOIN PROCESS AS p_2 ON p_2.ID_PK = rh_0.PROCESS_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_3 ON rp_3.REQUEST_ID = rh_0.REQUEST_ID AND (rh_0.REQUEST_TYPE = 40)) LEFT JOIN SEARCH_BY_COMPLEXITIES AS sc_4 ON sc_4.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN COMPLEXITIES AS co_5 ON co_5.code = sc_4.COMPLEXITY AND co_5.country = rh_0.COUNTRY_ID) INNER JOIN PHASE_HEAD AS ph_6 ON ph_6.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN MASTER_PHASE AS mp_7 ON mp_7.PROCESS_ID_PK = p_2.PROCESS_ID_PK AND mp_7.PHASE_ID_PK = ph_6.MASTER_PHASE_ID AND mp_7.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCK_HEAD AS bh_8 ON bh_8.PHASE_ID = ph_6.PHASE_ID) INNER JOIN WORKS AS gt_9 ON gt_9.parentId = bh_8.BLOCK_ID AND gt_9.parentType_ID = 30) INNER JOIN BLOCKS_PROVISIONING AS bp_10 ON bp_10.BLOCK_ID = bh_8.BLOCK_ID) LEFT JOIN MASTER_BLOCK AS mb_11 ON mb_11.PROCESS_ID_PK = p_2.PROCESS_ID_PK AND mb_11.PHASE_ID_PK = mp_7.PHASE_ID_PK AND mb_11.BLOCK_ID_PK = bh_8.MASTER_BLOCK_ID AND mb_11.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN DOCUMENTS_PER_BLOCK AS dp_12 ON dp_12.BLOCK_ID = gt_9.parentId AND dp_12.WORK_ID = gt_9.ID) LEFT JOIN localized_DOCUMENT_FLOW_STATUS AS dfs_13 ON dfs_13.code = dp_12.STATUS) LEFT JOIN DOCUMENT_FLOWS AS df_14 ON df_14.documentId = dp_12.GENERIC_TYPE_ID) LEFT JOIN INSTANCES_PER_DOCUMENT AS idp_15 ON idp_15.INSTANCE_ID = dp_12.REGISTER_ID) LEFT JOIN US_USERS_IAS AS uscm_16 ON uscm_16.USER_ID = rh_0.REQUEST_OWNER_ID) LEFT JOIN CACHE_R3_ENTITIES AS pp_17 ON pp_17.ENTITY_ID = rp_3.PREFERRED_PROVIDER AND pp_17.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND pp_17.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS dr_18 ON dr_18.ENTITY_ID = dp_12.T_RESPONSIBLE AND (dr_18.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' OR dr_18.ENTITY_TYPE = 'F4_GEWRK_AGEN') AND dr_18.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS sv_19 ON dr_18.ENTITY_ID = idp_15.SUBCONTRACTOR_VALIDATOR AND (dr_18.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' OR dr_18.ENTITY_TYPE = 'F4_GEWRK_AGEN') AND dr_18.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN US_USERS_IAS AS usir_20 ON usir_20.USER_ID = bp_10.RESPONSIBLE_PERSON) LEFT JOIN US_USERS_IAS AS uscv_21 ON uscv_21.USER_ID = idp_15.CELLNEX_VALIDATOR) LEFT JOIN US_USERS_IAS AS usdr_22 ON usdr_22.USER_ID = dp_12.T_RESPONSIBLE) LEFT JOIN WORK_TYPES AS type_23 ON gt_9.type_ID = type_23.ID);

CREATE VIEW localized_project_ProcessTypes AS SELECT
  PROCESS_TYPES_0.name,
  PROCESS_TYPES_0.descr,
  PROCESS_TYPES_0.code
FROM localized_PROCESS_TYPES AS PROCESS_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_ProcessTypes_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN project_ProcessTypes_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_project_ChangesLog AS SELECT
  CHANGE_LOG_0.logId,
  CHANGE_LOG_0.requestId,
  CHANGE_LOG_0.requestType,
  CHANGE_LOG_0.changeDate,
  CHANGE_LOG_0.userId,
  CHANGE_LOG_0.userName,
  CHANGE_LOG_0.userAction,
  CHANGE_LOG_0.userActionName,
  CHANGE_LOG_0.phaseProcessFlowId,
  CHANGE_LOG_0.phaseName,
  CHANGE_LOG_0.blockProcessFlowId,
  CHANGE_LOG_0.blockName,
  CHANGE_LOG_0.fieldName,
  CHANGE_LOG_0.fieldDescription,
  CHANGE_LOG_0.oldValue,
  CHANGE_LOG_0.oldValueDescription,
  CHANGE_LOG_0.newValue,
  CHANGE_LOG_0.newValueDescription,
  CHANGE_LOG_0.phaseId,
  CHANGE_LOG_0.BlockId,
  CHANGE_LOG_0.documentName,
  CHANGE_LOG_0.workType,
  CHANGE_LOG_0.workTypeName
FROM localized_CHANGE_LOG AS CHANGE_LOG_0;

CREATE VIEW localized_project_ProjectTypes AS SELECT
  PROJECT_TYPES_0.code,
  PROJECT_TYPES_0.country,
  PROJECT_TYPES_0.name
FROM localized_PROJECT_TYPES AS PROJECT_TYPES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_ProjectTypes_texts AS texts ON (texts.code = code AND texts.country = country),
  MANY TO ONE JOIN project_ProjectTypes_texts AS localized ON (localized.code = code AND localized.country = country AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_project_BooleanValues AS SELECT
  BOOLEAN_VALUES_0.name,
  BOOLEAN_VALUES_0.descr,
  BOOLEAN_VALUES_0.code
FROM localized_BOOLEAN_VALUES AS BOOLEAN_VALUES_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_BooleanValues_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN project_BooleanValues_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_workconfiguration_DocumentDefaults AS SELECT
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.ID,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.createdAt,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.createdBy,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.modifiedAt,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.modifiedBy,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.name,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.descr,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.documentId,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.approverType,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.externalType,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.subcontractorValidationReq,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.cellnexValidationReq,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.customerValidationReq,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.landlordValidationReq,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.default,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.deleted,
  WORK_CONFIG_DOCUMENT_DEFAULTS_0.Configuration_ID
FROM localized_WORK_CONFIG_DOCUMENT_DEFAULTS AS WORK_CONFIG_DOCUMENT_DEFAULTS_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_workconfiguration_WorkConfigs AS Configuration ON (Configuration.ID = Configuration_ID),
  MANY TO MANY JOIN workconfiguration_DocumentDefaults_texts AS texts ON (texts.ID = ID),
  MANY TO ONE JOIN workconfiguration_DocumentDefaults_texts AS localized ON (localized.ID = ID AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_SEARCH_BY_BLOCKS_WORKS AS SELECT
  rh_0.REQUEST_ID AS ID,
  rh_0.REQUEST_CODE AS code,
  rh_0.REQUEST_STATUS AS requestStatus,
  rh_0.COUNTRY_ID AS country,
  rh_0.WORKFLOW_ID AS projectType,
  rp_4.PROJECT_OBJECTIVE AS projectObjective,
  gt_10.status,
  st_12.STATUS_TEXT AS statusName,
  sc_5.COMPLEXITY AS complexity,
  co_6.name AS complexityName,
  rh_0.SITE_ID AS siteId,
  sit_2.siteName,
  sit_2.region AS siteRegion,
  sit_2.city AS siteCity,
  sit_2.cellnexZone AS cellnexZone,
  sit_2.legacyCode AS siteLegacyCode,
  rp_4.REQUESTED_DATE AS requestedDate,
  rh_0.CREATEDAT AS createdAt,
  ph_7.MASTER_PHASE_ID AS masterPhaseId,
  mp_8.PHASE_NAME AS phase,
  bh_9.MASTER_BLOCK_ID AS masterBlockID,
  mb_21.BLOCK_NAME AS block,
  gt_10.ID AS workId,
  gt_10.description AS work,
  type_22.ID AS workType,
  type_22.descr AS workTypeName,
  bh_9.ROLE_ID AS roleId,
  CASE gt_10.responsibleType WHEN '1' THEN gt_10.internalResponsible WHEN '2' THEN gt_10.externalResponsible ELSE CASE bp_13.ASSIGNED_RESPONSIBLE WHEN '1' THEN bp_13.RESPONSIBLE_PERSON WHEN '2' THEN bp_13.PROVIDER_NAME ELSE NULL END END AS assignedResponsible,
  CASE gt_10.responsibleType WHEN '1' THEN usw_15.USER_NAME WHEN '2' THEN CASE gt_10.externalType WHEN '3' THEN sbw_19.ENTITY_NAME WHEN '4' THEN agw_20.ENTITY_NAME ELSE NULL END ELSE CASE bp_13.ASSIGNED_RESPONSIBLE WHEN '1' THEN usn_14.USER_NAME WHEN '2' THEN CASE bp_13.SUBCONTRACTOR_TYPE WHEN '3' THEN sb_17.ENTITY_NAME WHEN '4' THEN ag_18.ENTITY_NAME ELSE NULL END ELSE NULL END END AS assignedResponsibleName,
  '' AS validator,
  '' AS validatorName,
  bp_13.RESPONSIBLE_PERSON AS internalResponsible,
  bp_13.PROVIDER_NAME AS externalResponsible,
  rh_0.REQUEST_OWNER_ID AS manager,
  us_3.USER_NAME AS managerName,
  rp_4.PREFERRED_PROVIDER AS preferredProvider,
  pp_16.ENTITY_NAME AS preferredProviderName,
  rh_0.ASSIGNATION_DATE AS assignationDate,
  0 AS taskType,
  0 AS searchType,
  '' AS documentId,
  '' AS documentType,
  '' AS documentName,
  '' AS documentValidation
FROM ((((((((((((((((((((((REQUEST_HEAD AS rh_0 LEFT JOIN PROCESS AS p_1 ON p_1.ID_PK = rh_0.PROCESS_ID) INNER JOIN SITES AS sit_2 ON sit_2.siteId = rh_0.SITE_ID) LEFT JOIN US_USERS_IAS AS us_3 ON us_3.USER_ID = rh_0.REQUEST_OWNER_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_4 ON rp_4.REQUEST_ID = rh_0.REQUEST_ID AND (rh_0.REQUEST_TYPE = 40)) LEFT JOIN SEARCH_BY_COMPLEXITIES AS sc_5 ON sc_5.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN COMPLEXITIES AS co_6 ON co_6.code = sc_5.COMPLEXITY AND co_6.country = rh_0.COUNTRY_ID) INNER JOIN PHASE_HEAD AS ph_7 ON ph_7.REQUEST_ID = rh_0.REQUEST_ID AND ph_7.PHASE_STATUS != 2) LEFT JOIN MASTER_PHASE AS mp_8 ON mp_8.PROCESS_ID_PK = p_1.PROCESS_ID_PK AND mp_8.PHASE_ID_PK = ph_7.MASTER_PHASE_ID AND mp_8.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCK_HEAD AS bh_9 ON bh_9.PHASE_ID = ph_7.PHASE_ID) INNER JOIN WORKS AS gt_10 ON gt_10.parentId = bh_9.BLOCK_ID AND gt_10.parentType_ID = 30) LEFT JOIN localized_BLOCK_STATUS AS bs_11 ON bs_11.code = bh_9.BLOCK_STATUS) LEFT JOIN STATUS_TEXTS AS st_12 ON st_12.STATUS_CODE = gt_10.status AND st_12."LANGUAGE" = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCKS_PROVISIONING AS bp_13 ON bp_13.BLOCK_ID = bh_9.BLOCK_ID) LEFT JOIN US_USERS_IAS AS usn_14 ON usn_14.USER_ID = bp_13.RESPONSIBLE_PERSON) LEFT JOIN US_USERS_IAS AS usw_15 ON usw_15.USER_ID = gt_10.internalResponsible) LEFT JOIN CACHE_R3_ENTITIES AS pp_16 ON pp_16.ENTITY_ID = rp_4.PREFERRED_PROVIDER AND pp_16.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND pp_16.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS sb_17 ON sb_17.ENTITY_ID = bp_13.PROVIDER_NAME AND sb_17.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND sb_17.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS ag_18 ON ag_18.ENTITY_ID = bp_13.PROVIDER_NAME AND ag_18.ENTITY_TYPE = 'F4_GEWRK_AGEN' AND ag_18.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS sbw_19 ON sbw_19.ENTITY_ID = gt_10.externalResponsible AND sbw_19.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND sbw_19.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS agw_20 ON agw_20.ENTITY_ID = gt_10.externalResponsible AND agw_20.ENTITY_TYPE = 'F4_GEWRK_AGEN' AND agw_20.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN MASTER_BLOCK AS mb_21 ON mb_21.PROCESS_ID_PK = p_1.PROCESS_ID_PK AND mb_21.PHASE_ID_PK = mp_8.PHASE_ID_PK AND mb_21.BLOCK_ID_PK = bh_9.MASTER_BLOCK_ID AND mb_21.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) LEFT JOIN WORK_TYPES AS type_22 ON gt_10.type_ID = type_22.ID);

CREATE VIEW localized_SEARCH_BY_WORK_DOCUMENTS AS SELECT
  rh_0.REQUEST_ID AS ID,
  rh_0.REQUEST_CODE AS code,
  rh_0.REQUEST_STATUS AS requestStatus,
  rh_0.COUNTRY_ID AS country,
  rh_0.WORKFLOW_ID AS projectType,
  rp_3.PROJECT_OBJECTIVE AS projectObjective,
  dp_12.STATUS AS status,
  dfs_13.name AS statusName,
  sc_4.COMPLEXITY AS complexity,
  co_5.name AS complexityName,
  rh_0.SITE_ID AS siteId,
  sit_1.siteName,
  sit_1.region AS siteRegion,
  sit_1.city AS siteCity,
  sit_1.cellnexZone AS cellnexZone,
  sit_1.legacyCode AS siteLegacyCode,
  rp_3.REQUESTED_DATE AS requestedDate,
  rh_0.CREATEDAT AS createdAt,
  ph_6.MASTER_PHASE_ID AS masterPhaseId,
  mp_7.PHASE_NAME AS phase,
  bh_8.MASTER_BLOCK_ID AS masterBlockID,
  mb_11.BLOCK_NAME AS block,
  gt_9.ID AS workId,
  gt_9.description AS work,
  type_23.ID AS workType,
  type_23.descr AS workTypeName,
  CASE WHEN idp_15.STEP_ID = '0' THEN CASE WHEN dp_12.RESPONSIBLE_ID = '1' THEN 'TIS_Cellnex' WHEN dp_12.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_12.SUBCONTRATOR_ID = '2' THEN 'TIS_WF_PRO_Customer' WHEN dp_12.SUBCONTRATOR_ID = '3' THEN 'TIS_WF_PRO_Subcontractor' WHEN dp_12.SUBCONTRATOR_ID = '4' THEN 'TIS_WF_PRO_Agency' ELSE 'TIS_WF_PRO_Subcontractor' END END WHEN idp_15.STEP_ID = '10' THEN CASE WHEN dp_12.RESPONSIBLE_ID = '1' THEN 'TIS_Cellnex' WHEN dp_12.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_12.SUBCONTRATOR_ID = '2' THEN 'TIS_WF_PRO_Customer' WHEN dp_12.SUBCONTRATOR_ID = '3' THEN 'TIS_WF_PRO_Subcontractor' WHEN dp_12.SUBCONTRATOR_ID = '4' THEN 'TIS_WF_PRO_Agency' ELSE 'TIS_WF_PRO_Subcontractor' END END WHEN idp_15.STEP_ID = '20' THEN 'TIS_Cellnex' WHEN idp_15.STEP_ID = '30' THEN 'TIS_WF_PRO_Subcontractor' WHEN idp_15.STEP_ID = '40' THEN 'TIS_WF_PRO_Customer' ELSE bh_8.ROLE_ID END AS roleId,
  dp_12.T_RESPONSIBLE AS assignedResponsible,
  CASE WHEN dp_12.RESPONSIBLE_ID = '1' THEN usdr_22.USER_NAME WHEN dp_12.RESPONSIBLE_ID = '2' THEN CASE WHEN dp_12.SUBCONTRATOR_ID = '3' OR dp_12.SUBCONTRATOR_ID = '4' THEN dr_18.ENTITY_NAME END END AS assignedResponsibleName,
  CASE WHEN idp_15.STEP_ID = '20' THEN idp_15.CELLNEX_VALIDATOR WHEN idp_15.STEP_ID = '30' THEN idp_15.SUBCONTRACTOR_VALIDATOR WHEN idp_15.STEP_ID = '40' THEN idp_15.CUSTOMER_VALIDATOR ELSE dp_12.T_RESPONSIBLE END AS validator,
  CASE WHEN idp_15.STEP_ID = '20' THEN uscv_21.USER_NAME WHEN idp_15.STEP_ID = '30' THEN sv_19.ENTITY_NAME ELSE usdr_22.USER_NAME END AS validatorName,
  bp_10.RESPONSIBLE_PERSON AS internalResponsible,
  bp_10.PROVIDER_NAME AS externalResponsible,
  rh_0.REQUEST_OWNER_ID AS manager,
  uscm_16.USER_NAME AS managerName,
  rp_3.PREFERRED_PROVIDER AS preferredProvider,
  pp_17.ENTITY_NAME AS preferredProviderName,
  rh_0.ASSIGNATION_DATE AS assignationDate,
  1 AS taskType,
  0 AS searchType,
  dp_12.REGISTER_ID AS documentId,
  dp_12.GENERIC_TYPE_ID AS documentType,
  df_14.documentName,
  CASE WHEN idp_15.STEP_ID = '0' THEN 'Responsible document upload' WHEN idp_15.STEP_ID = '20' THEN 'Cellnex validation' WHEN idp_15.STEP_ID = '30' THEN 'Subcontractor validation' WHEN idp_15.STEP_ID = '40' THEN 'On behalf of Customer validation' END AS documentValidation
FROM (((((((((((((((((((((((REQUEST_HEAD AS rh_0 INNER JOIN SITES AS sit_1 ON sit_1.siteId = rh_0.SITE_ID) LEFT JOIN PROCESS AS p_2 ON p_2.ID_PK = rh_0.PROCESS_ID) INNER JOIN REQUEST_CHAR_PRO AS rp_3 ON rp_3.REQUEST_ID = rh_0.REQUEST_ID AND (rh_0.REQUEST_TYPE = 40)) LEFT JOIN SEARCH_BY_COMPLEXITIES AS sc_4 ON sc_4.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN COMPLEXITIES AS co_5 ON co_5.code = sc_4.COMPLEXITY AND co_5.country = rh_0.COUNTRY_ID) INNER JOIN PHASE_HEAD AS ph_6 ON ph_6.REQUEST_ID = rh_0.REQUEST_ID) LEFT JOIN MASTER_PHASE AS mp_7 ON mp_7.PROCESS_ID_PK = p_2.PROCESS_ID_PK AND mp_7.PHASE_ID_PK = ph_6.MASTER_PHASE_ID AND mp_7.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN BLOCK_HEAD AS bh_8 ON bh_8.PHASE_ID = ph_6.PHASE_ID) INNER JOIN WORKS AS gt_9 ON gt_9.parentId = bh_8.BLOCK_ID AND gt_9.parentType_ID = 30) INNER JOIN BLOCKS_PROVISIONING AS bp_10 ON bp_10.BLOCK_ID = bh_8.BLOCK_ID) LEFT JOIN MASTER_BLOCK AS mb_11 ON mb_11.PROCESS_ID_PK = p_2.PROCESS_ID_PK AND mb_11.PHASE_ID_PK = mp_7.PHASE_ID_PK AND mb_11.BLOCK_ID_PK = bh_8.MASTER_BLOCK_ID AND mb_11.LANGUAGE_PK = UPPER(SESSION_CONTEXT('LOCALE'))) INNER JOIN DOCUMENTS_PER_BLOCK AS dp_12 ON dp_12.BLOCK_ID = gt_9.parentId AND dp_12.WORK_ID = gt_9.ID) LEFT JOIN localized_DOCUMENT_FLOW_STATUS AS dfs_13 ON dfs_13.code = dp_12.STATUS) LEFT JOIN DOCUMENT_FLOWS AS df_14 ON df_14.documentId = dp_12.GENERIC_TYPE_ID) LEFT JOIN INSTANCES_PER_DOCUMENT AS idp_15 ON idp_15.INSTANCE_ID = dp_12.REGISTER_ID) LEFT JOIN US_USERS_IAS AS uscm_16 ON uscm_16.USER_ID = rh_0.REQUEST_OWNER_ID) LEFT JOIN CACHE_R3_ENTITIES AS pp_17 ON pp_17.ENTITY_ID = rp_3.PREFERRED_PROVIDER AND pp_17.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' AND pp_17.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS dr_18 ON dr_18.ENTITY_ID = dp_12.T_RESPONSIBLE AND (dr_18.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' OR dr_18.ENTITY_TYPE = 'F4_GEWRK_AGEN') AND dr_18.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN CACHE_R3_ENTITIES AS sv_19 ON dr_18.ENTITY_ID = idp_15.SUBCONTRACTOR_VALIDATOR AND (dr_18.ENTITY_TYPE = 'F4_PROV_VENDOR_GEWRK' OR dr_18.ENTITY_TYPE = 'F4_GEWRK_AGEN') AND dr_18.USER_ID = SESSION_CONTEXT('APPLICATIONUSER')) LEFT JOIN US_USERS_IAS AS usir_20 ON usir_20.USER_ID = bp_10.RESPONSIBLE_PERSON) LEFT JOIN US_USERS_IAS AS uscv_21 ON uscv_21.USER_ID = idp_15.CELLNEX_VALIDATOR) LEFT JOIN US_USERS_IAS AS usdr_22 ON usdr_22.USER_ID = dp_12.T_RESPONSIBLE) LEFT JOIN WORK_TYPES AS type_23 ON gt_9.type_ID = type_23.ID);

CREATE VIEW localized_project_Currencies AS SELECT
  Currencies_0.name,
  Currencies_0.descr,
  Currencies_0.code,
  Currencies_0.symbol,
  Currencies_0.minorUnit
FROM localized_sap_common_Currencies AS Currencies_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN project_Currencies_texts AS texts ON (texts.code = code),
  MANY TO ONE JOIN project_Currencies_texts AS localized ON (localized.code = code AND localized.locale = SESSION_CONTEXT('LOCALE'))
);

CREATE VIEW localized_workconfiguration_FlowsPerProcess AS SELECT
  WORK_CONFIG_PROCESSES_0.createdAt,
  WORK_CONFIG_PROCESSES_0.createdBy,
  WORK_CONFIG_PROCESSES_0.modifiedAt,
  WORK_CONFIG_PROCESSES_0.modifiedBy,
  WORK_CONFIG_PROCESSES_0.ID,
  WORK_CONFIG_PROCESSES_0.processFlowId,
  WORK_CONFIG_PROCESSES_0.phaseTypeId,
  WORK_CONFIG_PROCESSES_0.blockTypeId,
  WORK_CONFIG_PROCESSES_0.default,
  WORK_CONFIG_PROCESSES_0.Type_ID,
  WORK_CONFIG_PROCESSES_0.Configuration_ID
FROM localized_WORK_CONFIG_PROCESSES AS WORK_CONFIG_PROCESSES_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_workconfiguration_WorkTypes AS Type ON (Type.ID = Type_ID),
  MANY TO ONE JOIN localized_workconfiguration_WorkConfigs AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW localized_workconfiguration_Documents AS SELECT
  WORK_CONFIG_DOCUMENT_FLOWS_0.ID,
  WORK_CONFIG_DOCUMENT_FLOWS_0.createdAt,
  WORK_CONFIG_DOCUMENT_FLOWS_0.createdBy,
  WORK_CONFIG_DOCUMENT_FLOWS_0.modifiedAt,
  WORK_CONFIG_DOCUMENT_FLOWS_0.modifiedBy,
  WORK_CONFIG_DOCUMENT_FLOWS_0.documentId,
  WORK_CONFIG_DOCUMENT_FLOWS_0.WorkType_ID,
  WORK_CONFIG_DOCUMENT_FLOWS_0.Configuration_ID
FROM localized_WORK_CONFIG_DOCUMENT_FLOWS AS WORK_CONFIG_DOCUMENT_FLOWS_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_workconfiguration_WorkTypes AS WorkType ON (WorkType.ID = WorkType_ID),
  MANY TO ONE JOIN localized_workconfiguration_WorkConfigs AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW localized_workconfiguration_Objectives AS SELECT
  WORK_CONFIG_OBJECTIVES_0.createdAt,
  WORK_CONFIG_OBJECTIVES_0.createdBy,
  WORK_CONFIG_OBJECTIVES_0.modifiedAt,
  WORK_CONFIG_OBJECTIVES_0.modifiedBy,
  WORK_CONFIG_OBJECTIVES_0.ID,
  WORK_CONFIG_OBJECTIVES_0.objective_ID,
  WORK_CONFIG_OBJECTIVES_0.Configuration_ID
FROM localized_WORK_CONFIG_OBJECTIVES AS WORK_CONFIG_OBJECTIVES_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_workconfiguration_MasterObjectives AS objective ON (objective.ID = objective_ID),
  MANY TO ONE JOIN localized_workconfiguration_WorkConfigs AS Configuration ON (Configuration.ID = Configuration_ID)
);

CREATE VIEW localized_workconfiguration_WorkConfigs AS SELECT
  WORK_CONFIGS_0.createdAt,
  WORK_CONFIGS_0.createdBy,
  WORK_CONFIGS_0.modifiedAt,
  WORK_CONFIGS_0.modifiedBy,
  WORK_CONFIGS_0.ID,
  WORK_CONFIGS_0.description
FROM localized_WORK_CONFIGS AS WORK_CONFIGS_0
WITH ASSOCIATIONS (
  MANY TO MANY JOIN localized_workconfiguration_FlowsPerProcess AS FlowsPerProcess ON (FlowsPerProcess.Configuration_ID = ID),
  MANY TO MANY JOIN localized_workconfiguration_Objectives AS Objectives ON (Objectives.Configuration_ID = ID),
  MANY TO MANY JOIN localized_workconfiguration_Documents AS Documents ON (Documents.Configuration_ID = ID),
  MANY TO MANY JOIN localized_workconfiguration_DocumentDefaults AS DocumentDefaults ON (DocumentDefaults.Configuration_ID = ID)
);

CREATE VIEW localized_project_DocumentsPerRequest AS SELECT
  DOCUMENTS_PER_REQUEST_0.ID,
  DOCUMENTS_PER_REQUEST_0.requestId,
  DOCUMENTS_PER_REQUEST_0.phaseFlowId,
  DOCUMENTS_PER_REQUEST_0.phaseId,
  DOCUMENTS_PER_REQUEST_0.blockFlowId,
  DOCUMENTS_PER_REQUEST_0.blockId,
  DOCUMENTS_PER_REQUEST_0.createdAt,
  DOCUMENTS_PER_REQUEST_0.createdBy,
  DOCUMENTS_PER_REQUEST_0.deleted,
  DOCUMENTS_PER_REQUEST_0.deletedAt,
  DOCUMENTS_PER_REQUEST_0.deletedBy,
  DOCUMENTS_PER_REQUEST_0.modifiedAt,
  DOCUMENTS_PER_REQUEST_0.modifiedBy,
  DOCUMENTS_PER_REQUEST_0."ORDER",
  DOCUMENTS_PER_REQUEST_0.responsibleDefault,
  DOCUMENTS_PER_REQUEST_0.responsibleId,
  DOCUMENTS_PER_REQUEST_0.subcontractorId,
  DOCUMENTS_PER_REQUEST_0.cellnexValidation,
  DOCUMENTS_PER_REQUEST_0.customerValidation,
  DOCUMENTS_PER_REQUEST_0.subcontractorValidation,
  DOCUMENTS_PER_REQUEST_0.siteOwnerValidation,
  DOCUMENTS_PER_REQUEST_0.documentId,
  DOCUMENTS_PER_REQUEST_0.status,
  DOCUMENTS_PER_REQUEST_0.cellnexResponsible,
  DOCUMENTS_PER_REQUEST_0.subcontractorResponsible,
  DOCUMENTS_PER_REQUEST_0.agencyResponsible,
  DOCUMENTS_PER_REQUEST_0.customerResponsible,
  DOCUMENTS_PER_REQUEST_0.cellnexResponsibleName,
  DOCUMENTS_PER_REQUEST_0.subcontractorResponsibleName,
  DOCUMENTS_PER_REQUEST_0.agencyResponsibleName,
  DOCUMENTS_PER_REQUEST_0.customerResponsibleName,
  DOCUMENTS_PER_REQUEST_0.cellnexResponsibleFC,
  DOCUMENTS_PER_REQUEST_0.subcontractorResponsibleFC,
  DOCUMENTS_PER_REQUEST_0.agencyResponsibleFC,
  DOCUMENTS_PER_REQUEST_0.customerResponsibleFC,
  DOCUMENTS_PER_REQUEST_0.approverTypeName,
  DOCUMENTS_PER_REQUEST_0.approverTypeFC,
  DOCUMENTS_PER_REQUEST_0.subcoTypeName,
  DOCUMENTS_PER_REQUEST_0.subcoTypeFC,
  DOCUMENTS_PER_REQUEST_0.responsibleDefaultName,
  DOCUMENTS_PER_REQUEST_0.responsibleDefaultFC,
  DOCUMENTS_PER_REQUEST_0.cellnexValidationFC,
  DOCUMENTS_PER_REQUEST_0.subcontractorValidationFC,
  DOCUMENTS_PER_REQUEST_0.customerValidationFC,
  DOCUMENTS_PER_REQUEST_0.siteOwnerValidationFC,
  DOCUMENTS_PER_REQUEST_0.cellnexValidatorFC,
  DOCUMENTS_PER_REQUEST_0.subcontractorValidatorFC,
  DOCUMENTS_PER_REQUEST_0.customerValidatorFC,
  DOCUMENTS_PER_REQUEST_0.siteOwnerValidatorFC,
  DOCUMENTS_PER_REQUEST_0.documentIdFC,
  DOCUMENTS_PER_REQUEST_0.Criticality,
  DOCUMENTS_PER_REQUEST_0.stepIdVF,
  DOCUMENTS_PER_REQUEST_0.statusIconVF,
  DOCUMENTS_PER_REQUEST_0.statusStateVF,
  DOCUMENTS_PER_REQUEST_0.statusTextVF,
  DOCUMENTS_PER_REQUEST_0.cellnexStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.cellnexStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.cellnexStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.responsibleStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.responsibleStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.responsibleStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.subcontractorStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.subcontractorStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.subcontractorStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.customerStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.customerStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.customerStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.siteOwnerStatusIconVF,
  DOCUMENTS_PER_REQUEST_0.siteOwnerStatusStateVF,
  DOCUMENTS_PER_REQUEST_0.siteOwnerStatusTextVF,
  DOCUMENTS_PER_REQUEST_0.canInit,
  DOCUMENTS_PER_REQUEST_0.canSee,
  DOCUMENTS_PER_REQUEST_0.canDelete,
  DOCUMENTS_PER_REQUEST_0.canDownload,
  DOCUMENTS_PER_REQUEST_0.cellnexValidationVF,
  DOCUMENTS_PER_REQUEST_0.subcontractorValidationVF,
  DOCUMENTS_PER_REQUEST_0.customerValidationVF,
  DOCUMENTS_PER_REQUEST_0.siteOwnerValidationVF
FROM DOCUMENTS_PER_REQUEST AS DOCUMENTS_PER_REQUEST_0
WITH ASSOCIATIONS (
  MANY TO ONE JOIN localized_project_Blocks AS Blocks ON (Blocks.ID = ID),
  MANY TO ONE JOIN localized_project_InstancesPerDocuments AS InstancesPerDocuments ON (InstancesPerDocuments.instanceId = ID),
  MANY TO ONE JOIN project_ApproverTypes AS ApproverTypes ON (ApproverTypes.code = responsibleId),
  MANY TO ONE JOIN project_SubcoTypes AS SubcoTypes ON (SubcoTypes.code = subcontractorId),
  MANY TO ONE JOIN project_DocumentFlowResponsibles AS DocumentFlowResponsibles ON (DocumentFlowResponsibles.code = responsibleDefault)
);

CREATE VIEW project_SearchByRequests AS SELECT
  SEARCH_BY_REQUESTS_0.ID,
  SEARCH_BY_REQUESTS_0.code,
  SEARCH_BY_REQUESTS_0.projectType,
  SEARCH_BY_REQUESTS_0.projectTypeName,
  SEARCH_BY_REQUESTS_0.projectObjective,
  SEARCH_BY_REQUESTS_0.projectObjectiveName,
  SEARCH_BY_REQUESTS_0.status,
  SEARCH_BY_REQUESTS_0.statusName,
  SEARCH_BY_REQUESTS_0.complexity,
  SEARCH_BY_REQUESTS_0.complexityName,
  SEARCH_BY_REQUESTS_0.siteId,
  SEARCH_BY_REQUESTS_0.siteName,
  SEARCH_BY_REQUESTS_0.siteRegion,
  SEARCH_BY_REQUESTS_0.siteRegionName,
  SEARCH_BY_REQUESTS_0.siteCity,
  SEARCH_BY_REQUESTS_0.cellnexZone,
  SEARCH_BY_REQUESTS_0.cellnexZoneName,
  SEARCH_BY_REQUESTS_0.lastPhase,
  SEARCH_BY_REQUESTS_0.lastBlock,
  SEARCH_BY_REQUESTS_0.lastPhaseName,
  SEARCH_BY_REQUESTS_0.lastBlockName,
  SEARCH_BY_REQUESTS_0.siteLegacyCode,
  SEARCH_BY_REQUESTS_0.requestedDate,
  SEARCH_BY_REQUESTS_0.createdAt,
  SEARCH_BY_REQUESTS_0.manager,
  SEARCH_BY_REQUESTS_0.managerName,
  SEARCH_BY_REQUESTS_0.preferredProvider,
  SEARCH_BY_REQUESTS_0.preferredProviderName,
  SEARCH_BY_REQUESTS_0.assignationDate,
  SEARCH_BY_REQUESTS_0.searchType,
  SEARCH_BY_REQUESTS_0.objectStatus
FROM SEARCH_BY_REQUESTS AS SEARCH_BY_REQUESTS_0;

CREATE VIEW SEARCH_BY_TASKS_WOTASK AS SELECT
  SEARCH_BY_BLOCKS_0.ID,
  SEARCH_BY_BLOCKS_0.code,
  SEARCH_BY_BLOCKS_0.requestStatus,
  SEARCH_BY_BLOCKS_0.country,
  SEARCH_BY_BLOCKS_0.projectType,
  SEARCH_BY_BLOCKS_0.projectObjective,
  SEARCH_BY_BLOCKS_0.status,
  SEARCH_BY_BLOCKS_0.statusName,
  SEARCH_BY_BLOCKS_0.complexity,
  SEARCH_BY_BLOCKS_0.complexityName,
  SEARCH_BY_BLOCKS_0.siteId,
  SEARCH_BY_BLOCKS_0.siteName,
  SEARCH_BY_BLOCKS_0.siteRegion,
  SEARCH_BY_BLOCKS_0.siteCity,
  SEARCH_BY_BLOCKS_0.cellnexZone,
  SEARCH_BY_BLOCKS_0.siteLegacyCode,
  SEARCH_BY_BLOCKS_0.requestedDate,
  SEARCH_BY_BLOCKS_0.createdAt,
  SEARCH_BY_BLOCKS_0.masterPhaseId,
  SEARCH_BY_BLOCKS_0.phase,
  SEARCH_BY_BLOCKS_0.masterBlockID,
  SEARCH_BY_BLOCKS_0.block,
  SEARCH_BY_BLOCKS_0.workId,
  SEARCH_BY_BLOCKS_0.work,
  SEARCH_BY_BLOCKS_0.workType,
  SEARCH_BY_BLOCKS_0.workTypeName,
  SEARCH_BY_BLOCKS_0.roleId,
  SEARCH_BY_BLOCKS_0.assignedResponsible,
  SEARCH_BY_BLOCKS_0.assignedResponsibleName,
  SEARCH_BY_BLOCKS_0.validator,
  SEARCH_BY_BLOCKS_0.validatorName,
  SEARCH_BY_BLOCKS_0.internalResponsible,
  SEARCH_BY_BLOCKS_0.externalResponsible,
  SEARCH_BY_BLOCKS_0.manager,
  SEARCH_BY_BLOCKS_0.managerName,
  SEARCH_BY_BLOCKS_0.preferredProvider,
  SEARCH_BY_BLOCKS_0.preferredProviderName,
  SEARCH_BY_BLOCKS_0.assignationDate,
  SEARCH_BY_BLOCKS_0.taskType,
  SEARCH_BY_BLOCKS_0.searchType,
  SEARCH_BY_BLOCKS_0.documentId,
  SEARCH_BY_BLOCKS_0.documentType,
  SEARCH_BY_BLOCKS_0.documentName,
  SEARCH_BY_BLOCKS_0.documentValidation
FROM SEARCH_BY_BLOCKS AS SEARCH_BY_BLOCKS_0
UNION ALL SELECT
  SEARCH_BY_BLOCKS_WORKS_1.ID,
  SEARCH_BY_BLOCKS_WORKS_1.code,
  SEARCH_BY_BLOCKS_WORKS_1.requestStatus,
  SEARCH_BY_BLOCKS_WORKS_1.country,
  SEARCH_BY_BLOCKS_WORKS_1.projectType,
  SEARCH_BY_BLOCKS_WORKS_1.projectObjective,
  SEARCH_BY_BLOCKS_WORKS_1.status,
  SEARCH_BY_BLOCKS_WORKS_1.statusName,
  SEARCH_BY_BLOCKS_WORKS_1.complexity,
  SEARCH_BY_BLOCKS_WORKS_1.complexityName,
  SEARCH_BY_BLOCKS_WORKS_1.siteId,
  SEARCH_BY_BLOCKS_WORKS_1.siteName,
  SEARCH_BY_BLOCKS_WORKS_1.siteRegion,
  SEARCH_BY_BLOCKS_WORKS_1.siteCity,
  SEARCH_BY_BLOCKS_WORKS_1.cellnexZone,
  SEARCH_BY_BLOCKS_WORKS_1.siteLegacyCode,
  SEARCH_BY_BLOCKS_WORKS_1.requestedDate,
  SEARCH_BY_BLOCKS_WORKS_1.createdAt,
  SEARCH_BY_BLOCKS_WORKS_1.masterPhaseId,
  SEARCH_BY_BLOCKS_WORKS_1.phase,
  SEARCH_BY_BLOCKS_WORKS_1.masterBlockID,
  SEARCH_BY_BLOCKS_WORKS_1.block,
  SEARCH_BY_BLOCKS_WORKS_1.workId,
  SEARCH_BY_BLOCKS_WORKS_1.work,
  SEARCH_BY_BLOCKS_WORKS_1.workType,
  SEARCH_BY_BLOCKS_WORKS_1.workTypeName,
  SEARCH_BY_BLOCKS_WORKS_1.roleId,
  SEARCH_BY_BLOCKS_WORKS_1.assignedResponsible,
  SEARCH_BY_BLOCKS_WORKS_1.assignedResponsibleName,
  SEARCH_BY_BLOCKS_WORKS_1.validator,
  SEARCH_BY_BLOCKS_WORKS_1.validatorName,
  SEARCH_BY_BLOCKS_WORKS_1.internalResponsible,
  SEARCH_BY_BLOCKS_WORKS_1.externalResponsible,
  SEARCH_BY_BLOCKS_WORKS_1.manager,
  SEARCH_BY_BLOCKS_WORKS_1.managerName,
  SEARCH_BY_BLOCKS_WORKS_1.preferredProvider,
  SEARCH_BY_BLOCKS_WORKS_1.preferredProviderName,
  SEARCH_BY_BLOCKS_WORKS_1.assignationDate,
  SEARCH_BY_BLOCKS_WORKS_1.taskType,
  SEARCH_BY_BLOCKS_WORKS_1.searchType,
  SEARCH_BY_BLOCKS_WORKS_1.documentId,
  SEARCH_BY_BLOCKS_WORKS_1.documentType,
  SEARCH_BY_BLOCKS_WORKS_1.documentName,
  SEARCH_BY_BLOCKS_WORKS_1.documentValidation
FROM SEARCH_BY_BLOCKS_WORKS AS SEARCH_BY_BLOCKS_WORKS_1
UNION ALL SELECT
  SEARCH_BY_DOCUMENTS_2.ID,
  SEARCH_BY_DOCUMENTS_2.code,
  SEARCH_BY_DOCUMENTS_2.requestStatus,
  SEARCH_BY_DOCUMENTS_2.country,
  SEARCH_BY_DOCUMENTS_2.projectType,
  SEARCH_BY_DOCUMENTS_2.projectObjective,
  SEARCH_BY_DOCUMENTS_2.status,
  SEARCH_BY_DOCUMENTS_2.statusName,
  SEARCH_BY_DOCUMENTS_2.complexity,
  SEARCH_BY_DOCUMENTS_2.complexityName,
  SEARCH_BY_DOCUMENTS_2.siteId,
  SEARCH_BY_DOCUMENTS_2.siteName,
  SEARCH_BY_DOCUMENTS_2.siteRegion,
  SEARCH_BY_DOCUMENTS_2.siteCity,
  SEARCH_BY_DOCUMENTS_2.cellnexZone,
  SEARCH_BY_DOCUMENTS_2.siteLegacyCode,
  SEARCH_BY_DOCUMENTS_2.requestedDate,
  SEARCH_BY_DOCUMENTS_2.createdAt,
  SEARCH_BY_DOCUMENTS_2.masterPhaseId,
  SEARCH_BY_DOCUMENTS_2.phase,
  SEARCH_BY_DOCUMENTS_2.masterBlockID,
  SEARCH_BY_DOCUMENTS_2.block,
  SEARCH_BY_DOCUMENTS_2.workId,
  SEARCH_BY_DOCUMENTS_2.work,
  SEARCH_BY_DOCUMENTS_2.workType,
  SEARCH_BY_DOCUMENTS_2.workTypeName,
  SEARCH_BY_DOCUMENTS_2.roleId,
  SEARCH_BY_DOCUMENTS_2.assignedResponsible,
  SEARCH_BY_DOCUMENTS_2.assignedResponsibleName,
  SEARCH_BY_DOCUMENTS_2.validator,
  SEARCH_BY_DOCUMENTS_2.validatorName,
  SEARCH_BY_DOCUMENTS_2.internalResponsible,
  SEARCH_BY_DOCUMENTS_2.externalResponsible,
  SEARCH_BY_DOCUMENTS_2.manager,
  SEARCH_BY_DOCUMENTS_2.managerName,
  SEARCH_BY_DOCUMENTS_2.preferredProvider,
  SEARCH_BY_DOCUMENTS_2.preferredProviderName,
  SEARCH_BY_DOCUMENTS_2.assignationDate,
  SEARCH_BY_DOCUMENTS_2.taskType,
  SEARCH_BY_DOCUMENTS_2.searchType,
  SEARCH_BY_DOCUMENTS_2.documentId,
  SEARCH_BY_DOCUMENTS_2.documentType,
  SEARCH_BY_DOCUMENTS_2.documentName,
  SEARCH_BY_DOCUMENTS_2.documentValidation
FROM SEARCH_BY_DOCUMENTS AS SEARCH_BY_DOCUMENTS_2;

CREATE VIEW SEARCH_BY_TASKS AS SELECT
  SEARCH_BY_TASKS_WOTASK_0.ID,
  SEARCH_BY_TASKS_WOTASK_0.code,
  SEARCH_BY_TASKS_WOTASK_0.requestStatus,
  st_3.name AS requestStatusName,
  SEARCH_BY_TASKS_WOTASK_0.country,
  SEARCH_BY_TASKS_WOTASK_0.projectType,
  pt_6.name AS projectTypeName,
  SEARCH_BY_TASKS_WOTASK_0.projectObjective,
  po_7.name AS projectObjectiveName,
  SEARCH_BY_TASKS_WOTASK_0.status,
  SEARCH_BY_TASKS_WOTASK_0.statusName,
  SEARCH_BY_TASKS_WOTASK_0.complexity,
  SEARCH_BY_TASKS_WOTASK_0.complexityName,
  SEARCH_BY_TASKS_WOTASK_0.siteId,
  SEARCH_BY_TASKS_WOTASK_0.siteName,
  SEARCH_BY_TASKS_WOTASK_0.siteRegion,
  rg_5.description AS siteRegionName,
  SEARCH_BY_TASKS_WOTASK_0.siteCity,
  SEARCH_BY_TASKS_WOTASK_0.cellnexZone,
  cz_4.description AS cellnexZoneName,
  SEARCH_BY_TASKS_WOTASK_0.siteLegacyCode,
  SEARCH_BY_TASKS_WOTASK_0.requestedDate,
  SEARCH_BY_TASKS_WOTASK_0.createdAt,
  SEARCH_BY_TASKS_WOTASK_0.masterPhaseId,
  SEARCH_BY_TASKS_WOTASK_0.phase,
  SEARCH_BY_TASKS_WOTASK_0.masterBlockID,
  SEARCH_BY_TASKS_WOTASK_0.block,
  la_1.lastPhase,
  la_1.lastPhaseName,
  la_1.lastBlock,
  la_1.lastBlockName,
  SEARCH_BY_TASKS_WOTASK_0.roleId,
  SEARCH_BY_TASKS_WOTASK_0.workId,
  SEARCH_BY_TASKS_WOTASK_0.work,
  SEARCH_BY_TASKS_WOTASK_0.workType,
  SEARCH_BY_TASKS_WOTASK_0.workTypeName,
  SEARCH_BY_TASKS_WOTASK_0.assignedResponsible,
  SEARCH_BY_TASKS_WOTASK_0.assignedResponsibleName,
  SEARCH_BY_TASKS_WOTASK_0.validator,
  SEARCH_BY_TASKS_WOTASK_0.validatorName,
  SEARCH_BY_TASKS_WOTASK_0.internalResponsible,
  SEARCH_BY_TASKS_WOTASK_0.externalResponsible,
  SEARCH_BY_TASKS_WOTASK_0.manager,
  SEARCH_BY_TASKS_WOTASK_0.managerName,
  SEARCH_BY_TASKS_WOTASK_0.preferredProvider,
  SEARCH_BY_TASKS_WOTASK_0.preferredProviderName,
  SEARCH_BY_TASKS_WOTASK_0.assignationDate,
  SEARCH_BY_TASKS_WOTASK_0.taskType,
  tt_2.name AS taskTypeName,
  SEARCH_BY_TASKS_WOTASK_0.searchType,
  SEARCH_BY_TASKS_WOTASK_0.documentId,
  SEARCH_BY_TASKS_WOTASK_0.documentType,
  SEARCH_BY_TASKS_WOTASK_0.documentName,
  SEARCH_BY_TASKS_WOTASK_0.documentValidation,
  CASE WHEN SEARCH_BY_TASKS_WOTASK_0.status = 7 THEN 2 WHEN SEARCH_BY_TASKS_WOTASK_0.status = 3 THEN 3 WHEN SEARCH_BY_TASKS_WOTASK_0.status = 4 THEN 1 ELSE 0 END AS objectStatus,
  CASE WHEN SEARCH_BY_TASKS_WOTASK_0.requestStatus = 7 THEN 2 WHEN SEARCH_BY_TASKS_WOTASK_0.requestStatus = 3 THEN 3 WHEN SEARCH_BY_TASKS_WOTASK_0.requestStatus = 4 THEN 1 WHEN SEARCH_BY_TASKS_WOTASK_0.requestStatus = 12 THEN 1 WHEN SEARCH_BY_TASKS_WOTASK_0.requestStatus = 32 THEN 2 ELSE 0 END AS objectRequestStatus,
  CASE WHEN la_1.lastPhase = SEARCH_BY_TASKS_WOTASK_0.masterPhaseId AND la_1.lastBlock = SEARCH_BY_TASKS_WOTASK_0.masterBlockID THEN TRUE ELSE FALSE END AS isFirstBlock
FROM (((((((SEARCH_BY_TASKS_WOTASK AS SEARCH_BY_TASKS_WOTASK_0 LEFT JOIN LAST_ACTIVE_PHASE_BLOCK AS la_1 ON la_1.REQUEST_ID = SEARCH_BY_TASKS_WOTASK_0.ID) LEFT JOIN localized_TASK_TYPES AS tt_2 ON tt_2.code = SEARCH_BY_TASKS_WOTASK_0.taskType) LEFT JOIN localized_REQUEST_STATUS AS st_3 ON st_3.code = SEARCH_BY_TASKS_WOTASK_0.requestStatus) LEFT JOIN CELLNEX_ZONES AS cz_4 ON cz_4.code = SEARCH_BY_TASKS_WOTASK_0.cellnexZone) LEFT JOIN REGIONS AS rg_5 ON rg_5.country = SEARCH_BY_TASKS_WOTASK_0.country AND rg_5.code = SEARCH_BY_TASKS_WOTASK_0.siteRegion) LEFT JOIN AUX_PROJECT_TYPES AS pt_6 ON pt_6.code = SEARCH_BY_TASKS_WOTASK_0.projectType AND pt_6.country = SEARCH_BY_TASKS_WOTASK_0.country) LEFT JOIN PROJECT_OBJECTIVES_BY_COUNTRY AS po_7 ON po_7.ID = SEARCH_BY_TASKS_WOTASK_0.projectObjective AND po_7.country = SEARCH_BY_TASKS_WOTASK_0.country);

CREATE VIEW project_SearchByTasks AS SELECT
  SEARCH_BY_TASKS_0.ID,
  SEARCH_BY_TASKS_0.code,
  SEARCH_BY_TASKS_0.projectType,
  SEARCH_BY_TASKS_0.projectTypeName,
  SEARCH_BY_TASKS_0.projectObjective,
  SEARCH_BY_TASKS_0.projectObjectiveName,
  SEARCH_BY_TASKS_0.requestStatus,
  SEARCH_BY_TASKS_0.requestStatusName,
  SEARCH_BY_TASKS_0.status,
  SEARCH_BY_TASKS_0.statusName,
  SEARCH_BY_TASKS_0.complexity,
  SEARCH_BY_TASKS_0.complexityName,
  SEARCH_BY_TASKS_0.siteId,
  SEARCH_BY_TASKS_0.siteName,
  SEARCH_BY_TASKS_0.siteRegion,
  SEARCH_BY_TASKS_0.siteRegionName,
  SEARCH_BY_TASKS_0.siteCity,
  SEARCH_BY_TASKS_0.cellnexZone,
  SEARCH_BY_TASKS_0.cellnexZoneName,
  SEARCH_BY_TASKS_0.siteLegacyCode,
  SEARCH_BY_TASKS_0.requestedDate,
  SEARCH_BY_TASKS_0.createdAt,
  SEARCH_BY_TASKS_0.masterPhaseId,
  SEARCH_BY_TASKS_0.phase,
  SEARCH_BY_TASKS_0.masterBlockID,
  SEARCH_BY_TASKS_0.block,
  SEARCH_BY_TASKS_0.lastPhase,
  SEARCH_BY_TASKS_0.lastBlock,
  SEARCH_BY_TASKS_0.lastPhaseName,
  SEARCH_BY_TASKS_0.lastBlockName,
  SEARCH_BY_TASKS_0.isFirstBlock,
  SEARCH_BY_TASKS_0.roleId,
  SEARCH_BY_TASKS_0.workId,
  SEARCH_BY_TASKS_0.work,
  SEARCH_BY_TASKS_0.workType,
  SEARCH_BY_TASKS_0.workTypeName,
  SEARCH_BY_TASKS_0.assignedResponsible,
  SEARCH_BY_TASKS_0.assignedResponsibleName,
  SEARCH_BY_TASKS_0.manager,
  SEARCH_BY_TASKS_0.managerName,
  SEARCH_BY_TASKS_0.preferredProvider,
  SEARCH_BY_TASKS_0.preferredProviderName,
  SEARCH_BY_TASKS_0.assignationDate,
  SEARCH_BY_TASKS_0.searchType,
  SEARCH_BY_TASKS_0.taskType,
  SEARCH_BY_TASKS_0.taskTypeName,
  SEARCH_BY_TASKS_0.documentType,
  SEARCH_BY_TASKS_0.documentName,
  SEARCH_BY_TASKS_0.documentValidation,
  SEARCH_BY_TASKS_0.objectStatus,
  SEARCH_BY_TASKS_0.objectRequestStatus
FROM SEARCH_BY_TASKS AS SEARCH_BY_TASKS_0;

