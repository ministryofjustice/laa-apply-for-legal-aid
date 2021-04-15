module LegalFramework
  class MeritsTaskList < ApplicationRecord
    belongs_to :legal_aid_application

    def task_list
      SerializableMeritsTaskList.new_from_serialized(serialized_data)
    end
  end
end
