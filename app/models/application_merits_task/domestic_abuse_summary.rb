module ApplicationMeritsTask
  class DomesticAbuseSummary < ApplicationRecord
    belongs_to :legal_aid_application
  end
end
