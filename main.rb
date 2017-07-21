require 'yaml'
require 'slim'
require 'attr_extras'
require 'require_all'
require 'pathname'
require 'fileutils'
require 'active_support/hash_with_indifferent_access'
require_all 'source'


# Shared
def load_yaml_folder(folder, struct)
  Dir["./content/#{folder}/*.yaml"].map do |path|
    struct.new(path: Pathname.new(path).basename.sub_ext(''),
                 **YAML.load(File.read(path)).symbolize_keys)
  end
end


class Argument
  attr_accessor_initialize [:path, :name,
                            :branch, :theory,
                            :philosopher,
                            :publication, :year,
                            :counterarguments,
                            :description, :structure]

  def self.all
    load_yaml_folder "arguments", Argument
  end
end



class Theory
  attr_accessor_initialize [:path, :name, :description]

  def self.all
    load_yaml_folder "theories", self
  end

  def arguments
    Argument.all.select { |a| a.theory == name }
  end
end



# Build
def build_theories
  Theory.all.each do |theory|
    path = "./dist/theories/#{theory}"
    File.write(path,
      Slim::Template.new('views/theory.slim', {}).render(theory))
  end
end


def build_arguments
  Argument.all.each do |arg|
    path = "./dist/arguments/#{arg.path}.html"
    File.write(path,
      Slim::Template.new('views/argument.slim', {}).render(arg))
  end
end


def build
  puts "Building..."

  ['arguments', 'theories'].each do |d|
    dir = "./dist/#{d}"
    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end
  end

  build_arguments
end


# build
