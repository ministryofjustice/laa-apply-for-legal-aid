require "rspec"
require "rails_helper"

RSpec.describe DelegatedFunctionsDateService do
  describe "sets date on proceeding records", :vcr do
    subject { described_class.call(laa) }

    let(:laa) { create(:legal_aid_application) }
    let!(:proceeding1) do
      create(:proceeding, :da001,
             legal_aid_application: laa,
             used_delegated_functions: df_used?,
             used_delegated_functions_on: df_date,
             used_delegated_functions_reported_on: reported_date)
    end
    let!(:proceeding2) { create(:proceeding, :se013, legal_aid_application: laa) }
    let(:df_used?) { true }
    let(:df_date) { Date.new(2021, 5, 10) }
    let(:reported_date) { Date.new(2021, 5, 13) }

    around do |example|
      travel_to Time.zone.local(2021, 5, 13, 12, 0, 0)
      example.run
      travel_back
    end

    it "returns true" do
      expect(subject).to be true
    end

    describe "sets the substantive_application_deadline_on date" do
      context "DF are used on at least one proceeding type" do
        let(:df_date) { Date.new(2021, 5, 10) }
        let(:reported_date) { Date.new(2021, 5, 13) }
        let(:expected_deadline) { Date.new(2021, 6, 8) }

        it "sets the substantive_application_deadline_on date" do
          subject
          expect(laa.reload.substantive_application_deadline_on).to eq expected_deadline
        end
      end

      context "no DF used on any proceeding type" do
        let(:df_used?) { nil }
        let(:df_date) { nil }
        let(:reported_date) { nil }

        it "sets the substantive application_deadline_on to nil" do
          subject
          expect(laa.reload.substantive_application_deadline_on).to be_nil
        end
      end
    end

    describe "scheduling reminder mails" do
      let(:scheduled_time1) { Time.zone.local(2021, 5, 30, 9, 0, 0) }
      let(:scheduled_time2) { Time.zone.local(2021, 5, 25, 9, 0, 0) }

      context "no delegated functions on any proceeding type" do
        let(:df_used?) { false }
        let(:df_date) { nil }
        let(:reported_date) { nil }

        context "scheduled mail already exists" do
          before do
            create(:scheduled_mailing, :waiting, legal_aid_application: laa, scheduled_at: scheduled_time1)
            create(:scheduled_mailing, :waiting, legal_aid_application: laa, scheduled_at: scheduled_time2)
          end

          it "deletes the scheduled mails" do
            subject
            expect(ScheduledMailing.where(mailer_klass: "SubmitApplicationReminderMailer", legal_aid_application_id: laa.id)).to be_empty
          end
        end
      end

      context "delegated functions on at least one proceeding type" do
        let(:expected_date1) { Time.zone.local(2021, 6, 1, 9, 0, 0) }
        let(:expected_date2) { Time.zone.local(2021, 6, 8, 9, 0, 0) }

        context "scheduled mail already exists" do
          before do
            create(:scheduled_mailing, :waiting, legal_aid_application: laa, scheduled_at: scheduled_time1)
            create(:scheduled_mailing, :waiting, legal_aid_application: laa, scheduled_at: scheduled_time2)
          end

          it "replaces existing email with one with new date" do
            subject
            new_scheduled_mailings = ScheduledMailing.where(mailer_klass: "SubmitApplicationReminderMailer", legal_aid_application_id: laa.id)
            expect(new_scheduled_mailings.size).to eq 2
            expect(new_scheduled_mailings.map(&:scheduled_at)).to contain_exactly(expected_date1, expected_date2)
          end
        end

        context "no scheduled mail already exists" do
          it "creates a new scheduled mail" do
            expect { subject }.to change(ScheduledMailing, :count).by(2)
            new_scheduled_mailings = ScheduledMailing.where(mailer_klass: "SubmitApplicationReminderMailer", legal_aid_application_id: laa.id)
            expect(new_scheduled_mailings.size).to eq 2
            expect(new_scheduled_mailings.map(&:scheduled_at)).to contain_exactly(expected_date1, expected_date2)
          end
        end
      end
    end
  end
end
