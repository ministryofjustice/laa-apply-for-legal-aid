module CFE
  class SubmissionManager

    def self.call(legal_aid_application_id)
      new(legal_aid_application_id).call
    end

    def initialize(legal_aid_application_id)
      @legal_aid_application_id = legal_aid_application_id
    end

    def call
      assessment = CFE::Submission.create!(legal_aid_application_id: @legal_aid_application_id)

      begin
        CFE::CreateAssessmentService.call(assessment)
        assessment.create_assessment!

        assessment.create_applicant! unless assessment.failed?
      rescue CFE::SubmissionError => err
        puts ">>>>>>>>> trapping error #{__FILE__}:#{__LINE__} <<<<<<<<<<\n"
        assessment.fail!

      end

    end
  end
end
