require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::VaryOrderForm do
  subject(:form) { described_class.new(params) }

  let(:params) { { details: } }
  let(:details) { "Some input details" }

  it { is_expected.to respond_to(:details, :proceeding_id) }

  describe "#valid?" do
    context "when details present" do
      let(:details) { "I'd like to vary the orginal order of the court because..." }

      it { is_expected.to be_valid }
    end

    context "when details absent" do
      let(:details) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
