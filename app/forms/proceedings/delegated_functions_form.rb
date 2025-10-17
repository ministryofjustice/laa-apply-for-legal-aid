module Proceedings
  class DelegatedFunctionsForm < BaseForm
    form_for Proceeding

    attr_accessor :used_delegated_functions, :used_delegated_functions_on

    validates :used_delegated_functions, presence: true, unless: :draft?
    validates :used_delegated_functions_on, date: { not_in_the_future: true, format: "%d/%m/%Y" }, if: :used_delegated_functions_on_presence_required?

    def save
      if used_delegated_functions&.to_s == "true"
        attributes[:used_delegated_functions_reported_on] = Time.zone.today
      else
        attributes[:used_delegated_functions_reported_on] = nil
        attributes[:used_delegated_functions_on] = nil
      end
      super
    end
    alias_method :save!, :save

  private

    # TODO: Redo range, use DateValidator's earliest_allowed_date?
    # def validate_date
    #   return unless used_delegated_functions.to_s == "true"

    #   month_range = Date.current.ago(12.months).strftime("%-d %B %Y")
    #   valid = !date_fields.form_date_invalid?
    #   date = valid ? date_fields.form_date : nil

    #   update_errors(valid, date, month_range)
    #   used_delegated_functions_on
    # end

    # def error_not_in_range(valid, date, month_range)
    #   return unless valid && date < Date.current - 12.months

    #   errors.add(:used_delegated_functions_on, I18n.t("#{error_base_path}.used_delegated_functions_on.date_not_in_range", months: month_range))
    # end
    #
    def used_delegated_functions_on_presence_required?
      return false if used_delegated_functions.to_s == "false" || draft?

      true
    end
  end
end
