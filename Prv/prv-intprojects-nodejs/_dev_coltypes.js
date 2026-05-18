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
    const tbls = ['REQUEST_HEAD','PHASE_HEAD','BLOCK_HEAD','REQUEST_CHAR_PRO','WORKS','CHECKLIST_ITEM'];
    for (const t of tbls) {
      console.log(`\n# ${t}`);
      const r = await exec(`SELECT COLUMN_NAME, DATA_TYPE_NAME FROM TABLE_COLUMNS WHERE SCHEMA_NAME='INTPROJ' AND TABLE_NAME='${t}' AND (COLUMN_NAME LIKE '%AT' OR COLUMN_NAME LIKE '%DATE%' OR COLUMN_NAME='DELETED_AT' OR COLUMN_NAME='STARTED_AT' OR COLUMN_NAME='ENDED_AT' OR COLUMN_NAME LIKE '%TIMESTAMP%') ORDER BY COLUMN_NAME`);
      r.forEach(row => console.log(`  ${row.COLUMN_NAME} ${row.DATA_TYPE_NAME}`));
    }
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
