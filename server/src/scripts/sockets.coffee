socket = require 'socket.io'

io = {}
id = 0

exports.init = (app) ->
    io = socket.listen app

    io.configure ()->
    io.set("transports", ["xhr-polling"])
    io.set 'polling duration', 10

    io.sockets.on 'connection', (socket) ->
        id = socket.id
        socket.emit 'news', {hello: 'world'}