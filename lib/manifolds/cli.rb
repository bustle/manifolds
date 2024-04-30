# frozen_string_literal: true

require "thor"
require "fileutils"
require "logger"

module Manifolds
  # CLI provides command line interface functionality
  # for creating and managing umbrella projects for data management.
  class CLI < Thor
    def initialize(*args, logger: Logger.new($stdout))
      super(*args)
      @logger = logger
      @logger.level = Logger::INFO
    end

    desc "init NAME", "Generate a new umbrella project for data management"
    def init(name)
      directory_path = "./#{name}/projects"
      FileUtils.mkdir_p(directory_path)
      @logger.info "Created umbrella project '#{name}' with a projects directory."
      # Generate Gemfile inside the new umbrella project
      File.open("./#{name}/Gemfile", "w") do |file|
        file.puts "source 'https://rubygems.org'"
        file.puts "gem 'thor'"
      end
      @logger.info "Generated Gemfile for the umbrella project."
    end

    desc "add PROJECT_NAME", "Add a new project within the current umbrella project"
    def add(project_name)
      unless Dir.exist?("./projects")
        @logger.error("Not inside a Manifolds umbrella project.")
        return
      end

      FileUtils.mkdir_p("tables")
      FileUtils.mkdir_p("routines")
      @logger.info "Added project '#{project_name}' with tables and routines directories."
    end
  end
end
