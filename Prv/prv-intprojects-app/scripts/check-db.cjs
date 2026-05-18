'use strict'
const path = require('node:path')
const fs = require('node:fs')
const { DatabaseSync } = require('node:sqlite')

const DB = path.resolve(__dirname, '..', '..', '..', 'Cmm', 'cmm-sync-database', 'cmm-sync.db')

if (!fs.existsSync(DB)) {
    console.error(`[check:db] missing ${DB}`)
    console.error('[check:db] build it first: cd Cmm/cmm-sync-database && npm run load')
    process.exit(1)
}

const db = new DatabaseSync(DB, { readOnly: true })
const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").all()
const expected = ['REQUEST_HEAD', 'PHASE_HEAD', 'BLOCK_HEAD', 'BLOCKS_PROVISIONING', 'PROCESS', 'WF_DETAIL_DOCUMENTS', 'DOCUMENTS_PER_BLOCK']
const missing = expected.filter(t => !tables.find(r => r.name === t))

console.log(`[check:db] ${DB}`)
console.log(`[check:db] tables: ${tables.length}`)
if (missing.length) {
    console.error(`[check:db] missing expected tables: ${missing.join(', ')}`)
    process.exit(2)
}
for (const t of expected) {
    const c = db.prepare(`SELECT COUNT(*) AS n FROM "${t}"`).get()
    console.log(`[check:db]   ${t.padEnd(28)} rows=${c.n}`)
}
db.close()
