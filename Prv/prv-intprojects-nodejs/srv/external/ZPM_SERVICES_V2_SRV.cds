/* checksum : d7d34cad4fdea8d55cd1a324bd84ef2e */
@cds.external : true
@m.IsDefaultEntityContainer : 'true'
@sap.supported.formats : 'atom json xlsx'
service ZPM_SERVICES_V2_SRV {};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.services {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Compliance Check'
  zcompliance : Boolean;
  @sap.label : 'Functional loc.'
  siteId : String(40);
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Date'
  lastReadyInvoiceDate : Timestamp;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Date'
  stopInvoiceDate : Timestamp;
  @sap.label : 'Description'
  serviceName : String(200) not null;
  @sap.label : 'Description'
  siteName : String(40);
  @sap.label : 'Legacy for service'
  legacyId : String(20);
  @sap.label : 'Service Catalog Elem'
  catalogId : String(18) not null;
  @sap.label : 'Description'
  catalogName : String(40);
  @sap.label : 'Class'
  catalogClass : String(18) not null;
  @sap.label : 'Description'
  catalogClassDescription : String(40);
  @sap.label : 'Class'
  instanceClass : String(18) not null;
  @sap.label : 'Description'
  instanceClassDescription : String(40);
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Date'
  createdOn : Timestamp;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Date'
  startDate : Timestamp;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Date'
  endDate : Timestamp;
  @sap.label : 'Company Code'
  companyCode : String(4) not null;
  @sap.label : 'Company Name'
  companyName : String(25);
  @sap.label : 'BusinessPartner'
  customerId : String(10) not null;
  @sap.label : 'First Name'
  customerName : String(40);
  @sap.label : 'Customer (Old)'
  customerOldId : String(10);
  @sap.label : 'Name'
  customerOldName : String(35);
  @sap.label : 'BusinessPartner'
  invoiceRecepient : String(10);
  @sap.label : 'First Name'
  invoiceRecepientName : String(40);
  @sap.label : 'BusinessPartner'
  serviceHolder : String(10);
  @sap.label : 'First Name'
  serviceHolderName : String(40);
  @sap.label : 'Opertative status'
  operativeStatus : String(4) not null;
  @sap.label : 'Short text'
  opStatusDescription : String(60);
  @sap.label : 'Invoincing status'
  invoiceStatus : String(25);
  @sap.label : 'Invoicing Status Des'
  invoiceStatusDescription : String(80);
  @sap.label : 'Business Line'
  businessLine : String(10);
  @sap.label : 'Opportunity'
  opportunity : String(100);
  @sap.label : 'Agreement'
  agreement : String(20);
  @sap.label : 'Ope. contract'
  opeContract : String(64);
  @sap.label : 'Operative Contract'
  operativeContract : String(30);
  @sap.label : 'Char 70'
  contractNumber : String(70);
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Date'
  contractEndDate : Timestamp;
  @sap.label : 'Tree ID'
  treeId : String(12);
  @sap.label : 'Node ID'
  nodeId : String(12);
  @sap.label : 'Node Description'
  nodeName : String(120);
  @sap.label : 'TRUE'
  isDeleted : Boolean;
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  modifiedAt : DateTime;
  @sap.label : 'Workflow'
  workflow : String(25);
  @sap.label : 'App'
  workflowApp : String(50);
  @sap.label : 'Phase'
  workflowPhase : String(100);
  @sap.label : 'TRUE'
  zzModifyNote : Boolean;
  @sap.label : 'TRUE'
  zzPopEnergy : Boolean;
  @sap.label : 'TRUE'
  zzPopFlag : Boolean;
  @sap.label : 'TRUE'
  zzEnergyFlag : Boolean;
  @sap.label : 'Pop Energy Int'
  zzPopEnergIdint : String(15);
  @sap.label : 'TRUE'
  noHeaderUpdateRequired : Boolean not null;
  @sap.label : 'C. Element ID'
  commercialElementId : String(36);
  @sap.label : 'C. Element Desc'
  commercialElementDescription : String(500);
  to_ServiceLocations : Association to many ZPM_SERVICES_V2_SRV.serviceLocations {  };
  to_ServiceEquipments : Association to many ZPM_SERVICES_V2_SRV.serviceEquipments {  };
  to_ServiceContacts : Association to many ZPM_SERVICES_V2_SRV.serviceContacts {  };
  to_ServiceNotes : Association to many ZPM_SERVICES_V2_SRV.serviceNotes {  };
  to_ServiceReservedConfiguration : Association to ZPM_SERVICES_V2_SRV.serviceReservedConfigurations {  };
  to_ServiceAliases : Association to many ZPM_SERVICES_V2_SRV.serviceAliases {  };
  to_CustomerPo : Association to many ZPM_SERVICES_V2_SRV.serviceCustomerPos {  };
  to_AvailableEquipments : Association to many ZPM_SERVICES_V2_SRV.serviceEquipments {  };
  to_ServiceAttributes : Association to many ZPM_SERVICES_V2_SRV.serviceAttributes {  };
  to_ServiceRequests : Association to many ZPM_SERVICES_V2_SRV.serviceRequests {  };
  to_Classifications : Association to ZPM_SERVICES_V2_SRV.classifications {  };
  to_ServiceOpStatusLogs : Association to many ZPM_SERVICES_V2_SRV.serviceOperationStatusLogs {  };
  to_ServiceLogs : Association to many ZPM_SERVICES_V2_SRV.serviceLogs {  };
  to_hardcodes : Association to many ZPM_SERVICES_V2_SRV.hardcodes {  };
  to_serviceHierarchyFrom : Association to many ZPM_SERVICES_V2_SRV.serviceHierarchies {  };
  to_serviceHierarchyTo : Association to many ZPM_SERVICES_V2_SRV.serviceHierarchies {  };
  to_FirstServiceLog : Association to ZPM_SERVICES_V2_SRV.serviceLogs {  };
  to_LastServiceLog : Association to ZPM_SERVICES_V2_SRV.serviceLogs {  };
  to_AvailableMeters : Association to many ZPM_SERVICES_V2_SRV.meters {  };
  to_Formfactor : Association to many ZPM_SERVICES_V2_SRV.equipmentFormFactors {  };
  to_ServiceCatalog : Association to ZPM_SERVICES_V2_SRV.serviceCatalogs {  };
  to_RelatedServices : Association to many ZPM_SERVICES_V2_SRV.serviceToServiceRelations {  };
  to_ExternalProject : Association to many ZPM_SERVICES_V2_SRV.externalProjects {  };
  to_TarificationTool : Association to many ZPM_SERVICES_V2_SRV.tarificationTools {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceLocations {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Functional loc.'
  key locationId : String(40) not null;
  @sap.label : 'Location description'
  locationName : String(40);
  @sap.label : 'SupFunctLoc.'
  parentLocationId : String(40);
  @sap.label : 'Location description'
  parentLocationName : String(40);
  @sap.label : 'Class'
  locationClass : String(18) not null;
  @sap.label : 'Keyword'
  locationClassDescription : String(40);
  @sap.label : 'FunctLocCat.'
  category : String(1) not null;
  @sap.label : 'Text Location Catego'
  categoryDescription : String(50);
  @sap.label : 'MaintPlant'
  maintenancePlant : String(4) not null;
  @sap.label : 'Name 1'
  maintenancePlantName : String(30);
  @sap.label : 'Company Code'
  companyCode : String(4) not null;
  @sap.label : 'Company Name'
  companyName : String(25);
  @sap.label : 'Planning plant'
  maintenancePlanningPlant : String(4) not null;
  @sap.label : 'Name 1'
  maintenancePlanningPlantName : String(30);
  @sap.label : 'Planner group'
  plannerGroup : String(3) not null;
  @sap.label : 'PM PlGrp name'
  plannerGroupDescription : String(18) not null;
  @sap.label : 'TRUE'
  isActive : Boolean not null;
  @sap.label : 'TRUE'
  isDeleted : Boolean not null;
  @sap.label : 'TRUE'
  hasSite : Boolean not null;
  site : String(30) not null;
  @sap.label : 'Location description'
  siteName : String(40);
  @sap.label : 'Functional loc.'
  intCode : String(40) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.invoiceStatuses {
  @sap.label : 'Invoice Status'
  key invoiceStatusId : String(4) not null;
  @sap.label : 'Invoicing Status Des'
  invoiceStatusDescription : String(80) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.operationalStatuses {
  @sap.label : 'Opertative status'
  key operationalStatusId : String(4) not null;
  @sap.label : 'Short Descript.'
  operationalStatusDescription : String(60) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceEquipments {
  @sap.label : 'Equipment'
  key equipmentId : String(18) not null;
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Keyword'
  classDescription : String(40);
  @sap.label : 'Class'
  classId : String(18);
  @sap.label : 'Description'
  equipmentName : String(40);
  @sap.label : 'Failed Propagation Description'
  failurePropagationTypeDesc : String(60);
  @sap.label : 'FailureProp'
  failurePropagationTypeId : String(2);
  @sap.label : 'TRUE'
  isDeleted : Boolean not null;
  @sap.label : 'Single-Character Flag'
  isUpdate : String(1);
  @sap.label : 'Partner'
  partnerId : String(12);
  @sap.label : 'c'
  partnerName : String(50);
  @sap.label : 'Description'
  serviceName : String(200);
  @sap.label : 'Status'
  status : String(5);
  @sap.label : 'Description'
  statusDescription : String(20);
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceContacts {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'BusinessPartner'
  key businessPartnerId : String(10) not null;
  @sap.label : 'First Name'
  businessPartnerFirstName : String(40);
  @sap.label : 'Last Name'
  businessPartnerLastName : String(40);
  @sap.label : 'Full Name'
  businessPartnerName : String(80);
  @sap.label : 'TRUE'
  isActive : String(10);
  @sap.label : 'Deletion block'
  isDeleted : Boolean;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.catalogAttributes {
  @sap.label : 'Service Catalog Elem'
  key catalogId : String(18) not null;
  key counter : Integer not null;
  key characteristic : String(30) not null;
  @sap.label : 'Class'
  catalogClass : String(18) not null;
  valueFrom : String(70) not null;
  valueTo : String(70) not null;
  characteristicDescription : String(30) not null;
  characteristicDataType : String(20) not null;
  @sap.label : 'Indicator'
  applyOnlyEmptyValue : Boolean not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceNotes {
  key serviceId : String(40) not null;
  key noteTitle : String(50) not null;
  key version : Integer not null;
  @sap.label : 'Note category'
  categoryId : String(6) not null;
  @sap.label : 'Notes'
  content : String(255) not null;
  @sap.label : 'TRUE'
  isDeleted : Boolean not null;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Time Stamp'
  createdAt : Timestamp;
  @sap.label : 'Full Name'
  createdBy : String(80) not null;
  @sap.label : 'TRUE'
  isActive : Boolean not null;
  @sap.label : 'Title Note'
  categoryDescription : String(50) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceReservedConfigurations {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  antenna : Integer;
  dishes : Integer;
  feeders : Integer;
  upperEquipment : Integer;
  lowerEquipment : Integer;
  groundBased : Integer;
  antennaSqm : Decimal(10, 6);
  dishesSqm : Decimal(10, 6);
  feederSqm : Decimal(10, 6);
  upperEquipmentSqm : Decimal(10, 6);
  lowerEquipmentSqm : Decimal(10, 6);
  groundBasedSqm : Decimal(10, 6);
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceAliases {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Client loc. code'
  key aliasId : String(80) not null;
  @sap.label : 'Cl. localiz. name'
  alias : String(80) not null;
  @sap.label : 'Name/address'
  businessPartnerName : String(80) not null;
  @sap.label : 'Client area'
  businessPartnerArea : String(30) not null;
  @sap.label : 'BusinessPartner'
  businessPartner : String(10) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceCustomerPos {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Char20'
  key customerPo : String(20) not null;
  @sap.label : 'Data field'
  comments : String(250) not null;
  @sap.label : 'Company Code'
  sellerId : String(4) not null;
  @sap.label : 'Company Name'
  sellerName : String(25) not null;
  @sap.label : 'BusinessPartner'
  customer : String(10) not null;
  @sap.label : 'First Name'
  customerName : String(40) not null;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Document Date'
  orderDate : Timestamp not null;
  @sap.unit : 'currency'
  @sap.label : 'Net value'
  orderValue : Decimal(16, 3) not null;
  @sap.label : 'Currency'
  @sap.semantics : 'currency-code'
  currency : String(5) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceAttributes {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Class'
  key instanceClass : String(18) not null;
  key characteristic : String(30) not null;
  key counter : Integer not null;
  characteristicDescription : String(30) not null;
  valueFrom : String(70) not null;
  valueTo : String(70) not null;
  dataType : String(20) not null;
  @sap.label : 'Indicator'
  applyOnlyEmptyValue : Boolean not null;
  to_Classifications : Association to ZPM_SERVICES_V2_SRV.classifications {  };
  to_CharacteristicDefinition : Association to ZPM_SERVICES_V2_SRV.characteristics {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceRequests {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Id request'
  key requestId : String(25) not null;
  @sap.label : 'TRUE'
  isDeleted : Boolean not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceBundles {
  key zzbunIdIntern : String(15) not null;
  operation : String(1) not null;
  @sap.label : 'Indicator'
  zzbundleFlg : Boolean not null;
  @sap.label : 'Name'
  zzcustTxt : String(35) not null;
  @sap.label : 'Deletion block'
  zzmarkDel : Boolean not null;
  @sap.label : 'Functional loc.'
  zzsite : String(40) not null;
  @sap.label : 'BusinessPartner'
  zzbusinesSprtnr : String(10) not null;
  @sap.label : 'Customer (Old)'
  zzcustomer : String(10) not null;
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  createDat : DateTime;
  @sap.label : 'Number'
  zzbundleType : String(6) not null;
  @sap.label : 'User'
  createdBy : String(12) not null;
  zzbundleTypeDesc : String(50) not null;
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  modifieDat : DateTime;
  zzbundleDesc : String(250) not null;
  @sap.label : 'User'
  modifiedBy : String(12) not null;
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  deletedAt : DateTime;
  @sap.label : 'User'
  deletedBy : String(12) not null;
  to_serviceBundleServ : Association to many ZPM_SERVICES_V2_SRV.serviceBundleServSet {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceHierarchies {
  @sap.label : 'Srv From'
  key idServiceFrom : String(15) not null;
  @sap.label : 'Srv To'
  key idServiceTo : String(15) not null;
  @sap.label : 'RelType'
  relType : String(2) not null;
  @sap.label : 'FailureProp'
  failProp : String(2) not null;
  @sap.label : 'Deletion Flag'
  deletion : Boolean not null;
  @sap.label : 'User'
  createdBy : String(12) not null;
  @sap.label : 'Time Stamp'
  createdAt : String(15) not null;
  @sap.label : 'User'
  modifiedBy : String(12) not null;
  @sap.label : 'Time Stamp'
  modifiedAt : String(15) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.characteristics {
  key characteristicId : String(30) not null;
  key class : String(18) not null;
  @sap.label : 'Value'
  dynamicSearch : String(132) not null;
  @sap.label : 'Indicator'
  caseSensitive : Boolean not null;
  defaultvalueFrom : String(70) not null;
  parentCharacteristic : String(30) not null;
  defaultvalueTo : String(70) not null;
  @sap.label : 'Indicator'
  isVisible : Boolean not null;
  @sap.label : 'String'
  frontendCondition : LargeString not null;
  @sap.label : 'Currency'
  currency : String(5) not null;
  dataType : String(20) not null;
  description : String(30) not null;
  @sap.label : 'Indicator'
  hasAdditionalValues : Boolean not null;
  @sap.label : 'Indicator'
  hasListOfValues : Boolean not null;
  @sap.label : 'Indicator'
  isIntervalValuesAllowed : Boolean not null;
  @sap.label : 'Indicator'
  isNegativeValuesAllowed : Boolean not null;
  @sap.label : 'Indicator'
  isRequired : Boolean not null;
  @sap.label : 'Number of characters'
  numberOfCharacters : String(2) not null;
  numberOfDecimals : String(2) not null;
  parentClass : String(18) not null;
  referenceTable : String(30) not null;
  type : String(100) not null;
  @sap.label : 'Technical'
  unitOfMeasure : String(6) not null;
  valueAssignment : String(20) not null;
  to_AllowedValues : Association to many ZPM_SERVICES_V2_SRV.characteristicAllowedValues {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.classifications {
  @sap.label : 'Class'
  key ClassId : String(18) not null;
  to_Characteristics : Association to many ZPM_SERVICES_V2_SRV.characteristics {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.characteristicAllowedValues {
  key characteristic : String(30) not null;
  key class : String(18) not null;
  key counter : Integer not null;
  description : String(30) not null;
  type : String(100) not null;
  value : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceOperationStatusLogs {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Change number'
  key changeCounter : String(3) not null;
  @sap.label : 'Full Name'
  author : String(80);
  @sap.label : 'Comments'
  comment : String(255);
  @sap.label : 'Status reason'
  reasonId : String(2);
  @sap.label : 'User Name'
  authorId : String(12) not null;
  @sap.label : 'Comments'
  reasonDescription : String(255);
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  createdAt : DateTime;
  @sap.label : 'Short Descript.'
  status : String(60);
  @sap.label : 'Opertative status'
  statusId : String(4);
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceLogs {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Int2'
  key counter : Integer not null;
  @sap.label : 'User'
  user : String(12);
  @sap.label : 'Full Name'
  userName : String(80);
  @sap.label : 'First Name'
  firstName : String(40);
  @sap.label : 'Last Name'
  lastName : String(40);
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  changedAt : DateTime;
  @sap.label : 'Short text'
  changeDescription : String(60);
  @sap.label : 'Old Value'
  oldValue : String(254);
  @sap.label : 'New Value'
  newValue : String(254);
  @sap.label : 'Description'
  oldValueDescription : String(30);
  @sap.label : 'Description'
  newValueDescription : String(30);
  @sap.label : 'Characteristic'
  characteristicId : String(30);
  @sap.label : '30 Characters'
  characteristic : String(30);
  @sap.label : '30 Characters'
  objectId : String(30);
  @sap.label : '30 Characters'
  objectIdBundle : String(30);
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.hardcodes {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'String'
  inputEntities : LargeString not null;
  @sap.label : 'String'
  returnJson : LargeString not null;
  to_service : Association to ZPM_SERVICES_V2_SRV.services {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceBundleServSet {
  @sap.label : 'Intern id'
  key zzidIntern : String(15) not null;
  key zzbunIdIntern : String(15) not null;
  @sap.label : 'Description'
  zzservid : String(200) not null;
  @sap.label : 'Deletion block'
  zzmarkdel : Boolean not null;
  zzbundleDesc : String(250) not null;
  @sap.label : 'Class'
  zzclass : String(18) not null;
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  createDat : DateTime;
  @sap.label : 'User'
  createdBy : String(12) not null;
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  modifieDat : DateTime;
  @sap.label : 'User'
  modifiedBy : String(12) not null;
  @sap.label : 'User'
  deletedBy : String(12) not null;
  @odata.Type : 'Edm.DateTime'
  @sap.label : 'Time Stamp'
  deletedAt : DateTime not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.realEstateContracts {
  @sap.label : 'BusinessPartner'
  key customerId : String(10) not null;
  @sap.label : 'Company Code'
  key sellerId : String(4) not null;
  @sap.label : 'Contract number'
  key contractId : String(70) not null;
  @sap.label : 'Contract Name'
  contractDescription : String(80) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.servicesView {
  @sap.label : 'Id request'
  key requestId : String(25) not null;
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Functional Loc.'
  key locationId : String(40) not null;
  @sap.label : 'Compliance Check'
  zcompliance : Boolean;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Date'
  lastReadyInvoiceDate : Timestamp;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.label : 'Date'
  stopInvoiceDate : Timestamp;
  startDate : String(8);
  endDate : String(8);
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  contractEndDate : Timestamp;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  createdOn : Timestamp;
  @sap.label : 'Description'
  serviceName : String(200);
  @sap.label : 'Legacy for service'
  legacyId : String(20);
  @sap.label : 'Service Catalog Elem'
  catalogId : String(18);
  @sap.label : 'Description'
  catalogName : String(40);
  @sap.label : 'Class'
  catalogClass : String(18);
  @sap.label : 'Keyword'
  catalogClassDescription : String(40);
  @sap.label : 'Class'
  instanceClass : String(18);
  @sap.label : 'Keyword'
  instanceClassDescription : String(40);
  @sap.label : 'Company Code'
  companyCode : String(4);
  @sap.label : 'Company Name'
  companyName : String(25);
  @sap.label : 'BusinessPartner'
  customerId : String(10);
  customerName : String(40);
  @sap.label : 'Business Line'
  businessLine : String(10);
  @sap.label : 'Opportunity'
  opportunity : String(100);
  @sap.label : 'Agreement'
  agreement : String(20);
  @sap.label : 'Ope. contract'
  opeContract : String(64);
  @sap.label : 'Operative Contract'
  operativeContract : String(30);
  @sap.label : 'Contract number'
  contractNumber : String(70);
  @sap.label : 'Creation time'
  modifiedAt : String(14);
  @sap.label : 'Opertative status'
  operativeStatus : String(4);
  @sap.label : 'Short Descript.'
  operativeStatusDesc : String(60);
  @sap.label : 'Invoincing status'
  invoiceStatus : String(25);
  @sap.label : 'Invoicing Status Des'
  invoiceStatusDescription : String(80);
  @sap.label : 'Description'
  locationName : String(40);
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.multiAttributes {
  @sap.label : 'Number'
  key cont : Integer not null;
  @sap.label : 'String'
  serviceIdList : LargeString not null;
  to_ServiceAttributes : Association to many ZPM_SERVICES_V2_SRV.serviceAttributes {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceTypes {
  @sap.label : 'Class'
  key instanceClass : String(18) not null;
  @sap.label : 'Keyword'
  instanceClassDecription : String(40);
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.companies {
  @sap.label : 'Company Code'
  key id : String(4) not null;
  @sap.label : 'Company Name'
  name : String(25) not null;
  @sap.label : 'Country'
  country : String(3) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.availableEquipmentsVh {
  @sap.label : 'Equipment'
  key equipmentId : String(18) not null;
  @sap.label : 'Description'
  equipmentDescription : String(40) not null;
  @sap.label : 'Description'
  locationDescription : String(40) not null;
  @sap.label : 'Functional loc.'
  locationId : String(40) not null;
  @sap.label : 'Status'
  statusId : String(5) not null;
  @sap.label : 'Description'
  statusDescription : String(20) not null;
  @sap.label : 'Contact Person'
  ownerId : String(10) not null;
  @sap.label : 'Name 1'
  ownerName : String(30) not null;
  @sap.label : 'Material'
  product : String(18) not null;
  @sap.label : 'Description'
  productName : String(40) not null;
  @sap.label : 'Class'
  productClass : String(18) not null;
  @sap.label : 'Keyword'
  productClassDescription : String(40) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.productClasses {
  @sap.label : 'Class'
  key productClassId : String(18) not null;
  @sap.label : 'Keyword'
  productClassDescription : String(40) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.equipmentStatuses {
  @sap.label : 'Status'
  key equipmentStatusId : String(5) not null;
  @sap.label : 'Description'
  equipmentStatusDescription : String(20) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.userProfiles {
  @sap.label : 'User'
  key userId : String(12) not null;
  @sap.label : 'Single-Character Flag'
  decimalSeparator : String(1) not null;
  @sap.label : 'Single-Character Flag'
  groupSeparator : String(1) not null;
  @sap.label : 'Short text'
  dateFormat : String(60) not null;
  @sap.label : 'Short text'
  timeFormat : String(60) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.meters {
  @sap.label : 'Functional loc.'
  key locationId : String(40) not null;
  @sap.label : 'Equipment'
  key meterId : String(18) not null;
  @sap.label : 'Description'
  meterDescription : String(40) not null;
  @sap.label : 'Intern id'
  serviceId : String(15) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.equipmentFormFactors {
  @sap.label : 'Intern id'
  key serviceId : String(15) not null;
  @sap.label : 'Equipment'
  key equipmentId : String(18) not null;
  @sap.label : 'Available Surface(m2)'
  availableSurface : String(10) not null;
  @sap.label : 'Description'
  equipmentDescription : String(40) not null;
  @sap.label : 'Weight(Kg)'
  weight : String(5) not null;
  @sap.label : 'Available Weight(Kg)'
  availableWeight : String(5) not null;
  @sap.label : 'Available Windload(N)'
  availableWindload : String(5) not null;
  @sap.label : 'Surface(m2)'
  surface : String(10) not null;
  @sap.label : 'flag to check whether form factor equipment'
  isformfactor : String(1) not null;
  @sap.label : 'Windload(N)'
  windload : String(5) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceCatalogs {
  @sap.label : 'Service Catalog Elem'
  key catalogId : String(18) not null;
  to_CatalogAttributes : Association to many ZPM_SERVICES_V2_SRV.catalogAttributes {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.failurePropagationTypes {
  key failurePropagationTypeId : String(2) not null;
  failurePropagationTypeDesc : String(60);
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceToServiceRelations {
  @sap.hierarchy.node.for : 'nodeId'
  @sap.label : 'Intern id'
  key nodeId : String(15) not null;
  @sap.hierarchy.parent.node.for : 'nodeId'
  @sap.label : 'Intern id'
  key parentId : String(15) not null;
  @odata.Type : 'Edm.Byte'
  @sap.hierarchy.level.for : 'nodeId'
  @sap.label : 'Int.'
  nodeLevel : Integer not null;
  @sap.hierarchy.drill.state.for : 'nodeId'
  @sap.label : 'Drill State'
  drillState : String(8) not null;
  @sap.label : 'Description'
  serviceName : String(200);
  @sap.label : 'Description'
  parentServiceName : String(200);
  @sap.label : 'RelType'
  relationTypeId : String(2);
  @sap.label : 'RelTypeDes'
  relationTypeDescription : String(20);
  @sap.label : 'FailureProp'
  failurePropagationTypeId : String(2);
  @sap.label : 'FailPropDesc'
  failurePropagationTypeDesc : String(20);
  @sap.label : 'Deletion Flag'
  isDeleted : Boolean not null;
  @sap.label : 'Intern id'
  rootServiceId : String(15) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.externalProjects {
  @sap.label : 'Id request'
  key idRequest : String(25) not null;
  key serviceId : String(30) not null;
  appType : String(3) not null;
  externalSystem : String(255) not null;
  url : String(255) not null;
  @sap.label : 'Delete indicator'
  isDeleted : Boolean not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.serviceRelationTypes {
  @sap.label : 'RelType'
  key relationTypeId : String(2) not null;
  @sap.label : 'RelTypeDes'
  relationTypeDescription : String(20) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZPM_SERVICES_V2_SRV.tarificationTools {
  key serviceId : String(15) not null;
  @sap.label : 'Functional loc.'
  key siteId : String(30) not null;
  key commercialElementId : String(36) not null;
  key priceBookEntry : String(36) not null;
  commercialElementDescription : String(500) not null;
  alias : String(500) not null;
  priceBookName : String(255) not null;
  priceBookCode : String(15) not null;
  commercialElementCode : String(15) not null;
};

@cds.external : true
type ZPM_SERVICES_V2_SRV.terminationReason {
  @sap.label : 'Status reason'
  ![key] : String(2);
  @sap.label : 'Comments'
  description : String(255);
};

@cds.external : true
type ZPM_SERVICES_V2_SRV.nextOpStatus {
  @sap.label : 'Planning plant'
  plant : String(4);
  @sap.label : 'Status ID'
  fromStatusId : String(4);
  @sap.label : 'Short Descript.'
  fromStatusDescription : String(60);
  @sap.label : 'Status ID'
  toStatusId : String(4);
  @sap.label : 'Short Descript.'
  toStatusDescription : String(60);
  @sap.label : 'TRUE'
  isInitialStatus : Boolean;
  @sap.label : 'TRUE'
  isAutoTransitionActive : Boolean;
};

@cds.external : true
type ZPM_SERVICES_V2_SRV.boolean {
  @sap.label : 'TRUE'
  boole : Boolean;
};

@cds.external : true
type ZPM_SERVICES_V2_SRV.serviceUpdateMessage {
  @sap.label : 'Intern id'
  ServiceId : String(15);
  @sap.label : 'Boolean Variable (X=true, -=false, space=unknown)'
  UpdateFlag : Boolean;
  @sap.label : 'STR_LIGHT'
  Message : LargeString;
};

@cds.external : true
function ZPM_SERVICES_V2_SRV.getNextOpStatuses() returns many ZPM_SERVICES_V2_SRV.nextOpStatus;

@cds.external : true
function ZPM_SERVICES_V2_SRV.setOpStatus(
  serviceId : String(15),
  opStatusId : String(4),
  comment : String(255),
  reasonCode : String(2)
) returns ZPM_SERVICES_V2_SRV.boolean;

@cds.external : true
function ZPM_SERVICES_V2_SRV.getTerminationReasons() returns many ZPM_SERVICES_V2_SRV.terminationReason;

@cds.external : true
function ZPM_SERVICES_V2_SRV.getProductClassForServiceType(
  @sap.label : 'Class'
  serviceType : String(18)
) returns many ZPM_SERVICES_V2_SRV.productClasses;

@cds.external : true
action ZPM_SERVICES_V2_SRV.onPowerRechargeMethodChange(
  @sap.label : 'PRM'
  powerRechargeMethod : Decimal(1, 0),
  requestId : String(25)
) returns many ZPM_SERVICES_V2_SRV.serviceUpdateMessage;

