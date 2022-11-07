module ApplicationMeritsTask
  class Urgency < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
