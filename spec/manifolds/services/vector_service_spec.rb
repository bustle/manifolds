# frozen_string_literal: true

RSpec.describe Manifolds::Services::VectorService do
  let(:logger) { instance_double("Logger") }
  let(:service) { described_class.new(logger) }

  describe "#load_vector_schema" do
    let(:vector_name) { "page" }
    let(:expected_schema) do
      {
        "name" => "page",
        "type" => "RECORD",
        "fields" => [
          { "name" => "id", "type" => "STRING", "mode" => "NULLABLE" },
          { "name" => "url", "type" => "STRING", "mode" => "NULLABLE" },
          { "name" => "created_at", "type" => "TIMESTAMP", "mode" => "NULLABLE" }
        ]
      }
    end
    let(:vector_config) do
      {
        "attributes" => {
          "id" => "string",
          "url" => "string",
          "created_at" => "timestamp"
        }
      }
    end

    before do
      vector_path = File.join(Dir.pwd, "vectors", "#{vector_name}.yml")
      allow(File).to receive(:exist?).with(vector_path).and_return(true)
      allow(YAML).to receive(:load_file).with(vector_path).and_return(vector_config)
    end

    it "loads and transforms vector schema" do
      schema = service.load_vector_schema(vector_name)
      expect(schema).to eq(expected_schema)
    end

    context "when vector file doesn't exist" do
      before do
        vector_path = File.join(Dir.pwd, "vectors", "#{vector_name}.yml")
        allow(File).to receive(:exist?).with(vector_path).and_return(false)
        allow(logger).to receive(:error)
      end

      it "returns nil" do
        expect(service.load_vector_schema(vector_name)).to be_nil
      end

      it "logs error" do
        vector_path = File.join(Dir.pwd, "vectors", "#{vector_name}.yml")
        service.load_vector_schema(vector_name)
        expect(logger).to have_received(:error)
          .with("Vector configuration not found: #{vector_path}")
      end
    end
  end
end
