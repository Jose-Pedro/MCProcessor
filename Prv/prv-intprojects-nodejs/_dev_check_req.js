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
    const r = await exec(`SELECT TOP 3 REQUEST_ID, SITE_ID, COUNTRY_ID, CREATEDAT, MODIFIEDAT, STARTED_AT, ASSIGNATION_DATE, ENDED_AT FROM REQUEST_HEAD WHERE REQUEST_TYPE = 40 ORDER BY CREATEDAT DESC`);
    console.log('REQUEST_HEAD type=40:', JSON.stringify(r, null, 2));

    const id = r[0] && r[0].REQUEST_ID;
    if (id) {
      console.log('\n# REQUEST_CHAR_PRO');
      const p = await exec(`SELECT REQUEST_ID, REQUESTED_DATE, CREATEDAT FROM REQUEST_CHAR_PRO WHERE REQUEST_ID='${id}'`);
      console.log(JSON.stringify(p, null, 2));

      console.log('\n# PHASE_HEAD count');
      const ph = await exec(`SELECT COUNT(*) AS N FROM PHASE_HEAD WHERE REQUEST_ID='${id}'`);
      console.log(ph);

      console.log('\n# Project Requests view returns');
      try {
        const v = await exec(`SELECT TOP 3 ID, country, requestedDate, createdAt, modifiedAt, startedAt FROM "PROJECT_REQUESTS" WHERE ID='${id}'`);
        console.log(JSON.stringify(v, null, 2));
      } catch (e) { console.log('  view ERR ' + e.message); }
    }
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
