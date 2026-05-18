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
    console.log('# VIBDAO AOTYPE distribution');
    const r = await exec(`SELECT AOTYPE, COUNT(*) AS N FROM VIBDAO GROUP BY AOTYPE ORDER BY N DESC LIMIT 20`);
    r.forEach(x => console.log(`  AOTYPE=${JSON.stringify(x.AOTYPE)} n=${x.N}`));

    console.log('\n# Existing 0FR sample');
    const fr = await exec(`SELECT TOP 3 AOID, AOTYPE, XAO, OBJNR, INTRENO FROM VIBDAO WHERE AOTYPE='0FR'`);
    console.log(JSON.stringify(fr, null, 2));

    console.log('\n# IFLOT sample');
    const i = await exec(`SELECT TOP 3 OBJNR, ILOAN, TPLNR FROM IFLOT WHERE ILOAN IS NOT NULL AND ILOAN <> ''`);
    console.log(JSON.stringify(i, null, 2));
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
