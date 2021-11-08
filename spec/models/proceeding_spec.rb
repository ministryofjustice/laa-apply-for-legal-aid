require 'rails_helper'

RSpec.describe Proceeding, type: :model do
  it {
    is_expected.to respond_to(:legal_aid_application_id,
                              :proceeding_case_id,
                              :lead_proceeding,
                              :ccms_code,
                              :meaning,
                              :description,
                              :substantive_cost_limitation,
                              :delegated_functions_cost_limitation,
                              :substantive_scope_limitation_code,
                              :substantive_scope_limitation_meaning,
                              :substantive_scope_limitation_description,
                              :delegated_functions_scope_limitation_code,
                              :delegated_functions_scope_limitation_meaning,
                              :delegated_functions_scope_limitation_description,
                              :used_delegated_functions_on,
                              :used_delegated_functions_reported_on)
  }

  describe '#application_proceeding_type' do
    let(:pt1) { create :proceeding_type, :with_real_data }
    let(:pt2) { create :proceeding_type, :as_section_8_child_residence }
    let(:laa) { create :legal_aid_application, :with_proceeding_types, explicit_proceeding_types: [pt1, pt2] }

    it 'returns the corresponding record' do
      proceeding = laa.proceedings.first
      apt = proceeding.application_proceeding_type
      expect(apt.proceeding_type.ccms_code).to eq proceeding.ccms_code
    end
  end

  describe '#section8?' do
    context 'section 8 proceeding' do
      let(:proceeding) { create :proceeding, :se014 }

      it 'returns true' do
        expect(proceeding.section8?).to eq true
      end
    end

    context 'non section 8 proceeding' do
      let(:proceeding) { create :proceeding, :da001 }

      it 'returns false' do
        expect(proceeding.section8?).to eq false
      end
    end
  end
end
