require 'rails_helper'

RSpec.describe 'check passported answers requests', type: :request do
  include ActionView::Helpers::NumberHelper

  describe 'GET /providers/applications/:id/check_passported_answers' do
    let(:vehicle) { create :vehicle, :populated }
    let(:own_vehicle) { true }
    let!(:application) do
      create :legal_aid_application,
             :with_everything,
             :with_proceeding_types,
             :with_passported_state_machine,
             :provider_entering_means,
             vehicle: vehicle,
             own_vehicle: own_vehicle
    end

    subject { get "/providers/applications/#{application.id}/check_passported_answers" }

    context 'unauthenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'logged in as an authenticated provider' do
      before do
        login_as application.provider
        application.reload
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the correct details' do
        expect(response.body).to include(I18n.t("shared.forms.own_home_form.#{application.own_home}"))
        expect(response.body).to include(gds_number_to_currency(application.property_value, unit: '£'))
        expect(response.body).to include(gds_number_to_currency(application.outstanding_mortgage_amount, unit: '£'))
        expect(response.body).to include(I18n.t("shared.forms.shared_ownership_form.#{application.shared_ownership}"))
        expect(response.body).to include(number_to_percentage(application.percentage_home, precision: 2))
        expect(response.body).to include('Does your client own the home they live in?')
        expect(unescaped_response_body).to include("How much is your client's home worth?")
        expect(unescaped_response_body).to include("What is the outstanding mortgage on your client's home?")
        expect(response.body).to include('Does your client own their home with anyone else?')
        expect(response.body).to include('What % share of their home does your client legally own?')
        expect(response.body).to include('Savings')
        expect(response.body).to include('assets')
        expect(response.body).to include('restrictions')
      end

      it 'displays the correct vehicles details' do
        expect(response.body).to include(gds_number_to_currency(vehicle.estimated_value, unit: '£'))
        expect(response.body).to include(gds_number_to_currency(vehicle.payment_remaining, unit: '£'))
        expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.heading'))
        expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.own'))
        expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.estimated_value'))
        expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.payment_remaining'))
        expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.more_than_three_years_old'))
        expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.used_regularly'))
      end

      it 'displays None Declared in the policy disregards section' do
        parsed_response = Nokogiri::HTML(response.body)
        node = parsed_response.css('#app-check-your-answers__policy_disregards_header + .govuk-summary-list')
        expect(node.text).to include(I18n.t('.generic.none_declared'))
      end

      context 'applicant does not have any savings' do
        let(:application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_proceeding_types,
                 :with_no_savings,
                 :with_passported_state_machine,
                 :provider_entering_means
        end
        it 'displays that no savings have been declared' do
          expect(response.body).to include(I18n.t('.generic.none_declared'))
        end
      end

      context 'applicant does not have any other assets' do
        let(:application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_proceeding_types,
                 :with_no_other_assets,
                 :with_passported_state_machine,
                 :provider_entering_means
        end
        it 'displays that no other assets have been declared' do
          expect(response.body).to include(I18n.t('.generic.none_declared'))
        end
      end

      context 'applicant does not have any capital restrictions' do
        let(:application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_proceeding_types,
                 :with_passported_state_machine,
                 :provider_entering_means,
                 has_restrictions: false
        end
        it 'displays that no capital restrictions have been declared' do
          expect(response.body).to include(I18n.t('.generic.no'))
        end
      end

      context 'applicant does not have any capital' do
        let(:application) do
          create :legal_aid_application,
                 :with_applicant,
                 :with_proceeding_types,
                 :with_policy_disregards,
                 :without_own_home,
                 :with_passported_state_machine,
                 :provider_entering_means
        end
        it 'does not display capital restrictions' do
          expect(response.body).not_to include('restrictions')
        end
      end

      it 'displays the correct URLs for changing values' do
        expect(response.body).to have_change_link(:own_home, providers_legal_aid_application_own_home_path(application))
        expect(response.body).to have_change_link(:property_value, providers_legal_aid_application_property_value_path(application, anchor: 'property_value'))
        expect(response.body).to have_change_link(:shared_ownership, providers_legal_aid_application_shared_ownership_path(application))
        expect(response.body).to have_change_link(:percentage_home, providers_legal_aid_application_percentage_home_path(application, anchor: 'percentage_home'))
        expect(response.body).to include(providers_legal_aid_application_offline_account_path(application))
        expect(response.body).to include(providers_legal_aid_application_other_assets_path(application))
        expect(response.body).to include(providers_legal_aid_application_restrictions_path(application))
      end

      it 'displays the correct savings details' do
        application.savings_amount.amount_attributes.each do |_attr, amount|
          expect(response.body).to include(gds_number_to_currency(amount, unit: '£')), 'saving amount should be in the page'
        end
      end

      it 'displays the correct assets details' do
        application.other_assets_declaration.amount_attributes.each do |attr, amount|
          expected = if attr == 'second_home_percentage'
                       number_to_percentage(amount, precision: 2)
                     else
                       gds_number_to_currency(amount, unit: '£')
                     end
          expect(response.body).to include(expected), 'asset amount should be in the page'
        end
      end

      it 'should change the state to "checking_passported_answers"' do
        expect(application.reload.checking_passported_answers?).to be_truthy
      end

      context 'applicant does not own home' do
        let(:application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_proceeding_types,
                 :without_own_home,
                 :with_passported_state_machine,
                 :provider_entering_means
        end
        it 'does not display property value' do
          expect(response.body).not_to include(gds_number_to_currency(application.property_value, unit: '£'))
          expect(response.body).not_to include('Property value')
        end

        it 'does not display shared ownership question' do
          expect(response.body).not_to include(I18n.t("shared.forms.shared_ownership_form.#{application.shared_ownership}"))
          expect(response.body).not_to include('Owned with anyone else')
        end
      end

      context 'applicant owns home without mortgage' do
        let(:application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_proceeding_types,
                 :with_own_home_owned_outright,
                 :with_passported_state_machine,
                 :provider_entering_means
        end
        it 'does not display property value' do
          expect(response.body).not_to include(gds_number_to_currency(application.outstanding_mortgage_amount, unit: '£'))
          expect(response.body).not_to include('Outstanding mortgage')
        end
      end

      context 'applicant received england infected blood scheme' do
        let!(:application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_proceeding_types,
                 :with_passported_state_machine,
                 :provider_entering_means,
                 :with_populated_policy_disregards,
                 vehicle: vehicle,
                 own_vehicle: own_vehicle
        end

        it 'displays yes for england infected scheme' do
          expect(response.body).to include('England Infected Blood Support Scheme')
        end
      end

      context 'applicant is sole owner of home' do
        let(:application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_no_other_assets,
                 :with_proceeding_types,
                 :with_home_sole_owner,
                 :with_passported_state_machine,
                 :provider_entering_means
        end
        it 'does not display percentage owned' do
          expect(response.body).not_to include(number_to_percentage(application.percentage_home, precision: 2))
          expect(response.body).not_to include('Percentage')
        end
      end

      context 'applicant does not have vehicle' do
        let(:vehicle) { nil }
        let(:own_vehicle) { false }
        it 'displays first vehicle question' do
          expect(response.body).to include(I18n.t('shared.check_answers.vehicles.providers.own'))
        end

        it 'does not display other vehicle questions' do
          expect(response.body).not_to include(I18n.t('shared.check_answers_vehicles.providers.estimated_value'))
          expect(response.body).not_to include(I18n.t('shared.check_answers_vehicles.providers.payment_remaining'))
          expect(response.body).not_to include(I18n.t('shared.check_answers_vehicles.providers.purchased_on'))
          expect(response.body).not_to include(I18n.t('shared.check_answers_vehicles.providers.used_regularly'))
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:id/check_passported_answers/continue' do
    let(:application) do
      create :legal_aid_application,
             :with_everything,
             :with_passported_state_machine,
             :checking_passported_answers
    end
    let(:params) { {} }
    subject do
      patch(
        "/providers/applications/#{application.id}/check_passported_answers/continue",
        params: params
      )
    end

    context 'logged in as an authenticated provider' do
      before do
        login_as application.provider
      end

      context 'call to Check Financial Eligibility Service is successful' do
        before do
          allow(CFE::SubmissionManager).to receive(:call).with(application.id).and_return(true)
          subject
        end

        it 'redirects to Has your client received legal help for the matter?' do
          expect(response).to redirect_to flow_forward_path
        end

        it 'transitions to provider_entering_merits state' do
          expect(application.reload.provider_entering_merits?).to be true
        end

        context 'Form submitted using Save as draft button' do
          let(:params) { { draft_button: 'Save as draft' } }

          it "redirects provider to provider's applications page" do
            subject
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end

          it 'sets the application as draft' do
            expect(application.reload).to be_draft
          end
        end
      end

      context 'call to Check Financial Eligibility Service is unsuccessful' do
        before do
          allow(CFE::SubmissionManager).to receive(:call).with(application.id).and_return(false)
          subject
        end

        it 'redirects to the problem page' do
          expect(response).to redirect_to(problem_index_path)
        end
      end
    end

    context 'unauthenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH "/providers/applications/:id/check_passported_answers/reset' do
    let(:application) do
      create :legal_aid_application,
             :with_everything,
             :with_passported_state_machine,
             :checking_passported_answers,
             :with_proceeding_types
    end

    subject { patch "/providers/applications/#{application.id}/check_passported_answers/reset" }

    context 'unauthenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'logged in as an authenticated provider' do
      let(:application) do
        create :legal_aid_application,
               :with_everything,
               :with_proceeding_types,
               :with_passported_state_machine,
               :provider_entering_means
      end

      before do
        login_as application.provider
        get providers_legal_aid_application_other_assets_path(application)
        get providers_legal_aid_application_check_passported_answers_path(application)
        subject
      end

      it 'transitions to provider_assessing_merits state' do
        expect(application.reload.provider_entering_means?).to be true
      end

      it 'redirects to the previous page' do
        expect(response).to redirect_to providers_legal_aid_application_other_assets_path(application, back: true)
      end
    end
  end
end
