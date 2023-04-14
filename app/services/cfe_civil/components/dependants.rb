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
        array = []
        legal_aid_application.dependants.each { |d| array << dependant_data(d) }
        array
      end

      def dependant_data(dependant)
        dependant.as_json
      end
    end
  end
end
