require "rails_helper"

RSpec.describe SavingsAmounts::SavingsAmountsForm, type: :form do
  subject(:described_form) { described_class.new(form_params) }

  let(:savings_amount) { create(:savings_amount) }
  let(:attributes) { described_class::ATTRIBUTES }
  let(:check_box_attributes) { described_class::CHECK_BOXES_ATTRIBUTES }
  let(:check_box_params) { {} }
  let(:amount_params) { {} }
  let(:params) { amount_params.merge(check_box_params) }
  let(:form_params) { params.merge(model: savings_amount) }

  describe "#save" do
    context "when check boxes are checked" do
      let(:check_box_params) { check_box_attributes.index_with { |attr| "true" unless attr == :none_selected } }

      context "and the amounts are valid" do
        let(:amount_params) { attributes.index_with { |_attr| rand(1...1_000_000.0).round(2).to_s } }

        it "updates all amounts" do
          described_form.save!
          savings_amount.reload

          attributes.each do |attr|
            val = savings_amount.__send__(attr)
            expected_val = params[attr]
            expect(val.to_s).to eq(expected_val), "Attr #{attr}: expected #{expected_val}, got #{val}"
          end
        end

        it "returns true" do
          expect(described_form.save).to be(true)
        end

        it "has no errors" do
          expect(described_form.errors).to be_empty
        end
      end

      context "when 'none of the above' and another checkbox are selected" do
        let(:check_box_params) { { check_box_life_assurance_endowment_policy: "true", life_assurance_endowment_policy: "100", none_selected: "true" } }

        it "errors" do
          expect(described_form.save).to be false
        end
      end

      shared_examples_for "it has an error" do
        let(:attribute_map) do
          {
            cash: /of money that's/i,
            other_person_account: /other people's.*account/,
            national_savings: /certificates and.*bonds/i,
            plc_shares: /shares/,
            peps_unit_trusts_capital_bonds_gov_stocks: /total.* of other investments/i,
            life_assurance_endowment_policy: /(total|value).*of life assurance.*policies/i,
          }
        end
        it "returns false" do
          expect(described_form.save).to be(false)
        end

        it "generates errors" do
          described_form.save!
          attributes.each do |attr|
            error_message = described_form.errors[attr].first
            expect(error_message).to match(expected_error)
            expect(error_message).to match(attribute_map[attr.to_sym])
          end
        end

        it "does not update the model" do
          expect { described_form.save }.not_to change { savings_amount.reload.updated_at }
        end
      end

      context "when the amounts are empty" do
        let(:amount_params) { attributes.index_with { |_attr| "" } }
        let(:expected_error) { /^Enter the/i }

        it_behaves_like "it has an error"
      end

      context "when the amounts are not numbers" do
        let(:amount_params) { attributes.index_with { |_attr| Faker::Lorem.word } }
        let(:expected_error) { /amount of money/ }

        it_behaves_like "it has an error"
      end

      context "when the amounts are less than 0" do
        context "and are not bank account attributes" do
          let(:attribute_map) do
            {
              cash: /of money that's/i,
              other_person_account: /other people's accounts/,
              national_savings: /certificates and.*bonds/i,
              plc_shares: /shares/,
              peps_unit_trusts_capital_bonds_gov_stocks: /total.* of other investments/i,
              life_assurance_endowment_policy: /(total|value).*of life assurance.*policies/i,
            }
          end
          let(:amount_params) { attributes.index_with { |_attr| Faker::Number.negative.to_s } }
          let(:expected_error) { /must be 0 or more/ }

          it "returns false" do
            expect(described_form.save).to be(false)
          end

          it "generates errors" do
            described_form.save!
            attributes.each do |attr|
              error_message = described_form.errors[attr].first
              expect(error_message).to match(expected_error)
              expect(error_message).to match(attribute_map[attr.to_sym])
            end
          end

          it "does not update the model" do
            expect { described_form.save }.not_to change { savings_amount.reload.updated_at }
          end
        end
      end

      context "when the amounts have a £ symbol" do
        let(:amount_params) { attributes.index_with { |_attr| "£#{rand(1...1_000_000.0).round(2)}" } }

        it "strips the values of £ symbols" do
          described_form.save!
          savings_amount.reload

          attributes.each do |attr|
            val = savings_amount.__send__(attr).to_s
            expected_val = params[attr]

            expect("£#{val}").to eq(expected_val), "Attr #{attr}: expected #{expected_val}, got £#{val}"
          end
        end
      end
    end

    context "when some check boxes are unchecked" do
      let(:check_box_params) do
        boxes = check_box_attributes.index_with { |_attr| "" }
        boxes[:check_box_cash] = "true"
        boxes
      end

      context "and the amounts are invalid" do
        let(:amount_params) { attributes.index_with { |_attr| rand(1...1_000_000.0).round(2).to_s } }

        it "empties amounts if checkbox is unchecked" do
          attributes_except_cash = attributes - [:cash]
          described_form.save!
          savings_amount.reload
          attributes_except_cash.each do |attr|
            val = savings_amount.__send__(attr)
            expect(val).to be_nil, "Attr #{attr}: expected nil, got #{val}"
          end
        end

        it "does not empty amount if a checkbox is checked" do
          described_form.save!
          expect(savings_amount.reload.cash).not_to be_nil
        end

        it "returns true" do
          expect(described_form.save).to be(true)
        end

        it "has no errors" do
          expect(described_form.errors).to be_empty
        end
      end

      context "when the amounts are not valid" do
        let(:amount_params) { attributes.index_with { |_attr| Faker::Lorem.word } }

        it "empties amounts" do
          described_form.save!
          savings_amount.reload
          attributes.each do |attr|
            val = savings_amount.__send__(attr)
            expect(val).to be_nil, "Attr #{attr}: expected nil, got #{val}"
          end
        end

        it "returns false" do
          expect(described_form.save).to be(false)
          expect(described_form.errors).not_to be_empty
        end
      end

      context "when none of the check boxes are checked" do
        let(:check_box_params) do
          boxes = check_box_attributes.index_with { |_attr| "" }
          boxes[:none_selected] = ""
          boxes
        end
        let(:journey) { "citizens" }

        it "doesnt save and validation returns an error message" do
          expect(described_form.save).to be(false)
          expect(described_form.errors[:check_box_cash]).to include(I18n.t("activemodel.errors.models.savings_amount.attributes.base.#{journey}.none_selected"))
        end
      end

      context "when the 'none selected' check box is checked" do
        let(:check_box_params) do
          boxes = check_box_attributes.index_with { |_attr| "" }
          boxes[:none_selected] = "true"
          boxes
        end

        it "returns true" do
          expect(described_form.save).to be(true)
          expect(described_form.errors).to be_empty
        end
      end
    end
  end
end
