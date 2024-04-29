# frozen_string_literal: true

require_relative '../cli'
require 'fileutils'

RSpec.describe ManifoldsCLI do
  describe '#new_umbrella' do
    let(:project_name) { 'test_project' }

    before do
      # Capture the console output to avoid clutter during tests
      allow($stdout).to receive(:write)
    end

    after do
      # Cleanup
      FileUtils.rm_rf(project_name)
    end

    it 'creates the necessary project structure' do
      expect(FileUtils).to receive(:mkdir_p).with("./#{project_name}/projects")
      expect(File).to receive(:open).with("./#{project_name}/Gemfile", 'w')
      subject.new_umbrella(project_name)
    end
  end
end
