require "native"

module Rsense
  module Utils

    def check_scope(editor)
      scopes = scopes_list(editor)
      scopes.any? do |scope|
        scope.match(/source\.ruby/)
      end
    end

    def scopes_list(editor)
      @editor = Native(editor)
      point = Native(@editor.getCursorBufferPosition())
      @editor.scopesForBufferPosition(point)
    end

    def editor
      @editor
    end

    module_function :check_scope
    module_function :scopes_list
    module_function :editor

  end
end
