require "rails_helper"

RSpec.describe CFECivil::Components::Applicant do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_positive_benefit_check_result, transaction_period_finish_on: Time.zone.today) }

  before do
    create(:applicant,
           first_name: "Barristan",
           last_name: "Selmy",
           date_of_birth: Date.new(1967, 2, 20),
           employed: true,
           legal_aid_application:)
  end

  describe ".call" do
    it "returns json in the expected format" do
      expect(call).to eq({
        applicant: {
          date_of_birth: "1967-02-20",
          employed: true,
          involvement_type: "applicant",
          has_partner_opponent: false,
          receives_qualifying_benefit: true,
        },
      }.to_json)
    end
  end
end
