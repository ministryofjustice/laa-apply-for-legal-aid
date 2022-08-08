module Proceedings
  class ClientInvolvementTypeForm < BaseForm
    form_for Proceeding

    attr_accessor :client_involvement_type_ccms_code

    validates :client_involvement_type_ccms_code, presence: true

    def save
      extrapolate_client_involvement_type_description if client_involvement_type_ccms_code
      super
    end

    def client_involvement_types
      @client_involvement_types ||= LegalFramework::ClientInvolvementTypes::All.call
    end

  private

    def extrapolate_client_involvement_type_description
      model.client_involvement_type_description = client_involvement_types.filter_map { |cit| cit.description if cit.ccms_code == client_involvement_type_ccms_code }.reduce
    end
  end
end
