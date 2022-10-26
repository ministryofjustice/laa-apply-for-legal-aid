require "rails_helper"

RSpec.describe Proceeding, type: :model do
  let(:matter_code) { "KSEC8" }
  let(:df_used) { nil }
  let(:df_date) { nil }
  let(:proceeding) do
    create(:proceeding,
           :da001,
           proceeding_case_id: 55_123_456,
           ccms_matter_code: matter_code,
           used_delegated_functions: df_used,
           used_delegated_functions_on: df_date)
  end

  it {
    is_expected.to respond_to(:legal_aid_application_id,
                              :proceeding_case_id,
                              :lead_proceeding,
                              :ccms_code,
                              :meaning,
                              :description,
                              :substantive_cost_limitation,
                              :delegated_functions_cost_limitation,
                              :substantive_scope_limitation_code,
                              :substantive_scope_limitation_meaning,
                              :substantive_scope_limitation_description,
                              :delegated_functions_scope_limitation_code,
                              :delegated_functions_scope_limitation_meaning,
                              :delegated_functions_scope_limitation_description,
                              :used_delegated_functions_on,
                              :used_delegated_functions_reported_on)
  }

  describe "#case_p_num" do
    it "returns formatted proceeding case id" do
      expect(proceeding.case_p_num).to eq "P_55123456"
    end
  end

  describe "#section8?" do
    context "with section 8 proceeding" do
      let(:proceeding) { create(:proceeding, :se014) }

      it "returns true" do
        expect(proceeding.section8?).to be true
      end
    end

    context "with non-section 8 proceeding" do
      let(:proceeding) { create(:proceeding, :da001) }

      it "returns false" do
        expect(proceeding.section8?).to be false
      end
    end
  end

  context "with domestic abuse" do
    let(:matter_code) { "MINJN" }

    it "returns false" do
      expect(proceeding.section8?).to be false
    end
  end

  describe "used_delegated_functions?" do
    subject(:used_delegated_functions?) { proceeding.used_delegated_functions? }

    context "when delegated functions question not answered" do
      it { is_expected.to be false }
    end

    context "when delegated functions not used" do
      let(:df_used) { false }
      let(:df_date) { nil }

      it { is_expected.to be false }
    end

    context "when delegated functions used" do
      let(:df_used) { true }
      let(:df_date) { Time.zone.yesterday }

      it { is_expected.to be true }
    end
  end

  describe "#delegated_functions_scope_limitation_meaning" do
    # TODO: This is TEMP for coverage
    # This was not being explicitly tested and caused a code-coverage drop, it can be
    # removed once the helper methods for single scope limitation values are removed from
    # the proceeding object
    subject(:delegated_functions_scope_limitation_meaning) { proceeding.delegated_functions_scope_limitation_meaning }

    it { is_expected.not_to be_nil }
  end

  describe "#proceeding_case_p_num" do
    it "prefixes the proceeding case id with P_" do
      legal_aid_application = create(:legal_aid_application, :with_proceedings)
      proceeding = legal_aid_application.proceedings.first
      allow(proceeding).to receive(:proceeding_case_id).and_return 55_200_301
      expect(proceeding.proceeding_case_p_num).to eq "P_55200301"
    end
  end
end
