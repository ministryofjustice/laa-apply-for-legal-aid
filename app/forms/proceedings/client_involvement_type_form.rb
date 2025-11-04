module Proceedings
  class ClientInvolvementTypeForm < BaseForm
    include ProceedingLoopResettable

    form_for Proceeding

    attr_accessor :client_involvement_type_ccms_code

    before_validation :assign_client_involvement_type_description,
                      if: -> { client_involvement_type_ccms_code.present? }

    validates :client_involvement_type_ccms_code, presence: true, unless: :draft?

    set_callback :save, :before, :client_involvement_type_changed
    set_callback :save, :after, :reset_proceeding_loop, if: :client_involvement_type_changed?

    def client_involvement_types
      @client_involvement_types ||= LegalFramework::ClientInvolvementTypes::Proceeding.call(model.ccms_code)
    end

  private

    def client_involvement_type_changed
      @client_involvement_type_changed ||= client_involvement_type_ccms_code != model.client_involvement_type_ccms_code
    end
    alias_method :client_involvement_type_changed?, :client_involvement_type_changed

    def assign_client_involvement_type_description
      model.client_involvement_type_description = client_involvement_type.description
    end

    def client_involvement_type
      client_involvement_types.find do |client_involvement_type|
        client_involvement_type.ccms_code == client_involvement_type_ccms_code
      end
    end
  end
end
