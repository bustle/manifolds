# frozen_string_literal: true

module Manifolds::API
  # Projects API
  class Vector
    attr_reader :name, :project, :config_template

    def initialize(name, project:, config_template: File.join("lib", "templates", "vector_template.yml"))
      binding.break
      self.name = name
      self.project = project
      self.config_template = config_template
    end

    def add
      FileUtils.mkdir_p(tables_directory)
      FileUtils.mkdir_p(routines_directory)
    end

    def tables_directory
      Pathname.new(File.join(project.vectors_directory, "tables"))
    end

    def routines_directory
      Pathname.new(File.join(project.vectors_directory, "routines"))
    end

    def config_file
      File.join(Dir.pwd, "vectors", "#{name.downcase}.yml")
    end

    private

    attr_writer :name, :project
  end
end
