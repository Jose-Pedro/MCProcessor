// Generate CREATE TABLE stubs for entities marked @cds.persistence.exists
// that are required by parameterized views but not present in HANA.
//
// Usage:  node gen-stubs.js  > stubs-pviews.sql

const path = require('path');
const cds = require(path.join(process.cwd(), 'node_modules', '@sap', 'cds'));

const TARGETS = [
  // CDS-defined "external" tables that views reference
  'BLOCK','PHASE','MASTER_BLOCK','MASTER_PHASE','PROCESS',
  'WORKS','DOCUMENT_FLOWS','APPROVER_TYPES','SUBCO_TYPES',
  // SAP ECC reference tables
  'ADRC','BUT000','CVI_CUST_LINK','IFLOT','ILOA',
  'VIBDAO','VIBDBE','VIBDOBJASS','VIBDOBJREL','VIBPOBJREL','VICNCN','VZOBJECT',
  'ZPMSERVCHNGS','ZPMSERVLOC','ZPMSITESERV','ZRETOAALIAS',
  // already-stubbed (no-op if already exists, but harmless to re-emit)
  'US_USERS_IAS',
];

(async () => {
  // load model from current dir's db/ + srv/
  const csn = await cds.load(['db','srv']);
  // strip persistence annotations on TARGETS so cds.compile emits DDL
  for (const name of TARGETS) {
    const def = csn.definitions[name];
    if (!def) { console.error(`-- WARNING: ${name} not in CSN`); continue; }
    delete def['@cds.persistence.exists'];
    delete def['@cds.persistence.skip'];
    delete def['@cds.persistence.calcview'];
  }
  // compile to HANA SQL, then filter to only TARGETS
  const ddl = cds.compile.to.sql(csn, { dialect: 'hana', as: 'str' });
  const lines = (Array.isArray(ddl) ? ddl : [ddl]).join('\n').split(/;\s*\n/);
  const want = new Set(TARGETS);
  console.log("-- Auto-generated stubs for parameterized-view dependencies");
  console.log("SET SCHEMA INTPROJ;");
  for (const stmt of lines) {
    const m = stmt.match(/^\s*CREATE\s+(?:COLUMN\s+)?TABLE\s+([A-Za-z0-9_]+)/);
    if (m && want.has(m[1])) {
      // make idempotent: prefix with conditional drop is risky; instead emit
      // 'CREATE TABLE IF NOT EXISTS' (HANA does not support that, so just DROP first)
      console.log(`-- ${m[1]}`);
      console.log(`DROP TABLE ${m[1]} CASCADE;`);
      console.log(stmt.trim() + ';');
      console.log('');
    }
  }
})().catch(e => { console.error(e); process.exit(1); });
