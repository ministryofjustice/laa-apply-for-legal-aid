module Reports
  module MIS
    class NonPassportedApplicationCsvLine
      attr_reader :laa

      delegate :provider, to: :laa

      def self.header_row
        %w[
          application_ref
          state
          username
          provider_email
          created_at
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
        @line << laa.provider.username
        @line << provider.email
        @line << laa.created_at.in_time_zone.strftime('%Y-%m-%d %H:%M:%S')
      end
    end
  end
end
