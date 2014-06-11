require "atom/file"

module Rsense
  class Client
    `Suggestion = require("autocomplete-plus").Suggestion`
    attr_accessor :atom, :editor, :text, :tempfile, :file, :filepath, :candidates, :settings, :rsense_port, :view

    def initialize(atom)
      @atom = atom
      @settings = @atom.config.settings
      @rsense_port = @settings.rsense.port
    end

    def completions(editor, row, col, cb)
      @editor = editor
      @candidates = []
      @text = @editor.getText
      @project_path = @atom.project.getPath()
      send_json = `JSON.stringify({
          command: "code_completion",
          project: #{@project_path},
          file: #{@editor.getPath},
          code: #{@text},
          location: {
            row: #{row + 1},
            column: #{col + 1}
          }
        })`
        `window.rview = #{send_json}`
        ajaxhash = {
          url: "http://localhost:#{@rsense_port}",
          type: 'POST',
          contentType: 'application/json; charset=utf-8',
          dataType: 'json',
          data: send_json,
          }
        `window.ajaxhash = #{ajaxhash.to_n}`
        `#{@view}.ajax(#{ajaxhash.to_n}).done(function(data) { cb(data) }).fail(function(err) { catch })`

    end

    def check_completion(view, cb)
      @view = Native(view)
      @editor = @atom.workspace.getActiveEditor()
      cursor = Native(@editor.getCursor())
      row = Native(cursor.getBufferRow)
      col = Native(cursor.getBufferColumn)

      completions @editor, row, col, -> suggestions {
        cb.call( `null`, suggestions)
      }

    end

  end
end
