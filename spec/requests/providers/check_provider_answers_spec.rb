require 'rails_helper'

RSpec.describe 'check your answers requests', type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/check_provider_answers' do
    subject { get "/providers/applications/#{application_id}/check_provider_answers" }

    context 'when the application does not exist' do
      let(:application_id) { SecureRandom.uuid }

      it 'redirects to the applications page with an error' do
        subject

        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'returns success' do
      subject

      expect(response).to be_successful
    end

    it 'displays the correct page' do
      subject

      expect(unescaped_response_body).to include('Check your answers')
    end

    it 'displays the correct proceeding' do
      subject

      expect(unescaped_response_body).to include(application.proceeding_types[0].meaning)
    end

    it 'displays the correct client details' do
      subject

      applicant = application.applicant
      address = applicant.addresses[0]

      expect(unescaped_response_body).to include(applicant.first_name)
      expect(unescaped_response_body).to include(applicant.last_name)
      expect(unescaped_response_body).to include(applicant.date_of_birth.to_s)
      expect(unescaped_response_body).to include(applicant.national_insurance_number)
      expect(unescaped_response_body).to include(applicant.email_address)
      expect(unescaped_response_body).to include(address.address_line_one)
      expect(unescaped_response_body).to include(address.city)
      expect(unescaped_response_body).to include(address.postcode)
    end

    it 'should have a link to next step' do
      subject
      expect(unescaped_response_body).to include(providers_legal_aid_application_check_benefits_path(application))
    end

    context "the applicant's address used s address lookup service" do
      let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address_lookup) }

      it 'should have a link to the address lookup page' do
        subject
        expect(unescaped_response_body).to include(providers_legal_aid_application_address_selection_path(application))
      end
    end

    context "the applicant's address used manual entry" do
      it 'should have a link to manual address pagelookup page' do
        subject
        expect(unescaped_response_body).to include(providers_legal_aid_application_address_path(application))
      end
    end
  end
end
