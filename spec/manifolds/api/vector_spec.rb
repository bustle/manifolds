# frozen_string_literal: true

RSpec.describe Manifolds::API::Vector do
  let(:project) { Manifolds::API::Project.new("wetland") }
  let(:name) { "page" }

  context "with name and project" do
    subject(:vector) { described_class.new(name, project: project) }

    describe ".initialize" do
      it { is_expected.to have_attributes(name: name, project: project) }
    end

    describe ".add" do
      before { vector.add }

      it { expect(vector.routines_directory).to be_directory }
      it { expect(vector.tables_directory).to be_directory }
    end

    describe ".routines_directory" do
      it { expect(vector.routines_directory).to be_an_instance_of(Pathname) }
    end

    describe ".tables_directory" do
      it { expect(vector.tables_directory).to be_an_instance_of(Pathname) }
    end
  end"
end
