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
    console.log('# PROCESS rows for int (master_process)');
    const p = await exec(`SELECT TOP 30 PROCESS_ID_PK, COUNTRY_CODE, COMPANY_CODE, CLASSIFICATION, CLIENT, PROGRAM, ID_PK FROM PROCESS WHERE PROCESS_ID_PK='int' ORDER BY COUNTRY_CODE, PROGRAM`);
    console.log(JSON.stringify(p, null, 2));
    console.log('\n# PROCESS distribution by PROCESS_ID_PK + COUNTRY_CODE');
    const d = await exec(`SELECT PROCESS_ID_PK, COUNTRY_CODE, COUNT(*) AS N FROM PROCESS GROUP BY PROCESS_ID_PK, COUNTRY_CODE ORDER BY PROCESS_ID_PK, COUNTRY_CODE`);
    d.forEach(r => console.log(`  ${r.PROCESS_ID_PK} ${r.COUNTRY_CODE} n=${r.N}`));
    console.log('\n# Sample SITES_BY_AOTYPE for FR (p_aotype=0FR)');
    try {
      const s = await exec(`SELECT TOP 3 * FROM SITES_BY_AOTYPE(PLACEHOLDER."$$P_AOTYPE$$" => '0FR')`);
      console.log(JSON.stringify(s, null, 2));
    } catch (e) { console.log('  ERR ' + e.message); }
    console.log('\n# Site counts in DB');
    const tables = ['CMM_SITE','CMM_SITES','SITES','MTO_SITE','BIM_SITE'];
    for (const t of tables) {
      try {
        const c = await exec(`SELECT COUNT(*) AS N FROM ${t}`);
        console.log(`  ${t}: ${c[0].N}`);
      } catch (e) { console.log(`  ${t}: ERR ${e.message.split(':')[0]}`); }
    }
    console.log('\n# Search for any *SITE* tables with FR rows');
    const ts = await exec(`SELECT TABLE_NAME FROM TABLES WHERE SCHEMA_NAME='INTPROJ' AND TABLE_NAME LIKE '%SITE%' AND TABLE_NAME NOT LIKE '%TEXT%' ORDER BY TABLE_NAME`);
    ts.forEach(r => console.log('  ' + r.TABLE_NAME));
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
