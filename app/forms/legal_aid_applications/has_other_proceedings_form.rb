module LegalAidApplications
  class HasOtherProceedingsForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :has_other_proceeding

    validates :has_other_proceeding, presence: true, unless: :draft?

    delegate :proceedings, to: :model

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
