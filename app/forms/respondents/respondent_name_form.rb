module Respondents
  class RespondentNameForm
    include BaseForm

    form_for Respondent

    attr_accessor :full_name

    validates :full_name,
              presence: true,
              unless: :draft?
  end
end
