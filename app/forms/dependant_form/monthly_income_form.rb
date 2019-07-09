module DependantForm
  class MonthlyIncomeForm
    include BaseForm
    form_for Dependant

    before_validation :clear_monthly_income

    attr_accessor :has_income, :monthly_income

    validates :has_income, presence: { message: ->(form, _) { form.error_message } }
    validates :monthly_income, presence: true, if: proc { |form| form.has_income.to_s == 'true' }
    validates :monthly_income, allow_blank: true, currency: { greater_than: 0.0 }

    def attributes_to_clean
      [:monthly_income]
    end

    def error_message
      I18n.t('activemodel.errors.models.dependant.attributes.has_income.blank_message', name: model.name)
    end

    private

    def clear_monthly_income
      monthly_income&.clear unless ActiveModel::Type::Boolean.new.cast(has_income.to_s)
    end
  end
end
