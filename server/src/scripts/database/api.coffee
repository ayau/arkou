config     = require '../../config'
nano       = require('nano')(config.database.endpoint)
db         = nano.use config.database.name


exports.getTask = (id, callback) ->
    db.get id, {}, (err, body) ->
        if err
            return callback err, null
        if body.type isnt 'task'
            return callback {error: 'id is not a task'}, null
        return callback null, body

exports.getTasks = (callback) ->
    db.view 'tasks', 'list', (err, body) ->
        if err
            return callback err, null
        return callback null, body.rows

exports.insertTask = (task, callback) ->
    db.insert task, (err, header, body) ->
        if err
            return callback err, null
        task.id = header.id
        task.rev = header.rev
        return callback null, task