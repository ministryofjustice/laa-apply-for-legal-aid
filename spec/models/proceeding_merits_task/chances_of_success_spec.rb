require 'rails_helper'

RSpec.describe ProceedingMeritsTask::ChancesOfSuccess, type: :model do
  describe '#pretty_success_propsect' do
    let(:pt_da) { create :proceeding_type, :with_real_data }
    let(:pt_s8) { create :proceeding_type, :as_section_8_child_residence }
    let(:legal_aid_application) do
      create :legal_aid_application, :with_proceeding_types, :with_proceedings, explicit_proceeding_types: [pt_da, pt_s8], explicit_proceedings: %i[da001 se014]
    end
    let(:application_proceeding_type) { legal_aid_application.application_proceeding_types.first }
    let(:proceeding) { legal_aid_application.proceedings.first }
    let(:chances_of_success) { create :chances_of_success, application_proceeding_type: application_proceeding_type, success_prospect: prospect, proceeding: proceeding }

    context 'likely' do
      let(:prospect) { 'likely' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Likely (>50%)'
      end
    end

    context 'likely' do
      let(:prospect) { 'likely' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Likely (>50%)'
      end
    end

    context 'marginal' do
      let(:prospect) { 'marginal' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Marginal (45-49%)'
      end
    end

    context 'poor' do
      let(:prospect) { 'poor' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Poor (<45%)'
      end
    end

    context 'borderline' do
      let(:prospect) { 'borderline' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Borderline'
      end
    end

    context 'not_known' do
      let(:prospect) { 'not_known' }
      it 'generates the correct pretty text' do
        expect(chances_of_success.pretty_success_prospect).to eq 'Uncertain'
      end
    end
  end
end
