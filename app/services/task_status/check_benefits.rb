# Check benefits is complete if
# - Check applicant answers has been progressed
# - and if non-means-tested, they have confirmed they are are haopy to proceed (how can we tell this
# - and if no national insurance number, they have confirmed they are happy to proceed (how can we tell this)
# - and if benefits response is negative they have confirmed they have either:
#   confirmed they are not receiving benefits
#   gone through the optional route to specify they are on benefits and provided evidence.
#
module TaskStatus
  class CheckBenefits < Base
    def call
      status = ValueObject.new

      # TODO: we might need a history of transitions
      status.cannot_start! unless previous_sections.all?(&:completed?)

      status.not_started! if previous_sections.all?(&:completed?) && !application.checking_applicant_details?

      status.completed! if previous_sections.all?(&:completed?) && (non_means_tested? || passported? || non_passported? || benefits_confirmed?)

      status
    end

    delegate :passported?, :non_passported?, :non_means_tested?, to: :application

  private

    # TODO: how can we check if they have confirmed they are are happy to proceed
    def benefits_confirmed?
      !application&.applicant&.national_insurance_number? || true
    end

    def previous_sections
      @previous_sections ||= [
        Applicants.new(application).call,
        ProceedingsTypes.new(application).call,
        HasNationalInsuranceNumbers.new(application).call,
      ]
    end
  end
end
