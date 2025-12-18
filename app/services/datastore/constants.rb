module Datastore
  module Constants
    STATUSES = {
      in_progress: { value: "APPLICATION_IN_PROGRESS", label: "In progress" },
      submitted: { value: "APPLICATION_SUBMITTED", label: "Submitted" },
    }.freeze

    def self.status_value(key)
      STATUSES[key]&.fetch(:value)
    end

    def self.status_label(key)
      STATUSES[key]&.fetch(:label)
    end
  end
end
