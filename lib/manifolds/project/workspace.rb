# frozen_string_literal: true

module Manifolds
  module API
    class Workspace
      attr_reader :name, :project, :template_file

      def initialize(name, project:,
                     template: File.join(Dir.pwd, "lib", "manifolds", "templates",
                                         "workspace_template.yml"))
        self.name = name
        self.project = project
        self.template_file = File.new(template)
      end

      def add
        FileUtils.mkdir_p(tables_directory)
        FileUtils.mkdir_p(routines_directory)
        FileUtils.cp(template_file, manifold_path)
      end

      def tables_directory
        Pathname.new(File.join(project.workspaces_directory, name, "tables"))
      end

      def routines_directory
        Pathname.new(File.join(project.workspaces_directory, name, "routines"))
      end

      def manifold_file
        return nil unless manifold_exists?

        File.new(manifold_path)
      end

      def manifold_exists?
        File.exist? manifold_path
      end

      def manifold_path
        File.join(project.workspaces_directory, name, "manifold.yml")
      end

      private

      attr_writer :name, :project, :template_file
    end
  end
end
