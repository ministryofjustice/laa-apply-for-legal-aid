module Applicants
  class EmailForm
    include BaseForm

    form_for Applicant

    attr_accessor :email_address

    validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :email_address, presence: true
  end
end
