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
end
