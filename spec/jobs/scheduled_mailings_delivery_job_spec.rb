require 'rails_helper'

RSpec.describe ScheduledMailingsDeliveryJob, type: :job do
  subject{ described_class.new.perform }

  describe 'ScheduledMailingsDeliveryJob' do
    let!(:mailing_one) { create :scheduled_mailing, :due }
    let!(:mailing_two) { create :scheduled_mailing }

    it 'calls deliver on each due item' do
      expect_any_instance_of(ScheduledMailing).to receive(:deliver!).and_call_original
      subject
      expect(mailing_one.reload.sent_at).not_to be_nil
      expect(mailing_two.reload.sent_at).to be_nil
    end
  end
end
