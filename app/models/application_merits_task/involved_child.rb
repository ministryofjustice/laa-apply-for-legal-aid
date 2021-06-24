module ApplicationMeritsTask
  class InvolvedChild < ApplicationRecord
    include NameSplitHelper
    include CCMSOpponentIdGenerator

    belongs_to :legal_aid_application
    has_many :application_proceeding_type_linked_children, class_name: 'ProceedingMeritsTask::ApplicationProceedingTypeLinkedChild', dependent: :destroy
  end
end
