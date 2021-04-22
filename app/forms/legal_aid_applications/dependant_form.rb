module LegalAidApplications
  class DependantForm  # rubocop:disable Metrics/ClassLength
    include BaseForm
    form_for Dependant

    before_validation :clear_value_fields

    BASE_ATTRIBUTES = %i[name relationship in_full_time_education has_income
                         monthly_income has_assets_more_than_threshold assets_value].freeze

    MODEL_ATTRIBUTES = BASE_ATTRIBUTES + %i[date_of_birth].freeze

    ATTRIBUTES = BASE_ATTRIBUTES + %i[date_of_birth_1i date_of_birth_2i date_of_birth_3i].freeze

    SCOPE = 'activemodel.errors.models.dependant.attributes'.freeze

    attr_accessor(*ATTRIBUTES)
    attr_writer :date_of_birth

    validates :name, presence: true
    validates :date_of_birth, presence: true
    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        earliest_allowed_date: { date: '1900-01-01' }
      },
      allow_nil: true
    )
    validate :relationship_presence
    validate :full_time_education_presence
    validate :validate_has_income_presence
    validates :monthly_income, presence: true, if: proc { |form| form.has_income.to_s == 'true' }
    validates :monthly_income, allow_blank: true, currency: { greater_than: 0.0 }
    validates(
      :has_assets_more_than_threshold,
      presence: { message: ->(form, _) { form.blank_option_error_message } },
      unless: :draft?
    )

    validates(
      :assets_value,
      currency: { allow_blank: true },
      presence: { unless: :draft? },
      if: :assets_more_than_threshold?
    )

    validates(
      :assets_value,
      currency: {
        greater_than_or_equal_to: 8_000,
        message: ->(form, _) { form.less_than_threshold_error_message }
      },
      if: :assets_more_than_threshold?
    )

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: date_fields.fields,
        model_attributes: date_fields.model_attributes
      )
    end

    def attributes_to_clean
      %i[monthly_income assets_value]
    end

    # Note that this method is first called by `validates`.
    # Without that validation, the functionality in this method will not be called before save
    def date_of_birth
      return @date_of_birth if @date_of_birth.present?
      return if date_fields.blank?
      return date_fields.input_field_values if date_fields.partially_complete? || date_fields.form_date_invalid?

      @date_of_birth = attributes[:date_of_birth] = date_fields.form_date
    end

    def save
      attributes[:assets_value] = nil if valid? && !assets_more_than_threshold?
      super
    end

    def blank_option_error_message
      I18n.t('.has_assets_more_than_threshold.blank_message', scope: SCOPE, name: model.name)
    end

    def assets_more_than_threshold?
      has_assets_more_than_threshold.to_s == 'true'
    end

    def less_than_threshold_error_message
      I18n.t('activemodel.errors.models.dependant.attributes.assets_value.less_than_threshold', name: model.name)
    end

    private

    def exclude_from_model
      date_fields.fields
    end

    def date_fields
      @date_fields ||= DateFieldBuilder.new(
        form: self,
        model: model,
        method: :date_of_birth,
        prefix: :date_of_birth_,
        suffix: :gov_uk
      )
    end

    def relationship_presence
      return if relationship.present?

      errors.add(:relationship, I18n.t('.relationship.blank', scope: SCOPE, name: model.name))
    end

    def full_time_education_presence
      return if in_full_time_education.present?

      errors.add(:in_full_time_education, I18n.t('.in_full_time_education.blank_message', scope: SCOPE, name: model.name))
    end

    def validate_has_income_presence
      return if has_income.present?

      errors.add(:has_income, I18n.t('.has_income.blank_message', scope: SCOPE, name: model.name))
    end

    def clear_value_fields
      monthly_income&.clear unless ActiveModel::Type::Boolean.new.cast(has_income.to_s)
      assets_value&.clear unless ActiveModel::Type::Boolean.new.cast(has_assets_more_than_threshold.to_s)
    end
  end
end
