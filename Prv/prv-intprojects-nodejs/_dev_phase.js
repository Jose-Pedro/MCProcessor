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
    const id = '2cdcc531-0fcb-4387-b7e9-796e5a241b83';

    console.log('# PHASE_HEAD columns');
    const cols = await exec(`SELECT COLUMN_NAME, DATA_TYPE_NAME FROM TABLE_COLUMNS WHERE SCHEMA_NAME='INTPROJ' AND TABLE_NAME='PHASE_HEAD' ORDER BY POSITION`);
    cols.forEach(c => console.log(`  ${c.COLUMN_NAME} ${c.DATA_TYPE_NAME}`));

    console.log('\n# PHASE_HEAD rows for this request');
    try {
      const r = await exec(`SELECT * FROM PHASE_HEAD WHERE REQUEST_ID='${id}'`);
      r.forEach(row => console.log(JSON.stringify(row)));
    } catch (e) { console.log('  ERR ' + e.message); }
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
