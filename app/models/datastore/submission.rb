module Datastore
  class Submission < ApplicationRecord
    def self.table_name_prefix
      "datastore_"
    end

    belongs_to :legal_aid_application
  end
end
