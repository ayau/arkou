sockets = require './sockets'
{resp}  = require './response'
db      = require './database/api'
{Task}  = require './models/task'


# GET /tasks/:id
exports.get_task = (req, res) ->
    id = req.params.id
    db.getTask id, (err, task) ->
        if err
            return resp.error res, resp.INTERNAL, err
        task = Task.clean task
        res.send task

# GET /tasks
exports.get_tasks = (req, res) ->
    db.getTasks (err, rows) ->
        if err
            return resp.error res, resp.INTERNAL, err
        tasks = Task.list rows
        res.send tasks

# POST /tasks
exports.post_task = (req, res) ->
    task = Task.create req.body
    db.insertTask task, (err, task) ->
        if err
            return resp.error res, resp.INTERNAL, err
        console.log 'TASK CREATED'
        res.send task

# PUT /tasks/:id
exports.put_task = (req, res) ->
    id = req.params.id
    new_task = req.body
    if !new_task?
        return resp.error res, resp.BAD, 'task not provided'       
    db.getTask id, (err, task) ->
        if err
            return resp.error res, resp.INTERNAL, err
        task = Task.update task
        res.send task

# DELETE /tasks/:id
exports.delete_task = (req, res) ->
    id = req.params.id