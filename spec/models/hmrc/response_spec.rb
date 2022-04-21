require "rails_helper"

RSpec.describe HMRC::Response, type: :model do
  subject(:response) { build(:hmrc_response) }

  context "when validating" do
    before { response.validate }

    context "with valid use_case" do
      it "is valid with all valid attributes" do
        expect(response).to be_valid
      end
    end

    context "with invalid use_case" do
      let(:response) { build(:hmrc_response, use_case: "three") }

      it { expect(response).to be_invalid }
      it { expect(response.errors.messages_for(:use_case)).to include("Invalid use case") }
    end

    context "with nil use_case" do
      let(:response) { build(:hmrc_response, use_case: nil) }

      it { expect(response).to be_invalid }
      it { expect(response.errors.messages_for(:use_case)).to include("can't be blank") }
    end

    context "with blank use_case" do
      let(:response) { build(:hmrc_response, use_case: "") }

      it { expect(response).to be_invalid }
      it { expect(response.errors.messages_for(:use_case)).to include("can't be blank") }
    end
  end

  describe ".use_case_for" do
    context "there are application id does not exist" do
      it "returns nil" do
        expect(described_class.use_case_one_for(SecureRandom.uuid)).to be_nil
      end
    end

    context "there is only one use case one record with the specified application id" do
      let!(:response1) { create :hmrc_response, :use_case_one }
      let!(:response_uc2) { create :hmrc_response, :use_case_two, legal_aid_application_id: response1.legal_aid_application_id }
      let!(:response2) { create :hmrc_response, :use_case_one }

      it "returns the record for the application we specify" do
        expect(described_class.use_case_one_for(response1.legal_aid_application_id)).to eq response1
      end
    end

    context "there are multiple use case one records with the specified application id" do
      let!(:response1) { create :hmrc_response, :use_case_one, created_at: 5.minutes.ago }
      let!(:response_uc2) { create :hmrc_response, :use_case_two, legal_aid_application_id: response1.legal_aid_application_id }
      let!(:response1_last) { create :hmrc_response, :use_case_one, legal_aid_application_id: response1.legal_aid_application_id }
      let!(:response2) { create :hmrc_response, :use_case_one }

      it "returns the last created use case one record for the specified application id" do
        expect(described_class.use_case_one_for(response1.legal_aid_application_id)).to eq response1_last
      end
    end
  end

  describe "#employment_income?" do
    context "when there is no hmrc data" do
      let(:response) { create :hmrc_response }

      it "returns false" do
        expect(response.employment_income?).to be false
      end
    end

    context "when the hmrc data does not contain employment income data" do
      let(:response) { create :hmrc_response }
      let(:response_data_with_no_employment_income) do
        { "submission" => "f3730ebf-4b56-4bc1-b419-417bdf2ce9d2",
          "status" => "completed",
          "data" =>
           [{ "correlation_id" => "f3730ebf-4b56-4bc1-b419-417bdf2ce9d2", "use_case" => "use_case_one" },
            { "individuals/matching/individual" => { "firstName" => "tesdt", "lastName" => "test", "nino" => "XX123456X", "dateOfBirth" => "1970-01-01" } },
            { "income/paye/paye" => { "income" => [] } }] }
      end

      before { response.response = response_data_with_no_employment_income }

      it "returns false" do
        expect(response.employment_income?).to be false
      end
    end

    context "when the hmrc data contains employment income data" do
      let(:response) { create :hmrc_response, :use_case_one }

      it "returns true" do
        expect(response.employment_income?).to be true
      end
    end
  end

  describe ".after_update" do
    let(:persistor_class) { HMRC::ParsedResponse::Persistor }
    let(:hmrc_response) { create(:hmrc_response, :use_case_one, :with_legal_aid_applicant) }
    let(:trigger_update) { hmrc_response.update!(url: "my_url") }

    before do
      allow(HMRC::ParsedResponse::Persistor).to receive(:call).and_call_original
    end

    it "calls HMRC::ParsedResponse::Persistor" do
      trigger_update
      expect(persistor_class).to have_received(:call).with(hmrc_response)
    end

    context "with a valid HMR response" do
      before do
        allow(HMRC::ParsedResponse::Validator).to receive(:call).and_return(true)
      end

      it "creates one employment record" do
        expect { trigger_update }.to change { hmrc_response.legal_aid_application.employments.count }.from(0).to(1)
      end
    end

    context "with an invalid HMR response" do
      before do
        allow(HMRC::ParsedResponse::Validator).to receive(:call).and_return(false)
      end

      it "does not create an employment record" do
        expect { trigger_update }.to change { hmrc_response.legal_aid_application.employments.count }.by(0)
      end
    end
  end

  describe "#status" do
    context "normal payload" do
      let(:response) { create :hmrc_response, :use_case_one }

      it "returns a 'completed' status" do
        expect(response.status).to eq "completed"
      end
    end

    context "processing payload" do
      let(:response) { create :hmrc_response, :processing }

      it "returns a 'processing' status" do
        expect(response.status).to eq "processing"
      end
    end

    context "nil payload" do
      let(:response) { create :hmrc_response, :nil_response }

      it "returns nil" do
        expect(response.status).to be_nil
      end
    end
  end
end
