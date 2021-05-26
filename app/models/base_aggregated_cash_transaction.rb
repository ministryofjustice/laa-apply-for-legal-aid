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

  attr_accessor :month1, :month2, :month3

  def initialize(legal_aid_application_id:)
    super
    legal_aid_application = LegalAidApplication.find(legal_aid_application_id)
    @month1 = legal_aid_application.calculation_date.beginning_of_month - 1.month
    @month2 = month1 - 1.month
    @month3 = month2 - 1.month
  end

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
      month_no = trx.month_number
      value_method = "#{trx.transaction_type.name}#{month_no}="
      checkbox_method = "check_box_#{trx.transaction_type.name}="
      model.__send__(value_method, trx.amount)
      model.__send__(checkbox_method, 'true')
      model.__send__("month#{trx.month_number}=", trx.transaction_date)
    end

    def find_by(legal_aid_application_id:)
      transactions = find_transactions(legal_aid_application_id)
      model = new(legal_aid_application_id: legal_aid_application_id)
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

  def period(month_number)
    period_start = transaction_date(month_number)
    I18n.l(period_start, format: '%B %Y')
  end

  def month_name(month_number)
    I18n.l(transaction_date(month_number), format: :month_name).to_s
  end

  private_class_method :attributes_for_transaction_types,
                       :populate_attribute,
                       :find_transactions

  private

  def transaction_date(month_number)
    __send__("month#{month_number}")
  end

  def update_cash_attributes(params)
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
        amount: amount,
        month_number: i
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

    errors.add(category_type.to_sym, model_error(:blank))
  end

  def validate_none_selected
    return if none_selected.blank?

    self.class.cash_transaction_categories.each do |category|
      checkbox_attr = "check_box_#{category}".to_sym
      next unless __send__(checkbox_attr) == 'true'

      errors.add(category_type.to_sym, model_error(:others_present))
      break
    end
  end

  def check_all_values_set_for(category) # rubocop:disable Metrics/AbcSize
    MONTH_RANGE.each do |i|
      value_attr = "#{category}#{i}".to_sym
      value = __send__(value_attr)
      errors.add(value_attr, blank_error(category, i)) if value.blank?

      next if value.blank?

      errors.add(value_attr, I18n.t("errors.#{self.class.to_s.underscore}.invalid_type")) unless number? value
      errors.add(value_attr, I18n.t("errors.#{self.class.to_s.underscore}.negative")) unless valid_amount? value
      errors.add(value_attr, I18n.t("errors.#{self.class.to_s.underscore}.too_many_decimals")) unless CurrencyValidator::ONLY_2_DECIMALS_PATTERN.match? value
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
    __send__("month#{month_number}".to_sym)
  end

  def checkbox_for(category)
    __send__("check_box_#{category}".to_sym)
  end

  def category_type
    self.class.to_s.underscore.gsub('aggregated_', '')
  end

  def blank_error(category, month_number)
    I18n.t("errors.#{self.class.to_s.underscore}.blank",
           category: I18n.t("transaction_types.names.error_message.#{category}"),
           month: month_name(month_number))
  end

  def model_error(type)
    I18n.t("activemodel.errors.models.#{self.class.to_s.underscore}.#{self.class.operation}.attributes.#{category_type}.#{type}")
  end
end
