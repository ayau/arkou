https   = require 'https'
{User}  = require './models/user'
config  = require '../config'
querystring = require 'querystring'

exports.refreshTokens = () ->
    User.get (err, user) ->
        if !user
            return # error fetching user
        body = 
            refresh_token: user.refresh_token
            client_id: config.google.id
            client_secret: config.google.secret
            grant_type: 'refresh_token'
        body = querystring.stringify body
        options =
            host: 'accounts.google.com'
            path: '/o/oauth2/token'
            method: 'POST'
            headers:
                'Content-Type': 'application/x-www-form-urlencoded'
                'Content-length': body.length

        sendRequest options, body, (json) ->
            if json.access_token?
                User.updateToken json.access_token

sendRequest = (options, body, callback) ->
    req = https.request options, (res) ->
        out = ''
        res.on 'data', (chunk) ->
            out = out + chunk
        res.on 'end', () ->
            json = JSON.parse out
            callback json
    req.write(body)
    req.end()