require 'rails_helper'

RSpec.describe HMRC::CreateResponsesService do
  subject(:create_service) { described_class.new(legal_aid_application) }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_transaction_period }

  describe '#call' do
    subject(:call) { described_class.call(legal_aid_application) }

    context 'when successful' do
      it 'creates two hmrc_response records, one for each use case' do
        expect { call }.to change { legal_aid_application.hmrc_responses.count }.by(2)
      end
      it 'creates two jobs to request the data' do
        expect { call }.to change(HMRC::SubmissionWorker.jobs, :size).by(2)
      end
    end
  end
end
