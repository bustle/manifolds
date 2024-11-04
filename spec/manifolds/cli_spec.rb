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

      it "creates a manifold.yml file" do
        expect(File.exist?("./projects/#{sub_project_name}/manifold.yml")).to be true
      end

      it "writes the manifold.yml file with vectors" do
        expect(File.read("./projects/#{sub_project_name}/manifold.yml")).to include("vectors")
      end

      it "writes the manifold.yml file with metrics" do
        config = File.read("./projects/#{sub_project_name}/manifold.yml")
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

  describe "vectors" do
    describe "add" do
      let(:vector_name) { "Page" }
      let(:vectors_command) { described_class.new.class.subcommand_classes["vectors"] }

      context "when within an umbrella project" do
        subject(:cli) { vectors_command.new }

        before do
          FileUtils.mkdir_p("./vectors")
          allow(FileUtils).to receive(:cp)
          cli.add(vector_name)
        end

        after do
          FileUtils.rm_rf("./vectors")
        end

        it "copies the vector template" do
          template_path = File.join(File.dirname(File.expand_path("../../lib/manifolds/cli", __dir__)),
                                    "templates",
                                    "vector_template.yml")
          expect(FileUtils).to have_received(:cp)
            .with(template_path, "./vectors/page.yml")
        end
      end

      context "when outside an umbrella project" do
        subject(:cli) { vectors_command.new }

        it "logs an error" do
          expect { cli.add(vector_name) }
            .to output(/Not inside a Manifolds umbrella project/).to_stdout
        end
      end
    end
  end
end
