module Applicants
  class EmailForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    include BaseForm
    extend BaseForm::ClassMethods

    form_for Applicant

    attr_accessor :email_address

    validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :email_address, presence: true

    def model
      legal_aid_application.applicant
    end
  end
end
