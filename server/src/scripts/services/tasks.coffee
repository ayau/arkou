https  = require 'https'
db     = require '../database/api'
util   = require '../util'
{Task} = require '../models/task'

task_lists = []
last_processed = 0 # should really store last processed instead of resyncing everything when server resetarts
waiting = 0

exports.checkUpdates = checkUpdates = (retry = false) ->
    if task_lists.length is 0
        if retry # if already checked
            return
        return get_task_lists () ->
            checkUpdates true

    for id in task_lists
        get_tasks id, (tasks) ->
            updateDB tasks

updateDB = (tasks) ->
    waiting = tasks.length
    for t in tasks
        if util.parseGoogleDate(t.updated) > last_processed
            updateTask t
        else
            complete()

updateTask = (t) ->
    db.getTask t.id, (err, task) ->
        if !task
            # don't sync if already completed
            if t.status is 'completed'
                return complete()
            task = Task.createFromGoogle t
            Task.save task, () ->
                complete()
        else
            Task.updateFromGoogle task, t, () ->
                complete()

complete = () ->
    waiting -= 1
    if !waiting
        console.log 'google tasks updated'
        last_processed = Math.floor((new Date().getTime())/1000)

get_task_lists = (callback) ->
    db.getUser (err, user) ->
        if err
            console.log err
            return callback()
        options = 
            host: 'www.googleapis.com'
            path: '/tasks/v1/users/@me/lists'
            method: 'GET'
            headers:
                Authorization: 'OAuth ' + user.access_token
        sendRequest options, null, (json) ->
            console.log json
            for l in json.items
                task_lists.push l.id
            return callback()

get_tasks = (task_list, callback) ->
    db.getUser (err, user) ->
        if err
            console.log err
            return callback null
        options =
            host: 'www.googleapis.com'
            path: '/tasks/v1/lists/' + task_list + '/tasks'
            method: 'GET'
            headers:
                Authorization: 'OAuth ' + user.access_token
        sendRequest options, null, (json) ->
            callback json.items

sendRequest = (options, body, callback) ->
    req = https.request options, (res) ->
        out = ''
        res.on 'data', (chunk) ->
            out = out + chunk
        res.on 'end', () ->
            json = JSON.parse out
            callback json
    if body
        req.write body
    req.end()


