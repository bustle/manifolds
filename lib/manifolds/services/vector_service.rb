# frozen_string_literal: true

module Manifolds
  module Services
    # Handles the loading of vector schemas from configuration files
    class VectorService
      def initialize(logger)
        @logger = logger
      end

      def load_vector_schema(vector_name)
        path = File.join(Dir.pwd, "vectors", "#{vector_name.downcase}.yml")
        unless File.exist?(path)
          @logger.error("Vector configuration not found: #{path}")
          return nil
        end

        config = YAML.load_file(path)
        fields = transform_attributes_to_schema(config["attributes"])
        { "name" => vector_name.downcase, "type" => "RECORD", "fields" => fields }
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
