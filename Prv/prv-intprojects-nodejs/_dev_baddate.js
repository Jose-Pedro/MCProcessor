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

    console.log('# REQUEST_HEAD raw');
    const rh = await exec(`SELECT * FROM REQUEST_HEAD WHERE REQUEST_ID='${id}'`);
    console.log(JSON.stringify(rh[0], null, 2));

    console.log('\n# Underlying view name for project.Requests');
    const vs = await exec(`SELECT VIEW_NAME FROM VIEWS WHERE SCHEMA_NAME='INTPROJ' AND (VIEW_NAME LIKE '%REQUEST%' AND VIEW_NAME NOT LIKE '%TEXTS%' AND VIEW_NAME NOT LIKE '%LOCALIZED%') ORDER BY VIEW_NAME`);
    vs.forEach(v => console.log('  ' + v.VIEW_NAME));

    console.log('\n# PROJECT_REQUESTS row');
    try {
      const r = await exec(`SELECT * FROM PROJECT_REQUESTS WHERE ID='${id}'`);
      const cols = Object.keys(r[0] || {});
      cols.forEach(c => {
        const v = r[0][c];
        if (v instanceof Date || (typeof v === 'string' && /\d{4}/.test(v) && c.match(/AT$|DATE|TIME|FROM|TO|_AT/i))) {
          console.log(`  ${c} = ${JSON.stringify(v)}`);
        }
      });
    } catch (e) { console.log('  ERR ' + e.message); }
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
