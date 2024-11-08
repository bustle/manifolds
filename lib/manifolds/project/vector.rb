# frozen_string_literal: true

module Manifolds
  module API
    class Vector
      attr_reader :name, :project, :config_template_file

      def initialize(name, project:,
                     config_template_file: File.join(Dir.pwd, "lib", "manifolds", "templates", "vector_template.yml"))
        self.name = name
        self.project = project
        self.config_template_file = File.new(config_template_file)
      end

      def add
        FileUtils.mkdir_p(tables_directory)
        FileUtils.mkdir_p(routines_directory)
        FileUtils.cp(config_template_file, config_file)
      end

      def tables_directory
        Pathname.new(File.join(project.vectors_directory, "tables"))
      end

      def routines_directory
        Pathname.new(File.join(project.vectors_directory, "routines"))
      end

      def config_file
        File.new(File.join(project.directory, "#{name.downcase}.yml"))
      end

      private

      attr_writer :name, :project, :config_template_file
    end
  end
end
