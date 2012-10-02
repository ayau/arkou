module.exports =
    users:
        _id: '_design/users'

        views:
            get:
                map: (doc) ->
                    if doc.type is 'user'
                        emit doc._id, doc
    tasks:
        _id: '_design/tasks'

        # validate_doc_update: ->

        views:
            list:
                map: (doc) ->
                    if doc.type is 'task'
                        emit doc._id, doc