module CFE
  class CreateDependantsService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/dependants"
    end

    def request_body
      puts ">>>>>>>>>>>> request bogy #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
      puts({ dependants: dependants_data }.to_json)
      puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
      {
        dependants: dependants_data
      }.to_json
    end

    private

    def process_response
      @submission.dependants_created!
    end

    def dependants_data
      array = []
      legal_aid_application.dependants.each { |d| array << dependant_data(d) }
      array
    end

    def dependant_data(dependant)
      dependant.as_json
    end
  end
end
