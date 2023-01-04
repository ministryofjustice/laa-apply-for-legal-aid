module CCMS
  class CaseAddRequestorFactory
    def self.call(submission, options)
      if submission.legal_aid_application.passported?
        Requestors::CaseAddRequestor.new(submission, options)
      elsif submission.legal_aid_application.non_means_tested?
        Requestors::NonMeansTestedCaseAddRequestor.new(submission, options)
      else
        Requestors::NonPassportedCaseAddRequestor.new(submission, options)
      end
    end
  end
end
