# frozen_string_literal: true

module Manifolds
  # CLI provides command line interface functionality
  # for creating and managing umbrella projects for data management.
  class CLI < Thor
    attr_accessor :logger, :bq_service

    def initialize(*args, logger: Logger.new($stdout))
      super(*args)

      self.logger = logger
      logger.level = Logger::INFO

      self.bq_service = Services::BigQueryService.new(logger)
    end

    desc "init NAME", "Generate a new umbrella project for data management"
    def init(name)
      Project.new(name).init
      logger.info "Created umbrella project '#{name}' with projects and vectors directories."
    end

    desc "vectors SUBCOMMAND ...ARGS", "Manage vectors"
    subcommand "vectors", Class.new(Thor) {
      namespace :vectors

      def initialize(*args, logger: Logger.new($stdout))
        super(*args)
        self.logger = logger
      end

      desc "add VECTOR_NAME", "Add a new vector configuration"
      def add(name)
        project = API::Project.new(File.basename(Dir.getwd))
        vector = API::Vector.new(name, project: project)
        vector.add
        # unless Dir.exist?("#{Dir.pwd}/vectors")
        #   logger.error("Not inside a Manifolds umbrella project.")
        #   return
        # end

        # vector_path = File.join(Dir.pwd, "vectors", "#{name.downcase}.yml")
        # copy_vector_template(vector_path)
        logger.info "Created vector configuration for '#{name}'."
      end

      private

      def copy_vector_template(vector_path)
        template_path = File.join(File.dirname(__FILE__), "templates", "vector_template.yml")
        FileUtils.cp(template_path, vector_path)
      end
    }

    desc "add PROJECT_NAME", "Add a new project within the current umbrella project"
    def add(project_name)
      project_path = File.join(Dir.pwd, "projects", project_name)
      unless Dir.exist?("#{Dir.pwd}/projects")
        logger.error("Not inside a Manifolds umbrella project.")
        return
      end

      FileUtils.mkdir_p("#{project_path}/tables")
      FileUtils.mkdir_p("#{project_path}/routines")
      copy_config_template(project_path)
      logger.info "Added project '#{project_name}' with tables and routines directories."
    end

    desc "generate PROJECT_NAME SERVICE", "Generate services for a project"
    def generate(project_name, service)
      case service
      when "bq"
        bq_service.generate_dimensions_schema(project_name)
      else
        logger.error("Unsupported service: #{service}")
      end
    end

    private

    def copy_config_template(project_path)
      template_path = File.join(File.dirname(__FILE__), "templates", "config_template.yml")
      FileUtils.cp(template_path, "#{project_path}/manifold.yml")
    end
  end
end
