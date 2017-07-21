require 'yaml'
require 'slim'
require 'attr_extras'
require 'require_all'
require 'pathname'
require 'fileutils'
require 'active_support/all'
require_all 'source'


# Helpers
def load_yaml_folder(folder, struct)
  Dir["./content/#{folder}/*.yaml"].map do |path|
    struct.new(path: Pathname.new(path).basename.sub_ext(''),
                 **YAML.load(File.read(path)).symbolize_keys)
  end
end

def slim(template, it)
  File.write("./dist/#{template.pluralize}/#{it.path}.html",
    Slim::Template.new("views/#{template}.slim", pretty: true).render(it))
end


# Model
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

  def self.build
    Argument.all.each do |arg|
      slim "argument", arg
    end
  end
end



class Theory
  attr_accessor_initialize [:path, :name, :description]

  def self.all
    load_yaml_folder "theories", self
  end

  def self.build
    Theory.all.each do |theory|
      slim "theory", theory
    end
  end

  def arguments
    Argument.all.select { |a| a.theory == name }
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

  [Argument, Theory].each do |x|
    x.build
  end
end


build
