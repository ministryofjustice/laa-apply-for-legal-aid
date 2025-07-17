require "rails_helper"

RSpec.describe SavingsAmounts::OfflineAccountsForm, type: :form do
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
      let(:check_box_params) { check_box_attributes.index_with { |attr| "true" unless attr == :no_account_selected } }

      context "when amounts are valid" do
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
        let(:check_box_params) { { check_box_joint_offline_savings_accounts: "true", no_account_selected: "true" } }

        it "errors" do
          expect(described_form.save).to be false
        end
      end

      shared_examples_for "it has an error" do
        let(:attribute_map) do
          {
            offline_current_accounts: /total.*current accounts/i,
            offline_savings_accounts: /total.*savings accounts/i,
            partner_offline_current_accounts: /total.*current accounts/i,
            partner_offline_savings_accounts: /total.*savings accounts/i,
            joint_offline_current_accounts: /total.*current accounts/i,
            joint_offline_savings_accounts: /total.*savings accounts/i,
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

      shared_examples_for "it has a not a number error" do
        let(:attribute_map) do
          {
            offline_current_accounts: /amount.*savings/i,
            offline_savings_accounts: /amount.*savings/i,
            partner_offline_current_accounts: /total.*current accounts/i,
            partner_offline_savings_accounts: /total.*savings accounts/i,
            joint_offline_current_accounts: /total.*current accounts/i,
            joint_offline_savings_accounts: /total.*savings accounts/i,
          }
        end
        it "returns false" do
          expect(described_form.save).to be(false)
        end

        it "generates errors" do
          described_form.save!
          attributes.each do |attr|
            error_message = described_form.errors[attr].first
            expected_error = attr.starts_with?("partner") || attr.starts_with?("joint") ? expected_partner_error : expected_applicant_error
            expect(error_message).to match(expected_error)
            expect(error_message).to match(attribute_map[attr.to_sym])
          end
        end

        it "does not update the model" do
          expect { described_form.save }.not_to change { savings_amount.reload.updated_at }
        end
      end

      context "when amounts are empty" do
        let(:amount_params) { attributes.index_with { |_attr| "" } }
        let(:expected_error) { /enter the( estimated)? total/i }

        it_behaves_like "it has an error"
      end

      context "when amounts are not numbers" do
        let(:amount_params) { attributes.index_with { |_attr| Faker::Lorem.word } }
        let(:expected_applicant_error) { /Enter the amount of savings, like 1,000 or 20.30/ }
        let(:expected_partner_error) { /must be an amount of money, like 60,000/ }

        it_behaves_like "it has a not a number error"
      end

      context "when amounts have a £ symbol" do
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
        {
          check_box_offline_current_accounts: "true",
          check_box_offline_savings_accounts: "",
          check_box_partner_offline_current_accounts: "",
          check_box_partner_offline_savings_accounts: "",
          check_box_joint_offline_current_accounts: "",
          check_box_joint_offline_savings_accounts: "",
          no_account_selected: "",
        }
      end

      context "when amounts are invalid" do
        let(:amount_params) do
          {
            offline_current_accounts: rand(1...1_000_000.0).round(2).to_s,
            offline_savings_accounts: rand(1...1_000_000.0).round(2).to_s,
            partner_offline_current_accounts: rand(1...1_000_000.0).round(2).to_s,
            partner_offline_savings_accounts: rand(1...1_000_000.0).round(2).to_s,
            joint_offline_current_accounts: rand(1...1_000_000.0).round(2).to_s,
            joint_offline_savings_accounts: rand(1...1_000_000.0).round(2).to_s,
          }
        end

        it "empties amounts if checkbox is unchecked" do
          described_form.save!
          savings_amount.reload
          expect(savings_amount.offline_savings_accounts).to be_nil
        end

        it "does not empty amount if a checkbox is checked" do
          described_form.save!
          expect(savings_amount.reload.offline_current_accounts).not_to be_nil
        end

        it "returns true" do
          expect(described_form.save).to be(true)
        end

        it "has no errors" do
          expect(described_form.errors).to be_empty
        end
      end

      context "when amounts are not valid" do
        let(:amount_params) { attributes.index_with { |_attr| Faker::Lorem.word } }

        it "empties amounts" do
          described_form.save!
          savings_amount.reload
          expect(savings_amount.offline_current_accounts).to be_nil
          expect(savings_amount.offline_savings_accounts).to be_nil
        end

        it "returns false" do
          expect(described_form.save).to be(false)
          expect(described_form.errors).not_to be_empty
        end
      end

      context "when the 'none of these' check box is checked" do
        let(:check_box_params) do
          {
            check_box_offline_current_accounts: "",
            check_box_offline_savings_accounts: "",
            no_account_selected: "true",
          }
        end

        it "returns true" do
          expect(described_form.save).to be(true)
          expect(described_form.errors).to be_empty
        end
      end

      context "when no check box at all is checked" do
        let(:check_box_params) do
          {
            check_box_offline_current_accounts: "",
            check_box_offline_savings_accounts: "",
            no_account_selected: "",
          }
        end

        it "returns false" do
          expect(described_form.save).to be(false)
        end

        it "displays an error message" do
          described_form.save!
          expect(described_form.errors[:check_box_offline_current_accounts]).to include(I18n.t("activemodel.errors.models.savings_amount.attributes.base.providers.no_account_selected"))
        end
      end

      context "when a partner is present and data is submitted" do
        let(:check_box_params) do
          {
            check_box_offline_current_accounts: "",
            check_box_offline_savings_accounts: "",
            check_box_partner_offline_current_accounts: "true",
            check_box_partner_offline_savings_accounts: "true",
            check_box_joint_offline_current_accounts: "true",
            check_box_joint_offline_savings_accounts: "true",
            no_account_selected: "",
          }
        end

        let(:amount_params) do
          {
            offline_current_accounts: rand(1...1_000_000.0).round(2).to_s,
            offline_savings_accounts: rand(1...1_000_000.0).round(2).to_s,
            partner_offline_current_accounts: rand(1...1_000_000.0).round(2).to_s,
            partner_offline_savings_accounts: rand(1...1_000_000.0).round(2).to_s,
            joint_offline_current_accounts: rand(1...1_000_000.0).round(2).to_s,
            joint_offline_savings_accounts: rand(1...1_000_000.0).round(2).to_s,
          }
        end

        it "stores values for partner and joint accounts" do
          described_form.save!
          expect(savings_amount.reload.offline_current_accounts).to be_nil
          expect(savings_amount.reload.offline_savings_accounts).to be_nil
          expect(savings_amount.reload.partner_offline_current_accounts).not_to be_nil
          expect(savings_amount.reload.partner_offline_savings_accounts).not_to be_nil
          expect(savings_amount.reload.joint_offline_current_accounts).not_to be_nil
          expect(savings_amount.reload.joint_offline_savings_accounts).not_to be_nil
        end
      end
    end
  end
end
