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

    def completions(editor, row, col)
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

        ajaxhash = {
          url: "http://localhost:#{@rsense_port}",
          type: 'POST',
          contentType: 'application/json; charset=utf-8',
          dataType: 'json',
          data: send_json,
          }
        [send_json, ajaxhash.to_n]
    end

    def check_completion(view)
      @view = Native(view)
      @editor = @atom.workspace.getActiveEditor()
      cursor = Native(@editor.getCursor())
      row = Native(cursor.getBufferRow)
      col = Native(cursor.getBufferColumn)

      completions(@editor, row, col)
    end

  end
end
