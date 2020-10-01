require 'rails_helper'

module Dashboard
  RSpec.describe FeedbackItemJob do
    describe '.perform' do
      let(:feedback) { create :feedback, :from_provider, satisfaction: 2, difficulty: 4 }
      let(:suspended_list) { Rails.configuration.x.suspended_dashboard_updater_jobs }
      subject { described_class.perform_now(feedback) }

      let(:geckoboard_client) { double Geckoboard::Client }
      let(:datasets_client) { double Geckoboard::DatasetsClient }
      let(:dataset) { double Geckoboard::Dataset }

      before do
        allow(Geckoboard).to receive(:client).and_return(geckoboard_client)
        allow(geckoboard_client).to receive(:ping).and_return(true)
        allow(geckoboard_client).to receive(:datasets).and_return(datasets_client)
        allow(Rails.configuration.x.suspended_dashboard_updater_jobs).to receive(:include?).with('Dashboard::FeedbackItemJob').and_return(false)
      end

      describe '#perform' do
        context 'job is not in the suspended list' do
          before { allow(HostEnv).to receive(:environment).and_return(:production) }
          it 'calls the runs the geckoboard feedback updater' do
            expect_any_instance_of(Dashboard::SingleObject::Feedback).to receive(:run)
            subject
          end
        end

        context 'job is not in the suspended list' do
          before { allow(HostEnv).to receive(:environment).and_return(:uat) }
          it 'calls the runs the geckoboard feedback updater' do
            expect_any_instance_of(Dashboard::SingleObject::Feedback).not_to receive(:run)
            subject
          end
        end
      end
    end
  end
end
