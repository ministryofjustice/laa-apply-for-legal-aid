require "rails_helper"

RSpec.describe ProceedingHelper, type: :helper do
  describe "#position_in_array" do
    subject(:array_position) { position_in_array(proceeding) }

    context "when an application has two proceedings" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }

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
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings) }

      context "and the first is passed to the helper" do
        let(:proceeding) { legal_aid_application.proceedings.in_order_of_addition.first }

        it { is_expected.to eq "Proceeding 1" }
      end
    end
  end

  describe "#scope_limits" do
    subject(:scope_limitations) { scope_limits(proceeding, scope_type) }

    let(:emergency_scope_limitations) do
      [
        create(
          :scope_limitation,
          :emergency,
          meaning: "Special hearing",
          hearing_date: Date.new(2022, 12, 25),
        ),
        create(
          :scope_limitation,
          :emergency_cv118,
          meaning: "Interim order",
        ),
      ]
    end

    let(:substantive_scope_limitations) do
      [
        create(
          :scope_limitation,
          :substantive,
          meaning: "Final heading",
        ),
        create(
          :scope_limitation,
          :substantive,
          meaning: "General report",
          limitation_note: "This is a note",
        ),
      ]
    end

    let(:proceeding) do
      create(
        :proceeding,
        :se013,
        no_scope_limitations: true,
        scope_limitations: emergency_scope_limitations + substantive_scope_limitations,
      )
    end

    context "when scope type is emergency" do
      let(:scope_type) { "emergency" }

      it "returns only the emergency scope limitation meanings" do
        expect(scope_limitations).to contain_exactly(
          "Special hearing<br>Date: 25 December 2022",
          "Interim order",
        )
      end
    end

    context "when scope type is substantive" do
      let(:scope_type) { "substantive" }

      it "returns only the substantive scope limitation meanings" do
        expect(scope_limitations).to contain_exactly(
          "Final heading",
          "General report<br>Note: This is a note",
        )
      end
    end
  end
end
