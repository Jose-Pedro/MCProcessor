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
