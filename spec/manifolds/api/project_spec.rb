# frozen_string_literal: true

RSpec.describe Manifolds::API::Project do
  include FakeFS::SpecHelpers

  let(:name) { "wetland" }

  context "with name" do
    subject(:project) { described_class.new(name) }

    describe ".initialize" do
      it { is_expected.to have_attributes(name: name) }
    end

    describe ".init" do
      before { project.init }

      it { expect(project.vectors_directory).to be_directory }
      it { expect(project.workspaces_directory).to be_directory }
    end

    describe ".workspaces_directory" do
      it { expect(project.workspaces_directory).to be_an_instance_of(Pathname) }
    end

    describe ".vectors_directory" do
      it { expect(project.vectors_directory).to be_an_instance_of(Pathname) }
    end
  end

  context "with directory" do
    subject(:project) { described_class.new(name, directory: directory) }

    let(:directory) { Pathname.new(File.join(Dir.pwd, "supplied_directory")) }

    it { is_expected.to have_attributes(directory: directory) }
  end
end
