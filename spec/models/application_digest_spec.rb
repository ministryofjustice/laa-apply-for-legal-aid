require "rails_helper"

RSpec.describe ApplicationDigest do
  describe ".create_or_update!" do
    subject { described_class.create_or_update!(laa.id) }

    let(:firm_name) { "Regional Legal Services" }
    let(:username) { "regional_user_1" }
    let(:firm) { create :firm, name: firm_name }
    let(:provider) { create :provider, firm:, username: }
    let(:creation_time) { Time.zone.local(2019, 1, 1, 12, 15, 30) }
    let(:creation_date) { creation_time.to_date }
    let(:submission_time) { creation_time + 3.days }
    let(:submission_date) { submission_time.to_date }

    let(:laa) do
      travel_to creation_time do
        create :legal_aid_application,
               :assessment_submitted,
               :with_everything,
               :with_proceedings,
               :with_cfe_v4_result,
               explicit_proceedings: %i[da001 se013 se014],
               provider:,
               merits_submitted_at: submission_time
      end
    end
    let(:laa_at_use_ccms) { create :legal_aid_application, :use_ccms, :with_applicant }

    let(:digest) { described_class.find_by(legal_aid_application_id: laa.id) }

    context "when a digest record already exists for this application" do
      before { create :application_digest, legal_aid_application_id: laa.id }

      it "does not create a new record" do
        expect { subject }.not_to change(described_class, :count)
      end

      it "updates the values on the existing record" do
        subject
        expect(digest.firm_name).to eq firm_name
        expect(digest.provider_username).to eq username
        expect(digest.date_started).to eq creation_date
        expect(digest.date_submitted).to eq submission_date
        expect(digest.days_to_submission).to eq 4
        expect(digest.matter_types).to eq "Domestic Abuse;Section 8 orders"
        expect(digest.proceedings).to eq "DA001;SE013;SE014"
      end

      describe "applicant employment status" do
        context "when not employed" do
          it "writes false to the digest record" do
            subject
            expect(digest.employed).to be false
          end
        end

        context "when employed" do
          before { laa.applicant.update(employed: true) }

          it "writes true to the digest record" do
            subject
            expect(digest.employed).to be true
          end
        end
      end

      describe "hmrc_data_used" do
        before { allow(HMRC::StatusAnalyzer).to receive(:call).with(laa).and_return(hmrc_status) }

        context "when HMRC::StatusAnalyzer runs succesfully" do
          before { subject }

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

          context "but no hrmrc data" do
            let(:hmrc_status) { :no_hmrc_data }

            it "returns false" do
              expect(digest.hmrc_data_used).to be false
            end
          end

          context "and multiple employments" do
            let(:hmrc_status) { :hmrc_multiple_employments }

            it "returns false" do
              expect(digest.hmrc_data_used).to be false
            end
          end

          context "and single employment" do
            let(:hmrc_status) { :hmrc_single_employment }

            it "returns false" do
              expect(digest.hmrc_data_used).to be true
            end
          end
        end

        context "when an unknown result is received from HMRC::StatusAnalyzer" do
          let(:hmrc_status) { :what_is_this? }

          it "raises" do
            expect { subject }.to raise_error RuntimeError, "Unexpected response from HMRC::StatusAnalyser :what_is_this?"
          end
        end
      end

      describe "referred_to_caseworker" do
        before { allow(CCMS::ManualReviewDeterminer).to receive(:new).and_return(mock_determiner) }

        let(:mock_determiner) { instance_double(CCMS::ManualReviewDeterminer, manual_review_required?: review_required) }

        context "when not referred to caseworker" do
          let(:review_required) { false }

          it "returns false" do
            subject
            expect(digest.referred_to_caseworker).to be false
          end
        end

        context "when referred to caseworker" do
          let(:review_required) { true }

          it "returns true" do
            subject
            expect(digest.referred_to_caseworker).to be true
          end
        end
      end
    end

    context "when no digest record exists for this application" do
      it "creates a new record" do
        VCR.use_cassette "bank_holidays" do
          expect { subject }.to change(described_class, :count).by(1)
        end
      end

      it "creates a record with expected values" do
        VCR.use_cassette "bank_holidays" do
          subject
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

    context "use_ccms" do
      context "application is not at use_ccms" do
        it "is false" do
          subject
          expect(digest.use_ccms).to be false
        end
      end

      context "application is at use_ccms" do
        it "is true" do
          described_class.create_or_update!(laa_at_use_ccms.id)
          digest = described_class.find_by(legal_aid_application_id: laa_at_use_ccms.id)
          expect(digest.use_ccms).to be true
        end
      end
    end

    context "passported" do
      context "application is passported" do
        before do
          allow_any_instance_of(LegalAidApplication).to receive(:passported?).and_return(true)
          subject
        end

        it "returns true" do
          expect(digest.passported).to be true
        end
      end

      context "application is NOT passported" do
        before do
          allow_any_instance_of(LegalAidApplication).to receive(:passported?).and_return(false)
          subject
        end

        it "returns true" do
          expect(digest.passported).to be false
        end
      end
    end

    context "delegated_functions" do
      context "delegated_functions not used" do
        it "returns false and nils" do
          subject
          expect(digest.df_used).to be false
          expect(digest.earliest_df_date).to be_nil
          expect(digest.df_reported_date).to be_nil
          expect(digest.working_days_to_report_df).to be_nil
        end
      end

      context "delegated_functions used" do
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
            proceeding.update!(used_delegated_functions_on: used_date, used_delegated_functions_reported_on: reported_date)
          end
          laa.reload
        end

        # for some reason, just running the test with VCR_RECORD_MODE=all would not create the cassette, so have to do it manually here
        it "returns true and dates" do
          VCR.use_cassette "ApplicationDigest/create_or_update/delegated_functions/delegated_functions_used/returns_true_and_dates" do
            subject
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
