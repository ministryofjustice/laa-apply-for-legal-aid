require "rails_helper"

RSpec.describe AggregatedCashOutgoings do
  let(:aco) { described_class.new(legal_aid_application_id: application.id) }
  let(:month1_tx_date) { Time.zone.today.beginning_of_month - 1.month }
  let(:month2_tx_date) { Time.zone.today.beginning_of_month - 2.months }
  let(:month3_tx_date) { Time.zone.today.beginning_of_month - 3.months }
  let(:month1_period) { "#{month1_tx_date.strftime('%d %b %Y')} - #{month1_tx_date.end_of_month.strftime('%d %b %Y')}" }
  let(:month2_period) { "#{month2_tx_date.strftime('%d %b %Y')} - #{month2_tx_date.end_of_month.strftime('%d %b %Y')}" }
  let(:month3_period) { "#{month3_tx_date.strftime('%d %b %Y')} - #{month3_tx_date.end_of_month.strftime('%d %b %Y')}" }
  let(:month1_name) { month1_tx_date.strftime("%B") }
  let(:month2_name) { month2_tx_date.strftime("%B") }
  let(:month3_name) { month3_tx_date.strftime("%B") }
  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:categories) { %i[rent_or_mortgage maintenance_out] }
  let!(:maintenance_out) { create(:transaction_type, :maintenance_out) }

  before do
    create(:transaction_type, :legal_aid)
    create(:transaction_type, :rent_or_mortgage)
    application.set_transaction_period
  end

  describe "#find_by" do
    context "with no cash income transaction records" do
      it "returns an empty model" do
        aco = described_class.find_by(legal_aid_application_id: application.id, owner: "Applicant")
        expect(aco.check_box_rent_or_mortgage).to be_nil
        expect(aco.rent_or_mortgage1).to be_nil
        expect(aco.rent_or_mortgage2).to be_nil
        expect(aco.rent_or_mortgage3).to be_nil
        expect(aco.check_box_child_care).to be_nil
        expect(aco.child_care1).to be_nil
        expect(aco.child_care2).to be_nil
        expect(aco.child_care3).to be_nil
        expect(aco.check_box_maintenance_out).to be_nil
        expect(aco.maintenance_out1).to be_nil
        expect(aco.maintenance_out2).to be_nil
        expect(aco.maintenance_out3).to be_nil
        expect(aco.check_box_legal_aid).to be_nil
        expect(aco.legal_aid1).to be_nil
        expect(aco.legal_aid2).to be_nil
        expect(aco.legal_aid3).to be_nil
        expect(aco.month1).to eq month1_tx_date
        expect(aco.month2).to eq month2_tx_date
        expect(aco.month3).to eq month3_tx_date
      end
    end

    context "when cash income transaction records exist" do
      let!(:maintenance_out_first_month) { create(:cash_transaction, :credit_month1, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_out) }
      let!(:maintenance_out_second_month) { create(:cash_transaction, :credit_month2, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_out) }
      let!(:maintenance_out_third_month) { create(:cash_transaction, :credit_month3, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_out) }
      let(:month_1_date) { Date.new(2020, 12, 1) }
      let(:month_2_date) { Date.new(2020, 11, 1) }
      let(:month_3_date) { Date.new(2020, 10, 1) }
      let(:aco) { described_class.find_by(legal_aid_application_id: application.id, owner: "Applicant") }

      around do |example|
        travel_to Time.zone.local(2021, 1, 4, 13, 24, 44)
        example.run
        travel_back
      end

      it "populates the model" do
        expect(aco.check_box_maintenance_out).to eq "true"
        expect(aco.maintenance_out1).to eq maintenance_out_first_month.amount
        expect(aco.maintenance_out2).to eq maintenance_out_second_month.amount
        expect(aco.maintenance_out3).to eq maintenance_out_third_month.amount
        expect(aco.check_box_legal_aid).to be_nil
        expect(aco.legal_aid1).to be_nil
        expect(aco.legal_aid2).to be_nil
        expect(aco.legal_aid3).to be_nil
        expect(aco.check_box_rent_or_mortgage).to be_nil
        expect(aco.rent_or_mortgage1).to be_nil
        expect(aco.rent_or_mortgage2).to be_nil
        expect(aco.rent_or_mortgage3).to be_nil
        expect(aco.check_box_child_care).to be_nil
        expect(aco.child_care1).to be_nil
        expect(aco.child_care2).to be_nil
        expect(aco.child_care3).to be_nil

        expect(aco.month1).to eq month_1_date
        expect(aco.month2).to eq month_2_date
        expect(aco.month3).to eq month_3_date
      end
    end
  end

  describe "#valid?" do
    before do
      aco.update(params)
    end

    context "with valid params" do
      context "and none selected" do
        let(:params) { none_selected_params }

        it "is valid" do
          expect(aco.valid?).to be true
        end

        it "has the expected attributes" do
          expect(aco.none_selected).to eq "true"
        end
      end

      context "with categories selected" do
        let(:params) { valid_params }

        it "is valid" do
          expect(aco.valid?).to be true
        end

        it "has the expected attributes" do
          expect(aco.check_box_rent_or_mortgage).to eq "true"
          expect(aco.rent_or_mortgage1).to eq "1"
          expect(aco.rent_or_mortgage2).to eq "2"
          expect(aco.rent_or_mortgage3).to eq "3"

          expect(aco.check_box_maintenance_out).to eq "true"
          expect(aco.maintenance_out1).to eq "4"
          expect(aco.maintenance_out2).to eq "5"
          expect(aco.maintenance_out3).to eq "6"

          expect(aco.none_selected).not_to be_present
        end
      end
    end

    context "with invalid params" do
      context "and missing month value" do
        let(:params) { missing_month_params }

        it "is invalid" do
          expect(aco).not_to be_valid
        end

        it "populates the errors" do
          expect(aco.errors[:maintenance_out1][0]).to eq error_msg("maintenance", month1_name)
          expect(aco.errors[:rent_or_mortgage1][0]).to eq error_msg("housing", month1_name)
          expect(aco.errors[:rent_or_mortgage3][0]).to eq error_msg("housing", month3_name)
        end
      end

      context "with amount negative" do
        let(:params) { valid_params.merge({ rent_or_mortgage1: "-1" }) }

        it "is invalid" do
          expect(aco).not_to be_valid
        end

        it "populates the errors" do
          error_msg = "Amount must be more than or equal to zero"
          expect(aco.errors[:rent_or_mortgage1][0]).to eq error_msg
        end
      end

      context "when amount not numerical" do
        let(:params) { valid_params.merge({ rent_or_mortgage1: "$%^&" }) }

        it "is invalid" do
          expect(aco).not_to be_valid
        end

        it "populates the errors" do
          expect(aco.errors[:rent_or_mortgage1][0]).to eq error_msg("housing", month1_name)
        end
      end

      context "when amount has too many decimals" do
        let(:params) { valid_params.merge({ rent_or_mortgage1: "9.99999" }) }

        it "is invalid" do
          expect(aco).not_to be_valid
        end

        it "populates the errors" do
          expect(aco.errors[:rent_or_mortgage1][0]).to eq error_msg("housing", month1_name)
        end
      end

      context "with no categories selected" do
        let(:params) { { legal_aid_application_id: application.id } }

        it "is invalid" do
          expect(aco).not_to be_valid
        end

        it "populates the errors" do
          expect(aco.errors.full_messages).to eq ["Cash outgoings Select any payments made in cash"]
        end
      end

      context "when none selected with values" do
        let(:params) { none_selected_with_params }

        it "is invalid" do
          expect(aco).not_to be_valid
        end

        it "populates the errors" do
          expect(aco.errors.full_messages).to eq ["Cash outgoings Select payments in cash or None of the above"]
        end
      end
    end
  end

  describe "#update" do
    context "with previous values" do
      before do
        aco.update(valid_params)
      end

      context "with successful validation" do
        let(:call_update) { aco.update(additional_valid_params) }

        it "updates with previously selected checkboxes" do
          call_update
          expect(aco.check_box_rent_or_mortgage).to eq "true"
          expect(aco.check_box_maintenance_out).to eq "true"
        end

        it "updates with previous values submitted" do
          call_update
          expect(aco.rent_or_mortgage1).to eq additional_valid_params[:rent_or_mortgage1]
          expect(aco.rent_or_mortgage2).to eq additional_valid_params[:rent_or_mortgage2]
          expect(aco.rent_or_mortgage3).to eq additional_valid_params[:rent_or_mortgage3]
          expect(aco.maintenance_out1).to eq additional_valid_params[:maintenance_out1]
          expect(aco.maintenance_out2).to eq additional_valid_params[:maintenance_out2]
          expect(aco.maintenance_out3).to eq additional_valid_params[:maintenance_out3]
        end
      end
    end

    context "when no cash income records exist" do
      subject(:call_update) { aco.update(params) }

      context "with valid params" do
        let(:params) { valid_params }

        it "creates the expected cash income records" do
          expect { call_update }.to change(CashTransaction, :count).by(6)
        end
      end

      context "with valid comma separate monetary params" do
        let(:params) { valid_params.merge(rent_or_mortgage1: "1,222,222.33") }

        it "creates the expected cash income records" do
          expect { call_update }.to change(CashTransaction, :count).by(6)
          expect(CashTransaction.pluck(:amount)).to include(1_222_222.33)
        end
      end

      context "with invalid params" do
        context "and non-numeric values" do
          let(:params) { non_numeric_params }

          it "does not create the Cash Transaction records" do
            expect { call_update }.not_to change(CashTransaction, :count)
          end

          it "is not valid" do
            call_update
            expect(aco).not_to be_valid
          end

          it "populates the errors" do
            call_update
            expect(aco.errors[:rent_or_mortgage2]).to include error_msg("housing", month2_name)
          end
        end

        context "with too many decimal numbers" do
          let(:params) { too_many_decimal_params }

          it "does not create the Cash Transaction records" do
            expect { call_update }.not_to change(CashTransaction, :count)
          end

          it "is not valid" do
            call_update
            expect(aco).not_to be_valid
          end

          it "populates the errors" do
            call_update
            expect(aco.errors[:maintenance_out3]).to include error_msg("maintenance", month3_name)
          end
        end

        context "with a negative value" do
          let(:params) { negative_params }

          it "does not create the Cash Transaction records" do
            expect { call_update }.not_to change(CashTransaction, :count)
          end

          it "is not valid" do
            call_update
            expect(aco).not_to be_valid
          end

          it "populates the errors" do
            call_update
            expect(aco.errors[:rent_or_mortgage1]).to include "Amount must be more than or equal to zero"
          end
        end

        context "with a missing value" do
          let(:params) { missing_value_params }

          it "does not create the Cash Transaction records" do
            expect { call_update }.not_to change(CashTransaction, :count)
          end

          it "is not valid" do
            call_update
            expect(aco).not_to be_valid
          end

          it "populates the errors" do
            call_update
            expect(aco.errors[:rent_or_mortgage1]).to include "Enter the amount paid for housing in #{month1_name}, like 1,000 or 20.30"
          end
        end
      end
    end

    context "when cash income records already exist" do
      before do
        aco.update(valid_params)
      end

      context "with preexisting records" do
        subject(:call_update) { aco.update(corrected_valid_params) }

        it "does not change the record count when records updated" do
          expect { call_update }.not_to change(CashTransaction, :count)
        end

        it "changes the preexisting amounts of the records" do
          call_update

          categories.each do |category|
            transactions = category_transactions(aco, category)

            transactions.each_with_index do |transaction, i|
              new_amount = corrected_valid_params[:"#{category}#{i + 1}"]
              expect(transaction.amount).to eq BigDecimal(new_amount)
            end
          end
        end
      end

      context "with preexisting transaction types" do
        subject(:call_update) { aco.update(none_selected_params) }

        it "removes all records when none selected" do
          expect { call_update }.to change(CashTransaction, :count).by(-6)
        end
      end

      context "with additional transaction types" do
        subject(:call_update) { aco.update(additional_valid_params) }

        it "adds to prexisting transaction types" do
          expect { call_update }.to change(CashTransaction, :count).by(3)
        end
      end

      context "with previous months preexisting" do
        subject(:call_update) { aco.update(corrected_valid_params) }

        before do
          travel_to Time.zone.local(2100, 1, 7, 13, 45)
        end

        it "does not add to old records" do
          expect { call_update }.not_to change(CashTransaction, :count)
        end

        it "updates the three previous months according to applicaiton calculation date" do
          call_update

          categories.each do |category|
            transactions = category_transactions(aco, category)

            transactions.each_with_index do |transaction, i|
              date = transaction.transaction_date
              historical_date = application.calculation_date.at_beginning_of_month - (i + 1).months
              expect(date).to eq historical_date
            end
          end
        end
      end
    end
  end

  def error_msg(name, month)
    "Enter the amount paid for #{name} in #{month}, like 1,000 or 20.30"
  end

  def valid_params
    {
      check_box_rent_or_mortgage: "true",
      rent_or_mortgage1: "1",
      rent_or_mortgage2: "2",
      rent_or_mortgage3: "3",
      check_box_maintenance_out: "true",
      maintenance_out1: "4",
      maintenance_out2: "5",
      maintenance_out3: "6",
      legal_aid_application_id: application.id,
      owner_type: "Applicant",
      owner_id: application.applicant.id,
      none_selected: "",
    }
  end

  def additional_valid_params
    valid_params.merge({
      check_box_legal_aid: "true",
      legal_aid1: "15",
      legal_aid2: "20",
      legal_aid3: "25",
    })
  end

  def non_numeric_params
    valid_params.merge(rent_or_mortgage2: "abc")
  end

  def too_many_decimal_params
    valid_params.merge(maintenance_out3: "24.366")
  end

  def negative_params
    valid_params.merge(rent_or_mortgage1: "-45.33")
  end

  def missing_value_params
    valid_params.merge(rent_or_mortgage1: "")
  end

  def corrected_valid_params
    valid_params.merge({
      rent_or_mortgage1: "7",
      rent_or_mortgage2: "8",
      rent_or_mortgage3: "9",
      maintenance_out1: "10",
      maintenance_out2: "11",
      maintenance_out3: "12",
    })
  end

  def none_selected_params
    {
      check_box_rent_or_mortgage: "",
      rent_or_mortgage1: "",
      rent_or_mortgage2: "",
      rent_or_mortgage3: "",
      check_box_maintenance_out: "",
      maintenance_out1: "",
      maintenance_out2: "",
      maintenance_out3: "",
      legal_aid_application_id: application.id,
      owner_type: "Applicant",
      owner_id: application.applicant.id,
      none_selected: "true",
    }
  end

  def none_selected_with_params
    valid_params.merge({ none_selected: "true" })
  end

  def missing_month_params
    valid_params.merge({ rent_or_mortgage1: "", rent_or_mortgage3: "", maintenance_out1: "" })
  end

  def category_transactions(aco, category)
    CashTransaction.where(
      legal_aid_application_id: aco.legal_aid_application_id,
      transaction_type_id: transaction_type(category),
    )
  end

  def transaction_type(category)
    TransactionType.debits.find_by(name: category).id
  end
end
