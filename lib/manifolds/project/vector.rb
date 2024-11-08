# frozen_string_literal: true

module Manifolds
  module API
    # Describes the entities for whom metrics are calculated.
    class Vector
      attr_reader :name, :project, :config_template_path

      DEFAULT_CONFIG_TEMPLATE_PATH = File.join(
        Dir.pwd, "lib", "manifolds", "templates", "vector_template.yml"
      )

      def initialize(name, project:, config_template_path: DEFAULT_CONFIG_TEMPLATE_PATH)
        self.name = name
        self.project = project
        self.config_template_path = Pathname.new(config_template_path)
      end

      def add
        Pathname.new(tables_directory).mkpath
        Pathname.new(routines_directory).mkpath
        FileUtils.cp(config_template_path, config_file_path)
      end

      def tables_directory
        Pathname.new(File.join(project.vectors_directory, "tables"))
      end

      def routines_directory
        Pathname.new(File.join(project.vectors_directory, "routines"))
      end

      def config_file_path
        Pathname.new(project.directory).join("vectors", "#{name.downcase}.yml")
      end

      private

      attr_writer :name, :project, :config_template_path
    end
  end
end
