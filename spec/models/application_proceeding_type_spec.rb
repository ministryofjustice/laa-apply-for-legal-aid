require 'rails_helper'

RSpec.describe ApplicationProceedingType do
  describe '#proceeding_case_id' do
    let!(:legal_aid_application) { create :legal_aid_application }
    let!(:proceeding_type) { create :proceeding_type }
    let!(:proceeding_type2) { create :proceeding_type }

    context 'empty_database' do
      it 'creates record with first proceeding case id' do
        expect(ApplicationProceedingType.count).to be_zero
        legal_aid_application.proceeding_types << proceeding_type
        legal_aid_application.save!
        application_proceeding_type = legal_aid_application.application_proceeding_types.first
        expect(application_proceeding_type.proceeding_case_id > 55_000_000).to be true
        expect(application_proceeding_type.lead_proceeding).to be true
      end
    end

    context 'database with records' do
      it 'creates a record with the next in sequence' do
        3.times { create :legal_aid_application, :with_proceeding_types }
        expect(ApplicationProceedingType.count).to eq 3
        highest_proceeding_case_id = ApplicationProceedingType.order(:proceeding_case_id).last.proceeding_case_id
        legal_aid_application.proceeding_types << proceeding_type
        legal_aid_application.save!
        application_proceeding_type = legal_aid_application.application_proceeding_types.first
        expect(application_proceeding_type.proceeding_case_id).to eq highest_proceeding_case_id + 1
      end

      it 'creates record with multiple proceedings and assigns the first one as lead_proceeding' do
        legal_aid_application.proceeding_types << proceeding_type
        legal_aid_application.proceeding_types << proceeding_type2
        legal_aid_application.save!
        first_proceeding_type = legal_aid_application.application_proceeding_types.order(proceeding_case_id: :asc).first
        expect(first_proceeding_type.lead_proceeding).to be true
        second_proceeding_type = legal_aid_application.application_proceeding_types.order(proceeding_case_id: :asc).last
        expect(second_proceeding_type.lead_proceeding).to be false
      end
    end
  end

  describe '#proceeding_case_p_num' do
    it 'prefixes the proceeding case id with P_' do
      legal_aid_application = create :legal_aid_application, :with_proceeding_types
      application_proceeding_type = legal_aid_application.application_proceeding_types.first
      allow(application_proceeding_type).to receive(:proceeding_case_id).and_return 55_200_301
      expect(application_proceeding_type.proceeding_case_p_num).to eq 'P_55200301'
    end
  end
end
