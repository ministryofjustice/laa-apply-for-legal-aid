module ApplicationMeritsTask
  class Opponent < ApplicationRecord
    include CCMSOpponentIdGenerator

    belongs_to :opposable, polymorphic: true
    belongs_to :legal_aid_application
  end
end
