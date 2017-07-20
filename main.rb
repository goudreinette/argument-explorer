require 'yaml'
require 'slim'
require 'kwstruct'
require 'require_all'
require 'pathname'
require 'active_support/hash_with_indifferent_access'
require_all 'source'


Argument = KwStruct.new(:path, :name, :branch, :theory, :philosopher,
                        :publication, :year, :counterarguments,
                        :description, :structure)


def arguments
  Dir["./content/*.yaml"].map do |path|
    Argument.new(path: Pathname.new(path).basename.sub_ext(''),
                 **YAML.load(File.read(path)).symbolize_keys)
  end
end

def build
  puts "Building..."
  arguments.each do |arg|
    File.write("./dist/#{arg.path}.html",
      Slim::Template.new('views/argument.slim', {}).render(arg))
  end
end


build
