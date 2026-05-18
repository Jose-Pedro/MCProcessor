// Seed mocked user FRPRCOLMNG with country FR (France) so the requests/blocks
// handlers in srv/code/*.js stop returning notAuthorizedNoCountry.
const hana = require('@sap/hana-client');
const c = hana.createConnection();
c.connect({ host: 'localhost', port: 39041, uid: 'INTPROJ', pwd: 'IntprojPwd2026', databaseName: 'HXE' }, async (e) => {
  if (e) { console.log('CONN ERR:', e.message); process.exit(1); }
  const q = (sql) => new Promise((res, rej) => c.exec(sql, (e2, r) => e2 ? rej(e2) : res(r)));

  console.log('US_COUNTRIES total: ' + (await q("SELECT COUNT(*) AS N FROM US_COUNTRIES"))[0].N);
  console.log('Sample rows:');
  (await q("SELECT TOP 3 * FROM US_COUNTRIES")).forEach(r => console.log('  ' + JSON.stringify(r)));

  // Mocked auth may emit user.id in either case; cover both.
  for (const uid of ['FRPRCOLMNG', 'frprcolmng']) {
    const existing = await q(`SELECT * FROM US_COUNTRIES WHERE USER_ID='${uid}'`);
    if (existing.length === 0) {
      await q(`INSERT INTO US_COUNTRIES (USER_ID, COUNTRY_ID) VALUES ('${uid}', 'FR')`);
      console.log(`Inserted ${uid} / FR`);
    } else {
      console.log(`${uid} already present (${existing.length} rows)`);
    }
  }
  // Also seed a baseline role row so getRoles() doesn't return empty.
  for (const uid of ['FRPRCOLMNG', 'frprcolmng']) {
    const existing = await q(`SELECT * FROM US_ROLES_AGR WHERE USER_ID='${uid}'`);
    if (existing.length === 0) {
      await q(`INSERT INTO US_ROLES_AGR (USER_ID, IAS_GROUP) VALUES ('${uid}', 'TIS_WF_PRO_IntProjectsMgr')`);
      console.log(`Inserted ${uid} role`);
    }
  }
  // And a BUK row.
  for (const uid of ['FRPRCOLMNG', 'frprcolmng']) {
    const existing = await q(`SELECT * FROM US_BUKS WHERE USER_ID='${uid}'`);
    if (existing.length === 0) {
      await q(`INSERT INTO US_BUKS (USER_ID, BUK) VALUES ('${uid}', 'FR01')`);
      console.log(`Inserted ${uid} BUK`);
    }
  }
  console.log('Final US_COUNTRIES rows for FRPRCOLMNG (any case):');
  (await q("SELECT * FROM US_COUNTRIES WHERE UPPER(USER_ID)='FRPRCOLMNG'")).forEach(r => console.log('  ' + JSON.stringify(r)));
  c.disconnect();
});
