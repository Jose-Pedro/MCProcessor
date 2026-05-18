const fs = require('fs');
const path = require('path');
const hana = require('@sap/hana-client');

const SCHEMA_FILE = path.resolve(__dirname, '..', 'schema-hana.utf8.sql');
const sql = fs.readFileSync(SCHEMA_FILE, 'utf8');

// Extract names from CREATE VIEW / CREATE TABLE statements (unquoted form CDS emits).
function extractNames(re) {
  const out = [];
  let m;
  const r = new RegExp(re, 'gi');
  while ((m = r.exec(sql)) !== null) out.push(m[1].toUpperCase());
  return out;
}
const expectedViews = extractNames('CREATE\\s+VIEW\\s+([A-Za-z0-9_]+)');
const expectedTables = extractNames('CREATE\\s+TABLE\\s+([A-Za-z0-9_]+)');

const c = hana.createConnection();
c.connect({ host: 'localhost', port: 39041, uid: 'INTPROJ', pwd: 'IntprojPwd2026', databaseName: 'HXE' }, (e) => {
  if (e) { console.log('CONN ERR:', e.message); process.exit(1); }
  c.exec(`SELECT VIEW_NAME FROM SYS.VIEWS WHERE SCHEMA_NAME='INTPROJ'`, (e2, rows) => {
    if (e2) { console.log('Q1 ERR:', e2.message); process.exit(1); }
    const haveViews = new Set(rows.map(r => r.VIEW_NAME));
    c.exec(`SELECT TABLE_NAME FROM SYS.TABLES WHERE SCHEMA_NAME='INTPROJ'`, (e3, rows3) => {
      if (e3) { console.log('Q2 ERR:', e3.message); process.exit(1); }
      const haveTables = new Set(rows3.map(r => r.TABLE_NAME));
      const missingViews = expectedViews.filter(v => !haveViews.has(v));
      const missingTables = expectedTables.filter(t => !haveTables.has(t));
      console.log(`Expected views: ${expectedViews.length} | present: ${haveViews.size} | missing: ${missingViews.length}`);
      console.log(`Expected tables: ${expectedTables.length} | present (any): ${haveTables.size} | missing: ${missingTables.length}`);
      console.log('--- MISSING VIEWS ---');
      missingViews.forEach(v => console.log('  ' + v));
      console.log('--- MISSING TABLES ---');
      missingTables.forEach(t => console.log('  ' + t));
      c.disconnect();
    });
  });
});
