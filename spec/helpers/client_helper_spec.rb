require "rails_helper"

RSpec.describe ClientHelper do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application, applicant:) }
  let(:applicant) { build_stubbed(:applicant) }

  describe "means_tested_description" do
    subject(:means_tested) { means_tested_description(legal_aid_application) }

    context "when the client is means tested" do
      it { is_expected.to eql("Yes") }
    end

    context "when the client is not means tested because they are under 18" do
      before { allow(applicant).to receive(:under_18?).and_return(true) }

      it { is_expected.to eql("No, client under 18") }
    end

    context "when the client is not means tested because they are under 18 and it's an SCA application" do
      before do
        allow(legal_aid_application).to receive(:special_children_act_proceedings?).and_return(true)
        allow(applicant).to receive(:under_18?).and_return(true)
      end

      it { is_expected.to eql("No, SCA application") }
    end

    context "when the client is not means tested because it's an SCA application" do
      before { allow(legal_aid_application).to receive(:special_children_act_proceedings?).and_return(true) }

      it { is_expected.to eql("No, SCA application") }
    end
  end
end
