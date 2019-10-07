module CFE
  class Result < ApplicationRecord
    belongs_to :legal_aid_application
    belongs_to :submission
  end
end
