# frozen_string_literal: true

require_relative "../../lib/manifolds/cli"
require "fileutils"

RSpec.describe Manifolds::CLI do
  describe "#new_umbrella" do
    subject(:cli) { described_class.new } # Using a named subject

    let(:project_name) { "test_project" }

    before do
      allow($stdout).to receive(:write)
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:open)
      cli.new_umbrella(project_name) # Using the named subject
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
end
