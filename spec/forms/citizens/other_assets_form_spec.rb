require 'rails_helper'

RSpec.describe Citizens::OtherAssetsForm do
  let(:empty_oad) { create :other_assets_declaration }
  let(:oad_with_second_home) { create :other_assets_declaration, :with_second_home }
  let(:oad_with_all_values) { create :other_assets_declaration, :with_all_values }

  context 'second home params' do
    let(:valid_second_home_params) do
      { check_box_second_home: 'yes',
        second_home_value: '859374.00',
        second_home_mortgage: '123000.00',
        second_home_percentage: '66.66' }
    end

    let(:empty_second_home_params) do
      { check_box_second_home: '',
        second_home_value: '',
        second_home_mortgage: '',
        second_home_percentage: '' }
    end

    let(:alpha_second_home_params) do
      { check_box_second_home: 'yes',
        second_home_value: 'aabb',
        second_home_mortgage: '123000.00',
        second_home_percentage: '100' }
    end

    let(:partial_second_home_params) do
      { check_box_second_home: 'yes',
        second_home_mortgage: '123000.00',
        second_home_percentage: '100' }
    end

    describe 'instantiation' do
      context 'from an existing record' do
        let(:form) { described_class.new(current_params(empty_oad)) }

        context 'with values all nil' do
          it 'returns an unchecked status for second home checkbox' do
            expect(form.second_home_checkbox_status).to be_nil
          end
        end

        context 'with second home values' do
          let(:form) { described_class.new(current_params(oad_with_second_home)) }

          it 'returns checked status for second home checkbox' do
            expect(form.second_home_checkbox_status).to eq 'checked'
          end
        end
      end

      context 'from an existing record and form params' do
        let(:form) { described_class.new(form_params(empty_oad)) }

        context 'valid form params' do
          context 'all fields present' do
            let(:submitted_params) { valid_second_home_params }

            it 'is valid' do
              expect(form).to be_valid
            end
          end

          context 'no fields present' do
            let(:submitted_params) { empty_second_home_params }

            it 'is valid' do
              expect(form).to be_valid
            end
          end
        end

        context 'invalid form params' do
          context 'non-numeric characters' do
            let(:submitted_params) { alpha_second_home_params }

            it 'is not valid' do
              expect(form).not_to be_valid
              expect(form.errors[:second_home_value]).to eq [translation_for(:second_home_value, :not_a_number)]
            end
          end
        end
      end
    end
  end

  describe 'other params' do
    let(:params) do
      { check_box_second_home: 'true',
        second_home_value: '85,9374.00',
        second_home_mortgage: '123,000.00',
        second_home_percentage: '66.66',
        check_box_timeshare_value: 'true',
        timeshare_value: '67762',
        check_box_land_value: 'true',
        land_value: '1,234.55',
        check_box_jewellery_value: 'true',
        jewellery_value: '566.0',
        check_box_vehicle_value: 'true',
        vehicle_value: '7,338.0',
        check_box_classic_car_value: 'true',
        classic_car_value: '5,000',
        check_box_money_assets_value: 'true',
        money_assets_value: '3,500',
        check_box_money_owed_value: 'true',
        money_owed_value: '0.45',
        check_box_trust_value: 'true',
        trust_value: '3,560,622.77' }
    end

    describe 'instantiation' do
      context 'from an existing record' do
        let(:form) { described_class.new(current_params(oad_with_all_values)) }

        context 'from an existing record and form params' do
          let(:form) { described_class.new(form_params(empty_oad)) }
          context 'valid form params' do
            context 'all fields present' do
              let(:submitted_params) { params }

              it 'is valid' do
                form.valid?
                expect(form).to be_valid
              end
            end

            context 'no form fields present' do
              let(:submitted_params) { {} }

              it 'is valid' do
                expect(form).to be_valid
              end
            end
          end

          context 'invalid params - each value suffixed with an x' do
            let(:submitted_params) { params.each { |_key, val| val.sub!(/$/, 'x') } }

            it 'is not valid' do
              expect(form).not_to be_valid
              expect(form.errors[:timeshare_value]).to eq [translation_for(:timeshare_value, 'not_a_number')]
              expect(form.errors[:land_value]).to eq [translation_for(:land_value, 'not_a_number')]
              expect(form.errors[:jewellery_value]).to eq [translation_for(:jewellery_value, 'not_a_number')]
              expect(form.errors[:vehicle_value]).to eq [translation_for(:vehicle_value, 'not_a_number')]
              expect(form.errors[:classic_car_value]).to eq [translation_for(:classic_car_value, 'not_a_number')]
              expect(form.errors[:money_assets_value]).to eq [translation_for(:money_assets_value, 'not_a_number')]
              expect(form.errors[:money_owed_value]).to eq [translation_for(:money_owed_value, 'not_a_number')]
              expect(form.errors[:trust_value]).to eq [translation_for(:trust_value, 'not_a_number')]
            end
          end
        end
      end
    end

    describe '#save' do
      let(:submitted_params) { params }
      let(:form) { described_class.new(form_params(empty_oad)) }

      it 'saves all the normalized values to the record' do
        expect(form.save).to be true
        oad = empty_oad.reload
        expect(oad.second_home_value).to eq 859_374.0
        expect(oad.second_home_mortgage).to eq 123_000.0
        expect(oad.second_home_percentage).to eq 66.66
        expect(oad.timeshare_value).to eq 67_762.0
        expect(oad.land_value).to eq 1_234.55
        expect(oad.jewellery_value).to eq 566.0
        expect(oad.vehicle_value).to eq 7_338.0
        expect(oad.classic_car_value).to eq 5_000.0
        expect(oad.money_assets_value).to eq 3_500.0
        expect(oad.money_owed_value).to eq 0.45
        expect(oad.trust_value).to eq 3_560_622.77
      end
    end
  end

  def current_params(oad)
    oad.attributes.symbolize_keys.except(:id, :created_at, :updated_at, :legal_aid_application_id)
  end

  def form_params(oad)
    submitted_params.merge(model: oad)
  end

  def translation_for(attr, error)
    I18n.t("activemodel.errors.models.other_assets_declaration.attributes.#{attr}.#{error}")
  end
end
