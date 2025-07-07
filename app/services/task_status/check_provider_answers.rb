module TaskStatus
  class CheckProviderAnswers < Base
    # Check your answers validation/completion logic:
    # Rules:
    #   1. If not all prior sections completed then it is "Not ready yet"
    #   2. If all prior sections completed but CYA page not completed(*1) then it is "Not started"
    #   3. If all prior sections completed but revisited/changed(*2) and CYA page previously completed(*1) then it is "Review"
    #   4. If all prior sections completed and CYA page completed(*1) then it is "Completed"
    #
    # *1 "Save and continue[d]" will be considered to make the CYA "completed"
    # *2 For simplicity and/or MVP i think it will be better to simply rely on having revisited a page following a CYA page to make CYA need review again as determining if any field in any of the forms may have changed later than the CYA page was completed will be complex
    #
    # If a user goes back to a previous section and changes anything (?? teh data in any previous form) then its completed status
    # is "removed" and rules 1-4 must be reapplied
    #

    def call
      status = ValueObject.new

      status.not_ready!
      status.not_started! if not_started?
      status.review! if review?
      status.completed! if completed?

      status
    end

  private

    def not_started?
      startable? && !previously_reviewed?
    end

    def review?
      startable? && requires_review?
    end

    def completed?
      startable? && currently_reviewed?
    end

    def startable?
      previous_items_completed?
    end

    # See ApplicationTrackable
    # Tracking CYA review status relies on the check_provider_answers controller setting
    # tracked to include a { check_provider_answers: timestamp }
    # key-value pair AND all other controllers for the "section" setting
    # the value for this key to nil if they are visited.
    #

    def currently_reviewed?
      application.tracked[:check_provider_answers].present?
    end

    def previously_reviewed?
      application.tracked.include?(:check_provider_answers)
    end

    def requires_review?
      previously_reviewed? &&
        application.tracked[:check_provider_answers].nil?
    end

    def previous_items_completed?
      previous_item_statuses.all?(&:completed?)
    end

    def previous_item_statuses
      previous_items.map do |previous_item|
        previous_item.send(:new, application).call
      end
    end

    # TODO: this will need to include all prior task list items to this
    def previous_items
      [
        Applicants,
        # MakeLink,
        # ProceedingsTypes
      ]
    end
  end
end
