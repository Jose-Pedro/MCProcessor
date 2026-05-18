const isSameDayLocal = (ts1, ts2) => {
    let d1 = new Date(ts1)
    let d2 = new Date(ts2)
    return  d1.getFullYear() === d2.getFullYear() &&
            d1.getMonth() === d2.getMonth() &&
            d1.getDate() === d2.getDate()
}

module.exports = {
    isSameDayLocal
}