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
