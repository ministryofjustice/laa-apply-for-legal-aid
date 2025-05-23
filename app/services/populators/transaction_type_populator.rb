module Populators
  class TransactionTypePopulator
    def self.call(param = :with_other_income)
      new.call(param)
    end

    def call(param)
      insert_new_records
      mark_old_as_archived
      update_other_income_types if param == :with_other_income
      populate_hierarchy
    end

  private

    def insert_new_records
      TransactionType::NAMES.each_with_index do |(operation, names), op_index|
        names.each_with_index do |name, index|
          start_number = (op_index * 1000) + (index * 10)
          transaction_type = find_or_create(name, operation)
          transaction_type.update! sort_order: start_number
          transaction_type.update!(parent_id: nil) if transaction_type.attributes.include?("parent_id")
        end
      end
    end

    def find_or_create(name, operation)
      record = TransactionType.find_by(name:, operation:)
      record = TransactionType.new(name:, operation:) if record.nil?
      record
    end

    # NOTE: while we could remove transaction types from the TransactionType::NAMES constant to achieve the
    # "deactivation/archiving" this would mean the test environment and UAT branches would not reflect the
    # real world data, as they would not be seeded with that transaction type at all. Archiving a type explicitly,
    # aside from being clearer, therefore allows us identify test suite failures and manually test on UAT with
    # like-real-world data as well as enable use of conditional logic for existing applications with that transaction
    # type that we may want to handle differently.
    #
    # After a period of time, once we are confident the impact would be minimal, we could then remove the transaction type
    # from the TransactionType::NAMES constant AND possibly delete the old transaction type (and associated bank transactions??)
    #
    def mark_old_as_archived
      TransactionType.active.where.not(name: TransactionType::NAMES.values.flatten).update!(archived_at: Time.current)

      TransactionType.active.find_by(name: "excluded_benefits")&.update!(archived_at: Time.current)
    end

    def update_other_income_types
      TransactionType.where(name: TransactionType::OTHER_INCOME_TYPES).find_each do |tt|
        tt.update!(other_income: true)
      end
    end

    def populate_hierarchy
      TransactionType::HIERARCHIES.each do |child_name, parent_name|
        child = TransactionType.find_by(name: child_name)
        parent = TransactionType.find_by(name: parent_name)
        child.update!(parent_id: parent.id) if child.attributes.include?("parent_id")
      end
    end
  end
end
