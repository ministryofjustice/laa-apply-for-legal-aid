require "rails_helper"

RSpec.describe Flow::Steps::ProceedingsSCA::InterruptsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application, provider_step_params:) }
  let(:provider_step_params) { { type: } }
  let(:type) { "change_of_name" }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_sca_interrupt_path(legal_aid_application, type) }
  end
end
