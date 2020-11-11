module Reports
  module MIS
    class NonPassportedApplicationCsvLine
      include Sanitisable
      attr_reader :laa

      delegate :provider, to: :laa

      def self.header_row
        %w[
          application_ref
          state
          ccms_reason
          username
          provider_email
          created_at
          applicant_name
          deleted
        ]
      end

      def self.call(legal_aid_application)
        new(legal_aid_application).call
      end

      def initialize(legal_aid_application)
        @laa = legal_aid_application
        @line = []
      end

      def call
        @line << laa.application_ref
        @line << laa.state
        @line << laa.ccms_reason
        @line << laa.provider.username
        @line << provider.email
        @line << laa.created_at.strftime('%Y-%m-%d %H:%M:%S')
        @line << laa.applicant.full_name
        @line << deleted?(laa)
        sanitise
      end

      def deleted?(laa)
        laa.discarded? ? 'Y' : ''
      end
    end
  end
end
