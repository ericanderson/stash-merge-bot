stream = require 'stream'

###
A logger to pass to Socket IO v0.9
###
class SocketIoLogger
  constructor: (@logger) ->

  log: (level, moar...) ->
    @logger.log(level, moar...)

['debug', 'info', 'warn', 'error'].forEach (level) ->
  SocketIoLogger.prototype[level] = ->
    @log.apply(this, [level, "SOCKETIO: "].concat(Array.prototype.slice.call(arguments)))

###
A stream for outputting json text as socket io messages
###
class CachingSocketIoWriteStream extends stream.Writable
  constructor: (@io) ->
    @logCache = []
    super

  _write: (chunk, encoding, callback) ->
    entry = JSON.parse(chunk.toString())
    @io.sockets.emit('log', entry)
    @logCache.push(entry)
    @logCache.shift() while @logCache.length > 35
    callback()

exports = module.exports = {
  CachingSocketIoWriteStream: CachingSocketIoWriteStream
  SocketIoLogger: SocketIoLogger
}