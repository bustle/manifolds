# frozen_string_literal: true

require "thor"
require "fileutils"
require "logger"

require_relative "services/big_query_service"

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

    private

    def copy_config_template(project_path)
      template_path = File.join(File.dirname(__FILE__), "templates", "config_template.yml")
      FileUtils.cp(template_path, "#{project_path}/manifold.yml")
    end
  end
end
