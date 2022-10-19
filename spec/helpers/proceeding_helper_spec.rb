require "rails_helper"

RSpec.describe ProceedingHelper, type: :helper do
  describe "#position_in_array" do
    subject(:array_position) { position_in_array(proceeding) }

    context "when an application has two proceedings" do
      let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceedings_inc_section8 }

      context "and the first is passed to the helper" do
        let(:proceeding) { legal_aid_application.proceedings.in_order_of_addition.first }

        it { is_expected.to eq "Proceeding 1 of 2" }
      end

      context "and the second is passed to the helper" do
        let(:proceeding) { legal_aid_application.proceedings.in_order_of_addition.last }

        it { is_expected.to eq "Proceeding 2 of 2" }
      end
    end

    context "when an application has a single proceeding" do
      let(:legal_aid_application) { create :legal_aid_application, :with_proceedings }

      context "and the first is passed to the helper" do
        let(:proceeding) { legal_aid_application.proceedings.in_order_of_addition.first }

        it { is_expected.to eq "Proceeding 1" }
      end
    end
  end

  describe "#scope_limits" do
    subject(:scope_limitations) { scope_limits(proceeding, scope_type) }

    let(:proceeding) { create :proceeding, :se013, no_scope_limitations: true, scope_limitations: [scope_limitation1, scope_limitation2, scope_limitation3, scope_limitation4] }
    let(:scope_limitation1) { create :scope_limitation, :emergency_cv118, hearing_date: Date.yesterday }
    let(:scope_limitation2) { create :scope_limitation, :emergency }
    let(:scope_limitation3) { create :scope_limitation, :substantive }
    let(:scope_limitation4) { create :scope_limitation, :substantive_CV119, limitation_note: "a handwriting expert" }

    context "when scope type is emergency" do
      let(:scope_type) { "emergency" }

      it { is_expected.to eq ["Hearing<br>Date: #{Date.yesterday.strftime('%e %B %Y')}", "Interim order inc. return date"] }
    end

    context "when scope type is substantive" do
      let(:scope_type) { "substantive" }

      it { is_expected.to eq ["Final hearing", "General Report<br>Note: a handwriting expert"] }
    end
  end
end
