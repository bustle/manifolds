# frozen_string_literal: true

RSpec.describe Manifolds::Services::BigQueryService do
  let(:logger) { instance_double("Logger") }
  let(:service) { described_class.new(logger) }
  let(:project_name) { "test_project" }
  let(:config_path) { "./projects/#{project_name}/manifold.yml" }
  let(:config) do
    {
      "vectors" => [
        { "name" => "User" }
      ]
    }
  end
  let(:vector_service) { instance_double(Manifolds::Services::VectorService) }

  before do
    allow(File).to receive(:exist?).with(config_path).and_return(true)
    allow(YAML).to receive(:load_file).with(config_path).and_return(config)
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:write)
    allow(logger).to receive(:info) # Allow 'info' to be called to avoid unexpected message errors
    allow(Manifolds::Services::VectorService).to receive(:new).and_return(vector_service)
    allow(vector_service).to receive(:load_vector_schema).and_return([
                                                                       {
                                                                         "name" => "user_id",
                                                                         "type" => "STRING",
                                                                         "mode" => "NULLABLE"
                                                                       }
                                                                     ])
  end

  describe "#generate_dimensions_schema" do
    it "checks if the configuration file exists" do
      service.generate_dimensions_schema(project_name)
      expect(File).to have_received(:exist?).with(config_path)
    end

    context "when configuration file does not exist" do
      before do
        allow(File).to receive(:exist?).with(config_path).and_return(false)
        allow(logger).to receive(:error)
      end

      it "logs an error message" do
        service.generate_dimensions_schema(project_name)
        expect(logger).to have_received(:error).with("Config file missing for project 'test_project'.")
      end
    end

    it "writes the dimensions schema to a file" do
      service.generate_dimensions_schema(project_name)
      expect(File).to have_received(:write).with("./projects/#{project_name}/bq/tables/dimensions.json", anything)
    end

    it "logs success message" do
      service.generate_dimensions_schema(project_name)
      expect(logger).to have_received(:info).with("Generated BigQuery dimensions table schema for 'test_project'.")
    end
  end
end
