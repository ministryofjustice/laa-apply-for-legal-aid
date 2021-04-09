module LegalFramework
  class MeritsTaskList < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
