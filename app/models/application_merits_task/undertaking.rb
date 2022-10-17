module ApplicationMeritsTask
  class Undertaking < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
