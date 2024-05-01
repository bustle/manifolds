# frozen_string_literal: true

require_relative "../../lib/manifolds/cli"
require "fileutils"
require "logger"

RSpec.describe Manifolds::CLI do
  let(:project_name) { "commerce" }
  let(:sub_project_name) { "Pages" }
  let(:null_logger) { Logger.new(File::NULL) }
  let(:bq_service) { instance_double("Manifolds::Services::BigQueryService", "commerce") }

  describe "#init" do
    subject(:cli) { described_class.new(logger: null_logger) }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:open)
      cli.init(project_name)
    end

    it "creates the projects directory" do
      expect(FileUtils).to have_received(:mkdir_p).with("./#{project_name}/projects")
    end
  end

  describe "#add" do
    let(:cli) { described_class.new(logger: null_logger) }

    context "when within an umbrella project" do
      before do
        FileUtils.mkdir_p("#{project_name}/projects") # Simulate an umbrella project
        Dir.chdir(project_name)
        cli.add(sub_project_name)
      end

      after do
        Dir.chdir("..")
        FileUtils.rm_rf(project_name)
      end

      it "creates a tables directory within the project" do
        expect(Dir.exist?("./projects/#{sub_project_name}/tables")).to be true
      end

      it "creates a routines directory within the project" do
        expect(Dir.exist?("./projects/#{sub_project_name}/routines")).to be true
      end

      it "creates a config.yml file" do
        expect(File.exist?("./projects/#{sub_project_name}/config.yml")).to be true
      end

      it "writes the config.yml file with dimensions" do
        expect(File.read("./projects/#{sub_project_name}/config.yml")).to include("dimensions")
      end

      it "writes the config.yml file with metrics" do
        config = File.read("./projects/#{sub_project_name}/config.yml")
        expect(config).to include("metrics")
      end
    end

    context "when outside an umbrella project" do
      subject(:cli_with_stdout) { described_class.new(logger: Logger.new($stdout)) }

      it "does not allow adding projects and logs an error" do
        expect do
          cli_with_stdout.add("Pages")
        end.to output(/Not inside a Manifolds umbrella project./).to_stdout
      end
    end
  end

  describe "#generate" do
    subject(:cli) { described_class.new(logger: null_logger) }

    before do
      allow(Manifolds::Services::BigQueryService).to receive(:new).and_return(bq_service)
      allow(bq_service).to receive(:generate_dimensions_schema)
    end

    it "calls generate_dimensions_schema on bq service with correct project name" do
      cli.generate("Pages", "bq")
      expect(bq_service).to have_received(:generate_dimensions_schema).with("Pages")
    end
  end
end
