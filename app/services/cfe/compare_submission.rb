module CFE
  class CompareSubmission
    # NOTE: This is intended as a temporary class while we switch from CFE-Legacy to CFE-Civil
    # Once that change over is complete, the aim is that this can be removed, along with
    # the save_result: attribute for submission_builder

    def initialize(legal_aid_application, submission_builder)
      @legal_aid_application = legal_aid_application
      @submission_builder = submission_builder
      @results = {}
    end

    def self.call(legal_aid_application, submission_builder)
      new(legal_aid_application, submission_builder).call
    end

    def call
      raise StandardError, "Cannot compare CFE results" if missing_data?

      build_results
      CFE::StoreCompareResult.call([Time.current,
                                    @legal_aid_application.cfe_result.created_at,
                                    current_env,
                                    @results.empty?,
                                    @legal_aid_application.id,
                                    @legal_aid_application.cfe_result.id,
                                    JSON.pretty_generate(@submission_builder.request_body),
                                    JSON.pretty_generate(JSON.parse(@legal_aid_application.cfe_result.result)),
                                    JSON.pretty_generate(JSON.parse(@submission_builder.cfe_result)),
                                    JSON.pretty_generate(JSON.parse(@results.to_json))])
      @results.empty?
    end

  private

    def current_env
      if HostEnv.environment == :uat
        [HostEnv.environment, ENV.fetch("APP_BRANCH", "")].join("_")
      else
        HostEnv.environment.to_s
      end
    end

    def build_results
      @v5_result = parse_json(@legal_aid_application.cfe_result.result)
      @v6_result = parse_json(@submission_builder.cfe_result)
      @v5_result.each_key do |key|
        process_key([key])
      end
      @results
    end

    def process_key(key)
      test_value = @v5_result.dig(*key)
      case test_value
      when Hash
        test_value.each_key do |sub_key|
          process_key key.dup << sub_key
        end
      when Array
        if test_value.count == 1
          test_value.each_with_index do |_values, index|
            process_key key.dup << index
          end
        elsif test_value.count > 1
          test_value.each do |values|
            case values
            when Hash
              compare_array(key, values, @v6_result.dig(*key).find { |group| group[values.keys.first] == values[values.keys.first] })
            when String
              # this should be an array of strings so test the above level
              result = test_value - @v6_result.dig(*key)
              @results[key.join("/")] = "CFE-Legacy=#{test_value}, CFE-Civil=#{@v6_result.dig(*key)}" unless result.empty?
            end
          end
        end
      else
        return if ignore(key)
        return if compare_values(test_value, @v6_result.dig(*key))

        @results[key.join("/")] = "CFE-Legacy=#{test_value}, CFE-Civil=#{@v6_result.dig(*key)}"
      end
    end

    def ignore(key)
      [
        /assessment-capital-capital_items-vehicles-\d-date_of_purchase/,
        /assessment-capital-capital_items-properties-main_home-main_home_equity_disregard/,
        /result_summary-capital-assessed_capital/,
      ].any? { |pattern| pattern.match?(key.join("-")) }
    end

    def compare_array(key, v5_array, v6_array)
      v5_array.each_key do |key_name|
        next if compare_values(v5_array[key_name], v6_array[key_name])

        @results[key.join("/")] = "CFE-Legacy=#{v5_array[key_name]}, CFE-Civil=#{v6_array[key_name]}"
      end
    end

    def compare_values(v5_value, v6_value)
      if v6_value.is_a?(Numeric) || v5_value.is_a?(Numeric)
        sprintf("%.2f", v6_value) == sprintf("%.2f", v5_value)
      else
        v6_value == v5_value
      end
    end

    def parse_json(json)
      parsed = JSON.parse(json)
      # strip out known clashes
      parsed["assessment"]["id"] = :ignored
      parsed["assessment"]["submission_date"] = :ignored
      parsed.except!("timestamp", "version")
    end

    def missing_data?
      missing_correct_cfe_result? || missing_submission_builder?
    end

    def missing_correct_cfe_result?
      @legal_aid_application.nil? ||
        @legal_aid_application.cfe_result.nil? ||
        @legal_aid_application.cfe_result.type != "CFE::V5::Result"
    end

    def missing_submission_builder?
      @submission_builder.nil? ||
        JSON.parse(@submission_builder.cfe_result)["version"] != "6"
    end
  end
end
