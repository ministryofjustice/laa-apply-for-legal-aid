require "rails_helper"

module HMRC
  RSpec.describe Response, type: :model do
    subject(:response) { build(:hmrc_response) }

    describe "validations" do
      subject(:valid) { response.valid? }
      it "is valid with all valid attributes" do
        expect(valid).to be true
      end

      context "when the use case is not valid for apply" do
        let(:response) { build(:hmrc_response, use_case: "three") }

        it { is_expected.to be false }
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
          expect(response.employment_income?).to eq false
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
          expect(response.employment_income?).to eq false
        end
      end

      context "when the hmrc data contains employment income data" do
        let(:response) { create :hmrc_response, :use_case_one }

        it "returns true" do
          expect(response.employment_income?).to eq true
        end
      end
    end

    describe ".after_update" do
      let(:persistor_class) { HMRC::ParsedResponse::Persistor }

      before do
        allow(persistor_class).to receive(:call)
        hmrc_response.update!(url: "my_url")
      end

      context "with a use case two HMRC response" do
        let(:hmrc_response) { create :hmrc_response, :use_case_two }

        it "does not call HMRC::ParsedResponse::Persistor" do
          expect(persistor_class).not_to have_received(:call)
        end
      end

      context "with a use case one HMRC response" do
        context "when there is no response" do
          let(:hmrc_response) { create :hmrc_response, :use_case_one, :nil_response }

          it "does not call HMRC::ParsedResponse::Persistor" do
            expect(persistor_class).not_to have_received(:call)
          end
        end

        context "when status is not completed" do
          let(:hmrc_response) { create :hmrc_response, :use_case_one, :processing }

          it "does not call HMRC::ParsedResponse::Persistor" do
            expect(persistor_class).not_to have_received(:call)
          end
        end

        context "when status is completed" do
          let(:hmrc_response) { create :hmrc_response, :use_case_one }

          it "calls HMRC::ParsedResponse::Persistor" do
            expect(persistor_class).to have_received(:call)
          end
        end
      end
    end

    describe "#correlation_id" do
      context "normal payload" do
        let(:uuid) { SecureRandom.uuid }
        let(:response) { create :hmrc_response, :use_case_one, submission_id: uuid }

        it "extracts the correlation id" do
          expect(response.correlation_id).to eq uuid
        end
      end

      context "nil payload" do
        let(:response) { create :hmrc_response, :nil_response }

        it "returns nil" do
          expect(response.correlation_id).to be_nil
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
end
