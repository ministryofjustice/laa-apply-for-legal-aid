module Providers
  module ApplicationDependable
    extend ActiveSupport::Concern

    class_methods do
      def legal_aid_application_not_required!
        @legal_aid_application_not_required = true
      end

      def legal_aid_application_not_required?
        @legal_aid_application_not_required
      end

      def skip_provider_step_update
        @skip_provider_step_update || []
      end

      def skip_provider_step_update_for(*actions)
        @skip_provider_step_update = actions.map(&:to_sym)
      end
    end

    included do
      before_action :encode_upload_header
      before_action :set_legal_aid_application

      # Let ActiveRecord::RecordNotFound bubble up for handling by exceptions_app as a 404
      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
      end
      delegate :applicant, to: :legal_aid_application

    private

      def set_legal_aid_application
        return if self.class.legal_aid_application_not_required?

        legal_aid_application.update!(provider_step:, provider_step_params:) unless provider_step == :delete || self.class.skip_provider_step_update.include?(action_name.to_sym)
      end

      def provider_step_params
        params.except(:action, :controller, :legal_aid_application_id)
      end

      def provider_step
        respond_to?(:current_step) ? __send__(:current_step) : controller_name
      end

      def encode_upload_header(x_params = nil)
        return unless request.content_mime_type&.symbol == :multipart_form

        x_params ||= params

        x_params.each_value do |v|
          case v
          when ActionController::Parameters
            encode_upload_header(v)
          when ActionDispatch::Http::UploadedFile
            encode_header(v.headers)
          end
        end
      end

      def encode_header(headers)
        headers.encode!(Encoding::UTF_8)
      rescue EncodingError
        headers.force_encoding(Encoding::UTF_8)
      end
    end
  end
end
