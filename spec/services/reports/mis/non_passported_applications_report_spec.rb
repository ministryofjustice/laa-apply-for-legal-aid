require 'rails_helper'

module Reports
  module MIS
    RSpec.describe NonPassportedApplicationsReport do
      before do
        create_early_non_passported_application
        travel_to(8.minutes.ago) { create_non_passported_application }
        travel_to(6.minutes.ago) { create_non_passported_application_use_ccms }
        travel_to(4.minutes.ago) { create_passported_application }
        travel_to(2.minutes.ago) { create_submitted_application }
      end

      after do
        travel_back
      end

      subject { described_class.new.run }

      describe 'run' do
        let(:application) { LegalAidApplication.find_by(application_ref: 'L-ATE') }
        let(:username) { application.provider.username }
        let(:applicant) { application.applicant }
        let(:email) { application.provider.email }
        let(:created_at) { application.created_at.strftime('%Y-%m-%d %H:%M:%S') }
        let(:submission_date) { LegalAidApplication.find_by(application_ref: 'L-SUBMITTED').ccms_submission_date.strftime('%Y-%m-%d %H:%M:%S') }
        let(:lines) { subject.split("\n") }

        it 'four lines of data' do
          expect(lines.size).to eq 4
        end

        it 'returns a header line as the first line' do
          expect(lines.first).to eq 'state,ccms_reason,username,provider_email,created_at,date_submitted,applicant_name,deleted'
        end

        it 'returns data for all non-passorted applications after Sep 21st' do
          expect(lines[1]).to eq %(checking_citizen_answers,,#{username},#{email},#{created_at},,#{applicant.full_name},"")
          expect(lines[2]).to match(/^use_ccms,employed,/)
          expect(lines[3]).to match(/^assessment_submitted,.*#{submission_date},.*$/)
        end
      end

      def create_early_non_passported_application
        travel_to(Time.zone.local(2020, 9, 1, 2, 3, 4)) do
          create :legal_aid_application,
                 :with_applicant,
                 :with_negative_benefit_check_result,
                 :with_non_passported_state_machine,
                 :at_client_completed_means,
                 application_ref: 'L-EAR-LY'
        end
      end

      def create_non_passported_application
        create :legal_aid_application,
               :with_applicant,
               :with_negative_benefit_check_result,
               :with_non_passported_state_machine,
               :at_client_completed_means,
               application_ref: 'L-ATE'
      end

      def create_non_passported_application_use_ccms
        create :legal_aid_application,
               :with_applicant,
               :with_negative_benefit_check_result,
               :with_non_passported_state_machine,
               :use_ccms_employed,
               application_ref: 'L-USE-CCMS'
      end

      def create_passported_application
        create :legal_aid_application,
               :with_applicant,
               :with_passported_state_machine,
               :with_positive_benefit_check_result,
               application_ref: 'L-PASS'
      end

      def create_submitted_application
        create :legal_aid_application,
               :with_applicant,
               :with_negative_benefit_check_result,
               :with_non_passported_state_machine,
               :at_assessment_submitted,
               application_ref: 'L-SUBMITTED'
      end
    end
  end
end
