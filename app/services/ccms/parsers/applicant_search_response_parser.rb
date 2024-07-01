module CCMS
  module Parsers
    class ApplicantSearchResponseParser < BaseResponseParser
      TRANSACTION_ID_PATH = "//Body//ClientInqRS//HeaderRS//TransactionID".freeze
      RECORD_COUNT_PATH = "//Body//ClientInqRS//RecordCount//RecordsFetched".freeze

      ClientResult = Struct.new(:first_initial, :last_name, :last_name_at_birth, :date_of_birth, :national_insurance_number, :client_reference, :match)

      def initialize(tx_request_id, response, applicant)
        @applicant = applicant
        super(tx_request_id, response)
      end

      def record_count
        @record_count ||= parse(:extracted_record_count)
      end

      def applicant_ccms_reference
        @applicant_ccms_reference ||= process_ccms_reference
      end

    private

      def process_ccms_reference
        if client_list.present?
          client_array = build_client_result_array
          client_array.each do |client|
            parse_client(client)
          end
          full_data_matches = client_array.select(&:match)
          choice = full_data_matches.one? ? full_data_matches.first.client_reference : nil
        else
          full_data_matches = []
          choice = nil
        end
        log_message("CCMS records returned: #{extracted_record_count}, Full matches: #{full_data_matches.count}, ChosenMatch: #{choice}")
        choice
      end

      def response_type
        "ClientInqRS".freeze
      end

      def extracted_transaction_request_id
        text_from(TRANSACTION_ID_PATH)
      end

      def extracted_record_count
        text_from(RECORD_COUNT_PATH)
      end

      def client_list
        @client_list ||= Hash.from_xml(doc.xpath("//Body//ClientInqRS//ClientList").to_s)&.deep_transform_keys { |k| k.underscore.to_sym }
      end

      def build_client_result_array
        all_data = multiple_clients_returned? ? client_list[:client_list][:client] : [client_list[:client_list][:client]]
        all_data.each_with_object([]) do |client_data, payload|
          payload << ClientResult.new(first_initial: client_data[:name][:first_name].first,
                                      last_name: client_data[:name][:surname],
                                      last_name_at_birth: client_data[:name][:surname_at_birth],
                                      date_of_birth: client_data[:date_of_birth],
                                      national_insurance_number: client_data[:ni_number],
                                      client_reference: client_data[:client_reference_number])
        end
      end

      def parse_client(client_struct)
        client_struct.match = [
          @applicant.first_name.gsub(/[’‘]/, CCMS::Requestors::BaseRequestor::CHARACTERS).first.casecmp?(client_struct.first_initial),
          @applicant.last_name.gsub(/[’‘]/, CCMS::Requestors::BaseRequestor::CHARACTERS).casecmp?(client_struct.last_name),
          @applicant.surname_at_birth.gsub(/[’‘]/, CCMS::Requestors::BaseRequestor::CHARACTERS).casecmp?(client_struct.last_name_at_birth),
          @applicant.date_of_birth.strftime("%Y-%m-%d").eql?(client_struct.date_of_birth),
          (@applicant.national_insurance_number || "").casecmp?(client_struct.national_insurance_number),
        ].all?
      end

      def multiple_clients_returned?
        client_list[:client_list][:client].instance_of?(Array)
      end
    end
  end
end
