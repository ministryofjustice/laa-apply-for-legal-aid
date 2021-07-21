require 'rails_helper'

RSpec.describe CCMSRestartSubmissions do
  subject(:restart_submissions) { described_class.call }

  context 'when no submissions are paused' do
    it { is_expected.to eql 'No paused submissions found' }
  end

  context 'when two applications are paused' do
    before do
      create_list :legal_aid_application, 2, :submission_paused
    end

    it { is_expected.to eql '2 CCMS submissions restarted' }

    it 'changes the states to submitting_assessment' do
      subject
      expect(LegalAidApplication.first.reload.state).to eql 'submitting_assessment'
      expect(LegalAidApplication.last.reload.state).to eql 'submitting_assessment'
    end
  end
end
