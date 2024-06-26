module HMRC
  module Interface
    class ResultService < BaseService
      def call
        raw_response = run_get_request
        parsed_response = parse_json_response(raw_response.body)
        case raw_response.status
        when 200, 202
          parsed_response
        else
          raise HMRC::InterfaceError.new(detailed_error(parsed_response, @hmrc_response.url), raw_response.status)
        end
      end

    private

      def run_get_request
        conn.get(@hmrc_response.url)
      rescue StandardError => e
        catch_and_record_exception(e)
      end
    end
  end
end
