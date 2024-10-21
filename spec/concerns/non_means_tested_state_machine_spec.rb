require "rails_helper"
require "aasm/rspec"

RSpec.describe NonMeansTestedStateMachine do
  subject(:state_machine) { legal_aid_application.state_machine }

  let(:legal_aid_application) { create(:legal_aid_application, :with_non_means_tested_state_machine) }

  it { expect(legal_aid_application).not_to be_applicant_entering_means }
  it { expect(legal_aid_application).not_to be_awaiting_applicant }
  it { expect(legal_aid_application).not_to be_provider_assessing_means }
  it { expect(legal_aid_application).not_to be_checking_passported_answers }
  it { expect(legal_aid_application).not_to be_checking_citizen_answers }
  it { expect(legal_aid_application).not_to be_checking_non_passported_means }
end
