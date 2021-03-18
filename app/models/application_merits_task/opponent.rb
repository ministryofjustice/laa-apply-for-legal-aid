module ApplicationMeritsTask
  class Opponent < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
