class BankTransactionPresenter
  CELLS = {
    happened_at: 'happened_at',
    amount_debit: 'debit',
    amount_credit: 'credit',
    operation: 'type',
    description: 'description',
    merchant: 'merchant',
    running_balance: 'balance/running total',
    account_type: 'account type',
    account_name: 'account name',
    category: 'category',
    flagged: 'flagged'
  }.freeze

  attr_reader :transaction

  def self.present!(item, remarks)
    new(item, remarks).present
  end

  def self.headers
    CELLS.values
  end

  def initialize(item, remarks)
    @transaction = item
    @remarks = remarks
  end

  def build_transaction_hash
    values = {}
    CELLS.keys.map { |k| values[k.to_sym] = send("transaction_#{k}") }
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

  def transaction_amount_credit
    @transaction.amount if @transaction.operation.eql?('credit')
  end

  def transaction_amount_debit
    @transaction.amount if @transaction.operation.eql?('debit')
  end

  def transaction_operation
    @transaction.operation
  end

  def transaction_merchant
    @transaction.merchant
  end

  def transaction_category
    return unless @transaction.meta_data.present?

    @transaction.meta_data[:name]
  end

  def transaction_flagged
    return nil if @remarks.empty?

    @remarks.map { |x| x.to_s.humanize }.join(', ').to_s
  end

  def transaction_running_balance
    @transaction.running_balance || 'Not available'
  end

  def transaction_account_type
    account_for_transaction.account_type_label
  end

  def transaction_account_name
    account_for_transaction.bank_and_account_name
  end

  def account_for_transaction
    @transaction.bank_account
  end
end
