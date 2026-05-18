// dev: drive the workflow for one request — for every active block, satisfy
// the close() preconditions (mandatory checklist fields, BlockProvision
// responsible/subcontractor, mandatory header fields, in-progress documents)
// and call close(); repeat until no more active blocks.
const hana = require('@sap/hana-client')
const http = require('http')

const REQUEST_ID = process.argv[2] || '2cdcc531-0fcb-4387-b7e9-796e5a241b83'
const USER = 'FRPRCOLMNG', PWD = 'Cellnex01.'
const AUTH = 'Basic ' + Buffer.from(`${USER}:${PWD}`).toString('base64')

const conn = hana.createConnection()
const exec = (sql, args=[]) => new Promise((res, rej) => conn.exec(sql, args, (e,r) => e ? rej(e) : res(r)))
const connect = () => new Promise((res, rej) => conn.connect({ serverNode:'localhost:39041', uid:'INTPROJ', pwd:'IntprojPwd2026', encrypt:false, sslValidateCertificate:false }, e => e ? rej(e) : res()))

function api(method, path, body) {
    return new Promise((res) => {
        const data = body && JSON.stringify(body)
        const req = http.request({ host:'localhost', port:4004, path:encodeURI(`/service/project${path}`), method,
            headers:{ Authorization:AUTH, 'Content-Type':'application/json', ...(data && { 'Content-Length':Buffer.byteLength(data) }) } },
            r => { let chunks=''; r.on('data', c => chunks+=c); r.on('end', () => res({ status:r.statusCode, body:chunks })) })
        req.on('error', e => res({ status:0, body:String(e) }))
        if (data) req.write(data)
        req.end()
    })
}

async function fillChecklist(blockId) {
    const items = await exec(`
        SELECT ci.ID, it.VALUETYPE_ID, ci.BOOLEANVALUE, ci.STRINGVALUE, ci.DATEVALUE, ci.INTEGERVALUE, ci.DECIMALVALUE, ci.PICKLIST
        FROM CHECKLIST_ITEM ci LEFT JOIN CHECKLIST_ITEMTYPE it ON it.ID = ci.TYPE_ID
        WHERE ci.BLOCK_ID = ? AND (ci.DELETED IS NULL OR ci.DELETED = FALSE) AND ci.MANDATORY = TRUE`, [blockId])
    let n = 0
    for (const it of items) {
        const map = { 1:['BOOLEANVALUE',true], 2:['STRINGVALUE','auto'], 3:['DATEVALUE','2026-05-11'], 4:['INTEGERVALUE',1], 5:['DECIMALVALUE',1], 6:['PICKLIST','1'] }
        const [col, val] = map[it.VALUETYPE_ID] || ['STRINGVALUE','auto']
        if (it[col] === null || it[col] === undefined || it[col] === '') {
            await exec(`UPDATE CHECKLIST_ITEM SET ${col} = ? WHERE ID = ?`, [val, it.ID]); n++
        }
    }
    return n
}

async function ensureBlockProvision(blockId) {
    // ensure subcontractor + responsible filled when assigned external
    const rows = await exec(`SELECT ASSIGNED_RESPONSIBLE, SUBCONTRACTOR_TYPE, PROVIDER_NAME, RESPONSIBLE_PERSON FROM BLOCKS_PROVISIONING WHERE BLOCK_ID = ?`, [blockId])
    if (!rows.length) return 0
    const r = rows[0]; let sets=[], vals=[]
    if (r.ASSIGNED_RESPONSIBLE === '2') {
        if (!r.SUBCONTRACTOR_TYPE) { sets.push('SUBCONTRACTOR_TYPE=?'); vals.push(3) }
        if (!r.PROVIDER_NAME) { sets.push('PROVIDER_NAME=?'); vals.push('0000089881') }
    } else if (r.ASSIGNED_RESPONSIBLE === '1' && !r.RESPONSIBLE_PERSON) {
        sets.push('RESPONSIBLE_PERSON=?'); vals.push(USER)
    }
    if (!sets.length) return 0
    vals.push(blockId)
    await exec(`UPDATE BLOCKS_PROVISIONING SET ${sets.join(',')} WHERE BLOCK_ID = ?`, vals)
    return sets.length
}

