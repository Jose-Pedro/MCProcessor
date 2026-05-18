// Inspect existing INTPROJ tables that conflict with view definitions.
const hana = require('@sap/hana-client');
const c = hana.createConnection();
c.connect({ host: 'localhost', port: 39041, uid: 'INTPROJ', pwd: 'IntprojPwd2026', databaseName: 'HXE' }, async (e) => {
  if (e) { console.log('CONN ERR:', e.message); process.exit(1); }
  const q = (sql) => new Promise((res, rej) => c.exec(sql, (e2, r) => e2 ? rej(e2) : res(r)));
  for (const name of ['APPROVER_TYPES', 'SUBCO_TYPES', 'WORK_CONFIG_DOCUMENT_FLOWS', 'WORK_CONFIG_DOCUMENT_DEFAULTS']) {
    const tabs = await q(`SELECT TABLE_NAME,RECORD_COUNT FROM SYS.M_TABLES WHERE SCHEMA_NAME='INTPROJ' AND TABLE_NAME='${name}'`);
    if (tabs.length) {
      console.log(`TABLE ${name} rows=${tabs[0].RECORD_COUNT}`);
      const cols = await q(`SELECT COLUMN_NAME,DATA_TYPE_NAME,LENGTH FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME='INTPROJ' AND TABLE_NAME='${name}' ORDER BY POSITION`);
      console.log('  cols: ' + cols.map(x => x.COLUMN_NAME + ':' + x.DATA_TYPE_NAME + (x.LENGTH ? '(' + x.LENGTH + ')' : '')).join(', '));
    } else {
      console.log(`TABLE ${name} NOT FOUND`);
    }
  }
  c.disconnect();
});
