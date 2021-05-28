require 'rails_helper'

RSpec.describe LegalAidApplications::EmergencyCostOverrideForm do
  subject(:form) { described_class.new(form_params) }
  let!(:application) { create :legal_aid_application, :with_applicant_and_address }

  let(:params) do
    {
      emergency_cost_override: overridden,
      emergency_cost_requested: value,
      emergency_cost_reasons: reasons
    }
  end
  let(:form_params) { params.merge(model: application) }

  let(:overridden) { 'false' }
  let(:value) { nil }
  let(:reasons) { nil }

  describe 'validation' do
    subject(:valid?) { form.valid? }

    context 'when no parameters sent' do
      let(:params) { {} }
      before { valid? }

      it { is_expected.to be false }
      it 'displays relevant errors' do
        expect(form.errors[:emergency_cost_override]).to eq [I18n.t('activemodel.errors.models.legal_aid_application.attributes.emergency_cost_override.blank')]
      end
    end

    context 'when the override is not requested' do
      it { is_expected.to be true }
    end

    context 'when the override requested' do
      let(:overridden) { 'true' }
      let(:value) { '5,000' }
      let(:reasons) { 'Something, something, argument' }

      it { is_expected.to be true }

      context 'but no value supplied' do
        let(:value) { nil }
        before { valid? }

        it { is_expected.to be false }
        it 'displays the relevant errors' do
          expect(form.errors[:emergency_cost_requested]).to eq [I18n.t('activemodel.errors.models.legal_aid_application.attributes.emergency_cost_requested.blank')]
        end
      end

      context 'but no reasons supplied' do
        let(:reasons) { nil }
        before { valid? }

        it { is_expected.to be false }
        it 'displays the relevant errors' do
          expect(form.errors[:emergency_cost_reasons]).to eq [I18n.t('activemodel.errors.models.legal_aid_application.attributes.emergency_cost_reasons.blank')]
        end
      end
    end
  end
end
