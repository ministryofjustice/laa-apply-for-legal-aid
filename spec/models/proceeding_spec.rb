require 'rails_helper'

RSpec.describe Proceeding, type: :model do
  let(:matter_code) { 'KSEC8' }
  let(:df_date) { nil }
  let(:proceeding) do
    create :proceeding,
           :da001,
           proceeding_case_id: 55_123_456,
           ccms_matter_code: matter_code,
           used_delegated_functions_on: df_date
  end

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

  describe '#case_p_num' do
    it 'returns formatted proceeding case id' do
      expect(proceeding.case_p_num).to eq 'P_55123456'
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

  context 'domestic abuse' do
    let(:matter_code) { 'MINJN' }
    it 'returns false' do
      expect(proceeding.section8?).to be false
    end
  end

  describe '#default_level_of_service_level' do
    it 'returns hard coded value' do
      expect(proceeding.default_level_of_service_level).to eq '3'
    end
  end

  describe '#used_delegated_functions?' do
    context 'df not used' do
      it 'returns false' do
        expect(proceeding.used_delegated_functions?).to be false
      end
    end

    context 'df_used' do
      let(:df_date) { 2.days.ago }
      it 'returns true' do
        expect(proceeding.used_delegated_functions?).to be true
      end
    end
  end
end
