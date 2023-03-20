require "rails_helper"

RSpec.describe Providers::Partners::ClientHasPartnerForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:applicant) { create(:applicant, has_partner: nil) }
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }

  let(:params) do
    {
      has_partner:,
      model: applicant,
    }
  end

  describe ".model_name" do
    it 'is "Applicant"' do
      expect(described_class.model_name).to eq("Applicant")
    end
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with yes chosen and valid national insurance number provided" do
      let(:params) { { model: applicant, has_partner: "true" } }

      it "updates has_partner" do
        expect { call_save }.to change { applicant.attributes.symbolize_keys }
                                  .from(hash_including(has_partner: nil))
                                  .to(hash_including(has_partner: true))
      end
    end

    context "with no chosen" do
      let(:params) { { model: applicant, has_partner: "false" } }

      context "when no answer previously chosen" do
        before { applicant.update!(has_partner: nil) }

        it "updates has_partner" do
          expect { call_save }.to change { applicant.attributes.symbolize_keys }
                                    .from(hash_including(has_partner: nil))
                                    .to(hash_including(has_partner: false))
        end
      end

      context "when yes previously chosen" do
        before { applicant.update!(has_partner: true) }

        it "updates has_national_insurance_number to false" do
          expect { call_save }.to change(applicant, :has_partner).from(true).to(false)
        end
      end
    end

    context "with no answer chosen" do
      let(:params) { { has_partner: "", model: applicant } }

      it "is invalid" do
        call_save
        expect(instance).to be_invalid
      end

      it "adds custom blank error message" do
        call_save
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if the client has a partner")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    context "with yes chosen" do
      let(:params) { { model: applicant, has_partner: "true" } }

      it "updates has_partner" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
                                      .from(hash_including(has_partner: nil))
                                      .to(hash_including(has_partner: true))
      end

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end

    context "with no chosen" do
      let(:params) { { model: applicant, has_partner: "false" } }

      it "updates has_partner" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
                                      .from(hash_including(has_partner: nil))
                                      .to(hash_including(has_partner: false))
      end

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end

    context "with no answer chosen" do
      let(:params) { { model: applicant, has_partner: "" } }

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end
  end
end
