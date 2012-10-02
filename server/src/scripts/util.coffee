

exports.parseGoogleDate = (d) ->
    googleDate = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.(\d{3})Z$/
    m = googleDate.exec(d)
    if m is null
        return -1
    year   = +m[1]
    month  = +m[2]
    day    = +m[3]
    hour   = +m[4]
    minute = +m[5]
    second = +m[6]
    msec   = +m[7]
    time = new Date(year, month - 1, day, hour, minute, second, msec).getTime()
    return Math.floor(time/1000)
