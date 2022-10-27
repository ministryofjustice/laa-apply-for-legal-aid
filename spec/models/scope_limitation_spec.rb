require "rails_helper"

RSpec.describe ScopeLimitation do
  subject { described_class.new }

  it { is_expected.to define_enum_for(:scope_type).with_values(%i[substantive emergency]) }

  describe "#description" do
    subject(:sl_description) { scope_limitation.description }

    let(:scope_limitation) { create(:scope_limitation, :substantive) }

    it { is_expected.to eq "Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order." }

    context "when a hearing date has been set" do
      let(:scope_limitation) { create(:scope_limitation, :emergency_cv118, hearing_date: Date.yesterday) }

      it { is_expected.to eq "Limited to all steps up to and including the hearing on #{Date.yesterday.strftime('%e %B %Y')}" }
    end

    context "when a limitation_note has been set" do
      let(:scope_limitation) { create(:scope_limitation, :substantive_CV119, limitation_note: "a handwriting expert") }

      it { is_expected.to eq "Limited to obtaining a report from a handwriting expert" }
    end

    context "when a hearing date is required but has not been set" do
      # this test simulates the live service before the feature flag is enabled
      let(:scope_limitation) { create(:scope_limitation, :emergency_cv118, hearing_date: nil) }

      it { is_expected.to eq "Limited to all steps up to and including the hearing on [see additional limitation notes]" }
    end
  end
end
