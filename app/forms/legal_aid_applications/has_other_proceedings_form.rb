module LegalAidApplications
  class HasOtherProceedingsForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :has_other_proceeding

    validate :radio_button_selected?

    validate :at_least_one_domestic_abuse

    delegate :proceeding_types, to: :model

    def draft!
      @draft = true
    end

    def radio_button_selected?
      return if draft?

      errors.add(:has_other_proceeding, I18n.t('providers.has_other_proceedings.show.error')) if @has_other_proceeding.blank?
    end

    def at_least_one_domestic_abuse
      return if draft? || has_other_proceeding == 'true'

      return if proceeding_types_include_domestic_abuse?

      errors.add(:base, I18n.t('providers.has_other_proceedings.show.must_add_domestic_abuse'))
    end

    def exclude_from_model
      [:has_other_proceeding]
    end

    def proceeding_types_include_domestic_abuse?
      proceeding_types.map(&:domestic_abuse?).include?(true)
    end

    def has_other_proceeding? # rubocop:disable Naming/PredicateName
      @has_other_proceeding == 'true'
    end
  end
end
