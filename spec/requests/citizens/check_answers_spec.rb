require 'rails_helper'

RSpec.describe 'check your answers requests', type: :request do
  include ActionView::Helpers::NumberHelper
  let(:firm) { create :firm }
  let(:provider) { create :provider, firm: firm }
  let(:vehicle) { create :vehicle, :populated }
  let(:own_vehicle) { true }
  let(:credit) { create :transaction_type, :credit_with_standard_name }
  let(:debit) { create :transaction_type, :debit_with_standard_name }
  let!(:legal_aid_application) do
    create :legal_aid_application,
           :with_non_passported_state_machine,
           :applicant_entering_means,
           :with_everything,
           :with_student_finance,
           :with_irregular_income,
           vehicle: vehicle,
           own_vehicle: own_vehicle,
           has_restrictions: has_restrictions,
           restrictions_details: restrictions_details,
           provider: provider
  end
  let!(:application_transaction_types) do
    create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: credit
    create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: debit
  end

  let(:has_restrictions) { true }
  let(:restrictions_details) { Faker::Lorem.paragraph }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  before { get citizens_legal_aid_application_path(secure_id) }

  describe 'GET /citizens/check_answers' do
    subject { get '/citizens/check_answers' }
    before { subject }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct section headings' do
      expect(response.body).to include('Your bank accounts')
      expect(response.body).to include('Payments you receive')
      expect(response.body).to include('Payments you receive in cash')
      expect(response.body).to include('Payments you make')
      expect(response.body).to include('Payments you make in cash')
      expect(response.body).to include('Do you get student finance?')
      expect(response.body).to include('How much student finance will you get this academic year?')
    end

    it 'displays the correct URLs for changing values' do
      expect(response.body).to have_change_link(:incomings, citizens_identify_types_of_income_path)
      expect(response.body).to have_change_link(:payments, citizens_identify_types_of_outgoing_path)
    end

    it 'should change the state to "checking_citizen_answers"' do
      expect(legal_aid_application.reload.checking_citizen_answers?).to be_truthy
    end

    it 'displays the name of the firm' do
      subject
      expect(response.body).to include(html_compare(firm.name))
    end

    context 'firms with special characters in the name' do
      let(:firm) { create :firm, name: %q(O'Keefe & Sons - "Pay less with  <The master builders>!") }
      it 'finds the firm even though it has special characters' do
        subject
        expect(response.body).to include(html_compare(firm.name))
      end
    end
  end

  describe 'PATCH /citizens/check_answers/continue' do
    subject { patch '/citizens/check_answers/continue' }

    before do
      legal_aid_application.check_citizen_answers!
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(flow_forward_path)
    end

    it 'changes the state' do
      expect { subject }.to change { legal_aid_application.reload.state }
    end

    it 'sets the application state to analysing_bank_transactions' do
      subject
      expect(legal_aid_application.reload.state).to eq 'analysing_bank_transactions'
      expect(legal_aid_application.completed_at).to be_within(1).of(Time.current)
    end

    it 'changes the provider step to start_chances_of_success' do
      subject
      expect(legal_aid_application.reload.provider_step).to eq('client_completed_means')
    end

    it 'records when the declaration was accepted' do
      subject
      expect(legal_aid_application.reload.declaration_accepted_at).to be_between(2.seconds.ago, Time.current)
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

  describe 'PATCH /citizens/check_answers/reset' do
    subject { patch '/citizens/check_answers/reset' }

    before do
      legal_aid_application.check_citizen_answers!
      get citizens_identify_types_of_outgoing_path
      get citizens_check_answers_path
      subject
    end

    it 'should redirect back' do
      expect(response).to redirect_to(citizens_identify_types_of_outgoing_path(back: true))
    end

    it 'should change the state back to "applicant_entering_means"' do
      expect(legal_aid_application.reload.applicant_entering_means?).to be true
    end
  end
end
