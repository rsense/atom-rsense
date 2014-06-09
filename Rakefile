# Rakefile
require 'opal'

desc "Build the Opal runtime and corelib"
task :opaljs do
  opal = Opal::Builder.build('opal')

  File.open("lib/js/opal.js", "w+") do |out|
    out << opal.to_s
  end
end

desc "Build our plugin to ./lib/js/rsense.js"
task :build => :opaljs do
  env = Opal::Environment.new
  env.append_path "src"

  File.open("lib/js/rsense.js", "w+") do |out|
    out << env["rsense"].to_s
  end
end
