module Proceedings
  class DelegatedFunctionsForm < BaseForm
    form_for Proceeding

    attr_accessor :used_delegated_functions, :used_delegated_functions_on_1i, :used_delegated_functions_on_2i, :used_delegated_functions_on_3i
    attr_writer :used_delegated_functions_on

    validate :used_delegated_functions_presence
    validates :used_delegated_functions_on, presence: true, if: :used_delegated_functions_on_presence_required?
    validate :validate_date

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: date_fields.fields,
        model_attributes: date_fields.model_attributes,
      )
    end

    # Note that this method is first called by `validates`.
    # Without that validation, the functionality in this method will not be called before save
    def used_delegated_functions_on
      return @used_delegated_functions_on if @used_delegated_functions_on.present?
      return if date_fields.blank?
      return date_fields.input_field_values if date_fields.partially_complete? || date_fields.form_date_invalid?

      @used_delegated_functions_on = attributes[:used_delegated_functions_on] = date_fields.form_date
    end

    def save
      model.used_delegated_functions_reported_on = Time.zone.today if used_delegated_functions&.to_s == "true"
      super
    end

  private

    def used_delegated_functions_presence
      errors.add(:used_delegated_functions, I18n.t("#{error_base_path}.used_delegated_functions.blank")) if used_delegated_functions.blank?
    end

    def validate_date
      return unless used_delegated_functions.to_s == "true"

      month_range = Date.current.ago(12.months).strftime("%-d %B %Y")
      valid = !date_fields.form_date_invalid?
      date = valid ? date_fields.form_date : nil

      update_errors(valid, date, month_range)
      used_delegated_functions_on
    end

    def update_errors(valid, date, month_range)
      error_date_invalid(valid)
      error_not_in_range(valid, date, month_range)
      error_in_future(valid, date)
    end

    def error_date_invalid(valid)
      return if valid

      errors.add(:used_delegated_functions_on, I18n.t("#{error_base_path}.used_delegated_functions_on.date_invalid"))
    end

    def error_not_in_range(valid, date, month_range)
      return unless valid && date < Date.current - 12.months

      errors.add(:used_delegated_functions_on, I18n.t("#{error_base_path}.used_delegated_functions_on.date_not_in_range", months: month_range))
    end

    def error_in_future(valid, date)
      return unless valid && date > Date.current

      errors.add(:used_delegated_functions_on, I18n.t("#{error_base_path}.used_delegated_functions_on.date_is_in_the_future"))
    end

    def error_base_path
      "activemodel.errors.models.proceedings.attributes"
    end

    def used_delegated_functions_on_presence_required?
      return false if used_delegated_functions.to_s == "false"

      draft_and_not_partially_complete_date?
    end

    def draft_and_not_partially_complete_date?
      draft? && !date_fields.partially_complete?
    end

    def exclude_from_model
      date_fields.fields
    end

    def date_fields
      @date_fields ||= DateFieldBuilder.new(
        form: self,
        model:,
        method: :used_delegated_functions_on,
        prefix: :used_delegated_functions_on_,
        suffix: :gov_uk,
      )
    end
  end
end
