module SmokeTest
  class TestEmails
    def self.call
      new.call
    end

    def call
      send_feedback_email
      send_citizen_start_email
      send_resend_link_request_email
      send_citizen_completed_means_email
      send_submission_confirmation_email
      send_email_reminder
    end

    private

    def send_email_reminder
      SubmitApplicationReminderMailer.notify_provider(
        legal_aid_application.id,
        legal_aid_application.provider.name,
        to
      ).deliver_later!
    end

    def send_citizen_completed_means_email
      CitizenCompletedMeansMailer.notify_provider(
        JSON.parse(legal_aid_application.to_json),
        JSON.parse(legal_aid_application.provider.name.to_json),
        JSON.parse(legal_aid_application.applicant.full_name.to_json),
        'www.example.com/providers/applications',
        to
      ).deliver_later!
    end

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
      SubmissionConfirmationMailer.notify(legal_aid_application.id).deliver_later!
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
      @legal_aid_application || FactoryBot.create(
        :legal_aid_application,
        :with_applicant,
        :with_delegated_functions,
        :with_substantive_application_deadline_on,
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
