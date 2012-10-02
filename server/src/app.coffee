config     = require './config'
express    = require 'express'
routes     = require './routes'
api        = require './scripts/api'
sockets    = require './scripts/sockets'
everyauth  = require 'everyauth'
{resp}     = require './scripts/response'

cronJob    = require('cron').CronJob
cron       = require './scripts/cron'

app = module.exports = express.createServer()

sessions = {}

everyauth.google
    .appId(config.google.id)
    .appSecret(config.google.secret)
    .entryPath('/auth/google')
    .callbackPath('/oauth2callback')
    .authQueryParam({ access_type:'offline', approval_prompt:'force' })
    .scope('https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/tasks') # What you want access to
    .handleAuthCallbackError( (req, res) ->
        # If a user denies your app, Google will redirect the user to
        # /auth/google/callback?error=access_denied
        # This configurable route handler defines how you want to respond to
        # that.
        # If you do not configure this, everyauth renders a default fallback
        # view notifying the user that their authentication failed and why.
    ).findOrCreateUser( (session, accessToken, accessTokenExtra, googleUserMetadata) ->
        # accessTokenExtra.expires_in
        refresh_token = accessTokenExtra.refresh_token
        email = googleUserMetadata.email
        if email isnt 'alexyauyang@gmail.com'
            return
        first_name = googleUserMetadata.given_name
        last_name = googleUserMetadata.family_name
        userPromise = @Promise()
        api.login accessToken, refresh_token, email, first_name, last_name, (err, user) ->
            return userPromise.fail 'promise failed!?' if err || !user?
            userPromise.fulfill user
            sessions[user.id] = user
        return userPromise
    ).redirectPath('/')

everyauth.everymodule.findUserById (req, userId, callback) ->
    callback null, sessions[userId]

app.configure ->
    app.set('views', __dirname + '/views')
    app.set('view engine', 'jade')
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser()
    # app.use express.favicon(__dirname + '/../../client/gen/assets/images/favicon.ico')
    app.use(express.static(__dirname + '/../../client/gen'))
    app.use express.session({secret: "49def7e"})
    app.use everyauth.middleware()
    app.use app.router 

app.configure 'development', ->
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
    app.use(express.errorHandler())

authenticate = (req, res, next) ->
    if !req.user?
        resp.error res, resp.UNAUTHORIZED, 'unauthorized'
    else
        next()

# Routes
app.get '/', routes.index

app.get '/api/me', authenticate, api.get_me

app.get '/api/tasks/:id', api.get_task
app.get '/api/tasks', api.get_tasks
app.post '/api/tasks', api.post_task
app.put '/api/tasks/:id', api.put_task
app.delete '/api/tasks/:id', api.delete_task

# Heroku ports or 3000
port = process.env.PORT || 3000
app.listen port, ->
    console.log 'Express server listening on port %d in %s mode', app.address().port, app.settings.env

# Initialize sockets
sockets.init app

tasks = require './scripts/services/tasks'
# Set up cron jobs
# seconds, minute, hour, day of month, month, day of week
# job = new cronJob {
#     cronTime: '*/5 * * * * *'
#     onTick: () ->
#         tasks.checkUpdates()
#     start: true
# }

refreshTokens = new cronJob {
    cronTime: '0 0/30 * * * *'
    # cronTime: '*/5 * * * * *'
    onTick: () ->
        cron.refreshTokens()
    start: true
}
