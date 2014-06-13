
sourceFile = "#{__dirname}/js/opal.js"

fs = require('fs')

source = fs.readFileSync(sourceFile).toString()

vm = require 'vm'
vm.runInThisContext(source)
RsenseProvider = require("./rsense-provider")
require('./js/rsense.js')

_ = require "underscore-plus"
{ProviderPackageFactory} = require "autocomplete-plus"

module.exports =
  configDefaults:
    port: 47367
    rsenseBinPath: "rsense"

  editorSubscription: null
  providers: []
  autocomplete: null

  ###
   * Registers a SnippetProvider for each editor view
  ###
  activate: ->
    @server = Opal.Rsense.Server.$new()
    @server.$start_server()
    @rsense = Opal.Rsense.Rsense.$new()
    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule
        @registerProviders()

  ###
   * Registers a SnippetProvider for each editor view
  ###
  registerProviders: ->
    @editorSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        editorView.editor.on "grammar-changed", =>
          if editorView.editor.getGrammar().scopeName.match(/source.ruby/)
            provider = new RsenseProvider editorView

            @autocomplete.registerProviderForEditorView provider, editorView

            @providers.push provider
            @rsense.$add_provider(provider)

  ###
   * Cleans everything up, unregisters all SnippetProvider instances
  ###
  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null

    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider
    @rsense.$clear_providers()

    @providers = []
    @server.stop_server
