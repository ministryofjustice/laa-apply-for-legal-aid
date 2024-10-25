require "rails_helper"

RSpec.describe DashboardEventHandler do
  context "when an unrecognised dashboard event is sent" do
    it "raises" do
      expect {
        ActiveSupport::Notifications.instrument "dashboard.zzzzz"
      }.to raise_error DashboardEventHandler::UnrecognisedEventError, "Unrecognised event: dashboard.zzzzz"
    end
  end

  context "when an unrecognized non-dashboard event is sent" do
    it "does not raise" do
      expect {
        ActiveSupport::Notifications.instrument "other_category.zzzzz"
      }.not_to raise_error
    end
  end

  context "when an application is created" do
    before do
      allow_any_instance_of(described_class).to receive(:provider_updated)
      allow_any_instance_of(described_class).to receive(:firm_created)
    end

    it "fires an application_created event" do
      expect_any_instance_of(described_class).to receive(:application_created).and_call_original
      expect(Dashboard::UpdaterJob).to receive(:perform_later).with("Applications").at_least(:once)

      create(:legal_aid_application)
    end
  end

  context "when a provider is updated" do
    before do
      allow_any_instance_of(described_class).to receive(:firm_created)
    end

    it "fires a ProviderDataJob event" do
      expect_any_instance_of(described_class).to receive(:provider_updated).and_call_original
      expect(Dashboard::ProviderDataJob).to receive(:perform_later).at_least(:once)

      create(:provider)
    end
  end

  context "when a firm is created" do
    it "fires a NumberProviderFirms job" do
      expect(Dashboard::UpdaterJob).to receive(:perform_later).with("NumberProviderFirms")
      create(:firm)
    end
  end

  context "when a ccms_submission is saved" do
    subject(:create_ccms_submission) { create(:ccms_submission, aasm_state: state) }

    before { ActiveJob::Base.queue_adapter = :test }

    after { ActiveJob::Base.queue_adapter = :sidekiq }

    context "and saved with state initialised" do
      let(:state) { "initialised" }

      it "does not fire additional Application jobs" do
        # one is fired from creating the LegalAidApplication required by the ccms_submission factory
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("Applications").at_most(1).times
      end

      it "fires PendingCCMSSubmissions job" do
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("PendingCCMSSubmissions").once
      end
    end

    context "and saved with state failed" do
      let(:state) { "failed" }

      it "fires the Applications job" do
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("Applications").at_least(1).times
      end

      it "fires PendingCCMSSubmissions job" do
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("PendingCCMSSubmissions").once
      end
    end

    context "and saved with state completed" do
      let(:state) { "completed" }

      it "fires the Applications job" do
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("Applications").at_least(1).times
      end

      it "fires the PendingCCMSSubmissions job" do
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("PendingCCMSSubmissions").once
      end
    end

    context "and saved with state abandoned" do
      let(:state) { "abandoned" }

      it "does not fire additional Application jobs" do
        # one is fired from creating the LegalAidApplication required by the ccms_submission factory
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("Applications").at_most(1).times
      end

      it "fires the PendingCCMSSubmissions job" do
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("PendingCCMSSubmissions").once
      end
    end

    context "and saved with document_ids_obtained" do
      let(:state) { "document_ids_obtained" }

      it "does not fire additional Application jobs" do
        # one is fired from creating the LegalAidApplication required by the ccms_submission factory
        expect { create_ccms_submission }.to have_enqueued_job(Dashboard::UpdaterJob).with("Applications").at_most(1).times
      end

      it "does not fire a PendingCCMSSubmissions job" do
        expect { create_ccms_submission }.not_to have_enqueued_job(Dashboard::UpdaterJob).with("PendingCCMSSubmissions")
      end
    end
  end

  context "when feedback is created" do
    it "fires the FeedbackItemJob job" do
      expect(Dashboard::FeedbackItemJob).to receive(:perform_later)
      create(:feedback)
    end
  end

  context "when an application is completed" do
    let(:legal_aid_application) do
      create(:legal_aid_application, :with_proceedings,
             :with_delegated_functions_on_proceedings,
             explicit_proceedings: [:da004],
             df_options: { DA004: [rand(12).days.ago.to_date, Time.zone.now] })
    end

    before do
      allow_any_instance_of(described_class).to receive(:firm_created)
      allow_any_instance_of(described_class).to receive(:provider_updated).and_call_original
      allow_any_instance_of(described_class).to receive(:application_created)
    end

    it "fires the submitted applications job" do
      expect(Dashboard::ProviderDataJob).to receive(:perform_later).at_least(:once)
      expect(Dashboard::UpdaterJob).to receive(:perform_later).with("Applications").at_least(:once)
      legal_aid_application.merits_complete!
    end
  end
end
