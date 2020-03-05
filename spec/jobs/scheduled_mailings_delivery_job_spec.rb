require 'rails_helper'

RSpec.describe ScheduledMailingsDeliveryJob, type: :job do
  subject { described_class.new.perform }

  describe 'ScheduledMailingsDeliveryJob' do
    let!(:mailing_one) { create :scheduled_mailing, scheduled_at: 3.days.ago }
    let!(:mailing_two) { create :scheduled_mailing }

    it 'calls deliver on each due item' do
      expect_any_instance_of(ScheduledMailing).to receive(:deliver!) do |arg|
        expect(arg.id).to eq mailing_one.id
      end
      subject
    end
  end
end
