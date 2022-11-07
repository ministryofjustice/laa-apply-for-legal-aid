module ApplicationMeritsTask
  class MatterOpposition < ApplicationRecord
    belongs_to :legal_aid_application

    validates :reason, presence: true
  end
end
