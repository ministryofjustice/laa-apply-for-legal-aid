module Reviewable
  module Model
    def self.included(base)
      base.class_eval do
        store :reviewed, coder: JSON
      end
    end

    def reviewed!(reviewable_name)
      reviewed[reviewable_name] = Time.current
      save!
    end

    def unreview!(reviewable_name)
      return unless reviewable_name && reviewed.include?(reviewable_name)

      reviewed[reviewable_name] = nil
      save!
    end

    def currently_reviewed?(reviewable_name)
      reviewed[reviewable_name].present?
    end

    def previously_reviewed?(reviewable_name)
      reviewed.include?(reviewable_name)
    end

    def requires_review?(reviewable_name)
      previously_reviewed?(reviewable_name) &&
        reviewed[reviewable_name].nil?
    end
  end
end
