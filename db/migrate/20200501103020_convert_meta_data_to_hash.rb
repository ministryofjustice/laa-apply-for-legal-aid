class ConvertMetaDataToHash < ActiveRecord::Migration[6.0]
  # convert all existing BankTransaction records with String meta data to hash.
  def up
    BankTransaction.where.not(meta_data: nil).each do |bt|
      next unless bt.meta_data.is_a?(String)

      label = bt.meta_data
      bt.update!(meta_data: { label: label, name: label, code: 'xx' })
    end
  end

  def down
    BankTransaction.where.not(meta_data: nil).each do |bt|
      label = bt.meta_data[:label]
      bt.update!(meta_data: label)
    end
  end
end
