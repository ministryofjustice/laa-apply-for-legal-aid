require 'rails_helper'

RSpec.describe CCMS::SubmissionProcessWorker do
  let(:state) { :initialised }
  let(:submission) { create :submission, aasm_state: state }
  let(:worker) { described_class.new }

  before { allow(CCMS::Submission).to receive(:find).with(submission.id).and_return(submission) }

  subject { worker.perform(submission.id, state) }

  it 'calls process! on the submission' do
    expect(submission).to receive(:process!)
    subject
  end

  context 'the state has changed' do
    let(:submission) { create :submission, aasm_state: :initialised }
    let(:state) { :case_ref_obtained }

    it 'does nothing' do
      expect(submission).not_to receive(:process!)
      subject
    end
  end
end
