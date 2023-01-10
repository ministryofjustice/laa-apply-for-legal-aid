module LegalAidApplications
  class ConfirmClientDeclarationForm < BaseForm
    include ActiveModel::Attributes

    form_for LegalAidApplication

    attribute :client_declaration_confirmed, :boolean

    validates :client_declaration_confirmed,
              acceptance: true, allow_nil: false, unless: :draft?

    def save
      return false unless valid?

      model.update!(client_declaration_confirmed_at: Time.current)
    end

    alias_method :save!, :save
  end
end
