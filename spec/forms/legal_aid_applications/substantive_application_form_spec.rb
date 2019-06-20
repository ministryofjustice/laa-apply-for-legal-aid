require 'rails_helper'

RSpec.describe LegalAidApplications::SubstantiveApplicationForm, type: :form, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let(:application) { create :legal_aid_application, state: :client_details_answers_checked }
  let(:substantive_application) { false }
  let(:working_day_calculator) { WorkingDayCalculator.new(Date.today) }
  let(:working_days_to_complete) { LegalAidApplication::WORKING_DAYS_TO_COMPLETE_SUBSTANTIVE_APPLICATION }
  let(:deadline) { working_day_calculator.add_working_days(working_days_to_complete) }
  let(:params) do
    {
      substantive_application: substantive_application.to_s,
      model: application
    }
  end

  subject { described_class.new(params) }

  describe '#save' do
    it 'updates application' do
      expect { subject.save }
        .to change { application.substantive_application }
        .from(nil)
        .to(substantive_application)
    end

    it 'generates a deadline date' do
      subject.save
      expect(application.reload.substantive_application_deadline_on).to eq(deadline)
    end

    it 'updates application' do
      expect(subject.save).to be true
      expect(application).not_to be_substantive_application
    end

    context 'when a deadline is already set' do
      let(:deadline) { 3.days.from_now.to_date }
      let(:application) do
        create :legal_aid_application, substantive_application_deadline_on: deadline, state: :client_details_answers_checked
      end

      it 'does not change deadline' do
        subject.save
        expect(application.reload.substantive_application_deadline_on).to eq(deadline)
      end
    end

    context 'when completing substantive application now selected' do
      let(:substantive_application) { true }

      it 'does not generates a deadline date' do
        subject.save
        expect(application.reload.substantive_application_deadline_on).to be_nil
      end

      it 'updates application' do
        expect(subject.save).to be true
        expect(application).to be_substantive_application
      end
    end

    context 'with no entry' do
      let(:substantive_application) { '' }

      it 'does not update application' do
        expect(subject.save).to be false
        expect(application.substantive_application).to be_nil
      end
    end
  end
end
