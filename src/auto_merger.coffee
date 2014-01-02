AutoMergerEntry = require './auto_merger_entry'
Stash = require 'astash'

class AutoMerger
  constructor: (@config) ->
    @stash = new Stash(@config.stash)
    @dryRun = config.dryRun || false

  perform: ->
    @config.autoMerge.forEach (entry) =>
      new AutoMergerEntry(@stash, entry, entry.logger || @config.logger, @dryRun).perform()

exports = module.exports = AutoMerger