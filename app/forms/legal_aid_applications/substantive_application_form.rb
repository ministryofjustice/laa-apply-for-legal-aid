module LegalAidApplications
  class SubstantiveApplicationForm
    include BaseForm
    form_for LegalAidApplication

    attr_accessor :substantive_application

    validates :substantive_application, presence: { unless: :draft? }

    delegate :substantive_application_deadline_on, to: :model
  end
end
