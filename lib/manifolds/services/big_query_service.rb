# frozen_string_literal: true

require "yaml"
require "json"

module Manifolds
  module Services
    # Handles the generation of BigQuery schemas based on project configurations
    class BigQueryService
      def initialize(logger)
        @logger = logger
      end

      def generate_dimensions_schema(project_name)
        config_path = "./projects/#{project_name}/manifold.yml"
        return unless validate_config_exists(config_path, project_name)

        config = YAML.load_file(config_path)
        dimensions = extract_dimensions(config["dimensions"])
        create_dimensions_file(project_name, dimensions)
      end

      private

      def validate_config_exists(config_path, project_name)
        unless File.exist?(config_path)
          @logger.error("Config file missing for project '#{project_name}'.")
          return false
        end
        true
      end

      def extract_dimensions(dimensions_hash)
        dimensions_hash.map do |dimension|
          extract_fields(dimension)
        end
      end

      def extract_fields(fields_hash, mode = "NULLABLE")
        fields_hash.map do |name, type|
          if type.is_a?(Hash)
            { "type" => "RECORD", "name" => name, "fields" => extract_fields(type) }
          elsif type
            { "type" => type.upcase, "name" => name, "mode" => mode }
          end
        end
      end

      def create_dimensions_file(project_name, dimensions)
        FileUtils.mkdir_p("./projects/#{project_name}/bq/tables")
        File.write("./projects/#{project_name}/bq/tables/dimensions.json", dimensions_schema(dimensions))
        @logger.info("Generated BigQuery dimensions table schema for '#{project_name}'.")
      end

      def dimensions_schema(dimensions)
        JSON.pretty_generate([
                               { "type" => "STRING", "name" => "id", "mode" => "REQUIRED" },
                               { "type" => "RECORD", "name" => "dimensions", "mode" => "REQUIRED",
                                 "fields" => dimensions }
                             ]).concat("\n")
      end
    end
  end
end
