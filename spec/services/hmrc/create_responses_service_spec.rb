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

    context 'when requests already exist' do
      let!(:hmrc_response) { create :hmrc_response, legal_aid_application: legal_aid_application }
      it 'does not create any more hmrc_response records' do
        expect { call }.not_to change { legal_aid_application.hmrc_responses.count }
      end
      it 'does not create any jobs to request the data' do
        expect { call }.not_to change(HMRC::SubmissionWorker.jobs, :size)
      end
    end
  end
end
