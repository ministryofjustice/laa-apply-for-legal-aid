module Applicants
  class UsesOnlineBankingForm
    include BaseForm

    form_for Applicant

    attr_accessor :uses_online_banking

    validates :uses_online_banking, presence: true
  end
end
