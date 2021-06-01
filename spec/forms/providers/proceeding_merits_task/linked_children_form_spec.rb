require 'rails_helper'

RSpec.describe Providers::ProceedingMeritsTask::LinkedChildrenForm, type: :form do
  subject(:form) { described_class.new(params) }
  let(:params) { { linked_children: linked_children_params, model: application_proceeding_type } }
  let(:legal_aid_application) { create :legal_aid_application, :with_involved_children, :with_multiple_proceeding_types_inc_section8 }
  let(:proceeding_type) { legal_aid_application.proceeding_types.find_by(ccms_matter_code: 'KSEC8') }
  let(:application_proceeding_type) { legal_aid_application.application_proceeding_types.find_by(proceeding_type_id: proceeding_type.id) }
  let(:linked_children_params) { nil }

  describe '.value_list' do
    subject(:form) { described_class.new(model: application_proceeding_type) }

    let(:expected_array) do
      legal_aid_application.involved_children.map do |child|
        { id: child.id, name: child.full_name, is_checked: false }
      end
    end

    it 'loads an array of involved_children from the legal_aid_application' do
      expect(form.value_list).to match_array expected_array
    end
  end

  describe '.valid?' do
    before { form.valid? }

    context 'when all values are false' do
      let(:linked_children_params) { ['', '', ''] }

      it { is_expected.to be_invalid }
    end

    context 'when all values are true' do
      let(:linked_children_params) do
        legal_aid_application.involved_children.map(&:id)
      end

      it { is_expected.to be_valid }
    end

    context 'when one value is true' do
      let(:linked_children_params) do
        legal_aid_application.involved_children.each_with_index.map { |child, index| index.zero? ? child.id : '' }
      end

      it { is_expected.to be_valid }
    end
  end

  describe '.save' do
    subject(:save_form) { form.save }
    let(:linked_children_params) do
      legal_aid_application.involved_children.each_with_index.map { |child, index| index.zero? ? child.id : '' }
    end
    context 'when the initial application_proceeding_type has no linked_children' do
      it { expect(application_proceeding_type.application_proceeding_type_linked_children).to match_array [] }
      it { expect { subject }.to change { application_proceeding_type.application_proceeding_type_linked_children.count }.by(1) }
    end

    context 'when a user has previously linked two children' do
      let(:first_child) { legal_aid_application.involved_children.first }
      let(:second_child) { legal_aid_application.involved_children.second }
      let(:third_child) { legal_aid_application.involved_children.third }
      let(:initial_array) { [second_child.id, third_child.id] }
      let(:linked_children_params) { [first_child.id, '', ''] }
      before do
        create :application_proceeding_type_linked_child, application_proceeding_type: application_proceeding_type, involved_child: second_child
        create :application_proceeding_type_linked_child, application_proceeding_type: application_proceeding_type, involved_child: third_child
      end

      it { expect { subject }.to change { application_proceeding_type.application_proceeding_type_linked_children.count }.by(-1) }
      it { expect(application_proceeding_type.application_proceeding_type_linked_children.map(&:involved_child_id)).to match_array initial_array }

      context 'when an error occurs' do
        let(:linked_children_params) { ['guid-for-non-existent-child', '', ''] }

        it { expect { subject }.to_not change { application_proceeding_type.application_proceeding_type_linked_children.count } }
        it 'it rolls back all changes' do
          expect(subject).to eql false
          expect(application_proceeding_type.application_proceeding_type_linked_children.reload.map(&:involved_child_id)).to match_array initial_array
        end
      end
    end
  end
end
