# frozen_string_literal: true

require "yaml"

module Manifolds
  module Services
    class EntityService
      def initialize(logger)
        @logger = logger
      end

      def load_entity_schema(entity_name)
        path = "./projects/entities/#{entity_name.downcase}.yml"
        unless File.exist?(path)
          @logger.error("Entity configuration not found: #{path}")
          return nil
        end

        config = YAML.load_file(path)
        transform_attributes_to_schema(config["attributes"])
      end

      private

      def transform_attributes_to_schema(attributes)
        attributes.map do |name, type|
          {
            "name" => name,
            "type" => type.upcase,
            "mode" => "NULLABLE"
          }
        end
      end
    end
  end
end
