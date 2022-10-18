module ApplicationMeritsTask
  class Allegation < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
