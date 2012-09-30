config     = require '../../config'
nano       = require('nano')(config.database.endpoint)
db         = nano.use config.database.name


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