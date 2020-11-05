require 'rails_helper'

module Reports
  module MIS
    RSpec.describe NonPassportedApplicationsReport do
      before do
        create_early_non_passported_application
        create_non_passported_application
        create_non_passported_applicationin_use_ccms
        create_passported_application
      end

      subject { described_class.new.run }

      describe 'run' do
        let(:application) { LegalAidApplication.find_by(application_ref: 'L-ATE') }
        let(:username) { application.provider.username }
        let(:email) { application.provider.email }
        let(:created_at) { application.created_at.strftime('%Y-%m-%d %H:%M:%S') }
        let(:lines) { subject.split("\n") }

        it 'two lines of data' do
          expect(lines.size).to eq 2
        end

        it 'returns a header line as the first line' do
          expect(lines.first).to eq 'application_ref,state,ccms_reason,username,provider_email,created_at'
        end

        it 'returns data for the only non-passorted application after Sep 21st as second line' do
          expect(lines[1]).to eq "L-ATE,initiated,,#{username},#{email},#{created_at}"
        end
      end

      def create_early_non_passported_application
        Timecop.freeze(Time.new(2020, 9, 1, 2, 3, 4)) do
          create :legal_aid_application,
                 :with_negative_benefit_check_result,
                 :with_non_passported_state_machine,
                 :at_client_completed_means,
                 application_ref: 'L-EAR-LY'
        end
      end

      def create_non_passported_application
        create :legal_aid_application,
               :with_negative_benefit_check_result,
               :with_non_passported_state_machine,
               :at_client_completed_means,
               application_ref: 'L-ATE'
      end

      def create_non_passported_applicationin_use_ccms
        create :legal_aid_application,
               :with_negative_benefit_check_result,
               :with_non_passported_state_machine,
               :at_use_ccms,
               application_ref: 'L-USE-CCMS'
      end

      def create_passported_application
        create :legal_aid_application,
               :with_passported_state_machine,
               :with_positive_benefit_check_result,
               application_ref: 'L-PASS'
      end
    end
  end
end
