module Manifolds::API
  # Projects API
  class Project
    attr_reader :name, :directory

    def initialize(name, directory: Pathname.new(File.join(Dir.pwd, name)))
      self.name = name
      self.directory = directory
    end

    def init
      FileUtils.mkdir_p(workspaces_directory)
      FileUtils.mkdir_p(vectors_directory)
    end

    def workspaces_directory
      Pathname.new(File.join(directory, "workspaces"))
    end

    def vectors_directory
      Pathname.new(File.join(directory, "vectors"))
    end

    private

    attr_writer :name, :directory
  end
end
