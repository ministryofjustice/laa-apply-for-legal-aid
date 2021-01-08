# Base class for AggregatedCashIncome and AggregatedCashOutgoings.
#
# These classes are facades to allow three cash transaction records per Transaction Type
# to be displayed on a form and validated.
#
class BaseAggregatedCashTransaction # rubocop:disable Metrics/ClassLength
  include ActiveModel::Model
  include MoneyHelper

  NUMBER_OF_FIELDS = 3
  MONTH_RANGE = (1..NUMBER_OF_FIELDS).freeze

  validate :validate_none_selected
  validate :validate_at_least_one_selected
  validate :checkbox_integrity

  class << self
    # defines the following accessors for each category passed in:
    #  check_box_<category>, <category>1, <category>2, <category>3
    #
    # Usage example:
    #    attributes_for_transaction_types :benefits, :maintenane_in, :pension
    #
    def attributes_for_transaction_types(categories)
      categories.each do |category|
        attr_accessor "check_box_#{category}".to_sym

        MONTH_RANGE.each do |i|
          attr_accessor "#{category}#{i}".to_sym
        end
      end
    end

    def populate_attribute(model, trx)
      month_no = month_number(trx)
      value_method = "#{trx.transaction_type.name}#{month_no}="
      checkbox_method = "check_box_#{trx.transaction_type.name}="
      model.__send__(value_method, trx.amount)
      model.__send__(checkbox_method, 'true')
    end

    def month_number(trx)
      current_month = trx.updated_at.to_date.at_beginning_of_month
      MONTH_RANGE.each do |i|
        return i if (current_month - i.months) == trx.transaction_date
      end
    end

    def find_by(legal_aid_application_id:)
      transactions = find_transactions(legal_aid_application_id)
      model = new
      transactions.each { |trx| populate_attribute(model, trx) }
      model
    end

    def find_transactions(id)
      transaction_type_ids = TransactionType.__send__(operation).map(&:id)

      CashTransaction.where(
        legal_aid_application_id: id,
        transaction_type_id: transaction_type_ids
      )
    end
  end

  private_class_method :attributes_for_transaction_types,
                       :populate_attribute,
                       :month_number,
                       :find_transactions

  private

  def update_attributes(params)
    params.each do |key, value|
      __send__("#{key}=", value)
    end
  end

  def save_cash_transaction_records
    self.class.cash_transaction_categories.each do |category|
      CashTransaction.where(
        legal_aid_application_id: legal_aid_application_id,
        transaction_type_id: transaction_type_id(category)
      ).destroy_all

      save_category(category) if checkbox_for(category) == 'true'
    end
  end

  def save_category(category)
    MONTH_RANGE.each do |i|
      amount = __send__("#{category}#{i}".to_sym)
      date = calculated_date(i)

      CashTransaction.create!(
        legal_aid_application_id: legal_aid_application_id,
        transaction_type_id: transaction_type_id(category),
        transaction_date: date,
        amount: amount
      )
    end
  end

  def checkbox_integrity
    self.class.cash_transaction_categories.each do |category|
      checkbox_attr = "check_box_#{category}".to_sym

      if __send__(checkbox_attr) == 'true'
        check_all_values_set_for category
      else
        erase_values_for category
      end
    end
  end

  def validate_at_least_one_selected
    return if none_selected.present?

    self.class.cash_transaction_categories.each do |category|
      checkbox_attr = "check_box_#{category}".to_sym
      return false if __send__(checkbox_attr) == 'true'
    end

    errors.add(:none_selected, model_error(:blank))
  end

  def validate_none_selected
    return unless none_selected.present?

    self.class.cash_transaction_categories.each do |category|
      checkbox_attr = "check_box_#{category}".to_sym
      next unless __send__(checkbox_attr) == 'true'

      errors.add(:none_selected, model_error(:others_present))
      break
    end
  end

  def check_all_values_set_for(category) # rubocop:disable Metrics/AbcSize
    MONTH_RANGE.each do |i|
      value_attr = "#{category}#{i}".to_sym
      value = __send__(value_attr)

      errors.add(value_attr, amount_error(:blank)) unless value.present?
      errors.add(value_attr, amount_error(:invalid_type)) unless number? value
      errors.add(value_attr, amount_error(:negative)) unless valid_amount? value
      errors.add(value_attr, amount_error(:too_many_decimals)) unless CurrencyValidator::ONLY_2_DECIMALS_PATTERN.match? value
    end
  end

  def erase_values_for(category)
    MONTH_RANGE.each do |i|
      method = "#{category}#{i}=".to_sym
      __send__(method, nil)
    end
  end

  def transaction_type_id(category)
    TransactionType.__send__(self.class.operation).find_by(name: category)&.id
  end

  def calculated_date(month_number)
    Date.today.at_beginning_of_month - month_number.months
  end

  def checkbox_for(category)
    __send__("check_box_#{category}".to_sym)
  end
end
