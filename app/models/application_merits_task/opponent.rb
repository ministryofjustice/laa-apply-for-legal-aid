module ApplicationMeritsTask
  class Opponent < ApplicationRecord
    include NameSplitHelper

    belongs_to :legal_aid_application
  end
end
