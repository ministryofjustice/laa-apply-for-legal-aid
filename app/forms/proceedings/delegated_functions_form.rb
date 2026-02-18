module Proceedings
  class DelegatedFunctionsForm < BaseForm
    include ProceedingLoopResettable

    form_for Proceeding

    attr_accessor :used_delegated_functions, :used_delegated_functions_on

    validates :used_delegated_functions, presence: true, unless: :draft?

    validates :used_delegated_functions_on,
              date: {
                format: Date::DATE_FORMATS[:date_picker_parse_format],
                strict_pattern: Date::DATE_PATTERNS[:date_picker_strict],
                not_in_the_future: true,
                earliest_allowed_date: { date: 12.months.ago.to_date.strftime(Date::DATE_FORMATS[:date_picker_parse_format]) },
              },
              if: :used_delegated_functions_on_required?

    # NOTE: position matters. We set the values of these "dirty/changed" variables before any other callbacks so that subsequent callbacks can use them reliably
    set_callback :save, :before, :used_delegated_functions_changed, :used_delegated_functions_on_changed

    set_callback :save, :before, :sync_used_delegated_functions_dates
    set_callback :save, :after, :reset_proceeding_loop, if: :used_delegated_functions_changed?

  private

    def used_delegated_functions_on_required?
      return false if draft?

      used_delegated_functions.to_s == "true"
    end

    def sync_used_delegated_functions_dates
      return unless used_delegated_functions_or_on_changed?

      if used_delegated_functions&.to_s == "true"
        attributes[:used_delegated_functions_reported_on] = Time.zone.today
      else
        attributes[:used_delegated_functions_reported_on] = nil
        attributes[:used_delegated_functions_on] = nil
      end
    end

    def used_delegated_functions_or_on_changed?
      used_delegated_functions_changed? || used_delegated_functions_on_changed?
    end

    # setter
    def used_delegated_functions_changed
      @used_delegated_functions_changed ||= used_delegated_functions.to_s != model.used_delegated_functions.to_s
    end

    # getter
    def used_delegated_functions_changed?
      @used_delegated_functions_changed
    end

    # setter
    def used_delegated_functions_on_changed
      @used_delegated_functions_on_changed ||= used_delegated_functions_on&.to_date != model.used_delegated_functions_on&.to_date
    end

    # getter
    def used_delegated_functions_on_changed?
      @used_delegated_functions_on_changed
    end
  end
end
