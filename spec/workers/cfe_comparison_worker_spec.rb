require "rails_helper"
require "sidekiq/testing"

RSpec.describe CFEComparisonWorker do
  subject(:perform) { described_class.new.perform }

  let(:cfe_compare) { instance_double(CFE::CompareResults) }

  before { allow(CFE::CompareResults).to receive(:call).and_return(cfe_compare) }

  it "calls the CFE bulk comparison" do
    expect(CFE::CompareResults).to receive(:call).once
    perform
  end

  context "when run before the target time" do
    it "schedules another run at 8pm for the same day" do
      travel_to(Time.zone.now.change(hour: 14, minute: 0)) do
        expected_date = Time.zone.now.change(hour: 20)
        expect { perform }.to change(described_class.jobs, :size).by(1)
        expect(described_class).to have_enqueued_sidekiq_job.at(expected_date)
      end
    end
  end

  context "when run at the scheduled time" do
    it "schedules another run at 8pm the following day" do
      travel_to(Time.zone.now.change(hour: 20, minute: 0)) do
        expected_date = Time.zone.now.advance(days: 1).change(hour: 20)
        expect { perform }.to change(described_class.jobs, :size).by(1)
        expect(described_class).to have_enqueued_sidekiq_job.at(expected_date)
      end
    end
  end
end
