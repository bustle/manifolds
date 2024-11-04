# frozen_string_literal: true

RSpec.describe Manifolds::Services::EntityService do
  let(:logger) { instance_double("Logger") }
  let(:service) { described_class.new(logger) }

  describe "#load_entity_schema" do
    let(:entity_name) { "user" }
    let(:entity_path) { "./projects/entities/user.yml" }
    let(:entity_config) do
      {
        "attributes" => {
          "id" => "string",
          "email" => "string",
          "created_at" => "timestamp"
        }
      }
    end

    before do
      allow(File).to receive(:exist?).with(entity_path).and_return(true)
      allow(YAML).to receive(:load_file).with(entity_path).and_return(entity_config)
      allow(logger).to receive(:error)
    end

    it "loads and transforms entity schema" do
      schema = service.load_entity_schema(entity_name)

      expect(schema).to contain_exactly(
        {
          "name" => "id",
          "type" => "STRING",
          "mode" => "NULLABLE"
        },
        {
          "name" => "email",
          "type" => "STRING",
          "mode" => "NULLABLE"
        },
        {
          "name" => "created_at",
          "type" => "TIMESTAMP",
          "mode" => "NULLABLE"
        }
      )
    end

    context "when entity file doesn't exist" do
      before do
        allow(File).to receive(:exist?).with(entity_path).and_return(false)
      end

      it "returns nil and logs error" do
        expect(service.load_entity_schema(entity_name)).to be_nil
        expect(logger).to have_received(:error).with("Entity configuration not found: #{entity_path}")
      end
    end
  end
end
