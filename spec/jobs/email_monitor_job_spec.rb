require 'rails_helper'

RSpec.describe EmailMonitorJob, type: :job do
  describe 'perform' do
    let!(:waiting) { create :scheduled_mailing, :due }
    let!(:created) { create :scheduled_mailing, :created }
    let!(:processing) { create :scheduled_mailing, :processing }
    let!(:sending) { create :scheduled_mailing, :sending }

    it 'calls GovukEmails::Monitor for every scheduled mail record with a monitored status' do
      expect(GovukEmails::Monitor).to receive(:call).with(created.id)
      expect(GovukEmails::Monitor).to receive(:call).with(processing.id)
      expect(GovukEmails::Monitor).to receive(:call).with(sending.id)
      described_class.new.perform
    end

    context 'no subsequent job in queue' do
      let(:job) { double 'Job', perform_later: nil }

      before { allow(GovukEmails::Monitor).to receive(:call).at_least(1) }

      it 'schedules another job' do
        expect(JobQueue).to receive(:enqueued?).with(described_class).and_return(false)
        expect(described_class).to receive(:set).with(wait: EmailMonitorJob::DEFAULT_DELAY).and_return(job)
        described_class.new.perform
      end
    end

    context 'subsequen monitor job already in queue' do
      before { allow(GovukEmails::Monitor).to receive(:call).at_least(1) }

      it 'does not schedule another job' do
        expect(JobQueue).to receive(:enqueued?).with(described_class).and_return(true)
        expect(described_class).not_to receive(:set)
        described_class.new.perform
      end
    end
  end
end
