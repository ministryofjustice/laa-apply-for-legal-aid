module CFEResults
  module V6
    FactoryBot.define do
      factory :cfe_v6_result, class: "CFE::V6::Result" do
        submission factory: :cfe_submission
        legal_aid_application { submission.legal_aid_application }
        result { CFEResults::V6::MockResults.eligible.to_json }
        type { "CFE::V6::Result" }

        trait :eligible do
          result { CFEResults::V6::MockResults.eligible.to_json }
        end

        trait :not_eligible do
          result { CFEResults::V6::MockResults.not_eligible.to_json }
        end

        trait :ineligible_gross_income do
          result { CFEResults::V6::MockResults.ineligible_gross_income.to_json }
        end

        trait :ineligible_disposable_income do
          result { CFEResults::V6::MockResults.ineligible_disposable_income.to_json }
        end

        trait :ineligible_capital do
          result { CFEResults::V6::MockResults.ineligible_capital.to_json }
        end

        trait :fake_ineligible_disposable_income_and_capital do
          result { CFEResults::V6::MockResults.fake_ineligible_disposable_income_and_capital.to_json }
        end

        trait :partially_eligible do
          result { CFEResults::V6::MockResults.partially_eligible.to_json }
        end

        trait :no_capital do
          result { CFEResults::V6::MockResults.no_capital.to_json }
        end

        trait :with_capital_contribution_required do
          result { CFEResults::V6::MockResults.with_capital_contribution_required.to_json }
        end

        trait :with_income_contribution_required do
          result { CFEResults::V6::MockResults.with_income_contribution_required.to_json }
        end

        trait :with_capital_and_income_contributions_required do
          result { CFEResults::V6::MockResults.with_capital_and_income_contributions_required.to_json }
        end

        trait :partially_eligible_with_income_contribution_required do
          result { CFEResults::V6::MockResults.partially_eligible_with_income_contribution_required.to_json }
        end

        trait :partially_eligible_with_capital_contribution_required do
          result { CFEResults::V6::MockResults.partially_eligible_with_capital_contribution_required.to_json }
        end

        trait :no_additional_properties do
          result { CFEResults::V6::MockResults.no_additional_properties.to_json }
        end

        trait :with_additional_properties do
          result { CFEResults::V6::MockResults.with_additional_properties.to_json }
        end

        trait :with_no_vehicles do
          result { CFEResults::V6::MockResults.with_no_vehicles.to_json }
        end

        trait :with_maintenance_received do
          result { CFEResults::V6::MockResults.with_maintenance_received.to_json }
        end

        trait :with_student_finance_received do
          result { CFEResults::V6::MockResults.with_student_finance_received.to_json }
        end

        trait :with_mortgage_costs do
          result { CFEResults::V6::MockResults.with_mortgage_costs.to_json }
        end

        trait :with_monthly_income_equivalents do
          result { CFEResults::V6::MockResults.with_monthly_income_equivalents.to_json }
        end

        trait :with_monthly_outgoing_equivalents do
          result { CFEResults::V6::MockResults.with_monthly_outgoing_equivalents.to_json }
        end

        trait :with_total_gross_income do
          result { CFEResults::V6::MockResults.with_total_gross_income.to_json }
        end

        trait :with_total_deductions do
          result { CFEResults::V6::MockResults.with_total_deductions.to_json }
        end

        trait :with_unknown_result do
          result { CFEResults::V6::MockResults.unknown.to_json }
        end

        trait :with_mixed_proceeding_type_results do
          result { CFEResults::V6::MockResults.mixed_proceeding_type_results.to_json }
        end

        trait :with_employments do
          result { CFEResults::V6::MockResults.with_employments.to_json }
        end

        trait :with_no_employments do
          result { CFEResults::V6::MockResults.with_no_employments.to_json }
        end

        trait :with_employment_records_and_remarks do
          after(:create) do |record|
            record.legal_aid_application.employments << create(:employment, :with_irregularities)
            record.legal_aid_application.employments << create(:employment)

            record.update!(result: CFEResults::V6::MockResults.with_employment_remarks(record).to_json)
          end
        end

        trait :with_partner do
          result { CFEResults::V6::MockResults.with_partner.to_json }
        end

        # NOTE: this is a fake setup to excercise a CFE result and remarks that result in "all" review reasons
        # Amend to add any new remarks as necessary.
        trait :with_all_remarks do
          result { CFEResults::V6::MockResults.with_all_remarks.to_json }
        end

        trait :without_partner_jobs do
          result { CFEResults::V6::MockResults.without_partner_jobs.to_json }
        end
      end
    end
  end
end
