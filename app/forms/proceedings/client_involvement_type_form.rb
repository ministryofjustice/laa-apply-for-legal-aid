module Proceedings
  class ClientInvolvementTypeForm < BaseForm
    include ProceedingLoopResettable

    form_for Proceeding

    attr_accessor :client_involvement_type_ccms_code, :all_client_involvement_types

    before_validation :assign_client_involvement_type_description,
                      if: -> { client_involvement_type_ccms_code.present? }

    validates :client_involvement_type_ccms_code, presence: true, unless: :draft?

    set_callback :save, :before, :client_involvement_type_changed
    set_callback :save, :after, :reset_proceeding_loop, if: :client_involvement_type_changed?

    def initialize(*args)
      @all_client_involvement_types = args.first[:cit_types]
      args.first.delete(:cit_types)
      super
    end

    def client_involvement_types
      # TODO: AP-6988 Move the logic to remove Child Subject if applicant_over_18? to LFA
      @client_involvement_types ||= all_client_involvement_types.reject { |cit| cit.ccms_code == "W" if applicant_over_18? }
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
      all_client_involvement_types.find do |client_involvement_type|
        client_involvement_type.ccms_code == client_involvement_type_ccms_code
      end
    end

    def applicant_date_of_birth
      @applicant_date_of_birth ||= model.legal_aid_application&.applicant&.date_of_birth
    end

    def applicant_over_18?
      return false unless applicant_date_of_birth

      as_of = model.used_delegated_functions_on || Date.current
      age = AgeCalculator.call(applicant_date_of_birth, as_of)
      age >= 18
    end
  end
end
