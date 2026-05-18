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

    console.log('# REQUEST_CHAR_PRO raw');
    const r = await exec(`SELECT * FROM REQUEST_CHAR_PRO WHERE REQUEST_ID='${id}'`);
    console.log(JSON.stringify(r[0], null, 2));

    console.log('\n# PROJECT_REQUESTPROVISION via view');
    try {
      const v = await exec(`SELECT * FROM PROJECT_REQUESTPROVISION WHERE ID='${id}'`);
      Object.entries(v[0] || {}).forEach(([k, vl]) => {
        console.log(`  ${k} = ${JSON.stringify(vl)}`);
      });
    } catch (e) { console.log('  ERR ' + e.message); }
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
