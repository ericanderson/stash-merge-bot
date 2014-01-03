config = require '../conf/config'

express = require('express')
sys = require('sys')
util = require('util')
fs = require('fs')
https = require 'https'
http = require 'http'


app = module.exports = express()
server = http.createServer(app)


CaterpillarSocketIo = require ('./caterpillar_socket_io')



io = require('socket.io').listen(server, {logger: new CaterpillarSocketIo.SocketIoLogger(config.consoleLogger)})
cachingSocketIoWriteStream = new CaterpillarSocketIo.CachingSocketIoWriteStream(io)

config.logger.pipe(cachingSocketIoWriteStream)

io.sockets.on 'connection', (socket) ->
  cachingSocketIoWriteStream.logCache.forEach (entry) ->
    socket.emit 'log', entry


app.configure ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  app.use(express.logger())
  app.use(express.cookieParser())
  app.use(express.session({secret: config.sessionSecret}))
  app.use(express.static(__dirname + '/../public'));


AutoMerger = require './auto_merger'

doWork = ->
  new AutoMerger(config).perform()

pjson = require('../package.json');
program = require 'commander'

program
  .version(pjson.version)
  .option('-n, --dry-run', 'perform read-only actions')
  .option('-o, --run-once', 'don\' loop, just run once')
  .parse(process.argv)

if program.dryRun
  config.dryRun = true

config.logger.log('warn', 'DRY RUN IS ON') if config.dryRun

if program.runOnce?
  doWork()
else
  config.logger.log('info', "Scheduling work every #{config.interval}ms.")
  setInterval(doWork, config.interval)
  server.listen(parseInt(process.env.PORT || 28080))
