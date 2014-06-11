{Provider, Suggestion} = require "autocomplete-plus"
fuzzaldrin = require "fuzzaldrin"
{View} = require "atom"

module.exports =
class RsenseProvider extends Provider

  init: (@client) ->
    aeditor = atom.workspace.getActiveEditor()
    aeditor.getBuffer().on "contents-modified", (e) =>
      @fetchCompletions()

  wordRegex: /[^\.:]*$/g
  @completions = []
  buildSuggestions: ->
    selection = @editor?.getSelection()
    prefix = @prefixOfSelection selection
    for x in [1..20000000]
      x

    suggestions = @findSuggestionsForPrefix prefix
    return unless suggestions?.length
    return suggestions

  fetchCompletions: () ->
    @client.$check_completion View, (err, res) =>
      if res?.completions?.length
        @completions = res?.completions?.map (c) =>
          c

  find_completion: (completions, word) ->
    for c in completions
      if c.name is word
        return c

  findSuggestionsForPrefix: (prefix) ->
    # Filter the words using fuzzaldrin
    if @completions?.length
      names = @completions.map (c) =>
        c.name

      words = fuzzaldrin.filter names, prefix

      # Builds suggestions for the words
      suggestions = for word in words when word isnt prefix
        completion = @find_completion(@completions, word)
        new Suggestion this, word: word, prefix: prefix, label: "#{completion.qualified_name} #{completion.kind}"

      return suggestions
