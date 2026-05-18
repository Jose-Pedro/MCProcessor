/* checksum : 55ed9a64e07ed714f30b02a87c69a4d1 */
@cds.external : true
@m.IsDefaultEntityContainer : 'true'
@sap.supported.formats : 'atom json xlsx'
service ZTIS_ODATA_SERVICES_SRV {};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.customerSet {
  @sap.unicode : 'false'
  @sap.label : 'Field length 10'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key CustomerId : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Outdoor'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Outdoor : Decimal(15, 4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Single-Character Indicator'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Vip : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Indoor'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Indoor : Decimal(15, 4) not null;
  @sap.unicode : 'false'
  @sap.label : 'c'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NameCustomer : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Aerial'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Aerial : Decimal(15, 4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Field length 10'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NumEquipments : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Client location code.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  IdAlias : String(80) not null;
  @sap.unicode : 'false'
  @sap.label : 'Client localization name'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  AliasName : String(80) not null;
  @sap.unicode : 'false'
  @sap.label : 'Client localization name'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Partnzone : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.customer_equipmentSet {
  @sap.unicode : 'false'
  @sap.label : '30 caracteres'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Description'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Classtxt : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Field length 10'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  CustomerId : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  IdEquipo : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Description'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Statustxt : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'c'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  DescriptionEquipment : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Char20'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  TypeEquipment : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Char20'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  TypeEquipmentTxt : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'c'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  CustomerName : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Status'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Status : String(5) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.access_processSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'TDLINE'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Tdline : LargeString not null;
  @sap.unicode : 'false'
  @sap.label : 'Access type description'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaccestypetxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'ZZRESCENTTXT'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzrescenttxt : LargeString not null;
  @sap.unicode : 'false'
  @sap.label : 'Center restrictions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzrescent : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'ZZCONDACCTXT'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcondacctxt : LargeString not null;
  @sap.unicode : 'false'
  @sap.label : 'Access type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaccestype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Access conditions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcondaccess : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Staff presence'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzpresencia : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Accreditation necess'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzacreditacion : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Overnight'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzpernocta : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzprestxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Locken?'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlocken : Boolean not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.protected_areasSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Protec. area name'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NameArea : String(100) not null;
  @sap.unicode : 'false'
  @sap.label : 'Protected area desc.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  DescriptionArea : String(80) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtGeographicalInfoSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Latitude Coordinate'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlatitud : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Longitude Coordinate'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlongitud : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Longitude directio'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzdirlon : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Latitude Dir.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzdirlat : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Northing Coordinates'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zznorthing : Decimal(13, 8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Easting Coordinates'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzeasting : Decimal(13, 8) not null;
  @sap.unicode : 'false'
  @sap.label : 'UTM – X'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzutmx : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'UTM – Y'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzutmy : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Coordinate Type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzutmhuso : String(2) not null;
  @sap.unicode : 'false'
  @sap.label : 'Dimension'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcota : Decimal(15, 2) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtAddressInfoSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Name'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Landx : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzzonaopertxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Street'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Street : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Description'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzregiontxt : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzunidopertxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'City Identifier'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  City1 : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Description'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcomtxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Postal Code'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  PostCode1 : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Region'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Region : String(3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Auto.community'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcomunidad : String(3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Country'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Country : String(3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Operative Area'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzzonaoper : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Operative Unit'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzunidoper : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'House Number'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  House_num1 : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Floor in building'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Floor : String(10) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtGeneralInfoSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzinfotxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Site Primary leg.cod'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzinfo : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzsiteusetxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Site Use'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzsiteuse : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zztitularidadtxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Site type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzsitetype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Inter. ID'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Aoid : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzmunatxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzoperorigintxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Mangng company'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zztitularidad : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Equipment location'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzequipament : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Short descript.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Doorplt : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : 'Building type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzbuildingtype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Site Second.leg.cod.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzmuna : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Infrastr. orig.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzoperorigin : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Roof height'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaltura : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Access type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaccestype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Access type description'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaccestypetxt : String(60) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtClassifInfoSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcomercialtxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzopertypetxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcoubtypetxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Marketing class'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzopertype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcontypetxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Co-location type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcoubtype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Marketable'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcomercial : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Interconn. Type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzconnecttype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Ran Sharing'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzrshar : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Ran Sharing Text'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzrshartxt : String(50) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtLegalInfoSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzjurstattxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlandcontrtxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlegalownertxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Contract status'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzjurstat : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzgenstattxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Land contract'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlandcontract : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzoperadorestxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Car.8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzfealta : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzproyecttxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Status'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzgenstat : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Infr. supplier'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzoperadores : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Car.8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Validfrom : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Land type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzurbtype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Returned'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzdevuelto : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Project'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzproyect : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Car.8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Validto : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Legal owner'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlegalowner : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Car.8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzfedevolucion : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Car.8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzfebaja : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Single-Character Indicator'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzgestthird : String(1) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtContractSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'RE Key'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Intreno : String(13) not null;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.unicode : 'false'
  @sap.label : 'Contract Start'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  StartDate : Timestamp not null;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.unicode : 'false'
  @sap.label : '1st Contr. End'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FirstEndDate : Timestamp not null;
  @sap.unicode : 'false'
  @sap.label : 'Contract Type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ClassContract : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Contract'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Recnnr : String(13) not null;
  @sap.unicode : 'false'
  @sap.label : 'Name 1'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NameOrg1 : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'char8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Recnendabs : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'X Flag'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Active : Boolean not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtConditionSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'GUID'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Condguid : LargeBinary not null;
  @sap.unicode : 'false'
  @sap.label : 'RE Key'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Intreno : String(13) not null;
  @sap.unicode : 'false'
  @sap.label : 'Condition Type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Condtype : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Cond. Type Name'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Xcondtypel : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Ext.Cond.Purp.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Condpurposeext : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Condition Purp.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Xmcondpurposeext : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Frequency'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Frequency : String(3) not null;
  @sap.unicode : 'false'
  @sap.unit : 'Condcurr'
  @sap.label : 'Per Year'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Condvalueyear : Decimal(16, 3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Currency'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  @sap.semantics : 'currency-code'
  Condcurr : String(5) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtRestrictionSet {
  @sap.unicode : 'false'
  @sap.label : 'ID Intern'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Idintern : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  key Objectid : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Familytxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Restriction Info'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Restrictioninformation : String(500) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Affectedtxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'FAMILY'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Family : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Restypetxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'AFFECTED'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Affected : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Respontxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Responntxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'RESTRICTIONTYPE'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Restrictiontype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Alerttxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'RESTRICTIONTYPEDESCRIPTION'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Restrictiontypedescription : String(500) not null;
  @sap.unicode : 'false'
  @sap.label : 'X Flag'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  ActualRestr : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'RESPONSIBLE'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Responsible : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'RESPONSIBLENAME'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Responsiblename : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'ALERT'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Alert : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'STARTDATE'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Startdate : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'ENDATE'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Endate : String(8) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtAliasSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Client loc. code'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key IdAlias : String(80) not null;
  @sap.unicode : 'false'
  @sap.label : 'Cl. localiz. name'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  AliasName : String(80) not null;
  @sap.unicode : 'false'
  @sap.label : 'Name/address'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  PartnerName : String(80) not null;
  @sap.unicode : 'false'
  @sap.label : 'Client service code'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zaliasserv : String(120) not null;
  @sap.unicode : 'false'
  @sap.label : 'Other'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zaliasother : String(120) not null;
  @sap.unicode : 'false'
  @sap.label : 'Client area'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Partnzone : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.pageable : 'false'
@sap.addressable : 'false'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.attributesSet {
  key class : String(18) not null;
  key type : LargeString not null;
  key characteristic : String(30) not null;
  key counter : Integer not null;
  location : String(30) not null;
  material : String(40) not null;
  valueFrom : String(70) not null;
  valueTo : String(70) not null;
  equipmentId : String(18) not null;
  to_Characteristic : Association to ZTIS_ODATA_SERVICES_SRV.characteristics {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.attributes {
  key class : String(18) not null;
  key type : LargeString not null;
  key characteristic : String(30) not null;
  key counter : Integer not null;
  location : String(30) not null;
  material : String(40) not null;
  valueFrom : String(70) not null;
  valueTo : String(70) not null;
  equipmentId : String(18) not null;
  to_Characteristic : Association to ZTIS_ODATA_SERVICES_SRV.characteristics {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.virtualLinkTypeSet {
  @sap.unicode : 'false'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key id : String(8) not null;
  @sap.unicode : 'false'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  description : String(40) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.tec_objectSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Instante de creación'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  MODIFTIMESTAMP : String(14) not null;
  @sap.unicode : 'false'
  @sap.label : 'Validar IP'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ValidarIp : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'char8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Activdate : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Nº inventario'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Invnr : String(25) not null;
  @sap.unicode : 'false'
  @sap.label : 'Texto'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Logcomment : String(255) not null;
  @sap.unicode : 'false'
  @sap.label : 'audit result'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaudit : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Car.8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzauditdate : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'App'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzapp : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Código postal'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  AdPstcd1 : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Workflow'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzwf : String(25) not null;
  @sap.unicode : 'false'
  @sap.label : 'Ident.OA'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Aoid : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Phase'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzphase : String(100) not null;
  @sap.unicode : 'false'
  @sap.label : 'Work center'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Arbpl : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Short Text'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Arbpltxt : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Keyword'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Classtxt : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Company Code'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Company : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Comentario'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Consignation : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'char8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Deactivdate : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Denominación'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Description : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Campo de texto, longitud 10'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Dvorbes : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Obj. type text'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Eartx : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Tp.objeto'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Eqart : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Tipo de equipo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Eqtyp : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  EquiCopied : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'EquipCatDesc.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Etytx : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Piso'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Floor : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Nº (edificio)'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  HouseNum : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Clase'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Klasse1 : String(18) not null;
  @sap.unicode : 'false'
  @sap.label : 'País'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Land1 : String(3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Serial Number'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Manserno : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Start Up Date'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Startfrom : String(8);
  @sap.unicode : 'false'
  @sap.label : 'Manufacturer'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Manfacture : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Model number'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Manmodel : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Comentario'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Owner : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Description'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Parentdescription : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : '30 caracteres'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  ParentObjId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Partner'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Partner : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Changed on'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ReadChdat : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Changed by'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ReadChnam : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Created on'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ReadCrdat : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Created by'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ReadCrnam : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Región'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Region : String(3) not null;
  @sap.unicode : 'false'
  @sap.label : 'REmoved'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Removed : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Ámbito no definido , posiblemente para niveles patch'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Searchtype : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Not More Closely Defined Area, Possibly Used for Patchlevels'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Status : String(5) not null;
  @sap.unicode : 'false'
  @sap.label : 'Description'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Statustxt : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Calle'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Street : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Size/dimens.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Surface : String(18) not null;
  @sap.unicode : 'false'
  @sap.label : 'Ce.emplazam.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Swerk : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'TYPESUPPORT'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Typesupport : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Typesupportxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Campo de texto, longitud 10'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ValBusqueda : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'char8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Validfrom : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'char8'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Validto : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Denom.obj.arq.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Xao : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Tipo de acceso'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaccestype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaccestypetxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Nombre localización'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Zzalias : String(80) not null;
  @sap.unicode : 'false'
  @sap.label : 'Roof height'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzaltura : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzbuidtyptxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Building type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzbuildingtype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Marketable'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcomercial : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Dimension'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcota : Decimal(15, 2) not null;
  @sap.unicode : 'false'
  @sap.label : 'Coordenadas Easting'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzeasting : Decimal(13, 8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Equipment location'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzequipament : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzequipamenttxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Id ciudad'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ZzidCity : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Site Primary leg.cod'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzinfo : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Coordenadas latitud'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlatitude : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Coordenadas Longitud'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzlongitude : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Site Second.leg.cod.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzmuna : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Coord. Northing'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zznorthing : Decimal(13, 8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Telecom infrastructure ownership'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzownership : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Telecom infrastructure ownership'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzownershiptxt : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Site en riesgo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzriesgo : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Site type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzsitetype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzsitetypetxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Unite urbaine'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzurb : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Unite urbaine type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzurbt : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Unite urbaine type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ZzurbtTxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Unite urbaine'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ZzurbTxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Land type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzurbtype : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descriptions'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzurbtypetxt : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Coordinate Type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzutmhuso : String(2) not null;
  @sap.unicode : 'false'
  @sap.label : 'UTM – X'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzutmx : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'UTM – Y'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzutmy : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descripción restricc'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzxrescent : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Código de Arbol'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Treeid : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Código de Nodo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Nodeid : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descripción Nodo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Nodedesc : String(120) not null;
  @sap.unicode : 'false'
  @sap.label : 'Material'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Material : String(18) not null;
  @sap.unicode : 'false'
  @sap.label : 'Denominación'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  MaterialDescription : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Locations Type'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  TypeLoc : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'NºMaterial ant.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  PartNumber : String(18) not null;
  customerSet : Association to many ZTIS_ODATA_SERVICES_SRV.customerSet {  };
  access_processSet : Association to many ZTIS_ODATA_SERVICES_SRV.access_processSet {  };
  relevant_indSet : Association to many ZTIS_ODATA_SERVICES_SRV.relevant_indSet {  };
  TtAddressInfoSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtAddressInfoSet {  };
  TtGeneralInfoSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtGeneralInfoSet {  };
  TtClassifInfoSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtClassifInfoSet {  };
  TtLegalInfoSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtLegalInfoSet {  };
  protected_areasSet : Association to many ZTIS_ODATA_SERVICES_SRV.protected_areasSet {  };
  TtContractSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtContractSet {  };
  TtConditionSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtConditionSet {  };
  TtRestrictionSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtRestrictionSet {  };
  TtAliasSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtAliasSet {  };
  Traceability : Association to many ZTIS_ODATA_SERVICES_SRV.TraceabilitySet {  };
  CtRtuSet : Association to many ZTIS_ODATA_SERVICES_SRV.CtRtuSet {  };
  landlordSet : Association to many ZTIS_ODATA_SERVICES_SRV.landlordSet {  };
  customer_equipmentSet : Association to many ZTIS_ODATA_SERVICES_SRV.customer_equipmentSet {  };
  characteristics : Association to many ZTIS_ODATA_SERVICES_SRV.charactericsSet {  };
  object_id : Association to many ZTIS_ODATA_SERVICES_SRV.relevant_indSet {  };
  TtGeographicalInfoSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtGeographicalInfoSet {  };
  notesSet : Association to many ZTIS_ODATA_SERVICES_SRV.notesSet {  };
  TtAttachmentSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtAttachmentSet {  };
  occupation_siteSet : Association to many ZTIS_ODATA_SERVICES_SRV.occupation_siteSet {  };
  Provision : Association to many ZTIS_ODATA_SERVICES_SRV.ProvisionSet {  };
  TtRequestsSet : Association to many ZTIS_ODATA_SERVICES_SRV.TtRequestsSet {  };
  attributesSet : Association to many ZTIS_ODATA_SERVICES_SRV.attributesSet {  };
  virtualLinksSet : Association to many ZTIS_ODATA_SERVICES_SRV.virtualLinksSet {  };
  CtMeasuredServiceSet : Association to many ZTIS_ODATA_SERVICES_SRV.CtMeasuredServiceSet {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.landlordSet {
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.unicode : 'false'
  @sap.label : 'Prior notice'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key LandlordId : Timestamp not null;
  @sap.unicode : 'false'
  @sap.label : 'Real Estate Key'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ContractId : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Search term 1'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  LandlordName : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'E-Mail Address'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  LandlordEmail : String(241) not null;
  @sap.unicode : 'false'
  @sap.label : 'Telephone'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  LandlordPhone : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.charactericsSet {
  key class : String(18) not null;
  key type : String(100) not null;
  key characteristic : String(30) not null;
  description : String(30) not null;
  @sap.label : 'Indicador'
  hasListOfValues : Boolean not null;
  @sap.label : 'Indicador'
  hasAdditionalValues : Boolean not null;
  dataType : String(20) not null;
  valueAssignment : String(20) not null;
  @sap.label : 'Indicador'
  isRequired : Boolean not null;
  numberOfCharacters : String(2) not null;
  @sap.label : 'Indicador'
  caseSensitive : Boolean not null;
  numberOfDecimals : String(2) not null;
  currency : String(5) not null;
  @sap.label : 'Indicador'
  isIntervalValuesAllowed : Boolean not null;
  @sap.label : 'Indicador'
  isNegativeValuesAllowed : Boolean not null;
  unitOfMeasure : String(6) not null;
  referenceTable : String(30) not null;
  counter : Integer not null;
  parentClass : String(18) not null;
  to_AllowedValues : Association to many ZTIS_ODATA_SERVICES_SRV.characteristicsAllowedValues {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.characteristics {
  key class : String(18) not null;
  key type : String(100) not null;
  key characteristic : String(30) not null;
  description : String(30) not null;
  @sap.label : 'Indicador'
  hasListOfValues : Boolean not null;
  @sap.label : 'Indicador'
  hasAdditionalValues : Boolean not null;
  dataType : String(20) not null;
  valueAssignment : String(20) not null;
  @sap.label : 'Indicador'
  isRequired : Boolean not null;
  numberOfCharacters : String(2) not null;
  @sap.label : 'Indicador'
  caseSensitive : Boolean not null;
  numberOfDecimals : String(2) not null;
  currency : String(5) not null;
  @sap.label : 'Indicador'
  isIntervalValuesAllowed : Boolean not null;
  @sap.label : 'Indicador'
  isNegativeValuesAllowed : Boolean not null;
  unitOfMeasure : String(6) not null;
  referenceTable : String(30) not null;
  counter : Integer not null;
  parentClass : String(18) not null;
  to_AllowedValues : Association to many ZTIS_ODATA_SERVICES_SRV.characteristicsAllowedValues {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.relevant_indSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Explanation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzservidtxt : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Insonorización'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzinson : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Servid. Aeronáutica'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzservid : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Conexión Saneamiento'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzsaneam : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Conexión Agua potabl'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzagua : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'agua contra incendio'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzincendio : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Emisión Electromagné'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzememis : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Vallado'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzvallado : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Iluminación exterior'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzilum : Boolean not null;
  @sap.unicode : 'false'
  @sap.label : 'Carácter 1'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzinsonx : String(1) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtAoidGeolocSet {
  @sap.unicode : 'false'
  @sap.label : 'Ident.OA'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Aoid : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Arch. Object'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Intreno : String(13) not null;
  @sap.unicode : 'false'
  @sap.label : 'ZZEASTING'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Zzeasting : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : 'ZZCOTA'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzcota : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : 'ZZNORTHING'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Zznorthing : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : 'ZZAREA'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Zzarea : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : 'Denom.obj.arq.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Xao : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Site Use'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  Zzrsiteuse : String(10);
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.notesSet {
  key id : String(40) not null;
  key objectType : String(10) not null;
  key title : String(50) not null;
  key version : Integer not null;
  category : String(50) not null;
  note : String(255) not null;
  @sap.label : 'Indicador'
  markedForDeletion : Boolean not null;
  createdBy : String(80) not null;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  @sap.label : 'Cronomarcador'
  createdOn : Timestamp;
  status : String(30) not null;
  categoryDescription : String(50) not null;
  to_Location : Association to ZTIS_ODATA_SERVICES_SRV.locations {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.notes {
  key id : String(40) not null;
  key objectType : String(10) not null;
  key title : String(50) not null;
  key version : Integer not null;
  category : String(50) not null;
  note : String(255) not null;
  @sap.label : 'Indicador'
  markedForDeletion : Boolean not null;
  createdBy : String(80) not null;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  @sap.label : 'Cronomarcador'
  createdOn : Timestamp;
  status : String(30) not null;
  categoryDescription : String(50) not null;
  to_Location : Association to ZTIS_ODATA_SERVICES_SRV.locations {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtAttachmentSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Objectid : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Binary String'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  XstringDoc : LargeBinary not null;
  @sap.unicode : 'false'
  @sap.label : 'Customer'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Operator : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Not More Closely Defined Area, Possibly Used for Patchlevels'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Extension : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Character Field Length = 10'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Title : String(10) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.occupation_siteSet {
  @sap.unicode : 'false'
  @sap.label : '30 Characters'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Char20'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Class : String(18) not null;
  @sap.unicode : 'false'
  @sap.label : 'Description of Technical Object'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ClassTxt : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Field length 10'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Countequip : String(10) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TraceabilitySet {
  @sap.unicode : 'false'
  @sap.label : '30 caracteres'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Usuario'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  USER : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Nombre'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FIRSTNAME : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Apellido'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  LASTNAME : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'Fecha de inicio'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  DATE : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Hora última modifica'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  TIME : String(6) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descripción breve'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  SHORT_DESC : String(60) not null;
  @sap.unicode : 'false'
  @sap.label : 'Valor anterior'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  OLD_VALUE : String(254) not null;
  @sap.unicode : 'false'
  @sap.label : 'Valor nuevo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NEW_VALUE : String(254) not null;
  @sap.unicode : 'false'
  @sap.label : 'Denominación'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  OLD_VALUE_DESC : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Denominación'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NEW_VALUE_DESC : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Característica'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  CHAR_CODE : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : '30 caracteres'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  CHAR_DESC : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.pageable : 'false'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.ProvisionSet {
  @sap.unicode : 'false'
  @sap.label : 'App'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Zzapp : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : '30 caracteres'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Workflow'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzwf : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Phase'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Zzphase : String(100) not null;
  @sap.unicode : 'false'
  @sap.label : 'Objeto doc.modif.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Objectclas : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : 'Nº documento'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Changenr : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Usuario'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Username : String(12) not null;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.unicode : 'false'
  @sap.label : 'Fecha'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Udate : Timestamp not null;
  @sap.unicode : 'false'
  @sap.label : 'Hora'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Utime : Time not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.CtRtuSet {
  @sap.unicode : 'false'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key ObjectId : String(30) not null;
  @sap.unicode : 'false'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  RtuId : String(5) not null;
  @sap.unicode : 'false'
  @sap.label : 'NMS ID'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NmsStr : String(40) not null;
  @sap.unicode : 'false'
  @sap.label : 'NMS Desc'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NmsId : String(2) not null;
  @sap.unicode : 'false'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  NmsDesc : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Protocol'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProtocolId : String(2) not null;
  @sap.unicode : 'false'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProtocolDesc : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.TtRequestsSet {
  @sap.unicode : 'false'
  @sap.label : 'Equipo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Idequipment : String(18) not null;
  @sap.unicode : 'false'
  @sap.label : 'Hana Deleta'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  IndicadorR3 : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'ID request'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Idrequest : String(25) not null;
  @sap.unicode : 'false'
  @sap.label : 'Sociedad'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Bukrs : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Fecha de registro'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FechaReg : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Hora de Registro'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  HoraReg : String(6) not null;
  @sap.unicode : 'false'
  @sap.label : 'Usuario Regi'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  UsuarioReg : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Indicador de borrado'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  IndicadorBor : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Fecha de borrado'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FechaBor : String(8) not null;
  @sap.unicode : 'false'
  @sap.label : 'Hora de Borrado'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  HoraBor : String(6) not null;
  @sap.unicode : 'false'
  @sap.label : 'Usuario Bor.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  UsuarioBor : String(12) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.pageable : 'false'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.CtReturnSet {
  @sap.unicode : 'false'
  @sap.label : 'Tipo de mensaje'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Type : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Clase de mensajes'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Id : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Nº mensaje'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Number : String(3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Texto mensaje'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Message : String(220) not null;
  @sap.unicode : 'false'
  @sap.label : 'Número log'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  LogNo : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Nº mensaje'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  LogMsgNo : String(6) not null;
  @sap.unicode : 'false'
  @sap.label : 'Variable de mensaje'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  MessageV1 : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Variable de mensaje'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  MessageV2 : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Variable de mensaje'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  MessageV3 : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Variable de mensaje'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  MessageV4 : String(50) not null;
  @sap.unicode : 'false'
  @sap.label : 'Parámetro'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Parameter : String(32) not null;
  @sap.unicode : 'false'
  @sap.label : 'Línea parámetro'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Row : Integer not null;
  @sap.unicode : 'false'
  @sap.label : 'Nombre campo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Field : String(30) not null;
  @sap.unicode : 'false'
  @sap.label : 'Sistema lógico'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  System : String(10) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.pageable : 'false'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.virtualLinksSet {
  key id : String(18) not null;
  key location : String(30) not null;
  shortText : String(40) not null;
  linkType : String(8) not null;
  linkTypeDescription : String(40) not null;
  fromLocation : String(30) not null;
  fromLocationDescription : String(40) not null;
  fromEquipment : String(18) not null;
  fromEquipmentDescription : String(40) not null;
  toLocation : String(30) not null;
  toLocationDescription : String(40) not null;
  toEquipment : String(18) not null;
  toEquipmentDescription : String(40) not null;
  direction : String(6) not null;
  @sap.label : 'Indicador'
  deletionFlag : Boolean not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.virtualLinks {
  key id : String(18) not null;
  key location : String(30) not null;
  shortText : String(40) not null;
  linkType : String(8) not null;
  linkTypeDescription : String(40) not null;
  fromLocation : String(30) not null;
  fromLocationDescription : String(40) not null;
  fromEquipment : String(18) not null;
  fromEquipmentDescription : String(40) not null;
  toLocation : String(30) not null;
  toLocationDescription : String(40) not null;
  toEquipment : String(18) not null;
  toEquipmentDescription : String(40) not null;
  direction : String(6) not null;
  @sap.label : 'Indicador'
  deletionFlag : Boolean not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.pageable : 'false'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.orderHistorySet {
  @sap.unicode : 'false'
  @sap.label : 'Doc.compras'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Ebeln : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Doc.material'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Belnr : String(10) not null;
  @sap.unicode : 'false'
  @sap.label : 'Nombre empresa'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Butxt : String(25) not null;
  @sap.unicode : 'false'
  @sap.label : 'Cl.movimiento'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Bwart : String(3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Posición'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Buzei : String(3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Posición'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Ebelp : String(5) not null;
  @sap.unicode : 'false'
  @sap.label : 'Ejercicio'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Gjahr : String(4) not null;
  @odata.Type : 'Edm.DateTime'
  @odata.Precision : 7
  @sap.unicode : 'false'
  @sap.label : 'Fecha contab.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Budat : Timestamp not null;
  @sap.unicode : 'false'
  @sap.label : 'Clase operación'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Vgabe : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Cantidad'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Menge : Decimal(13, 3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Importe ML'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Dmbtr : Decimal(14, 3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Moneda'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  @sap.semantics : 'currency-code'
  Waers : String(5) not null;
  @sap.unicode : 'false'
  @sap.label : 'Ctd.UMPP'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Bpmng : Decimal(13, 3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Importe'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Wrbtr : Decimal(14, 3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Moneda local'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  @sap.semantics : 'currency-code'
  Hswae : String(5) not null;
  @sap.unicode : 'false'
  @sap.label : 'Val.comp.EM/RF'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Areww : Decimal(14, 3) not null;
  @sap.unicode : 'false'
  @sap.label : 'Referencia'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Xblnr : String(16) not null;
  @sap.unicode : 'false'
  @sap.label : 'Tipo stocks'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Btext : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'Txt.brv.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Bewtk : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Texto expl.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Bewtl : String(20) not null;
  @sap.unicode : 'false'
  @sap.label : 'TipoHistor-ped'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Bewtp : String(1) not null;
  @sap.unicode : 'false'
  @sap.label : 'Sociedad'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Bukrs : String(4) not null;
  @sap.unicode : 'false'
  @sap.label : 'Autor'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Ernam : String(12) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.searchable : 'true'
@sap.pageable : 'false'
@sap.requires.filter : 'true'
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.CtMeasuredServiceSet {
  @sap.unicode : 'false'
  @sap.label : 'TxtError cont.'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Equipmentid : String(250) not null;
  @sap.unicode : 'false'
  @sap.label : 'Id interno'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  key Serviceid : String(15) not null;
  @sap.unicode : 'false'
  @sap.label : 'Desc. del servicio'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Serviceiddesc : String(200) not null;
  @sap.unicode : 'false'
  @sap.label : 'Código de Nodo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Nodeid : String(12) not null;
  @sap.unicode : 'false'
  @sap.label : 'Descripción Nodo'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Nodeiddesc : String(120) not null;
  @sap.unicode : 'false'
  @sap.label : 'Código de Arbol'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Treeid : String(12) not null;
  tec_object : Association to ZTIS_ODATA_SERVICES_SRV.tec_objectSet {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.maintenancePlants {
  key id : String(4) not null;
  name : String(30) not null;
  companyCode : String(4) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.locationCategories {
  key id : String(1) not null;
  name : String(50) not null;
  action : String(1) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.addresses {
  key id : String(10) not null;
  recipientName : String(40) not null;
  street : String(60) not null;
  number : String(40) not null;
  street2 : String(60) not null;
  street3 : String(40) not null;
  street4 : String(40) not null;
  street5 : String(40) not null;
  region : String(40) not null;
  postalCode : String(10) not null;
  city : String(40) not null;
  country : String(3) not null;
  timeZone : String(6) not null;
  comments : String(50) not null;
  phoneNumber : String(30) not null;
  mobilePhoneNumber : String(30) not null;
  faxNumber : String(30) not null;
  emailAddress : String(30) not null;
  to_CommunicationDetails : Association to ZTIS_ODATA_SERVICES_SRV.communicationDetails {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.communicationDetails {
  key id : String(10) not null;
  phoneNumber : String(30) not null;
  mobilePhoneNumber : String(30) not null;
  faxNumber : String(30) not null;
  emailAddress : String(241) not null;
  to_Addresses : Association to ZTIS_ODATA_SERVICES_SRV.addresses {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.files {
  key requestId : String(32) not null;
  userName : String(12) not null;
  creationDate : String(8) not null;
  type : String(20) not null;
  app : String(100) not null;
  fileName : String(50) not null;
  fileXtring : LargeBinary not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.services {
  key service : String(15) not null;
  location : String(30) not null;
  description : String(200) not null;
  creationDate : String(8) not null;
  startDate : String(8) not null;
  endDate : String(8) not null;
  customer : String(10) not null;
  customerName : String(80) not null;
  locationDescription : String(30) not null;
  contractNumer : String(70) not null;
  popEnergyId : String(15) not null;
  modificationDate : String(14) not null;
  legacyId : String(20) not null;
  contractDate : String(8) not null;
  sla : String(30) not null;
  businessPartner : String(10) not null;
  businessPartnerName : String(80) not null;
  businessLine : String(10) not null;
  serviceCatalog : String(18) not null;
  serviceCatalogName : String(40) not null;
  agreement : String(20) not null;
  operativeContract : String(64) not null;
  invoicingStatus : String(25) not null;
  opportunity : String(100) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.businessPartnersRol {
  key bpRole : String(100) not null;
  key id : String(10) not null;
  name1 : String(40) not null;
  name2 : String(40) not null;
  status : String(10) not null;
  bpRolDescription : String(25) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.classes {
  key class : String(18) not null;
  key type : String(100) not null;
  description : String(40) not null;
  level : Integer not null;
  parentClass : String(18) not null;
  drillState : String(8) not null;
  to_Characteristics : Association to many ZTIS_ODATA_SERVICES_SRV.characteristics {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.characteristicsAllowedValues {
  key class : String(18) not null;
  key type : String(100) not null;
  key characteristic : String(30) not null;
  key counter : Integer not null;
  value : String(30) not null;
  description : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.locations {
  key location : String(30) not null;
  description : String(40) not null;
  class : String(18) not null;
  category : String(1) not null;
  maintenancePlant : String(4) not null;
  company : String(4) not null;
  maintenancePlanningPlant : String(4) not null;
  plannerGroup : String(3) not null;
  status : String(10) not null;
  @sap.label : 'Indicador'
  isMarkedForDeletion : Boolean not null;
  parentLocation : String(30) not null;
  hasSite : String(3) not null;
  site : String(30) not null;
  level : Integer not null;
  drillState : String(8) not null;
  classDescription : String(40) not null;
  categoryDescription : String(50) not null;
  companyDescription : String(40) not null;
  parentDescription : String(40) not null;
  siteDescription : String(40) not null;
  maintenancePlantDescription : String(30) not null;
  maintenancePlanningPlantDescri : String(30) not null;
  plannerGroupDescription : String(18) not null;
  postCode : String(10) not null;
  landDescription : String(15) not null;
  region : String(3) not null;
  regionDescription : String(20) not null;
  land : String(2) not null;
  @sap.label : 'Calle'
  street : String(60) not null;
  @sap.label : 'Nº (edificio)'
  house_num1 : String(10) not null;
  @sap.label : 'Población'
  city1 : String(40) not null;
  to_VirtualLinks : Association to many ZTIS_ODATA_SERVICES_SRV.virtualLinks {  };
  to_Contacts : Association to many ZTIS_ODATA_SERVICES_SRV.contacts {  };
  to_Services : Association to many ZTIS_ODATA_SERVICES_SRV.services {  };
  to_Equipments : Association to many ZTIS_ODATA_SERVICES_SRV.equipment {  };
  to_Attributes : Association to many ZTIS_ODATA_SERVICES_SRV.attributes {  };
  to_Notes : Association to many ZTIS_ODATA_SERVICES_SRV.notes {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.catalog {
  key material : String(40) not null;
  class : String(18) not null;
  instanceClass : String(18) not null;
  partNumber : String(70) not null;
  type : String(100) not null;
  description : String(40) not null;
  active : String(8) not null;
  vendor : String(10) not null;
  vendorFamily : String(30) not null;
  classDescription : String(40) not null;
  vendorDescription : String(40) not null;
  vendorFamilyDescription : String(255) not null;
  instanceClassDescription : String(40) not null;
  to_Notes : Association to many ZTIS_ODATA_SERVICES_SRV.notes {  };
  to_Vendor : Association to ZTIS_ODATA_SERVICES_SRV.catalogVendors {  };
  to_Class : Association to ZTIS_ODATA_SERVICES_SRV.classes {  };
  to_Attributes : Association to many ZTIS_ODATA_SERVICES_SRV.attributes {  };
  to_Contacts : Association to many ZTIS_ODATA_SERVICES_SRV.contacts {  };
  to_VendorFamily : Association to ZTIS_ODATA_SERVICES_SRV.catalogVendorsFamilies {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.contacts {
  key id : String(10) not null;
  name1 : String(40) not null;
  name2 : String(40) not null;
  status : String(10) not null;
  location : String(30) not null;
  material : String(40) not null;
  @sap.label : 'Indicador'
  deletionFlag : Boolean not null;
  to_Address : Association to ZTIS_ODATA_SERVICES_SRV.addresses {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.catalogVendors {
  key id : String(10) not null;
  name1 : String(40) not null;
  name2 : String(40) not null;
  status : String(10) not null;
  location : String(30) not null;
  material : String(40) not null;
  @sap.label : 'Indicador'
  deletionFlag : Boolean not null;
  to_Address : Association to ZTIS_ODATA_SERVICES_SRV.addresses {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.catalogVendorsFamilies {
  key vendor : String(10) not null;
  key family : String(30) not null;
  description : String(255) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.locationTree {
  key location : String(30) not null;
  description : String(40) not null;
  class : String(18) not null;
  category : String(1) not null;
  maintenancePlant : String(4) not null;
  company : String(4) not null;
  maintenancePlanningPlant : String(4) not null;
  plannerGroup : String(3) not null;
  status : String(10) not null;
  @sap.label : 'Indicador'
  isMarkedForDeletion : Boolean not null;
  parentLocation : String(30) not null;
  hasSite : String(3) not null;
  site : String(30) not null;
  level : Integer not null;
  drillState : String(8) not null;
  postCode : String(10) not null;
  land : String(15) not null;
  region : String(20) not null;
  @sap.label : 'Calle'
  street : String(60) not null;
  @sap.label : 'Nº (edificio)'
  house_num1 : String(10) not null;
  @sap.label : 'Población'
  city1 : String(40) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.locationPredecessors {
  key location : String(30) not null;
  description : String(40) not null;
  class : String(18) not null;
  category : String(1) not null;
  maintenancePlant : String(4) not null;
  company : String(4) not null;
  maintenancePlanningPlant : String(4) not null;
  plannerGroup : String(3) not null;
  status : String(10) not null;
  @sap.label : 'Indicador'
  isMarkedForDeletion : Boolean not null;
  parentLocation : String(30) not null;
  @sap.label : 'Indicador'
  hasSite : Boolean not null;
  site : String(30) not null;
  level : Integer not null;
  drillDownState : String(8) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.countries {
  key id : String(3) not null;
  name : String(15) not null;
  to_countryRegion : Association to many ZTIS_ODATA_SERVICES_SRV.countryRegion {  };
  to_locations : Association to ZTIS_ODATA_SERVICES_SRV.locations {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.companies {
  key id : String(4) not null;
  name : String(25) not null;
  country : String(3) not null;
  to_Country : Association to ZTIS_ODATA_SERVICES_SRV.countries {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.maintenancePlanningPlants {
  key id : String(4) not null;
  name : String(30) not null;
  companyCode : String(4) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.plannerGroups {
  key id : String(3) not null;
  key maintenancePlanningPlant : String(4) not null;
  name : String(18) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.noteCategories {
  key id : String(50) not null;
  name : String(50) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.equipment {
  key EquipmentID : String(18) not null;
  DateValidFrom : String(10) not null;
  Description : String(40) not null;
  ClassID : String(18) not null;
  ClassName : String(40) not null;
  MaterialID : String(18) not null;
  MaterialDescription : String(40) not null;
  CompanyID : String(4) not null;
  CompanyName : String(40) not null;
  Status : String(30) not null;
  ObjectID : String(10) not null;
  ObjectDescritption : String(40) not null;
  LocationID : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.classDetermination {
  key class : String(18) not null;
  key type : String(100) not null;
  key material : String(18) not null;
  serviceClass : String(18) not null;
  serviceClassDescription : String(40) not null;
  equipmentClass : String(18) not null;
  equipmentClassDescription : String(40) not null;
  objectCategory : String(1) not null;
  objectCategoryDescription : String(30) not null;
  objectType : String(10) not null;
  objectTypeDescription : String(20) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.countryRegion {
  key id : String(3) not null;
  description : String(20) not null;
  countryId : String(3) not null;
  to_locations : Association to ZTIS_ODATA_SERVICES_SRV.locations {  };
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.createworkspaceSet {
  key location : String(30) not null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '1'
entity ZTIS_ODATA_SERVICES_SRV.CheckSpaceSet {
  key location : String(30) not null;
  @sap.label : 'Variable booleana (X=verdadero, -=falso, space=descon.)'
  spacecreated : Boolean not null;
};

