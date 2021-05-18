class BinaryChoiceForm
  include ActiveModel::Model

  validate :input_present?

  class << self
    def call(journey:, radio_buttons_input_name:, action: :show, form_params: nil, error: nil)
      attr_accessor radio_buttons_input_name.to_sym

      define_input_conditional(radio_buttons_input_name, form_params) if form_params
      new(journey, radio_buttons_input_name, action, form_params, error)
    end

    def define_input_conditional(input_name, form_params)
      define_method "#{input_name}?" do
        form_params[input_name] == 'true'
      end
    end
  end

  def initialize(journey, radio_buttons_input_name, action, form_params, error)
    super(form_params)
    @journey = journey
    @input_name = radio_buttons_input_name
    @action = action
    @error = error || 'error'
  end

  private

  def input_present?
    errors.add @input_name.to_sym, error_message if blank_value? || bad_value?
  end

  def blank_value?
    __send__(@input_name).blank?
  end

  def bad_value?
    %w[true false].exclude? __send__(@input_name)
  end

  def error_message
    I18n.t("#{@journey.to_s.pluralize}.#{@input_name.to_s.pluralize}.#{@action}.#{@error}")
  end
end
