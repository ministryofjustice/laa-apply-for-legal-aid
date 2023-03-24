require "rails_helper"

RSpec.describe Partners::SharedAddressForm, type: :form do
  subject(:shared_address_form) { described_class.new(params) }

  let(:partner) { create(:partner, shared_address_with_client: partner_shares_address) }
  let(:partner_shares_address) { nil }

  let(:params) do
    {
      shared_address_with_client:,
      model: partner,
    }
  end

  describe "#validate" do
    subject(:validate_form) { shared_address_form.valid? }

    before { validate_form }

    context "with yes chosen" do
      let(:shared_address_with_client) { "true" }

      it "is valid" do
        expect(shared_address_form).to be_valid
      end
    end

    context "with no chosen" do
      let(:shared_address_with_client) { "false" }

      it "is valid" do
        expect(shared_address_form).to be_valid
      end
    end

    context "when no answer chosen" do
      let(:params) { { shared_address_with_client: "", model: partner } }

      it "is invalid" do
        expect(shared_address_form).to be_invalid
      end

      it "adds custom blank error message" do
        error_messages = shared_address_form.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if the partner has the same address as your client")
      end
    end
  end

  describe "#save" do
    subject(:call_save) { shared_address_form.save }

    context "with yes chosen" do
      let(:params) { { model: partner, shared_address_with_client: "true" } }

      it "updates has_partner" do
        expect { call_save }.to change(partner, :shared_address_with_client).from(nil).to(true)
      end
    end

    context "with no chosen" do
      let(:params) { { model: partner, shared_address_with_client: "false" } }

      context "when no answer previously chosen" do
        it "updates has_partner" do
          expect { call_save }.to change(partner, :shared_address_with_client).from(nil).to(false)
        end
      end

      context "when yes previously chosen" do
        let(:partner_shares_address) { true }

        it "updates shared_address_with_client to false" do
          expect { call_save }.to change(partner, :shared_address_with_client).from(true).to(false)
        end
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { shared_address_form.save_as_draft }

    context "with yes chosen" do
      let(:shared_address_with_client) { "true" }

      it "updates has_partner" do
        expect { save_as_draft }.to change(partner, :shared_address_with_client).from(nil).to(true)
      end
    end

    context "with no chosen" do
      let(:shared_address_with_client) { "false" }

      it "updates has_partner" do
        expect { save_as_draft }.to change(partner, :shared_address_with_client).from(nil).to(false)
      end
    end
  end
end
