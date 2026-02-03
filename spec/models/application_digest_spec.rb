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
                   shared_benefit_with_partner: false,
                   partner_has_contrary_interest: true)
          end

          it "returns the expected data" do
            application_digest
            expect(digest.has_partner).to be true
            expect(digest.contrary_interest).to be true
            expect(digest.partner_dwp_challenge).to be false
          end
        end

        context "when the applicant has a partner with contrary interest and disputed benefits" do
          let(:applicant) do
            create(:applicant,
                   :with_partner,
                   shared_benefit_with_partner: true,
                   partner_has_contrary_interest: true)
          end

          it "returns the expected data" do
            application_digest
            expect(digest.has_partner).to be true
            expect(digest.contrary_interest).to be true
            expect(digest.partner_dwp_challenge).to be true
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

      describe "linked application fields" do
        context "when the application has no linked applications" do
          it "returns the expected data" do
            application_digest

            expect(digest.family_linked).to be false
            expect(digest.family_linked_lead_or_associated).to be_nil
            expect(digest.number_of_family_linked_applications).to be_nil
            expect(digest.legal_linked).to be false
            expect(digest.legal_linked_lead_or_associated).to be_nil
            expect(digest.number_of_legal_linked_applications).to be_nil
          end
        end

        context "when the application is a lead family linked application" do
          let(:linked_application) { create(:legal_aid_application) }

          before do
            LinkedApplication.create!(lead_application_id: laa.id, associated_application_id: linked_application.id, link_type_code: "FC_LEAD", confirm_link: true)
          end

          it "returns the expected data" do
            application_digest

            expect(digest.family_linked).to be true
            expect(digest.family_linked_lead_or_associated).to eq "Lead"
            expect(digest.number_of_family_linked_applications).to eq 2
            expect(digest.legal_linked).to be false
            expect(digest.legal_linked_lead_or_associated).to be_nil
            expect(digest.number_of_legal_linked_applications).to be_nil
          end
        end

        context "when the application is an associated family linked application" do
          let(:linked_application) { create(:legal_aid_application) }

          before do
            LinkedApplication.create!(lead_application_id: linked_application.id, associated_application_id: laa.id, link_type_code: "FC_LEAD", confirm_link: true)
          end

          it "returns the expected data" do
            application_digest

            expect(digest.family_linked).to be true
            expect(digest.family_linked_lead_or_associated).to eq "Associated"
            expect(digest.number_of_family_linked_applications).to be_nil
            expect(digest.legal_linked).to be false
            expect(digest.legal_linked_lead_or_associated).to be_nil
            expect(digest.number_of_legal_linked_applications).to be_nil
          end
        end

        context "when the application is a lead legal linked application" do
          let(:linked_application) { create(:legal_aid_application) }
          let(:another_associated_application) { create(:legal_aid_application) }

          before do
            LinkedApplication.create!(lead_application_id: laa.id, associated_application_id: linked_application.id, link_type_code: "LEGAL", confirm_link: true)
            LinkedApplication.create!(lead_application_id: laa.id, associated_application_id: another_associated_application.id, link_type_code: "LEGAL", confirm_link: true)
          end

          it "returns the expected data" do
            application_digest

            expect(digest.family_linked).to be false
            expect(digest.family_linked_lead_or_associated).to be_nil
            expect(digest.number_of_family_linked_applications).to be_nil
            expect(digest.legal_linked).to be true
            expect(digest.legal_linked_lead_or_associated).to eq "Lead"
            expect(digest.number_of_legal_linked_applications).to eq 3
          end
        end

        context "when the application is an associated legal linked application" do
          let(:lead_application) { create(:legal_aid_application) }

          before do
            LinkedApplication.create!(lead_application_id: lead_application.id, associated_application_id: laa.id, link_type_code: "LEGAL", confirm_link: true)
          end

          it "returns the expected data" do
            application_digest

            expect(digest.family_linked).to be false
            expect(digest.family_linked_lead_or_associated).to be_nil
            expect(digest.number_of_family_linked_applications).to be_nil
            expect(digest.legal_linked).to be true
            expect(digest.legal_linked_lead_or_associated).to eq "Associated"
            expect(digest.number_of_legal_linked_applications).to be_nil
          end
        end

        context "when the application is both a lead family linked application and a lead legal linked application" do
          let(:family_linked_application) { create(:legal_aid_application) }
          let(:legal_linked_application) { create(:legal_aid_application) }

          before do
            LinkedApplication.create!(lead_application_id: laa.id, associated_application_id: family_linked_application.id, link_type_code: "FC_LEAD", confirm_link: true)
            LinkedApplication.create!(lead_application_id: laa.id, associated_application_id: legal_linked_application.id, link_type_code: "LEGAL", confirm_link: true)
          end

          it "returns the expected data" do
            application_digest

            expect(digest.family_linked).to be true
            expect(digest.family_linked_lead_or_associated).to eq "Lead"
            expect(digest.number_of_family_linked_applications).to eq 2
            expect(digest.legal_linked).to be true
            expect(digest.legal_linked_lead_or_associated).to eq "Lead"
            expect(digest.number_of_legal_linked_applications).to eq 2
          end
        end

        context "when the provider has started but not completed the linking process" do
          context "when the provider has not selected the lead application to link to" do
            before do
              LinkedApplication.create!(associated_application_id: laa.id, link_type_code: "FC_LEAD")
            end

            it "returns the expected data" do
              application_digest

              expect(digest.family_linked).to be false
              expect(digest.family_linked_lead_or_associated).to be_nil
              expect(digest.number_of_family_linked_applications).to be_nil
              expect(digest.legal_linked).to be false
              expect(digest.legal_linked_lead_or_associated).to be_nil
              expect(digest.number_of_legal_linked_applications).to be_nil
            end

            context "when the provider has not confirmed the link" do
              let(:linked_application) { create(:legal_aid_application) }

              before do
                LinkedApplication.create!(lead_application_id: linked_application.id, associated_application_id: laa.id, link_type_code: "FC_LEAD")
              end

              it "returns the expected data" do
                application_digest

                expect(digest.family_linked).to be false
                expect(digest.family_linked_lead_or_associated).to be_nil
                expect(digest.number_of_family_linked_applications).to be_nil
                expect(digest.legal_linked).to be false
                expect(digest.legal_linked_lead_or_associated).to be_nil
                expect(digest.number_of_legal_linked_applications).to be_nil
              end
            end
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
        let(:bank_holidays_cache) { Redis.new(url: Rails.configuration.x.redis.bank_holidays_url) }

        before do
          bank_holidays_cache.flushdb
          stub_bankholiday_legacy_success
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

        after do
          bank_holidays_cache.flushdb
          bank_holidays_cache.quit
        end

        # for some reason, just running the test with VCR_RECORD_MODE=all would not create the cassette, so have to do it manually here
        it "returns true and dates" do
          application_digest
          expect(digest.df_used).to be true
          expect(digest.earliest_df_date).to eq Date.parse("2021-03-29")
          expect(digest.df_reported_date).to eq Date.parse("2021-04-08")
          expect(digest.working_days_to_report_df).to eq 7
        end
      end
    end

    describe "applicant address" do
      context "when they have no fixed residence" do
        before { laa.applicant.update(no_fixed_residence: true) }

        it "sets no_fixed_address to true" do
          application_digest
          expect(digest.no_fixed_address).to be true
        end
      end

      context "when they have a home address" do
        before { laa.applicant.update(no_fixed_residence: false) }

        it "sets no_fixed_address to false" do
          application_digest
          expect(digest.no_fixed_address).to be false
        end
      end

      context "when the question is not answered (legacy applications)" do
        it "sets no_fixed_address to false" do
          application_digest
          expect(digest.no_fixed_address).to be false
        end
      end
    end

    describe "sca fields" do
      let(:sca_proceeding) { create(:proceeding, :pb059) }

      before do
        laa.proceedings << sca_proceeding
        laa.applicant.update!(relationship_to_children:)
      end

      context "when the application has a proceeding with relationship_to_child biological" do
        let(:relationship_to_children) { "biological" }

        it "returns the expected data" do
          application_digest
          expect(digest.biological_parent).to be true
          expect(digest.parental_responsibility_agreement).to be false
          expect(digest.parental_responsibility_court_order).to be false
          expect(digest.child_subject).to be false
          expect(digest.parental_responsibility_evidence).to be false
        end
      end

      context "when the application has a proceeding with relationship_to_child parental_responsibility_agreement" do
        let(:relationship_to_children) { "parental_responsibility_agreement" }
        let(:parental_responsibility_evidence) { create(:attachment, :parental_responsibility, attachment_name: "parental_responsibility") }

        before do
          laa.proceedings << sca_proceeding
          laa.attachments << parental_responsibility_evidence
        end

        it "returns the expected data" do
          application_digest
          expect(digest.biological_parent).to be false
          expect(digest.parental_responsibility_agreement).to be true
          expect(digest.parental_responsibility_court_order).to be false
          expect(digest.child_subject).to be false
          expect(digest.parental_responsibility_evidence).to be true
        end
      end

      context "when the application has a proceeding with relationship_to_child court_order" do
        let(:relationship_to_children) { "court_order" }

        before { laa.proceedings << sca_proceeding }

        it "returns the expected data" do
          application_digest
          expect(digest.biological_parent).to be false
          expect(digest.parental_responsibility_agreement).to be false
          expect(digest.parental_responsibility_court_order).to be true
          expect(digest.child_subject).to be false
          expect(digest.parental_responsibility_evidence).to be false
        end
      end

      context "when the application has a proceeding with relationship_to_child child_subject" do
        let(:relationship_to_children) { "child_subject" }

        before { laa.proceedings << sca_proceeding }

        it "returns the expected data" do
          application_digest
          expect(digest.biological_parent).to be false
          expect(digest.parental_responsibility_agreement).to be false
          expect(digest.parental_responsibility_court_order).to be false
          expect(digest.child_subject).to be true
          expect(digest.parental_responsibility_evidence).to be false
        end
      end
    end

    describe "autogranted" do
      context "when the application is not autogranted" do
        it "returns autogranted false" do
          application_digest
          expect(digest.autogranted).to be false
        end
      end
    end
  end
end
