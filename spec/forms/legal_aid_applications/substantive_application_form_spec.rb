require "rails_helper"

RSpec.describe LegalAidApplications::SubstantiveApplicationForm, type: :form do
  subject(:described_form) { described_class.new(params) }

  let(:used_delegated_functions_on) { 1.day.ago.to_date }
  let(:application) do
    create(:legal_aid_application, :applicant_details_checked)
  end
  let(:substantive_application) { false }
  let(:params) do
    {
      substantive_application: substantive_application.to_s,
      model: application,
    }
  end

  describe "#save" do
    it "updates application" do
      expect { described_form.save }
        .to change(application, :substantive_application)
        .from(nil)
        .to(substantive_application)
    end

    context "when setting the value to false" do
      it "does not set the substantive_application state of the application" do
        expect(described_form.save).to be true
        expect(application).not_to be_substantive_application
      end
    end

    context "when completing substantive application now selected" do
      let(:substantive_application) { true }

      it "updates application" do
        expect(described_form.save).to be true
        expect(application).to be_substantive_application
      end
    end

    context "with no entry" do
      let(:substantive_application) { "" }

      it "does not update application" do
        expect(described_form.save).to be false
        expect(application.substantive_application).to be_nil
      end
    end
  end
end
