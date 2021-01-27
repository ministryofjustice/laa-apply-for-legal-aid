require 'rails_helper'

RSpec.describe LegalAidApplications::DelegatedFunctionsDateForm, type: :form, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let(:legal_aid_application) { create :legal_aid_application, used_delegated_functions_on: '12/12/2020' }
  let(:confirm_delegated_functions_date) { true }
  let(:used_delegated_functions_reported_on) { Date.today }
  let(:used_delegated_functions_on) { rand(20).days.ago.to_date }
  let(:day) { used_delegated_functions_on.day }
  let(:month) { used_delegated_functions_on.month }
  let(:year) { used_delegated_functions_on.year }
  let(:i18n_scope) { 'activemodel.errors.models.legal_aid_application.attributes' }
  let(:error_locale) { :defined_in_spec }
  let(:message) { I18n.t(error_locale, scope: i18n_scope) }

  let(:params) do
    {
      used_delegated_functions_day: day.to_s,
      used_delegated_functions_month: month.to_s,
      used_delegated_functions_year: year.to_s,
      confirm_delegated_functions_date: :confirm_delegated_functions_date.to_s
    }
  end

  subject { described_class.new(params.merge(model: legal_aid_application)) }

  describe '#save' do
    before do
      subject.save
      legal_aid_application.reload
    end

    it 'does not update the application' do
      expect(legal_aid_application.used_delegated_functions_on).to eq(Date.parse('12/12/2020'))
    end

    context 'confirm_delegated_functions_date is false' do
      let(:confirm_delegated_functions_date) { false }

      it 'updates the application' do
        expect(legal_aid_application.used_delegated_functions_reported_on).to eq(used_delegated_functions_reported_on)
        expect(legal_aid_application.used_delegated_functions_on).to eq(used_delegated_functions_on)
        # expect { subject.save }.to change { legal_aid_application }
      end
    end
  end
end
