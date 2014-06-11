module Atom
  class Process
    include Native
    native_accessor :stdin, :stdout, :stderr, :argv, :execPath, :execArgv, :env,
                    :version, :versions, :config, :pid, :title, :arch,
                    :platform,

    def initialize
      super(`process`)
    end

    alias_native :cwd
    alias_native :chdir

  end
end
