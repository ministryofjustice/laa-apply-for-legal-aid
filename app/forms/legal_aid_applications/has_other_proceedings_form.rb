module LegalAidApplications
  class HasOtherProceedingsForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :has_other_proceeding

    validates :has_other_proceeding, presence: true, unless: :draft?

    delegate :proceedings, to: :model

    def remaining_proceedings
      @remaining_proceedings ||= LegalFramework::ProceedingTypes::All.call(model).count
    rescue LegalFramework::ProceedingTypes::All::NoMatchingProceedingsFoundError
      0
    end

    def draft!
      @draft = true
    end

    def has_other_proceeding?
      @has_other_proceeding == "true"
    end

  private

    def exclude_from_model
      [:has_other_proceeding]
    end
  end
end
