module ApplicationMeritsTask
  class InvolvedChild < ApplicationRecord
    belongs_to :legal_aid_application
    has_many :application_proceeding_type_linked_children, class_name: 'ProceedingMeritsTask::ApplicationProceedingTypeLinkedChild', dependent: :destroy

    def split_full_name
      name_parts = normalize_spacing_name.split(' ')
      last_name = name_parts.pop
      first_name = name_parts.join(' ')
      first_name = 'unspecified' if first_name.blank?
      [first_name, last_name]
    end

    def normalize_spacing_name
      full_name.strip.gsub(/\s+/, ' ')
    end
  end
end
