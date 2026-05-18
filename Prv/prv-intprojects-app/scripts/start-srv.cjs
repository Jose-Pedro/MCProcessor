'use strict'
// Boots the CAP backend (../prv-intprojects-nodejs) against the local cmm-sync SQLite replica.
// Computes absolute paths so the spawned cds-serve resolves the DB independently of cwd.
// Also seeds empty stubs for identity tables that live in a separate HANA schema (cnx_external)
// and are absent from cmm-sync dumps; without them the per-request user bootstrap throws.
const path = require('node:path')
const fs = require('node:fs')
const { DatabaseSync } = require('node:sqlite')
const { spawn } = require('node:child_process')

const ROOT = path.resolve(__dirname, '..', '..', '..')
const SRV = path.resolve(__dirname, '..', '..', 'prv-intprojects-nodejs')
const DB = path.join(ROOT, 'Cmm', 'cmm-sync-database', 'cmm-sync.db')

if (!fs.existsSync(DB)) {
    console.error(`[start:srv] DB not found at ${DB}`)
    console.error('[start:srv] build it first: cd Cmm/cmm-sync-database && npm run load')
    process.exit(1)
}
if (!fs.existsSync(path.join(SRV, 'node_modules'))) {
    console.error(`[start:srv] ${SRV}/node_modules missing -- run: npm run install:srv`)
    process.exit(1)
}

// Schemas mirror Prv/prv-intprojects-nodejs/db/userinfo.cds. They live in a separate HANA
// schema (cnx_external) in production and are absent from cmm-sync dumps; create them empty
// so the per-request user bootstrap and the MANAGERS/PMO_MANAGERS/REQUESTERS views work.
const STUBS = [
    ['US_USERS_IAS', '(USER_ID TEXT PRIMARY KEY, USER_NAME TEXT, EMAIL TEXT, TELEPHONE TEXT, NEDAP TEXT, ILOQ TEXT, CARD_NUMBER TEXT)'],
    ['US_ROLES_AGR', '(USER_ID TEXT, IAS_GROUP TEXT, PRIMARY KEY (USER_ID, IAS_GROUP))'],
    ['US_BUKS',      '(USER_ID TEXT, BUK TEXT, PRIMARY KEY (USER_ID, BUK))'],
    ['US_COUNTRIES', '(USER_ID TEXT, COUNTRY_ID TEXT, PRIMARY KEY (USER_ID, COUNTRY_ID))'],
    ['US_ZAGENCY',   '(USER_ID TEXT, ZAGENCY_ID TEXT, ZAGENCY_DESCRIPTION TEXT, PRIMARY KEY (USER_ID, ZAGENCY_ID))'],
    ['US_ZCUSTOMER', '(USER_ID TEXT, ZCUSTOMER_ID TEXT, ZCUSTOMER_DESCRIPTION TEXT, PRIMARY KEY (USER_ID, ZCUSTOMER_ID))'],
    ['US_ZVENDOR',   '(USER_ID TEXT, ZVENDOR_ID TEXT, ZVENDOR_DESCRIPTION TEXT, PRIMARY KEY (USER_ID, ZVENDOR_ID))']
]
{
    const db = new DatabaseSync(DB)
    for (const [name, cols] of STUBS) {
        // Drop+recreate is safe: these tables are never populated by the cmm-sync loader.
        db.exec(`DROP TABLE IF EXISTS "${name}"`)
        db.exec(`CREATE TABLE "${name}" ${cols}`)
    }
    db.close()
    console.log(`[start:srv] ensured ${STUBS.length} identity stub tables`)
}

const env = {
    ...process.env,
    NODE_ENV: 'development',
    CDS_ENV: 'development',
    // cds.requires.db -> sqlite pointing at the cmm-sync replica
    CDS_REQUIRES_DB_KIND: 'sqlite',
    CDS_REQUIRES_DB_CREDENTIALS_URL: DB,
    // local mode: skip XSUAA, allow anonymous
    CDS_REQUIRES_AUTH_KIND: 'mocked',
    PORT: process.env.PORT || '4004'
}

console.log('[start:srv] cwd  =', SRV)
console.log('[start:srv] db   =', DB)
console.log('[start:srv] port =', env.PORT)

const isWin = process.platform === 'win32'
const child = spawn(isWin ? 'npm.cmd' : 'npm', ['run', 'start'], { cwd: SRV, env, stdio: 'inherit', shell: isWin })
child.on('exit', code => process.exit(code ?? 0))
