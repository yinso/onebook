path    = require 'path'
fs = require '../shared/fs'
BASE    = path.join(__dirname, '..')

# Module dependencies.
express = require 'express'
http = require 'http'
{makeCompiler, coffee} = require './compiler'
sass = require 'node-sass'
amdee = require 'amdee'

User = require '../src/user'
SessionMaker = require '../src/session'
SessionStore = require '../src/sessionstore'
Database = require '../src/connection'
uuid = require '../shared/uuid'
qs = require 'querystring'
app = express()

storeMaker = (app, cb) ->
  conn = Database.get 'default'
  cb null, new SessionStore conn

signedSecret = 'this-is-the-secret'

env = process.env.NODE_ENV || 'development'

baseErrorHandler = (options) ->
  (err, req, res, next) ->
    console.log '**********************************************************************'
    console.log 'REQUEST_ERROR: ', req.method, req.url, err
    console.log '**********************************************************************'
    if err.status
      res.statusCode = err.status
    if err.statusCode < 400
      res.statusCode = 500 # ??? why?
    if 'prod' != env
      console.error err.stack
    accept = req.headers.accept or ''
    res.json err.status, err

baseConfigure = () ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', path.join(BASE,"views")
  app.set 'view engine', 'hbs'
  app.set 'baseUrl', process.env.BASE_URL || 'http://FIXME'
  app.set 'projectRoot', path.join(process.env.HOME, 'bookish') # how to get this value?

  app.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
    next()

  # serve static files first to avoid unnecessary dynamic processing.
  app.use '/img', express.static path.join(BASE, 'public/img')
  #app.use '/js', express.static path.join(BASE, 'public/js')
  handler = express.static path.join(BASE, 'public/js')
  app.use '/js', (req, res) ->
    console.log req.method, req.url
    handler req, res
  app.use '/views', express.static path.join(BASE, 'public/views')
  app.use '/editor', express.static path.join(BASE, 'public/editor')
  #app.use sass.middleware # need to be careful about these precompilers
  #  src: path.join(BASE)
  #  dest: path.join(BASE, 'public')
  #  debug: true
  app.use '/css', express.static path.join(BASE, 'public/css')

  #if process.env.NODE_ENV != 'test'
  #  app.use express.logger('dev')

  app.use express.favicon()
  app.use express.cookieParser signedSecret
  app.use express.bodyParser(keepExtensions: true, hash: 'sha256')

  # database-related work.
  app.use (req, res, next) ->
    req.connection = Database.get 'default'
    next()
  
  app.use SessionMaker app, storeMaker, secret: signedSecret, cookieID: 'bookish.sid', timeoutDuration: 86400 * 7

  app.use User.sessionLoad


  #app.use makeCompiler
  #  prefix: '/js'
  #  srcDir: './client'
  #  destDir: './public'
  #  inner: coffee

  app.use express.methodOverride()
  app.use app.router
  app.use baseErrorHandler({showStack: true, dumpExceptions: true})

devConfigure = () ->
  app.use express.errorHandler({showStack: true, dumpExceptions: true})

app.configure baseConfigure
app.configure 'development', devConfigure

process.on 'exit', () ->
  #app.close()
  #conn.disconnect()

routesPath = path.join BASE, 'routes'
files = fs.readdirSync routesPath

for file in files
  module = path.basename file, path.extname(file)
  filePath = path.join(BASE, 'routes', module)
  route = require filePath
  route.init app, (if module == 'index' then '/' else "/#{module}")

http.createServer(app).listen app.get('port'), () ->
  Database.load 'mongoquery.json', (err) ->
    if err
      console.log 'Fail to connect against DATABASE'
      process.exit()
    else
      conn = Database.get 'default'
      # I want to specify that the database conn is used for the SessionStore connection?
      # how do I do that here?
      console.log 'before request'
      conn.query 'getSessions', {}, (err, records) =>
        app.set 'connection', conn
        console.log "Bookish running on PORT=#{app.get('port')}"
        console.log "getSession result", records

module.exports = app

