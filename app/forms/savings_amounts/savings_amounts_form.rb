module SavingsAmounts
  class SavingsAmountsForm
    include BaseForm

    form_for SavingsAmount

    ATTRIBUTES = %i[
      isa
      cash
      other_person_account
      national_savings
      plc_shares
      peps_unit_trusts_capital_bonds_gov_stocks
      life_assurance_endowment_policy
    ].freeze

    CHECK_BOXES_ATTRIBUTES = ATTRIBUTES.map { |attribute| "check_box_#{attribute}".to_sym }.freeze

    ATTRIBUTES.each do |attribute|
      check_box_attribute = "check_box_#{attribute}".to_sym
      validates attribute, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
      validates attribute, presence: true, if: proc { |form| form.send(check_box_attribute).present? }
    end

    attr_accessor(*ATTRIBUTES)
    attr_accessor(*CHECK_BOXES_ATTRIBUTES)

    before_validation :empty_unchecked_values, :normalize_amounts

    def exclude_from_model
      CHECK_BOXES_ATTRIBUTES
    end

    private

    def empty_unchecked_values
      ATTRIBUTES.each do |attribute|
        check_box_attribute = "check_box_#{attribute}".to_sym
        if send(check_box_attribute).blank?
          attributes[attribute] = nil
          send("#{attribute}=", nil)
        end
      end
    end

    def normalize_amounts
      ATTRIBUTES
        .map { |attribute| send(attribute) }
        .compact
        .each { |value| value.delete!(',') }
    end
  end
end
