require "rails_helper"

module CCMS
  RSpec.describe ManualReviewDeterminer, :ccms do
    let(:setting) { Setting.setting }
    let!(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
    let(:determiner) { described_class.new(legal_aid_application) }
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

    describe "#manual_review_required?" do
      subject(:manual_review_required) { determiner.manual_review_required? }

      context "when an assessment is not yet carried out on legal aid application" do
        it "raises an error" do
          expect { manual_review_required }.to raise_error RuntimeError, "Unable to determine whether Manual review is required before means assessment"
        end
      end

      context "when the manual review setting is true" do
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
          before { create(:dwp_override, legal_aid_application:) }

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

      context "and manual review is set to false" do
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
          before { create(:dwp_override, legal_aid_application:) }

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
            create(:cfe_v4_result, submission: cfe_submission)
          end

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "without policy_disregards" do
          before do
            allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
            create(:cfe_v4_result, submission: cfe_submission)
          end

          it "returns false" do
            expect(manual_review_required).to be false
          end
        end

        context "with further employment information" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_employed_applicant_and_extra_info) }

          before { create(:cfe_v4_result, submission: cfe_submission) }

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end

        context "without further employment information" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_employed_applicant) }

          before { create(:cfe_v4_result, submission: cfe_submission) }

          it "returns false" do
            expect(manual_review_required).to be false
          end
        end

        context "with uploaded bank_statements" do
          let(:provider) { create(:provider) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, attachments: [bank_statement], provider:) }
          let(:bank_statement) { create(:attachment, :bank_statement) }

          before { create(:cfe_v5_result, submission: cfe_submission) }

          it "returns true" do
            expect(manual_review_required).to be true
          end
        end
      end
    end

    describe "#review_reasons" do
      subject(:review_reasons_result) { determiner.review_reasons }

      let(:cfe_result) { double "CFE Result", remarks: cfe_remarks, ineligible?: false }
      let(:cfe_remarks) { double "CFE Remarks", review_reasons: }
      let(:review_reasons) { %i[unknown_frequency multi_benefit] }
      let(:override_reasons) { %i[unknown_frequency multi_benefit dwp_override] }
      let(:further_employment_details_reasons) { %i[unknown_frequency multi_benefit further_employment_details] }
      let(:restrictions_reasons) { %i[unknown_frequency multi_benefit restrictions] }

      before { allow_any_instance_of(cfe_submission.class).to receive(:result).and_return(cfe_result) }

      context "without DWP Override" do
        it "just takes the review reasons from the CFE result" do
          expect(review_reasons_result).to eq review_reasons
        end
      end

      context "with DWP override" do
        before { create(:dwp_override, legal_aid_application:) }

        it "adds the dwp review to the cfe result reasons" do
          expect(review_reasons_result).to eq override_reasons
        end
      end

      context "with further employment information" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_employed_applicant_and_extra_info) }

        it "adds further_employment_details to the review reasons" do
          expect(review_reasons_result).to eq further_employment_details_reasons
        end
      end

      context "with restrictions" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, has_restrictions: true) }

        it "adds restrictions to the review reasons" do
          expect(review_reasons_result).to eq restrictions_reasons
        end
      end

      context "with uploaded bank statements" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

        before do
          allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return true
        end

        it "adds uploaded_bank_statements to the review reasons" do
          expect(review_reasons_result).to include(:uploaded_bank_statements)
        end
      end

      context "with cfe result ineligible" do
        let(:cfe_result) { double "CFE Result", remarks: cfe_remarks, ineligible?: true }

        it "adds ineligible to the review reasons" do
          expect(review_reasons_result).to include(:ineligible)
        end
      end
    end
  end
end
