module.exports =
    users:
        _id: '_design/tasks'

        # validate_doc_update: ->

        views:
            list:
                map: (doc) ->
                    if doc.type == 'task'
                        emit doc._id, doc