###
task = {
    name: (name of task)
    description: (description of task)
    category: (ie cis391)
    type: 'task'
    created_at: (datetime the task was created at)
    deadline: (datetime scheduled to be completed by)
    notified_at: (datetime last notified/reminded client)
    updated_at:
    finished_at:
    priority: (the calculated priority of this task)
    difficulty: (estimated difficulty of task) 
    time: (estimated time it will take)   
    finished: (boolean)
}
https://developers.google.com/google-apps/tasks/v1/reference/tasks#resource
gTask = {
    id:
    title:
    position:
    notes:
    status: 'completed' / 'needsAction'
    updated:
    due:
    completed:
}
###
util = require '../util'
db   = require '../database/api'

exports.Task =

    create: (task) ->
        out = 
            name: task.name
            description: task.description
            category: task.category
            deadline: task.deadline
            priority: task.priority
            difficulty: task.difficulty
        return validate out

    createFromGoogle: (gTask) ->
        out = 
            name: gTask.title
            description: gTask.notes
            deadline: util.parseGoogleDate gTask.due
            updated_at: util.parseGoogleDate gTask.updated
            finished: gTask.status is 'completed'
            _id: gTask.id
        if gTask.completed?
            out.finished_at = util.parseGoogleDate gTask.completed 
        return validate out

    updateFromGoogle: (task, gTask, callback) ->
        task.name = gTask.title
        task.description = gTask.notes
        task.deadline = util.parseGoogleDate gTask.due
        task.updated_at = util.parseGoogleDate gTask.updated
        task.finished = gTask.status is 'completed'
        if gTask.completed?
            task.finished_at = util.parseGoogleDate gTask.completed
        @save task, () ->
            callback()

    save: (task, callback) ->
        db.insertTask task, (err, task) ->
            return callback()

    clean: (task) ->
        task.id = task._id if task._id? && !task.id?
        delete task._id if task._id?
        delete task._rev if task._rev?
        delete task.rev if task.rev?
        return task

    list: (rows) ->
        tasks = []
        for r in rows
            task = @clean r.value
            tasks.push task
        return tasks

def =
    name: 'untitled'
    description: ''
    category: ''
    type: 'task'
    deadline: -1
    notified_at: 0
    finished_at: -1
    priority: -1
    difficulty: -1 
    time: -1   
    finished: false

validate = (task) ->
    task.name        = def.name if !task.name? || task.name is ''
    task.description = def.descriptoin if !task.description?
    task.category    = def.category if !task.category?
    task.type        = def.type
    task.deadline    = def.deadline if !task.deadline?
    task.created_at  = Math.floor((new Date().getTime())/1000)
    task.notified_at = def.notified_at if !task.notified_at?
    task.updated_at  = Math.floor((new Date().getTime())/1000) if !task.updated_at?
    task.finished_at = def.finished_at if !task.finished_at?
    task.priority    = def.priority if !task.priority?
    task.difficulty  = def.difficulty if !task.difficulty?
    task.time        = def.time if !task.time?
    task.finished    = def.finished if !task.finished?
    return task