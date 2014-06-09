require "atom/atom"
require "atom/buf_process"
require "atom/file"
require "atom/config"

module Rsense
  module Server
    module_function
    @atom = Atom::Atom.new
    @settings = @atom.config.settings

    def process_env_vars
      @rsense_port = @rsense_port || @settings.rsense.port
      @project_path = @project_path || @atom.project.getPath()
    end

    def start_server
      stop_server()
      process_env_vars()

      rsense_bin = @settings.rsense.rsenseBinPath
      command = "#{rsense_bin}"
      args = ["start", "--port", @rsense_port]
      stdout = -> output {
        `console.log(#{output})`
      }
      myexit = -> code {
        `console.log(#{code})`
      }
      buffer = Atom::BufProcess.new(command, args, stdout, myexit)
    end

    def stop_server
      rsense_bin = @settings.rsense.rsenseBinPath
      command = "#{rsense_bin}"
      args = ["stop"]
      stdout = -> output {
        #
      }
      myexit = -> code {
        #
      }
      buffer = Atom::BufProcess.new(command, args, stdout, myexit)
    end
  end
end
