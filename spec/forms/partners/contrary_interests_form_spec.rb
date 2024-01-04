require "rails_helper"

RSpec.describe Partners::ContraryInterestsForm, type: :form do
  subject(:contrary_interest_form) { described_class.new(params) }

  let(:applicant) { create(:applicant, partner_has_contrary_interest: contrary_interest) }
  let(:contrary_interest) { nil }

  let(:params) do
    {
      partner_has_contrary_interest:,
      model: applicant,
    }
  end

  describe "#validate" do
    subject(:validate_form) { contrary_interest_form.valid? }

    before { validate_form }

    context "with yes chosen" do
      let(:partner_has_contrary_interest) { "true" }

      it "is valid" do
        expect(contrary_interest_form).to be_valid
      end
    end

    context "with no chosen" do
      let(:partner_has_contrary_interest) { "false" }

      it "is valid" do
        expect(contrary_interest_form).to be_valid
      end
    end

    context "when no answer chosen" do
      let(:params) { { partner_has_contrary_interest: "", model: applicant } }

      it "is invalid" do
        expect(contrary_interest_form).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = contrary_interest_form.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if the partner has a contrary interest in the proceedings")
      end
    end
  end

  describe "#save" do
    subject(:call_save) { contrary_interest_form.save }

    context "with yes chosen and valid national insurance number provided" do
      let(:params) { { model: applicant, partner_has_contrary_interest: "true" } }

      it "updates partner_has_contrary_interest" do
        expect { call_save }.to change { applicant.attributes.symbolize_keys }
                                  .from(hash_including(partner_has_contrary_interest: nil))
                                  .to(hash_including(partner_has_contrary_interest: true))
      end
    end

    context "with no chosen" do
      let(:params) { { model: applicant, partner_has_contrary_interest: "false" } }

      context "when no answer previously chosen" do
        before { applicant.update!(partner_has_contrary_interest: nil) }

        it "updates partner_has_contrary_interest" do
          expect { call_save }.to change { applicant.attributes.symbolize_keys }
                                    .from(hash_including(partner_has_contrary_interest: nil))
                                    .to(hash_including(partner_has_contrary_interest: false))
        end
      end

      context "when yes previously chosen" do
        before { applicant.update!(partner_has_contrary_interest: true) }

        it "updates has_national_insurance_number to false" do
          expect { call_save }.to change(applicant, :partner_has_contrary_interest).from(true).to(false)
        end
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { contrary_interest_form.save_as_draft }

    context "with yes chosen" do
      let(:contrary_interest) { nil }
      let(:partner_has_contrary_interest) { "true" }

      it "updates partner_has_contrary_interest" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
                                      .from(hash_including(partner_has_contrary_interest: nil))
                                      .to(hash_including(partner_has_contrary_interest: true))
      end
    end

    context "with no chosen" do
      let(:contrary_interest) { nil }
      let(:partner_has_contrary_interest) { "false" }

      it "updates partner_has_contrary_interest" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
                                      .from(hash_including(partner_has_contrary_interest: nil))
                                      .to(hash_including(partner_has_contrary_interest: false))
      end
    end
  end
end
