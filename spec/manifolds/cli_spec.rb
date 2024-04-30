# frozen_string_literal: true

require_relative "../../lib/manifolds/cli"
require "fileutils"
require "logger"

RSpec.describe Manifolds::CLI do
  let(:project_name) { "commerce" }
  let(:sub_project_name) { "Pages" }
  let(:null_logger) { Logger.new(File::NULL) }

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

    it "creates the Gemfile" do
      expect(File).to have_received(:open).with("./#{project_name}/Gemfile", "w")
    end
  end

  describe "#add" do
    subject(:cli) { described_class.new(logger: null_logger) }

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
end
