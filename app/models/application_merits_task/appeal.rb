module ApplicationMeritsTask
  class Appeal < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
