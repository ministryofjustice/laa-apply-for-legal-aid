module Applicants
  class EmailForm
    include BaseForm

    form_for Applicant

    attr_accessor :email

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :email, presence: true
  end
end
