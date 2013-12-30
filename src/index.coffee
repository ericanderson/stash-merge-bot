
express = require('express')
sys = require('sys')
util = require('util')
fs = require('fs')
https = require 'https'
Stash = require 'astash'
config = require '../conf/config'

app = module.exports = express()

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
  app.use(express.logger());
  app.use(express.cookieParser());
  app.use(express.session({secret: config.sessionSecret}));

app.get('/', (request, response) ->

)

class AutoMerger
  constructor: (@config) ->
    @stash = new Stash(config.stash)

  perform: ->
    config.autoMerge.forEach (entry) =>
      new AutoMergerEntry(@stash, entry, entry.logger || config.logger).perform()

class AutoMergerEntry
  constructor: (@stash, @config, @logger) ->

  perform: ->
    @logger.log("info", "Fetching pull requests for #{@config.project}/#{@config.repo}")

    @stash.eachPullRequest(@config.project, @config.repo, (pr) =>
      @_performPullRequest(pr)
    ).done( =>
      @logger.log('debug', "Finished iterating through pages for #{@config.project}/#{@config.repo}")
    )

  _performPullRequest: (pr) ->
    @logger.log('debug', "Checking if stash will allow us to merge #{pr.shortName()}")

    pr.canMerge().then((result) =>
      if result.canMerge and @_pullRequestPassesRequirements(pr)
        pr.attemptMerge().done()
      else
        @logger.log('info', "#{pr.shortName()} does not meet requirements for merge.")
    )

  _pullRequestPassesRequirements: (pr) ->
    if @config.requiredApprovers == null || @config.requiredApprovers.length == 0
      return true

    count = 0
    @config.minRequiredApprovers ?= @config.requiredApprovers.length
    pr.reviewers.forEach (reviewer) =>
      if reviewer.approved and reviewer.user.name in @config.requiredApprovers
        count += 1

    @logger.log('info', "#{pr.shortName()} (#{count} of #{@config.minRequiredApprovers} present)")

    return (count >= @config.minRequiredApprovers)

new AutoMerger(config).perform()

#app.listen(parseInt(process.env.PORT || 8080));