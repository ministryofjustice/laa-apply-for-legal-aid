require "rails_helper"

RSpec.describe Applicants::PreviousReferenceForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:applicant) { create(:applicant, applied_previously: nil, previous_reference: nil) }
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }

  let(:params) do
    {
      applied_previously:,
      model: applicant,
    }
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with no chosen" do
      let(:params) { { model: applicant, applied_previously: "false" } }

      it "updates the applied_previously field in the database" do
        expect { call_save }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(applied_previously: nil))
          .to(hash_including(applied_previously: false))
      end
    end

    context "with yes chosen and valid previous reference provided" do
      let(:params) { { model: applicant, applied_previously: "true", previous_reference: "300001234567" } }

      it "updates the applied_previously and previous_reference fields in the database" do
        expect { call_save }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(applied_previously: nil, previous_reference: nil))
          .to(hash_including(applied_previously: true, previous_reference: "300001234567"))
      end
    end

    context "when neither yes nor no is chosen for applied_previously question" do
      let(:params) { { model: applicant, applied_previously: "" } }

      it "is invalid" do
        call_save
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        call_save
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if your client has applied for civil legal aid before")
      end
    end

    context "when yes is chosen but no previous_reference is provided" do
      let(:params) { { model: applicant, applied_previously: "true", previous_reference: "" } }

      it "is invalid" do
        call_save
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        call_save
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Enter the reference number for any previous application")
      end
    end

    context "with yes chosen but invalid previous reference number provided" do
      context "with too many numbers" do
        let(:params) { { model: applicant, applied_previously: "true", previous_reference: "3234567890123" } }

        it "is invalid" do
          call_save
          expect(instance).not_to be_valid
        end

        it "adds custom blank error message" do
          call_save
          error_messages = instance.errors.messages.values.flatten
          expect(error_messages).to include("Enter the reference number in the correct format")
        end
      end

      context "with not enough numbers" do
        let(:params) { { model: applicant, applied_previously: "true", previous_reference: "3234567890" } }

        it "is invalid" do
          call_save
          expect(instance).not_to be_valid
        end

        it "adds custom blank error message" do
          call_save
          error_messages = instance.errors.messages.values.flatten
          expect(error_messages).to include("Enter the reference number in the correct format")
        end
      end

      context "when a non-integer included" do
        let(:params) { { model: applicant, applied_previously: "true", previous_reference: "32345678901F" } }

        it "is invalid" do
          call_save
          expect(instance).not_to be_valid
        end

        it "adds custom blank error message" do
          call_save
          error_messages = instance.errors.messages.values.flatten
          expect(error_messages).to include("Enter the reference number in the correct format")
        end
      end

      context "when 1 or 3 is not at the beginning" do
        let(:params) { { model: applicant, applied_previously: "true", previous_reference: "423456789012" } }

        it "is invalid" do
          call_save
          expect(instance).not_to be_valid
        end

        it "adds custom blank error message" do
          call_save
          error_messages = instance.errors.messages.values.flatten
          expect(error_messages).to include("Enter the reference number in the correct format")
        end
      end

      context "when a blank space is included in the previous reference number" do
        let(:params) { { model: applicant, applied_previously: "true", previous_reference: "321 123456789" } }

        it "updates the applied_previously and previous_reference fields in the database" do
          expect { call_save }.to change { applicant.attributes.symbolize_keys }
            .from(hash_including(applied_previously: nil, previous_reference: nil))
            .to(hash_including(applied_previously: true, previous_reference: "321123456789"))
        end
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    context "when yes is chosen but no previous_reference is provided" do
      let(:params) { { model: applicant, applied_previously: "true", previous_reference: "" } }

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "updates the applied_previously field in the database" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(applied_previously: nil))
          .to(hash_including(applied_previously: true))
      end
    end

    context "when neither yes nor no is chosen for applied_previously question" do
      let(:params) { { model: applicant, applied_previously: "", previous_reference: "" } }

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end
  end
end
