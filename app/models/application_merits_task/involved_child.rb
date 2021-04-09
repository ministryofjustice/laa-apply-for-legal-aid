module ApplicationMeritsTask
  class InvolvedChild < ApplicationRecord
    belongs_to :legal_aid_application
    has_many :application_proceeding_type_involved_children, dependent: :destroy
  end
end
