require 'rails_helper'

module Dashboard
  RSpec.describe ApplicantEmailJob do
    describe '.perform' do
      let(:application) { create :legal_aid_application, :with_applicant }
      let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }
      subject { described_class.perform_now(application) }

      let(:geckoboard_client) { double Geckoboard::Client }
      let(:datasets_client) { double Geckoboard::DatasetsClient }
      let(:dataset) { double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive(:ping).and_return(true)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
      end

      describe '#perform' do
        context 'job is not in the suspended list' do
          before { allow(HostEnv).to receive(:environment).and_return(:production) }
          it 'calls the applicant email job' do
            expect_any_instance_of(Dashboard::SingleObject::ApplicantEmail).to receive(:run)
            subject
          end
        end

        context 'job is in the suspended list' do
          before { allow(HostEnv).to receive(:environment).and_return(:development) }
          it 'does not call the applicant email job' do
            expect_any_instance_of(Dashboard::SingleObject::ApplicantEmail).not_to receive(:run)
            subject
          end
        end

        context 'job is sending email to an Apply team email' do
          let(:applicant) { create :applicant, email: Rails.configuration.x.email_domain.suffix }
          let(:application) { create :legal_aid_application, applicant: applicant }
          before { allow(HostEnv).to receive(:environment).and_return(:production) }

          context 'in production environment' do
            before { allow(Rails.env).to receive(:production?).and_return(true) }

            it 'does not call the applicant email job' do
              expect_any_instance_of(Dashboard::SingleObject::ApplicantEmail).not_to receive(:run)
              subject
            end
          end

          context 'not in production environment' do
            before { allow(Rails.env).to receive(:production?).and_return(false) }

            it 'calls the applicant email job' do
              expect_any_instance_of(Dashboard::SingleObject::ApplicantEmail).to receive(:run)
              subject
            end
          end
        end
      end
    end
  end
end
