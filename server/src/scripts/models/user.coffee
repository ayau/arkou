db      = require '../database/api'
###
User = {
    type: 'user'
    first_name:    
    last_name:
    email:
    access_token: 
    refresh_token:
}
###

# cached
me = {}

exports.User =
    get: (callback) ->
        if me._id?
            return callback null, me
        @populateSelf (err, user) ->
            if user
                me = user
            return callback err, user
    
    save: (callback) ->
        if !me._id?
            return callback()
        db.insertUser me, (err, user) ->
            if user
                me = user
            console.log me
            return callback()

    update: (access_token, refresh_token, callback) ->
        if !me._id?
            return callback()
        me.access_token = access_token
        me.refresh_token = refresh_token
        @save () ->
            callback()

    updateToken: (access_token) ->
        if !me._id?
            return
        me.access_token = access_token
        @save () ->
            console.log 'token updated'


    create: (token, refresh_token, email, first_name, last_name) ->
        user =
            type: 'user'
            first_name: first_name
            last_name: last_name
            email: email
            token: token
            refresh_token: refresh_token
        return user

    clean: (user) ->
        user.id = user._id if user._id? && !user.id?
        delete user._id if user._id?
        delete user._rev if user._rev?
        delete user.rev if user.rev?
        delete user['access_token'] if user['access_token']?
        delete user['refresh_token'] if user['refresh_token']?
        return user

    populateSelf: (callback) ->
        db.getUser (err, user) ->
            if err
                return callback err, null
            if !user # user does not exist
                return callback null, null
            return callback null, user