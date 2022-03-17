require 'rails_helper'

module ProceedingMeritsTask
  RSpec.describe ProceedingLinkedChild do
    context 'validation of correct involved child' do
      let(:laa) { create :legal_aid_application }
      let(:other_laa) { create :legal_aid_application }
      let(:proceeding) { create :proceeding, :da001, legal_aid_application: laa }
      let(:linked_child) { described_class.create(proceeding:, involved_child:) }

      context 'involved child belongs to this application' do
        let(:involved_child) { create :involved_child, legal_aid_application: laa }

        it 'it is valid' do
          expect(linked_child).to be_valid
        end
      end

      context 'involved child does not belong to this application' do
        let(:involved_child) { create :involved_child, legal_aid_application: other_laa }

        it 'is not valid' do
          expect(linked_child).not_to be_valid
          expect(linked_child.errors[:involved_child]).to eq ['belongs to another application']
        end
      end
    end
  end
end
