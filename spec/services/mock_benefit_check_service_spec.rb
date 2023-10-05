require "rails_helper"

RSpec.describe MockBenefitCheckService do
  subject(:mock_benefit_check) { described_class.call(application) }

  let(:last_name) { "Smith" }
  let(:date_of_birth) { "1999/01/11".to_date }
  let(:national_insurance_number) { "ZZ123459A" }
  let(:applicant) { create(:applicant, last_name:, date_of_birth:, national_insurance_number:) }
  let(:application) { create(:application, applicant:) }

  describe ".call" do
    it "returns confirmation_ref" do
      expect(mock_benefit_check[:confirmation_ref]).to eq("mocked:#{described_class}")
    end

    it "returns 'Yes' as in known data" do
      expect(mock_benefit_check[:benefit_checker_status]).to eq("Yes")
    end

    context "with incorrect date" do
      let(:date_of_birth) { "2012/01/10".to_date }

      it "returns no" do
        expect(mock_benefit_check[:benefit_checker_status]).to eq("No")
      end

      it "returns confirmation_ref" do
        expect(mock_benefit_check[:confirmation_ref]).to eq("mocked:#{described_class}")
      end
    end

    context "with unknown name" do
      let(:last_name) { "Unknown" }

      it "returns no" do
        expect(mock_benefit_check[:benefit_checker_status]).to eq("No")
      end
    end
  end
end
