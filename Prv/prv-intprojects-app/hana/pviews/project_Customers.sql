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
