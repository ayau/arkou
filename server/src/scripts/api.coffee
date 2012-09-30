sockets = require './sockets'
{resp}  = require './response'
db      = require './database/api'
{Task}  = require './models/task'

# GET /tasks
exports.get_tasks = (req, res) ->
    db.getTasks (err, rows) ->
        if err
            return resp.error res, resp.INTERNAL, err
        tasks = Task.list rows
        res.send tasks

# GET /tasks/:id
exports.get_task = (req, res) ->
    id = req.params.id

# POST /tasks
exports.post_task = (req, res) ->
    
    console.log 'here'
    task = Task.create req.body
    db.insertTask task, (err, task) ->
        if err
            return resp.error res, resp.INTERNAL, err
        console.log 'TASK CREATED'
        res.send task


# PUT /tasks/:id
exports.put_task = (req, res) ->
    id = req.params.id

# DELETE /tasks/:id
exports.delete_task = (req, res) ->
    id = req.params.id