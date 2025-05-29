require "rails_helper"

RSpec.describe HasOtherProceedingsHelper do
  let(:output) do
    [
      instance_double(LegalFramework::ProceedingTypes::All::ProceedingTypeStruct, ccms_code: "SE004", ccms_matter_code: "KSEC8", meaning: "Specific issue order"),
      instance_double(LegalFramework::ProceedingTypes::All::ProceedingTypeStruct, ccms_code: "SE013", ccms_matter_code: "KSEC8", meaning: "Child arrangements order (CAO) - contact"),
      instance_double(LegalFramework::ProceedingTypes::All::ProceedingTypeStruct, ccms_code: "PBM17", ccms_matter_code: "KPBLB", meaning: "Specific issue order"),
      instance_double(LegalFramework::ProceedingTypes::All::ProceedingTypeStruct, ccms_code: "PBM38", ccms_matter_code: "KPBLB", meaning: "Child arrangements order (CAO) - contact"),
      instance_double(LegalFramework::ProceedingTypes::All::ProceedingTypeStruct, ccms_code: "DA001", ccms_matter_code: "MINJN", meaning: "Specific issue order"),
      instance_double(LegalFramework::ProceedingTypes::All::ProceedingTypeStruct, ccms_code: "DA002", ccms_matter_code: "MINJN", meaning: "Specific issue order"),
    ]
  end

  describe ".show_check_proceeding_warning?" do
    subject(:show_check_proceeding_warning) { helper.show_check_proceeding_warning?(legal_aid_application) }

    before do
      allow(LegalFramework::ProceedingTypes::All).to receive(:call).and_return(output)
    end

    context "when at least one proceeding is selected which should show a warning" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[se004 se013]) }

      it { is_expected.to be true }
    end

    context "when no proceedings which should show a warning are selected" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 da002]) }

      it { is_expected.to be false }
    end
  end
end
