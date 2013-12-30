
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

stash = new Stash(config.stash)

config.autoMerge.forEach (entry) ->
  logger = entry.logger || config.logger
  logger.log("info", "Fetching pull requests for #{entry.project}/#{entry.repo}")

  allPullRequestsPromise = stash.eachPullRequest(entry.project, entry.repo, (pr) ->
    logger.log('debug', "Checking if stash will allow us to merge #{pr.shortName()}")

    pr.canMerge().then((result) ->
      if result.canMerge
        approved = false
        if entry.requiredApprovers == null || entry.requiredApprovers.length == 0
          approved = true
        else
          count = 0
          entry.minRequiredApprovers ?= entry.requiredApprovers.length
          pr.reviewers.forEach (reviewer) ->
            if reviewer.approved and reviewer.user.name in entry.requiredApprovers
              count += 1

          if (count >= entry.minRequiredApprovers)
            approved = true

        logger.log('info', "#{pr.shortName()} (#{count} of #{entry.minRequiredApprovers} present), approved: #{approved}")

        if approved
          1+1
          #pr.attemptMerge().done()
      else
        logger.log('info', "#{pr.shortName()} does not meet stash's requirements for merge.")
    )
  )

  allPullRequestsPromise.done(->
    logger.log('debug', "Finished iterating through pages for #{entry.project}/#{entry.repo}")
  )

#app.listen(parseInt(process.env.PORT || 8080));