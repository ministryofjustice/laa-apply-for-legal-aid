require 'rails_helper'

RSpec.describe 'check passported answers requests', type: :request do
  include ActionView::Helpers::NumberHelper

  describe 'GET /providers/applications/:id/check_passported_answers' do
    let(:vehicle) { create :vehicle, :populated }
    let!(:application) do
      create :legal_aid_application,
             :with_everything,
             :client_details_answers_checked,
             vehicle: vehicle
    end
    let!(:restriction) { create :restriction, legal_aid_applications: [application] }

    subject { get "/providers/applications/#{application.id}/check_passported_answers" }

    context 'unauthenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'logged in as an authenticated provider' do
      before do
        login_as create(:provider)
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the correct details' do
        expect(response.body).to include(I18n.t("shared.forms.own_home_form.#{application.own_home}"))
        expect(response.body).to include(number_to_currency(application.property_value, unit: '£'))
        expect(response.body).to include(number_to_currency(application.outstanding_mortgage_amount, unit: '£'))
        expect(response.body).to include(I18n.t("shared.forms.shared_ownership_form.shared_ownership_item.#{application.shared_ownership}"))
        expect(response.body).to include(number_to_percentage(application.percentage_home, precision: 2))
        expect(response.body).to include('Property owned')
        expect(response.body).to include('Property value')
        expect(response.body).to include('Outstanding mortgage')
        expect(response.body).to include('Owned with anyone else')
        expect(response.body).to include('Percentage')
        expect(response.body).to include('Savings')
        expect(response.body).to include('assets')
        expect(response.body).to include('restrictions')
      end

      it 'displays the correct vehicles details' do
        expect(response.body).to include(number_to_currency(vehicle.estimated_value, unit: '£'))
        expect(response.body).to include(number_to_currency(vehicle.payment_remaining, unit: '£'))
        expect(response.body).to include(vehicle.purchased_on.to_s)
        expect(response.body).to include(I18n.t('shared.check_answers_vehicles.providers.heading'))
        expect(response.body).to include(I18n.t('shared.check_answers_vehicles.providers.own'))
        expect(response.body).to include(I18n.t('shared.check_answers_vehicles.providers.estimated_value'))
        expect(response.body).to include(I18n.t('shared.check_answers_vehicles.providers.payment_remaining'))
        expect(response.body).to include(I18n.t('shared.check_answers_vehicles.providers.purchased_on'))
        expect(response.body).to include(I18n.t('shared.check_answers_vehicles.providers.used_regularly'))
      end

      it 'does not display None Declared if values are entered' do
        expect(response.body).not_to include(I18n.t('.generic.none_declared'))
      end

      context 'applicant does not have any savings' do
        let(:application) { create :legal_aid_application, :with_everything, :with_no_savings, :client_details_answers_checked }
        it 'displays that no savings have been declared' do
          expect(response.body).to include(I18n.t('.generic.none_declared'))
        end
      end

      context 'applicant does not have any other assets' do
        let(:application) { create :legal_aid_application, :with_everything, :with_no_other_assets, :client_details_answers_checked }
        it 'displays that no other assets have been declared' do
          expect(response.body).to include(I18n.t('.generic.none_declared'))
        end
      end

      context 'applicant does not have any capital restrictions' do
        let(:application) { create :legal_aid_application, :with_everything, :client_details_answers_checked }
        let!(:restriction) { nil }
        it 'displays that no capital restrictions have been declared' do
          expect(response.body).to include(I18n.t('.generic.none_declared'))
        end
      end

      context 'applicant does not have any capital' do
        let(:application) { create :legal_aid_application, :provider_submitted, :with_applicant, :without_own_home, :client_details_answers_checked }
        it 'does not display capital restrictions' do
          expect(response.body).not_to include('restrictions')
        end
      end

      it 'displays the correct URLs for changing values' do
        expect(response.body).to have_change_link(:own_home, providers_legal_aid_application_own_home_path(application))
        expect(response.body).to have_change_link(:property_value, providers_legal_aid_application_property_value_path(application, anchor: 'property_value'))
        expect(response.body).to have_change_link(:shared_ownership, providers_legal_aid_application_shared_ownership_path(application))
        expect(response.body).to have_change_link(:percentage_home, providers_legal_aid_application_percentage_home_path(application, anchor: 'percentage_home'))
        expect(response.body).to include(providers_legal_aid_application_savings_and_investment_path(application))
        expect(response.body).to include(providers_legal_aid_application_other_assets_path(application))
        expect(response.body).to include(providers_legal_aid_application_restrictions_path(application))
      end

      it 'displays the correct savings details' do
        application.savings_amount.amount_attributes.each do |_, amount|
          expect(response.body).to include(number_to_currency(amount, unit: '£')), 'saving amount should be in the page'
        end
      end

      it 'displays the correct assets details' do
        application.other_assets_declaration.amount_attributes.each do |attr, amount|
          expected = if attr == 'second_home_percentage'
                       number_to_percentage(amount, precision: 2)
                     else
                       number_to_currency(amount, unit: '£')
                     end
          expect(response.body).to include(expected), 'asset amount should be in the page'
        end
      end

      it 'should change the state to "checking_passported_answers"' do
        expect(application.reload.checking_passported_answers?).to be_truthy
      end

      context 'applicant does not own home' do
        let(:application) { create :legal_aid_application, :with_everything, :without_own_home, :client_details_answers_checked }
        it 'does not display property value' do
          expect(response.body).not_to include(number_to_currency(application.property_value, unit: '£'))
          expect(response.body).not_to include('Property value')
        end

        it 'does not display shared ownership question' do
          expect(response.body).not_to include(I18n.t("shared.forms.shared_ownership_form.shared_ownership_item.#{application.shared_ownership}"))
          expect(response.body).not_to include('Owned with anyone else')
        end
      end

      context 'applicant owns home without mortgage' do
        let(:application) { create :legal_aid_application, :with_everything, :with_own_home_owned_outright, :client_details_answers_checked }
        it 'does not display property value' do
          expect(response.body).not_to include(number_to_currency(application.outstanding_mortgage_amount, unit: '£'))
          expect(response.body).not_to include('Outstanding mortgage')
        end
      end

      context 'applicant is sole owner of home' do
        let(:application) { create :legal_aid_application, :with_everything, :with_no_other_assets, :with_home_sole_owner, :client_details_answers_checked }
        it 'does not display percentage owned' do
          expect(response.body).not_to include(number_to_percentage(application.percentage_home, precision: 2))
          expect(response.body).not_to include('Percentage')
        end
      end

      context 'applicant does not have vehicle' do
        let(:vehicle) { nil }
        it 'displays first vehicle question' do
          expect(response.body).to include(I18n.t('shared.check_answers_vehicles.providers.own'))
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
        login_as create(:provider)
        subject
      end

      it 'redirects to Has your client received legal help for the matter?' do
        expect(response).to redirect_to flow_forward_path
      end

      it 'transitions to means_completed state' do
        expect(application.reload.means_completed?).to be true
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

    context 'unauthenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH "/providers/applications/:id/check_passported_answers/reset' do
    let(:application) do
      create :legal_aid_application,
             :with_everything,
             :checking_passported_answers
    end

    subject { patch "/providers/applications/#{application.id}/check_passported_answers/reset" }

    context 'unauthenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'logged in as an authenticated provider' do
      let(:application) { create :legal_aid_application, :with_everything, :client_details_answers_checked }

      before do
        login_as create(:provider)
        get providers_legal_aid_application_other_assets_path(application)
        get providers_legal_aid_application_check_passported_answers_path(application)
        subject
      end

      it 'transitions to means_completed state' do
        expect(application.reload.client_details_answers_checked?).to be true
      end

      it 'redirects to the previous page' do
        expect(response).to redirect_to providers_legal_aid_application_other_assets_path(application, back: true)
      end
    end
  end
end
