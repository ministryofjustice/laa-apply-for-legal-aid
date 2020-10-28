require 'csv'
module TrueLayer
  class SampleTransactionsCsvParser
    def self.call
      new.call
    end

    def call
      @transaction_ids = []
      CSV.read(Rails.root.join(Setting.bank_transaction_filename), headers: true).map do |row|
        parse_transaction_csv_row(row.to_h.symbolize_keys)
      end
    end

    private

    def parse_transaction_csv_row(row)
      transaction_type = row[:amount_in].present? ? :credit : :debit
      amount = transaction_type == :credit ? parse_amount(row[:amount_in]) : - parse_amount(row[:amount_out])
      {
        transaction_id: unique_but_not_random_id(row),
        description: row[:description],
        currency: 'GBP',
        amount: amount.to_f,
        timestamp: Time.zone.parse(row[:date]).to_s,
        transaction_type: transaction_type.to_s,
        running_balance: running_balance(row)
      }
    end

    def running_balance(row)
      return nil if row[:running_balance].nil?

      { amount: parse_amount(row[:running_balance]), currency: 'GBP' }
    end

    def parse_amount(amount_string)
      amount_string.tr('^0-9.', '').to_d
    end

    def unique_but_not_random_id(row)
      counter = 0
      transaction_id = ''
      loop do
        counter += 1
        transaction_id = JWT.encode("#{row.values.join}#{counter}", 'secret!', 'HS256').last(40)
        break unless transaction_id.in?(@transaction_ids)
      end
      @transaction_ids << transaction_id
      transaction_id
    end
  end
end
