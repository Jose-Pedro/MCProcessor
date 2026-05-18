// Probe PRO HANA Cloud for the few tables/views still missing locally so we can
// decide whether to replicate the data or just stub the schema.
const hana = require('@sap/hana-client');

const NAMES = [
  'WORK_CONFIG_DOCUMENT_FLOWS',
  'WORK_CONFIG_DOCUMENT_DEFAULTS',
  'WORK_CONFIG_DOCUMENT_DEFAULTS_TEXTS',
  'WORK_CONFIG_DOCUMENT_DEFAULTS_texts',
  'APPROVER_TYPES',
  'SUBCO_TYPES',
];

const c = hana.createConnection();
c.connect({
  host: 'b6ff13e4-624a-48f7-aa9c-fc5cf59beb8c.hana.prod-eu20.hanacloud.ondemand.com',
  port: 443, uid: 'AGORA_READ_ONLY', pwd: '32QGPr52q>8qa7y8o',
  encrypt: true, sslValidateCertificate: false,
}, async (e) => {
  if (e) { console.log('CONN ERR:', e.message); process.exit(1); }
  const q = (sql) => new Promise((res, rej) => c.exec(sql, (e2, r) => e2 ? rej(e2) : res(r)));
  const inList = NAMES.map(n => "'" + n + "'").join(',');
  try {
    const tabs = await q(
      `SELECT SCHEMA_NAME,TABLE_NAME,RECORD_COUNT FROM SYS.M_TABLES ` +
      `WHERE TABLE_NAME IN (${inList}) AND SCHEMA_NAME NOT IN ('SYS','PUBLIC') ` +
      `ORDER BY TABLE_NAME,SCHEMA_NAME`);
    console.log('--- TABLES ---');
    tabs.forEach(r => console.log(`  ${r.SCHEMA_NAME}.${r.TABLE_NAME}  rows=${r.RECORD_COUNT}`));

    const vws = await q(
      `SELECT SCHEMA_NAME,VIEW_NAME FROM SYS.VIEWS ` +
      `WHERE VIEW_NAME IN (${inList}) AND SCHEMA_NAME NOT IN ('SYS','PUBLIC') ` +
      `ORDER BY VIEW_NAME,SCHEMA_NAME`);
    console.log('--- VIEWS ---');
    vws.forEach(r => console.log(`  ${r.SCHEMA_NAME}.${r.VIEW_NAME}`));

    // For each found, dump column list.
    for (const r of [...tabs, ...vws]) {
      const name = r.TABLE_NAME || r.VIEW_NAME;
      const cols = await q(
        `SELECT COLUMN_NAME,DATA_TYPE_NAME,LENGTH,SCALE,IS_NULLABLE FROM SYS.TABLE_COLUMNS ` +
        `WHERE SCHEMA_NAME='${r.SCHEMA_NAME}' AND TABLE_NAME='${name}' ORDER BY POSITION`);
      if (!cols.length) {
        const cv = await q(
          `SELECT COLUMN_NAME,DATA_TYPE_NAME,LENGTH,SCALE FROM SYS.VIEW_COLUMNS ` +
          `WHERE SCHEMA_NAME='${r.SCHEMA_NAME}' AND VIEW_NAME='${name}' ORDER BY POSITION`);
        console.log(`COLS ${r.SCHEMA_NAME}.${name} (view): ${cv.map(x => x.COLUMN_NAME + ':' + x.DATA_TYPE_NAME).join(', ')}`);
      } else {
        console.log(`COLS ${r.SCHEMA_NAME}.${name}: ${cols.map(x => x.COLUMN_NAME + ':' + x.DATA_TYPE_NAME + (x.LENGTH ? '(' + x.LENGTH + ')' : '')).join(', ')}`);
      }
    }
  } catch (ex) {
    console.log('Q ERR:', ex.message);
  }
  c.disconnect();
});
