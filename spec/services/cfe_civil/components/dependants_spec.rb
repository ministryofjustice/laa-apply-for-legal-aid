require "rails_helper"

RSpec.describe CFECivil::Components::Dependants do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no dependants" do
    it "returns expected JSON structure" do
      expect(call).to eq({
        dependants: [],
      }.to_json)
    end
  end

  context "when dependants exist" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

    before do
      create(:dependant,
             date_of_birth: Date.new(2005, 3, 17),
             relationship: "adult_relative",
             monthly_income: 250.00,
             in_full_time_education: false,
             assets_value: 0,
             legal_aid_application:)
    end

    it "returns expected JSON structure" do
      expect(call).to eq({
        dependants: [
          date_of_birth: "2005-03-17",
          relationship: "adult_relative",
          monthly_income: "250.0",
          in_full_time_education: false,
          assets_value: "0.0",
        ],
      }.to_json)
    end
  end
end
