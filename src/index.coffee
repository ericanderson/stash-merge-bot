
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


new AutoMerger(config).perform()

app.listen(parseInt(process.env.PORT || 28080))