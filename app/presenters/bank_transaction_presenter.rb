class BankTransactionPresenter
  CELLS = %i[
    happened_at
    debit
    credit
    type
    description
    merchant
    balance_running_total
    account_type
    account_name
    sort_code
    account_number
    category
    selected_by
    flagged
  ].freeze

  attr_reader :transaction

  def self.present!(item, remarks)
    new(item, remarks).present
  end

  def self.headers
    CELLS.map(&:to_s)
  end

  def initialize(item, remarks)
    @transaction = item
    @remarks = remarks
  end

  def build_transaction_hash
    values = {}
    CELLS.map { |k| values[k.to_sym] = send("transaction_#{k}") }
    values
  end

  def present
    build_transaction_hash.values
  end

  private

  def transaction_happened_at
    @transaction.happened_at.strftime('%d/%b/%Y')
  end

  def transaction_description
    @transaction.description
  end

  def transaction_credit
    @transaction.amount if @transaction.operation.eql?('credit')
  end

  def transaction_debit
    @transaction.amount if @transaction.operation.eql?('debit')
  end

  def transaction_type
    @transaction.operation
  end

  def transaction_merchant
    @transaction.merchant
  end

  def transaction_category
    return if @transaction.meta_data.blank?

    @transaction.meta_data[:name]
  end

  def transaction_selected_by
    return if @transaction.meta_data.blank?

    @transaction.meta_data[:selected_by]
  end

  def transaction_flagged
    return nil if @remarks.empty?

    @remarks.map { |x| x.to_s.humanize }.join(', ').to_s
  end

  def transaction_balance_running_total
    @transaction.running_balance || 'Not available'
  end

  def transaction_account_type
    account_for_transaction.account_type_label
  end

  def transaction_account_name
    account_for_transaction.bank_and_account_name
  end

  def transaction_sort_code
    # add tab to end of sort code to prevent bug in Excel interpreting it as a date
    "#{account_for_transaction.sort_code}\t"
  end

  def transaction_account_number
    account_for_transaction.account_number
  end

  def account_for_transaction
    @transaction.bank_account
  end
end
