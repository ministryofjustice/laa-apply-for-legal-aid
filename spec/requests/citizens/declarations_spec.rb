require 'rails_helper'

RSpec.describe Citizens::DeclarationsController, type: :request do
  let(:firm) { create :firm }
  let(:provider) { create :provider, firm: firm }
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :applicant_entering_means, :with_applicant, provider: provider }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
  end

  describe 'GET /citizens/declaration' do
    subject { get citizens_declaration_path }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays the name of the firm' do
      subject
      expect(unescaped_response_body).to include(firm.name)
    end

    context 'with completed application' do
      it 'redirects to already completed' do
        legal_aid_application.update completed_at: 1.minute.ago
        subject
        expect(response).to redirect_to(error_path(:assessment_already_completed))
      end
    end
  end

  describe 'PATCH /citizens/declaration' do
    subject { patch citizens_declaration_path }

    before do
      legal_aid_application.check_citizen_answers!
    end

    # Uncomment when next step defined.
    xit 'redirects to next step' do
      subject
      expect(response).to redirect_to(flow_forward_path)
    end

    it 'sets the application state to analysing_bank_transactions' do
      subject
      expect(legal_aid_application.reload.state).to eq 'analysing_bank_transactions'
      expect(legal_aid_application.completed_at).to be_within(1).of(Time.current)
    end

    it 'changes the provider step to start_merits_assessment' do
      subject
      expect(legal_aid_application.reload.provider_step).to eq('client_completed_means')
    end

    it 'records when the declartion accepted' do
      subject
      expect(legal_aid_application.reload.declaration_accepted_at).to be_between(2.seconds.ago, Time.now)
    end

    it 'syncs the application' do
      expect(CleanupCapitalAttributes).to receive(:call).with(legal_aid_application)
      subject
    end

    it 'saves the applicant means answers' do
      expect(SaveApplicantMeansAnswers).to receive(:call).with(legal_aid_application)
      subject
    end
  end
end
