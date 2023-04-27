module CFECivil
  module Components
    class Dependants < BaseDataBlock
      def call
        {
          dependants: dependants_data,
        }.to_json
      end

    private

      def dependants_data
        legal_aid_application.dependants.each_with_object([]) { |d, arr| arr << dependant_data(d) }
      end

      def dependant_data(dependant)
        dependant.as_json
      end
    end
  end
end
