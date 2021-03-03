require 'rails_helper'

RSpec.describe ScheduledMailing do
  let(:mailer_klass) { 'NotifyMailer' }
  let(:mailer_method) { 'notify' }
  let(:legal_aid_application) { create :legal_aid_application }
  let(:addressee) { Faker::Internet.safe_email }
  let(:mailer_args) { [:one, :two, 'three'] }
  let(:frozen_time) { Time.zone.now }
  let(:future_time) { 2.hours.from_now }

  describe '.send_now' do
    subject do
      described_class.send_now!(mailer_klass: mailer_klass,
                                mailer_method: mailer_method,
                                legal_aid_application_id: legal_aid_application.id,
                                addressee: addressee,
                                arguments: mailer_args)
    end

    it 'creates a record in waiting state' do
      travel_to frozen_time

      expect { subject }.to change { ScheduledMailing.count }.by(1)
      rec = ScheduledMailing.first
      expect(rec.mailer_klass).to eq mailer_klass
      expect(rec.legal_aid_application_id).to eq legal_aid_application.id
      expect(rec.mailer_method).to eq mailer_method
      expect(rec.arguments).to eq mailer_args
      expect(rec.addressee).to eq addressee
      expect(rec.scheduled_at.to_i).to eq frozen_time.to_i
      expect(rec.status).to eq 'waiting'

      travel_back
    end
  end

  describe '.send_later!' do
    subject do
      described_class.send_later!(mailer_klass: mailer_klass,
                                  mailer_method: mailer_method,
                                  legal_aid_application_id: legal_aid_application.id,
                                  addressee: addressee,
                                  arguments: mailer_args,
                                  scheduled_at: future_time)
    end

    it 'creates a record in waiting state with a scheduled time' do
      expect { subject }.to change { ScheduledMailing.count }.by(1)
      rec = ScheduledMailing.first
      expect(rec.mailer_klass).to eq mailer_klass
      expect(rec.mailer_method).to eq mailer_method
      expect(rec.legal_aid_application_id).to eq legal_aid_application.id
      expect(rec.arguments).to eq mailer_args
      expect(rec.addressee).to eq addressee
      expect(rec.scheduled_at.to_i).to eq future_time.to_i
      expect(rec.status).to eq 'waiting'
    end
  end

  describe '#cancel' do
    let(:rec) { create :scheduled_mailing }
    it 'updates the cancelled at column' do
      travel_to frozen_time
      rec.cancel!
      expect(rec.cancelled_at.to_i).to eq frozen_time.to_i
      travel_back
    end
  end

  describe '#waiting?' do
    context 'waiting' do
      it 'returns true' do
        rec = create :scheduled_mailing, :due
        expect(rec.waiting?).to be true
      end
    end

    context 'not waiting' do
      it 'returns true' do
        rec = create :scheduled_mailing, :delivered
        expect(rec.waiting?).to be false
      end
    end
  end

  describe 'scopes' do
    let!(:waiting_due) { create :scheduled_mailing, :due }
    let!(:waiting_due_later) { create :scheduled_mailing, :due_later }
    let!(:processing) { create :scheduled_mailing, :processing }
    let!(:failed) { create :scheduled_mailing, :failed }
    let!(:created) { create :scheduled_mailing, :created }
    let!(:sending) { create :scheduled_mailing, :sending }

    describe 'waiting' do
      it 'picks only waiting status' do
        expect(ScheduledMailing.waiting).to match_array [waiting_due, waiting_due_later]
      end
    end

    describe :past_due do
      it 'picks only records where scheduled at is in the past' do
        expect(ScheduledMailing.past_due).to match_array [waiting_due]
      end
    end

    describe 'monitored' do
      it 'picks only records in processing, created, sending states' do
        expect(ScheduledMailing.monitored).to match_array [processing, created, sending]
      end
    end
  end
end
