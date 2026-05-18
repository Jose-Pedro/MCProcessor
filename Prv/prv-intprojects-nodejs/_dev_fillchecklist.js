// dev: fill mandatory checklist items for given block IDs in HXE
const cds = require('@sap/cds')
const hana = require('@sap/hana-client')

const conn = hana.createConnection()
const params = { serverNode: 'localhost:39041', uid: 'INTPROJ', pwd: 'IntprojPwd2026', encrypt: false, sslValidateCertificate: false }

function exec(sql, args=[]) {
    return new Promise((res, rej) => conn.exec(sql, args, (e, r) => e ? rej(e) : res(r)))
}

;(async () => {
    await new Promise((res, rej) => conn.connect(params, e => e ? rej(e) : res()))
    const blockIds = process.argv.slice(2)
    if (!blockIds.length) { console.error('usage: node _dev_fillchecklist.js <blockId> [<blockId>...]'); process.exit(1) }
    const placeholders = blockIds.map(() => '?').join(',')
    const items = await exec(`
        SELECT ci.ID, ci.BLOCK_ID, ci.MANDATORY, ci.TYPE_ID, it.VALUETYPE_ID,
               ci.BOOLEANVALUE, ci.STRINGVALUE, ci.DATEVALUE, ci.INTEGERVALUE, ci.DECIMALVALUE, ci.PICKLIST
        FROM CHECKLIST_ITEM ci LEFT JOIN CHECKLIST_ITEMTYPE it ON it.ID = ci.TYPE_ID
        WHERE ci.BLOCK_ID IN (${placeholders}) AND (ci.DELETED IS NULL OR ci.DELETED = FALSE) AND ci.MANDATORY = TRUE
        ORDER BY ci.BLOCK_ID, ci.ID`, blockIds)

    console.log(`Found ${items.length} mandatory checklist items`)
    for (const it of items) {
        const vt = it.VALUETYPE_ID
        let col, val
        switch (vt) {
            case 1: col = 'BOOLEANVALUE'; val = true; break
            case 2: col = 'STRINGVALUE'; val = 'auto-filled'; break
            case 3: col = 'DATEVALUE'; val = '2026-05-11'; break
            case 4: col = 'INTEGERVALUE'; val = 1; break
            case 5: col = 'DECIMALVALUE'; val = 1; break
            case 6: col = 'PICKLIST'; val = '1'; break
            default:
                // unknown valuetype: try populating all single-value cols cautiously, prefer string
                col = 'STRINGVALUE'; val = 'auto-filled'
                console.log(`  unknown VALUETYPE_ID=${vt} for item ${it.ID} (TYPE=${it.TYPE_ID}); defaulting to STRING`)
        }
        // skip if already populated
        const cur = it[col]
        if (cur !== null && cur !== undefined && cur !== '') { console.log(`  skip ${it.ID} ${col} already set`); continue }
        await exec(`UPDATE CHECKLIST_ITEM SET ${col} = ? WHERE ID = ?`, [val, it.ID])
        console.log(`  updated ${it.ID} ${col}=${val}`)
    }
    conn.disconnect()
})().catch(e => { console.error(e); process.exit(2) })
