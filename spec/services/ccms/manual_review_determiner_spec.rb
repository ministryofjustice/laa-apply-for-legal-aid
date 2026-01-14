require "rails_helper"

module CCMS
  RSpec.describe ManualReviewDeterminer, :ccms do
    let(:determiner) { described_class.new(legal_aid_application) }
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

    describe "#manual_review_required?" do
      subject(:manual_review_required) { determiner.manual_review_required? }

      let(:setting) { Setting.setting }
      let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }

      context "when an assessment is not yet carried out on legal aid application" do
        it "raises an error" do
          expect { manual_review_required }.to raise_error RuntimeError, "Unable to determine whether Manual review is required before means assessment"
        end
      end

      context "when manual review setting is true" do
        before { setting.update! manually_review_all_cases: true }

        context "and there is no DWP override" do
          context "when passported, no contrib, no_restrictions" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_positive_benefit_check_result) }

            before { create(:cfe_v3_result, submission: cfe_submission) }

            it "returns false" do
              expect(manual_review_required).to be false
            end
          end

          context "when non-passported, no contrib" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_negative_benefit_check_result) }

            before { create(:cfe_v3_result, submission: cfe_submission) }

            it "returns true" do
              expect(manual_review_required).to be true
            end
          end
        end

        context "with DWP override" do
          before { create(:dwp_override, :with_evidence, legal_aid_application:) }

          context "when passported, no contrib, no_restrictions" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_positive_benefit_check_result) }

            before { create(:cfe_v3_result, submission: cfe_submission) }

            it "returns true" do
              expect(manual_review_required).to be true
            end
          end

          context "when non-passported, no contrib" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_negative_benefit_check_result) }

            before { create(:cfe_v3_result, submission: cfe_submission) }

            it "returns true" do
              expect(manual_review_required).to be true
            end
          end
        end
      end

      context "when manual review setting is false" do
        before { setting.update! manually_review_all_cases: false }

        context "without DWP override" do
          context "and the application is passported" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_positive_benefit_check_result, has_restrictions: true) }

            context "and a contribution is required" do
              before { create(:cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission) }

              it "returns true" do
                expect(manual_review_required).to be true
              end
            end

            context "and there is no contribution" do
              before { create(:cfe_v3_result, submission: cfe_submission) }

              context "and there are restrictions" do # TODO: check this - description does not match expectation
                it "returns false" do
                  expect(manual_review_required).to be true
                end
              end

              context "and no restrictions" do
                before { legal_aid_application.update! has_restrictions: false }

                it "returns false" do
                  expect(manual_review_required).to be false
                end
              end
            end
          end

          context "and the application is non-passported" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_negative_benefit_check_result, has_restrictions: true) }

            context "when there is a contribution" do
              before { create(:cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission) }

              it "returns true" do
                expect(manual_review_required).to be true
              end
            end

            context "when there is no contribution" do
              before { create(:cfe_v3_result, submission: cfe_submission) }

              context "but with restrictions" do
                it "returns false" do
                  expect(manual_review_required).to be true
                end
              end

              context "and no restrictions" do
                before { legal_aid_application.update! has_restrictions: false }

                it "returns false" do
                  expect(manual_review_required).to be false
                end
              end
            end
          end
        end

        context "with DWP override" do
          before { create(:dwp_override, :with_evidence, legal_aid_application:) }

          context "and the application is passported" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_positive_benefit_check_result, has_restrictions: true) }

            context "when there is a contribution" do
              before { create(:cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission) }

              it "returns true" do
                expect(manual_review_required).to be true
              end
            end

            context "when there is no contribution" do
              before { create(:cfe_v3_result, submission: cfe_submission) }

              context "and there are restrictions" do # TODO: check this - description does not match expectation
                it "returns false" do
                  expect(manual_review_required).to be true
                end
              end

              context "and there are no restrictions" do
                before { legal_aid_application.update! has_restrictions: false }

                it "returns true" do
                  expect(manual_review_required).to be true
                end
              end
            end
          end

          context "when the application is non-passported" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_negative_benefit_check_result, has_restrictions: true) }

            context "and a contribution is required" do
              before { create(:cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission) }

              it "returns true" do
                expect(manual_review_required).to be true
              end
            end

            context "and there is no contribution" do
              before { create(:cfe_v3_result, submission: cfe_submission) }

              context "and there are restrictions" do # TODO: check this - description does not match expectation
                it "returns false" do
                  expect(manual_review_required).to be true
                end
              end

              context "and there are no restrictions" do
                before { legal_aid_application.update! has_restrictions: false }

                it "returns true" do
                  legal_aid_application.reload
                  expect(manual_review_required).to be true
                end
              end
            end
          end
        end

        context "with policy_disregards" do
          before do
            allow(legal_aid_application).to receive(:policy_disregards?).and_return(true)
            create(:cfe_v6_result, submission: cfe_submission)
          end

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "without policy_disregards" do
          before do
            allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
            create(:cfe_v6_result, submission: cfe_submission)
          end

          it "returns false" do
            expect(manual_review_required).to be false
          end
        end

        context "with capital_disregards" do
          before do
            allow(legal_aid_application).to receive(:capital_disregards?).and_return(true)
            create(:cfe_v6_result, submission: cfe_submission)
          end

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "without capital_disregards" do
          before do
            allow(legal_aid_application).to receive(:capital_disregards?).and_return(false)
            create(:cfe_v6_result, submission: cfe_submission)
          end

          it "returns false" do
            expect(manual_review_required).to be false
          end
        end

        context "with client further employment information" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_employed_applicant_and_extra_info) }

          before { create(:cfe_v6_result, submission: cfe_submission) }

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "with partner further employment information" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_employed_partner_and_extra_info) }

          before { create(:cfe_v6_result, submission: cfe_submission) }

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "without further employment information" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_employed_applicant) }

          before { create(:cfe_v6_result, submission: cfe_submission) }

          it "returns false" do
            expect(manual_review_required).to be false
          end
        end

        context "with client uploaded bank_statements" do
          let(:provider) { create(:provider) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, attachments: [bank_statement], provider:) }
          let(:bank_statement) { create(:attachment, :bank_statement) }

          before { create(:cfe_v5_result, submission: cfe_submission) }

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "with partner uploaded bank_statements" do
          let(:provider) { create(:provider) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, attachments: [bank_statement], provider:) }
          let(:bank_statement) { create(:attachment, :partner_bank_statement) }

          before { create(:cfe_v5_result, submission: cfe_submission) }

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "with negative equity" do
          let(:legal_aid_application) { create(:legal_aid_application, outstanding_mortgage_amount: 101_000, property_value: 100_000) }

          before { create(:cfe_v6_result, submission: cfe_submission) }

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "without negative equity" do
          let(:legal_aid_application) { create(:legal_aid_application, outstanding_mortgage_amount: 100_000, property_value: 101_000) }

          before { create(:cfe_v6_result, submission: cfe_submission) }

          it "returns false" do
            expect(manual_review_required).to be false
          end
        end
      end
    end

    describe "#review_reasons" do
      subject(:review_reasons_result) { determiner.review_reasons }

      context "with non-passported application" do
        let(:cfe_result) { instance_double CFE::V6::Result, remarks: cfe_remarks, ineligible?: false }
        let(:cfe_remarks) { instance_double CFE::Remarks, review_reasons: }
        let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
        let(:review_reasons) { %i[unknown_frequency multi_benefit non_passported] }
        let(:override_reasons) { %i[unknown_frequency multi_benefit non_passported dwp_override] }
        let(:client_further_employment_details_reasons) { %i[unknown_frequency multi_benefit non_passported client_further_employment_details] }
        let(:partner_further_employment_details_reasons) { %i[unknown_frequency multi_benefit non_passported partner_further_employment_details] }
        let(:restrictions_reasons) { %i[unknown_frequency multi_benefit non_passported restrictions] }

        before { allow_any_instance_of(cfe_submission.class).to receive(:result).and_return(cfe_result) }

        context "without DWP Override" do
          it "just takes the review reasons from the CFE result and non-passported" do
            expect(review_reasons_result).to eq review_reasons
          end
        end

        context "with DWP override" do
          before { create(:dwp_override, :with_evidence, legal_aid_application:) }

          it "adds the dwp review to the cfe result reasons" do
            expect(review_reasons_result).to eq override_reasons
          end
        end

        context "with inconsistent dwp override values" do
          # This replicates a production application that presented caseworkers with a dilemma,
          # we were unable to replicate the steps taken to get to this state
          before { create(:dwp_override, legal_aid_application:, has_evidence_of_benefit: nil, passporting_benefit: nil) }

          it "does not add dwp_override to reason" do
            expect(review_reasons_result).not_to include(:dwp_override)
          end
        end

        context "with client further employment information" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_employed_applicant_and_extra_info) }

          it "adds further_employment_details to the review reasons" do
            expect(review_reasons_result).to eq client_further_employment_details_reasons
          end
        end

        context "with partner further employment information" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_employed_partner_and_extra_info) }

          it "adds further_employment_details to the review reasons" do
            expect(review_reasons_result).to eq partner_further_employment_details_reasons
          end
        end

        context "with restrictions" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, has_restrictions: true) }

          it "adds restrictions to the review reasons" do
            expect(review_reasons_result).to eq restrictions_reasons
          end
        end

        context "with client uploaded bank statements" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

          before do
            allow(legal_aid_application).to receive(:client_uploading_bank_statements?).and_return true
          end

          it "adds uploaded_bank_statements to the review reasons" do
            expect(review_reasons_result).to include(:client_uploaded_bank_statements)
          end
        end

        context "with partner uploaded bank statements" do
          let(:provider) { create(:provider) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, attachments: [bank_statement], provider:) }
          let(:bank_statement) { create(:attachment, :partner_bank_statement) }

          it "adds uploaded_bank_statements to the review reasons" do
            expect(review_reasons_result).to include(:partner_uploaded_bank_statements)
          end
        end

        context "with cfe result ineligible" do
          let(:cfe_result) { instance_double CFE::V6::Result, remarks: cfe_remarks, ineligible?: true }

          it "adds ineligible to the review reasons" do
            expect(review_reasons_result).to include(:ineligible)
          end
        end

        context "with policy_disregards" do
          before do
            create(:policy_disregards, legal_aid_application:, vaccine_damage_payments: true)
          end

          it "adds capital_disregards to the review reasons" do
            expect(review_reasons_result).to include(:policy_disregards)
          end
        end

        context "without policy_disregards" do
          before do
            create(:policy_disregards, legal_aid_application:)
          end

          it "does not add policy_disregards to the review reasons" do
            expect(review_reasons_result).not_to include(:policy_disregards)
          end
        end

        context "with capital_disregards" do
          before do
            create(:capital_disregard, legal_aid_application:)
          end

          it "adds capital_disregards to the review reasons" do
            expect(review_reasons_result).to include(:capital_disregards)
          end
        end

        context "without capital_disregards" do
          before do
            legal_aid_application.capital_disregards.destroy_all
          end

          it "does not add capital_disregards to the review reasons" do
            expect(review_reasons_result).not_to include(:capital_disregards)
          end
        end

        context "with negative equity" do
          let(:legal_aid_application) { create(:legal_aid_application, outstanding_mortgage_amount: 101_000, property_value: 100_000) }

          it "includes negative_equity in the review reasons" do
            expect(review_reasons_result).to include(:negative_equity)
          end
        end

        context "without negative equity" do
          let(:legal_aid_application) { create(:legal_aid_application, outstanding_mortgage_amount: 100_000, property_value: 101_000) }

          it "does not include negative_equity in the review reasons" do
            expect(review_reasons_result).not_to include(:negative_equity)
          end
        end
      end

      context "with passported application" do
        let(:legal_aid_application) { create(:legal_aid_application, :passported, :with_cfe_empty_result) }

        it "returns no review reasons" do
          expect(review_reasons_result).to be_empty
        end
      end
    end
  end
end
