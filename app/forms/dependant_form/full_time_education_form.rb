module DependantForm
  class FullTimeEducationForm
    include BaseForm
    form_for Dependant

    attr_accessor :in_full_time_education

    validates(
      :in_full_time_education,
      presence: { message: ->(form, _) { form.error_message } },
      unless: :draft?
    )

    def error_message
      I18n.t(
        'activemodel.errors.models.dependant.attributes.in_full_time_education.blank_message',
        name: model.name
      )
    end
  end
end
