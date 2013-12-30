vows = require 'vows'
assert = require 'assert'

AutoMergerEntry = require '../src/auto_merger_entry'

suite = vows.describe 'AutoMergerEntry'

SILENT_LOGGER = {
  log: ->
}

createReviewer = (name, approved=true) ->
  {
    approved: approved
    user: {name: name}
  }

pr = (reviewers=[], description="") ->
  return {
    reviewers: reviewers
    shortName: -> ""
    description: description
  }

suite.addBatch({
  'a project with three reviewers, requiring one': {
    topic: ->
      stash = {}
      config = {
        project: 'SOMEPROJECT'
        repo: 'some-repo'
        requiredApprovers: ['alice', 'bob', 'carol']
        minRequiredApprovers: 1
        draftRegex: /\===DRAFT===/
      }
      ame = new AutoMergerEntry(stash, config, SILENT_LOGGER)

      ame._pullRequestPassesRequirements.bind(ame)

    'doesnt merge with no reviewers': (passes) ->
      assert !passes(pr([
      ]))

    'doesnt merge with no required reviewers': (passes) ->
      assert !passes(pr([
        createReviewer('cow')
      ]))

    'doesnt merge with reviwers who havent approved': (passes) ->
      assert !passes(pr([
        createReviewer('alice', false)
      ]))

    'merges with one reviwer who has approved': (passes) ->
      assert passes(pr([
        createReviewer('alice', false),
        createReviewer('bob')
      ]))

    'doesnt merge with one reviewer who has approved and is a draft': (passes) ->
      assert !passes(pr([
        createReviewer('alice', false)
      ], "===DRAFT==="))
  }

})

suite.export(module)