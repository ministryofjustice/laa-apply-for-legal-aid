require 'rails_helper'

RSpec.describe 'check passported answers requests', type: :request do
  include ActionView::Helpers::NumberHelper

  let(:application) do
    create :legal_aid_application,
           :with_everything,
           :answers_checked
  end

  describe 'GET /providers/applications/:id/check_passported_answers' do
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
        expect(response.body).to include(I18n.translate("shared.forms.own_home_form.#{application.own_home}"))
        expect(response.body).to include(number_to_currency(application.property_value, unit: '£'))
        expect(response.body).to include(number_to_currency(application.outstanding_mortgage_amount, unit: '£'))
        expect(response.body).to include(I18n.translate("shared.forms.shared_ownership_form.shared_ownership_item.#{application.shared_ownership}"))
        expect(response.body).to include(number_to_percentage(application.percentage_home, precision: 2))
        expect(response.body).to include('Own the home')
        expect(response.body).to include('Property value')
        expect(response.body).to include('Outstanding mortgage')
        expect(response.body).to include('Owned with anyone else')
        expect(response.body).to include('Percentage')
        expect(response.body).to include('Savings')
        expect(response.body).to include('assets')
        expect(response.body).to include('restrictions')
      end

      it 'displays the correct URLs for changing values' do
        expect(response.body).to have_change_link(:own_home, providers_legal_aid_application_own_home_path(application))
        expect(response.body).to have_change_link(:property_value, providers_legal_aid_application_property_value_path(application, anchor: 'property_value'))
        expect(response.body).to have_change_link(:shared_ownership, providers_legal_aid_application_shared_ownership_path(application))
        expect(response.body).to have_change_link(:percentage_home, providers_legal_aid_application_percentage_home_path(application, anchor: 'percentage_home'))
        expect(response.body).to have_change_link(:savings_and_investments, providers_legal_aid_application_savings_and_investment_path(application))
        expect(response.body).to have_change_link(:other_assets, providers_legal_aid_application_other_assets_path(application))
        expect(response.body).to have_change_link(:restrictions, providers_legal_aid_application_restrictions_path(application))
      end

      it 'displays the correct savings details' do
        application.savings_amount.amount_attributes.each do |_, amount|
          expect(response.body).to include(number_to_currency(amount, unit: '£')), 'saving amount should be in the page'
        end
      end

      it 'displays the correct assets details' do
        application.other_assets_declaration.amount_attributes.each do |_, amount|
          expect(response.body).to include(number_to_currency(amount, unit: '£')), 'asset amount should be in the page'
        end
      end

      it 'should change the state to "checking_passported_answers"' do
        expect(application.reload.checking_passported_answers?).to be_truthy
      end

      context 'applicant does not own home' do
        let(:application) { create :legal_aid_application, :with_everything, :without_own_home, :answers_checked }
        it 'does not display property value' do
          expect(response.body).not_to include(number_to_currency(application.property_value, unit: '£'))
          expect(response.body).not_to include('Property value')
        end

        it 'does not display shared ownership question' do
          expect(response.body).not_to include(I18n.translate("shared.forms.shared_ownership_form.shared_ownership_item.#{application.shared_ownership}"))
          expect(response.body).not_to include('Owned with anyone else')
        end
      end

      context 'applicant owns home without mortgage' do
        let(:application) { create :legal_aid_application, :with_everything, :with_own_home_owned_outright, :answers_checked }
        it 'does not display property value' do
          expect(response.body).not_to include(number_to_currency(application.outstanding_mortgage_amount, unit: '£'))
          expect(response.body).not_to include('Outstanding mortgage')
        end
      end

      context 'applicant is sole owner of home' do
        let(:application) { create :legal_aid_application, :with_everything, :with_home_sole_owner, :answers_checked }
        it 'does not display percentage owned' do
          expect(response.body).not_to include(number_to_percentage(application.percentage_home, precision: 2))
          expect(response.body).not_to include('Percentage')
        end
      end

      context 'applicant does not have any capital' do
        let(:application) { create :legal_aid_application, :provider_submitted, :with_applicant, :without_own_home, :answers_checked }
        it 'does not display capital restrictions' do
          expect(response.body).not_to include('restrictions')
        end
      end
    end
  end
end
