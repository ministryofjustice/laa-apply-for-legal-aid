require "rails_helper"

module Dashboard
  RSpec.describe ApplicantEmailJob do
    describe ".perform" do
      subject(:applicant_email_job) { described_class.perform_now(application) }

      let(:application) { create(:legal_aid_application, :with_applicant) }
      let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }

      let(:geckoboard_client) { instance_double Geckoboard::Client }
      let(:datasets_client) { instance_double Geckoboard::DatasetsClient }
      let(:dataset) { instance_double Geckoboard::Dataset }
      let(:applicant_email) { instance_double(Dashboard::SingleObject::ApplicantEmail) }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive_messages(ping: true, datasets: datasets_client)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
        allow(Dashboard::SingleObject::ApplicantEmail).to receive(:new).and_return(applicant_email)
      end

      describe "#perform" do
        context "when job is not in the suspended list" do
          before { allow(HostEnv).to receive(:environment).and_return(:production) }

          it "calls the applicant email job" do
            expect(applicant_email).to receive(:run)
            applicant_email_job
          end
        end

        context "when job is in the suspended list" do
          before { allow(HostEnv).to receive(:environment).and_return(:development) }

          it "does not call the applicant email job" do
            expect(applicant_email).not_to receive(:run)
            applicant_email_job
          end
        end

        context "when job is sending email to an Apply team email" do
          let(:applicant) { create(:applicant, email: Rails.configuration.x.email_domain.suffix) }
          let(:application) { create(:legal_aid_application, applicant:) }

          before { allow(HostEnv).to receive(:environment).and_return(:production) }

          context "when in production environment" do
            before { allow(Rails.env).to receive(:production?).and_return(true) }

            it "does not call the applicant email job" do
              expect(applicant_email).not_to receive(:run)
              applicant_email_job
            end
          end

          context "when not in production environment" do
            before { allow(Rails.env).to receive(:production?).and_return(false) }

            it "calls the applicant email job" do
              expect(applicant_email).to receive(:run)
              applicant_email_job
            end
          end
        end
      end
    end
  end
end
