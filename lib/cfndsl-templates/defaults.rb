require 'yaml'
require 'recursive-open-struct'

def defaults
  RecursiveOpenStruct.new(YAML::load(File.open('config/defaults.yml')))
end
