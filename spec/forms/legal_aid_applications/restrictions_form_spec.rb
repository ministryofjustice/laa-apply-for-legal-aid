require "rails_helper"

RSpec.describe LegalAidApplications::RestrictionsForm, type: :form do
  subject(:described_form) { described_class.new(form_params) }

  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:restrictions_details) { Faker::Lorem.paragraph }
  let(:has_restrictions) { "true" }
  let(:params) do
    {
      has_restrictions:,
      restrictions_details:,
    }
  end
  let(:form_params) { params.merge(model: application) }

  describe "#save" do
    before do
      described_form.save!
      application.reload
    end

    it "updates applications" do
      expect(application.restrictions_details).to eq restrictions_details
    end

    it "updates applications has restriction" do
      expect(application.has_restrictions).to be true
    end

    context "when there are no restrictions" do
      let(:has_restrictions) { "false" }
      let(:restrictions_details) { "" }

      it "saves false into has restrictions" do
        expect(application.has_restrictions).to be false
      end

      it "does not add restrictions details" do
        expect(application.restrictions_details).to be_empty
      end
    end

    context "with invalid params" do
      let(:has_restrictions) { "true" }
      let(:restrictions_details) { "" }

      it "is invalid" do
        expect(described_form).not_to be_valid
      end

      it "generates the expected error message" do
        expect(described_form.errors[:restrictions_details]).to include "Enter the assets your client cannot sell or borrow against, and why"
      end

      context "with no restrictions present" do
        let(:has_restrictions) { "" }

        it "is invalid" do
          expect(described_form).not_to be_valid
        end

        it "generates the expected error message" do
          expect(described_form.errors[:has_restrictions]).to include "Select yes if your client is prohibited from selling or borrowing against their assets"
        end
      end
    end

    describe "#save_as_draft" do
      before do
        described_form.save_as_draft
        application.reload
      end

      it "updates the legal_aid_application restrictions information" do
        expect(application.has_restrictions).to be true
        expect(application.restrictions_details).not_to be_empty
      end
    end
  end
end
