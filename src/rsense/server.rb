require "atom/atom"
require "atom/buf_process"
require "atom/file"
require "atom/config"
require "atom/process"

module Rsense
  class Server
    attr_accessor :atom, :settings, :start_path, :process

    def initialize
      @atom = Atom::Atom.new
      @settings = @atom.config.settings
      @process = Atom::Process.new
    end

    def process_env_vars
      @rsense_port = @rsense_port || @settings.rsense.port
      @project_path = @project_path || @atom.project.getPath()
      @start_path = @process.cwd()
    end

    def start_server
      process_env_vars()
      stop_server()

      rsense_bin = @settings.rsense.rsenseBinPath
      command = "#{rsense_bin}"
      args = ["start", "--port", @rsense_port]
      stdout = -> output {
        `console.log(#{output})`
      }
      myexit = -> code {
        `console.log("Rsense Started on port " + #{@rsense_port})`
        #`console.log(#{code})` unless code == 0
      }
      @process.chdir(@project_path)
      buffer = Atom::BufProcess.new(command, args, stdout, myexit)
      @process.chdir(@start_path)
    end

    def stop_server
      rsense_bin = @settings.rsense.rsenseBinPath
      command = "#{rsense_bin}"
      args = ["stop"]
      stdout = -> output {
        `console.log("Rsense Server Stopped")`
        `console.log(#{output})`
      }
      myexit = -> code {
        #`console.log(#{code})`
      }

      @process.chdir(@project_path)
      buffer = Atom::BufProcess.new(command, args, stdout, myexit)
      @process.chdir(@start_path)
    end
  end
end
