require 'rails_helper'

RSpec.describe SavingsAmounts::SavingsAmountsForm, type: :form do
  let(:savings_amount) { create :savings_amount }
  let(:attributes) { described_class::ATTRIBUTES }
  let(:check_box_attributes) { described_class::CHECK_BOXES_ATTRIBUTES }
  let(:check_box_params) { {} }
  let(:amount_params) { {} }
  let(:params) { amount_params.merge(check_box_params) }
  let(:form_params) { params.merge(model: savings_amount) }

  subject { described_class.new(form_params) }

  describe '#save' do
    context 'check boxes are checked' do
      let(:check_box_params) { check_box_attributes.index_with { |_attr| 'true' } }

      context 'amounts are valid' do
        let(:amount_params) { attributes.index_with { |_attr| rand(1...1_000_000.0).round(2).to_s } }

        it 'updates all amounts' do
          subject.save
          savings_amount.reload

          attributes.each do |attr|
            val = savings_amount.__send__(attr)
            expected_val = params[attr]
            expect(val.to_s).to eq(expected_val), "Attr #{attr}: expected #{expected_val}, got #{val}"
          end
        end

        it 'returns true' do
          expect(subject.save).to eq(true)
        end

        it 'has no errors' do
          expect(subject.errors).to be_empty
        end
      end

      shared_examples_for 'it has an error' do
        let(:attribute_map) do
          {
            cash: /total.*cash savings/i,
            other_person_account: /other people’s accounts/,
            national_savings: /certificates and bonds/,
            plc_shares: /shares/,
            peps_unit_trusts_capital_bonds_gov_stocks: /total.*of other investments/i,
            life_assurance_endowment_policy: /total.*of life assurance policies/i
          }
        end
        it 'returns false' do
          expect(subject.save).to eq(false)
        end

        it 'generates errors' do
          subject.save
          attributes.each do |attr|
            error_message = subject.errors[attr].first
            expect(error_message).to match(expected_error)
            expect(error_message).to match(attribute_map[attr.to_sym])
          end
        end

        it 'does not update the model' do
          expect { subject.save }.not_to change { savings_amount.reload.updated_at }
        end
      end

      context 'amounts are empty' do
        let(:amount_params) { attributes.index_with { |_attr| '' } }
        let(:expected_error) { /enter the( estimated)? total/i }

        it_behaves_like 'it has an error'
      end

      context 'amounts are not numbers' do
        let(:amount_params) { attributes.index_with { |_attr| Faker::Lorem.word } }
        let(:expected_error) { /must be an amount of money, like 60,000/ }

        it_behaves_like 'it has an error'
      end

      context 'amounts are less than 0' do
        context 'that are not bank account attributes' do
          let(:attribute_map) do
            {
              cash: /total.*cash savings/i,
              other_person_account: /other people’s accounts/,
              national_savings: /certificates and bonds/,
              plc_shares: /shares/,
              peps_unit_trusts_capital_bonds_gov_stocks: /total.*of other investments/i,
              life_assurance_endowment_policy: /total.*of life assurance policies/i
            }
          end
          let(:amount_params) { attributes.index_with { |_attr| Faker::Number.negative.to_s } }
          let(:expected_error) { /must be 0 or more/ }

          it 'returns false' do
            expect(subject.save).to eq(false)
          end

          it 'generates errors' do
            subject.save
            attributes.each do |attr|
              error_message = subject.errors[attr].first
              expect(error_message).to match(expected_error)
              expect(error_message).to match(attribute_map[attr.to_sym])
            end
          end

          it 'does not update the model' do
            expect { subject.save }.not_to change { savings_amount.reload.updated_at }
          end
        end
      end

      context 'amounts have a £ symbol' do
        let(:amount_params) { attributes.index_with { |_attr| "£#{rand(1...1_000_000.0).round(2)}" } }

        it 'strips the values of £ symbols' do
          subject.save
          savings_amount.reload

          attributes.each do |attr|
            val = savings_amount.__send__(attr).to_s
            expected_val = params[attr]

            expect("£#{val}").to eq(expected_val), "Attr #{attr}: expected #{expected_val}, got £#{val}"
          end
        end
      end
    end

    context 'some check boxes are unchecked' do
      let(:check_box_params) do
        boxes = check_box_attributes.index_with { |_attr| '' }
        boxes[:check_box_cash] = 'true'
        boxes
      end

      context 'amounts are invalid' do
        let(:amount_params) { attributes.index_with { |_attr| rand(1...1_000_000.0).round(2).to_s } }

        it 'empties amounts if checkbox is unchecked' do
          attributes_except_cash = attributes - [:cash]
          subject.save
          savings_amount.reload
          attributes_except_cash.each do |attr|
            val = savings_amount.__send__(attr)
            expect(val).to eq(nil), "Attr #{attr}: expected nil, got #{val}"
          end
        end

        it 'does not empty amount if a checkbox is checked' do
          subject.save
          expect(savings_amount.reload.cash).not_to eq(nil)
        end

        it 'returns true' do
          expect(subject.save).to eq(true)
        end

        it 'has no errors' do
          expect(subject.errors).to be_empty
        end
      end

      context 'amounts are not valid' do
        let(:amount_params) { attributes.index_with { |_attr| Faker::Lorem.word } }

        it 'it empties amounts' do
          subject.save
          savings_amount.reload
          attributes.each do |attr|
            val = savings_amount.__send__(attr)
            expect(val).to eq(nil), "Attr #{attr}: expected nil, got #{val}"
          end
        end

        it 'returns false' do
          expect(subject.save).to eq(false)
          expect(subject.errors).not_to be_empty
        end
      end

      context 'if none of the check boxes are checked' do
        let(:check_box_params) do
          boxes = check_box_attributes.index_with { |_attr| '' }
          boxes[:none_selected] = ''
          boxes
        end
        let(:journey) { 'citizens' }

        it 'returns true' do
          expect(subject.save).to eq(false)
          expect(subject.errors[:check_box_cash]).to include(I18n.t("activemodel.errors.models.savings_amount.attributes.base.#{journey}.none_selected"))
        end
      end

      context 'none of these check box is checked' do
        let(:check_box_params) do
          boxes = check_box_attributes.index_with { |_attr| '' }
          boxes[:none_selected] = 'true'
          boxes
        end

        it 'returns true' do
          expect(subject.save).to eq(true)
          expect(subject.errors).to be_empty
        end
      end
    end
  end
end
