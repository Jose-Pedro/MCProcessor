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
    // Pick an FR VIBDAO entry
    const [site] = await exec(`SELECT TOP 1 AOID, AOTYPE, XAO, OBJNR, INTRENO FROM VIBDAO WHERE AOTYPE='0FR' AND AOID='FR-44-013253'`);
    if (!site) { console.error('no site'); process.exit(1); }
    console.log('Site:', site);

    // Pick an IFLOT row
    const [iflot] = await exec(`SELECT TOP 1 OBJNR, ILOAN, TPLNR FROM IFLOT WHERE ILOAN IS NOT NULL AND ILOAN <> '' AND OBJNR IS NOT NULL AND OBJNR <> ''`);
    if (!iflot) { console.error('no iflot'); process.exit(1); }
    console.log('IFLOT:', iflot);

    // Find an FR-ish company code from T001
    let companyCode = '2160';
    try {
      const co = await exec(`SELECT BUKRS FROM T001 WHERE LAND1='FR' AND BUTXT NOT LIKE '%Obsole%' ORDER BY BUKRS LIMIT 5`);
      console.log('FR companies:', co);
      if (co.length > 0) companyCode = co[0].BUKRS.trim();
    } catch (e) { console.log('T001 lookup err:', e.message); }
    console.log('Using companyCode =', companyCode);

    // Look up existing rows so we don't duplicate
    const dup = await exec(`SELECT COUNT(*) AS N FROM VIBDOBJASS WHERE OBJNRSRC='${site.OBJNR}' AND OBJASSTYPE='61' AND OBJNRTRG='${iflot.OBJNR}'`);
    if (dup[0].N > 0) {
      console.log('VIBDOBJASS link already exists, skipping insert');
    } else {
      await exec(`INSERT INTO VIBDOBJASS (MANDT, OBJNRSRC, OBJASSTYPE, OBJNRTRG, VALIDFROM) VALUES ('100', '${site.OBJNR}', '61', '${iflot.OBJNR}', '20200101')`);
      console.log('Inserted VIBDOBJASS link');
    }

    const dupIloa = await exec(`SELECT COUNT(*) AS N FROM ILOA WHERE ILOAN='${iflot.ILOAN}'`);
    if (dupIloa[0].N > 0) {
      console.log('ILOA already exists, updating BUKRS');
      await exec(`UPDATE ILOA SET BUKRS='${companyCode}' WHERE ILOAN='${iflot.ILOAN}'`);
    } else {
      await exec(`INSERT INTO ILOA (MANDT, ILOAN, BUKRS) VALUES ('100', '${iflot.ILOAN}', '${companyCode}')`);
      console.log('Inserted ILOA');
    }

    // Verify SITES_BY_AOTYPE
    const out = await exec(`SELECT TOP 3 siteId, siteName, company, country, AOTYPE FROM SITES_BY_AOTYPE(P_AOTYPE => '0FR')`);
    console.log('\nSITES_BY_AOTYPE result:', JSON.stringify(out, null, 2));
  } catch (e) { console.error('ERR', e.message); }
  conn.disconnect();
});
