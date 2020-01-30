module CCMS
  module Parsers
    class DocumentUploadResponseParser < BaseResponseParser
      STATUS_PATH = '//Body//DocumentUploadRS//HeaderRS//Status'.freeze

      def success?
        /Success/.match?(parse(:extracted_status))
      end

      def parse(data_method)
        __send__(data_method)
      end

      private

      def extracted_status
        text_from(STATUS_PATH)
      end
    end
  end
end
