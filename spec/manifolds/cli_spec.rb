# frozen_string_literal: true

RSpec.describe Manifolds::CLI do
  include FakeFS::SpecHelpers

  let(:project_name) { "wetland" }
  let(:workspace_name) { "Commerce" }
  let(:null_logger) { Logger.new(File::NULL) }

  before do
    # Set up any template files that need to exist
    FileUtils.mkdir_p("#{File.dirname(__FILE__)}/../../lib/manifolds/templates")
    File.write("#{File.dirname(__FILE__)}/../../lib/manifolds/templates/workspace_template.yml", "vectors:\nmetrics:")
    File.write("#{File.dirname(__FILE__)}/../../lib/manifolds/templates/vector_template.yml", "attributes:")
  end

  describe "#init" do
    subject(:cli) { described_class.new(logger: null_logger) }

    context "when initializing a new project" do
      after { cli.init(project_name) }

      it { expect(null_logger).to receive(:info) }

      it "figures out how to check it interacted with the API?"
    end
  end

  describe "#add" do
    subject(:cli) { described_class.new(logger: null_logger) }

    context "when adding a workspace within a project" do
      before do
        FileUtils.mkdir_p("#{project_name}/workspaces")
        cli.add(workspace_name)
      end

      after { Dir.chdir("..") }

      let(:workspace_path) { File.join(Dir.pwd, "workspaces", workspace_name) }

      it "creates a 'tables' directory" do
        expect(Pathname.new(workspace_path).join("tables")).to be_directory
      end

      it "creates a 'routines' directory" do
        expect(Pathname.new(workspace_path).join("routines")).to be_directory
      end

      it "adds vectors to the project's manifold configuration" do
        config = YAML.safe_load_file(File.join(workspace_path, "manifold.yml"))
        expect(config).to have_key("vectors")
      end

      it "adds metrics to the project's manifold configuration" do
        config = YAML.safe_load_file(File.join(workspace_path, "manifold.yml"))
        expect(config).to have_key("metrics")
      end
    end
  end

  describe "vectors#add" do
    subject(:cli) { vectors_command.new(logger: null_logger) }

    let(:project) { Manifolds::API::Project.new("wetland") }
    let(:vector_name) { "page" }
    let(:vectors_command) { described_class.new.class.subcommand_classes["vectors"] }

    context "when adding a vector within an umbrella project" do
      before do
        cli.add(vector_name)
      end

      it "creates a vector configuration file with 'attributes'" do
        config = YAML.safe_load_file(File.join(Dir.pwd, "vectors", "page.yml"))
        expect(config).to have_key("attributes")
      end
    end
  end
end
