# frozen_string_literal: true

require "thor"
require "fileutils"
require "logger"

require_relative "services/big_query_service"
require_relative "services/entity_service"

module Manifolds
  # CLI provides command line interface functionality
  # for creating and managing umbrella projects for data management.
  class CLI < Thor
    def initialize(*args, logger: Logger.new($stdout))
      super(*args)
      @logger = logger
      @logger.level = Logger::INFO

      @bq_service = Services::BigQueryService.new(@logger)
    end

    desc "init NAME", "Generate a new umbrella project for data management"
    def init(name)
      directory_path = "./#{name}/projects"
      FileUtils.mkdir_p(directory_path)
      @logger.info "Created umbrella project '#{name}' with a projects directory."
    end

    desc "add PROJECT_NAME", "Add a new project within the current umbrella project"
    def add(project_name)
      project_path = "./projects/#{project_name}"
      unless Dir.exist?("./projects")
        @logger.error("Not inside a Manifolds umbrella project.")
        return
      end

      FileUtils.mkdir_p("#{project_path}/tables")
      FileUtils.mkdir_p("#{project_path}/routines")
      copy_config_template(project_path)
      @logger.info "Added project '#{project_name}' with tables and routines directories."
    end

    desc "generate PROJECT_NAME SERVICE", "Generate services for a project"
    def generate(project_name, service)
      case service
      when "bq"
        @bq_service.generate_dimensions_schema(project_name)
      else
        @logger.error("Unsupported service: #{service}")
      end
    end

    desc "entity NAME", "Create a new entity configuration"
    def entity(name)
      unless Dir.exist?("./projects")
        @logger.error("Not inside a Manifolds umbrella project.")
        return
      end

      entity_dir = "./projects/entities"
      FileUtils.mkdir_p(entity_dir)

      entity_path = "#{entity_dir}/#{name.downcase}.yml"
      copy_entity_template(entity_path)
      @logger.info "Created entity configuration for '#{name}'."
    end

    private

    def copy_config_template(project_path)
      template_path = File.join(File.dirname(__FILE__), "templates", "config_template.yml")
      FileUtils.cp(template_path, "#{project_path}/manifold.yml")
    end

    def copy_entity_template(entity_path)
      template_path = File.join(File.dirname(__FILE__), "templates", "entity_template.yml")
      FileUtils.cp(template_path, entity_path)
    end
  end
end
