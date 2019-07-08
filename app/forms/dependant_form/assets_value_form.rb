module DependantForm
  class AssetsValueForm
    include BaseForm

    form_for Dependant

    attr_accessor :has_assets_more_than_threshold, :assets_value

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
      numericality: {
        greater_than_or_equal_to: 8_000,
        message: ->(form, _) { form.less_than_threshold_error_message }
      },
      if: :assets_more_than_threshold?
    )

    def assets_more_than_threshold?
      has_assets_more_than_threshold&.to_s == 'true'
    end

    def save
      attributes[:assets_value] = nil if valid? && !assets_more_than_threshold?
      super
    end

    def attributes_to_clean
      [:assets_value]
    end

    def blank_option_error_message
      I18n.t(
        'activemodel.errors.models.dependant.attributes.has_assets_more_than_threshold.blank_message',
        name: model.name
      )
    end

    def less_than_threshold_error_message
      I18n.t(
        'activemodel.errors.models.dependant.attributes.assets_value.less_than_threshold',
        name: model.name
      )
    end
  end
end
