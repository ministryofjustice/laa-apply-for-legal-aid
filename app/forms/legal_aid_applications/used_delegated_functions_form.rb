module LegalAidApplications
  class UsedDelegatedFunctionsForm # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model

    validate :validate_nothing_selected,
             :validate_proceeding_date

    attr_accessor :draft,
                  :used_delegated_functions,
                  :proceeding_types_by_name,
                  :none_selected

    class << self
      def call(proceeding_types_by_name)
        populate_attr_accessors(proceeding_types_by_name.map(&:name))
        new({ proceeding_types_by_name: proceeding_types_by_name })
      end

      def populate_attr_accessors(proceeding_names)
        proceeding_names.each do |name|
          attr_accessor :"#{name}_used_delegated_functions_on_1i",
                        :"#{name}_used_delegated_functions_on_2i",
                        :"#{name}_used_delegated_functions_on_3i",
                        :"#{name}_used_delegated_functions_on"
        end
      end
    end

    def initialize(*args)
      super
      proceeding_types_by_name.each do |proceeding|
        date = proceeding.application_proceeding_type.used_delegated_functions_on
        next unless date

        __send__('used_delegated_functions=', 'true') if date
        __send__("#{proceeding.name}_used_delegated_functions_on=", date)
      end
    end

    def save(params)
      update_proceeding_attributes(params)
      populate_inputted_date

      return false unless valid? || draft_nothing_selected?

      save_proceeding_records
    end

    private_class_method :populate_attr_accessors

    private

    def update_proceeding_attributes(params)
      params.each do |key, value|
        __send__("#{key}=", value)
      end
    end

    def populate_inputted_date
      name = proceeding_types_by_name.first.name
      __send__("#{name}_used_delegated_functions_on=", date_fields(name).input_field_values)
    end

    def save_proceeding_records
      proceeding_types_by_name.each do |proceeding|
        date_field = delegated_functions_dates.detect { |field| field.method == :"#{proceeding.name}_used_delegated_functions_on" }
        delegated_functions_date = date_field&.form_date

        proceeding.application_proceeding_type.update(
          used_delegated_functions_on: delegated_functions_date,
          used_delegated_functions_reported_on: delegated_functions_reported_date(delegated_functions_date)
        )
      end
    end

    def delegated_functions_dates
      @delegated_functions_dates ||= proceeding_types_by_name.filter_map do |type|
        date_fields(type.name, type.meaning) if used_delegated_functions == 'true'
      end
    end

    def date_fields(name, meaning = nil)
      DateFieldBuilder.new(
        label: meaning,
        form: self,
        model: self,
        method: :"#{name}_used_delegated_functions_on",
        prefix: :"#{name}_used_delegated_functions_on_",
        suffix: :gov_uk
      )
    end

    def delegated_functions_reported_date(date)
      Time.zone.today unless date.nil?
    end

    def draft_nothing_selected?
      draft && errors.include?(:delegated_functions)
    end

    def validate_nothing_selected
      return if used_delegated_functions.present?

      errors.add(:delegated_functions, I18n.t("#{error_base_path}.nothing_selected"))
    end

    def validate_proceeding_date
      month_range = Date.current.ago(12.months).strftime('%d %m %Y')

      delegated_functions_dates.each do |date_field|
        meaning = date_field.label
        attr_name = date_field.method
        valid = !date_field.form_date_invalid?
        date = valid ? date_field.form_date : nil

        update_errors(meaning, attr_name, valid, date, month_range)
      end
    end

    def update_errors(meaning, attr_name, valid, date, month_range)
      error_date_invalid(meaning, attr_name, valid)
      error_not_in_range(meaning, attr_name, valid, date, month_range)
      error_in_future(meaning, attr_name, valid, date)
    end

    def error_date_invalid(meaning, attr_name, valid)
      return if valid

      errors.add(attr_name, I18n.t("#{error_base_path}.date_invalid", meaning: meaning))
    end

    def error_not_in_range(meaning, attr_name, valid, date, month_range)
      return unless valid && date < Date.current.ago(12.months)

      errors.add(attr_name, I18n.t("#{error_base_path}.date_not_in_range", months: month_range, meaning: meaning))
    end

    def error_in_future(meaning, attr_name, valid, date)
      return unless valid && date > Date.current

      errors.add(attr_name, I18n.t("#{error_base_path}.date_is_in_the_future", meaning: meaning))
    end

    def error_base_path
      'activemodel.errors.models.application_proceeding_types.attributes.used_delegated_functions_on'
    end
  end
end
