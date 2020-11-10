require 'rails_helper'

module Reports
  module MIS
    RSpec.describe NonPassportedApplicationsReport do
      before do
        Timecop.freeze(10.seconds.ago) { create_early_non_passported_application }
        Timecop.freeze(8.seconds.ago) { create_non_passported_application }
        Timecop.freeze(6.seconds.ago) { create_non_passported_application_use_ccms }
        Timecop.freeze(4.seconds.ago) { create_passported_application }
      end

      subject { described_class.new.run }

      describe 'run' do
        let(:application) { LegalAidApplication.find_by(application_ref: 'L-ATE') }
        let(:username) { application.provider.username }
        let(:email) { application.provider.email }
        let(:created_at) { application.created_at.strftime('%Y-%m-%d %H:%M:%S') }
        let(:lines) { subject.split("\n") }

        it 'three lines of data' do
          expect(lines.size).to eq 3
        end

        it 'returns a header line as the first line' do
          expect(lines.first).to eq 'application_ref,state,ccms_reason,username,provider_email,created_at'
        end

        it 'returns data for the only non-passorted application after Sep 21st as second line' do
          expect(lines[1]).to eq "L-ATE,initiated,,#{username},#{email},#{created_at}"
          expect(lines[2]).to match(/^L-USE-CCMS,use_ccms,employed,/)
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

      def create_non_passported_application_use_ccms
        create :legal_aid_application,
               :with_negative_benefit_check_result,
               :with_non_passported_state_machine,
               :use_ccms_employed,
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
