module ApplicationMeritsTask
  class Incident < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
