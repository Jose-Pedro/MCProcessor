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

    console.log('# All PROJECT_REQUESTS columns and their data type');
    const cols = await exec(`SELECT COLUMN_NAME, DATA_TYPE_NAME FROM VIEW_COLUMNS WHERE SCHEMA_NAME='INTPROJ' AND VIEW_NAME='PROJECT_REQUESTS' ORDER BY POSITION`);
    cols.forEach(c => console.log(`  ${c.COLUMN_NAME} ${c.DATA_TYPE_NAME}`));

    console.log('\n# All values for our row');
    const r = await exec(`SELECT * FROM PROJECT_REQUESTS WHERE ID='${id}'`);
    Object.entries(r[0] || {}).forEach(([k, v]) => {
      if (v !== null) console.log(`  ${k} = ${JSON.stringify(v)} type=${typeof v}`);
    });

    console.log('\n# Try toISOString on each value');
    Object.entries(r[0] || {}).forEach(([k, v]) => {
      if (v === null || v === undefined) return;
      try {
        new Date(v).toISOString();
      } catch (e) {
        console.log(`  BAD ${k} = ${JSON.stringify(v)}: ${e.message}`);
      }
    });
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
