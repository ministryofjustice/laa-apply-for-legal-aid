require "rails_helper"

RSpec.describe AggregatedCashIncome do
  let(:aci) { described_class.new(legal_aid_application_id: application.id) }
  let!(:pension) { create(:transaction_type, :pension) }
  let(:month1_tx_date) { Time.zone.today.beginning_of_month - 1.month }
  let(:month2_tx_date) { Time.zone.today.beginning_of_month - 2.months }
  let(:month3_tx_date) { Time.zone.today.beginning_of_month - 3.months }
  let(:month1_period) { "#{month1_tx_date.strftime('%d %b %Y')} - #{month1_tx_date.end_of_month.strftime('%d %b %Y')}" }
  let(:month2_period) { "#{month2_tx_date.strftime('%d %b %Y')} - #{month2_tx_date.end_of_month.strftime('%d %b %Y')}" }
  let(:month3_period) { "#{month3_tx_date.strftime('%d %b %Y')} - #{month3_tx_date.end_of_month.strftime('%d %b %Y')}" }
  let(:month1_name) { month1_tx_date.strftime("%B") }
  let(:month2_name) { month2_tx_date.strftime("%B") }
  let(:month3_name) { month3_tx_date.strftime("%B") }
  let(:application) { create(:legal_aid_application, :with_applicant, :with_proceedings) }
  let(:categories) { %i[benefits maintenance_in] }
  let!(:maintenance_in) { create(:transaction_type, :maintenance_in) }

  before do
    create(:transaction_type, :property_or_lodger)
    create(:transaction_type, :friends_or_family)
    create(:transaction_type, :benefits)
    application.set_transaction_period
  end

  describe "#find_by" do
    around do |example|
      travel_to Date.parse("2021-03-12")
      example.run
      travel_back
    end

    context "with no cash income transaction records" do
      it "returns an empty model" do
        aci = described_class.find_by(legal_aid_application_id: application.id, owner: "Applicant")
        expect(aci.check_box_benefits).to be_nil
        expect(aci.benefits1).to be_nil
        expect(aci.benefits2).to be_nil
        expect(aci.benefits3).to be_nil
        expect(aci.check_box_friends_or_family).to be_nil
        expect(aci.friends_or_family1).to be_nil
        expect(aci.friends_or_family2).to be_nil
        expect(aci.friends_or_family3).to be_nil
        expect(aci.check_box_maintenance_in).to be_nil
        expect(aci.maintenance_in1).to be_nil
        expect(aci.maintenance_in2).to be_nil
        expect(aci.maintenance_in3).to be_nil
        expect(aci.check_box_property_or_lodger).to be_nil
        expect(aci.property_or_lodger1).to be_nil
        expect(aci.property_or_lodger2).to be_nil
        expect(aci.property_or_lodger3).to be_nil
        expect(aci.check_box_pension).to be_nil
        expect(aci.pension1).to be_nil
        expect(aci.pension2).to be_nil
        expect(aci.pension3).to be_nil
        expect(aci.month1).to eq month1_tx_date
        expect(aci.month2).to eq month2_tx_date
        expect(aci.month3).to eq month3_tx_date
      end

      context "when delegated functions not used" do
        it "sets the months based on the transaction period end date" do
          expect(application.used_delegated_functions?).to be false
          expect(application.transaction_period_finish_on).to eq Date.parse("2021-03-12")
          expect(aci.month1).to eq Date.parse("2021-02-01")
          expect(aci.month2).to eq Date.parse("2021-01-01")
          expect(aci.month3).to eq Date.parse("2020-12-01")
        end
      end

      context "when delegated functions are used" do
        before do
          application.proceedings.first.update!(used_delegated_functions: true,
                                                used_delegated_functions_on: Date.parse("2021-01-28"),
                                                used_delegated_functions_reported_on: Date.parse("2021-01-28"))
          application.reload
        end

        it "sets the months based on the delegated functions date" do
          expect(application.reload.used_delegated_functions?).to be true
          expect(application.transaction_period_finish_on).to eq Date.parse("2021-03-12")
          expect(aci.month1).to eq Date.parse("2020-12-01")
          expect(aci.month2).to eq Date.parse("2020-11-01")
          expect(aci.month3).to eq Date.parse("2020-10-01")
        end
      end
    end

    context "when cash income transaction records exist" do
      let!(:pension_first_month) { create(:cash_transaction, :credit_month1, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: pension) }
      let!(:pension_second_month) { create(:cash_transaction, :credit_month2, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: pension) }
      let!(:pension_third_month) { create(:cash_transaction, :credit_month3, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: pension) }
      let!(:maintenance_in_first_month) { create(:cash_transaction, :credit_month1, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_in) }
      let!(:maintenance_in_second_month) { create(:cash_transaction, :credit_month2, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_in) }
      let!(:maintenance_in_third_month) { create(:cash_transaction, :credit_month3, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_in) }
      let(:month_1_date) { Date.new(2020, 12, 1) }
      let(:month_2_date) { Date.new(2020, 11, 1) }
      let(:month_3_date) { Date.new(2020, 10, 1) }
      let(:aci) { described_class.find_by(legal_aid_application_id: application.id, owner: "Applicant") }

      around do |example|
        travel_to Time.zone.local(2021, 1, 4, 13, 24, 44)
        example.run
        travel_back
      end

      it "populates the model" do
        expect(aci.check_box_pension).to eq "true"
        expect(aci.pension1).to eq pension_first_month.amount
        expect(aci.pension2).to eq pension_second_month.amount
        expect(aci.pension3).to eq pension_third_month.amount

        expect(aci.check_box_maintenance_in).to eq "true"
        expect(aci.maintenance_in1).to eq maintenance_in_first_month.amount
        expect(aci.maintenance_in2).to eq maintenance_in_second_month.amount
        expect(aci.maintenance_in3).to eq maintenance_in_third_month.amount

        expect(aci.check_box_property_or_lodger).to be_nil
        expect(aci.property_or_lodger1).to be_nil
        expect(aci.property_or_lodger2).to be_nil
        expect(aci.property_or_lodger3).to be_nil

        expect(aci.check_box_benefits).to be_nil
        expect(aci.benefits1).to be_nil
        expect(aci.benefits2).to be_nil
        expect(aci.benefits3).to be_nil

        expect(aci.check_box_friends_or_family).to be_nil
        expect(aci.friends_or_family1).to be_nil
        expect(aci.friends_or_family2).to be_nil
        expect(aci.friends_or_family3).to be_nil

        expect(aci.month1).to eq month_1_date
        expect(aci.month2).to eq month_2_date
        expect(aci.month3).to eq month_3_date
      end
    end
  end

  describe "#valid?" do
    before do
      aci.update(params)
    end

    context "with valid params" do
      context "and none selected" do
        let(:params) { none_selected_params }

        it "is valid" do
          expect(aci.valid?).to be true
        end

        it "has the expected attributes" do
          expect(aci.none_selected).to eq "true"
        end
      end

      context "with categories selected" do
        let(:params) { valid_params }

        it "is valid" do
          expect(aci.valid?).to be true
        end

        it "has the expected attributes" do
          expect(aci.check_box_benefits).to eq "true"
          expect(aci.benefits1).to eq "1"
          expect(aci.benefits2).to eq "2"
          expect(aci.benefits3).to eq "3"

          expect(aci.check_box_maintenance_in).to eq "true"
          expect(aci.maintenance_in1).to eq "4"
          expect(aci.maintenance_in2).to eq "5"
          expect(aci.maintenance_in3).to eq "6"

          expect(aci.none_selected).not_to be_present
        end
      end
    end

    context "with invalid params" do
      context "and missing month value" do
        let(:params) { missing_month_params }

        it "is invalid" do
          expect(aci).not_to be_valid
        end

        it "populates the errors" do
          expect(aci.errors[:maintenance_in1][0]).to eq "Enter the cash amount received in maintenance in #{month1_name}"
          expect(aci.errors[:benefits1][0]).to eq "Enter the cash amount received in benefits in #{month1_name}"
          expect(aci.errors[:benefits3][0]).to eq "Enter the cash amount received in benefits in #{month3_name}"
        end
      end

      context "when amount negative" do
        let(:params) { valid_params.merge({ benefits1: "-1" }) }

        it "is invalid" do
          expect(aci).not_to be_valid
        end

        it "populates the errors" do
          error_msg = "Amount must be more than or equal to zero"
          expect(aci.errors[:benefits1][0]).to eq error_msg
        end
      end

      context "when amount not numerical" do
        let(:params) { valid_params.merge({ benefits1: "$%^&" }) }

        it "is invalid" do
          expect(aci).not_to be_valid
        end

        it "populates the errors" do
          error_msg = "Amount must be an amount of money, like 1000"
          expect(aci.errors[:benefits1][0]).to eq error_msg
        end
      end

      context "when amount has too many decimals" do
        let(:params) { valid_params.merge({ benefits1: "9.99999" }) }

        it "is invalid" do
          expect(aci).not_to be_valid
        end

        it "populates the errors" do
          error_msg = "Amount must not include more than 2 decimal numbers"
          expect(aci.errors[:benefits1][0]).to eq error_msg
        end
      end

      context "with no categories selected" do
        let(:params) { { legal_aid_application_id: application.id } }

        it "is invalid" do
          expect(aci).not_to be_valid
        end

        it "populates the errors" do
          expect(aci.errors.full_messages).to eq ["Cash income Select any payments received in cash"]
        end
      end

      context "when none selected with values" do
        let(:params) { none_selected_with_params }

        it "is invalid" do
          expect(aci).not_to be_valid
        end

        it "populates the errors" do
          expect(aci.errors.full_messages).to eq ["Cash income Select payments in cash or None of the above"]
        end
      end
    end
  end

  describe "#update" do
    context "with previous values" do
      before do
        aci.update(valid_params)
      end

      context "with successful validation" do
        subject(:valid_update) { aci.update(additional_valid_params) }

        it "updates with previously selected checkboxes" do
          valid_update
          expect(aci.check_box_benefits).to eq "true"
          expect(aci.check_box_maintenance_in).to eq "true"
          expect(aci.check_box_pension).to eq "true"
        end

        it "updates with previous values submitted" do
          valid_update
          expect(aci.benefits1).to eq additional_valid_params[:benefits1]
          expect(aci.benefits2).to eq additional_valid_params[:benefits2]
          expect(aci.benefits3).to eq additional_valid_params[:benefits3]
          expect(aci.maintenance_in1).to eq additional_valid_params[:maintenance_in1]
          expect(aci.maintenance_in2).to eq additional_valid_params[:maintenance_in2]
          expect(aci.maintenance_in3).to eq additional_valid_params[:maintenance_in3]
          expect(aci.pension1).to eq additional_valid_params[:pension1]
          expect(aci.pension2).to eq additional_valid_params[:pension2]
          expect(aci.pension3).to eq additional_valid_params[:pension3]
        end
      end
    end

    context "when no cash income records exist" do
      subject(:call_update) { aci.update(params) }

      context "with valid params" do
        let(:params) { valid_params }

        it "creates the expected cash income records" do
          expect { call_update }.to change(CashTransaction, :count).by(6)
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
            expect(aci).not_to be_valid
          end

          it "populates the errors" do
            call_update
            expect(aci.errors[:benefits2]).to include "Amount must be an amount of money, like 1000"
          end
        end

        context "with too many decimal numbers" do
          let(:params) { too_many_decimal_params }

          it "does not create the Cash Transaction records" do
            expect { call_update }.not_to change(CashTransaction, :count)
          end

          it "is not valid" do
            call_update
            expect(aci).not_to be_valid
          end

          it "populates the errors" do
            call_update
            expect(aci.errors[:maintenance_in3]).to include "Amount must not include more than 2 decimal numbers"
          end
        end

        context "with a negative value" do
          let(:params) { negative_params }

          it "does not create the Cash Transaction records" do
            expect { call_update }.not_to change(CashTransaction, :count)
          end

          it "is not valid" do
            call_update
            expect(aci).not_to be_valid
          end

          it "populates the errors" do
            call_update
            expect(aci.errors[:benefits1]).to include "Amount must be more than or equal to zero"
          end
        end

        context "with missing value" do
          let(:params) { missing_value_params }

          it "does not create the Cash Transaction records" do
            expect { call_update }.not_to change(CashTransaction, :count)
          end

          it "is not valid" do
            call_update
            expect(aci).not_to be_valid
          end

          it "populates the errors" do
            call_update
            expect(aci.errors[:benefits1]).to include "Enter the cash amount received in benefits in #{month1_name}"
          end
        end
      end
    end

    context "when cash income records already exist" do
      before do
        aci.update(valid_params)
      end

      context "with preexisting records" do
        subject(:call_update) { aci.update(corrected_valid_params) }

        it "does not change the record count when records updated" do
          expect { call_update }.not_to change(CashTransaction, :count)
        end

        it "changes the preexisting amounts of the records" do
          call_update

          categories.each do |category|
            transactions = category_transactions(aci, category)

            transactions.each_with_index do |transaction, i|
              new_amount = corrected_valid_params[:"#{category}#{i + 1}"]
              expect(transaction.amount).to eq BigDecimal(new_amount)
            end
          end
        end
      end

      context "with preexisting transaction types" do
        subject(:call_update) { aci.update(none_selected_params) }

        it "removes all records when none selected" do
          expect { call_update }.to change(CashTransaction, :count).by(-6)
        end
      end

      context "with additional transaction types" do
        subject(:call_update) { aci.update(additional_valid_params) }

        it "adds to prexisting transaction types" do
          expect { call_update }.to change(CashTransaction, :count).by(3)
        end
      end

      context "with previous months preexisting" do
        subject(:call_update) { aci.update(corrected_valid_params) }

        before do
          travel_to Time.zone.local(2100, 1, 7, 13, 45)
        end

        it "does not add to old records" do
          expect { call_update }.not_to change(CashTransaction, :count)
        end

        it "updates the three previous months according to application calculation date date" do
          call_update

          categories.each do |category|
            transactions = category_transactions(aci, category)

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

  context "with date labeling" do
    around do |example|
      travel_to Time.zone.local(2021, 1, 4, 13, 24, 44)
      example.run
      travel_back
    end

    before do
      create(:cash_transaction, :credit_month1, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: pension)
      create(:cash_transaction, :credit_month2, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: pension)
      create(:cash_transaction, :credit_month3, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: pension)
      create(:cash_transaction, :credit_month1, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_in)
      create(:cash_transaction, :credit_month2, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_in)
      create(:cash_transaction, :credit_month3, legal_aid_application: application, owner_type: "Applicant", owner_id: application.applicant.id, transaction_type: maintenance_in)
    end

    let(:aci) { described_class.find_by(legal_aid_application_id: application.id, owner: "Applicant") }

    describe "#period" do
      context "with locale :en" do
        it "displays the start and end dates of the period" do
          expect(aci.period(1)).to eq "December 2020"
          expect(aci.period(2)).to eq "November 2020"
          expect(aci.period(3)).to eq "October 2020"
        end
      end

      context "with locale :cy" do
        around do |example|
          I18n.with_locale(:cy) { example.run }
        end

        it "displays period in faux Welsh" do
          expect(aci.period(1)).to eq "rebmeceD 2020"
          expect(aci.period(2)).to eq "rebmevoN 2020"
          expect(aci.period(3)).to eq "rebotcO 2020"
        end
      end
    end

    describe "#month name" do
      context "with locale :en" do
        it "displays the month name" do
          expect(aci.month_name(1)).to eq "December"
          expect(aci.month_name(2)).to eq "November"
          expect(aci.month_name(3)).to eq "October"
        end
      end

      context "with locale :cy" do
        around do |example|
          I18n.with_locale(:cy) { example.run }
        end

        it "displays the month nae in faux Welsh" do
          expect(aci.month_name(1)).to eq "rebmeceD"
          expect(aci.month_name(2)).to eq "rebmevoN"
          expect(aci.month_name(3)).to eq "rebotcO"
        end
      end
    end
  end

  def valid_params
    {
      check_box_benefits: "true",
      benefits1: "1",
      benefits2: "2",
      benefits3: "3",
      check_box_maintenance_in: "true",
      maintenance_in1: "4",
      maintenance_in2: "5",
      maintenance_in3: "6",
      legal_aid_application_id: application.id,
      owner_type: "Applicant",
      owner_id: application.applicant.id,
      none_selected: "",
    }
  end

  def non_numeric_params
    valid_params.merge(benefits2: "abc")
  end

  def too_many_decimal_params
    valid_params.merge(maintenance_in3: "24.366")
  end

  def negative_params
    valid_params.merge(benefits1: "-45.33")
  end

  def missing_value_params
    valid_params.merge(benefits1: "")
  end

  def corrected_valid_params
    valid_params.merge({
      benefits1: "7",
      benefits2: "8",
      benefits3: "9",
      maintenance_in1: "10",
      maintenance_in2: "11",
      maintenance_in3: "12",
    })
  end

  def additional_valid_params
    valid_params.merge({
      check_box_pension: "true",
      pension1: "15",
      pension2: "20",
      pension3: "25",
    })
  end

  def none_selected_params
    {
      check_box_benefits: "",
      benefits1: "",
      benefits2: "",
      benefits3: "",
      check_box_maintenance_in: "",
      maintenance_in1: "",
      maintenance_in2: "",
      maintenance_in3: "",
      legal_aid_application_id: application.id,
      none_selected: "true",
    }
  end

  def none_selected_with_params
    valid_params.merge({ none_selected: "true" })
  end

  def missing_month_params
    valid_params.merge({ benefits1: "", benefits3: "", maintenance_in1: "" })
  end

  def category_transactions(aci, category)
    CashTransaction.where(
      legal_aid_application_id: aci.legal_aid_application_id,
      transaction_type_id: transaction_type(category),
    )
  end

  def transaction_type(category)
    TransactionType.credits.find_by(name: category).id
  end
end
