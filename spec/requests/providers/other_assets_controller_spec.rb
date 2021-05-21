require 'rails_helper'

RSpec.describe 'provider other assets requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:oad) { application.create_other_assets_declaration! }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe 'GET providers/applications/:id/other_assets' do
    subject { get providers_legal_aid_application_other_assets_path(application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the show page' do
        expect(response.body).to include I18n.t('providers.other_assets.show.h1-heading')
      end
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
          check_box_timeshare_property_value: 'true',
          timeshare_property_value: '234,567.89',
          check_box_land_value: 'true',
          land_value: '34,567.89',
          check_box_valuable_items_value: 'true',
          valuable_items_value: '456,789.01',
          check_box_inherited_assets_value: 'true',
          inherited_assets_value: '89,012.34',
          check_box_money_owed_value: 'true',
          money_owed_value: '90,123.45',
          check_box_trust_value: 'true',
          trust_value: '1,234.56',
          none_selected: ''
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
          check_box_timeshare_property_value: '',
          timeshare_property_value: '',
          check_box_land_value: '',
          land_value: '',
          check_box_valuable_items_value: '',
          valuable_items_value: '',
          check_box_inherited_assets_value: '',
          inherited_assets_value: '',
          check_box_money_owed_value: '',
          money_owed_value: '',
          check_box_trust_value: '',
          trust_value: '',
          none_selected: none_selected
        }
      }
    end

    let(:none_selected) { '' }

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      context 'Submitted with Continue button' do
        let(:submit_button) do
          { continue_button: 'Continue' }
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
            expect(oad.timeshare_property_value).to eq 234_567.89
            expect(oad.land_value).to eq 34_567.89
            expect(oad.valuable_items_value).to eq 456_789.01
            expect(oad.inherited_assets_value).to eq 89_012.34
            expect(oad.money_owed_value).to eq 90_123.45
            expect(oad.trust_value).to eq 1_234.56
          end

          context 'has other_assets' do
            let(:oad) { create :other_assets_declaration, land_value: rand(1...1_000_000.0).round(2) }
            let(:application) { oad.legal_aid_application }

            before do
              patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: params.merge(submit_button)
            end

            it 'redirects to capital restrictions' do
              expect(application.reload.other_assets?).to be true
              expect(application.own_home?).to be false
              expect(application.savings_amount?).to be false
              expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(oad.legal_aid_application))
            end
          end

          context 'has savings and investments' do
            let(:oad) { create :other_assets_declaration }
            let(:application) { oad.legal_aid_application }
            let(:none_selected) { 'true' }

            before do
              application.create_savings_amount!
              application.savings_amount.cash = rand(1...1_000_000.0).round(2)
              application.savings_amount.save!
              patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
            end

            it 'redirects to capital restrictions' do
              expect(application.reload.other_assets?).to be false
              expect(application.own_home?).to be false
              expect(application.savings_amount?).to be true
              expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(oad.legal_aid_application))
            end
          end

          context 'has own home' do
            let(:application) { create :legal_aid_application, :with_own_home_mortgaged }
            let(:oad) { create :other_assets_declaration, legal_aid_application: application }
            let(:none_selected) { 'true' }

            before do
              patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
            end

            it 'redirects to capital restrictions' do
              expect(application.reload.other_assets?).to be false
              expect(application.own_home?).to be true
              expect(application.savings_amount?).to be false
              expect(response).to redirect_to(providers_legal_aid_application_restrictions_path(oad.legal_aid_application))
            end
          end

          context 'checking answers' do
            let(:application) { create :legal_aid_application, :without_own_home, :checking_passported_answers }
            let(:oad) { create :other_assets_declaration, legal_aid_application: application }
            let(:none_selected) { 'true' }

            before do
              patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
            end

            it 'redirects to checking answers' do
              expect(application.reload.other_assets?).to be false
              expect(application.own_home?).to be false
              expect(application.savings_amount?).to be false
              expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(oad.legal_aid_application))
            end

            context "provider checking citizen's answers" do
              let(:application) { create :legal_aid_application, :without_own_home, :with_non_passported_state_machine, :checking_non_passported_means }

              it 'redirects to means summary page' do
                expect(response).to redirect_to(providers_legal_aid_application_means_summary_path(application))
              end
            end
          end

          context 'has nothing' do
            let(:application) { create :legal_aid_application, :with_positive_benefit_check_result }
            let(:oad) { create :other_assets_declaration, legal_aid_application: application }
            let(:none_selected) { 'true' }
            let(:policy_disregards) { true }
            before do
              allow_any_instance_of(LegalAidApplication).to receive(:capture_policy_disregards?).and_return(policy_disregards)
              patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: empty_params.merge(submit_button)
            end

            context 'with none of these checkbox selected' do
              it 'redirects to policy disregards' do
                expect(application.reload.other_assets?).to be false
                expect(application.own_home?).to be false
                expect(application.savings_amount?).to be false
                expect(response).to redirect_to(providers_legal_aid_application_policy_disregards_path(application))
              end

              context 'when the calculation date is prior to the policy disregards date' do
                let(:application) do
                  create :legal_aid_application,
                         :with_positive_benefit_check_result,
                         :with_proceeding_types,
                         :with_delegated_functions,
                         delegated_functions_date: Date.new(2021, 1, 5)
                end
                let(:policy_disregards) { false }

                it 'redirects to policy disregards' do
                  expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(application))
                end
              end
            end

            context 'and none of these checkbox is not selected' do
              let(:none_selected) { '' }

              it 'the response includes the error message' do
                expect(response.body).to include(I18n.t('activemodel.errors.models.other_assets_declaration.attributes.base.providers.none_selected'))
              end
            end
          end
        end

        context 'none of these checkbox is selected' do
          let(:params) do
            {
              other_assets_declaration: { none_selected: 'true' }
            }
          end

          it 'sets none_selected to true' do
            expect(oad.reload.none_selected).to eq(true)
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
            expect(oad.positive?).to be false
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
        let(:submit_button) { { draft_button: 'Save as draft' } }

        before do
          patch providers_legal_aid_application_other_assets_path(oad.legal_aid_application), params: params.merge(submit_button)
        end

        context 'valid params' do
          it 'updates the record' do
            oad.reload
            expect(oad.second_home_value).to eq 875_123
            expect(oad.second_home_mortgage).to eq 125_345.67
            expect(oad.second_home_percentage).to eq 64.44
            expect(oad.timeshare_property_value).to eq 234_567.89
            expect(oad.land_value).to eq 34_567.89
            expect(oad.valuable_items_value).to eq 456_789.01
            expect(oad.inherited_assets_value).to eq 89_012.34
            expect(oad.money_owed_value).to eq 90_123.45
            expect(oad.trust_value).to eq 1_234.56
          end

          it "redirects provider to provider's applications page" do
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end

          context 'has other_assets' do
            let(:oad) { create :other_assets_declaration, land_value: rand(1...1_000_000.0).round(2) }
            let(:application) { oad.legal_aid_application }

            it 'redirects to provider applications page' do
              expect(application.reload.other_assets?).to be true
              expect(application.own_home?).to be false
              expect(application.savings_amount?).to be false
              expect(response).to redirect_to providers_legal_aid_applications_path
            end
          end

          context 'has savings and investments' do
            let(:oad) { create :other_assets_declaration }
            let(:application) { oad.legal_aid_application }

            before do
              application.create_savings_amount!
              application.savings_amount.cash = rand(1...1_000_000.0).round(2)
              application.savings_amount.save!
              patch providers_legal_aid_application_other_assets_path(application), params: empty_params.merge(submit_button)
            end

            it 'redirects to provider applications page' do
              expect(application.reload.other_assets?).to be false
              expect(application.own_home?).to be false
              expect(application.savings_amount?).to be true
              expect(response).to redirect_to providers_legal_aid_applications_path
            end
          end

          context 'has own home' do
            let(:application) { create :legal_aid_application, :with_own_home_mortgaged }
            let(:oad) { create :other_assets_declaration, legal_aid_application: application }
            let(:params) { empty_params }
            let(:none_selected) { 'true' }

            it 'redirects to provider applications page' do
              expect(application.reload.other_assets?).to be false
              expect(application.own_home?).to be true
              expect(application.savings_amount?).to be false
              expect(response).to redirect_to providers_legal_aid_applications_path
            end
          end

          context 'has nothing' do
            let(:oad) { create :other_assets_declaration }
            let(:application) { oad.legal_aid_application }
            let(:params) { empty_params }
            let(:none_selected) { 'true' }

            it 'redirects to provider applications page' do
              expect(application.reload.other_assets?).to be false
              expect(application.own_home?).to be false
              expect(application.savings_amount?).to be false
              expect(response).to redirect_to providers_legal_aid_applications_path
            end
          end
        end

        context 'invalid params' do
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
            expect(oad.positive?).to be false
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
end
