{Provider, Suggestion} = require "autocomplete-plus"
fuzzaldrin = require "fuzzaldrin"
{View} = require "atom"

module.exports =
class RsenseProvider extends Provider

  init: (@client) ->
    aeditor = atom.workspace.getActiveEditor()

  wordRegex: /[^\.:]*$/g

  buildSuggestions: ->
    selection = @editor?.getSelection()
    prefix = @prefixOfSelection selection

    if prefix == ""
      compls = @fetchCompletions()
    else
      compls = @completions

    suggestions = @findSuggestionsForPrefix prefix, compls
    return unless suggestions?.length
    return suggestions

  fetchCompletions: () ->
    [send_json, ajax_hash] = @client.$check_completion(View)
    View.ajax(ajax_hash).done (res) =>

      if res?.completions?.length
        return @completions = res?.completions?.map (c) =>
          c

  find_completion: (completions, word) ->
    for c in completions
      if c.name is word
        return c

  findSuggestionsForPrefix: (prefix, completions) ->
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
