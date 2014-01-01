AutoMergerEntry = require './auto_merger_entry'
Stash = require 'astash'

class AutoMerger
  constructor: (@config) ->
    @stash = new Stash(@config.stash)

  perform: ->
    @config.autoMerge.forEach (entry) =>
      new AutoMergerEntry(@stash, entry, entry.logger || @config.logger).perform()

exports = module.exports = AutoMerger