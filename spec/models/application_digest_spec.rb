require "rails_helper"

RSpec.describe ApplicationDigest do
  describe ".create_or_update!" do
    subject(:application_digest) { described_class.create_or_update!(laa.id) }

    let(:firm_name) { "Regional Legal Services" }
    let(:username) { "regional_user_1" }
    let(:firm) { create(:firm, name: firm_name) }
    let(:provider) { create(:provider, firm:, username:) }
    let(:creation_time) { Time.zone.local(2019, 1, 1, 12, 15, 30) }
    let(:creation_date) { creation_time.to_date }
    let(:submission_time) { creation_time + 3.days }
    let(:submission_date) { submission_time.to_date }

    let(:laa) do
      travel_to creation_time do
        create(:legal_aid_application,
               :assessment_submitted,
               :with_everything,
               :with_proceedings,
               :with_cfe_v5_result,
               explicit_proceedings: %i[da001 se013 se014],
               provider:,
               merits_submitted_at: submission_time)
      end
    end
    let(:laa_at_use_ccms) { create(:legal_aid_application, :use_ccms, :with_applicant) }

    let(:digest) { described_class.find_by(legal_aid_application_id: laa.id) }

    context "when a digest record already exists for this application" do
      before { create(:application_digest, legal_aid_application_id: laa.id) }

      it "does not create a new record" do
        expect { application_digest }.not_to change(described_class, :count)
      end

      it "updates the values on the existing record" do
        application_digest
        expect(digest.firm_name).to eq firm_name
        expect(digest.provider_username).to eq username
        expect(digest.date_started).to eq creation_date
        expect(digest.date_submitted).to eq submission_date
        expect(digest.days_to_submission).to eq 4
        expect(digest.matter_types).to eq "Domestic Abuse;Section 8 orders"
        expect(digest.proceedings).to eq "DA001;SE013;SE014"
        expect(digest.applicant_age).to eq laa.applicant.age
        expect(digest.non_means_tested).to be false
      end

      describe "applicant employment status" do
        context "when not employed" do
          it "writes false to the digest record" do
            application_digest
            expect(digest.employed).to be false
          end
        end

        context "when employed" do
          before { laa.applicant.update(employed: true) }

          it "writes true to the digest record" do
            application_digest
            expect(digest.employed).to be true
          end
        end
      end

      describe "hmrc_data_used" do
        before { allow(HMRC::StatusAnalyzer).to receive(:call).with(laa).and_return(hmrc_status) }

        context "when HMRC::StatusAnalyzer runs succesfully" do
          before { application_digest }

          context "and provider not enabled for employed journey" do
            let(:hmrc_status) { :provider_not_enabled_for_employed_journey }

            it "returns false" do
              expect(digest.hmrc_data_used).to be false
            end
          end

          context "and applicant not employed" do
            let(:hmrc_status) { :applicant_not_employed }

            it "returns false" do
              expect(digest.hmrc_data_used).to be false
            end
          end

          context "but no hmrc data" do
            let(:hmrc_status) { :applicant_no_hmrc_data }

            it "returns false" do
              expect(digest.hmrc_data_used).to be false
            end
          end

          context "and multiple employments" do
            let(:hmrc_status) { :applicant_multiple_employments }

            it "returns false" do
              expect(digest.hmrc_data_used).to be false
            end
          end

          context "and unexpected data" do
            let(:hmrc_status) { :applicant_unexpected_employment_data }

            it "returns true" do
              expect(digest.hmrc_data_used).to be false
            end
          end

          context "and single employment" do
            let(:hmrc_status) { :applicant_single_employment }

            it "returns true" do
              expect(digest.hmrc_data_used).to be true
            end
          end
        end

        context "when an unknown result is received from HMRC::StatusAnalyzer" do
          let(:hmrc_status) { :what_is_this? }

          it "raises an error" do
            expect { application_digest }.to raise_error RuntimeError, "Unexpected response from HMRC::StatusAnalyser :what_is_this?"
          end
        end
      end

      describe "referred_to_caseworker" do
        before { allow(CCMS::ManualReviewDeterminer).to receive(:new).and_return(mock_determiner) }

        let(:mock_determiner) { instance_double(CCMS::ManualReviewDeterminer, manual_review_required?: review_required) }

        context "when not referred to caseworker" do
          let(:review_required) { false }

          it "returns false" do
            application_digest
            expect(digest.referred_to_caseworker).to be false
          end
        end

        context "when referred to caseworker" do
          let(:review_required) { true }

          it "returns true" do
            application_digest
            expect(digest.referred_to_caseworker).to be true
          end
        end
      end

      describe "partner fields" do
        let(:laa) { create(:legal_aid_application, applicant:) }

        context "when the applicant does not have a partner" do
          let(:applicant) { create(:applicant) }

          it "returns the expected data" do
            application_digest
            expect(digest.has_partner).to be false
            expect(digest.contrary_interest).to be_nil
            expect(digest.partner_dwp_challenge).to be_nil
          end
        end

        context "when the applicant has a partner with contrary interest" do
          let(:applicant) do
            create(:applicant,
                   :with_partner,
                   partner_has_contrary_interest: true)
          end

          it "returns the expected data" do
            application_digest
            expect(digest.has_partner).to be true
            expect(digest.contrary_interest).to be true
            # TODO: The partner_dwp_challenge should be false but a bug is preventing it being recorded
            # Replace `be_nil` with `be false` and update the test harnesses once ticket 5136 is resolved
            expect(digest.partner_dwp_challenge).to be_nil
          end
        end

        context "when the applicant has a partner with no contrary interest and disputed benefits" do
          before { create(:partner, shared_benefit_with_applicant: true, legal_aid_application: laa) }

          let(:applicant) do
            create(:applicant,
                   :with_partner,
                   partner_has_contrary_interest: false)
          end

          it "returns the expected data" do
            application_digest
            expect(digest.has_partner).to be true
            expect(digest.contrary_interest).to be false
            expect(digest.partner_dwp_challenge).to be true
          end
        end
      end
    end

    context "when no digest record exists for this application" do
      it "creates a new record" do
        VCR.use_cassette "bank_holidays" do
          expect { application_digest }.to change(described_class, :count).by(1)
        end
      end

      it "creates a record with expected values" do
        VCR.use_cassette "bank_holidays" do
          application_digest
          expect(digest.firm_name).to eq firm_name
          expect(digest.provider_username).to eq username
          expect(digest.date_started).to eq creation_date
          expect(digest.date_submitted).to eq submission_date
          expect(digest.days_to_submission).to eq 4
          expect(digest.matter_types).to eq "Domestic Abuse;Section 8 orders"
          expect(digest.proceedings).to eq "DA001;SE013;SE014"
        end
      end
    end

    context "with use_ccms" do
      context "when application is not at use_ccms" do
        it "is false" do
          application_digest
          expect(digest.use_ccms).to be false
        end
      end

      context "when application is at use_ccms" do
        it "is true" do
          described_class.create_or_update!(laa_at_use_ccms.id)
          digest = described_class.find_by(legal_aid_application_id: laa_at_use_ccms.id)
          expect(digest.use_ccms).to be true
        end
      end
    end

    context "when passported" do
      before do
        application_digest
      end

      context "when application is passported" do
        let(:laa) do
          travel_to creation_time do
            create(:legal_aid_application,
                   :assessment_submitted,
                   :with_everything,
                   :with_proceedings,
                   :with_cfe_v5_result,
                   :with_passported_state_machine,
                   explicit_proceedings: %i[da001 se013 se014],
                   provider:,
                   merits_submitted_at: submission_time)
          end
        end

        it "returns true" do
          expect(digest.passported).to be true
        end
      end

      context "when application is NOT passported" do
        let(:laa) do
          travel_to creation_time do
            create(:legal_aid_application,
                   :assessment_submitted,
                   :with_everything,
                   :with_proceedings,
                   :with_cfe_v5_result,
                   :with_non_passported_state_machine,
                   explicit_proceedings: %i[da001 se013 se014],
                   provider:,
                   merits_submitted_at: submission_time)
          end
        end

        it "returns false" do
          expect(digest.passported).to be false
        end
      end
    end

    context "with delegated_functions" do
      context "and delegated_functions not used" do
        it "returns false and nils" do
          application_digest
          expect(digest.df_used).to be false
          expect(digest.earliest_df_date).to be_nil
          expect(digest.df_reported_date).to be_nil
          expect(digest.working_days_to_report_df).to be_nil
        end
      end

      context "and delegated_functions used" do
        before do
          # DF used on DA001 and SE014 only - used and reported dates specified in array
          # Good Friday on 2nd April, Easter Monday 5th April
          dates = {
            "DA001" => [Date.parse("2021-03-29"), Date.parse("2021-04-08")],
            "SE013" => [nil, nil],
            "SE014" => [Date.parse("2021-04-06"), Date.parse("2021-04-07")],
          }
          laa.proceedings.each do |proceeding|
            used_date, reported_date = dates[proceeding.ccms_code]
            proceeding.update!(used_delegated_functions: true, used_delegated_functions_on: used_date, used_delegated_functions_reported_on: reported_date)
          end
          laa.reload
        end

        # for some reason, just running the test with VCR_RECORD_MODE=all would not create the cassette, so have to do it manually here
        it "returns true and dates" do
          VCR.use_cassette "ApplicationDigest/create_or_update/delegated_functions/delegated_functions_used/returns_true_and_dates" do
            application_digest
            expect(digest.df_used).to be true
            expect(digest.earliest_df_date).to eq Date.parse("2021-03-29")
            expect(digest.df_reported_date).to eq Date.parse("2021-04-08")
            expect(digest.working_days_to_report_df).to eq 7
          end
        end
      end
    end
  end
end
