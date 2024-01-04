require "rails_helper"

RSpec.describe Partners::ClientHasPartnerForm, type: :form do
  subject(:client_partner_form) { described_class.new(params) }

  let(:applicant) { create(:applicant, has_partner: applicant_has_partner) }
  let(:applicant_has_partner) { nil }

  let(:params) do
    {
      has_partner:,
      model: applicant,
    }
  end

  describe "#validate" do
    subject(:validate_form) { client_partner_form.valid? }

    before { validate_form }

    context "with yes chosen" do
      let(:has_partner) { "true" }

      it "is valid" do
        expect(client_partner_form).to be_valid
      end
    end

    context "with no chosen" do
      let(:has_partner) { "false" }

      it "is valid" do
        expect(client_partner_form).to be_valid
      end
    end

    context "when no answer chosen" do
      let(:params) { { has_partner: "", model: applicant } }

      it "is invalid" do
        expect(client_partner_form).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = client_partner_form.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if the client has a partner")
      end
    end
  end

  describe "#save" do
    subject(:call_save) { client_partner_form.save }

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
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { client_partner_form.save_as_draft }

    context "with yes chosen" do
      let(:has_partner) { "true" }

      it "updates has_partner" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
                                      .from(hash_including(has_partner: nil))
                                      .to(hash_including(has_partner: true))
      end
    end

    context "with no chosen" do
      let(:applicant_has_partner) { nil }
      let(:has_partner) { "false" }

      it "updates has_partner" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
                                      .from(hash_including(has_partner: nil))
                                      .to(hash_including(has_partner: false))
      end
    end
  end
end
