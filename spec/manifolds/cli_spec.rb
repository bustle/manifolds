# frozen_string_literal: true

require_relative "../../lib/manifolds/cli"
require "fileutils"

RSpec.describe Manifolds::CLI do
  let(:project_name) { "commerce" }
  let(:sub_project_name) { "Pages" }

  describe "#init" do
    subject(:cli) { described_class.new }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:open)
      cli.init(project_name)
    end

    after do
      FileUtils.rm_rf(project_name)
    end

    it "creates the projects directory" do
      expect(FileUtils).to have_received(:mkdir_p).with("./#{project_name}/projects")
    end

    it "creates the Gemfile" do
      expect(File).to have_received(:open).with("./#{project_name}/Gemfile", "w")
    end
  end

  describe "#add" do
    context "when within an umbrella project" do
      before do
        FileUtils.mkdir_p("#{project_name}/projects") # Simulate an umbrella project
        Dir.chdir(project_name)
        described_class.new.add(sub_project_name)
      end

      after do
        Dir.chdir("..")
        FileUtils.rm_rf(project_name)
      end

      it "creates a tables directory" do
        expect(Dir.exist?("tables")).to be true
      end

      it "creates a routines directory" do
        expect(Dir.exist?("routines")).to be true
      end
    end

    context "when outside an umbrella project" do
      it "does not allow adding projects" do
        expect { described_class.new.add("Pages") }.to output(/Not inside a Manifolds umbrella project./).to_stdout
      end
    end
  end
end
