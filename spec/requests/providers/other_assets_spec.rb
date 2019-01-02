require 'rails_helper'

RSpec.describe 'provider other assets requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:oad) { application.create_other_assets_declaration! }
  let(:application_id) { application.id }

  before { get providers_legal_aid_application_other_assets_path(application) }

  describe 'GET providers/applications/:id/other_assets' do
    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the show page' do
      expect(response.body).to include I18n.t('providers.other_assets.show.h1-heading')
    end
  end

  describe 'PATCH providers/applications/:id/other_assets' do
    let(:params) do
      {
        other_assets_declaration: {
          check_box_second_home: 'true',
          second_home_value: '875123',
          second_home_mortgage: '125,345.67',
          second_home_percentage: '64.440',
          check_box_timeshare_value: 'true',
          timeshare_value: '234,567.89',
          check_box_land_value: 'true',
          land_value: '34,567.89',
          check_box_jewellery_value: 'true',
          jewellery_value: '456,789.01',
          check_box_vehicle_value: 'true',
          vehicle_value: '56,789.01',
          check_box_classic_car_value: 'true',
          classic_car_value: '67,890.12',
          check_box_money_assets_value: 'true',
          money_assets_value: '89,012.34',
          check_box_money_owed_value: 'true',
          money_owed_value: '90,123.45',
          check_box_trust_value: 'true',
          trust_value: '1,234.56'
        }
      }
    end

    let(:empty_params) do
      {
        other_assets_declaration: {
          check_box_second_home: '',
          second_home_value: '',
          second_home_mortgage: '',
          second_home_percentage: '',
          check_box_timeshare_value: '',
          timeshare_value: '',
          check_box_land_value: '',
          land_value: '',
          check_box_jewellery_value: '',
          jewellery_value: '',
          check_box_vehicle_value: '',
          vehicle_value: '',
          check_box_classic_car_value: '',
          classic_car_value: '',
          check_box_money_assets_value: '',
          money_assets_value: '',
          check_box_money_owed_value: '',
          money_owed_value: '',
          check_box_trust_value: '',
          trust_value: ''
        }
      }
    end

    context 'Submitted with Continue button' do
      let(:submit_button) do
        { 'continue-button' => 'Continue' }
      end

      before do
        patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: params.merge(submit_button)
      end

      context 'valid params' do
        it 'updates the record' do
          oad.reload
          expect(oad.second_home_value).to eq 875_123
          expect(oad.second_home_mortgage).to eq 125_345.67
          expect(oad.second_home_percentage).to eq 64.44
          expect(oad.timeshare_value).to eq 234_567.89
          expect(oad.land_value).to eq 34_567.89
          expect(oad.jewellery_value).to eq 456_789.01
          expect(oad.vehicle_value).to eq 56_789.01
          expect(oad.classic_car_value).to eq 67_890.12
          expect(oad.money_assets_value).to eq 89_012.34
          expect(oad.money_owed_value).to eq 90_123.45
          expect(oad.trust_value).to eq 1_234.56
        end

        context 'has other_assets' do
          let(:oad) { create :other_assets_declaration, land_value: Faker::Number.decimal.to_d }
          let(:application) { oad.legal_aid_application }

          before do
            patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: params.merge(submit_button)
          end

          it 'redirects to capital restrictions' do
            expect(application.reload.other_assets?).to be true
            expect(application.own_home?).to be false
            expect(application.savings_or_investments?).to be false
            expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(oad.legal_aid_application))
          end
        end

        context 'has savings and investments' do
          let(:oad) { create :other_assets_declaration }
          let(:application) { oad.legal_aid_application }

          before do
            application.create_savings_amount!
            application.savings_amount.cash = Faker::Number.decimal.to_d
            application.savings_amount.save!
            patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
          end

          it 'redirects to capital restrictions' do
            expect(application.reload.other_assets?).to be false
            expect(application.own_home?).to be false
            expect(application.savings_or_investments?).to be true
            expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(oad.legal_aid_application))
          end
        end

        context 'has own home' do
          let(:application) { create :legal_aid_application, :with_own_home_mortgaged }
          let(:oad) { create :other_assets_declaration, legal_aid_application: application }

          before do
            patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
          end

          it 'redirects to capital restrictions' do
            expect(application.reload.other_assets?).to be false
            expect(application.own_home?).to be true
            expect(application.savings_or_investments?).to be false
            expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(oad.legal_aid_application))
          end
        end

        context 'has nothing' do
          let(:oad) { create :other_assets_declaration }
          let(:application) { oad.legal_aid_application }

          before do
            patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
          end

          it 'redirects to check provider answers' do
            expect(application.reload.other_assets?).to be false
            expect(application.own_home?).to be false
            expect(application.savings_or_investments?).to be false
            expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(application))
          end
        end
      end

      context 'invalid params - nothing specified' do
        let(:params) do
          {
            other_assets_declaration: {
              check_box_second_home: 'true',
              second_home_value: 'aaa'
            }
          }
        end

        it 'returns http_success' do
          expect(response).to have_http_status(:ok)
        end

        it 'does not update the record' do
          expect(oad.any_value?).to be false
        end

        it 'the response includes the error message' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.other_assets_declaration.attributes.second_home_value.not_a_number'))
        end

        it 'renders the show page' do
          expect(response.body).to include I18n.t('providers.other_assets.show.h1-heading')
        end
      end
    end

    context 'Submitted with Save as draft button' do
      let(:submit_button) do
        {
          'draft-button' => 'Save as draft'
        }
      end

      before do
        patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: params.merge(submit_button)
      end

      context 'valid params' do
        it 'updates the record' do
          oad.reload
          expect(oad.second_home_value).to eq 875_123
          expect(oad.second_home_mortgage).to eq 125_345.67
          expect(oad.second_home_percentage).to eq 64.44
          expect(oad.timeshare_value).to eq 234_567.89
          expect(oad.land_value).to eq 34_567.89
          expect(oad.jewellery_value).to eq 456_789.01
          expect(oad.vehicle_value).to eq 56_789.01
          expect(oad.classic_car_value).to eq 67_890.12
          expect(oad.money_assets_value).to eq 89_012.34
          expect(oad.money_owed_value).to eq 90_123.45
          expect(oad.trust_value).to eq 1_234.56
        end

        context 'has other_assets' do
          let(:oad) { create :other_assets_declaration, land_value: Faker::Number.decimal.to_d }
          let(:application) { oad.legal_aid_application }

          before do
            patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: params.merge(submit_button)
          end

          it 'redirects to provider applications page' do
            expect(application.reload.other_assets?).to be true
            expect(application.own_home?).to be false
            expect(application.savings_or_investments?).to be false
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end

        context 'has savings and investments' do
          let(:oad) { create :other_assets_declaration }
          let(:application) { oad.legal_aid_application }

          before do
            application.create_savings_amount!
            application.savings_amount.cash = Faker::Number.decimal.to_d
            application.savings_amount.save!
            patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
          end

          it 'redirects to provider applications page' do
            expect(application.reload.other_assets?).to be false
            expect(application.own_home?).to be false
            expect(application.savings_or_investments?).to be true
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end

        context 'has own home' do
          let(:application) { create :legal_aid_application, :with_own_home_mortgaged }
          let(:oad) { create :other_assets_declaration, legal_aid_application: application }

          before do
            patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
          end

          it 'redirects to provider applications page' do
            expect(application.reload.other_assets?).to be false
            expect(application.own_home?).to be true
            expect(application.savings_or_investments?).to be false
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end

        context 'has nothing' do
          let(:oad) { create :other_assets_declaration }
          let(:application) { oad.legal_aid_application }

          before do
            patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
          end

          it 'redirects to provider applications page' do
            expect(application.reload.other_assets?).to be false
            expect(application.own_home?).to be false
            expect(application.savings_or_investments?).to be false
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end

      context 'invalid params - nothing specified' do
        let(:params) do
          {
            other_assets_declaration: {
              check_box_second_home: 'true',
              second_home_value: 'aaa'
            }
          }
        end

        it 'returns http_success' do
          expect(response).to have_http_status(:ok)
        end

        it 'does not update the record' do
          expect(oad.any_value?).to be false
        end

        it 'the response includes the error message' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.other_assets_declaration.attributes.second_home_value.not_a_number'))
        end

        it 'renders the show page' do
          expect(response.body).to include I18n.t('providers.other_assets.show.h1-heading')
        end
      end
    end
  end
end
