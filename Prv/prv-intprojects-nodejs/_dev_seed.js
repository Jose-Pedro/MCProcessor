const hana = require('@sap/hana-client');
const conn = hana.createConnection();
const cmd = process.argv[2] || 'inspect';
conn.connect({
  serverNode: 'localhost:39041', uid: 'INTPROJ',
  pwd: process.env.HXE_PWD || 'IntprojPwd2026',
  encrypt: false, sslValidateCertificate: false, currentSchema: 'INTPROJ'
}, async (err) => {
  if (err) { console.error(err); process.exit(1); }
  const exec = (sql) => new Promise((res, rej) => conn.exec(sql, (e, r) => e ? rej(e) : res(r)));
  try {
    if (cmd === 'inspect') {
      for (const t of ['SAP_COMMON_CURRENCIES','SAP_COMMON_CURRENCIES_TEXTS','PROJECT_TYPES','PROJECT_TYPES_TEXTS','PROCESS_TYPES','PROCESS_TYPES_TEXTS','MASTER_PROCESS','REQUEST_TYPE','PROCESS','PHASE']) {
        try {
          const cols = await exec(`SELECT COLUMN_NAME, DATA_TYPE_NAME, LENGTH, IS_NULLABLE FROM TABLE_COLUMNS WHERE SCHEMA_NAME='INTPROJ' AND TABLE_NAME='${t}' ORDER BY POSITION`);
          console.log(`\n# ${t}`);
          cols.forEach(c => console.log(`  ${c.COLUMN_NAME.padEnd(30)} ${c.DATA_TYPE_NAME}${c.LENGTH?'('+c.LENGTH+')':''} ${c.IS_NULLABLE==='FALSE'?'NOT NULL':''}`));
        } catch (e) { console.log(`  (no table ${t})`); }
      }
      // sample rows
      for (const t of ['MASTER_PROCESS','REQUEST_TYPE','PROCESS']) {
        try {
          const r = await exec(`SELECT TOP 5 * FROM ${t}`);
          console.log(`\n# sample ${t} (${r.length})`);
          if (r.length) console.log(JSON.stringify(r[0], null, 2).slice(0, 800));
        } catch (e) {}
      }
    } else if (cmd === 'seed') {
      // SAP_COMMON_CURRENCIES: PK=CODE; cols NAME, DESCR, CODE, SYMBOL, MINORUNIT
      const curs = [['EUR','Euro','€'],['USD','US Dollar','$'],['GBP','British Pound','£']];
      for (const [code,name,sym] of curs) {
        try {
          await exec(`UPSERT SAP_COMMON_CURRENCIES (CODE, SYMBOL, NAME, DESCR, MINORUNIT) VALUES ('${code}', '${sym}', '${name}', '${name}', 2) WITH PRIMARY KEY`);
          await exec(`UPSERT SAP_COMMON_CURRENCIES_TEXTS (LOCALE, CODE, NAME, DESCR) VALUES ('en', '${code}', '${name}', '${name}') WITH PRIMARY KEY`);
          console.log(`upserted currency ${code}`);
        } catch (e) { console.log(`currency ${code} ERR: ${e.message}`); }
      }
      // PROJECT_TYPES: PK=(CODE,COUNTRY); seed for FR (current user's country) plus a couple more
      const ptys = [['STD','Standard project'],['REFURB','Refurbishment'],['NEWBUILD','New build']];
      for (const country of ['FR','GB','ES']) {
        for (const [code,name] of ptys) {
          try {
            await exec(`UPSERT PROJECT_TYPES (CODE, COUNTRY, NAME) VALUES ('${code}','${country}','${name}') WITH PRIMARY KEY`);
            await exec(`UPSERT PROJECT_TYPES_TEXTS (LOCALE, CODE, COUNTRY, NAME) VALUES ('en','${code}','${country}','${name}') WITH PRIMARY KEY`);
          } catch (e) { console.log(`project_type ${country}/${code} ERR: ${e.message}`); }
        }
      }
      console.log('upserted project types for FR/GB/ES');
      // PROCESS_TYPES: PK=CODE; cols NAME, DESCR, CODE — seed minimal
      const psy = [['STD','Standard','Standard process'],['EXP','Express','Express process']];
      for (const [code,name,descr] of psy) {
        try {
          await exec(`UPSERT PROCESS_TYPES (CODE, NAME, DESCR) VALUES ('${code}','${name}','${descr}') WITH PRIMARY KEY`);
          await exec(`UPSERT PROCESS_TYPES_TEXTS (LOCALE, CODE, NAME, DESCR) VALUES ('en','${code}','${name}','${descr}') WITH PRIMARY KEY`);
          console.log(`upserted process type ${code}`);
        } catch (e) { console.log(`process_type ${code} ERR: ${e.message}`); }
      }
    }
  } catch (e) { console.error('FATAL', e); }
  conn.disconnect();
});
