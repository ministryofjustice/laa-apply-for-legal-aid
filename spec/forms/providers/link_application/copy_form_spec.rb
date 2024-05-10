require "rails_helper"

RSpec.describe Providers::LinkApplication::CopyForm, type: :form do
  subject(:described_form) { described_class.new(params.merge(model: application)) }

  let(:lead_application) { create(:legal_aid_application) }
  let(:link) { create(:linked_application, lead_application:, associated_application: application) }
  let(:application) { create(:legal_aid_application, :with_applicant_and_address, lead_application:) }

  describe "#save" do
    context "when copy_case is not completed" do
      let(:params) { {} }

      it "raises an error" do
        expect(described_form.save).to be false
        expect(described_form.errors[:copy_case]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.copy_case.blank")]
      end
    end

    context "when copy_case is true" do
      let(:params) { { copy_case: "true" } }

      it "updates copy_case attributes" do
        expect(application.copy_case).to be_nil
        expect(application.copy_case_id).to be_nil
        described_form.save!
        expect(application.copy_case).to be true
        expect(application.copy_case_id).to eq lead_application.id
      end

      context "and proceedings exist for the application" do
        before { create(:proceeding, :se013, legal_aid_application: application) }

        it "deletes any existing proceedings" do
          expect(application.proceedings.count).to be 1
          expect { described_form.save! }.to change(application.proceedings, :count)
          expect(application.proceedings.count).to be 0
        end
      end
    end

    context "when copy_case is false" do
      let(:params) { { copy_case: "false" } }

      it "updates copy_case attributes" do
        expect(application.copy_case).to be_nil
        expect(application.copy_case_id).to be_nil
        described_form.save!
        expect(application.copy_case).to be false
        expect(application.copy_case_id).to be_nil
      end

      context "and a previous yes response has been recorded" do
        let(:application) do
          create(:legal_aid_application,
                 :with_applicant_and_address,
                 lead_application:,
                 copy_case: true,
                 copy_case_id: SecureRandom.uuid)
        end

        it "resets the copy_case attributes" do
          expect(application.copy_case).to be true
          expect(application.copy_case_id).to be_present
          described_form.save!
          expect(application.copy_case).to be false
          expect(application.copy_case_id).to be_nil
        end
      end
    end
  end
end
