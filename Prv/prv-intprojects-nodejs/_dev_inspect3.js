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
    // record counts
    for (const t of ['VIBDAO','VIBDOBJASS','IFLOT','ILOA','VZOBJECT','ADRC']) {
      try {
        const c = await exec(`SELECT COUNT(*) AS N FROM ${t}`);
        console.log(`${t}: ${c[0].N}`);
      } catch (e) { console.log(`${t}: ERR ${e.message}`); }
    }
    // schema for each
    for (const t of ['VIBDAO','VIBDOBJASS','IFLOT','ILOA','VZOBJECT','ADRC']) {
      try {
        const cols = await exec(`SELECT COLUMN_NAME, DATA_TYPE_NAME, LENGTH, IS_NULLABLE FROM TABLE_COLUMNS WHERE SCHEMA_NAME='INTPROJ' AND TABLE_NAME='${t}' ORDER BY POSITION`);
        console.log(`\n# ${t} columns (${cols.length})`);
        cols.forEach(c => console.log(`  ${c.COLUMN_NAME} ${c.DATA_TYPE_NAME}(${c.LENGTH}) null=${c.IS_NULLABLE}`));
      } catch (e) { console.log(`# ${t}: ERR ${e.message}`); }
    }
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
