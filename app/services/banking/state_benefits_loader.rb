module Banking
  Struct.new("Benefit", :code, :label, :name, :excluded?)

  class StateBenefitsLoader
    attr_accessor :state_benefit_codes

    def self.call
      new.call
    end

    def initialize
      @state_benefit_codes = {}
    end

    def call
      load_state_benefit_types
      state_benefit_codes
    end

  private

    def load_state_benefit_types
      state_benefit_list.each do |state_benefit|
        next if state_benefit["dwp_code"].nil?

        store_benefit(state_benefit)
      end
    end

    def state_benefit_list
      CFECivil::ObtainStateBenefitTypesService.call
    end

    def store_benefit(state_benefit)
      benefit = Struct::Benefit.new(state_benefit["dwp_code"], state_benefit["label"], state_benefit["name"], state_benefit["exclude_from_gross_income"])
      state_benefit_codes[benefit.code] = benefit
    end
  end
end
