module Reviewable
  module Model
    def self.included(base)
      base.class_eval do
        store :reviewed, coder: JSON
      end
    end

    def review_in_progress!(reviewable_name)
      reviewed[reviewable_name] = { status: "in_progress", at: Time.current }
      save!
    end

    def review_completed!(reviewable_name)
      reviewed[reviewable_name] = { status: "completed", at: Time.current }
      save!
    end

    def unreview!(reviewable_name)
      return unless reviewable_name && reviewed.include?(reviewable_name)

      reviewed[reviewable_name] = nil
      save!
    end

    def review_completed?(reviewable_name)
      reviewed[reviewable_name].present? &&
        reviewed[reviewable_name].fetch(:status, nil) == "completed"
    end

    def review_in_progress?(reviewable_name)
      reviewed[reviewable_name].present? &&
        reviewed[reviewable_name].fetch(:status, nil) == "in_progress"
    end

    def reviewed?(reviewable_name)
      reviewed.include?(reviewable_name)
    end

    def requires_review?(reviewable_name)
      reviewed?(reviewable_name) &&
        reviewed[reviewable_name].nil?
    end
  end
end
