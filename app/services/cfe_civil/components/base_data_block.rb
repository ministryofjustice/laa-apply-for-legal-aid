module CFECivil
  module Components
    class BaseDataBlock
      attr_reader :legal_aid_application

      def self.call(legal_aid_application)
        new(legal_aid_application).call
      end

      def initialize(legal_aid_application)
        @legal_aid_application = legal_aid_application
      end
    end
  end
end
