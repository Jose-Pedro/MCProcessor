// Re-apply CREATE VIEW statements from schema-hana.utf8.sql into INTPROJ.
// Skips views already present. Logs failures. Idempotent.
const fs = require('fs');
const path = require('path');
const hana = require('@sap/hana-client');

const SCHEMA_FILE = path.resolve(__dirname, '..', 'schema-hana.utf8.sql');
const sql = fs.readFileSync(SCHEMA_FILE, 'utf8');

// Split into statements on ';' at end of line. CDS SQL has no embedded ';' in
// view bodies that would confuse this naive split.
const statements = sql.split(/;\s*\r?\n/).map(s => s.trim()).filter(Boolean);
const viewStmts = statements
  .map(s => {
    const m = s.match(/^CREATE\s+VIEW\s+([A-Za-z0-9_]+)/i);
    return m ? { name: m[1].toUpperCase(), sql: s } : null;
  })
  .filter(Boolean);

console.log(`Found ${viewStmts.length} CREATE VIEW statements in schema.`);

const c = hana.createConnection();
c.connect({ host: 'localhost', port: 39041, uid: 'INTPROJ', pwd: 'IntprojPwd2026', databaseName: 'HXE' }, (e) => {
  if (e) { console.log('CONN ERR:', e.message); process.exit(1); }
  c.exec(`SELECT VIEW_NAME FROM SYS.VIEWS WHERE SCHEMA_NAME='INTPROJ'`, (e2, rows) => {
    if (e2) { console.log('Q ERR:', e2.message); process.exit(1); }
    const have = new Set(rows.map(r => r.VIEW_NAME));
    const todo = viewStmts.filter(v => !have.has(v.name));
    console.log(`Already present: ${have.size}. To create: ${todo.length}.`);

    let i = 0, ok = 0, fail = 0;
    const failures = [];
    function next() {
      if (i >= todo.length) {
        console.log(`\nDONE. created=${ok} failed=${fail}`);
        if (failures.length) {
          console.log('--- FAILURES ---');
          failures.forEach(f => console.log(`  ${f.name}: ${f.err}`));
        }
        c.disconnect();
        return;
      }
      const v = todo[i++];
      c.exec(v.sql, (err) => {
        if (err) {
          fail++;
          failures.push({ name: v.name, err: err.message.split('\n')[0] });
        } else {
          ok++;
        }
        if ((i % 25) === 0) process.stdout.write(`  progress ${i}/${todo.length}\n`);
        setImmediate(next);
      });
    }
    next();
  });
});
