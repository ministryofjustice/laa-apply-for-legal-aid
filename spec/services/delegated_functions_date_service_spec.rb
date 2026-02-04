require "rails_helper"

RSpec.describe DelegatedFunctionsDateService do
  describe "sets date on proceeding records" do
    subject(:call) { described_class.call(laa) }

    let(:laa) { create(:legal_aid_application) }
    let(:df_used?) { true }
    let(:df_date) { Date.new(2021, 5, 10) }
    let(:reported_date) { Date.new(2021, 5, 13) }
    let(:bank_holidays_cache) { Redis.new(url: Rails.configuration.x.redis.bank_holidays_url) }

    before do
      create(:proceeding, :da001,
             legal_aid_application: laa,
             used_delegated_functions: df_used?,
             used_delegated_functions_on: df_date,
             used_delegated_functions_reported_on: reported_date)
      create(:proceeding, :se013, legal_aid_application: laa)
      bank_holidays_cache.flushdb
      stub_bankholiday_legacy_success
    end

    after do
      bank_holidays_cache.flushdb
      bank_holidays_cache.quit
    end

    around do |example|
      travel_to Time.zone.local(2021, 5, 13, 12, 0, 0)
      example.run
      travel_back
    end

    it "returns true" do
      expect(call).to be true
    end

    describe "sets the substantive_application_deadline_on date" do
      context "when DF are used on at least one proceeding type" do
        let(:df_date) { Date.new(2021, 5, 10) }
        let(:reported_date) { Date.new(2021, 5, 13) }
        let(:expected_deadline) { Date.new(2021, 6, 8) }

        it "sets the substantive_application_deadline_on date" do
          call
          expect(laa.reload.substantive_application_deadline_on).to eq expected_deadline
        end
      end

      context "when no DF used on any proceeding type" do
        let(:df_used?) { nil }
        let(:df_date) { nil }
        let(:reported_date) { nil }

        it "sets the substantive application_deadline_on to nil" do
          call
          expect(laa.reload.substantive_application_deadline_on).to be_nil
        end
      end
    end

    describe "scheduling reminder mails" do
      let(:scheduled_time1) { Time.zone.local(2021, 5, 30, 9, 0, 0) }
      let(:scheduled_time2) { Time.zone.local(2021, 5, 25, 9, 0, 0) }

      context "when no delegated functions on any proceeding type" do
        let(:df_used?) { false }
        let(:df_date) { nil }
        let(:reported_date) { nil }

        context "and a scheduled mail already exists" do
          before do
            create(:scheduled_mailing, :waiting, legal_aid_application: laa, scheduled_at: scheduled_time1)
            create(:scheduled_mailing, :waiting, legal_aid_application: laa, scheduled_at: scheduled_time2)
          end

          it "deletes the scheduled mails" do
            call
            expect(ScheduledMailing.where(mailer_klass: "SubmitApplicationReminderMailer", legal_aid_application_id: laa.id)).to be_empty
          end
        end
      end

      context "when delegated functions on at least one proceeding type" do
        let(:expected_date1) { Time.zone.local(2021, 6, 1, 9, 0, 0) }
        let(:expected_date2) { Time.zone.local(2021, 6, 8, 9, 0, 0) }

        context "and scheduled mail already exists" do
          before do
            create(:scheduled_mailing, :waiting, legal_aid_application: laa, scheduled_at: scheduled_time1)
            create(:scheduled_mailing, :waiting, legal_aid_application: laa, scheduled_at: scheduled_time2)
          end

          it "replaces existing email with one with new date" do
            call
            new_scheduled_mailings = ScheduledMailing.where(mailer_klass: "SubmitApplicationReminderMailer", legal_aid_application_id: laa.id)
            expect(new_scheduled_mailings.size).to eq 2
            expect(new_scheduled_mailings.map(&:scheduled_at)).to contain_exactly(expected_date1, expected_date2)
          end
        end

        context "when no scheduled mail already exists" do
          it "creates a new scheduled mail" do
            expect { call }.to change(ScheduledMailing, :count).by(2)
            new_scheduled_mailings = ScheduledMailing.where(mailer_klass: "SubmitApplicationReminderMailer", legal_aid_application_id: laa.id)
            expect(new_scheduled_mailings.size).to eq 2
            expect(new_scheduled_mailings.map(&:scheduled_at)).to contain_exactly(expected_date1, expected_date2)
          end
        end
      end
    end
  end
end
