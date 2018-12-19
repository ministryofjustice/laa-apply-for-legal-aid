require 'rails_helper'

RSpec.describe 'citizen other assets requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:oad) { application.create_other_assets_declaration! }
  let(:application_id) { application.id }
  let(:secure_id) { oad.legal_aid_application.generate_secure_id }

  before { get citizens_legal_aid_application_path(secure_id) }

  describe 'GET citizens/other_assets' do
    it 'returns http success' do
      get citizens_other_assets_path
      expect(response).to have_http_status(:ok)
    end

    it 'displays the show page' do
      get citizens_other_assets_path
      expect(response.body).to include I18n.t('citizens.other_assets.show.h1-heading')
    end
  end

  describe 'PATCH citizens/other_assets' do
    before { patch citizens_other_assets_path, params: params }

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
        },
        commit: 'Continue'
      }
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

      it 'redirects to the capital restrictions page' do
        expect(response).to redirect_to(citizens_restrictions_path)
      end

      context 'no asset' do
        let(:params) do
          {
            other_assets_declaration: {
              check_box_second_home: 'true',
              second_home_value: '0',
              second_home_mortgage: '0',
              second_home_percentage: '0'
            }
          }
        end

        # TODO: remove when "check_answers" page is implemented
        it 'redirects to the capital restrictions page' do
          expect(response.body).to eq('citizens_check_answers_path')
        end

        # TODO: enable when "check_answers" page is implemented
        xit 'redirects to the capital restrictions page' do
          expect(response).to redirect_to(citizens_check_answers_path)
        end
      end
    end

    context 'invalid params - nothing specified' do
      let(:params) do
        {
          other_assets_declaration: {
            check_box_second_home: 'true',
            second_home_value: 'aaa'
          },
          commit: 'Continue'
        }
      end

      it 'returns http_success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not update the record' do
        expect(oad.second_home_value).to be_nil
        expect(oad.second_home_mortgage).to be_nil
        expect(oad.second_home_percentage).to be_nil
        expect(oad.timeshare_value).to be_nil
        expect(oad.land_value).to be_nil
        expect(oad.jewellery_value).to be_nil
        expect(oad.vehicle_value).to be_nil
        expect(oad.classic_car_value).to be_nil
        expect(oad.money_assets_value).to be_nil
        expect(oad.money_owed_value).to be_nil
        expect(oad.trust_value).to be_nil
      end

      it 'the response includes the error message' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.other_assets_declaration.attributes.second_home_value.not_a_number'))
      end

      it 'renders the show page' do
        expect(response.body).to include I18n.t('citizens.other_assets.show.h1-heading')
      end
    end
  end
end
