require 'rails_helper'

module CCMS
  RSpec.describe CaseAddRequestorFactory do
    let(:submission) { create :submission, legal_aid_application: legal_aid_application }

    context 'passported' do
      let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
      it 'returns an instance of CaseAddRequestor' do
        expect(CaseAddRequestorFactory.call(submission, {})).to be_instance_of(Requestors::CaseAddRequestor)
      end
    end

    context 'non-passported' do
      let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }
      it 'returns an instance of CaseAddRequestor' do
        expect(CaseAddRequestorFactory.call(submission, {})).to be_instance_of(Requestors::NonPassportedCaseAddRequestor)
      end
    end
  end
end
