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
###

exports.Task =
    create: (task) ->
        out = 
            name: task.name ? ''
            description: task.description ? ''
            category: task.category ? ''
            type: 'task'
            created_at: Math.floor((new Date().getTime())/1000);
            deadline: task.deadline ? -1
            notified_at: 0
            updated_at: Math.floor((new Date().getTime())/1000);
            finished_at: -1
            priority: task.priority ? -1
            difficulty: task.difficulty ? -1 
            time: -1   
            finished: false
        return out

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