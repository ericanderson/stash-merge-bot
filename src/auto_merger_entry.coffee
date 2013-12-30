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
    if @config.draftRegex && pr.description.match(@config.draftRegex)
      return false

    if @config.requiredApprovers == null || @config.requiredApprovers.length == 0
      return true

    count = 0
    @config.minRequiredApprovers ?= @config.requiredApprovers.length
    pr.reviewers.forEach (reviewer) =>
      if reviewer.approved and reviewer.user.name in @config.requiredApprovers
        count += 1

    @logger.log('info', "#{pr.shortName()} (#{count} of #{@config.minRequiredApprovers} present)")

    return (count >= @config.minRequiredApprovers)

module.exports = exports = AutoMergerEntry