require 'rails_helper'

RSpec.describe AggregatedCashIncome, type: :model do
  let(:aci) { AggregatedCashIncome.new }
  let(:application) { create :legal_aid_application }
  let(:categories) { %i[benefits maintenance_in] }
  let!(:benefits) { create :transaction_type, :benefits }
  let!(:maintenance_in) { create :transaction_type, :maintenance_in }
  let!(:friends_or_family) { create :transaction_type, :friends_or_family }
  let!(:property_or_lodger) { create :transaction_type, :property_or_lodger }
  let!(:pension) { create :transaction_type, :pension }

  describe '#find_by' do
    context 'no cash income transaction records' do
      it 'returns an empty model' do
        aci = AggregatedCashIncome.find_by(legal_aid_application_id: application.id)
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
      end
    end

    context 'cash income transaction records exist' do
      let(:pension1) { create :cash_transaction, :credit_month_1, legal_aid_application: application, transaction_type: pension }
      let(:pension2) { create :cash_transaction, :credit_month_2, legal_aid_application: application, transaction_type: pension }
      let(:pension3) { create :cash_transaction, :credit_month_3, legal_aid_application: application, transaction_type: pension }
      let(:maintenance_in1) { create :cash_transaction, :credit_month_1, legal_aid_application: application, transaction_type: maintenance_in }
      let(:maintenance_in2) { create :cash_transaction, :credit_month_2, legal_aid_application: application, transaction_type: maintenance_in }
      let(:maintenance_in3) { create :cash_transaction, :credit_month_3, legal_aid_application: application, transaction_type: maintenance_in }

      before do
        pension1
        pension2
        pension3
        maintenance_in1
        maintenance_in2
        maintenance_in3
      end

      it 'populates the model' do
        aci = AggregatedCashIncome.find_by(legal_aid_application_id: application.id)
        expect(aci.check_box_pension).to eq 'true'
        expect(aci.pension1).to eq pension1.amount
        expect(aci.pension2).to eq pension2.amount
        expect(aci.pension3).to eq pension3.amount
        expect(aci.check_box_maintenance_in).to eq 'true'
        expect(aci.maintenance_in1).to eq maintenance_in1.amount
        expect(aci.maintenance_in2).to eq maintenance_in2.amount
        expect(aci.maintenance_in3).to eq maintenance_in3.amount
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
      end
    end
  end

  describe '#valid?' do
    before do
      aci.update(params)
    end

    context 'valid params' do
      context 'none selected' do
        let(:params) { none_selected_params }

        it 'is valid' do
          expect(aci.valid?).to be true
        end

        it 'has the expected attributes' do
          expect(aci.none_selected).to eq 'true'
        end
      end

      context 'categories selected' do
        let(:params) { valid_params }

        it 'is valid' do
          expect(aci.valid?).to be true
        end

        it 'has the expected attributes' do
          expect(aci.check_box_benefits).to eq 'true'
          expect(aci.benefits1).to eq '1'
          expect(aci.benefits2).to eq '2'
          expect(aci.benefits3).to eq '3'

          expect(aci.check_box_maintenance_in).to eq 'true'
          expect(aci.maintenance_in1).to eq '4'
          expect(aci.maintenance_in2).to eq '5'
          expect(aci.maintenance_in3).to eq '6'

          expect(aci.none_selected).not_to be_present
        end
      end
    end

    context 'invalid params' do
      context 'missing month value' do
        let(:params) { missing_month_params }

        it 'is invalid' do
          expect(aci).not_to be_valid
        end

        it 'populates the errors' do
          error_msg = 'Enter the total cash amount you received in each calendar month'

          expect(aci.errors[:maintenance_in1][0]).to eq error_msg
          expect(aci.errors[:benefits1][0]).to eq error_msg
          expect(aci.errors[:benefits3][0]).to eq error_msg
        end
      end

      context 'amount negative' do
        let(:params) { valid_params.merge({ benefits1: '-1' }) }

        it 'is invalid' do
          expect(aci).not_to be_valid
        end

        it 'populates the errors' do
          error_msg = 'Amount must be more than or equal to zero'
          expect(aci.errors[:benefits1][0]).to eq error_msg
        end
      end

      context 'amount not numerical' do
        let(:params) { valid_params.merge({ benefits1: '$%^&' }) }

        it 'is invalid' do
          expect(aci).not_to be_valid
        end

        it 'populates the errors' do
          error_msg = 'Amount must be an amount of money, like 1,000'
          expect(aci.errors[:benefits1][0]).to eq error_msg
        end
      end

      context 'amount too many decimals' do
        let(:params) { valid_params.merge({ benefits1: '9.99999' }) }

        it 'is invalid' do
          expect(aci).not_to be_valid
        end

        it 'populates the errors' do
          error_msg = 'Amount must not include more than 2 decimal numbers'
          expect(aci.errors[:benefits1][0]).to eq error_msg
        end
      end

      context 'no categories selected' do
        let(:params) { { legal_aid_application_id: application.id } }

        it 'is invalid' do
          expect(aci).not_to be_valid
        end

        it 'populates the errors' do
          expect(aci.errors.full_messages).to eq ['None selected Select if you receive these payments in cash']
        end
      end

      context 'none selected with values' do
        let(:params) { none_selected_with_params }

        it 'is invalid' do
          expect(aci).not_to be_valid
        end

        it 'populates the errors' do
          expect(aci.errors.full_messages).to eq ['None selected Select payments in cash or None of the above']
        end
      end
    end
  end

  describe '#update' do
    context 'previous values' do
      before do
        aci.update(valid_params)
      end

      context 'upon successful validation' do
        let(:subject) { aci.update(additional_valid_params) }

        it 'updates with previously selected checkboxes' do
          subject
          expect(aci.check_box_benefits).to eq 'true'
          expect(aci.check_box_maintenance_in).to eq 'true'
          expect(aci.check_box_pension).to eq 'true'
        end

        it 'updates with previous values submitted' do
          subject
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

    context 'no cash income records exist' do
      let(:subject) { aci.update(params) }

      context 'valid params' do
        let(:params) { valid_params }
        it 'creates the expected cash income records' do
          expect { subject }.to change { CashTransaction.count }.by(6)
        end
      end

      context 'invalid params' do
        context 'non-numeric values' do
          let(:params) { non_numeric_params }

          it 'does not create the Cash Transaction records' do
            expect { subject }.not_to change { CashTransaction.count }
          end

          it 'is not valid' do
            subject
            expect(aci).not_to be_valid
          end

          it 'populates the errors' do
            subject
            expect(aci.errors[:benefits2]).to include 'Amount must be an amount of money, like 1,000'
          end
        end

        context 'too many decimal numbers' do
          let(:params) { too_many_decimal_params }

          it 'does not create the Cash Transaction records' do
            expect { subject }.not_to change { CashTransaction.count }
          end

          it 'is not valid' do
            subject
            expect(aci).not_to be_valid
          end

          it 'populates the errors' do
            subject
            expect(aci.errors[:maintenance_in3]).to include 'Amount must not include more than 2 decimal numbers'
          end
        end

        context 'negative value' do
          let(:params) { negative_params }

          it 'does not create the Cash Transaction records' do
            expect { subject }.not_to change { CashTransaction.count }
          end

          it 'is not valid' do
            subject
            expect(aci).not_to be_valid
          end

          it 'populates the errors' do
            subject
            expect(aci.errors[:benefits1]).to include 'Amount must be more than or equal to zero'
          end
        end

        context 'missing value' do
          let(:params) { missing_value_params }

          it 'does not create the Cash Transaction records' do
            expect { subject }.not_to change { CashTransaction.count }
          end

          it 'is not valid' do
            subject
            expect(aci).not_to be_valid
          end

          it 'populates the errors' do
            subject
            expect(aci.errors[:benefits1]).to include 'Enter the total cash amount you received in each calendar month'
          end
        end
      end
    end

    context 'cash income records already exist' do
      before do
        aci.update(valid_params)
      end

      context 'preexisting records' do
        let(:subject) { aci.update(corrected_valid_params) }

        it 'does not change the record count when records updated' do
          expect { subject }.to change { CashTransaction.count }.by(0)
        end

        it 'changes the preexisting amounts of the records' do
          subject

          categories.each do |category|
            transactions = category_transactions(aci, category)

            transactions.each_with_index do |transaction, i|
              new_amount = corrected_valid_params["#{category}#{i + 1}".to_sym]
              expect(transaction.amount).to eq BigDecimal(new_amount)
            end
          end
        end
      end

      context 'preexisting transaction types' do
        let(:subject) { aci.update(none_selected_params) }

        it 'removes all records when none selected' do
          expect { subject }.to change { CashTransaction.count }.by(-6)
        end
      end

      context 'additional transaction types' do
        let(:subject) { aci.update(additional_valid_params) }

        it 'adds to prexisting transaction types' do
          expect { subject }.to change { CashTransaction.count }.by(3)
        end
      end

      context 'previous months preexisting' do
        let(:subject) { aci.update(corrected_valid_params) }

        before do
          travel_to Time.local(2100, 1, 7, 13, 45)
        end

        it 'does not add to old records' do
          expect { subject }.to change { CashTransaction.count }.by(0)
        end

        it 'updates the three previous months according to current date' do
          subject

          categories.each do |category|
            transactions = category_transactions(aci, category)

            transactions.each_with_index do |transaction, i|
              date = transaction.transaction_date
              historical_date = Date.today.at_beginning_of_month - (i + 1).months
              expect(date).to eq historical_date
            end
          end
        end
      end
    end
  end

  def valid_params
    {
      check_box_benefits: 'true',
      benefits1: '1',
      benefits2: '2',
      benefits3: '3',
      check_box_maintenance_in: 'true',
      maintenance_in1: '4',
      maintenance_in2: '5',
      maintenance_in3: '6',
      legal_aid_application_id: application.id,
      none_selected: ''
    }
  end

  def non_numeric_params
    valid_params.merge(benefits2: 'abc')
  end

  def too_many_decimal_params
    valid_params.merge(maintenance_in3: '24.366')
  end

  def negative_params
    valid_params.merge(benefits1: '-45.33')
  end

  def missing_value_params
    valid_params.merge(benefits1: '')
  end

  def corrected_valid_params
    valid_params.merge({
                         benefits1: '7',
                         benefits2: '8',
                         benefits3: '9',
                         maintenance_in1: '10',
                         maintenance_in2: '11',
                         maintenance_in3: '12'
                       })
  end

  def additional_valid_params
    valid_params.merge({
                         check_box_pension: 'true',
                         pension1: '15',
                         pension2: '20',
                         pension3: '25'
                       })
  end

  def none_selected_params
    {
      check_box_benefits: '',
      benefits1: '',
      benefits2: '',
      benefits3: '',
      check_box_maintenance_in: '',
      maintenance_in1: '',
      maintenance_in2: '',
      maintenance_in3: '',
      legal_aid_application_id: application.id,
      none_selected: 'true'
    }
  end

  def none_selected_with_params
    valid_params.merge({ none_selected: 'true' })
  end

  def missing_month_params
    valid_params.merge({ benefits1: '', benefits3: '', maintenance_in1: '' })
  end

  def category_transactions(aci, category)
    CashTransaction.where(
      legal_aid_application_id: aci.legal_aid_application_id,
      transaction_type_id: transaction_type(category)
    )
  end

  def transaction_type(category)
    TransactionType.credits.find_by(name: category).id
  end
end
