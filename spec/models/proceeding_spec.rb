require "rails_helper"

RSpec.describe Proceeding do
  let(:matter_code) { "KSEC8" }
  let(:df_used) { nil }
  let(:df_date) { nil }
  let(:emergency_level_of_service) { nil }

  let(:proceeding) do
    create(:proceeding,
           :da001,
           proceeding_case_id: 55_123_456,
           ccms_matter_code: matter_code,
           used_delegated_functions: df_used,
           used_delegated_functions_on: df_date,
           emergency_level_of_service:)
  end

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

  describe "#proceeding_case_p_num" do
    it "prefixes the proceeding case id with P_" do
      legal_aid_application = create(:legal_aid_application, :with_proceedings)
      proceeding = legal_aid_application.proceedings.first
      allow(proceeding).to receive(:proceeding_case_id).and_return 55_200_301
      expect(proceeding.proceeding_case_p_num).to eq "P_55200301"
    end
  end

  describe "#family_help_higher?" do
    subject { proceeding.family_help_higher? }

    context "when emergency level of service is 1" do
      let(:emergency_level_of_service) { 1 }

      it { is_expected.to be true }
    end

    context "when emergency level of service is not 1" do
      let(:emergency_level_of_service) { 3 }

      it { is_expected.to be false }
    end
  end

  describe "#full_representation?" do
    subject { proceeding.full_representation? }

    context "when emergency level of service is 3" do
      let(:emergency_level_of_service) { 3 }

      it { is_expected.to be true }
    end

    context "when emergency level of service is not 1" do
      let(:emergency_level_of_service) { 1 }

      it { is_expected.to be false }
    end
  end

  describe "#emergency_final_hearing" do
    subject { proceeding.emergency_final_hearing }

    context "when there is already an emergency final hearing" do
      let(:final_hearing) { create(:final_hearing, proceeding: proceeding, work_type: :emergency) }

      before do
        final_hearing
      end

      it "returns the existing record (does not build a new one)" do
        expect(proceeding.emergency_final_hearing).to eq(final_hearing)
        expect(FinalHearing.count).to eq 1
      end
    end

    context "when no emergency final hearings exist" do
      it "builds but does not save a new emergency final hearing" do
        expect(proceeding.emergency_final_hearing).to be_new_record
        expect(FinalHearing.count).to eq 0
      end
    end
  end
end
