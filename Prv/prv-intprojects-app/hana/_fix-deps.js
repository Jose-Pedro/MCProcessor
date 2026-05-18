// Fix the leftover dependency gaps so all 218 missing views can be created:
//   1. DROP empty stub tables APPROVER_TYPES, SUBCO_TYPES so the homonymous
//      views in schema-hana.utf8.sql can be created.
//   2. CREATE empty stub tables for the @cds.persistence.exists entities owned
//      by the (external) works module that aren't in our deploy:
//        - WORK_CONFIG_DOCUMENT_FLOWS
//        - WORK_CONFIG_DOCUMENT_DEFAULTS
//        - WORK_CONFIG_DOCUMENT_DEFAULTS_texts
//      Column lists derived from the corresponding hdbview definitions in
//      Prv/prv-intprojects-nodejs/gen/db/src/gen/.
const hana = require('@sap/hana-client');

// Notes on identifier casing for these stub tables:
//   The CDS-generated view bodies reference column / table names UNQUOTED,
//   which HANA uppercases at parse time. So the persisted column / table
//   names must be uppercase too.
//   - Reserved keyword `default` is created as quoted "DEFAULT" so the
//     uppercase lookup from `_0.default` resolves.
//   - Texts table is created without quotes so its name lands as
//     WORK_CONFIG_DOCUMENT_DEFAULTS_TEXTS (matching the view's lookup).
const DDL = [
  { name: 'DROP_APPROVER_TYPES', sql: `DROP TABLE APPROVER_TYPES`, ignoreIfMissing: true },
  { name: 'DROP_SUBCO_TYPES',    sql: `DROP TABLE SUBCO_TYPES`,    ignoreIfMissing: true },
  { name: 'DROP_WCDF',           sql: `DROP TABLE WORK_CONFIG_DOCUMENT_FLOWS`,    ignoreIfMissing: true },
  { name: 'DROP_WCDD',           sql: `DROP TABLE WORK_CONFIG_DOCUMENT_DEFAULTS`, ignoreIfMissing: true },
  { name: 'DROP_WCDD_TEXTS_Q',   sql: `DROP TABLE "WORK_CONFIG_DOCUMENT_DEFAULTS_texts"`, ignoreIfMissing: true },
  { name: 'DROP_WCDD_TEXTS_U',   sql: `DROP TABLE WORK_CONFIG_DOCUMENT_DEFAULTS_TEXTS`,   ignoreIfMissing: true },
  {
    name: 'WORK_CONFIG_DOCUMENT_FLOWS',
    sql: `CREATE TABLE WORK_CONFIG_DOCUMENT_FLOWS (
      ID NVARCHAR(36) NOT NULL,
      createdAt TIMESTAMP,
      createdBy NVARCHAR(255),
      modifiedAt TIMESTAMP,
      modifiedBy NVARCHAR(255),
      documentId NVARCHAR(50),
      WorkType_ID NVARCHAR(36),
      Configuration_ID NVARCHAR(36),
      PRIMARY KEY (ID)
    )`
  },
  {
    name: 'WORK_CONFIG_DOCUMENT_DEFAULTS',
    sql: `CREATE TABLE WORK_CONFIG_DOCUMENT_DEFAULTS (
      ID NVARCHAR(36) NOT NULL,
      createdAt TIMESTAMP,
      createdBy NVARCHAR(255),
      modifiedAt TIMESTAMP,
      modifiedBy NVARCHAR(255),
      name NVARCHAR(255),
      descr NVARCHAR(1000),
      documentId NVARCHAR(50),
      approverType INTEGER,
      externalType INTEGER,
      subcontractorValidationReq BOOLEAN,
      cellnexValidationReq BOOLEAN,
      customerValidationReq BOOLEAN,
      landlordValidationReq BOOLEAN,
      "DEFAULT" BOOLEAN,
      deleted BOOLEAN,
      Configuration_ID NVARCHAR(36),
      PRIMARY KEY (ID)
    )`
  },
  {
    name: 'WORK_CONFIG_DOCUMENT_DEFAULTS_TEXTS',
    sql: `CREATE TABLE WORK_CONFIG_DOCUMENT_DEFAULTS_TEXTS (
      locale NVARCHAR(14) NOT NULL,
      ID NVARCHAR(36) NOT NULL,
      name NVARCHAR(255),
      descr NVARCHAR(1000),
      PRIMARY KEY (locale, ID)
    )`
  },
];

const c = hana.createConnection();
c.connect({ host: 'localhost', port: 39041, uid: 'INTPROJ', pwd: 'IntprojPwd2026', databaseName: 'HXE' }, async (e) => {
  if (e) { console.log('CONN ERR:', e.message); process.exit(1); }
  const q = (sql) => new Promise((res, rej) => c.exec(sql, (e2, r) => e2 ? rej(e2) : res(r)));
  for (const d of DDL) {
    try {
      await q(d.sql);
      console.log(`OK  ${d.name}`);
    } catch (ex) {
      const msg = ex.message.split('\n')[0];
      if (d.ignoreIfMissing && /not found|invalid table name/i.test(msg)) {
        console.log(`SKIP ${d.name} (not present)`);
      } else if (/cannot use duplicate table name|already exists/i.test(msg)) {
        console.log(`OK  ${d.name} (already exists)`);
      } else {
        console.log(`ERR ${d.name}: ${msg}`);
      }
    }
  }
  c.disconnect();
});
