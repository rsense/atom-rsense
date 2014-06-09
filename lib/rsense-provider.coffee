{Provider, Suggestion} = require "autocomplete-plus"
fuzzaldrin = require "fuzzaldrin"
{View} = require "atom"

module.exports =
class RsenseProvider extends Provider

  init: (@client) ->
    aeditor = atom.workspace.getActiveEditor()
    aeditor.getBuffer().on "contents-modified", (e) =>
      @fetchCompletions()

  wordRegex: /(\b\w*[a-zA-z1-9:.]\w*\b|[a-zA-z1-9:.])/g
  buildSuggestions: ->
    selection = @editor?.getSelection()
    prefix = @prefixOfSelection selection
    return unless prefix.length

    suggestions = @findSuggestionsForPrefix prefix
    return unless suggestions?.length
    return suggestions

  fetchCompletions: () ->
    @completions = []
    @client.$check_completion View, (err, res) =>
      @completions = res

  findSuggestionsForPrefix: (prefix) ->
    # Get rid of the leading @
    #prefix = prefix.replace /^::/, ''

    # Filter the words using fuzzaldrin
    if @completions?.length

      words = fuzzaldrin.filter @completions, prefix
      @completions = []

      # Builds suggestions for the words
      suggestions = for word in words when word isnt prefix
        new Suggestion this, word: word, prefix: prefix, label: "@#{word}"

      return suggestions
