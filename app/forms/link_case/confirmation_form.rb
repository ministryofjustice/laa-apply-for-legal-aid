module LinkCase
  class ConfirmationForm < BaseForm
    form_for LinkedApplication

    attr_accessor :link_type_code

    validates :link_type_code, presence: true, unless: proc { draft? }

    def save
      return if invalid? || draft?

      legal_aid_application.update!(link_case: link_type_code == "false" ? nil : true)

      if link_type_code.eql?("false")
        model.destroy!
      else
        model.update!(link_type_code:)
      end
    end
    alias_method :save!, :save

  private

    def legal_aid_application
      LegalAidApplication.find(model.associated_application_id)
    end
  end
end
