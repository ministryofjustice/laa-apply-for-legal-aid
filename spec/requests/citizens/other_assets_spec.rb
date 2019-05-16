require 'rails_helper'

RSpec.describe 'citizen other assets requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:application_id) { application.id }
  let(:oad) { application.other_assets_declaration }
  let(:secure_id) { application.generate_secure_id }

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
          check_box_timeshare_property_value: 'true',
          timeshare_property_value: '234,567.89',
          check_box_land_value: 'true',
          land_value: '34,567.89',
          check_box_valuable_items_value: 'true',
          valuable_items_value: '456,789.01',
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

    let(:empty_params) do
      {
        other_assets_declaration: {
          check_box_second_home: '',
          second_home_value: '',
          second_home_mortgage: '',
          second_home_percentage: '',
          check_box_timeshare_property_value: '',
          timeshare_property_value: '',
          check_box_land_value: '',
          land_value: '',
          check_box_valuable_items_value: '',
          valuable_items_value: '',
          check_box_money_assets_value: '',
          money_assets_value: '',
          check_box_money_owed_value: '',
          money_owed_value: '',
          check_box_trust_value: '',
          trust_value: ''
        },
        none_selected: none_selected
      }
    end

    let(:none_selected) { false }

    context 'valid params' do
      it 'updates the record' do
        oad.reload
        expect(oad.second_home_value).to eq 875_123
        expect(oad.second_home_mortgage).to eq 125_345.67
        expect(oad.second_home_percentage).to eq 64.44
        expect(oad.timeshare_property_value).to eq 234_567.89
        expect(oad.land_value).to eq 34_567.89
        expect(oad.valuable_items_value).to eq 456_789.01
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

        it 'redirects to check answers page' do
          expect(response).to redirect_to(citizens_check_answers_path)
        end

        context 'and none of these checkbox is not selected' do
          let(:none_selected) { false }
          before { patch citizens_other_assets_path, params: empty_params }
          it 'the response includes the error message' do
            expect(response.body).to include(I18n.t('activemodel.errors.models.other_assets_declaration.attributes.base.citizen_none_selected'))
          end
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

      it 'does not create the record' do
        expect(oad).to be_nil
      end

      it 'the response includes the error message' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.other_assets_declaration.attributes.second_home_value.not_a_number'))
      end

      it 'renders the show page' do
        expect(response.body).to include I18n.t('citizens.other_assets.show.h1-heading')
      end
    end

    context 'while checking answers' do
      let(:application) { create :legal_aid_application, :checking_client_details_answers, :with_applicant }

      it 'redirects to the "restrictions" page' do
        expect(response).to redirect_to(citizens_restrictions_path)
      end
    end
  end
end
