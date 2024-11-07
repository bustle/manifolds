# frozen_string_literal: true

require_relative "../../lib/manifolds/cli"
require "fileutils"
require "logger"
require "fakefs/spec_helpers"

RSpec.describe Manifolds::CLI do
  include FakeFS::SpecHelpers

  let(:project_name) { "commerce" }
  let(:sub_project_name) { "Pages" }
  let(:null_logger) { Logger.new(File::NULL) }

  before do
    FakeFS do
      # Set up any template files that need to exist
      FileUtils.mkdir_p("#{File.dirname(__FILE__)}/../../lib/manifolds/templates")
      File.write("#{File.dirname(__FILE__)}/../../lib/manifolds/templates/config_template.yml", "vectors:\nmetrics:")
      File.write("#{File.dirname(__FILE__)}/../../lib/manifolds/templates/vector_template.yml", "attributes:")
    end
  end

  describe "#init" do
    subject(:cli) { described_class.new(logger: null_logger) }

    context "when initializing a new project" do
      before { cli.init(project_name) }

      it "creates a 'projects' directory for the project" do
        expect(Dir.exist?(File.join(Dir.pwd, project_name, "projects"))).to be true
      end

      it "creates a 'vectors' directory for the project" do
        expect(Dir.exist?(File.join(Dir.pwd, project_name, "vectors"))).to be true
      end
    end
  end

  describe "#add" do
    subject(:cli) { described_class.new(logger: null_logger) }

    context "when adding a project within an umbrella project" do
      before do
        FileUtils.mkdir_p("#{project_name}/projects")
        Dir.chdir(project_name)
        cli.add(sub_project_name)
      end

      after do
        Dir.chdir("..")
      end

      it "creates a 'tables' directory for the project" do
        expect(Dir.exist?(File.join(Dir.pwd, "projects", sub_project_name, "tables"))).to be true
      end

      it "creates a 'routines' directory for the project" do
        expect(Dir.exist?("./projects/#{sub_project_name}/routines")).to be true
      end

      it "adds vectors to the project's manifold configuration" do
        config = YAML.safe_load_file(File.join(Dir.pwd, "projects", sub_project_name, "manifold.yml"))
        expect(config).to have_key("vectors")
      end

      it "adds metrics to the project's manifold configuration" do
        config = YAML.safe_load_file(File.join(Dir.pwd, "projects", sub_project_name, "manifold.yml"))
        expect(config).to have_key("metrics")
      end
    end

    context "when outside an umbrella project" do
      let(:cli_with_stdout) { described_class.new(logger: Logger.new($stdout)) }

      it "indicates that the command must be run within a project" do
        FakeFS do
          expect { cli_with_stdout.add(sub_project_name) }
            .to output(/Not inside a Manifolds umbrella project/).to_stdout
        end
      end
    end
  end

  describe "vectors" do
    describe "add" do
      subject(:cli) { vectors_command.new(logger: null_logger) }

      let(:vector_name) { "Page" }
      let(:vectors_command) { described_class.new.class.subcommand_classes["vectors"] }

      context "when adding a vector within an umbrella project" do
        before do
          FileUtils.mkdir_p(File.join(Dir.pwd, "vectors"))
          cli.add(vector_name)
        end

        it "creates a vector configuration file with 'attributes'" do
          config = YAML.safe_load_file(File.join(Dir.pwd, "vectors", "page.yml"))
          expect(config).to have_key("attributes")
        end
      end

      context "when outside an umbrella project" do
        it "indicates that the command must be run within a project" do
          expect { vectors_command.new.add(vector_name) }
            .to output(/Not inside a Manifolds umbrella project/).to_stdout
        end
      end
    end
  end
end
