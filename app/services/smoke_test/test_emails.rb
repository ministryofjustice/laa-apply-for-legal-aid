module SmokeTest
  class TestEmails
    def self.call
      new.call
    end

    def call
      send_feedback_email
      send_citizen_start_email
      send_resend_link_request_email
      send_submission_confirmation_email
    end

    private

    def send_feedback_email
      FeedbackMailer.notify(
        JSON.parse(feedback.to_json),
        to
      ).deliver_later!
    end

    def send_citizen_start_email
      NotifyMailer.citizen_start_email(*citizen_start_email_args).deliver_later!
    end

    def send_resend_link_request_email
      ResendLinkRequestMailer.notify(
        JSON.parse(legal_aid_application.to_json),
        JSON.parse(legal_aid_application.provider.to_json),
        JSON.parse(legal_aid_application.applicant.to_json),
        to
      ).deliver_later!
    end

    def send_submission_confirmation_email
      SubmissionConfirmationMailer.notify(
        JSON.parse(legal_aid_application.to_json),
        JSON.parse(legal_aid_application.provider.to_json),
        JSON.parse(legal_aid_application.applicant.to_json)
      ).deliver_later!
    end

    def citizen_start_email_args
      [
        legal_aid_application.application_ref,
        to,
        '/applications/123/citizen/start',
        legal_aid_application.applicant_full_name
      ]
    end

    def legal_aid_application
      @legal_aid_application || FactoryBot.build(
        :legal_aid_application,
        :with_applicant,
        provider: provider,
        application_ref: SecureRandom.hex
      )
    end

    def provider
      FactoryBot.build(:provider, id: SecureRandom.uuid, email: to)
    end

    def feedback
      FactoryBot.build(:feedback, :with_timestamps)
    end

    def to
      Rails.configuration.x.smoke_test_email_address
    end
  end
end
