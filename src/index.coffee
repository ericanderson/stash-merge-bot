
express = require('express')
sys = require('sys')
util = require('util')
fs = require('fs')
https = require 'https'
config = require '../conf/config'

app = module.exports = express()

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  app.use(express.logger())
  app.use(express.cookieParser())
  app.use(express.session({secret: config.sessionSecret}))

app.get('/', (request, response) ->

)

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

if program.once
  doWork()
else
  config.logger.log('info', "Scheduling work every #{config.interval}ms.")
  setInterval(doWork, config.interval)
  app.listen(parseInt(process.env.PORT || 28080))
