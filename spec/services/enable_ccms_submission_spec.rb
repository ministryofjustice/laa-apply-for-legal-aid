require 'rails_helper'

RSpec.describe EnableCCMSSubmission do
  subject(:enable_ccms_submission) { described_class.call }
  before do
    allow(Rails.configuration.x.ccms_soa).to receive(:submit_applications_to_ccms).and_return(allow_ccms_submission_var)
    allow(Setting).to receive(:enable_ccms_submission?).and_return(allow_ccms_submission_setting)
  end

  context 'when both the setting and env_var is true' do
    let(:allow_ccms_submission_setting) { true }
    let(:allow_ccms_submission_var) { true }

    it { is_expected.to be true }
  end

  context 'when the setting is false and the env_var is true' do
    let(:allow_ccms_submission_setting) { false }
    let(:allow_ccms_submission_var) { true }

    it { is_expected.to be false }
  end

  context 'when the setting is true and the env_var is false' do
    let(:allow_ccms_submission_setting) { true }
    let(:allow_ccms_submission_var) { false }

    it { is_expected.to be false }
  end
end
