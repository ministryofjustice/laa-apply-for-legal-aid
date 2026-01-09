require "rails_helper"

RSpec.describe HMRC::ParsedResponse::Validator do
  describe ".call" do
    subject(:call) { described_class.call(hmrc_response, person: applicant) }

    let(:instance) { described_class.new(hmrc_response, person: applicant) }
    let(:applicant) { create(:legal_aid_application, :with_applicant).applicant }

    let(:valid_individual_response) do
      { "firstName" => "not-checked",
        "lastName" => "not-checked",
        "nino" => applicant.national_insurance_number,
        "dateOfBirth" => applicant.date_of_birth }
    end

    let(:valid_employments_response) { [{}] }

    let(:valid_response_hash) do
      { "submission" => "must-be-present",
        "status" => "completed",
        "data" => [
          { "individuals/matching/individual" => valid_individual_response },
          { "income/paye/paye" => { "income" => [] } },
          { "employments/paye/employments" => valid_employments_response },
        ] }
    end

    context "when response has persistable employment details" do
      let(:hmrc_response) { build(:hmrc_response, use_case: "one", response: valid_response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      it { expect(call).to be_truthy }
    end

    context "when HRMC response use_case is \"two\"" do
      let(:instance) { described_class.new(hmrc_response, person: applicant) }
      let(:hmrc_response) { build(:hmrc_response, use_case: "two", response: valid_response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("use_case must be \"one\", but was \"two\"")
      }
    end

    context "when person is nil" do
      let(:instance) { described_class.new(hmrc_response, person: nil) }
      let(:hmrc_response) { build(:hmrc_response, use_case: "one", response: valid_response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("individual must match person")
      }
    end

    context "when response is nil" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }
      let(:response_hash) { nil }

      it { expect(call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("response must be present")
      }
    end

    context "when response is empty hash" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }
      let(:response_hash) { {} }

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message).size).to be >= 1
      }
    end

    context "when response status is not \"completed\"" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "foobar",
          "data" => [] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("response status must be \"completed\"")
      }
    end

    context "when response submission is nil" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => nil,
          "status" => "completed",
          "data" => [] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("response submission must be present")
      }
    end

    context "when response submission is blank" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "",
          "status" => "completed",
          "data" => [] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("response submission must be present")
      }
    end

    context "when response submission is missing" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "status" => "completed",
          "data" => [] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("response submission must be present")
      }
    end

    context "when response data is a hash" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => {} }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("data must be an array")
      }
    end

    context "when response data is nil" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => nil }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("data must be an array")
      }
    end

    context "when response data has \"individuals/matching/individual\" details matching request" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => valid_individual_response },
            { "income/paye/paye" => { "income" => [] } },
            { "employments/paye/employments" => valid_employments_response },
          ] }
      end

      it { expect(call).to be_truthy }
    end

    context "when response data has \"individuals/matching/individual\" details matching but different name" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

      let(:valid_individual_response) do
        { "firstName" => "Foo",
          "lastName" => "Bar",
          "nino" => applicant.national_insurance_number.downcase,
          "dateOfBirth" => applicant.date_of_birth }
      end

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => valid_individual_response },
            { "income/paye/paye" => { "income" => [] } },
            { "employments/paye/employments" => valid_employments_response },
          ] }
      end

      it { expect(call).to be_truthy }
    end

    context "when response data \"individuals/matching/individual\" details are missing" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "income/paye/paye" => { "income" => [] } },
          ] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("individual must match person")
      }
    end

    context "when response data \"individuals/matching/individual\" details are empty" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => {} },
            { "income/paye/paye" => { "income" => [] } },
          ] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("individual must match person")
      }
    end

    context "when response data \"individuals/matching/individual\" details has invalid dateOfBirth date" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => {
              "firstName" => legal_aid_application.applicant.first_name,
              "lastName" => legal_aid_application.applicant.last_name,
              "nino" => legal_aid_application.applicant.national_insurance_number,
              "dateOfBirth" => "1999-99-99",
            } },
            { "income/paye/paye" => { "income" => [] } },
          ] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("individual must match person")
      }
    end

    context "when response data \"individuals/matching/individual\" details do not match applicant" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => {
              "firstName" => legal_aid_application.applicant.first_name,
              "lastName" => legal_aid_application.applicant.last_name,
              "nino" => "FOOBAR",
              "dateOfBirth" => legal_aid_application.applicant.date_of_birth,
            } },
            { "income/paye/paye" => { "income" => [] } },
          ],
        }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("individual must match person")
      }
    end

    context "when response data \"income/paye/paye\" \"income\" is nil" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [{ "income/paye/paye" => { "income" => nil } }] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("income must be an array")
      }
    end

    context "when response data \"income/paye/paye\" \"income\" is hash" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [{ "income/paye/paye" => { "income" => {} } }] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("income must be an array")
      }
    end

    context "when response data \"income/paye/paye\" \"income\" contains invalid inPayPeriod1 string" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            {
              "income/paye/paye" => {
                "income" => [
                  {
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => "decimal-expected-here",
                    },
                  },
                ],
              },
            },
          ],
        }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("inPayPeriod1 must be numeric")
      }
    end

    context "when response data \"income/paye/paye\" \"income\" contains valid inPayPeriod1 float" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => valid_individual_response },
            {
              "income/paye/paye" => {
                "income" => [
                  {
                    "paymentDate" => "2021-01-01",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => 2345.29,
                    },
                  },
                ],
              },
            },
            { "employments/paye/employments" => valid_employments_response },
          ],
        }
      end

      it { expect(call).to be_truthy }
    end

    context "when response data \"income/paye/paye\" \"income\" contains valid inPayPeriod1 integer" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => valid_individual_response },
            {
              "income/paye/paye" => {
                "income" => [
                  {
                    "paymentDate" => "2021-01-01",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => 2345,
                    },
                  },
                ],
              },
            },
            { "employments/paye/employments" => valid_employments_response },
          ],
        }
      end

      it { expect(call).to be_truthy }
    end

    context "when response data \"income/paye/paye\" \"income\" contains multiple inPayPeriod1 including one invalid string" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            {
              "income/paye/paye" => {
                "income" => [
                  {
                    "paymentDate" => "2021-01-01",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => 2345.29,
                    },
                  },
                  {
                    "paymentDate" => "2021-01-01",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => "decimal-expected-here",
                    },
                  },
                ],
              },
            },
          ],
        }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("inPayPeriod1 must be numeric")
      }
    end

    context "when response data \"income/paye/paye\" \"income\" contains valid format of paymentDate" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => valid_individual_response },
            {
              "income/paye/paye" => {
                "income" => [
                  {
                    "paymentDate" => "2021-11-30",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => 2345.29,
                    },
                  },
                ],
              },
            },
            { "employments/paye/employments" => valid_employments_response },
          ],
        }
      end

      it { expect(call).to be_truthy }
    end

    context "when response data \"income/paye/paye\" \"income\" contains invalid date for paymentDate" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            {
              "income/paye/paye" => {
                "income" => [
                  {
                    "paymentDate" => "2021-11-32",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => 2345.29,
                    },
                  },
                ],
              },
            },
          ],
        }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("paymentDate must be a valid iso8601 formatted date")
      }
    end

    context "when response data \"income/paye/paye\" \"income\" contains non-iso8601 format of paymentDate" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            {
              "income/paye/paye" => {
                "income" => [
                  {
                    "paymentDate" => "01-11-2021",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => 2345.29,
                    },
                  },
                ],
              },
            },
          ],
        }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("paymentDate must be a valid iso8601 formatted date")
      }
    end

    context "when response data \"income/paye/paye\" \"income\" contains multiple paymentDates including one invalid" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        {
          "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            {},
            {
              "income/paye/paye" => {
                "income" => [
                  {
                    "paymentDate" => "2021-01-01",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => 2345.29,
                    },
                  },
                  {
                    "paymentDate" => "2021-01-32",
                    "grossEarningsForNics" => {
                      "inPayPeriod1" => 2345.29,
                    },
                  },
                ],
              },
            },
          ],
        }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("paymentDate must be a valid iso8601 formatted date")
      }
    end

    context "when response data \"employments/paye/employments\" is valid" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => valid_individual_response },
            { "income/paye/paye" => { "income" => [] } },
            { "employments/paye/employments" => [{}] },
          ] }
      end

      it { expect(call).to be_truthy }
    end

    context "when response data \"employments/paye/employments\" is missing" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("employments must be present")
      }
    end

    context "when response data \"employments/paye/employments\" is nil" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [{ "employments/paye/employments" => nil }] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("employments must be present")
      }
    end

    context "when response data \"employments/paye/employments\" is empty" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [{ "employments/paye/employments" => [] }] }
      end

      it { expect(instance.call).to be_falsey }

      it {
        instance.call
        expect(instance.errors.collect(&:message)).to include("employments must be present")
      }
    end

    context "when response data is invalid" do
      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "foobar",
          "data" => [
            { "individuals/matching/individual" => valid_individual_response },
            { "income/paye/paye" => { "income" => [] } },
            { "employments/paye/employments" => valid_employments_response },
          ] }
      end

      context "with use_case \"one\"" do
        let(:hmrc_response) { build(:hmrc_response, response: response_hash, use_case: "one", owner_id: applicant.id, owner_type: applicant.class) }

        before do
          allow(AlertManager).to receive(:capture_message)
          call
        end

        it "sends message to AlertManager with errors" do
          expect(AlertManager).to have_received(:capture_message)
                                    .with("HMRC Response is unacceptable (id: #{hmrc_response.id}) - response status must be \"completed\"")
        end
      end

      context "with use_case \"two\"" do
        let(:hmrc_response) { build(:hmrc_response, response: response_hash, use_case: "two", owner_id: applicant.id, owner_type: applicant.class) }

        before do
          allow(AlertManager).to receive(:capture_message)
          call
        end

        it "does not send message to AlertManager with errors" do
          expect(AlertManager).not_to have_received(:capture_message)
        end
      end
    end

    context "when client details are not found by HMRC" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }

      let!(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "failed",
          "data" => [{ "error" => "submitted client details could not be found in HMRC service" }] }
      end

      before do
        allow(AlertManager).to receive(:capture_message)
      end

      it { expect(instance.call).to be_falsey }

      it "does not send message to AlertManager with errors" do
        call
        expect(AlertManager).not_to have_received(:capture_message)
      end
    end

    context "when client has no employments recorded by HMRC" do
      let(:hmrc_response) { build(:hmrc_response, response: response_hash, owner_id: applicant.id, owner_type: applicant.class) }
      let(:response_hash) do
        { "submission" => "must-be-present",
          "status" => "completed",
          "data" => [
            { "individuals/matching/individual" => valid_individual_response },
            { "income/paye/paye" => { "income" => [] } },
            { "employments/paye/employments" => [] },
          ] }
      end

      before do
        allow(AlertManager).to receive(:capture_message)
      end

      it { expect(instance.call).to be_falsey }

      it "does not send message to AlertManager with errors" do
        call
        expect(AlertManager).not_to have_received(:capture_message)
      end
    end
  end
end
