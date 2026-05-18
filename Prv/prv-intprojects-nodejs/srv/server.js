const cds = require('@sap/cds')

// Local-dev patch: tolerate ISO timestamps already ending in 'Z'.
// Our HANA tables store timestamps as NVARCHAR (e.g. "2026-05-11T17:57:02.183Z"),
// but the CDS HANA converters assume native HANA TIMESTAMP format (no 'Z') and
// blindly append 'Z' before constructing a Date, producing "...ZZ" -> Invalid time value.
try {
    const conversion = require('@sap/cds/libx/_runtime/hana/conversion')
    const map = conversion.HANA_TYPE_CONVERSION_MAP
    const safeISO = (element) => {
        if (!element) return null
        const s = String(element)
        const dateTime = s.replace(' ', 'T')
        const candidate = dateTime.endsWith('Z') ? dateTime : dateTime + 'Z'
        const d = new Date(candidate)
        if (isNaN(d.getTime())) return null
        return d.toISOString()
    }
    const safeISONoMillis = (element) => {
        if (!element) return null
        const iso = safeISO(element)
        if (!iso) return null
        return iso.slice(0, 19) + iso.slice(23)
    }
    map.set('cds.Timestamp', safeISO)
    map.set('cds.DateTime', safeISONoMillis)
    console.log('[server] patched HANA_TYPE_CONVERSION_MAP for cds.Timestamp/cds.DateTime')
} catch (e) {
    console.error('[server] failed to patch HANA conversion map:', e.message)
}

module.exports = cds.server
