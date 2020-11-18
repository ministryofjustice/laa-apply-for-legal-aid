module Applicants
  class EmailForm
    include BaseForm

    form_for Applicant

    attr_accessor :email

    before_validation :strip_email

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :email, presence: true, unless: :draft?

    def strip_email
      email.strip!
    end
  end
end
