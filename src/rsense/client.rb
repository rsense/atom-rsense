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
      send_json = `JSON.stringify(#{{
          "command": "code_completion",
          "project": @project_path,
          "file": @editor.getPath,
          "code": @text,
          "location": {
            "row": row,
            "column": col
          }
        }})`
        @view.ajax({
          url: 'http://localhost:#{@port}',
          type: 'POST',
          contentType: 'application/json; charset=utf-8',
          dataType: 'json',
          data: send_json,
          success: cb
          })

    end

    def check_completion(view, cb)
      @view = Native(view)
      @editor = @atom.workspace.getActiveEditor()
      cursor = Native(@editor.getCursor())
      row = Native(cursor.getBufferRow)
      tbuffer = Native(@editor.getBuffer)
      col = Native(cursor.getBufferColumn)

      last_char = tbuffer.getTextInRange([[row, col -2], [row, col]])

      completions @editor, row, col, -> suggestions {
        completions = suggestions["completions"].keys

        cb.call( `null`, completions.to_n)
      }

    end

    def parse_single(line)
      matches = line.match(/^MATCH (\w*)\,/)
      if matches && matches.respond_to?(:captures)
        matches.captures.first
      end
    end

  end
end
