require "rails_helper"

RSpec.describe CFECivil::Components::Assessment do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_positive_benefit_check_result, application_ref: "L-T5T-R3F", transaction_period_finish_on: target_time) }
  let(:target_time) { Time.zone.today }

  describe ".call" do
    it "returns json in the expected format" do
      expect(call).to eq({
        assessment: {
          client_reference_id: "L-T5T-R3F",
          submission_date: target_time.strftime("%Y-%m-%d"),
        },
      }.to_json)
    end
  end
end
