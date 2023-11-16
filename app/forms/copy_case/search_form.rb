module CopyCase
  class SearchForm < BaseForm
    form_for LegalAidApplication

    APPLICATION_REF_REGEXP = /\AL-[0-9ABCDEFHIJKLMNPRTUVWXY]{3}-[0-9ABCDEFHIJKLMNPRTUVWXY]{3}\z/

    attr_accessor :search_ref, :copiable_case

    validates :search_ref,
              presence: true,
              format: { with: APPLICATION_REF_REGEXP },
              unless: :draft?

    validate :case_exists, unless: :draft?

    def save
      return false unless valid?

      model.update!(copied_case_id: copiable_case.id) unless draft?

      true
    end
    alias_method :save!, :save

    def case_exists
      errors.add(:search_ref, :not_found) unless case_found?
    end

    def case_found?
      @copiable_case = LegalAidApplication
                        .where(provider: model.provider)
                        .find_by(application_ref: search_ref)
    end
  end
end
