module ChancesOfSuccesses
  class SuccessLikelyForm
    include BaseForm

    form_for ProceedingMeritsTask::ChancesOfSuccess

    attr_accessor :success_likely

    validates :success_likely, presence: true, unless: :draft?
    before_validation :set_success_prospect

    private

    def set_success_prospect
      if success_likely == 'true'
        model.success_prospect = :likely
        model.success_prospect_details = nil
      elsif model.success_prospect_likely?
        model.success_prospect = nil
      end
    end
  end
end
