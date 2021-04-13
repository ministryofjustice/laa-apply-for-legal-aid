module ApplicationMeritsTask
  class InvolvedChild < ApplicationRecord
    belongs_to :legal_aid_application
    has_many :application_proceeding_type_involved_children, class_name: 'ProceedingMeritsTask::ApplicationProceedingTypeInvolvedChild', dependent: :destroy
  end
end
