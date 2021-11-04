require 'rails_helper'

RSpec.describe MarkPurgeableService do
  describe '.call' do
    let!(:old1) { create :legal_aid_application, updated_at: 24.months.ago }
    let!(:old2) { create :legal_aid_application, updated_at: 23.months.ago - 1.day }
    let!(:new1) { create :legal_aid_application, updated_at: 23.months.ago + 1.day }
    let!(:new2) { create :legal_aid_application, updated_at: 6.months.ago }

    it 'marks all records not updated for 23 months as purgeable' do
      described_class.call
      expect(old1.reload.purgeable?).to be true
      expect(old2.reload.purgeable?).to be true
      expect(new1.reload.purgeable?).to be false
      expect(new2.reload.purgeable?).to be false
    end
  end
end
