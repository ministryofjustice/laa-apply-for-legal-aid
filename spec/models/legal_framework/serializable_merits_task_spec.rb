require 'rails_helper'

module LegalFramework
  RSpec.describe SerializableMeritsTask, type: :model do
    let(:serialized_merits_task) { described_class.new(:proceeding_children, dependencies: [:application_children]) }

    describe '.new' do
      it 'instantiates a new object' do
        expect(serialized_merits_task.name).to eq :proceeding_children
        expect(serialized_merits_task.dependencies).to eq [:application_children]
        expect(serialized_merits_task.state).to eq :waiting_for_dependency
      end

      context 'no dependencies' do
        let(:serialized_merits_task) { described_class.new(:proceeding_children, dependencies: []) }

        it ' stores empty array for dependencies' do
          expect(serialized_merits_task.dependencies).to be_empty
        end
      end
    end

    describe '#remove_dependency' do
      subject(:remove_dependency) { legal_framework_serializable_merits_task.remove_dependency(parameter) }
      let(:legal_framework_serializable_merits_task) { build :legal_framework_serializable_merits_task, dependencies: [:application_children] }
      before { remove_dependency }

      context 'when sent a string' do
        let(:parameter) { 'application_children' }

        it 'removes the dependency' do
          expect(legal_framework_serializable_merits_task.dependencies).to be_empty
        end
      end

      context 'when sent a symbol' do
        let(:parameter) { :application_children }

        it 'removes the dependency' do
          expect(legal_framework_serializable_merits_task.dependencies).to be_empty
        end
      end
    end

    describe '#mark_as_complete!' do
      context 'has dependencies' do
        it 'raises an exception' do
          expect {
            serialized_merits_task.mark_as_complete!
          }.to raise_error RuntimeError, /Unmet dependency/
        end
      end

      context 'successful' do
        let(:serialized_merits_task) { described_class.new(:proceeding_children, dependencies: []) }

        it 'marks the task as complete' do
          serialized_merits_task.mark_as_complete!
          expect(serialized_merits_task.state).to eq :complete
        end
      end
    end
  end
end
