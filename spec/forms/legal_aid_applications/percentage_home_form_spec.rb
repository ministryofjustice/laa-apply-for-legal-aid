require 'rails_helper'

RSpec.describe LegalAidApplications::PercentageHomeForm, type: :form do
  let(:percentage_home) { rand(1...99.0).round(2) }
  let(:application) { create :legal_aid_application }
  let(:params) { { percentage_home: percentage_home } }
  let(:form_params) { params.merge(model: application) }

  subject { described_class.new(form_params) }

  describe '#percentage_home' do
    it 'matches the value in params' do
      expect(subject.percentage_home).to eq(percentage_home)
    end
  end

  describe '#save' do
    it 'updates application.percentage_home' do
      expect { subject.save }.to change { application.reload.percentage_home.to_s.to_d }.to(percentage_home.to_d)
    end

    it 'returns true' do
      expect(subject.save).to eq(true)
    end

    it 'has no errors' do
      expect(subject.errors).to be_empty
    end

    shared_examples_for 'it has an error' do
      it 'returns false' do
        expect(subject.save).to eq(false)
      end

      it 'generates an error' do
        subject.save
        expect(subject.errors[:percentage_home]).to contain_exactly(expected_error)
      end

      it 'does not update the application' do
        expect { subject.save }.not_to change { application.reload.percentage_home }
      end
    end

    context 'percentage_home is empty' do
      let(:percentage_home) { '' }
      let(:expected_error) { I18n.t('activemodel.errors.models.legal_aid_application.attributes.percentage_home.blank') }

      it_behaves_like 'it has an error'
    end

    context 'percentage_home is not a number' do
      let(:percentage_home) { 'one thousand percent!' }
      let(:expected_error) { I18n.t('activemodel.errors.models.legal_aid_application.attributes.percentage_home.not_a_number') }

      it_behaves_like 'it has an error'
    end

    context 'percentage_home is less than 0' do
      let(:percentage_home) { -1 }
      let(:expected_error) { I18n.t('activemodel.errors.models.legal_aid_application.attributes.percentage_home.less_than_or_equal_to') }

      it_behaves_like 'it has an error'
    end

    context 'percentage_home is more than 100' do
      let(:percentage_home) { 100.1 }
      let(:expected_error) { I18n.t('activemodel.errors.models.legal_aid_application.attributes.percentage_home.greater_than_or_equal_to') }

      it_behaves_like 'it has an error'
    end
  end
end
