require 'rails_helper'

RSpec.describe DestroyPurgeableService do

  let!(:nil_rec) { create :legal_aid_application, purgeable_on: nil }
  let!(:tomorrow_rec) { create :legal_aid_application, purgeable_on: Date.tomorrow.in_time_zone }
  let!(:yesterday_rec) { create :legal_aid_application, purgeable_on: Date.yesterday.in_time_zone }
  let!(:today_rec) { create :legal_aid_application, purgeable_on: Date.today.in_time_zone }

  before { described_class.call }

  describe '.call' do
    it 'does not delete records with null purgeable_on' do
      expect { LegalAidApplication.find(nil_rec.id) }.not_to raise_error ActiveRecord::RecordNotFound
    end

    it 'does not delete records with purgeable_on in the future' do
      expect { LegalAidApplication.find(tomorrow_rec.id) }.not_to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes records with purgeable_on in the past' do
      expect { LegalAidApplication.find(yesterday_rec.id) }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes records with purgeable_on today' do
      expect { LegalAidApplication.find(today_rec.id) }.to raise_error ActiveRecord::RecordNotFound
    end

  end
end
