exports.resp =
    UNAUTHORIZED: 401
    NOT_FOUND: 204
    INTERNAL: 500
    BAD: 400
    FORBIDDEN: 403
    CONFLICT: 409
    CREATED: 201
    OK: 200

    success: (res, msg) ->
        res.status @OK
        res.send {status: @OK, success: msg}

    error: (res, code, msg) ->
        res.status code
        res.send {status: code, error: msg}