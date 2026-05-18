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

    console.log('# PHASE_HEAD');
    const ph = await exec(`SELECT PHASE_ID, MASTER_PHASE_ID, STARTED_AT, ENDED_AT, CREATEDAT, MODIFIEDAT, FORECAST_END_DATE FROM PHASE_HEAD WHERE REQUEST_ID='${id}'`);
    console.log(JSON.stringify(ph, null, 2));

    console.log('\n# BLOCK_HEAD');
    const bh = await exec(`SELECT BLOCK_ID, MASTER_BLOCK_ID, STARTED_AT, ENDED_AT, CREATEDAT FROM BLOCK_HEAD WHERE PHASE_ID IN (SELECT PHASE_ID FROM PHASE_HEAD WHERE REQUEST_ID='${id}')`);
    console.log(`  count=${bh.length}, first 3:`, JSON.stringify(bh.slice(0, 3), null, 2));

    console.log('\n# Sample CHECKLIST');
    try {
      const cl = await exec(`SELECT TOP 3 ID, CREATEDAT, MODIFIEDAT FROM "Checklist.Item" WHERE REQUESTID='${id}'`);
      console.log(JSON.stringify(cl, null, 2));
    } catch (e) { console.log('  ERR ' + e.message); }

    console.log('\n# WORKS dates');
    try {
      const w = await exec(`SELECT TOP 3 ID, parentId, plannedStart, plannedEnd, realStart, realEnd, createdAt FROM WORKS WHERE parentId IN (SELECT BLOCK_ID FROM BLOCK_HEAD WHERE PHASE_ID IN (SELECT PHASE_ID FROM PHASE_HEAD WHERE REQUEST_ID='${id}'))`);
      console.log(JSON.stringify(w, null, 2));
    } catch (e) { console.log('  ERR ' + e.message); }

    console.log('\n# Project.Requests has associations - probe SITES join');
    try {
      const rs = await exec(`SELECT * FROM SITES_BY_AOTYPE(P_AOTYPE => '0FR') WHERE siteId='FR-44-013253'`);
      Object.entries(rs[0] || {}).forEach(([k, v]) => {
        console.log(`  ${k} = ${JSON.stringify(v)}`);
      });
    } catch (e) { console.log('  ERR ' + e.message); }
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
