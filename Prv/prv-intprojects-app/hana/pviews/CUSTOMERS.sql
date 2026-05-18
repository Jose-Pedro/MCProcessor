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
