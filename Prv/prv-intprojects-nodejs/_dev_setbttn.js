// dev: set BTTN_INV/SERV/DOC_UPDATED on the finalValidation/validDocument BlockProvision for a request
const hana = require('@sap/hana-client')
const REQUEST_ID = process.argv[2] || '2cdcc531-0fcb-4387-b7e9-796e5a241b83'
const conn = hana.createConnection()
const exec = (sql, args=[]) => new Promise((res, rej) => conn.exec(sql, args, (e,r) => e ? rej(e) : res(r)))
;(async () => {
    await new Promise((res, rej) => conn.connect({ serverNode:'localhost:39041', uid:'INTPROJ', pwd:'IntprojPwd2026', encrypt:false, sslValidateCertificate:false }, e => e ? rej(e) : res()))
    const rows = await exec(`
        SELECT bh.BLOCK_ID FROM PHASE_HEAD ph
        INNER JOIN BLOCK_HEAD bh ON bh.PHASE_ID = ph.PHASE_ID
        WHERE ph.REQUEST_ID = ? AND ph.MASTER_PHASE_ID = 'finalValidation' AND bh.MASTER_BLOCK_ID = 'validDocument'`, [REQUEST_ID])
    console.log('rows:', rows)
    for (const r of rows) {
        await exec(`UPDATE BLOCKS_PROVISIONING SET BTTN_INV_UPDATED='true', BTTN_SERV_UPDATED='true', BTTN_DOC_UPDATED='true' WHERE BLOCK_ID = ?`, [r.BLOCK_ID])
        console.log('  updated', r.BLOCK_ID)
    }
    conn.disconnect()
})().catch(e => { console.error(e); process.exit(2) })
