# frozen_string_literal: true

require_relative "../../lib/manifolds/cli"
require "fileutils"

RSpec.describe Manifolds::CLI do
  let(:project_name) { "commerce" }
  let(:sub_project_name) { "Pages" }

  before do
    # Redirect stdout to null device to silence output
    @original_stdout = $stdout
    $stdout = File.open(File::NULL, "w")
  end

  after do
    # Restore stdout
    $stdout = @original_stdout
  end

  describe "#init" do
    subject(:cli) { described_class.new } # Using a named subject

    before do
      allow($stdout).to receive(:write)
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:open)
      cli.init(project_name) # Using the named subject
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
    context "within an umbrella project" do
      before do
        FileUtils.mkdir_p("commerce/projects") # Simulate an umbrella project
        Dir.chdir("commerce")
      end

      after do
        Dir.chdir("..")
        FileUtils.rm_rf("commerce")
      end

      it "creates directories" do
        expect { described_class.new.add("Pages") }.to output(/Added project 'Pages'/).to_stdout
        expect(Dir.exist?("tables")).to be true
        expect(Dir.exist?("routines")).to be true
      end
    end

    context "outside an umbrella project" do
      it "does not allow adding projects" do
        expect { described_class.new.add("Pages") }.to output(/(.*)Not inside a Manifolds umbrella project./).to_stdout
      end
    end
  end
end
