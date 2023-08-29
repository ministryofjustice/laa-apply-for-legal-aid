require "rails_helper"

RSpec.describe LegalAidApplications::RestrictionsForm, type: :form do
  subject(:described_form) { described_class.new(form_params) }

  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:journey) { %i[providers citizens].sample }
  let(:restrictions_details) { Faker::Lorem.paragraph }
  let(:has_restrictions) { "true" }
  let(:params) do
    {
      has_restrictions:,
      restrictions_details:,
      journey:,
    }
  end
  let(:form_params) { params.merge(model: application) }

  describe "#save" do
    before do
      described_form.save
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
        expect(described_form).to be_invalid
      end

      it "generates the expected error message" do
        expect(described_form.errors[:restrictions_details]).to include I18n.t("activemodel.errors.models.legal_aid_application.attributes.restrictions_details.#{journey}.blank")
      end

      context "with no restrictions present" do
        let(:has_restrictions) { "" }

        it "is invalid" do
          expect(described_form).to be_invalid
        end

        it "generates the expected error message" do
          expect(described_form.errors[:has_restrictions]).to include I18n.t("activemodel.errors.models.legal_aid_application.attributes.has_restrictions.#{journey}.blank")
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
