module LinkCase
  class SearchForm < BaseForm
    form_for LinkedApplication

    attr_accessor :search_ref, :linkable_case, :legal_aid_application

    APPLICATION_REF_REGEXP = /\AL-[0-9ABCDEFHIJKLMNPRTUVWXY]{3}-[0-9ABCDEFHIJKLMNPRTUVWXY]{3}\z/

    validates :search_ref,
              presence: true,
              format: { with: APPLICATION_REF_REGEXP },
              unless: :draft?

    validate :case_exists, unless: :draft?

    def save
      return false if invalid? || draft?

      model.lead_application_id = linkable_case&.id
      model.associated_application_id = legal_aid_application.id
      model.save!(validate: false)
    end
    alias_method :save!, :save

    def case_exists
      errors.add(:search_ref, :not_found) unless case_found?
    end

    # TODO: restrict to firm / provider applications - will be done in AP-4510
    def case_found?
      @linkable_case = LegalAidApplication.find_by(application_ref: search_ref)
    end
  end
end
