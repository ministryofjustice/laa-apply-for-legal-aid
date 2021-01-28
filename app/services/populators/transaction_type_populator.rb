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
          transaction_type.update!(parent_id: nil) if transaction_type.attributes.include?('parent_id')
        end
      end
    end

    def find_or_create(name, operation)
      record = TransactionType.find_by(name: name, operation: operation)
      record = TransactionType.new(name: name, operation: operation) if record.nil?
      record
    end

    def mark_old_as_archived
      TransactionType.active.where.not(name: TransactionType::NAMES.values.flatten).update(archived_at: Time.current)
      TransactionType.find_by(name: 'student_loan').update!(archived_at: Time.current)
    end

    def update_other_income_types
      TransactionType.where(name: TransactionType::OTHER_INCOME_TYPES).each do |tt|
        tt.update!(other_income: true)
      end
    end

    def populate_hierarchy
      TransactionType::HIERARCHIES.each do |child_name, parent_name|
        child = TransactionType.find_by(name: child_name)
        parent = TransactionType.find_by(name: parent_name)
        child.update!(parent_id: parent.id) if child.attributes.include?('parent_id')
      end
    end
  end
end
