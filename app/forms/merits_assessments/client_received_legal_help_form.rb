module MeritsAssessments
  class ClientReceivedLegalHelpForm
    include BaseForm

    form_for MeritsAssessment

    attr_accessor :client_received_legal_help, :application_purpose

    before_validation :clear_application_purpose
    validates :client_received_legal_help, presence: true
    validates :application_purpose, presence: true, if: proc { |form| form.client_received_legal_help.to_s == 'false' }

    private

    def clear_application_purpose
      application_purpose.clear if client_received_legal_help.to_s == 'true'
    end
  end
end
