module Providers
  module ApplicationMeritsTask
    class StatementOfCaseUploadForm < BaseFileUploaderForm
      form_for ::ApplicationMeritsTask::StatementOfCase

      attr_accessor :original_file, :original_filename, :provider_uploader, :upload_button_pressed

      def exclude_from_model
        %i[upload_button_pressed original_file original_filename]
      end

      validate :at_least_one_file_or_draft
      validate :file_uploaded?
      validate :original_file_valid

      def save
        result = super
        return unless original_file

        # create and save statement_of_case model only if attachments were made
        model.save!(validate: false) if statement_of_case_uploaded?
        # return result which returns 300 for redirect to fix tests
        result
      end
      alias_method :save!, :save

    private

      def at_least_one_file_or_draft
        return if any_statements_of_case_or_draft?

        @errors.add(:original_file, :no_file_chosen)
      end

      def any_statements_of_case_or_draft?
        statement_of_case_uploaded? || original_file.present? || draft?
      end

      def statement_of_case_uploaded?
        model.legal_aid_application.statement_of_case_uploaded?
      end

      def original_file_valid
        return if original_file.nil?

        @original_filename = original_file.original_filename
        scanner_down(original_file)
        malware_scan(original_file)
        file_empty(original_file)
        disallowed_content_type(original_file)
        too_big(original_file)
        create_attachment(original_file) if errors.blank?
      end
    end
  end
end
