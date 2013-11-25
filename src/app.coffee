path    = require 'path'
fs = require 'fs'
BASE    = path.join(__dirname, '..')
express = require 'express'
http = require 'http'
{ncp} = require 'ncp'

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

signedSecret = 'this-is-the-secret'

baseConfigure = (app, basePath) ->
  app.set 'port', process.env.PORT || 3030
  app.set 'baseUrl', process.env.BASE_URL || 'http://FIXME'

  app.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
    next()

  # serve static files first to avoid unnecessary dynamic processing.
  app.use '/img', express.static path.join(basePath, 'img')
  app.use '/js', express.static path.join(basePath, 'js')
  app.use '/css', express.static path.join(basePath, 'css')
  app.use '/content', express.static path.join(basePath, 'content')
  app.use express.favicon()
  app.use express.cookieParser signedSecret
  app.use express.bodyParser(keepExtensions: true, hash: 'sha256')
  app.use express.methodOverride()
  app.use app.router
  app.use baseErrorHandler({showStack: true, dumpExceptions: true})

devConfigure = (app) ->
  app.use express.errorHandler({showStack: true, dumpExceptions: true})

initRoutes = (app) ->
  routesPath = path.join BASE, 'routes'
  files = fs.readdirSync routesPath

  for file in files
    module = path.basename file, path.extname(file)
    filePath = path.join(BASE, 'routes', module)
    route = require filePath
    route.init app, (if module == 'index' then '/' else "/#{module}")

run = (basePath) ->
  app = express()

  baseConfigure app, basePath
  devConfigure app
  initRoutes app
  http.createServer(app).listen app.get('port')

init = (basePath) ->
  # just copy all of the files from public over to basePath.
  ncp path.join(BASE, 'public'), basePath, (err) ->
    if err
      console.error "onebook init failed", err
    else
      console.log "onebook init success. Run onebook and point browser to http://localhost:3030"

module.exports =
  run: run
  init: init