async function fillMandatoryHeader(blockId, errorTarget, errorMsgArgs) {
    // errorTarget format e.g. /Blocks(guid'...')/<field>
    // errorMsgArgs[0] is field name
    const m = errorTarget && errorTarget.match(/^\/(Blocks|BlockProvision|Requests|RequestProvision)\(guid'([^']+)'\)\/(.+)$/)
    if (!m) return false
    const [_, entity, id, field] = m
    const tableMap = { Blocks:'BLOCK_HEAD', BlockProvision:'BLOCKS_PROVISIONING', Requests:'REQUEST_HEAD', RequestProvision:'REQUEST_CHAR_PRO' }
    const idColMap  = { Blocks:'BLOCK_ID',   BlockProvision:'BLOCK_ID',          Requests:'REQUEST_ID', RequestProvision:'REQUEST_ID' }
    const tab = tableMap[entity], idCol = idColMap[entity]
    if (!tab) return false
    // discover db column
    const cols = await exec(`SELECT COLUMN_NAME, DATA_TYPE_NAME FROM TABLE_COLUMNS WHERE SCHEMA_NAME = CURRENT_SCHEMA AND TABLE_NAME = ?`, [tab])
    const candidate = cols.find(c => c.COLUMN_NAME.replace(/_/g,'').toLowerCase() === field.toLowerCase())
    if (!candidate) { console.log(`    [skip] no col match ${entity}.${field}`); return false }
    const dt = candidate.DATA_TYPE_NAME
    let val
    if (/INT|TINYINT|SMALLINT|BIGINT/.test(dt)) val = 1
    else if (/DEC|FLOAT|DOUBLE/.test(dt)) val = 1
    else if (/DATE|TIME/.test(dt)) val = '2026-05-11'
    else if (/BOOL/.test(dt)) val = true
    else val = 'auto'
    await exec(`UPDATE ${tab} SET ${candidate.COLUMN_NAME} = ? WHERE ${idCol} = ?`, [val, id])
    console.log(`    [filled] ${tab}.${candidate.COLUMN_NAME} = ${val} for ${id}`)
    return true
}

async function closeBlock(b) {
    console.log(`\n--- close ${b.processFlowId} (${b.ID}) phase=${b.phaseId} ---`)
    let attempts = 0
    while (attempts++ < 8) {
        await ensureBlockProvision(b.ID)
        await fillChecklist(b.ID)
        const r = await api('POST', `/Blocks(${b.ID})/project.close`, {})
        if (r.status === 200) { console.log(`  [200] -> ${r.body}`); return true }
        let parsed; try { parsed = JSON.parse(r.body) } catch {}
        const errs = parsed?.error?.details || (parsed?.error ? [parsed.error] : [])
        console.log(`  [${r.status}] ${parsed?.error?.message || r.body.slice(0,200)}`)
        let progressed = false
        for (const e of errs) {
            if (e.target) progressed = (await fillMandatoryHeader(b.ID, e.target, e['@Common.additionalTargets'])) || progressed
            if (/checklist/i.test(e.message||'')) { await fillChecklist(b.ID); progressed = true }
        }
        if (!progressed) { console.log('  [no progress, abort]'); return false }
    }
    return false
}

;(async () => {
    await connect()
    let pass = 0
    while (pass++ < 20) {
        const r = await api('GET', `/Blocks?$filter=status eq 7 and Phases/requestId eq ${REQUEST_ID}`, null)
        let blocks = []; try { blocks = JSON.parse(r.body).value || [] } catch {}
        if (!blocks.length) {
            // fallback: any status=7 block (multi-phase)
            const r2 = await api('GET', `/Blocks?$filter=status eq 7`, null)
            try { blocks = JSON.parse(r2.body).value || [] } catch {}
            // filter by phase belonging to our request
            const phaseIds = new Set((JSON.parse((await api('GET', `/Phases?$filter=requestId eq ${REQUEST_ID}`,null)).body).value || []).map(p=>p.ID))
            blocks = blocks.filter(b => phaseIds.has(b.phaseId))
        }
        console.log(`\n==== pass ${pass}: ${blocks.length} active block(s) ====`)
        if (!blocks.length) break
        let closed = 0
        for (const b of blocks) {
            if (await closeBlock(b)) closed++
        }
        if (!closed) { console.log('no block closed this pass — aborting'); break }
    }
    const rs = JSON.parse((await api('GET', `/Requests(ID=${REQUEST_ID},IsActiveEntity=true)`,null)).body)
    console.log(`\n=== final request status = ${rs.status} ===`)
    conn.disconnect()
})().catch(e => { console.error(e); process.exit(2) })
