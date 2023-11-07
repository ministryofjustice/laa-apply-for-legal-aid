require "rails_helper"

RSpec.describe EmailMonitorJob do
  describe "perform" do
    before { create(:scheduled_mailing, :due) }

    let(:created) { create(:scheduled_mailing, :created) }
    let(:processing) { create(:scheduled_mailing, :processing) }
    let(:sending) { create(:scheduled_mailing, :sending) }

    it "calls GovukEmails::Monitor for every scheduled mail record with a monitored status" do
      expect(GovukEmails::Monitor).to receive(:call).with(created.id)
      expect(GovukEmails::Monitor).to receive(:call).with(processing.id)
      expect(GovukEmails::Monitor).to receive(:call).with(sending.id)
      described_class.new.perform
    end
  end
end
