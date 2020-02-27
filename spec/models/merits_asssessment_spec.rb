require 'rails_helper'

RSpec.describe MeritsAssessment do
  describe '#pretty_success_propsect' do
    let(:merits_assessment) { create :merits_assessment, success_prospect: prospect }

    context 'likely' do
      let(:prospect) { 'likely' }
      it 'generates the correct pretty text' do
        expect(merits_assessment.pretty_success_prospect).to eq 'Likely (>50%)'
      end
    end

    context 'likely' do
      let(:prospect) { 'likely' }
      it 'generates the correct pretty text' do
        expect(merits_assessment.pretty_success_prospect).to eq 'Likely (>50%)'
      end
    end

    context 'marginal' do
      let(:prospect) { 'marginal' }
      it 'generates the correct pretty text' do
        expect(merits_assessment.pretty_success_prospect).to eq 'Marginal (45-49%)'
      end
    end

    context 'poor' do
      let(:prospect) { 'poor' }
      it 'generates the correct pretty text' do
        expect(merits_assessment.pretty_success_prospect).to eq 'Poor (<45%)'
      end
    end

    context 'borderline' do
      let(:prospect) { 'borderline' }
      it 'generates the correct pretty text' do
        expect(merits_assessment.pretty_success_prospect).to eq 'Borderline'
      end
    end

    context 'not_known' do
      let(:prospect) { 'not_known' }
      it 'generates the correct pretty text' do
        expect(merits_assessment.pretty_success_prospect).to eq 'Uncertain'
      end
    end
  end
end
