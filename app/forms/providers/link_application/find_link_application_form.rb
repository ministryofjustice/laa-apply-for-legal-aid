module Providers
  module LinkApplication
    class FindLinkApplicationForm < BaseForm
      form_for LinkedApplication

    #   APPLICATION_REF_REGEXP = /\AL-[0-9ABCDEFHIJKLMNPRTUVWXY]{3}-[0-9ABCDEFHIJKLMNPRTUVWXY]{3}\z/

    #   # Is link_type_code what you want for attr_accessor or do you want something like search_ref?
    #   # Do you also need  :lead_application_id?
    #   attr_accessor :link_type_code

    #   # Validate that the LAA reference field is not empty and is in the correct format?
    #   validates :link_type_code,
    #             presence: true,
    #             format: { with: APPLICATION_REF_REGEXP },
    #             unless: draft?

    # # Add validations
    #   # If no case found. Use same validation and error message for: If case found, but it was submitted by another firm.
    #   # If case found but has not yet been submitted

    #   def case_exists
    #     errors.add(:link_type_code, :not_found) unless case_found?
    #   end

    #   def case_found?
    #     # Add definition here
    #   end
    end
  end
end
