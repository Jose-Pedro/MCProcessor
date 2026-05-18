const hana = require('@sap/hana-client');
const conn = hana.createConnection();
conn.connect({
  serverNode: 'localhost:39041', uid: 'INTPROJ',
  pwd: process.env.HXE_PWD || 'IntprojPwd2026',
  encrypt: false, sslValidateCertificate: false, currentSchema: 'INTPROJ'
}, async (err) => {
  if (err) { console.error(err); process.exit(1); }
  const exec = (sql) => new Promise((res, rej) => conn.exec(sql, (e, r) => e ? rej(e) : res(r)));
  try {
    console.log('# SITES table columns');
    const cols = await exec(`SELECT COLUMN_NAME, DATA_TYPE_NAME, LENGTH, IS_NULLABLE FROM TABLE_COLUMNS WHERE SCHEMA_NAME='INTPROJ' AND TABLE_NAME='SITES' ORDER BY POSITION`);
    cols.forEach(c => console.log(`  ${c.COLUMN_NAME} ${c.DATA_TYPE_NAME}(${c.LENGTH}) null=${c.IS_NULLABLE}`));

    console.log('\n# SITES_BY_AOTYPE definition');
    try {
      const v = await exec(`SELECT VIEW_NAME, DEFINITION FROM VIEWS WHERE SCHEMA_NAME='INTPROJ' AND VIEW_NAME='SITES_BY_AOTYPE'`);
      v.forEach(r => console.log(r.DEFINITION));
    } catch (e) { console.log('  ERR ' + e.message); }

    console.log('\n# SITES_BY_AOTYPE parameters');
    try {
      const p = await exec(`SELECT * FROM VIEW_PARAMETERS WHERE SCHEMA_NAME='INTPROJ' AND VIEW_NAME='SITES_BY_AOTYPE' ORDER BY POSITION`);
      console.log(JSON.stringify(p, null, 2));
    } catch (e) { console.log('  ERR ' + e.message); }

    console.log('\n# Look for any *site*-like tables with data');
    const ts = await exec(`SELECT TABLE_NAME, RECORD_COUNT FROM M_TABLES WHERE SCHEMA_NAME='INTPROJ' AND (TABLE_NAME LIKE '%SITE%' OR TABLE_NAME LIKE '%CABEZ%' OR TABLE_NAME LIKE '%OBJ%' OR TABLE_NAME LIKE 'AGORA%') AND RECORD_COUNT > 0 ORDER BY RECORD_COUNT DESC LIMIT 30`);
    ts.forEach(r => console.log(`  ${r.TABLE_NAME}: ${r.RECORD_COUNT}`));

    console.log('\n# SITES_BY_AOTYPE try with single quotes via plain call');
    try {
      const s = await exec(`SELECT TOP 3 * FROM "SITES_BY_AOTYPE" ('0FR')`);
      console.log(JSON.stringify(s, null, 2));
    } catch (e) { console.log('  ERR ' + e.message); }
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
