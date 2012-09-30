config     = require './config'
express    = require 'express'
routes     = require './routes'
api        = require './scripts/api'
sockets    = require './scripts/sockets'


app = module.exports = express.createServer()


app.configure ->
    app.set('views', __dirname + '/views')
    app.set('view engine', 'jade')
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser()
    # app.use express.favicon(__dirname + '/../../client/gen/assets/images/favicon.ico')
    app.use(express.static(__dirname + '/../../client/gen'))
    app.use express.session({secret: "49def7e"})
    # app.use everyauth.middleware()
    app.use app.router 

app.configure 'development', ->
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
    app.use(express.errorHandler())


# Routes
app.get '/', routes.index

app.get '/api/tasks', api.get_tasks
app.get '/api/tasks/:id', api.get_task
app.post '/api/tasks', api.post_task
app.put '/api/tasks/:id', api.put_task
app.delete '/api/tasks/:id', api.delete_task

# Heroku ports or 3000
port = process.env.PORT || 3000
app.listen port, ->
    console.log 'Express server listening on port %d in %s mode', app.address().port, app.settings.env

# Initialize sockets
sockets.init app

