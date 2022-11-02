module LegalAidApplications
  class HasOtherProceedingsForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :has_other_proceeding

    validates :has_other_proceeding, presence: true, unless: :draft?
    validate :at_least_one_domestic_abuse, unless: -> { draft? || has_other_proceeding? }

    delegate :proceedings, to: :model

    def draft!
      @draft = true
    end

    def has_other_proceeding?
      @has_other_proceeding == "true"
    end

  private

    def at_least_one_domestic_abuse
      errors.add(:has_other_proceeding, :must_add_domestic_abuse) unless
        proceedings_include_domestic_abuse?
    end

    def exclude_from_model
      [:has_other_proceeding]
    end

    def proceedings_include_domestic_abuse?
      proceedings.any?(&:domestic_abuse?)
    end
  end
end
