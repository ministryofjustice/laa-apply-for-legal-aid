require "rails_helper"

RSpec.describe Applicants::EmailForm, type: :form do
  subject(:described_form) { described_class.new(params) }

  let(:params) do
    {
      email:,
      model: applicant,
    }
  end
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, email: nil) }
  let(:email) { Faker::Internet.email }

  describe ".model_name" do
    it 'is "Applicant"' do
      expect(described_class.model_name).to eq("Client")
    end
  end

  describe "#save" do
    before do
      described_form.save!
      applicant.reload
    end

    it "updates the email address" do
      expect(applicant.email).to eq(email)
    end

    context "with an invalid email" do
      let(:email) { "invalid" }

      it "does not update the email address" do
        expect(applicant.email).not_to eq(email)
      end

      it "address errors" do
        expect(described_form.errors[:email]).to be_present
      end
    end

    context "when stripping whitespace" do
      let(:fake_email_address) { Faker::Internet.email }
      let(:email) { "  #{fake_email_address}  " }

      it "updates the applicant email with the email address without whitespace" do
        described_form.save!
        expect(applicant.reload.email).to eq fake_email_address
      end
    end
  end
end
