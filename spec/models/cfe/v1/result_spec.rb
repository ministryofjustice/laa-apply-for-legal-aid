require "rails_helper"

module CFE
  module V1
    RSpec.describe Result, type: :model do
      let(:eligible_result) { create :cfe_v1_result }
      let(:not_eligible_result) { create :cfe_v1_result, :not_eligible }
      let(:contribution_required_result) { create :cfe_v1_result, :contribution_required }
      let(:contribution_and_restriction_result) { create :cfe_v1_result, :contribution_required, submission: cfe_submission }
      let(:no_additional_properties) { create :cfe_v1_result, :no_additional_properties }
      let(:additional_property) { create :cfe_v1_result, :with_additional_properties }
      let(:capital_result) { contribution_required_result.capital }
      let(:legal_aid_application) { create :legal_aid_application, :with_restrictions, :with_cfe_v1_result }
      let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
      let(:expected_capital_result_keys) do
        %i[
          total_liquid
          total_non_liquid
          pensioner_capital_disregard
          total_capital
          capital_contribution
          liquid_capital_items
          non_liquid_capital_items
        ]
      end

      describe "#overview" do
        context "applicant is eligible" do
          it "returns assessment result" do
            expect(eligible_result.overview).to eq "eligible"
          end
        end

        context "applicant has contribution required and restrictions" do
          it "returns manual_check_required" do
            expect(contribution_and_restriction_result.capital_contribution_required?).to be true
            expect(legal_aid_application.has_restrictions?).to be true
            expect(contribution_and_restriction_result.overview).to eq "manual_check_required"
          end
        end

        context "applicant has contribution required and no restrictions" do
          it "returns manual_check_required" do
            expect(contribution_required_result.capital_contribution_required?).to be true
            expect(contribution_required_result.overview).to eq "capital_contribution_required"
          end
        end
      end

      describe "#assessment_result" do
        context "eligible" do
          it "returns eligible" do
            expect(eligible_result.assessment_result).to eq "eligible"
          end
        end

        context "not_eligible" do
          it "returns not_eligible" do
            expect(not_eligible_result.assessment_result).to eq "not_eligible"
          end
        end

        context "contribution_required" do
          it "returns contribution_required" do
            expect(contribution_required_result.assessment_result).to eq "contribution_required"
          end
        end
      end

      describe "#capital" do
        it "returns the capital hash" do
          expect(capital_result.keys).to match_array(expected_capital_result_keys)
        end
      end

      describe "#capital_contribution" do
        it "returns the value of the capital contribution" do
          expect(contribution_required_result.capital_contribution).to eq 465.66
        end
      end

      describe "#additional_property?" do
        context "present" do
          it "returns true" do
            expect(additional_property.additional_property?).to be true
          end
        end
        context "not present" do
          it "returns false" do
            expect(no_additional_properties.additional_property?).to be false
          end
        end
        context "present but zero" do
          it "returns false" do
            expect(eligible_result.additional_property?).to be false
          end
        end
      end

      describe "additional_property_value" do
        it "returns the value of the first additional property" do
          expect(additional_property.additional_property_value).to eq 350_255.0
        end
      end

      describe "additional_property_transaction_allowance" do
        it "returns the transaction allowance for the first additional property" do
          expect(additional_property.additional_property_transaction_allowance).to eq(-12_550.0)
        end
      end

      describe "additional_property_mortgage" do
        it "returns the mortgage for the first additional property" do
          expect(additional_property.additional_property_mortgage).to eq(-45_000.0)
        end
      end

      describe "additional_property_assessed_equity" do
        it "returns the assessed equity for the first additional property" do
          expect(additional_property.additional_property_assessed_equity).to eq 224_000.0
        end
      end

      context "vehicles" do
        let(:result) { not_eligible_result }
        let(:vehicle) { result.vehicle }

        describe "#vehicle" do
          it "returns the vehicle hash" do
            expect(vehicle.keys).to match_array(%i[
              in_regular_use
              value
              loan_amount_outstanding
              date_of_purchase
              included_in_assessment
              assessed_value
            ])
          end
        end

        describe "#vehicles?" do
          it "returns true" do
            expect(result.vehicles?).to be true
          end
        end

        describe "#vehicle_value" do
          it "returns the value" do
            expect(result.vehicle_value).to eq 900.0
          end
        end

        describe "#total_vehicles" do
          it "returns the zero" do
            expect(result.total_vehicles).to be_zero
          end
        end
      end

      context "capital_items" do
        let(:result) { contribution_required_result }

        describe "#non_liquid_capital_items" do
          it "returns empty array" do
            expect(result.non_liquid_capital_items).to eq []
          end
        end

        describe "#liquid_capital_items" do
          let(:expected_items) do
            [
              {
                description: "Off-line bank accounts",
                value: "350.0",
              }
            ]
          end

          it "returns array of items" do
            expect(result.liquid_capital_items).to eq expected_items
          end
        end

        describe "#total_property" do
          it "returns the value" do
            expect(result.total_property).to eq(-100_000.0)
          end
        end
      end
    end
  end
end
