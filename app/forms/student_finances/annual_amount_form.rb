module StudentFinances
  class AnnualAmountForm
    include BaseForm

    form_for IrregularIncome

    attr_accessor :income_type, :frequency, :amount, :legal_aid_application_id

    validates :amount,
              currency: {
                greater_than_or_equal_to: 0,
                allow_blank: true,
                message: I18n.t('activemodel.errors.models.legal_aid_application.attributes.annual_amount.not_a_number')
              },
              presence: { unless: :draft?, message: I18n.t('activemodel.errors.models.legal_aid_application.attributes.annual_amount.blank') }
  end
end
